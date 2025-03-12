// c 2024-01-02
// m 2025-03-11

namespace API {
    bool requesting = false;

    Net::HttpRequest@ GetAsync(const string &in url, bool start = true) {
        requesting = true;

        Net::HttpRequest@ req = Net::HttpRequest();
        req.Method = Net::HttpMethod::Get;
        req.Url = url;

        if (start) {
            req.Start();
            while (!req.Finished())
                yield();
        }

        requesting = false;
        return req;
    }

    Net::HttpRequest@ PostAsync(const string &in url, const string &in body = "", bool start = true, const string &in agent = "") {
        requesting = true;

        Net::HttpRequest@ req = Net::HttpRequest();
        req.Method = Net::HttpMethod::Post;
        req.Url = url;
        req.Body = body;
        req.Headers["Content-Type"] = "application/json";
        if (agent.Length > 0)
            req.Headers["User-Agent"] = agent;

        if (start) {
            req.Start();
            while (!req.Finished())
                yield();
        }

        requesting = false;
        return req;
    }

    Net::HttpRequest@ PostAsync(const string &in url, Json::Value@ body = null, bool start = true, const string &in agent = "") {
        return PostAsync(url, Json::Write(body), start, agent);
    }

    namespace Nadeo {
        bool requesting = false;

        namespace Internal {
            const string audienceCore = "NadeoServices";
            const string audienceLive = "NadeoLiveServices";
            uint64       lastRequest  = 0;
            const uint64 minimumWait  = 1000;

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
                return GetAsync(audienceCore, NadeoServices::BaseURLCore() + endpoint, start);
            }

            Net::HttpRequest@ GetLiveAsync(const string &in endpoint, bool start = true) {
                return GetAsync(audienceLive, NadeoServices::BaseURLLive() + endpoint, start);
            }

            Net::HttpRequest@ GetMeetAsync(const string &in endpoint, bool start = true) {
                return GetAsync(audienceLive, NadeoServices::BaseURLMeet() + endpoint, start);
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
                return PostAsync(audienceCore, NadeoServices::BaseURLCore() + endpoint, body, start);
            }

            Net::HttpRequest@ PostCoreAsync(const string &in endpoint, Json::Value@ body = null, bool start = true) {
                return PostAsync(audienceCore, NadeoServices::BaseURLCore() + endpoint, body, start);
            }

            Net::HttpRequest@ PostLiveAsync(const string &in endpoint, const string &in body = "", bool start = true) {
                return PostAsync(audienceLive, NadeoServices::BaseURLLive() + endpoint, body, start);
            }

            Net::HttpRequest@ PostLiveAsync(const string &in endpoint, Json::Value@ body = null, bool start = true) {
                return PostAsync(audienceLive, NadeoServices::BaseURLLive() + endpoint, body, start);
            }

            Net::HttpRequest@ PostMeetAsync(const string &in endpoint, const string &in body = "", bool start = true) {
                return PostAsync(audienceLive, NadeoServices::BaseURLMeet() + endpoint, body, start);
            }

            Net::HttpRequest@ PostMeetAsync(const string &in endpoint, Json::Value@ body = null, bool start = true) {
                return PostAsync(audienceLive, NadeoServices::BaseURLMeet() + endpoint, body, start);
            }

            void WaitAsync() {
                uint64 now;

                while ((now = Time::Now) - lastRequest < minimumWait)
                    yield();

                lastRequest = now;
            }
        }

        void GetMapsSeasonalAsync() {
            trace("A:GetMapsSeasonalAsync");

            Net::HttpRequest@ req = Internal::GetLiveAsync(
                "/api/token/campaign/official?length="
                + (2 + 4 * (Text::ParseInt(Time::FormatStringUTC("%Y", Time::Stamp)) - 2020))
            );

            const int code = req.ResponseCode();
            if (code != 200) {
                error("A:GetMapsSeasonalAsync: " + code + "; " + req.Error() + "; " + req.String());
                return;
            }

            Json::Value@ json = req.Json();
            if (!JsonExt::CheckType(json)) {
                error("A:GetMapsSeasonalAsync: bad json data: " + Json::Write(json));
                return;
            }

            Json::ToFile(IO::FromStorageFolder("seasonal_raw.json"), json, true);

            Json::Value@ campaignList = JsonExt::GetValue(json, "campaignList", Json::Type::Array);
            if (campaignList is null || campaignList.Length == 0) {
                error("A:GetMapsSeasonalAsync: bad/empty campaignList");
                return;
            }

            for (uint i = 0; i < campaignList.Length; i++)
                campaigns.InsertLast(Campaign(campaignList[i], CampaignType::Seasonal));
        }

