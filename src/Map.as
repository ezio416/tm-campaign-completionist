// c 2024-01-02
// m 2024-11-29

class Map {
    string           authorId;
    RaceTime         authorTime;
    bool             bookmarked = false;
    RaceTime         bronzeTime;
    string           date;
    string           downloadUrl;
    RaceTime         goldTime;
    string           id;
    Mode             mode       = Mode::Unknown;
    FormattedString@ name;
    RaceTime         pb;
    Season           season     = Season::Unknown;
    MapSeries        series     = MapSeries::Unknown;
    RaceTime         silverTime;
    bool             skipped    = false;
    // string           targetDelta;
    string           uid;

    string get_authorDisplayName() {
        const string name = authorName;

        if (name.Length > 0)
            return name;

        return "\\$I\\$666" + authorId.SubStr(0, 8) + "...";
    }

    string get_authorName() {
        return accounts.Get(authorId);
    }

    bool get_driven() {
        return Driven(pb);
    }

    uint get_myMedals() {
        if (!driven)
            return 0;

#if DEPENDENCY_WARRIORMEDALS
        if (pb <= WarriorMedals::GetWMTime(uid))
            return 5;
#endif

        if (pb <= authorTime)
            return 4;

        if (pb <= goldTime)
            return 3;

        if (pb <= silverTime)
            return 2;

        if (pb <= bronzeTime)
            return 1;

        return 0;
    }

    // Map() { }
    Map(int year, int month, Json::Value@ day) {  // TOTD
        date = "\\$S" + year + "-" + ZPad2(month) + "-" + ZPad2(day["monthDay"]);
        uid = day["mapUid"];
    }
    Map(Json::Value@ map, bool fromFile = false) {  // campaign or local file
        if (!fromFile) {
            uid = map["mapUid"];
            return;
        }

        authorId    = JsonExt::GetString(map, "authorId");
        authorTime  = JsonExt::GetUint(map, "authorTime");
        bookmarked  = JsonExt::GetBool(map, "bookmarked");
        bronzeTime  = JsonExt::GetUint(map, "bronzeTime");
        date        = "\\$S" + JsonExt::GetString(map, "date") + "\\$S";
        downloadUrl = JsonExt::GetString(map, "downloadUrl");
        goldTime    = JsonExt::GetUint(map, "goldTime");
        id          = JsonExt::GetString(map, "id");
        mode        = Mode(JsonExt::GetInt(map, "mode"));
        @name       = FormattedString(JsonExt::GetString(map, "name"));
        pb          = JsonExt::GetUint(map, "pb");
        season      = Season(JsonExt::GetInt(map, "season"));
        series      = MapSeries(JsonExt::GetInt(map, "series"));
        silverTime  = JsonExt::GetUint(map, "silverTime");
        skipped     = JsonExt::GetBool(map, "skipped");
        uid         = JsonExt::GetString(map, "uid");
    }

    void GetPBFromManager() {
        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        if (false
            || App.MenuManager is null
            || App.MenuManager.MenuCustom_CurrentManiaApp is null
            || App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr is null
            || App.UserManagerScript is null
            || App.UserManagerScript.Users.Length == 0
            || App.UserManagerScript.Users[0] is null
        ) {
            pb.Invalidate();
            return;
        }

        const uint record = App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr.Map_GetRecord_v2(App.UserManagerScript.Users[0].Id, uid, "PersonalBest", "", "TimeAttack", "");
        if (record != uint(-1))
            pb = record;
    }

