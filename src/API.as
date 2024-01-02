// c 2024-01-02
// m 2024-01-02

uint64 latestNandoRequest = 0;

void NandoRequestWait() {
    if (latestNandoRequest == 0) {
        latestNandoRequest = Time::Now;
        return;
    }

    while (Time::Now - latestNandoRequest < 1000)
        yield();

    latestNandoRequest = Time::Now;
}

void GetMaps() {
    while (!NadeoServices::IsAuthenticated(audienceLive))
        yield();

    Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
    while (coro.IsRunning())
        yield();

    Net::HttpRequest@ req = NadeoServices::Get(
        audienceLive,
        NadeoServices::BaseURLLive() + "/api/token/campaign/month?length=999&offset=0"
    );
    req.Start();
    while (!req.Finished())
        yield();

    int code = req.ResponseCode();
    if (code != 200) {
        warn("error getting maps: " + code + "; " + req.Error() + "; " + req.String());
        return;
    }

    Json::Value@ monthList = Json::Parse(req.String())["monthList"];

    for (int i = monthList.Length - 1; i >= 0; i--) {
        Json::Value@ days = monthList[i]["days"];

        for (uint j = 0; j < days.Length; j++) {
            Map@ map = Map(monthList[i]["year"], monthList[i]["month"], days[j]);

            if (map.uid.Length > 0) {
                maps.InsertLast(map);
                mapsDict.Set(map.uid, @map);
            }
        }
    }

    GetMapInfo();
}

void GetMapInfo() {
    while (!NadeoServices::IsAuthenticated(audienceCore))
        yield();

    uint index = 0;
    string url;

    while (index < maps.Length - 1) {
        url = NadeoServices::BaseURLCore() + "/maps/?mapUidList=";

        for (uint i = index; i < maps.Length; i++) {
            index = i;

            if (url.Length < 8192)
                url += maps[i].uid + ",";
            else
                break;
        }

        Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
        while (coro.IsRunning())
            yield();

        trace("getting map info (" + (index + 1) + "/" + maps.Length + ")");

        Net::HttpRequest@ req = NadeoServices::Get(audienceCore, url);
        req.Start();
        while (!req.Finished())
            yield();

        int code = req.ResponseCode();
        if (code != 200) {
            warn("error getting map info: " + code + "; " + req.Error() + "; " + req.String());
            return;
        }

        Json::Value@ mapInfo = Json::Parse(req.String());

        for (uint i = 0; i < mapInfo.Length; i++) {
            Map@ map = cast<Map@>(mapsDict[mapInfo[i]["mapUid"]]);

            map.authorTime  = mapInfo[i]["authorScore"];
            map.bronzeTime  = mapInfo[i]["bronzeScore"];
            map.downloadUrl = mapInfo[i]["fileUrl"];
            map.goldTime    = mapInfo[i]["goldScore"];
            map.id          = mapInfo[i]["mapId"];
            map.nameRaw     = mapInfo[i]["name"];
            map.silverTime  = mapInfo[i]["silverScore"];

            map.nameClean = StripFormatCodes(map.nameRaw);
            map.nameColored = ColoredString(map.nameRaw);
            map.nameQuoted = "\"" + map.nameClean + "\"";
        }
    }

    for (uint i = 0; i < maps.Length; i++) {
        Map@ map = maps[i];
        print(map.date + " " + map.nameColored + "\\$G: " + Time::Format(map.authorTime));
    }

    GetRecords();
}

void GetRecords() {
    ;
}