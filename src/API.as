// c 2024-01-02
// m 2024-01-08

#if TMNEXT

uint64       latestNandoRequest   = 0;
Json::Value@ mapsCampaignFromFile = Json::Object();
Json::Value@ mapsTotdFromFile     = Json::Object();

void NandoRequestWait() {
    if (latestNandoRequest == 0) {
        latestNandoRequest = Time::Now;
        return;
    }

    while (Time::Now - latestNandoRequest < 1000)
        yield();  // wait 1000ms between requests

    latestNandoRequest = Time::Now;
}

void GetMaps() {
    if (gettingNow)
        return;

    gettingNow = true;

    progressCount = 0;

    maps.RemoveRange(0, maps.Length);
    mapsByUid.DeleteAll();

    mapsCampaign.RemoveRange(0, mapsCampaign.Length);
    mapsCampaignById.DeleteAll();
    mapsCampaignByUid.DeleteAll();

    mapsTotd.RemoveRange(0, mapsTotd.Length);
    mapsTotdById.DeleteAll();
    mapsTotdByUid.DeleteAll();

    GetMapsFromApi(Mode::NadeoCampaign);
    GetMapsFromApi(Mode::TrackOfTheDay);
    GetMapsFromFiles();
    GetMapInfoFromApi(Mode::NadeoCampaign);
    GetMapInfoFromApi(Mode::TrackOfTheDay);
    GetRecordsFromApi(Mode::NadeoCampaign);
    GetRecordsFromApi(Mode::TrackOfTheDay);
    SetNextMap();

    gettingNow = false;
}

void GetMapsFromApi(Mode mode) {
    yield();

    while (!NadeoServices::IsAuthenticated(audienceLive))
        yield();

    string modeName = tostring(mode);

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

    int code = req.ResponseCode();
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
        @mapsCampaignFromFile = Json::FromFile("src/Assets/next_campaign.json");

        for (uint i = 0; i < mapsCampaignFromFile.Length; i++) {
            Json::Value@ mapFromFile = mapsCampaignFromFile[ZPad4(i)];
            string uid = mapFromFile["uid"];

            Map@ map = cast<Map@>(mapsCampaignByUid[uid]);

            if (map is null) {
                warn("GetMapsFromFiles: null Campaign map " + uid);
                continue;
            }

            map.authorTime  = mapFromFile["authorTime"];
            map.bronzeTime  = mapFromFile["bronzeTime"];
            map.downloadUrl = mapFromFile["downloadUrl"];
            map.goldTime    = mapFromFile["goldTime"];
            map.id          = mapFromFile["id"];
            map.nameRaw     = mapFromFile["nameRaw"];
            map.silverTime  = mapFromFile["silverTime"];

            map.SetNames();

            mapsCampaignById.Set(map.id, @map);
        }
    }

    if (mapsTotdFromFile.Length == 0) {
        @mapsTotdFromFile = Json::FromFile("src/Assets/next_totd.json");

        for (uint i = 0; i < mapsTotdFromFile.Length; i++) {
            Json::Value@ mapFromFile = mapsTotdFromFile[ZPad4(i)];
            string uid = mapFromFile["uid"];

            Map@ map = cast<Map@>(mapsTotdByUid[uid]);

            if (map is null) {
                warn("GetMapsFromFiles: null TOTD map " + uid);
                continue;
            }

            map.authorTime  = mapFromFile["authorTime"];
            map.bronzeTime  = mapFromFile["bronzeTime"];
            map.date        = mapFromFile["date"];
            map.downloadUrl = mapFromFile["downloadUrl"];
            map.goldTime    = mapFromFile["goldTime"];
            map.id          = mapFromFile["id"];
            map.nameRaw     = mapFromFile["nameRaw"];
            map.silverTime  = mapFromFile["silverTime"];

            map.SetNames();

            mapsTotdById.Set(map.id, @map);
        }
    }

    trace("getting maps from files done");
}

