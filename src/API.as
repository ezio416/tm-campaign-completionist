// c 2024-01-02
// m 2024-01-07

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

    GetCampaignMapsFromApi();
    GetTotdMapsFromApi();
    GetMapsFromFiles();
    GetCampaignMapInfoFromApi();
    GetTotdMapInfoFromApi();
    GetRecordsFromApi();

    gettingNow = false;
}

void GetCampaignMapsFromApi() {
    yield();

    while (!NadeoServices::IsAuthenticated(audienceLive))
        yield();

    trace("getting campaign maps from API...");

    Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
    while (coro.IsRunning())
        yield();

    Net::HttpRequest@ req = NadeoServices::Get(
        audienceLive,
        NadeoServices::BaseURLLive() + "/api/token/campaign/official?length=99&offset=0"
    );  // length 99 will work until 2045
    req.Start();
    while (!req.Finished())
        yield();

    int code = req.ResponseCode();
    if (code != 200) {
        warn("error getting campaign maps from API: " + code + "; " + req.Error() + "; " + req.String());
        return;
    }

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

    trace("getting campaign maps from API done");
}

void GetTotdMapsFromApi() {
    yield();

    while (!NadeoServices::IsAuthenticated(audienceLive))
        yield();

    trace("getting TOTD maps from API...");

    Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
    while (coro.IsRunning())
        yield();

    Net::HttpRequest@ req = NadeoServices::Get(
        audienceLive,
        NadeoServices::BaseURLLive() + "/api/token/campaign/month?length=99&offset=0"
    );  // length 99 will work until 2029
    req.Start();
    while (!req.Finished())
        yield();

    int code = req.ResponseCode();
    if (code != 200) {
        warn("error getting TOTD maps: " + code + "; " + req.Error() + "; " + req.String());
        return;
    }

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

    trace("getting TOTD maps from API done");
}

void GetMapsFromFiles() {
    yield();

    trace("getting maps from files...");

    if (mapsCampaignFromFile.Length == 0) {
        @mapsCampaignFromFile = Json::FromFile("src/Assets/next_campaign.json");

        for (uint i = 0; i < mapsCampaignFromFile.Length; i++) {
            Json::Value@ mapFromFile = mapsCampaignFromFile[ZPad4(i)];

            Map@ map = cast<Map@>(mapsCampaignByUid[string(mapFromFile["uid"])]);

            map.downloadUrl = mapFromFile["downloadUrl"];
            map.id          = mapFromFile["id"];
            map.nameRaw     = mapFromFile["nameRaw"];

            map.SetNames();
        }
    }

    if (mapsTotdFromFile.Length == 0) {
        @mapsTotdFromFile = Json::FromFile("src/Assets/next_totd.json");

        for (uint i = 0; i < mapsTotdFromFile; i++) {
            Json::Value@ mapFromFile = mapsTotdFromFile[ZPad4(i)];

            Map@ map = cast<Map@>(mapsTotdByUid[string(mapFromFile["uid"])]);

            map.date        = mapFromFile["date"];
            map.downloadUrl = mapFromFile["downloadUrl"];
            map.id          = mapFromFile["id"];
            map.nameRaw     = mapFromFile["nameRaw"];

            map.SetNames();
        }
    }

    trace("getting maps from files done");
}

void GetCampaignMapInfoFromApi() {
    yield();

    while (!NadeoServices::IsAuthenticated(audienceCore))
        yield();

    trace("getting campaign map info from API...");

    uint index = 0;
    string url;

    while (index < mapsCampaign.Length - 1) {
        url = NadeoServices::BaseURLCore() + "/maps/?mapUidList=";

        for (uint i = index; i < mapsCampaign.Length; i++) {
            index = i;
            progressCount++;

            if (url.Length < 8192)
                url += mapsCampaign[i].uid + ",";
            else
                break;
        }

        Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
        while (coro.IsRunning())
            yield();

        trace("getting campaign map info from API (" + (index + 1) + "/" + mapsCampaign.Length + ")");

        Net::HttpRequest@ req = NadeoServices::Get(audienceCore, url);
        req.Start();
        while (!req.Finished())
            yield();

        int code = req.ResponseCode();
        if (code != 200) {
            warn("error getting campaign map info from API: " + code + "; " + req.Error() + "; " + req.String());
            return;
        }

        Json::Value@ mapInfo = Json::Parse(req.String());

        for (uint i = 0; i < mapInfo.Length; i++) {
            Map@ map;

            if (S_Mode == Mode::NadeoCampaign)
                @map = cast<Map@>(mapsCampaignByUid[mapInfo[i]["mapUid"]]);
            else
                @map = cast<Map@>(mapsTotdByUid[mapInfo[i]["mapUid"]]);

            map.authorTime  = mapInfo[i]["authorScore"];
            map.bronzeTime  = mapInfo[i]["bronzeScore"];
            map.downloadUrl = mapInfo[i]["fileUrl"];
            map.goldTime    = mapInfo[i]["goldScore"];
            map.id          = mapInfo[i]["mapId"];
            map.nameRaw     = string(mapInfo[i]["name"]).Trim();
            map.silverTime  = mapInfo[i]["silverScore"];

            map.SetNames();

            if (S_Mode == Mode::NadeoCampaign)
                mapsCampaignById.Set(map.id, @map);
            else
                mapsTotdById.Set(map.id, @map);
        }
    }

    trace("getting campaign map info from API done");

    // MapsToJson();
}

