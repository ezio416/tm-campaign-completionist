// c 2025-03-03
// m 2025-03-10

enum CampaignSeason {
    Winter,
    Spring,
    Summer,
    Fall,
    Unknown
}

enum CampaignType {
    Seasonal,
    Weekly,
    Totd,
    Club,
    TMX,
    Custom,
    Unknown
}

class Campaign {
    int              clubId = -1;
    int              id     = -1;
    dictionary@      maps   = dictionary();
    int              month  = -1;
    FormattedString@ name;
    CampaignSeason   season = CampaignSeason::Unknown;
    int              tmxId  = -1;
    CampaignType     type   = CampaignType::Unknown;
    int              week   = -1;
    int              year   = -1;

    Campaign(Json::Value@ json, CampaignType type) {
        if (!JsonExt::CheckType(json)) {
            warn("bad " + tostring(type) + " campaign: " + Json::Write(json));
            return;
        }

        this.type = type;
        switch (type) {
            case CampaignType::Seasonal: {
                id = JsonExt::GetInt(json, "id");
                @name = FormattedString(JsonExt::GetString(json, "name"));

                string[]@ parts = name.stripped.Split(" ");

                if (parts[0] == "Winter")
                    season = CampaignSeason::Winter;
                else if (parts[0] == "Spring")
                    season = CampaignSeason::Spring;
                else if (parts[0] == "Summer")
                    season = CampaignSeason::Summer;
                else if (parts[0] == "Fall")
                    season = CampaignSeason::Fall;
                else
                    warn("invalid season: " + parts[0]);

                year = Text::ParseInt(parts[1]);

                Json::Value@ playlist = JsonExt::GetValue(json, "playlist", Json::Type::Array);
                if (playlist is null || playlist.Length == 0) {
                    warn("bad/empty playlist for campaign '" + name.stripped + "'");
                    return;
                }

                for (uint i = 0; i < playlist.Length; i++) {
                    Map@ map = Map(playlist[i]);
                    @map.campaign = this;

                    if (!maps.Exists(map.uid))
                        maps.Set(map.uid, @map);
                    else
                        warn("duplicate uid in '" + name.stripped + "': " + map.uid);

                    AddMap(map);
                }

                break;
            }

            case CampaignType::Weekly: {
                id = JsonExt::GetInt(json, "id");
                @name = FormattedString(JsonExt::GetString(json, "name"));
                year = JsonExt::GetInt(json, "year");

                Json::Value@ playlist = JsonExt::GetValue(json, "playlist", Json::Type::Array);
                if (playlist is null || playlist.Length == 0) {
                    warn("bad/empty playlist for '" + name.stripped + "'");
                    return;
                }

                for (uint i = 0; i < playlist.Length; i++) {
                    Map@ map = Map(playlist[i]);
                    @map.campaign = this;

                    if (!maps.Exists(map.uid))
                        maps.Set(map.uid, @map);
                    else
                        warn("duplicate uid in '" + name.stripped + "': " + map.uid);

                    AddMap(map);
                }

                break;
            }

            case CampaignType::Totd: {
                month = JsonExt::GetInt(json, "month");
                year = JsonExt::GetInt(json, "year");
                @name = FormattedString(year + "-" + month);

                switch (month) {
                    case 1: case 2: case 3:
                        season = CampaignSeason::Winter;
                        break;
                    case 4: case 5: case 6:
                        season = CampaignSeason::Spring;
                        break;
                    case 7: case 8: case 9:
                        season = CampaignSeason::Summer;
                        break;
                    case 10: case 11: case 12:
                        season = CampaignSeason::Fall;
                        break;
                    default:;
                }

                Json::Value@ days = JsonExt::GetValue(json, "days", Json::Type::Array);
                if (days is null || days.Length == 0) {
                    warn("bad/empty days for " + name);
                    return;
                }

                for (uint i = 0; i < days.Length; i++) {
                    Map@ map = Map(days[i]);
                    if (map.uid.Length == 0)
                        break;

                    @map.campaign = this;

                    if (!maps.Exists(map.uid))
                        maps.Set(map.uid, @map);
                    else
                        warn("duplicate uid in '" + name + "': " + map.uid);

                    AddMap(map);
                }

                break;
            }

            default:
                throw("invalid campaign type: " + tostring(type));
        }
    }
}
