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
    uint   myMedals = 0;
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

        App.ManiaTitleControlScriptAPI.PlayMap(downloadUrl, "TrackMania/TM_PlayMap_Local", "");

        const uint64 waitToPlayAgain = 5000;
        const uint64 now = Time::Now;

        while (Time::Now - now < waitToPlayAgain)
            yield();

        loadingMap = false;
    }
}