void GetTotdMapInfoFromApi() {
    yield();

    while (!NadeoServices::IsAuthenticated(audienceCore))
        yield();

    trace("getting TOTD map info from API...");

    ;

    trace("getting TOTD map info from API done");
}

void GetRecordsFromApi() {
    yield();

    trace("getting records from API...");

    uint index = 0;
    string url;

    Map@[] mapsToCheck = S_Mode == Mode::NadeoCampaign ? mapsCampaign : mapsTotd;

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

        trace("getting " + (S_Mode == Mode::NadeoCampaign ? "campaign" : "TOTD") + " records (" + (index + 1) + "/" + mapsToCheck.Length + ")");

        Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
        while (coro.IsRunning())
            yield();

        Net::HttpRequest@ req = NadeoServices::Get(audienceCore, url.SubStr(0, url.Length - 1));
        req.Start();
        while (!req.Finished())
            yield();

        int code = req.ResponseCode();
        if (code != 200) {
            warn("error getting " + (S_Mode == Mode::NadeoCampaign ? "campaign" : "TOTD") + " records: " + code + "; " + req.Error() + "; " + req.String());
            return;
        }

        Json::Value@ records = Json::Parse(req.String());

        for (uint i = 0; i < records.Length; i++) {
            Map@ map;

            if (S_Mode == Mode::NadeoCampaign)
                @map = cast<Map@>(mapsCampaignById[records[i]["mapId"]]);
            else
                @map = cast<Map@>(mapsTotdById[records[i]["mapId"]]);

            map.myMedals = records[i]["medal"];
            map.myTime = records[i]["recordScore"]["time"];
        }
    }

    trace("getting records done");

    if (S_Mode == Mode::NadeoCampaign) {
        maps = mapsCampaign;
        mapsByUid = mapsCampaignByUid;
    } else {
        maps = mapsTotd;
        mapsByUid = mapsTotdByUid;
    }

    SetNextMap();
}

void MapsToJson() {
    if (S_Mode == Mode::NadeoCampaign) {
        if (mapsCampaign.Length == 0) {
            warn("MapsToJson: no campaign maps!");
            return;
        }
    } else {
        if (mapsTotd.Length == 0) {
            warn("MapsToJson: no TOTD maps!");
            return;
        }
    }

    Json::Value@ mapsForJson = Json::Object();

    Map@[]@ mapsToSave = S_Mode == Mode::NadeoCampaign ? mapsCampaign : mapsTotd;

    for (uint i = 0; i < mapsToSave.Length; i++) {
        Map@ map = mapsToSave[i];

        Json::Value@ mapJson = Json::Object();

        mapJson["authorTime"]  = map.authorTime;
        mapJson["bronzeTime"]  = map.bronzeTime;
        mapJson["downloadUrl"] = map.downloadUrl;
        mapJson["goldTime"]    = map.goldTime;
        mapJson["id"]          = map.id;
        mapJson["nameRaw"]     = map.nameRaw;
        mapJson["silverTime"]  = map.silverTime;
        mapJson["uid"]         = map.uid;

        if (S_Mode == Mode::TrackOfTheDay)
            mapJson["date"]    = map.date;

        mapsForJson[ZPad4(i)] = mapJson;
    }

    Json::ToFile(IO::FromDataFolder("/Plugins/CampaignCompletionist/next_" + (S_Mode == Mode::NadeoCampaign ? "campaign" : "totd") + "_raw.json"), mapsForJson);

    trace("MapsToJson: done");
}