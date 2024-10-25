// c 2024-01-02
// m 2024-10-24

// Json::Value@ mapsCampaignFromFile = Json::Object();
// Json::Value@ mapsTotdFromFile     = Json::Object();

void GetMaps() {
    for (uint i = 0; i < mapsCampaign.Length; i++)
        @mapsCampaign[i] = null;
    mapsCampaign = {};
    mapsCampaignById.DeleteAll();
    mapsCampaignByUid.DeleteAll();
    // API::GetMapsAsync(Mode::NadeoCampaign);

    for (uint i = 0; i < mapsTotd.Length; i++)
        @mapsTotd[i] = null;
    mapsTotd = {};
    mapsTotdById.DeleteAll();
    mapsTotdByUid.DeleteAll();
    // API::GetMapsAsync(Mode::TrackOfTheDay);

    // GetMapsFromFiles();
    // API::GetMapInfos(Mode::NadeoCampaign);
    // API::GetMapInfos(Mode::TrackOfTheDay);
    // GetAllPBsAsync();
    // SetNextMap();
}

// void GetMapsFromFiles() {
    // yield();

    // trace("getting maps from files...");

    // if (mapsCampaignFromFile.Length == 0) {
    //     @mapsCampaignFromFile = Json::FromFile("assets/next_campaign.json");

    //     for (uint i = 0; i < mapsCampaignFromFile.Length; i++) {
    //         Json::Value@ mapFromFile = mapsCampaignFromFile[ZPad4(i)];
    //         const string uid = mapFromFile["uid"];

    //         Map@ map = cast<Map@>(mapsCampaignByUid[uid]);

    //         if (map is null) {
    //             warn("GetMapsFromFiles: null Campaign map " + uid);
    //             continue;
    //         }

    //         map.authorTime = mapFromFile["authorTime"];
    //         map.bronzeTime = mapFromFile["bronzeTime"];
    //         map.goldTime   = mapFromFile["goldTime"];
    //         map.id         = mapFromFile["id"];
    //         map.nameRaw    = mapFromFile["nameRaw"];
    //         map.silverTime = mapFromFile["silverTime"];

    //         map.SetNames();
    //         map.SetSeason(Mode::NadeoCampaign);

    //         mapsCampaignById.Set(map.id, @map);
    //     }
    // }

    // if (mapsTotdFromFile.Length == 0) {
    //     @mapsTotdFromFile = Json::FromFile("assets/next_totd.json");

    //     for (uint i = 0; i < mapsTotdFromFile.Length; i++) {
    //         Json::Value@ mapFromFile = mapsTotdFromFile[ZPad4(i)];
    //         const string uid = mapFromFile["uid"];

    //         Map@ map = cast<Map@>(mapsTotdByUid[uid]);

    //         if (map is null) {
    //             warn("GetMapsFromFiles: null TOTD map " + uid);
    //             continue;
    //         }

    //         map.authorTime = mapFromFile["authorTime"];
    //         map.bronzeTime = mapFromFile["bronzeTime"];
    //         map.date       = "\\$S" + string(mapFromFile["date"]);
    //         map.goldTime   = mapFromFile["goldTime"];
    //         map.id         = mapFromFile["id"];
    //         map.nameRaw    = mapFromFile["nameRaw"];
    //         map.silverTime = mapFromFile["silverTime"];

    //         map.SetNames();
    //         map.SetSeason(Mode::TrackOfTheDay);

    //         mapsTotdById.Set(map.id, @map);
    //     }
    // }

    // trace("getting maps from files done");
// }

