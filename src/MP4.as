// c 2024-01-03
// m 2024-01-04

#if MP4

string       colorCanyon;
string       colorLoadedTitle;
string       colorStadium;
string       colorValley;
string       colorLagoon;
bool         hasCanyon   = false;
bool         hasStadium  = false;
bool         hasValley   = false;
bool         hasLagoon   = false;
int          lastLoadedTitle = -1;
Json::Value@ loadedCanyon = Json::Object();
Json::Value@ loadedStadium = Json::Object();
int          loadedTitle = -1;
string       loadedTitleName;
Json::Value@ loadedValley = Json::Object();
Json::Value@ loadedLagoon = Json::Object();
Map@[]       mapsCanyon;
Map@[]       mapsStadium;
Map@[]       mapsValley;
Map@[]       mapsLagoon;

void GetTitlepacks() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    for (uint i = 0; i < App.ManiaTitles.Length; i++) {
        CGameManiaTitle@ title = App.ManiaTitles[i];
        if (title is null)
            continue;

        if (title.TitleId == "TMCanyon@nadeo") {
            hasCanyon = true;
            continue;
        }

        if (title.TitleId == "TMStadium@nadeo") {
            hasStadium = true;
            continue;
        }

        if (title.TitleId == "TMValley@nadeo") {
            hasValley = true;
            continue;
        }

        if (title.TitleId == "TMLagoon@nadeo") {
            hasLagoon = true;
            continue;
        }
    }
}

void GetMaps() {
    if (gettingNow)
        return;

    gettingNow = true;

    if (
        (!hasCanyon  || loadedCanyon.Length  == 65) &&
        (!hasStadium || loadedStadium.Length == 65) &&
        (!hasValley  || loadedValley.Length  == 65) &&
        (!hasLagoon  || loadedLagoon.Length  == 65)
    ) {
        gettingNow = false;
        return;
    }

    progressCount = 0;

    // maps.RemoveRange(0, maps.Length);
    mapsCanyon.RemoveRange(0, mapsCanyon.Length);
    mapsStadium.RemoveRange(0, mapsStadium.Length);
    mapsValley.RemoveRange(0, mapsValley.Length);
    mapsLagoon.RemoveRange(0, mapsLagoon.Length);
    mapsByUid.DeleteAll();

    if (hasCanyon) {
        trace("loading Canyon maps");
        @loadedCanyon = Json::FromFile("src/MapsMP4/canyon.json");

        for (uint i = 0; i < loadedCanyon.Length; i++) {
            string key = ZPad2(i);
            Map@ map = Map(loadedCanyon[key], 0);
            mapsCanyon.InsertLast(map);
            mapsByUid.Set(map.uid, @map);
        }
    }

    if (hasStadium) {
        trace("loading Stadium maps");
        @loadedStadium = Json::FromFile("src/MapsMP4/stadium.json");

        for (uint i = 0; i < loadedStadium.Length; i++) {
            string key = ZPad2(i);
            Map@ map = Map(loadedStadium[key], 1);
            mapsStadium.InsertLast(map);
            mapsByUid.Set(map.uid, @map);
        }
    }

    if (hasValley) {
        trace("loading Valley maps");
        @loadedValley = Json::FromFile("src/MapsMP4/valley.json");

        for (uint i = 0; i < loadedValley.Length; i++) {
            string key = ZPad2(i);
            Map@ map = Map(loadedValley[key], 2);
            mapsValley.InsertLast(map);
            mapsByUid.Set(map.uid, @map);
        }
    }

    if (hasLagoon) {
        trace("loading Lagoon maps");
        @loadedLagoon = Json::FromFile("src/MapsMP4/lagoon.json");

        for (uint i = 0; i < loadedLagoon.Length; i++) {
            string key = ZPad2(i);
            Map@ map = Map(loadedLagoon[key], 3);
            mapsLagoon.InsertLast(map);
            mapsByUid.Set(map.uid, @map);
        }
    }

    GetRecordsFromReplays();
}

void GetRecordsFromReplays() {
    gettingNow = true;

    trace("getting records from replays");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    for (uint i = 0; i < App.ReplayRecordInfos.Length; i++) {
        CGameCtnReplayRecordInfo@ Info = App.ReplayRecordInfos[i];
        if (Info is null || Info.MapUid == "")
            continue;

        Map@ map = cast<Map@>(mapsByUid[Info.MapUid]);
        if (map is null) {  // probably just not a Nadeo map
            // warn("map not found: " + Info.MapUid);
            continue;
        }

        progressCount++;

        map.myTime = Info.BestTime;
        map.CalcMedal();
    }

    trace("getting records from replays done");

    // GetRecordsFromLoadedCampaign();
    gettingNow = false;
}

void GetRecordsFromLoadedCampaign(bool fromTitleSwitch = false) {
    if (fromTitleSwitch) {
        for (uint i = 0; i < 10; i++)
            yield();  // give game time to load maps into the campaign
    }

    if (loadedTitle == -1) {
        warn("no titlepack loaded, can't load records from campaign");
        return;
    }

    gettingNow = true;

    trace("getting records from loaded campaign");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.OfficialCampaigns.Length == 0) {
        warn("no campaigns loaded!");
        gettingNow = false;
        return;
    }

    CGameCtnCampaign@ Campaign = App.OfficialCampaigns[0];
    if (Campaign is null) {
        warn("Campaign is null!");
        gettingNow = false;
        return;
    }

    if (Campaign.MapGroups.Length == 0) {
        warn("Campaign has no map groups!");
        gettingNow = false;
        return;
    }

    for (uint i = 0; i < Campaign.MapGroups.Length; i++) {
        if (Campaign.MapGroups[i].MapInfos.Length == 0) {
            warn("MapGroup[" + i + "] has no maps!");
            continue;
        }

        for (uint j = 0; j < Campaign.MapGroups[i].MapInfos.Length; j++) {
            CGameCtnChallengeInfo@ MapInfo = Campaign.MapGroups[i].MapInfos[j];
            if (MapInfo is null) {
                warn("MapInfo[ " + j + "] is null!");
                continue;
            }

            Map@ map = cast<Map@>(mapsByUid[MapInfo.MapUid]);
            if (map is null) {
                warn("map[" + MapInfo.MapUid + "] is null!");
                continue;
            }

            if (map.myTime > 0) {
                // trace(map.nameClean + " already has a time of " + Time::Format(map.myTime));
                continue;
            }

            if (MapInfo.BestTime == uint(-1)) {
                // warn("no time exists for " + map.nameClean);
                continue;
            }

            // trace("found time for " + map.nameClean);
            map.myTime = MapInfo.BestTime;
            map.CalcMedal();
        }
    }

    trace("getting records from loaded campaign done");

    gettingNow = false;
}

void SetMP4Colors() {
    colorCanyon  = "\\" + Text::FormatGameColor(S_ColorCanyon);
    colorStadium = "\\" + Text::FormatGameColor(S_ColorStadium);
    colorValley  = "\\" + Text::FormatGameColor(S_ColorValley);
    colorLagoon  = "\\" + Text::FormatGameColor(S_ColorLagoon);

    switch (loadedTitle) {
        case 0:  colorLoadedTitle = colorCanyon;  break;
        case 1:  colorLoadedTitle = colorStadium; break;
        case 2:  colorLoadedTitle = colorValley;  break;
        case 3:  colorLoadedTitle = colorLagoon;  break;
        default: colorLoadedTitle = "";
    }
}

#endif