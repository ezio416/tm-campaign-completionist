// c 2024-01-02
// m 2025-03-11

class Map {
    Campaign@    campaign;
    bool         gettingPB   = false;
    string       id;
    bool         loading     = false;
    int          medals      = -1;
    int          monthDay    = -1;
    String@      name;
    int          position    = -1;
    Maps::Series series      = Maps::Series::Unknown;
    uint         timeAuthor  = uint(-1);
    uint         timeBronze  = uint(-1);
    uint         timeGold    = uint(-1);
    uint         timeSilver  = uint(-1);
    uint         timeWarrior = uint(-1);
    string       uid;
    string       url;
    int          weekDay    = -1;

    string get_date() {
        if (campaign is null || campaign.type != Campaigns::Type::Totd)
            return "";

        return campaign.name.stripped + "-" + monthDay;
    }

    bool get_driven() {
        return Driven(_pb);
    }

    private uint _pb = uint(-1);
    uint get_pb() { return _pb; }
    void set_pb(uint p) {
        _pb = p;
        medals = GetMedals();
        // print(uid + " pb set to " + _pb);
        PB::Add(this);
    }

    string get_pbFmt() {
        return driven ? Time::Format(_pb) : "";
    }

    Map(Json::Value@ json) {
        if (!JsonExt::CheckType(json))
            throw("bad map: " + Json::Write(json));

        uid = JsonExt::GetString(json, "mapUid");

        if (json.HasKey("day")) {  // totd
            weekDay = JsonExt::GetInt(json, "day");
            monthDay = JsonExt::GetInt(json, "monthDay");
        } else {  // seasonal/weekly
            position = JsonExt::GetInt(json, "position");
        }
    }

    bool Achieved(Maps::Medal medal) {
        return medals >= medal;
    }

    void GetPB() {
        Manager::GetPB(this);
    }

    void GetPBAsync() {
        if (gettingPB)
            return;

        gettingPB = true;
        GetPB();
        sleep(500);
        gettingPB = false;
    }

    void PlayAsync() {
        if (!hasPlayPermission || loading)
            return;

        if (url.Length == 0) {
            Manager::GetMapInfoAsync(this);

            if (url.Length == 0) {
                warn("can't play " + name + ": blank url");
                return;
            }
        }

        loading = true;
        trace("loading '" + name + "'");

#if DEPENDENCY_MLHOOK
    if (Meta::GetPluginFromID("MLHook").Enabled)
        MLHook::Queue_Menu_SendCustomEvent(
            "Event_UpdateLoadingScreen",
            {"$0F0$I$N$S" + PluginName() + " - $G$I$M$S" + name.raw}
        );
#endif

        ReturnToMenuAsync();

        CTrackMania@ App = cast<CTrackMania@>(GetApp());
        App.ManiaTitleControlScriptAPI.PlayMap(url, "TrackMania/TM_PlayMap_Local", "");

        sleep(5000);

        loading = false;
    }

    int GetMedals() {
        if (!driven)
            return -1;

#if DEPENDENCY_WARRIORMEDALS
        if (Driven(timeWarrior) && pb <= timeWarrior)
            return 5;
#endif
        if (pb <= timeAuthor)
            return 4;
        if (pb <= timeGold)
            return 3;
        if (pb <= timeSilver)
            return 2;
        if (pb <= timeBronze)
            return 1;

        return 0;
    }
}

namespace Maps {
    enum Medal {
        Unplayed = -1,
        None     = 0,
        Bronze   = 1,
        Silver   = 2,
        Gold     = 3,
        Author   = 4,
#if DEPENDENCY_WARRIORMEDALS
        Warrior  = 5
#endif
    }

    enum Series {
        White,
        Green,
        Blue,
        Red,
        Black,
        Unknown
    }

    void Add(Map@ map) {
        if (!allMaps.Exists(map.uid))
            allMaps.Set(map.uid, @map);
        else
            warn("duplicate: " + map.uid);
    }

    Map@ Get(const string &in uid) {
        if (!allMaps.Exists(uid))
            return null;

        return cast<Map@>(allMaps[uid]);
    }
}