// void GetMapInfos(Mode mode) {
    // yield();

    // while (!NadeoServices::IsAuthenticated(audienceCore))
    //     yield();

    // const string modeName = tostring(mode);

    // trace("getting " + modeName + " map info from API...");

    // uint index = 0;
    // string url;

    // Map@[] mapsStillNeedInfo;
    // Map@[]@ mapsToCheck = mode == Mode::NadeoCampaign ? mapsCampaign : mapsTotd;

    // for (uint i = 0; i < mapsToCheck.Length; i++) {
    //     Map@ map = mapsToCheck[i];

    //     if (map.nameRaw.Length == 0)
    //         mapsStillNeedInfo.InsertLast(map);
    // }

    // while (mapsStillNeedInfo.Length > 0 && (index == 0 || index < mapsStillNeedInfo.Length - 1)) {
    //     url = NadeoServices::BaseURLCore() + "/maps/?mapUidList=";

    //     for (uint i = index; i < mapsStillNeedInfo.Length; i++) {
    //         index = i;

    //         if (url.Length < 8192)
    //             url += mapsStillNeedInfo[i].uid + ",";
    //         else
    //             break;
    //     }

    //     Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
    //     while (coro.IsRunning())
    //         yield();

    //     trace("getting " + modeName + " map info from API (" + (index + 1) + "/" + mapsStillNeedInfo.Length + ")");

    //     Net::HttpRequest@ req = NadeoServices::Get(audienceCore, url.SubStr(0, url.Length - 1));
    //     req.Start();
    //     while (!req.Finished())
    //         yield();

    //     const int code = req.ResponseCode();
    //     if (code != 200) {
    //         warn("error getting " + modeName + " map info from API: " + code + "; " + req.Error() + "; " + req.String());
    //         return;
    //     }

    //     Json::Value@ mapInfo = Json::Parse(req.String());

    //     for (uint i = 0; i < mapInfo.Length; i++) {
    //         const string uid = mapInfo[i]["mapUid"];

    //         Map@ map;
    //         if (mode == Mode::NadeoCampaign)
    //             @map = cast<Map@>(mapsCampaignByUid[uid]);
    //         else
    //             @map = cast<Map@>(mapsTotdByUid[uid]);

    //         if (map is null) {
    //             warn("GetMapInfos: null " + modeName + " map: " + uid);
    //             continue;
    //         }

    //         map.authorTime = mapInfo[i]["authorScore"];
    //         map.bronzeTime = mapInfo[i]["bronzeScore"];
    //         map.goldTime   = mapInfo[i]["goldScore"];
    //         map.id         = mapInfo[i]["mapId"];
    //         map.nameRaw    = mapInfo[i]["name"];
    //         map.silverTime = mapInfo[i]["silverScore"];

    //         map.SetNames();
    //         map.SetSeason(mode);

    //         if (mode == Mode::NadeoCampaign && !mapsCampaignById.Exists(map.id))
    //             mapsCampaignById.Set(map.id, @map);

    //         else if (mode == Mode::TrackOfTheDay && !mapsTotdById.Exists(map.id))
    //             mapsTotdById.Set(map.id, @map);
    //     }

    //     if (mapsStillNeedInfo.Length == 1)
    //         break;
    // }

    // trace("getting " + modeName + " map info from API done");
// }

// void RefreshRecords() {
    // GetAllPBsAsync();
    // SetNextMap();
// }

namespace API {
    const string audienceCore = "NadeoServices";
    const string audienceLive = "NadeoLiveServices";
    uint64       lastRequest  = 0;
    const uint64 minimumWait  = 1000;  // 1000 ms between any requests
    bool         requesting   = false;

    string get_urlCore() { return NadeoServices::BaseURLCore(); }
    string get_urlLive() { return NadeoServices::BaseURLLive(); }
    string get_urlMeet() { return NadeoServices::BaseURLMeet(); }

    Net::HttpRequest@ GetAsync(const string &in audience, const string &in url, bool start = true) {
        NadeoServices::AddAudience(audience);

        while (!NadeoServices::IsAuthenticated(audience) || requesting)
            yield();

        if (start)
            requesting = true;

        WaitAsync();

        Net::HttpRequest@ req = NadeoServices::Get(audience, url);
        if (start) {
            req.Start();
            while (!req.Finished())
                yield();

            requesting = false;
        }

        return req;
    }

    Net::HttpRequest@ GetCoreAsync(const string &in endpoint, bool start = true) {
        return GetAsync(audienceCore, urlCore + endpoint, start);
    }

    Net::HttpRequest@ GetLiveAsync(const string &in endpoint, bool start = true) {
        return GetAsync(audienceLive, urlLive + endpoint, start);
    }

    // void GetMapInfos(Mode mode) {
        // const string modeName = tostring(mode);

        // trace("getting " + modeName + " map infos from API...");

        // uint index = 0;
        // string endpoint;

        // Map@[] mapsStillNeedInfo;
        // Map@[]@ mapsToCheck = mode == Mode::NadeoCampaign ? mapsCampaign : mapsTotd;

        // for (uint i = 0; i < mapsToCheck.Length; i++) {
        //     Map@ map = mapsToCheck[i];