        void GetMapsTotdAsync() {
            trace("A:GetMapsTotdAsync");

            Net::HttpRequest@ req = Internal::GetLiveAsync(
                "/api/token/campaign/month?length="
                + (6 + 12 * (Text::ParseInt(Time::FormatStringUTC("%Y", Time::Stamp)) - 2020))
            );

            const int code = req.ResponseCode();
            if (code != 200) {
                error("A:GetMapsTotdAsync: " + code + "; " + req.Error() + "; " + req.String());
                return;
            }

            Json::Value@ json = req.Json();
            if (!JsonExt::CheckType(json)) {
                error("A:GetMapsTotdAsync: bad json data: " + Json::Write(json));
                return;
            }

            Json::ToFile(IO::FromStorageFolder("totd_raw.json"), json, true);

            Json::Value@ monthList = JsonExt::GetValue(json, "monthList", Json::Type::Array);
            if (monthList is null || monthList.Length == 0) {
                error("A:GetMapsTotdAsync: bad/empty monthList");
                return;
            }

            for (uint i = 0; i < monthList.Length; i++)
                campaigns.InsertLast(Campaign(monthList[i], CampaignType::Totd));
        }

        void GetMapsWeeklyAsync() {
            trace("A:GetMapsWeeklyAsync");

            Net::HttpRequest@ req = Internal::GetLiveAsync(
                "/api/campaign/weekly-shorts?length="
                + (3 + 53 * (Text::ParseInt(Time::FormatStringUTC("%Y", Time::Stamp)) - 2024))
            );

            const int code = req.ResponseCode();
            if (code != 200) {
                error("A:GetMapsWeeklyAsync: " + code + "; " + req.Error() + "; " + req.String());
                return;
            }

            Json::Value@ json = req.Json();
            if (!JsonExt::CheckType(json)) {
                error("A:GetMapsWeeklyAsync: bad json data: " + Json::Write(json));
                return;
            }

            Json::ToFile(IO::FromStorageFolder("weekly_raw.json"), json, true);

            Json::Value@ campaignList = JsonExt::GetValue(json, "campaignList", Json::Type::Array);
            if (campaignList is null || campaignList.Length == 0) {
                error("A:GetMapsWeeklyAsync: bad/empty campaignList");
                return;
            }

            for (uint i = 0; i < campaignList.Length; i++)
                campaigns.InsertAt(0, Campaign(campaignList[i], CampaignType::Weekly));
        }

        void GetPBsAsync(string[]@ uids) {
            if (uids is null || uids.Length == 0)
                return;

            const uint64 start = Time::Now;
            trace("A:GetPBsAsync " + uids.Length + " maps");

            uint         count, index = 0;
            const uint   max          = 50;
            // const float  progressMin  = 0.32f;
            // const float  progressMax  = 1.0f;
            string[]     remaining    = uids;
            uint64       reqStart;

            while (remaining.Length > 0 && (index == 0 || index < uids.Length - 1)) {
                trace("A:GetPBsAsync " + index + "/" + uids.Length);

                // progress = progressMin + (float(index) / Math::Max(1, uids.Length)) * (progressMax - progressMin);
                // print("progress " + progress);

                count = Math::Min(max, remaining.Length);

                // trace("checking " + count + " maps of " + remaining.Length + " remaining");

                Json::Value@ body = Json::Object();
                body["maps"] = Json::Array();

                for (uint i = 0; i < count; i++) {
                    Json::Value@ map = Json::Object();

                    map["groupUid"] = "Personal_Best";
                    map["mapUid"] = remaining[i];

                    body["maps"].Add(map);

                    index++;
                    // print("index " + index++);
                }

                reqStart = Time::Now;

                Net::HttpRequest@ req = Internal::PostLiveAsync("/api/token/leaderboard/group/map", body);
                // print("aprx. url length: " + (urlLive.Length + 32 + Json::Write(body).Length));

                const int respCode = req.ResponseCode();
                if (respCode != 200) {
                    error("A:GetPBsAsync some failed after " + (Time::Now - reqStart) + "ms: code: " + respCode + " | msg: " + req.String().Replace("\n", " "));
                    continue;
                }

                // const string s = req.String();
                // warn("setting clipboard with " + s.Length + " chars");
                // IO::SetClipboard(s);

                Json::Value@ data = req.Json();
                if (!JsonExt::CheckType(data, Json::Type::Array)) {
                    error("A:GetPBsAsync some failed after " + (Time::Now - reqStart) + "ms: bad json");
                    continue;
                }

                uint new = 0, score, total = 0;
                string uid;

                for (uint i = 0; i < data.Length; i++) {
                    Json::Value@ map_api = data[i];
                    if (!JsonExt::CheckType(map_api)) {
                        // warn("bad json type: " + i);
                        continue;
                    }

                    uid = JsonExt::GetString(map_api, "mapUid");
                    Map@ map = GetMap(uid);
                    if (map is null) {
                        // warn("null map: " + uid);
                        continue;
                    }

                    score = JsonExt::GetUint(map_api, "score");
                    if (!Driven(score)) {
                        // warn("score invalid: " + score);
                        continue;
                    }

                    total++;

                    if (!map.driven || score < map.pb) {
                        // print("\\$Isetting map pb: " + map.name.stripped + " | " + score);
                        map.pb = score;
                        new++;
                    } else if (score != map.pb) {
                        // warn("problem with score: " + score + " | map.pb " + map.pb);
                    }
                }

                uint missing = 0;

                for (uint i = 0; i < count; i++) {
                    Map@ map = GetMap(remaining[i]);
                    if (map is null)
                        continue;

                    if (map.pb == uint(-1)) {
                        map.pb = 0;  // api returned no pb
                        missing++;
                    }
                }

                remaining.RemoveRange(0, count);

                if (missing > 0 || new > 0) {
                    trace("A:GetPBsAsync " + count + " PBs after " + (Time::Now - reqStart) + "ms (new/none): " + new + " | " + missing);
                    Files::SavePBs();
                }
            }

            trace("A:GetPBsAsync " + uids.Length + " maps done after " + (Time::Now - start) + "ms");
        }

