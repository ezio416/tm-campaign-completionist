// c 2025-03-03
// m 2025-03-14

namespace Campaign {
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
        Tmx,
        Custom,
        Unknown
    }

    class Campaign {
        int             clubId = -1;
        int             id     = -1;
        dictionary@     maps   = dictionary();
        int             month  = -1;
        String::String@ name;
        Season          season = Season::Unknown;
        int             tmxId  = -1;
        Type            type   = Type::Unknown;
        string          uid;
        int             week   = -1;
        int             year   = -1;

        Campaign(Json::Value@ json, Type type) {
            if (!JsonExt::CheckType(json)) {
                warn("bad " + tostring(type) + " campaign: " + Json::Write(json));
                return;
            }

            this.type = type;
            switch (type) {
                case Type::Seasonal: {
                    clubId = JsonExt::GetInt(json, "clubId");
                    id = JsonExt::GetInt(json, "id");
                    @name = String::String(JsonExt::GetString(json, "name"));
                    uid = "cccamp-seas-" + String::Clean(name);

                    string[]@ parts = name.stripped.Split(" ");

                    if (parts[0] == "Winter")
                        season = Season::Winter;
                    else if (parts[0] == "Spring")
                        season = Season::Spring;
                    else if (parts[0] == "Summer")
                        season = Season::Summer;
                    else if (parts[0] == "Fall")
                        season = Season::Fall;
                    else
                        warn("invalid season: " + parts[0]);

                    year = Text::ParseInt(parts[1]);

                    Json::Value@ playlist = JsonExt::GetValue(json, "playlist", Json::Type::Array);
                    if (playlist is null || playlist.Length == 0) {
                        warn("bad/empty playlist for campaign '" + name.stripped + "'");
                        return;
                    }

                    for (uint i = 0; i < playlist.Length; i++) {
                        Map::Map@ map = Map::Map(playlist[i]);
                        @map.campaign = this;

                        if (!maps.Exists(map.uid))
                            maps.Set(map.uid, @map);
                        else
                            warn("duplicate uid in '" + name.stripped + "': " + map.uid);

                        Map::Add(map);
                    }

                    break;
                }

                case Type::Weekly: {
                    id = JsonExt::GetInt(json, "id");
                    @name = String::String(JsonExt::GetString(json, "name"));
                    uid = "cccamp-week-" + String::Clean(name);
                    year = JsonExt::GetInt(json, "year");

                    Json::Value@ playlist = JsonExt::GetValue(json, "playlist", Json::Type::Array);
                    if (playlist is null || playlist.Length == 0) {
                        warn("bad/empty playlist for '" + name.stripped + "'");
                        return;
                    }

                    for (uint i = 0; i < playlist.Length; i++) {
                        Map::Map@ map = Map::Map(playlist[i]);
                        @map.campaign = this;

                        if (!maps.Exists(map.uid))
                            maps.Set(map.uid, @map);
                        else
                            warn("duplicate uid in '" + name.stripped + "': " + map.uid);

                        Map::Add(map);
                    }

                    break;
                }

                case Type::Totd: {
                    month = JsonExt::GetInt(json, "month");
                    year = JsonExt::GetInt(json, "year");
                    @name = String::String(year + "-" + month);
                    uid = "cccamp-totd-" + String::Clean(name);

                    switch (month) {
                        case 1: case 2: case 3:
                            season = Season::Winter;
                            break;
                        case 4: case 5: case 6:
                            season = Season::Spring;
                            break;
                        case 7: case 8: case 9:
                            season = Season::Summer;
                            break;
                        case 10: case 11: case 12:
                            season = Season::Fall;
                            break;
                        default:;
                    }

                    Json::Value@ days = JsonExt::GetValue(json, "days", Json::Type::Array);
                    if (days is null || days.Length == 0) {
                        warn("bad/empty days for " + name);
                        return;
                    }

                    for (uint i = 0; i < days.Length; i++) {
                        Map::Map@ map = Map::Map(days[i]);
                        if (map.uid.Length == 0)
                            break;

                        @map.campaign = this;

                        if (!maps.Exists(map.uid))
                            maps.Set(map.uid, @map);
                        else
                            warn("duplicate uid in '" + name + "': " + map.uid);

                        Map::Add(map);
                    }

                    break;
                }

                default:
                    throw("invalid campaign type: " + tostring(type));
            }
        }

        // void PlayAsync() {
        //     Map::Map@[] sorted;

        //     string[]@ uids = maps.GetKeys();
        //     for (uint i = 0; i < uids.Length; i++)
        //         sorted.InsertLast(Map::Get(uids[i]));

        //     sorted.Sort(function(a, b) { return a.position < b.position; });

        //     MwFastBuffer<wstring> urls;
        //     for (uint i = 0; i < sorted.Length; i++)
        //         urls.Add(wstring(sorted[i].url));
        //     Script::PlayMapListAsync(urls, id, name);

        //     // Script::PlayCampaignAsync(this);
        // }
    }
}