        //     if (map.name is null)
        //         mapsStillNeedInfo.InsertLast(map);
        // }

        // while (mapsStillNeedInfo.Length > 0 && (index == 0 || index < mapsStillNeedInfo.Length - 1)) {
        //     endpoint = "/maps/?mapUidList=";

        //     for (uint i = index; i < mapsStillNeedInfo.Length; i++) {
        //         index = i;

        //         if (endpoint.Length < 8124)  // 8192 - 41 (base url) - 27 (map uid max), allows ~291 maps depending on uid lengths
        //             endpoint += mapsStillNeedInfo[i].uid + ",";
        //         else
        //             break;
        //     }

        //     WaitAsync();

        //     trace("getting " + modeName + " map info from API (" + (index + 1) + "/" + mapsStillNeedInfo.Length + ")");

        //     Net::HttpRequest@ req = GetCoreAsync(endpoint.SubStr(0, endpoint.Length - 1));
        //     // IO::SetClipboard(req.Url);

        //     const int code = req.ResponseCode();
        //     if (code != 200) {
        //         warn("error getting " + modeName + " map info from API: " + code + "; " + req.Error() + "; " + req.String());
        //         return;
        //     }

        //     Json::Value@ mapInfo = req.Json();
        //     if (!JsonExt::CheckType(mapInfo, Json::Type::Array))
        //         continue;

        //     // IO::SetClipboard(Json::Write(mapInfo));
        //     // throw("hi");

        //     for (uint i = 0; i < mapInfo.Length; i++) {
        //         const string uid = JsonExt::GetString(mapInfo[i], "mapUid");

        //         if (uid.Length > 0) {
        //             // Map@ map = mode == Mode::NadeoCampaign ? cast<Map@>(mapsCampaignByUid[uid]) : cast<Map@>(mapsTotdByUid[uid]);
        //             Map@ map = cast<Map@>(mode == Mode::NadeoCampaign ? mapsCampaignByUid[uid] : mapsTotdByUid[uid]);

        //             if (map is null) {
        //                 warn("GetMapInfos: null " + modeName + " map: " + uid);
        //                 continue;
        //             }

        //             map.authorTime  = JsonExt::GetUint(mapInfo[i], "authorScore");
        //             map.bronzeTime  = JsonExt::GetUint(mapInfo[i], "bronzeScore");
        //             map.downloadUrl = JsonExt::GetString(mapInfo[i], "fileUrl");
        //             map.goldTime    = JsonExt::GetUint(mapInfo[i], "goldScore");
        //             map.id          = JsonExt::GetString(mapInfo[i], "mapId");
        //             @map.name       = FormattedString(JsonExt::GetString(mapInfo[i], "name"));
        //             map.silverTime  = JsonExt::GetUint(mapInfo[i], "silverScore");

        //             map.SetSeason(mode);

        //             if (mode == Mode::NadeoCampaign && !mapsCampaignById.Exists(map.id))
        //                 mapsCampaignById.Set(map.id, @map);

        //             else if (mode == Mode::TrackOfTheDay && !mapsTotdById.Exists(map.id))
        //                 mapsTotdById.Set(map.id, @map);
        //         }
        //     }

        //     if (mapsStillNeedInfo.Length == 1)
        //         break;
        // }

        // trace("got " + modeName + " map info from API");
    // }

    // void GetMapsAsync(Mode mode) {
        // const string modeName = tostring(mode);

        // trace("getting " + modeName + " maps from API...");

        // // length 99 will work until 2029 (TOTD) or 2045 (campaign)
        // Net::HttpRequest@ req = GetLiveAsync(
        //     "/api/token/campaign/" + (mode == Mode::NadeoCampaign ? "official" : "month") + "?length=99&offset=0"
        // );

        // const int code = req.ResponseCode();
        // if (code != 200) {
        //     warn("error getting " + modeName + " maps from API: " + code + "; " + req.Error() + "; " + req.String());
        //     return;
        // }

        // Json::Value@ json = req.Json();
        // if (!JsonExt::CheckType(json)) {
        //     warn("bad json: " + req.String());
        //     return;
        // }

        // if (mode == Mode::NadeoCampaign) {
        //     Json::Value@ campaignList = JsonExt::GetValue(json, "campaignList", Json::Type::Array);

