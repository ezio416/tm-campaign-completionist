// c 2024-01-02
// m 2024-09-12

uint64       latestNandoRequest   = 0;
Json::Value@ mapsCampaignFromFile = Json::Object();
Json::Value@ mapsTotdFromFile     = Json::Object();

void NandoRequestWait() {
    if (latestNandoRequest == 0) {
        latestNandoRequest = Time::Now;
        return;
    }

    while (Time::Now - latestNandoRequest < 1000)  // wait 1000ms between requests
        yield();

    latestNandoRequest = Time::Now;
}

void GetMaps() {
    if (gettingNow)
        return;

    gettingNow = true;

    mapsCampaign = {};
    mapsCampaignById.DeleteAll();
    mapsCampaignByUid.DeleteAll();

    mapsTotd = {};
    mapsTotdById.DeleteAll();
    mapsTotdByUid.DeleteAll();

    GetMapsFromApi(Mode::NadeoCampaign);
    GetMapsFromApi(Mode::TrackOfTheDay);
    GetMapsFromFiles();
    GetMapInfoFromApi(Mode::NadeoCampaign);
    GetMapInfoFromApi(Mode::TrackOfTheDay);
    startnew(GetAllPBsAsyncCached);
    gettingNow = false;
    SetNextMap();
}

void GetMapsFromApi(Mode mode) {
    yield();

    while (!NadeoServices::IsAuthenticated(audienceLive))
        yield();

    const string modeName = tostring(mode);

    trace("getting " + modeName + " maps from API...");

    Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
    while (coro.IsRunning())
        yield();

    Net::HttpRequest@ req = NadeoServices::Get(
        audienceLive,
        NadeoServices::BaseURLLive() + "/api/token/campaign/" + (mode == Mode::NadeoCampaign ? "official" : "month") + "?length=99&offset=0"
    );  // length 99 will work until 2045 (campaign) or 2029 (TOTD)
    req.Start();
    while (!req.Finished())
        yield();

    const int code = req.ResponseCode();
    if (code != 200) {
        warn("error getting " + modeName + " maps from API: " + code + "; " + req.Error() + "; " + req.String());
        return;
    }

    if (mode == Mode::NadeoCampaign) {
        Json::Value@ campaignList = Json::Parse(req.String())["campaignList"];

        for (int i = campaignList.Length - 1; i >= 0; i--) {
            Json::Value@ playlist = campaignList[i]["playlist"];

            for (uint j = 0; j < playlist.Length; j++) {
                Map@ map = Map(playlist[j]);

                if (mapsCampaignByUid.Exists(map.uid))
                    continue;  // should never happen but who knows at this point

                mapsCampaign.InsertLast(map);
                mapsCampaignByUid.Set(map.uid, @map);
            }
        }
    } else {
        Json::Value@ monthList = Json::Parse(req.String())["monthList"];

        for (int i = monthList.Length - 1; i >= 0; i--) {
            Json::Value@ days = monthList[i]["days"];

            for (uint j = 0; j < days.Length; j++) {
                Map@ map = Map(monthList[i]["year"], monthList[i]["month"], days[j]);

                if (map.uid.Length > 0) {
                    if (mapsTotdByUid.Exists(map.uid))
                        continue;  // should never happen, but it did on 2024-01-06 so ¯\_(ツ)_/¯

                    mapsTotd.InsertLast(map);
                    mapsTotdByUid.Set(map.uid, @map);
                }
            }
        }
    }

    trace("getting " + modeName + " maps from API done");
}

void GetMapsFromFiles() {
    yield();

    trace("getting maps from files...");

    if (mapsCampaignFromFile.Length == 0) {
        @mapsCampaignFromFile = Json::FromFile("assets/next_campaign.json");

        for (uint i = 0; i < mapsCampaignFromFile.Length; i++) {
            Json::Value@ mapFromFile = mapsCampaignFromFile[ZPad4(i)];
            const string uid = mapFromFile["uid"];

            Map@ map = cast<Map@>(mapsCampaignByUid[uid]);

            if (map is null) {
                warn("GetMapsFromFiles: null Campaign map " + uid);
                continue;
            }

            map.authorTime = mapFromFile["authorTime"];
            map.bronzeTime = mapFromFile["bronzeTime"];
            map.goldTime   = mapFromFile["goldTime"];
            map.id         = mapFromFile["id"];
            map.nameRaw    = mapFromFile["nameRaw"];
            map.silverTime = mapFromFile["silverTime"];

            map.SetNames();
            map.SetSeason(Mode::NadeoCampaign);

            mapsCampaignById.Set(map.id, @map);
        }
    }

    if (mapsTotdFromFile.Length == 0) {
        @mapsTotdFromFile = Json::FromFile("assets/next_totd.json");

        for (uint i = 0; i < mapsTotdFromFile.Length; i++) {
            Json::Value@ mapFromFile = mapsTotdFromFile[ZPad4(i)];
            const string uid = mapFromFile["uid"];

            Map@ map = cast<Map@>(mapsTotdByUid[uid]);

            if (map is null) {
                warn("GetMapsFromFiles: null TOTD map " + uid);
                continue;
            }

            map.authorTime = mapFromFile["authorTime"];
            map.bronzeTime = mapFromFile["bronzeTime"];
            map.date       = "\\$S" + string(mapFromFile["date"]);
            map.goldTime   = mapFromFile["goldTime"];
            map.id         = mapFromFile["id"];
            map.nameRaw    = mapFromFile["nameRaw"];
            map.silverTime = mapFromFile["silverTime"];

            map.SetNames();
            map.SetSeason(Mode::TrackOfTheDay);

            mapsTotdById.Set(map.id, @map);
        }
    }

    trace("getting maps from files done");
}