        void GetPBsAsync() {
            GetPBsAsync(allMaps.GetKeys());
        }
    }
}

namespace Manager {
    void GetMapInfoAsync(Map@ map) {
        if (map is null)
            return;

        const uint64 start = Time::Now;
        trace("M:GetMapInfoAsync " + map.uid);

        try {
            if (map.uid.Length != 26 && map.uid.Length != 27)
                throw("bad uid: '" + map.uid + "'");

            CGameManiaAppTitle@ Title = cast<CTrackMania@>(GetApp()).MenuManager.MenuCustom_CurrentManiaApp;

            CWebServicesTaskResult_NadeoServicesMapScript@ task = Title.DataFileMgr.Map_NadeoServices_GetFromUid(
                Title.UserMgr.Users[0].Id,
                map.uid
            );
            while (task.IsProcessing)
                yield();

            if (task.HasFailed || !task.HasSucceeded || task.Map is null) {
                if (Title !is null && Title.DataFileMgr !is null)
                    Title.DataFileMgr.TaskResult_Release(task.Id);

                throw("task failed: '" + map.uid + "'");
            }

            @map.name      = FormattedString(task.Map.Name);
            map.timeAuthor = task.Map.AuthorScore;
            map.timeGold   = task.Map.GoldScore;
            map.timeSilver = task.Map.SilverScore;
            map.timeBronze = task.Map.BronzeScore;
            map.url        = task.Map.FileUrl;

            trace("M:GetMapInfoAsync " + map.uid + " (" + map.name + ") done after " + (Time::Now - start) + "ms");

            if (Title !is null && Title.DataFileMgr !is null)
                Title.DataFileMgr.TaskResult_Release(task.Id);

        } catch {
            warn("M:GetMapInfoAsync " + map.uid + " failed after " + (Time::Now - start) + "ms: " + getExceptionInfo());
        }
    }

    void GetMapInfoAsync(const string &in uid) {
        GetMapInfoAsync(GetMap(uid));
    }

