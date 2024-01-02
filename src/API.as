// c 2024-01-02
// m 2024-01-02

uint64 latestNandoRequest = 0;

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

    progressCount = 0;

    while (!NadeoServices::IsAuthenticated(audienceLive))
        yield();

    Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
    while (coro.IsRunning())
        yield();

    trace("getting " + (S_Mode == Mode::NadeoCampaign ? "campaign" : "TOTD") + " maps");

    maps.RemoveRange(0, maps.Length);
    mapsByUid.DeleteAll();

    if (S_Mode == Mode::NadeoCampaign) {
        mapsCampaign.RemoveRange(0, mapsCampaign.Length);
        mapsCampaignById.DeleteAll();
        mapsCampaignByUid.DeleteAll();
    } else {
        mapsTotd.RemoveRange(0, mapsTotd.Length);
        mapsTotdById.DeleteAll();
        mapsTotdByUid.DeleteAll();
    }

    Net::HttpRequest@ req = NadeoServices::Get(
        audienceLive,
        NadeoServices::BaseURLLive() + "/api/token/campaign/" + (S_Mode == Mode::NadeoCampaign ? "official" : "month") + "?length=999&offset=0"
    );
    req.Start();
    while (!req.Finished())
        yield();

    int code = req.ResponseCode();
    if (code != 200) {
        warn("error getting " + (S_Mode == Mode::NadeoCampaign ? "campaign" : "TOTD") + " maps: " + code + "; " + req.Error() + "; " + req.String());
        return;
    }

    if (S_Mode == Mode::NadeoCampaign) {
        Json::Value@ campaignList = Json::Parse(req.String())["campaignList"];

        for (int i = campaignList.Length - 1; i >= 0; i--) {
            Json::Value@ playlist = campaignList[i]["playlist"];

            for (uint j = 0; j < playlist.Length; j++) {
                Map@ map = Map(playlist[j]);

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
                    mapsTotd.InsertLast(map);
                    mapsTotdByUid.Set(map.uid, @map);
                }
            }
        }
    }

    trace("getting " + (S_Mode == Mode::NadeoCampaign ? "campaign" : "TOTD") + " maps done");

    GetMapInfo();
}

void GetMapInfo() {
    while (!NadeoServices::IsAuthenticated(audienceCore))
        yield();

    uint index = 0;
    string url;

    Map@[] mapsToCheck = S_Mode == Mode::NadeoCampaign ? mapsCampaign : mapsTotd;

    while (index < mapsToCheck.Length - 1) {
        url = NadeoServices::BaseURLCore() + "/maps/?mapUidList=";

        for (uint i = index; i < mapsToCheck.Length; i++) {
            index = i;
            progressCount++;

            if (url.Length < 8192)
                url += mapsToCheck[i].uid + ",";
            else
                break;
        }

        Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
        while (coro.IsRunning())
            yield();

        trace("getting " + (S_Mode == Mode::NadeoCampaign ? "campaign" : "TOTD") + " map info (" + (index + 1) + "/" + mapsToCheck.Length + ")");

        Net::HttpRequest@ req = NadeoServices::Get(audienceCore, url);
        req.Start();
        while (!req.Finished())
            yield();

        int code = req.ResponseCode();
        if (code != 200) {
            warn("error getting " + (S_Mode == Mode::NadeoCampaign ? "campaign" : "TOTD") + " map info: " + code + "; " + req.Error() + "; " + req.String());
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

            map.nameClean = StripFormatCodes(map.nameRaw);
            map.nameColored = ColoredString(map.nameRaw);
            map.nameQuoted = "\"" + map.nameClean + "\"";

            if (S_Mode == Mode::NadeoCampaign)
                mapsCampaignById.Set(map.id, @map);
            else
                mapsTotdById.Set(map.id, @map);
        }
    }

    trace("getting " + (S_Mode == Mode::NadeoCampaign ? "campaign" : "TOTD") + " map info done");

    GetRecords();
}

void GetRecords() {
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

        Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
        while (coro.IsRunning())
            yield();

        trace("getting " + (S_Mode == Mode::NadeoCampaign ? "campaign" : "TOTD") + " records (" + (index + 1) + "/" + mapsToCheck.Length + ")");

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

    gettingNow = false;

    SetNextMap();
}