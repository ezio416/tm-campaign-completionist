// c 2024-01-02
// m 2025-03-11

namespace Http {
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

        namespace Base {
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
            trace("H:N:GetMapsSeasonalAsync");

            Net::HttpRequest@ req = Base::GetLiveAsync(
                "/api/token/campaign/official?length="
                + (2 + 4 * (Text::ParseInt(Time::FormatStringUTC("%Y", Time::Stamp)) - 2020))
            );

            const int code = req.ResponseCode();
            if (code != 200) {
                error("H:N:GetMapsSeasonalAsync " + code + "; " + req.Error() + "; " + req.String());
                return;
            }

            Json::Value@ json = req.Json();
            if (!JsonExt::CheckType(json)) {
                error("H:N:GetMapsSeasonalAsync bad json data: " + Json::Write(json));
                return;
            }

            Json::ToFile(IO::FromStorageFolder("seasonal_raw.json"), json, true);

            Json::Value@ campaignList = JsonExt::GetValue(json, "campaignList", Json::Type::Array);
            if (campaignList is null || campaignList.Length == 0) {
                error("H:N:GetMapsSeasonalAsync bad/empty campaignList");
                return;
            }

            for (uint i = 0; i < campaignList.Length; i++)
                campaigns.InsertLast(Campaign(campaignList[i], Campaigns::Type::Seasonal));
        }

        void GetMapsTotdAsync() {
            trace("H:N:GetMapsTotdAsync");

            Net::HttpRequest@ req = Base::GetLiveAsync(
                "/api/token/campaign/month?length="
                + (6 + 12 * (Text::ParseInt(Time::FormatStringUTC("%Y", Time::Stamp)) - 2020))
            );

            const int code = req.ResponseCode();
            if (code != 200) {
                error("H:N:GetMapsTotdAsync " + code + "; " + req.Error() + "; " + req.String());
                return;
            }

            Json::Value@ json = req.Json();
            if (!JsonExt::CheckType(json)) {
                error("H:N:GetMapsTotdAsync bad json data: " + Json::Write(json));
                return;
            }

            Json::ToFile(IO::FromStorageFolder("totd_raw.json"), json, true);

            Json::Value@ monthList = JsonExt::GetValue(json, "monthList", Json::Type::Array);
            if (monthList is null || monthList.Length == 0) {
                error("H:N:GetMapsTotdAsync bad/empty monthList");
                return;
            }

            for (uint i = 0; i < monthList.Length; i++)
                campaigns.InsertLast(Campaign(monthList[i], Campaigns::Type::Totd));
        }

        void GetMapsWeeklyAsync() {
            trace("H:N:GetMapsWeeklyAsync");

            Net::HttpRequest@ req = Base::GetLiveAsync(
                "/api/campaign/weekly-shorts?length="
                + (3 + 53 * (Text::ParseInt(Time::FormatStringUTC("%Y", Time::Stamp)) - 2024))
            );

            const int code = req.ResponseCode();
            if (code != 200) {
                error("H:N:GetMapsWeeklyAsync: " + code + "; " + req.Error() + "; " + req.String());
                return;
            }

            Json::Value@ json = req.Json();
            if (!JsonExt::CheckType(json)) {
                error("H:N:GetMapsWeeklyAsync: bad json data: " + Json::Write(json));
                return;
            }

            Json::ToFile(IO::FromStorageFolder("weekly_raw.json"), json, true);

            Json::Value@ campaignList = JsonExt::GetValue(json, "campaignList", Json::Type::Array);
            if (campaignList is null || campaignList.Length == 0) {
                error("H:N:GetMapsWeeklyAsync: bad/empty campaignList");
                return;
            }

            for (uint i = 0; i < campaignList.Length; i++)
                campaigns.InsertAt(0, Campaign(campaignList[i], Campaigns::Type::Weekly));
        }

        void GetPBsAsync(string[]@ uids) {
            if (uids is null || uids.Length == 0)
                return;

            const uint64 start = Time::Now;
            trace("H:N:GetPBsAsync " + uids.Length + " maps");

            uint       count, index = 0;
            const uint max          = 50;
            string[]   remaining    = uids;
            uint64     reqStart;

            while (remaining.Length > 0 && (index == 0 || index < uids.Length - 1)) {
                trace("H:N:GetPBsAsync " + index + "/" + uids.Length);

                count = Math::Min(max, remaining.Length);

                Json::Value@ body = Json::Object();
                body["maps"] = Json::Array();

                for (uint i = 0; i < count; i++) {
                    Json::Value@ map = Json::Object();

                    map["groupUid"] = "Personal_Best";
                    map["mapUid"] = remaining[i];

                    body["maps"].Add(map);

                    index++;
                }

                reqStart = Time::Now;

                Net::HttpRequest@ req = Base::PostLiveAsync("/api/token/leaderboard/group/map", body);

                const int respCode = req.ResponseCode();
                if (respCode != 200) {
                    error("H:N:GetPBsAsync some failed after " + (Time::Now - reqStart) + "ms: code: " + respCode + " | msg: " + req.String().Replace("\n", " "));
                    continue;
                }

                Json::Value@ data = req.Json();
                if (!JsonExt::CheckType(data, Json::Type::Array)) {
                    error("H:N:GetPBsAsync some failed after " + (Time::Now - reqStart) + "ms: bad json");
                    continue;
                }

                uint new = 0, score, total = 0;
                string uid;

                for (uint i = 0; i < data.Length; i++) {
                    Json::Value@ map_api = data[i];
                    if (!JsonExt::CheckType(map_api))
                        continue;

                    uid = JsonExt::GetString(map_api, "mapUid");
                    Map@ map = Maps::Get(uid);
                    if (map is null)
                        continue;

                    score = JsonExt::GetUint(map_api, "score");
                    if (!Driven(score))
                        continue;

                    total++;

                    if (!map.driven || score < map.pb) {
                        map.pb = score;
                        new++;
                    } else if (score != map.pb) {
                        // warn("problem with score: " + score + " | map.pb " + map.pb);
                    }
                }

                uint missing = 0;

                for (uint i = 0; i < count; i++) {
                    Map@ map = Maps::Get(remaining[i]);
                    if (map is null)
                        continue;

                    if (map.pb == uint(-1)) {
                        map.pb = 0;  // api returned no pb
                        missing++;
                    }
                }

                remaining = {};

                if (missing > 0 || new > 0) {
                    trace("H:N:GetPBsAsync " + count + " PBs after " + (Time::Now - reqStart) + "ms (new/none): " + new + " | " + missing);
                    PB::SaveAll();
                }
            }

            trace("H:N:GetPBsAsync " + uids.Length + " maps done after " + (Time::Now - start) + "ms");
        }

        void GetPBsAsync() {
            GetPBsAsync(allMaps.GetKeys());
        }
    }
}