    void GetPBFromManagerAsync() {
        trace("GetPBFromManagerAsync " + name.stripped);

        if (pb == 0) {
            trace("already checked map, no pb for " + name.stripped);
            return;
        }

        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        if (false
            || App.MenuManager is null
            || App.MenuManager.MenuCustom_CurrentManiaApp is null
            || App.MenuManager.MenuCustom_CurrentManiaApp.LocalUser is null
            || App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr is null
            || App.UserManagerScript is null
            || App.UserManagerScript.Users.Length == 0
            || App.UserManagerScript.Users[0] is null
        ) {
            pb.Invalidate();
            return;
        }

        CGameManiaAppTitle@ Title = App.MenuManager.MenuCustom_CurrentManiaApp;

        MwFastBuffer<wstring> wsids;
        const string wsid = Title.LocalUser.WebServicesUserId;
        wsids.Add(wsid);

        CWebServicesTaskResult_MapRecordListScript@ task = Title.ScoreMgr.Map_GetPlayerListRecordList(
            App.UserManagerScript.Users[0].Id, wsids, uid, "PersonalBest", "", "TimeAttack", ""
        );
        while (task !is null && task.IsProcessing)
            yield();

        if (task is null) {
            warn("task null for " + name.stripped);
            return;
        }

        if (task.HasFailed || !task.HasSucceeded) {
            warn("error getting api pb for " + name.stripped + " | wsid: " + wsid + " | error: " + task.ErrorCode + " | type: " + task.ErrorType + " | desc: " + task.ErrorDescription);

            if (Title !is null && Title.ScoreMgr !is null)
                Title.ScoreMgr.TaskResult_Release(task.Id);

            return;
        }

        if (task.MapRecordList.Length > 0) {
            trace("got api pb for " + name.stripped + " | " + Time::Format(pb));

            if (!pb.driven || task.MapRecordList[0].Time < pb)
                pb = task.MapRecordList[0].Time;
        } else
            pb.NotDriven();

        if (Title !is null && Title.ScoreMgr !is null)
            Title.ScoreMgr.TaskResult_Release(task.Id);
    }

    bool MetTarget(TargetMedal medal) {
        if (!driven)
            return false;

        switch (medal) {
#if DEPENDENCY_WARRIORMEDALS
            case TargetMedal::Warrior: {
                RaceTime wm = WarriorMedals::GetWMTime(uid);
                return wm.driven && pb <= wm;
            }
#endif
            case TargetMedal::Author:
                return pb <= authorTime;

            case TargetMedal::Gold:
                return pb <= goldTime;

            case TargetMedal::Silver:
                return pb <= silverTime;

            case TargetMedal::Bronze:
                return pb <= bronzeTime;

            case TargetMedal::None:
                return true;

            default:
                return false;
        }
    }

    void Play() {
        startnew(CoroutineFunc(PlayAsync));
    }

    // courtesy of "Play Map" plugin - https://github.com/XertroV/tm-play-map
    void PlayAsync() {
        if (loadingMap || !hasPlayPermission)
            return;

        loadingMap = true;

        trace("loading map " + (name !is null ? name.stripped : uid) + " for playing");

        ReturnToMenu();

        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        App.ManiaTitleControlScriptAPI.PlayMap(downloadUrl, "TrackMania/TM_PlayMap_Local", "");

        const uint64 waitToPlayAgain = 5000;
        const uint64 now = Time::Now;

        while (Time::Now - now < waitToPlayAgain)
            yield();

        loadingMap = false;
    }

    void SetSeason() {
        if (mode == Mode::Seasonal) {
            if (name is null)
                return;

            for (int i = 0; i < Season::Unknown; i++) {
                Season season = Season(i);

                if (name.stripped.StartsWith(tostring(season).Replace("_", " "))) {
                    this.season = season;
                    return;
                }
            }

        } else if (mode == Mode::TOTD) {
            const string dateRaw = date.SubStr(3, date.Length - 3);
            const int year = Text::ParseInt(dateRaw.SubStr(0, 4));
            const int month = Text::ParseInt(dateRaw.SubStr(5, 2));

            switch (year) {  // update every season, GET RID OF THIS BY WINTER 25 /////////////////////////////////////
                case 2020:
                    switch (month) {
                        case 7:  case 8:  case 9:  season = Season::Summer_2020; break;
                        case 10: case 11: case 12: season = Season::Fall_2020;   break;
                        default:;
                    }
                    break;

                case 2021:
                    switch (month) {
                        case 1:  case 2:  case 3:  season = Season::Winter_2021; break;
                        case 4:  case 5:  case 6:  season = Season::Spring_2021; break;
                        case 7:  case 8:  case 9:  season = Season::Summer_2021; break;
                        case 10: case 11: case 12: season = Season::Fall_2021;   break;
                        default:;
                    }
                    break;

                case 2022:
                    switch (month) {
                        case 1:  case 2:  case 3:  season = Season::Winter_2022; break;
                        case 4:  case 5:  case 6:  season = Season::Spring_2022; break;
                        case 7:  case 8:  case 9:  season = Season::Summer_2022; break;
                        case 10: case 11: case 12: season = Season::Fall_2022;   break;
                        default:;
                    }
                    break;

                case 2023:
                    switch (month) {
                        case 1:  case 2:  case 3:  season = Season::Winter_2023; break;
                        case 4:  case 5:  case 6:  season = Season::Spring_2023; break;
                        case 7:  case 8:  case 9:  season = Season::Summer_2023; break;
                        case 10: case 11: case 12: season = Season::Fall_2023;   break;
                        default:;
                    }
                    break;

                case 2024:
                    switch (month) {
                        case 1:  case 2:  case 3:  season = Season::Winter_2024; break;
                        case 4:  case 5:  case 6:  season = Season::Spring_2024; break;
                        case 7:  case 8:  case 9:  season = Season::Summer_2024; break;
                        case 10: case 11: case 12: season = Season::Fall_2024;   break;
                        default:;
                    }
                    break;

                default:;
            }
        }
    }

