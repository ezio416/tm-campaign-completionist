// c 2024-01-04
// m 2024-01-04

#if TURBO

string       colorMedalSuperBronze;
string       colorMedalSuperGold;
string       colorMedalSuperSilver;
string       colorMedalSuperTrackmaster;
string       colorMedalTrackmaster;
Json::Value@ loadedMaps      = Json::Object();
uint         recordSleepTime = 500;

void GetMaps() {
    if (gettingNow)
        return;

    gettingNow = true;

    if (loadedMaps.Length == 200) {
        gettingNow = false;
        return;
    }

    maps.RemoveRange(0, maps.Length);

    @loadedMaps = Json::FromFile("src/Assets/turbo.json");

    progressCount = 0;

    for (uint i = 0; i < loadedMaps.Length; i++) {
        progressCount++;

        string key = ZPad3(i);
        Map@ map = Map(loadedMaps[key]);
        maps.InsertLast(map);
        mapsByUid.Set(map.uid, @map);
    }

    GetRecords();
}

void GetRecords() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.Challenge is null)
        NotifyWarn("Open any map to get records for all of them");

    while (App.Challenge is null)
        yield();

    trace("getting records");

    // CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    // if (Network is null) {
    //     warn("Network is null, can't get records");
    //     gettingNow = false;
    //     return;
    // }

    // CTrackManiaRaceRules@ RaceRules = Network.TmRaceRules;

    // if (RaceRules is null) {
    //     warn("RaceRules is null, can't get records");
    //     gettingNow = false;
    //     return;
    // }

    // CGameDataManagerScript@ DataMgr = RaceRules.DataMgr;

    // if (DataMgr is null) {
    //     warn("DataMgr is null, can't get records");
    //     gettingNow = false;
    //     return;
    // }

    recordSleepTime = 10;

    for (uint i = 0; i < maps.Length; i++) {
        progressCount++;

        maps[i].CheckPB();

        print(maps[i].nameClean);

        // Map@ map = maps[i];

        // DataMgr.RetrieveRecordsNoMedals(map.uid, DataMgr.MenuUserId);
        // yield();

        // if (DataMgr.Ready) {
        //     for (uint j = 0; j < DataMgr.Records.Length; j++) {
        //         if (DataMgr.Records[j].GhostName == "Solo_BestGhost") {
        //             if (map.myTime > 0 && map.myTime < DataMgr.Records[j].Time)
        //                 return;

        //             print("setting time on " + map.nameClean + " to " + Time::Format(DataMgr.Records[j].Time));
        //             map.myTime = DataMgr.Records[j].Time;
        //             map.CalcMedal();
        //             break;
        //         }
        //     }
        // }
    }

    recordSleepTime = 500;

    trace("getting records done");

    gettingNow = false;

    SetNextMap();
}

#endif