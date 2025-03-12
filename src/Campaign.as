// c 2025-03-03
// m 2025-03-10

class Campaign {
    int               clubId = -1;
    int               id     = -1;
    dictionary@       maps   = dictionary();
    int               month  = -1;
    String@           name;
    Campaigns::Season season = Campaigns::Season::Unknown;
    int               tmxId  = -1;
    Campaigns::Type   type   = Campaigns::Type::Unknown;
    int               week   = -1;
    int               year   = -1;

    Campaign(Json::Value@ json, Campaigns::Type type) {
        if (!JsonExt::CheckType(json)) {
            warn("bad " + tostring(type) + " campaign: " + Json::Write(json));
            return;
        }

        this.type = type;
        switch (type) {
            case Campaigns::Type::Seasonal: {
                id = JsonExt::GetInt(json, "id");
                @name = String(JsonExt::GetString(json, "name"));

                string[]@ parts = name.stripped.Split(" ");

                if (parts[0] == "Winter")
                    season = Campaigns::Season::Winter;
                else if (parts[0] == "Spring")
                    season = Campaigns::Season::Spring;
                else if (parts[0] == "Summer")
                    season = Campaigns::Season::Summer;
                else if (parts[0] == "Fall")
                    season = Campaigns::Season::Fall;
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

                    Maps::Add(map);
                }

                break;
            }

            case Campaigns::Type::Weekly: {
                id = JsonExt::GetInt(json, "id");
                @name = String(JsonExt::GetString(json, "name"));
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

                    Maps::Add(map);
                }

                break;
            }

            case Campaigns::Type::Totd: {
                month = JsonExt::GetInt(json, "month");
                year = JsonExt::GetInt(json, "year");
                @name = String(year + "-" + month);

                switch (month) {
                    case 1: case 2: case 3:
                        season = Campaigns::Season::Winter;
                        break;
                    case 4: case 5: case 6:
                        season = Campaigns::Season::Spring;
                        break;
                    case 7: case 8: case 9:
                        season = Campaigns::Season::Summer;
                        break;
                    case 10: case 11: case 12:
                        season = Campaigns::Season::Fall;
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

                    Maps::Add(map);
                }

                break;
            }

            default:
                throw("invalid campaign type: " + tostring(type));
        }
    }
}

namespace Campaigns {
    enum Season {
        Winter,
        Spring,
        Summer,
        Fall,
        Unknown
    }

    enum Type {
        Seasonal,
        Weekly,
        Totd,
        Club,
        TMX,
        Custom,
        Unknown
    }
}