    void GetMapInfosAsync(string[]@ uids) {
        if (uids is null || uids.Length == 0)
            return;

        const uint64 start = Time::Now;
        trace("M:GetMapInfosAsync " + uids.Length + " maps");

        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        try {
            MwFastBuffer<wstring> MapUidList;
            for (uint i = 0; i < uids.Length; i++)
                MapUidList.Add(wstring(uids[i]));

            CGameManiaAppTitle@ Title = App.MenuManager.MenuCustom_CurrentManiaApp;

            CWebServicesTaskResult_NadeoServicesMapListScript@ task = Title.DataFileMgr.Map_NadeoServices_GetListFromUid(
                Title.UserMgr.Users[0].Id,
                MapUidList
            );
            while (task.IsProcessing)
                yield();

            if (task.HasFailed || !task.HasSucceeded || task.MapList.Length == 0) {
                if (Title !is null && Title.DataFileMgr !is null)
                    Title.DataFileMgr.TaskResult_Release(task.Id);

                throw("task failed");
            }

            // print("\\$0F0got " + task.MapList.Length + " maps");

            for (uint i = 0; i < task.MapList.Length; i++) {
                CNadeoServicesMap@ reqMap = task.MapList[i];
                // print("got map '" + Text::OpenplanetFormatCodes(reqMap.Name) + "'");
                Map@ map = GetMap(reqMap.Uid);

                map.timeAuthor = reqMap.AuthorScore;
                map.timeGold   = reqMap.GoldScore;
                map.timeSilver = reqMap.SilverScore;
                map.timeBronze = reqMap.BronzeScore;
                @map.name      = FormattedString(reqMap.Name);
            }

            trace("M:GetMapInfosAsync " + task.MapList.Length + " maps after " + (Time::Now - start) + "ms");

            if (Title !is null && Title.DataFileMgr !is null)
                Title.DataFileMgr.TaskResult_Release(task.Id);

        } catch {
            warn("M:GetMapInfosAsync failed after " + (Time::Now - start) + "ms: " + getExceptionInfo());
        }
    }

    void GetMapInfosAsync() {
        GetMapInfosAsync(allMaps.GetKeys());
    }

    void GetPB(Map@ map) {
        if (map is null)
            return;

        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        if (false
            || App.MenuManager is null
            || App.MenuManager.MenuCustom_CurrentManiaApp is null
            || App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr is null
            || App.UserManagerScript is null
            || App.UserManagerScript.Users.Length == 0
            || App.UserManagerScript.Users[0] is null
        ) {
            map.pb = uint(-1);
            return;
        }

        const uint pb = App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr.Map_GetRecord_v2(
            App.UserManagerScript.Users[0].Id,
            map.uid,
            "PersonalBest",
            "",
            "TimeAttack",
            ""
        );
        if (pb != uint(-1))
            map.pb = pb;
    }

    void GetPB(const string &in uid) {
        GetPB(GetMap(uid));
    }

    void GetPBAsync(Map@ map) {
        if (map is null)
            return;

        const uint64 start = Time::Now;
        trace("M:GetPBAsync " + map.uid);

        try {
            CTrackMania@ App = cast<CTrackMania@>(GetApp());
            CGameManiaAppTitle@ Title = App.MenuManager.MenuCustom_CurrentManiaApp;

            MwFastBuffer<wstring> wsid;
            wsid.Add(Title.LocalUser.WebServicesUserId);

            CWebServicesTaskResult_MapRecordListScript@ task = Title.ScoreMgr.Map_GetPlayerListRecordList(
                App.UserManagerScript.Users[0].Id,
                wsid,
                map.uid,
                "PersonalBest",
                "",
                "TimeAttack",
                ""
            );
            while (task.IsProcessing)
                yield();

            if (task.HasFailed || !task.HasSucceeded) {
                if (Title !is null && Title.DataFileMgr !is null)
                    Title.DataFileMgr.TaskResult_Release(task.Id);

                throw("task failed: '" + map.uid + "'");
            }

            map.pb = task.MapRecordList.Length > 0 ? task.MapRecordList[0].Time : 0;

            trace("M:GetPBAsync " + map.uid + " (" + map.name + ") done after " + (Time::Now - start) + "ms");

            if (Title !is null && Title.DataFileMgr !is null)
                Title.DataFileMgr.TaskResult_Release(task.Id);

        } catch {
            warn("M:GetPBAsync " + map.uid + " failed after " + (Time::Now - start) + "ms: " + getExceptionInfo());
        }
    }

    void GetPBAsync(const string &in uid) {
        GetPBAsync(GetMap(uid));
    }

    void GetPBs(string[]@ uids) {
        if (uids is null || uids.Length == 0)
            return;

        for (uint i = 0; i < uids.Length; i++)
            GetPB(uids[i]);
    }

    void GetPBs() {
        GetPBs(allMaps.GetKeys());
    }

    void GetPBsAsync(string[]@ uids) {
        if (uids is null || uids.Length == 0)
            return;

        const uint64 start = Time::Now;
        trace("M:GetPBsAsync " + uids.Length + " maps");

        for (uint i = 0; i < uids.Length; i++)
            GetPBAsync(uids[i]);

        trace("M:GetPBsAsync " + uids.Length + " maps done after " + (Time::Now - start) + "ms");
    }

    void GetPBsAsync() {
        GetPBsAsync(allMaps.GetKeys());
    }
}
