// c 2024-01-02
// m 2024-01-02

bool loadingMap = false;

class Map {
    uint   authorTime;
    uint   bronzeTime;
    string date;
    string downloadUrl;
    uint   goldTime;
    string id;
    uint   myMedals;
    uint   myTime;
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
    Map(int year, int month, Json::Value@ map) {  // TOTD
        date = year + "-" + ZPad2(month) + "-" + ZPad2(map["monthDay"]);
        uid = map["mapUid"];
    }

#if MP4
    Map(Json::Value@ map, int titlepack) {
        authorTime = map["authorTime"];
        bronzeTime = map["bronzeTime"];
        goldTime   = map["goldTime"];
        group      = map["group"];
        groupIndex = map["groupIndex"];
        silverTime = map["silverTime"];
        uid        = map["uid"];

        switch (titlepack) {
            case 0: nameRaw = "Canyon ";  break;
            case 1: nameRaw = "Stadium "; break;
            case 2: nameRaw = "Valley ";  break;
            case 3: nameRaw = "Lagoon ";  break;
            default:;
        }

        nameRaw += map["nameRaw"];
        nameClean = StripFormatCodes(nameRaw);
        nameColored = ColoredString(nameRaw);
        nameQuoted = "\"" + nameClean + "\"";
    }

    uint group;
    uint groupIndex;

    void CalcMedal() {
        if (myTime < authorTime) {
            myMedals = 4;
            return;
        }
        if (myTime < goldTime) {
            myMedals = 3;
            return;
        }
        if (myTime < silverTime) {
            myMedals = 2;
            return;
        }
        if (myTime < bronzeTime) {
            myMedals = 1;
            return;
        }
        myMedals = 0;
    }
#endif

    // courtesy of "Play Map" plugin - https://github.com/XertroV/tm-play-map
    void Play() {
        if (loadingMap || !playPermission)
            return;

        loadingMap = true;

        trace("loading map " + nameQuoted + " for playing");

        ReturnToMenu();

#if TMNEXT
        CTrackMania@ App = cast<CTrackMania@>(GetApp());
        App.ManiaTitleControlScriptAPI.PlayMap(downloadUrl, "TrackMania/TM_PlayMap_Local", "");
#elif MP4
        FindAndPlay();
#endif

        const uint64 waitToPlayAgain = 5000;
        const uint64 now = Time::Now;

        while (Time::Now - now < waitToPlayAgain)
            yield();

        loadingMap = false;
    }

#if MP4
    void FindAndPlay() {
        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        if (App.OfficialCampaigns.Length == 0) {
            warn("no campaigns loaded!");
            return;
        }

        CGameCtnCampaign@ Campaign = App.OfficialCampaigns[0];
        if (Campaign is null) {
            warn("Campaign is null!");
            return;
        }

        if (Campaign.MapGroups.Length == 0) {
            warn("Campaign has no map groups!");
            return;
        }

        CGameCtnChallengeGroup@ MapGroup = Campaign.MapGroups[group];
        if (MapGroup is null) {
            warn("MapGroup is null!");
            return;
        }

        if (MapGroup.MapInfos.Length == 0) {
            warn("MapGroup has no maps!");
            return;
        }

        CGameCtnChallengeInfo@ MapInfo = MapGroup.MapInfos[groupIndex];
        if (MapInfo is null) {
            warn("MapInfo is null!");
            return;
        }

        if (App.ManiaTitleControlScriptAPI is null) {
            warn("ScriptAPI is null!");
            return;
        }

        App.ManiaTitleControlScriptAPI.PlayCampaign(Campaign, MapInfo, "SingleMap", "");
    }

    // courtesy of "MXRandom" plugin - https://github.com/GreepTheSheep/openplanet-MXRandom
    bool ThisSessionPB() {
        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        CTrackManiaRaceNew@ Playground = cast<CTrackManiaRaceNew@>(App.CurrentPlayground);

        if (Playground is null || Playground.PlayerRecordedGhost is null || myTime < Playground.PlayerRecordedGhost.RaceTime)
            return false;

        myTime = Playground.PlayerRecordedGhost.RaceTime;
        CalcMedal();

        return true;
    }
#endif

}