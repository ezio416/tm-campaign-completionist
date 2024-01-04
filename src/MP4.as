// c 2024-01-03
// m 2024-01-04

#if MP4

string       colorCanyon;
string       colorLoadedTitle;
string       colorStadium;
string       colorValley;
string       colorLagoon;
bool         hasCanyon       = false;
bool         hasStadium      = false;
bool         hasValley       = false;
bool         hasLagoon       = false;
int          lastLoadedTitle = -1;
Json::Value@ loadedCanyon    = Json::Object();
Json::Value@ loadedStadium   = Json::Object();
int          loadedTitle     = -1;
string       loadedTitleName;
Json::Value@ loadedValley    = Json::Object();
Json::Value@ loadedLagoon    = Json::Object();
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

void LoadTitlepack() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameManiaPlanetScriptAPI@ ScriptAPI = App.ManiaPlanetScriptAPI;
    if (ScriptAPI is null) {
        warn("failed to load titlepack - ScriptAPI null");
        return;
    }

    switch (desiredTitlepack) {
        case 0:
            if (hasCanyon) {
                ReturnToTitleSelect();
                ScriptAPI.SelectTitle("TMCanyon@nadeo");
                ScriptAPI.EnterTitle("TMCanyon@nadeo");
            } else
                warn("you don't own Canyon!");
            break;
        case 1:
            if (hasStadium) {
                ReturnToTitleSelect();
                ScriptAPI.SelectTitle("TMCanyon@nadeo");
                ScriptAPI.EnterTitle("TMStadium@nadeo");
            } else
                warn("you don't have Stadium!");
            break;
        case 2:
            if (hasValley) {
                ReturnToTitleSelect();
                ScriptAPI.SelectTitle("TMCanyon@nadeo");
                ScriptAPI.EnterTitle("TMValley@nadeo");
            } else
                warn("you don't have Valley!");
            break;
        case 3:
            if (hasLagoon) {
                ReturnToTitleSelect();
                ScriptAPI.SelectTitle("TMCanyon@nadeo");
                ScriptAPI.EnterTitle("TMLagoon@nadeo");
            } else
                warn("you don't have Lagoon!");
            break;
        default: warn("invalid titlepack: " + desiredTitlepack);
    }
}

void ReturnToTitleSelect() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.ActiveMenus.Length == 0) {
        warn("no active menus!");
        return;
    }

    CGameMenu@ Menu = App.ActiveMenus[0];
    if (Menu is null) {
        warn("Menu is null!");
        return;
    }

    CGameMenuFrame@ CurrentFrame = Menu.CurrentFrame;
    if (CurrentFrame is null) {
        warn("CurrentFrame is null!");
        return;
    }

    if (CurrentFrame.Id.GetName() != "FrameMenuCustom") {
        warn("not in titlepack menu!");
        return;
    }

    if (CurrentFrame.Childs.Length == 0) {
        warn("CurrentFrame has no children!");
        return;
    }

    CGameMenuFrame@ Instance = cast<CGameMenuFrame@>(CurrentFrame.Childs[0]);
    if (Instance is null) {
        warn("Instance is null!");
        return;
    }

    if (Instance.Id.GetName() != "MenuFrameInstance") {
        warn("Instance has wrong type: " + Instance.Id.GetName());
        return;
    }

    if (Instance.Childs.Length == 0) {
        warn("Instance has no children!");
        return;
    }

    for (uint i = 0; i < Instance.Childs.Length; i++) {
        CControlFrame@ Content = cast<CControlFrame@>(Instance.Childs[i]);
        if (Content is null)
            continue;

        if (Content.Id.GetName() == "FrameContent") {
            if (Content.Childs.Length == 0) {
                warn("Content has no children!");
                return;
            }

            CControlFrame@ Container = cast<CControlFrame@>(Content.Childs[0]);
            if (Container is null) {
                warn("Container is null!");
                return;
            }

            if (Container.Childs.Length < 12) {
                warn("Container doesn't have enough children!");
                return;
            }

            CControlFrame@ Frame1 = cast<CControlFrame@>(Container.Childs[11]);  // #12
            if (Frame1 is null) {
                warn("Frame1 is null!");
                return;
            }

            if (Frame1.Childs.Length == 0) {
                warn("Frame1 has no children!");
                return;
            }

            CControlFrame@ Frame2 = cast<CControlFrame@>(Frame1.Childs[0]);  // #1
            if (Frame2 is null) {
                warn("Frame2 is null!");
                return;
            }

            if (Frame2.Childs.Length < 4) {
                warn("Frame2 doesn't have enough children!");
                return;
            }

            CControlFrame@ Frame3 = cast<CControlFrame@>(Frame2.Childs[3]);  // #4
            if (Frame3 is null) {
                warn("Frame3 is null!");
                return;
            }

            if (Frame3.Childs.Length == 0) {
                warn("Frame3 has no children!");
                return;
            }

            CControlQuad@ BackBtn = cast<CControlQuad@>(Frame3.Childs[0]);  // #1
            if (BackBtn is null) {
                warn("BackBtn is null!");
                return;
            }

            BackBtn.OnAction();

            for (uint j = 0; j < 10; j++)
                yield();

            return;
        }
    }

    warn("FrameContent not found!");
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