void GetMapInfoFromApi(Mode mode) {
    yield();

    while (!NadeoServices::IsAuthenticated(audienceCore))
        yield();

    string modeName = tostring(mode);

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

    while (mapsStillNeedInfo.Length > 0 && index < mapsStillNeedInfo.Length - 1) {
        url = NadeoServices::BaseURLCore() + "/maps/?mapUidList=";

        for (uint i = index; i < mapsStillNeedInfo.Length; i++) {
            index = i;
            progressCount++;

            if (url.Length < 8192)
                url += mapsStillNeedInfo[i].uid + ",";
            else
                break;
        }

        Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
        while (coro.IsRunning())
            yield();

        trace("getting " + modeName + " map info from API (" + (index + 1) + "/" + mapsStillNeedInfo.Length + ")");

        Net::HttpRequest@ req = NadeoServices::Get(audienceCore, url);
        req.Start();
        while (!req.Finished())
            yield();

        int code = req.ResponseCode();
        if (code != 200) {
            warn("error getting " + modeName + " map info from API: " + code + "; " + req.Error() + "; " + req.String());
            return;
        }

        Json::Value@ mapInfo = Json::Parse(req.String());

        for (uint i = 0; i < mapInfo.Length; i++) {
            string uid = mapInfo[i]["mapUid"];

            Map@ map;
            if (mode == Mode::NadeoCampaign)
                @map = cast<Map@>(mapsCampaignByUid[uid]);
            else
                @map = cast<Map@>(mapsTotdByUid[uid]);

            if (map is null) {
                warn("GetMapInfoFromApi: null " + modeName + " map " + uid);
                continue;
            }

            map.authorTime  = mapInfo[i]["authorScore"];
            map.bronzeTime  = mapInfo[i]["bronzeScore"];
            map.downloadUrl = mapInfo[i]["fileUrl"];
            map.goldTime    = mapInfo[i]["goldScore"];
            map.id          = mapInfo[i]["mapId"];
            map.nameRaw     = mapInfo[i]["name"];
            map.silverTime  = mapInfo[i]["silverScore"];

            map.SetNames();

            if (mode == Mode::NadeoCampaign && !mapsCampaignById.Exists(map.id))
                mapsCampaignById.Set(map.id, @map);

            else if (mode == Mode::TrackOfTheDay && !mapsTotdById.Exists(map.id))
                mapsTotdById.Set(map.id, @map);
        }
    }

    trace("getting " + modeName + " map info from API done");
}

void GetRecordsFromApi(Mode mode) {
    gettingNow = true;

    yield();

    string modeName = tostring(mode);

    trace("getting " + modeName + " records from API...");

    uint index = 0;
    string url;

    Map@[]@ mapsToCheck = mode == Mode::NadeoCampaign ? mapsCampaign : mapsTotd;

    while (index < mapsToCheck.Length - 1) {
        url = NadeoServices::BaseURLCore() + "/mapRecords/?accountIdList=" + accountId + "&mapIdList=";

        for (uint i = index; i < mapsToCheck.Length; i++) {
            index = i;
            progressCount++;

            if (url.Length < 8183)
                url += mapsToCheck[i].id + ",";
            else
                break;
        }

        trace("getting " + modeName + " records (" + (index + 1) + "/" + mapsToCheck.Length + ")");

        Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
        while (coro.IsRunning())
            yield();

        Net::HttpRequest@ req = NadeoServices::Get(audienceCore, url.SubStr(0, url.Length - 1));
        req.Start();
        while (!req.Finished())
            yield();

        int code = req.ResponseCode();
        if (code != 200) {
            warn("error getting " + modeName + " records: " + code + "; " + req.Error() + "; " + req.String());
            gettingNow = false;
            return;
        }

        Json::Value@ records = Json::Parse(req.String());

        for (uint i = 0; i < records.Length; i++) {
            string id = records[i]["mapId"];

            Map@ map;
            if (mode == Mode::NadeoCampaign)
                @map = cast<Map@>(mapsCampaignById[id]);
            else
                @map = cast<Map@>(mapsTotdById[id]);

            if (map is null) {
                warn("GetRecordsFromApi: null " + modeName + " map " + id);
                continue;
            }

            map.myMedals = records[i]["medal"];
            map.myTime = records[i]["recordScore"]["time"];
        }
    }

    trace("getting " + modeName + " records done");

    if (mode == Mode::NadeoCampaign) {
        maps = mapsCampaign;
        mapsByUid = mapsCampaignByUid;
    } else {
        maps = mapsTotd;
        mapsByUid = mapsTotdByUid;
    }
}

#endif