// c 2024-01-02
// m 2024-11-12

// Json::Value@ mapsCampaignFromFile = Json::Object();
// Json::Value@ mapsTotdFromFile     = Json::Object();

// void GetMaps() {
    // for (uint i = 0; i < mapsCampaign.Length; i++)
    //     @mapsCampaign[i] = null;
    // mapsCampaign = {};
    // mapsCampaignById.DeleteAll();
    // mapsCampaignByUid.DeleteAll();
    // API::GetMapsAsync(Mode::NadeoCampaign);

    // for (uint i = 0; i < mapsTotd.Length; i++)
    //     @mapsTotd[i] = null;
    // mapsTotd = {};
    // mapsTotdById.DeleteAll();
    // mapsTotdByUid.DeleteAll();
    // API::GetMapsAsync(Mode::TrackOfTheDay);

    // maps.DeleteAll();
    // mapsArr = { };
    // API::GetMapsAsync(Mode::Seasonal);

    // GetMapsFromFiles();
    // API::GetMapInfos(Mode::NadeoCampaign);
    // API::GetMapInfos(Mode::TrackOfTheDay);
    // GetAllPBsAsync();
    // SetNextMap();
// }

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
    float        progress     = 0.0f;
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

    void GetMapInfosAsync() {
        // const string modeName = tostring(mode);
        const uint64 start = Time::Now;
        trace("getting map infos from Nadeo...");

        uint index = 0;
        string endpoint;

        Map@[] mapsStillNeedInfo;

        for (uint i = 0; i < mapsArr.Length; i++) {
            Map@ map = mapsArr[i];

            if (map.name is null)
                mapsStillNeedInfo.InsertLast(map);
        }

        while (mapsStillNeedInfo.Length > 0 && (index == 0 || index < mapsStillNeedInfo.Length - 1)) {
            endpoint = "/maps/?mapUidList=";

            for (uint i = index; i < mapsStillNeedInfo.Length; i++) {
                index = i;

                if (endpoint.Length < 8124)  // 8192 - 41 (base url) - 27 (map uid max), allows ~291 maps depending on uid lengths
                    endpoint += mapsStillNeedInfo[i].uid + ",";
                else
                    break;
            }

            trace("getting map info from Nadeo (" + (index + 1) + "/" + mapsStillNeedInfo.Length + ")");
            const float progressMin = 0.15f;
            const float progressMax = 0.95f;
            progress = progressMin + (float(index) / mapsStillNeedInfo.Length) * (progressMax - progressMin);
            print("progress " + progress);

            Net::HttpRequest@ req = GetCoreAsync(endpoint.SubStr(0, endpoint.Length - 1));
            // IO::SetClipboard(req.Url);

            const int code = req.ResponseCode();
            if (code != 200) {
                warn("error getting map info from Nadeo: code " + code + " | err " + req.Error() + " | str" + req.String());
                continue;
            }

            Json::Value@ mapInfo = req.Json();
            if (!JsonExt::CheckType(mapInfo, Json::Type::Array))
                continue;

            // IO::SetClipboard(Json::Write(mapInfo));
            // throw("hi");

            for (uint i = 0; i < mapInfo.Length; i++) {
                const string uid = JsonExt::GetString(mapInfo[i], "mapUid");

                if (uid.Length > 0) {
                    // Map@ map = mode == Mode::NadeoCampaign ? cast<Map@>(mapsCampaignByUid[uid]) : cast<Map@>(mapsTotdByUid[uid]);
                    Map@ map = cast<Map@>(maps[uid]);

                    if (map is null) {
                        warn("GetMapInfosAsync: null map: " + uid);
                        continue;
                    }

                    map.authorId = JsonExt::GetString(mapInfo[i], "author");
                    accounts.Add(map.authorId);

                    map.authorTime  = JsonExt::GetUint(mapInfo[i], "authorScore");
                    map.bronzeTime  = JsonExt::GetUint(mapInfo[i], "bronzeScore");
                    map.downloadUrl = JsonExt::GetString(mapInfo[i], "fileUrl");
                    map.goldTime    = JsonExt::GetUint(mapInfo[i], "goldScore");
                    map.id          = JsonExt::GetString(mapInfo[i], "mapId");
                    @map.name       = FormattedString(JsonExt::GetString(mapInfo[i], "name"));
                    map.silverTime  = JsonExt::GetUint(mapInfo[i], "silverScore");

                    map.SetSeason();
                }
            }

            if (mapsStillNeedInfo.Length == 1)
                break;
        }

        trace("got map infos from Nadeo after " + (Time::Now - start) + "ms");
    }

    void GetMapsAsync() {
        maps.DeleteAll();
        mapsArr = { };

        API::GetMapsAsync(Mode::Seasonal);
        progress = 0.05f;

        API::GetMapsAsync(Mode::TOTD);
        progress = 0.1f;

        // Files::LoadMaps();
        progress = 0.15f;

        API::GetMapInfosAsync();

        accounts.Refresh();
        progress = 0.95f;

        Files::SaveMaps();

        progress = 1.0f;
        sleep(500);
        progress = 0.0f;
    }

    void GetMapsAsync(Mode mode) {
        uint count = 0;
        const string modeName = tostring(mode);

        if (mode != Mode::Seasonal && mode != Mode::TOTD) {
            warn("GetMapsAsync unsupported mode: " + tostring(mode));
            return;
        }

        trace("getting " + modeName + " maps from Nadeo...");

        // length 99 will work until 2029 (TOTD) or 2045 (campaign)
        Net::HttpRequest@ req = GetLiveAsync(
            "/api/token/campaign/" + (mode == Mode::Seasonal ? "official" : "month") + "?length=99&offset=0"
        );

        const int code = req.ResponseCode();
        if (code != 200) {
            warn("error getting " + modeName + " maps from Nadeo: " + code + "; " + req.Error() + "; " + req.String());
            return;
        }

        Json::Value@ json = req.Json();
        if (!JsonExt::CheckType(json)) {
            warn("bad json: " + req.String());
            return;
        }

        if (mode == Mode::Seasonal) {
            Json::Value@ campaignList = JsonExt::GetValue(json, "campaignList", Json::Type::Array);

            if (campaignList is null)
                warn("campaignList null");

            else {
                for (int i = campaignList.Length - 1; i >= 0; i--) {
                    Json::Value@ playlist = JsonExt::GetValue(campaignList[i], "playlist", Json::Type::Array);

                    if (playlist is null)
                        warn("playlist null");

                    else {
                        for (uint j = 0; j < playlist.Length; j++) {
                            Map@ map = Map(playlist[j]);

                            map.mode = Mode::Seasonal;

                            switch (j / 5) {
                                case 0:
                                    map.series = Series::White;
                                    break;
                                case 1:
                                    map.series = Series::Green;
                                    break;
                                case 2:
                                    map.series = Series::Blue;
                                    break;
                                case 3:
                                    map.series = Series::Red;
                                    break;
                                case 4:
                                    map.series = Series::Black;
                            }

                            if (!maps.Exists(map.uid)) {
                                maps.Set(map.uid, @map);
                                mapsArr.InsertLast(@map);
                                count++;
                            }
                        }
                    }
                }
            }

        } else if (mode == Mode::TOTD) {
            Json::Value@ monthList = JsonExt::GetValue(json, "monthList", Json::Type::Array);

            if (monthList is null)
                warn("monthList null");

            else {
                for (int i = monthList.Length - 1; i >= 0; i--) {
                    Json::Value@ days = JsonExt::GetValue(monthList[i], "days", Json::Type::Array);

                    if (days is null)
                        warn("days null");

                    else {
                        for (uint j = 0; j < days.Length; j++) {
                            Map@ map = Map(
                                JsonExt::GetInt(monthList[i], "year"),
                                JsonExt::GetInt(monthList[i], "month"),
                                days[j]
                            );

                            map.mode = Mode::TOTD;

                            if (map.uid.Length > 0 && !maps.Exists(map.uid)) {
                                maps.Set(map.uid, @map);
                                mapsArr.InsertLast(@map);
                                count++;
                            }
                        }
                    }
                }
            }
        }

        trace("got " + count + " " + modeName + " maps from Nadeo");
    }

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