void GetMapInfoFromApi(Mode mode) {
    yield();

    while (!NadeoServices::IsAuthenticated(audienceCore))
        yield();

    const string modeName = tostring(mode);

    trace("getting " + modeName + " map info from API...");

    uint index = 0;
    string url;

    Map@[] mapsStillNeedInfo;
    Map@[]@ mapsToCheck = mode == Mode::NadeoCampaign ? mapsCampaign : mapsTotd;

    for (uint i = 0; i < mapsToCheck.Length; i++) {
        Map@ map = mapsToCheck[i];

        if (map.nameRaw.Length == 0)
            mapsStillNeedInfo.InsertLast(map);
    }

    while (mapsStillNeedInfo.Length > 0 && (index == 0 || index < mapsStillNeedInfo.Length - 1)) {
        url = NadeoServices::BaseURLCore() + "/maps/?mapUidList=";

        for (uint i = index; i < mapsStillNeedInfo.Length; i++) {
            index = i;

            if (url.Length < 8192)
                url += mapsStillNeedInfo[i].uid + ",";
            else
                break;
        }

        Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
        while (coro.IsRunning())
            yield();

        trace("getting " + modeName + " map info from API (" + (index + 1) + "/" + mapsStillNeedInfo.Length + ")");

        Net::HttpRequest@ req = NadeoServices::Get(audienceCore, url.SubStr(0, url.Length - 1));
        req.Start();
        while (!req.Finished())
            yield();

        const int code = req.ResponseCode();
        if (code != 200) {
            warn("error getting " + modeName + " map info from API: " + code + "; " + req.Error() + "; " + req.String());
            return;
        }

        Json::Value@ mapInfo = Json::Parse(req.String());

        for (uint i = 0; i < mapInfo.Length; i++) {
            const string uid = mapInfo[i]["mapUid"];

            Map@ map;
            if (mode == Mode::NadeoCampaign)
                @map = cast<Map@>(mapsCampaignByUid[uid]);
            else
                @map = cast<Map@>(mapsTotdByUid[uid]);

            if (map is null) {
                warn("GetMapInfoFromApi: null " + modeName + " map: " + uid);
                continue;
            }

            map.authorTime = mapInfo[i]["authorScore"];
            map.bronzeTime = mapInfo[i]["bronzeScore"];
            map.goldTime   = mapInfo[i]["goldScore"];
            map.id         = mapInfo[i]["mapId"];
            map.nameRaw    = mapInfo[i]["name"];
            map.silverTime = mapInfo[i]["silverScore"];

            map.SetNames();
            map.SetSeason(mode);

            if (mode == Mode::NadeoCampaign && !mapsCampaignById.Exists(map.id))
                mapsCampaignById.Set(map.id, @map);

            else if (mode == Mode::TrackOfTheDay && !mapsTotdById.Exists(map.id))
                mapsTotdById.Set(map.id, @map);
        }

        if (mapsStillNeedInfo.Length == 1)
            break;
    }

    trace("getting " + modeName + " map info from API done");
}

void RefreshRecords() {
    GetAllPBsAsyncForceRefresh();
}


class ClearTask {
    CWebServicesTaskResult@ task;
    CMwNod@ nod;

    CGameUserManagerScript@ userMgr { get { return cast<CGameUserManagerScript>(nod); } }
    CGameDataFileManagerScript@ dataFileMgr { get { return cast<CGameDataFileManagerScript>(nod); } }
    CGameScoreAndLeaderBoardManagerScript@ scoreMgr { get { return cast<CGameScoreAndLeaderBoardManagerScript>(nod); } }

    ClearTask(CWebServicesTaskResult@ task, CMwNod@ owner) {
        @this.task = task;
        @nod = owner;
    }

    void Release() {
        if (userMgr !is null) userMgr.TaskResult_Release(task.Id);
        else if (dataFileMgr !is null) dataFileMgr.TaskResult_Release(task.Id);
        else if (scoreMgr !is null) scoreMgr.TaskResult_Release(task.Id);
        else throw("ClearTask.Release called but I don't know how to handle this type: " + Reflection::TypeOf(nod).Name);
    }
}

ClearTask@[] tasksToClear;

// Wait for the task to finish processing, then add it to the list of tasks to be cleared later. Execution returns immediately, so you should consume all data in the task before yielding.
void WaitAndClearTaskLater(CWebServicesTaskResult@ task, CMwNod@ owner) {
    while (task.IsProcessing) yield();
    // clearing tasks that don't succeed mb causes a crash?
    if (task.HasSucceeded)
        tasksToClear.InsertLast(ClearTask(task, owner));
}

void ClearTaskCoro() {
    while (true) {
        yield();
        if (tasksToClear.Length == 0) continue;
        // give a little buffer, rather than doing it next frame
        uint toClear = tasksToClear.Length;
        sleep(50);
        for (uint i = 0; i < toClear; i++) {
            tasksToClear[i].Release();
        }
        tasksToClear.RemoveRange(0, toClear);
    }
}

void ClearAllTasksNow() {
    uint n = tasksToClear.Length;
    for (uint i = 0; i < tasksToClear.Length; i++) {
        tasksToClear[i].Release();
    }
    tasksToClear.RemoveRange(0, n);
}