// c 2024-01-02
// m 2024-11-11

class Map {
    string           authorId;
    uint             authorTime;
    bool             bookmarked = false;
    uint             bronzeTime;
    string           date;
    string           downloadUrl;
    uint             goldTime;
    string           id;
    Mode             mode       = Mode::Unknown;
    uint             myMedals   = 0;
    FormattedString@ name;
    uint             pb         = uint(-1);
    Season           season     = Season::Unknown;
    Series           series     = Series::Unknown;
    uint             silverTime;
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

    Map() { }
    Map(Json::Value@ map) {  // campaign
        uid = map["mapUid"];
    }
    Map(int year, int month, Json::Value@ day) {  // TOTD
        date = "\\$S" + year + "-" + ZPad2(month) + "-" + ZPad2(day["monthDay"]);
        uid = day["mapUid"];
    }
    Map(Json::Value@ map, bool fromFile) {
        authorId    = JsonExt::GetString(map, "authorId");
        authorTime  = JsonExt::GetUint(map, "authorTime");
        bookmarked  = JsonExt::GetBool(map, "bookmarked");
        bronzeTime  = JsonExt::GetUint(map, "bronzeTime");
        date        = "\\$S" + JsonExt::GetString(map, "date");
        downloadUrl = JsonExt::GetString(map, "downloadUrl");
        goldTime    = JsonExt::GetUint(map, "goldTime");
        id          = JsonExt::GetString(map, "id");
        mode        = Mode(JsonExt::GetInt(map, "mode"));
        @name       = FormattedString(JsonExt::GetString(map, "name"));
        pb          = JsonExt::GetUint(map, "pb");
        season      = Season(JsonExt::GetInt(map, "season"));
        series      = Series(JsonExt::GetInt(map, "series"));
        silverTime  = JsonExt::GetUint(map, "silverTime");
        skipped     = JsonExt::GetBool(map, "skipped");
        uid         = JsonExt::GetString(map, "uid");

        SetMedals();
    }

    // courtesy of "BetterTOTD" plugin - https://github.com/XertroV/tm-better-totd
    // void GetMapInfoFromManager() {
        // const uint64 start = Time::Now;

        // CTrackMania@ App = cast<CTrackMania@>(GetApp());

        // CTrackManiaMenus@ MenuManager = cast<CTrackManiaMenus@>(App.MenuManager);
        // if (MenuManager is null) {
        //     warn("GetMapInfoFromManager error: null MenuManager");
        //     return;
        // }

        // CGameManiaAppTitle@ Title = MenuManager.MenuCustom_CurrentManiaApp;
        // if (Title is null) {
        //     warn("GetMapInfoFromManager error: null Title");
        //     return;
        // }

        // CGameUserManagerScript@ UserMgr = Title.UserMgr;
        // if (UserMgr is null || UserMgr.Users.Length == 0) {
        //     warn("GetMapInfoFromManager error: null UserMgr or no users");
        //     return;
        // }

        // CGameUserScript@ User = UserMgr.Users[0];
        // if (User is null) {
        //     warn("GetMapInfoFromManager error: null User");
        //     return;
        // }

        // CGameDataFileManagerScript@ FileMgr = Title.DataFileMgr;
        // if (FileMgr is null) {
        //     warn("GetMapInfoFromManager error: null FileMgr");
        //     return;
        // }

        // CWebServicesTaskResult_NadeoServicesMapScript@ task = FileMgr.Map_NadeoServices_GetFromUid(User.Id, uid);

        // while (task !is null && task.IsProcessing)
        //     yield();

        // if (task !is null && task.HasSucceeded) {
        //     CNadeoServicesMap@ taskMap = task.Map;
        //     downloadUrl = taskMap.FileUrl;

        // } else
        //     warn("GetMapInfoFromManager error: task failed");

        // try {
        //     FileMgr.TaskResult_Release(task.Id);
        // } catch {}

        // trace("GetMapInfoFromManager done: " + (Time::Now - start) + "ms");
    // }

