// c 2024-01-02
// m 2024-01-16

bool loadingMap = false;

class Map {
    uint   authorTime;
    uint   bronzeTime;
    string date;
    string downloadUrl;
    uint   goldTime;
    string id;
    uint   myMedals = 0;
    uint   myTime   = 0;
    string nameClean;
    string nameColored;
    string nameQuoted;
    string nameRaw;
    uint   silverTime;
    string uid;

    Map() { }
    Map(Json::Value@ map) {  // campaign
        uid = map["mapUid"];
    }
    Map(int year, int month, Json::Value@ day) {  // TOTD
        date = year + "-" + ZPad2(month) + "-" + ZPad2(day["monthDay"]);
        uid = day["mapUid"];
    }

    // courtesy of "BetterTOTD" plugin - https://github.com/XertroV/tm-better-totd
    void GetMapInfoFromManager() {
        const uint64 start = Time::Now;

        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        CTrackManiaMenus@ MenuManager = cast<CTrackManiaMenus@>(App.MenuManager);
        if (MenuManager is null) {
            warn("GetMapInfoFromManager error: null MenuManager");
            return;
        }

        CGameManiaAppTitle@ Title = MenuManager.MenuCustom_CurrentManiaApp;
        if (Title is null) {
            warn("GetMapInfoFromManager error: null Title");
            return;
        }

        CGameUserManagerScript@ UserMgr = Title.UserMgr;
        if (UserMgr is null || UserMgr.Users.Length == 0) {
            warn("GetMapInfoFromManager error: null UserMgr or no users");
            return;
        }

        CGameUserScript@ User = UserMgr.Users[0];
        if (User is null) {
            warn("GetMapInfoFromManager error: null User");
            return;
        }

        CGameDataFileManagerScript@ FileMgr = Title.DataFileMgr;
        if (FileMgr is null) {
            warn("GetMapInfoFromManager error: null FileMgr");
            return;
        }

        CWebServicesTaskResult_NadeoServicesMapScript@ task = FileMgr.Map_NadeoServices_GetFromUid(User.Id, uid);

        while (task.IsProcessing)
            yield();

        if (task.HasSucceeded) {
            CNadeoServicesMap@ taskMap = task.Map;
            downloadUrl = taskMap.FileUrl;

            FileMgr.TaskResult_Release(task.Id);
        } else
            warn("GetMapInfoFromManager error: task failed");

        trace("GetMapInfoFromManager done: " + (Time::Now - start) + "ms");
    }

    // courtesy of "Play Map" plugin - https://github.com/XertroV/tm-play-map
    void Play() {
        if (loadingMap || !club)
            return;

        loadingMap = true;

        trace("loading map " + nameQuoted + " for playing");

        GetMapInfoFromManager();  // in case downloadUrl changed

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
        if (myTime == 0)
            myMedals = 0;
        else if (myTime < authorTime)
            myMedals = 4;
        else if (myTime < goldTime)
            myMedals = 3;
        else if (myTime < silverTime)
            myMedals = 2;
        else if (myTime < bronzeTime)
            myMedals = 1;
        else
            myMedals = 0;
    }

    void SetNames() {
        nameClean   = StripFormatCodes(nameRaw).Trim();
        nameColored = ColoredString(nameRaw).Trim();
        nameQuoted  = "\"" + nameClean + "\"";
    }
}