// c 2024-01-02
// m 2024-01-04

bool loadingMap = false;

class Map {
    uint   authorTime;
    uint   bronzeTime;
    string date;
    string downloadUrl;
    uint   goldTime;
    string id;
    uint   mxid = 0;
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
        try { mxid = map["mxid"]; } catch { }  // ManiaExchange ID, only used for fallback on certain maps
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
        FindAndPlayFromCampaign();
#endif

        const uint64 waitToPlayAgain = 5000;
        const uint64 now = Time::Now;

        while (Time::Now - now < waitToPlayAgain)
            yield();

        loadingMap = false;
    }

#if MP4
    void FindAndPlayFromCampaign() {
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

        // not working for:
        //    Canyon D02-D05, D07-D10, D12-D15, E01-E05
        // App.ManiaTitleControlScriptAPI.PlayCampaign(Campaign, MapInfo, "SingleMap", "");

        if (mxid != 0)
            FallbackPlayFromManiaExchange();
        else
            trace("map has no mxid");
    }

    // only for when the above method fails for some reason
    void FallbackPlayFromManiaExchange() {
        const uint64 now = Time::Now;
        while (Time::Now - now < 5000)
            yield();

        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        if (App.RootMap !is null && App.RootMap.MapInfo !is null && App.RootMap.MapInfo.MapUid == currentUid) {
            trace("load seems okay");
            return;
        }

        string url = "https://tm.mania.exchange/maps/download/" + mxid;

        trace("loading map from game failed, trying ManiaExchange (" + url + ")");

        App.ManiaTitleControlScriptAPI.PlayMap(url, "SingleMap", "");
    }

    // courtesy of "MXRandom" plugin - https://github.com/GreepTheSheep/openplanet-MXRandom
    bool ThisSessionPB() {
        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        CTrackManiaRaceNew@ Playground = cast<CTrackManiaRaceNew@>(App.CurrentPlayground);

        if (
            Playground is null ||
            Playground.PlayerRecordedGhost is null ||
            (myTime > 0 && myTime < Playground.PlayerRecordedGhost.RaceTime)
        )
            return false;

        myTime = Playground.PlayerRecordedGhost.RaceTime;
        CalcMedal();

        trace("new PB on " + nameClean + ": " + Time::Format(myTime));

        return true;
    }
#endif

}