    // void GetPB() {
        // CTrackMania@ App = cast<CTrackMania@>(GetApp());

        // if (false
        //     || App.MenuManager is null
        //     || App.MenuManager.MenuCustom_CurrentManiaApp is null
        //     || App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr is null
        //     || App.UserManagerScript is null
        //     || App.UserManagerScript.Users.Length == 0
        //     || App.UserManagerScript.Users[0] is null
        // ) {
        //     myTime = 0;
        //     return;
        // }

        // const uint pb = App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr.Map_GetRecord_v2(App.UserManagerScript.Users[0].Id, uid, "PersonalBest", "", "TimeAttack", "");
        // if (pb != uint(-1))
        //     myTime = pb;

        // SetMedals();
        // SetTargetDelta();
    // }

    void Play() {
        startnew(CoroutineFunc(PlayAsync));
    }

    // courtesy of "Play Map" plugin - https://github.com/XertroV/tm-play-map
    void PlayAsync() {
        if (loadingMap || !hasPlayPermission)
            return;

        loadingMap = true;

        trace("loading map " + (name !is null ? name.stripped : uid) + " for playing");

        // GetMapInfoFromManager();

        ReturnToMenu();

        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        App.ManiaTitleControlScriptAPI.PlayMap(downloadUrl, "TrackMania/TM_PlayMap_Local", "");

        const uint64 waitToPlayAgain = 5000;
        const uint64 now = Time::Now;

        while (Time::Now - now < waitToPlayAgain)
            yield();

        loadingMap = false;
    }

    void SetMedals() {
        if (pb == 0)
            myMedals = 0;
        else if (pb <= authorTime)
            myMedals = 4;
        else if (pb <= goldTime)
            myMedals = 3;
        else if (pb <= silverTime)
            myMedals = 2;
        else if (pb <= bronzeTime)
            myMedals = 1;
        else
            myMedals = 0;
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

            switch (year) {  // update every season
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

    // void SetTargetDelta() {
        // int delta;
        // targetDelta = "";

        // switch (S_Target) {
        //     case TargetMedal::Author: delta = myTime > 0 ? int(myTime) - int(authorTime) : int(authorTime); break;
        //     case TargetMedal::Gold:   delta = myTime > 0 ? int(myTime) - int(goldTime)   : int(goldTime);   break;
        //     case TargetMedal::Silver: delta = myTime > 0 ? int(myTime) - int(silverTime) : int(silverTime); break;
        //     case TargetMedal::Bronze: delta = myTime > 0 ? int(myTime) - int(bronzeTime) : int(bronzeTime); break;
        //     default:                  delta = 0;
        // }

        // if (delta == 0) {
        //     targetDelta = "";
        //     return;
        // }

        // if (delta < 100)
        //     targetDelta += colorDeltaSub01;
        // else if (delta < 500)
        //     targetDelta += colorDelta01to05;
        // else if (delta < 1000)
        //     targetDelta += colorDelta05to1;
        // else if (delta < 2000)
        //     targetDelta += colorDelta1to2;
        // else if (delta < 3000)
        //     targetDelta += colorDelta2to3;
        // else
        //     targetDelta += colorDeltaAbove3;

        // targetDelta += "\\$S(" + (delta < 0 ? "" : "+") + Time::Format(delta) + ") \\$Z ";  // should never be negative
    // }

    Json::Value@ ToJson() {
        Json::Value@ ret = Json::Object();

        ret["authorId"]    = authorId;
        ret["authorTime"]  = authorTime;
        ret["bookmarked"]  = bookmarked;
        ret["bronzeTime"]  = bronzeTime;
        ret["date"]        = Text::StripFormatCodes(date).Replace("\\", "");
        ret["downloadUrl"] = downloadUrl;
        ret["goldTime"]    = goldTime;
        ret["id"]          = id;
        ret["mode"]        = int(mode);
        ret["name"]        = name.raw;
        ret["pb"]          = pb;
        ret["season"]      = int(season);
        ret["series"]      = int(series);
        ret["silvertime"]  = silverTime;
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