    string TargetDelta(TargetMedal medal) {
        if (!driven)
            return "";

        int delta;
        string ret;

        switch (medal) {
#if DEPENDENCY_WARRIORMEDALS
            case TargetMedal::Warrior: {
                RaceTime wm = WarriorMedals::GetWMTime(uid);
                delta = pb - (wm.driven ? wm : authorTime);
                break;
            }
#endif

            case TargetMedal::Author:
                delta = pb - authorTime;
                break;

            case TargetMedal::Gold:
                delta = pb - goldTime;
                break;

            case TargetMedal::Silver:
                delta = pb - silverTime;
                break;

            case TargetMedal::Bronze:
                delta = pb - bronzeTime;
                break;

            default:
                delta = 0;
        }

        if (delta <= 0)  // should never be negative?
            ret += colorDeltaUnder;
        else if (delta <= 100)
            ret += colorDelta0001to0100;
        else if (delta <= 250)
            ret += colorDelta0101to0250;
        else if (delta <= 500)
            ret += colorDelta0251to0500;
        else if (delta <= 1000)
            ret += colorDelta0501to1000;
        else if (delta <= 2000)
            ret += colorDelta1001to2000;
        else if (delta <= 3000)
            ret += colorDelta2001to3000;
        else if (delta <= 5000)
            ret += colorDelta3001to5000;
        else
            ret += colorDelta5001Above;

        return ret + "(" + (delta < 0 ? "" : "+") + Time::Format(delta) + ") \\$G";
    }

    Json::Value@ ToJson() {
        Json::Value@ ret = Json::Object();

        ret["authorId"]    = authorId;
        ret["authorTime"]  = uint(authorTime);
        ret["bookmarked"]  = bookmarked;
        ret["bronzeTime"]  = uint(bronzeTime);
        ret["date"]        = Text::StripFormatCodes(date).Replace("\\", "");
        ret["downloadUrl"] = downloadUrl;
        ret["goldTime"]    = uint(goldTime);
        ret["id"]          = id;
        ret["mode"]        = int(mode);
        ret["name"]        = name.raw;
        ret["pb"]          = uint(pb);
        ret["season"]      = int(season);
        ret["series"]      = int(series);
        ret["silverTime"]  = uint(silverTime);
        ret["skipped"]     = skipped;
        ret["uid"]         = uid;

        return ret;
    }

    string ToString() {
        return Json::Write(ToJson());
    }

    void UpdateDetails(Map@ other) {
        if (other is null || other.uid != uid)
            return;

        authorId    = other.authorId;
        authorTime  = other.authorTime;
        bookmarked  = other.bookmarked;
        bronzeTime  = other.bronzeTime;
        date        = other.date;
        downloadUrl = other.downloadUrl;
        goldTime    = other.goldTime;
        id          = other.id;
        mode        = other.mode;
        @name       = other.name;
        pb          = other.pb;
        season      = other.season;
        series      = other.series;
        silverTime  = other.silverTime;
        skipped     = other.skipped;
    }
}