        //     if (campaignList !is null) {
        //         for (int i = campaignList.Length - 1; i >= 0; i--) {
        //             Json::Value@ playlist = JsonExt::GetValue(campaignList[i], "playlist", Json::Type::Array);

        //             if (playlist !is null) {
        //                 for (uint j = 0; j < playlist.Length; j++) {
        //                     Map@ map = Map(playlist[j]);

        //                     map.SetSeason(Mode::NadeoCampaign);

        //                     if (mapsCampaignByUid.Exists(map.uid))
        //                         continue;  // should never happen but this code has ghosts

        //                     mapsCampaign.InsertLast(@map);
        //                     mapsCampaignByUid.Set(map.uid, @map);
        //                 }
        //             } else
        //                 warn("playlist null");
        //         }
        //     } else
        //         warn("campaignList null");
        // } else {
        //     Json::Value@ monthList = JsonExt::GetValue(json, "monthList", Json::Type::Array);

        //     if (monthList !is null) {
        //         for (int i = monthList.Length - 1; i >= 0; i--) {
        //             Json::Value@ days = JsonExt::GetValue(monthList[i], "days", Json::Type::Array);

        //             if (days !is null) {
        //                 for (uint j = 0; j < days.Length; j++) {
        //                     Map@ map = Map(
        //                         JsonExt::GetInt(monthList[i], "year"),
        //                         JsonExt::GetInt(monthList[i], "month"),
        //                         days[j]
        //                     );

        //                     map.SetSeason(Mode::TrackOfTheDay);

        //                     if (map.uid.Length > 0) {
        //                         if (mapsTotdByUid.Exists(map.uid))
        //                             continue;  // should never happen but it did on 2024-01-06

        //                         mapsTotd.InsertLast(@map);
        //                         mapsTotdByUid.Set(map.uid, @map);
        //                     }
        //                 }
        //             } else
        //                 warn("days null");
        //         }
        //     } else
        //         warn("monthList null");
        // }

        // trace("got " + (mode == Mode::NadeoCampaign ? mapsCampaign.Length : mapsTotd.Length) + " " + modeName + " maps from API");
    // }

    Net::HttpRequest@ GetMeetAsync(const string &in endpoint, bool start = true) {
        return GetAsync(audienceLive, urlMeet + endpoint, start);
    }

    Net::HttpRequest@ PostAsync(const string &in audience, const string &in url, const string &in body = "", bool start = true) {
        NadeoServices::AddAudience(audience);

        while (!NadeoServices::IsAuthenticated(audience) || requesting)
            yield();

        if (start)
            requesting = true;

        WaitAsync();

        Net::HttpRequest@ req = NadeoServices::Post(audience, url, body);
        if (start) {
            req.Start();
            while (!req.Finished())
                yield();

            requesting = false;
        }

        return req;
    }

    Net::HttpRequest@ PostAsync(const string &in audience, const string &in url, Json::Value@ body = null, bool start = true) {
        return PostAsync(audience, url, Json::Write(body), start);
    }

    Net::HttpRequest@ PostCoreAsync(const string &in endpoint, const string &in body = "", bool start = true) {
        return PostAsync(audienceCore, urlCore + endpoint, body, start);
    }

    Net::HttpRequest@ PostCoreAsync(const string &in endpoint, Json::Value@ body = null, bool start = true) {
        return PostAsync(audienceCore, urlCore + endpoint, body, start);
    }

    Net::HttpRequest@ PostLiveAsync(const string &in endpoint, const string &in body = "", bool start = true) {
        return PostAsync(audienceLive, urlLive + endpoint, body, start);
    }

    Net::HttpRequest@ PostLiveAsync(const string &in endpoint, Json::Value@ body = null, bool start = true) {
        return PostAsync(audienceLive, urlLive + endpoint, body, start);
    }

    Net::HttpRequest@ PostMeetAsync(const string &in endpoint, const string &in body = "", bool start = true) {
        return PostAsync(audienceLive, urlMeet + endpoint, body, start);
    }

    Net::HttpRequest@ PostMeetAsync(const string &in endpoint, Json::Value@ body = null, bool start = true) {
        return PostAsync(audienceLive, urlMeet + endpoint, body, start);
    }

    void WaitAsync() {
        uint64 now;

        while ((now = Time::Now) - lastRequest < minimumWait)
            yield();

        lastRequest = now;
    }
}
