// c 2024-01-02
// m 2024-01-08

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

    // courtesy of "Play Map" plugin - https://github.com/XertroV/tm-play-map
    void Play() {
        if (loadingMap || !playPermission)
            return;

        loadingMap = true;

        trace("loading map " + nameQuoted + " for playing");

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