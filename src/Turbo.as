// c 2024-01-04
// m 2024-01-04

#if TURBO

string       colorMedalSuperBronze;
string       colorMedalSuperGold;
string       colorMedalSuperSilver;
string       colorMedalSuperTrackmaster;
string       colorMedalTrackmaster;
Json::Value@ loadedMaps = Json::Object();

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
    ;

    gettingNow = false;
}

#endif