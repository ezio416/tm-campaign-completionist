// c 2024-01-02
// m 2025-03-10

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
        const string audienceCore = "NadeoServices";
        const string audienceLive = "NadeoLiveServices";
        bool         cancel       = false;
        uint64       lastRequest  = 0;
        const uint64 minimumWait  = 1000;
        bool         requesting   = false;

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

        void GetMapsAsync() {
            try {
                campaigns = {};
                allMaps.DeleteAll();

                GetMapsSeasonalAsync();
                GetMapsWeeklyAsync();
                GetMapsTotdAsync();

                GetInfosAsync();

            } catch {
                const string info = getExceptionInfo();
                error(info);
                UI::ShowNotification(
                    pluginTitle,
                    info,
                    vec4(1.0f, 0.3f, 0.0f, 0.8f),
                    10000
                );
            }
        }

        void GetMapsSeasonalAsync() {
            trace("GetMapsSeasonalAsync");

            Net::HttpRequest@ req = GetLiveAsync(
                "/api/token/campaign/official?length="
                + (2 + 4 * (Text::ParseInt(Time::FormatStringUTC("%Y", Time::Stamp)) - 2020))
            );

            const int code = req.ResponseCode();
            if (code != 200) {
                error("GetMapsSeasonalAsync: " + code + "; " + req.Error() + "; " + req.String());
                return;
            }

            Json::Value@ json = req.Json();
            if (!JsonExt::CheckType(json)) {
                error("GetMapsSeasonalAsync: bad json data: " + Json::Write(json));
                return;
            }

            Json::ToFile(IO::FromStorageFolder("seasonal_raw.json"), json, true);

            Json::Value@ campaignList = JsonExt::GetValue(json, "campaignList", Json::Type::Array);
            if (campaignList is null || campaignList.Length == 0) {
                error("GetMapsSeasonalAsync: bad/empty campaignList");
                return;
            }

            for (uint i = 0; i < campaignList.Length; i++)
                campaigns.InsertLast(Campaign(campaignList[i], CampaignType::Seasonal));
        }

        void GetMapsTotdAsync() {
            trace("GetMapsTotdAsync");

            Net::HttpRequest@ req = GetLiveAsync(
                "/api/token/campaign/month?length="
                + (6 + 12 * (Text::ParseInt(Time::FormatStringUTC("%Y", Time::Stamp)) - 2020))
            );

            const int code = req.ResponseCode();
            if (code != 200) {
                error("GetMapsTotdAsync: " + code + "; " + req.Error() + "; " + req.String());
                return;
            }

            Json::Value@ json = req.Json();
            if (!JsonExt::CheckType(json)) {
                error("GetMapsTotdAsync: bad json data: " + Json::Write(json));
                return;
            }

            Json::ToFile(IO::FromStorageFolder("totd_raw.json"), json, true);

            Json::Value@ monthList = JsonExt::GetValue(json, "monthList", Json::Type::Array);
            if (monthList is null || monthList.Length == 0) {
                error("GetMapsTotdAsync: bad/empty monthList");
                return;
            }

            for (uint i = 0; i < monthList.Length; i++)
                campaigns.InsertLast(Campaign(monthList[i], CampaignType::Totd));
        }

        void GetMapsWeeklyAsync() {
            trace("GetMapsWeeklyAsync");

            Net::HttpRequest@ req = GetLiveAsync(
                "/api/campaign/weekly-shorts?length="
                + (3 + 53 * (Text::ParseInt(Time::FormatStringUTC("%Y", Time::Stamp)) - 2024))
            );

            const int code = req.ResponseCode();
            if (code != 200) {
                error("GetMapsWeeklyAsync: " + code + "; " + req.Error() + "; " + req.String());
                return;
            }

            Json::Value@ json = req.Json();
            if (!JsonExt::CheckType(json)) {
                error("GetMapsWeeklyAsync: bad json data: " + Json::Write(json));
                return;
            }

            Json::ToFile(IO::FromStorageFolder("weekly_raw.json"), json, true);

            Json::Value@ campaignList = JsonExt::GetValue(json, "campaignList", Json::Type::Array);
            if (campaignList is null || campaignList.Length == 0) {
                error("GetMapsWeeklyAsync: bad/empty campaignList");
                return;
            }

            for (uint i = 0; i < campaignList.Length; i++)
                campaigns.InsertAt(0, Campaign(campaignList[i], CampaignType::Weekly));
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
}
