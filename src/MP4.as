// c 2024-01-03
// m 2024-01-15

#if MP4

bool         atTitleSelect      = false;
bool         checkingTitlepacks = false;
string       colorCanyon;
string       colorLoadedTitle;
string       colorStadium;
string       colorValley;
string       colorLagoon;
bool         hasCanyon          = false;
bool         hasStadium         = false;
bool         hasValley          = false;
bool         hasLagoon          = false;
int          lastLoadedTitle    = -1;
Json::Value@ loadedCanyon       = Json::Object();
Json::Value@ loadedStadium      = Json::Object();
int          loadedTitle        = -1;
string       loadedTitleName;
Json::Value@ loadedValley       = Json::Object();
Json::Value@ loadedLagoon       = Json::Object();
bool         loadingTitlepack   = false;
dictionary   mapsByUid;
Map@[]       mapsCanyon;
Map@[]       mapsStadium;
Map@[]       mapsValley;
Map@[]       mapsLagoon;

void GetTitlepacks() {
    if (checkingTitlepacks)
        return;

    checkingTitlepacks = true;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    while (App.ManiaTitles.Length == 0)
        yield();

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

    checkingTitlepacks = false;
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

    // maps.RemoveRange(0, maps.Length);
    mapsCanyon.RemoveRange(0, mapsCanyon.Length);
    mapsStadium.RemoveRange(0, mapsStadium.Length);
    mapsValley.RemoveRange(0, mapsValley.Length);
    mapsLagoon.RemoveRange(0, mapsLagoon.Length);
    mapsByUid.DeleteAll();

    if (hasCanyon) {
        trace("loading Canyon maps");
        @loadedCanyon = Json::FromFile("src/Assets/mp4_canyon.json");

        for (uint i = 0; i < loadedCanyon.Length; i++) {
            string key = ZPad2(i);
            Map@ map = Map(loadedCanyon[key], 0);
            mapsCanyon.InsertLast(map);
            mapsByUid.Set(map.uid, @map);
        }
    }

    if (hasStadium) {
        trace("loading Stadium maps");
        @loadedStadium = Json::FromFile("src/Assets/mp4_stadium.json");

        for (uint i = 0; i < loadedStadium.Length; i++) {
            string key = ZPad2(i);
            Map@ map = Map(loadedStadium[key], 1);
            mapsStadium.InsertLast(map);
            mapsByUid.Set(map.uid, @map);
        }
    }

    if (hasValley) {
        trace("loading Valley maps");
        @loadedValley = Json::FromFile("src/Assets/mp4_valley.json");

        for (uint i = 0; i < loadedValley.Length; i++) {
            string key = ZPad2(i);
            Map@ map = Map(loadedValley[key], 2);
            mapsValley.InsertLast(map);
            mapsByUid.Set(map.uid, @map);
        }
    }

    if (hasLagoon) {
        trace("loading Lagoon maps");
        @loadedLagoon = Json::FromFile("src/Assets/mp4_lagoon.json");

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

        map.myTime = Info.BestTime;
        map.SetMedals();
    }

    trace("getting records from replays done");

    // GetRecordsFromLoadedCampaign();
    gettingNow = false;
}

void GetRecordsFromLoadedCampaign(bool fromTitleSwitch = false) {
    if (fromTitleSwitch) {
        for (uint i = 0; i < 20; i++)
            yield();  // give game time to load maps into the campaign
    }

    if (loadedTitle == -1) {
        // warn("no titlepack loaded, can't load records from campaign");
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
            map.SetMedals();
        }
    }

    trace("getting records from loaded campaign done");

    gettingNow = false;
}

void LoadTitlepack() {
    if (loadingTitlepack)
        return;

    loadingTitlepack = true;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.ManiaTitles.Length == 0) {
        warn("game not loaded yet!");
        return;
    }

    CGameManiaPlanetScriptAPI@ ScriptAPI = App.ManiaPlanetScriptAPI;
    if (ScriptAPI is null) {
        warn("failed to load titlepack - ScriptAPI null");
        return;
    }

    bool success = false;

    switch (S_Titlepack) {
        case Titlepack::Canyon:
            if (App.LoadedManiaTitle !is null && App.LoadedManiaTitle.TitleId == "TMCanyon@nadeo") {
                trace("already in Canyon");
                success = true;
                break;
            }
            if (hasCanyon) {
                NotifyTrace("Switching titlepack to Canyon...");
                ReturnToTitleSelect();
                // ScriptAPI.SelectTitle("TMCanyon@nadeo");
                ScriptAPI.EnterTitle("TMCanyon@nadeo");
                success = true;
            } else
                NotifyWarn("You don't own Canyon!");
            break;
        case Titlepack::Stadium:
            if (App.LoadedManiaTitle !is null && App.LoadedManiaTitle.TitleId == "TMStadium@nadeo") {
                trace("already in Stadium");
                success = true;
                break;
            }
            if (hasStadium) {
                NotifyTrace("Switching titlepack to Stadium...");
                ReturnToTitleSelect();
                // ScriptAPI.SelectTitle("TMCanyon@nadeo");
                ScriptAPI.EnterTitle("TMStadium@nadeo");
                success = true;
            } else
                NotifyWarn("You don't have Stadium!");
            break;
        case Titlepack::Valley:
            if (App.LoadedManiaTitle !is null && App.LoadedManiaTitle.TitleId == "TMValley@nadeo") {
                trace("already in Valley");
                success = true;
                break;
            }
            if (hasValley) {
                NotifyTrace("Switching titlepack to Valley...");
                ReturnToTitleSelect();
                // ScriptAPI.SelectTitle("TMCanyon@nadeo");
                ScriptAPI.EnterTitle("TMValley@nadeo");
                success = true;
            } else
                NotifyWarn("You don't have Valley!");
            break;
        case Titlepack::Lagoon:
            if (App.LoadedManiaTitle !is null && App.LoadedManiaTitle.TitleId == "TMLagoon@nadeo") {
                trace("already in Lagoon");
                success = true;
                break;
            }
            if (hasLagoon) {
                NotifyTrace("Switching titlepack to Lagoon...");
                ReturnToTitleSelect();
                // ScriptAPI.SelectTitle("TMCanyon@nadeo");
                ScriptAPI.EnterTitle("TMLagoon@nadeo");
                success = true;
            } else
                NotifyWarn("You don't have Lagoon!");
            break;
        default:;
    }

    if (success) {
        mapsRemaining.RemoveRange(0, mapsRemaining.Length);

        while (
            App.LoadedManiaTitle is null ||
            App.ActiveMenus.Length == 0 ||
            App.ActiveMenus[0] is null ||
            App.ActiveMenus[0].CurrentFrame is null ||
            App.ActiveMenus[0].CurrentFrame.Id.GetName() != "FrameMenuCustom"
        )
            yield();
    }

    loadingTitlepack = false;
}

void ReturnToTitleSelect() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.ManiaTitles.Length == 0) {
        warn("game not loaded yet!");
        return;
    }

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
        // warn("not in titlepack menu!");
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

            ReturnToTitleSelect();  // may need to go back a few times

            return;
        }
    }

    warn("FrameContent not found!");
}

// void SelectOpponentCampaign() {
    // trace("selecting opponent in campaign menu");

    // CTrackMania@ App = cast<CTrackMania@>(GetApp());
    // CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    // if (Network is null)
    //     return;

    // const uint64 now = Time::Now;
    // while (App.RootMap is null && Time::Now - now < 10000)
    //     yield();  // time this so we don't get stuck if the map load fails

    // CTmRaceInterfaceManialinkScripHandler@ Handler = cast<CTmRaceInterfaceManialinkScripHandler@>(Network.PlaygroundInterfaceScriptHandler);  // yes, nando misspelled this one
    // if (Handler is null)
    //     return;

    // MwFastBuffer<wstring> ghostChoice = MwFastBuffer<wstring>();
    // ghostChoice.Add("0");  // C_GhostChoice_None
    // Handler.SendCustomEvent("StartRaceMenuEvent_StartRace", ghostChoice);

    // warn("can't set opponent in campaign mode");
// }

void SelectOpponentLocal() {
    if (!S_AutoOpponent)
        return;

    trace("selecting opponent in local menu");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    const uint64 now = Time::Now;
    while (Time::Now - now < 10000 && (App.RootMap is null || App.RootMap.MapInfo is null || App.ActiveMenus.Length == 0))
        yield();  // time this so we don't get stuck if the map load fails

    try {
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

        if (CurrentFrame.Id.GetName() != "FrameDialogQuickChooseGhostOpponents") {
            warn("not in opponent selection menu!");
            return;
        }

        if (CurrentFrame.Childs.Length == 0) {
            warn("CurrentFrame has no children!");
            return;
        }

        for (uint i = 0; i < CurrentFrame.Childs.Length; i++) {
            CControlFrame@ FrameContent = cast<CControlFrame@>(CurrentFrame.Childs[i]);
            if (FrameContent is null)
                continue;

            if (FrameContent.Id.GetName() == "FrameContent") {
                if (FrameContent.Childs.Length == 0) {
                    warn("FrameContent has no children!");
                    return;
                }

                for (uint j = 0; j < FrameContent.Childs.Length; j++) {
                    CControlPager@ Pager = cast<CControlPager@>(FrameContent.Childs[j]);  // go to medals page if on a regional one
                    if (Pager !is null && Pager.Id.GetName() == "PagerGridZones" && Pager.ButtonNextPage !is null) {
                        for (uint k = 0; k < 4; k++) {
                            // trace("clicking next page");
                            Pager.ButtonNextPage.OnAction();
                        }
                    }

                    CControlListCard@ ListRankings = cast<CControlListCard@>(FrameContent.Childs[j]);
                    if (ListRankings is null)
                        continue;

                    if (ListRankings.Id.GetName() == "ListRankings") {
                        if (ListRankings.Childs.Length < 5 || ListRankings.Childs.Length > 6) {
                            warn("ListRankings has a wrong number of children!");
                            return;
                        }

                        CControlFrame@ GhostFrame = cast<CControlFrame@>(ListRankings.Childs[GetOpponentButtonIndex(ListRankings.Childs.Length, App.RootMap.MapInfo.MapUid)]);
                        if (GhostFrame is null) {
                            warn("GhostFrame is null!");
                            return;
                        }

                        if (GhostFrame.Childs.Length == 0) {
                            warn("GhostFrame has no children!");
                            return;
                        }

                        for (uint k = 0; k < GhostFrame.Childs.Length; k++) {
                            CControlButton@ Button = cast<CControlButton@>(GhostFrame.Childs[k]);
                            if (Button is null)
                                continue;

                            if (Button.Id.GetName() == "ButtonFocus") {
                                trace("selecting opponent (" + (S_OpponentSelection == OpponentSelection::None ? "None" : tostring(S_Target)) + ")");
                                Button.IsFocused = true;
                                Button.OnAction();
                                break;
                            }

                            warn("ButtonFocus not found!");
                            return;
                        }

                        for (uint k = 0; k < CurrentFrame.Childs.Length; k++) {
                            CGameControlCardGeneric@ ButtonPlay = cast<CGameControlCardGeneric@>(CurrentFrame.Childs[k]);
                            if (ButtonPlay is null)
                                continue;

                            if (ButtonPlay.Id.GetName() == "ButtonPlay") {
                                if (ButtonPlay.Childs.Length == 0) {
                                    warn("ButtonPlay has no children!");
                                    return;
                                }

                                for (uint l = 0; l < ButtonPlay.Childs.Length; l++) {
                                    CControlButton@ ButtonSelection = cast<CControlButton@>(ButtonPlay.Childs[l]);
                                    if (ButtonSelection is null)
                                        continue;

                                    if (ButtonSelection.Id.GetName() == "ButtonSelection") {
                                        trace("clicking play");
                                        ButtonSelection.IsFocused = true;
                                        ButtonSelection.OnAction();
                                        return;
                                    }
                                }

                                warn("ButtonSelection not found!");
                                return;
                            }
                        }

                        warn("ButtonPlay not found!");
                        return;
                    }

                    warn("ListRankings not found!");
                    return;
                }
            }
        }

        warn("FrameContent not found!");
    } catch {
        NotifyWarn("Error selecting opponent, maybe it loaded in campaign mode?", false);
        warn("exception in selecting opponent: " + getExceptionInfo());
    }
}

uint GetOpponentButtonIndex(uint length, const string &in uid) {
    trace("getting opponent index");

    if (length == 5)
        return S_OpponentSelection == OpponentSelection::None ? 4 : S_Target;

    if (!mapsByUid.Exists(uid)) {
        warn("map not found! returning 0");
        return 0;
    }

    Map@ map = cast<Map@>(mapsByUid[uid]);
    if (map is null) {
        warn("map is null! returning 0");
        return 0;
    }

    if (S_OpponentSelection == OpponentSelection::None) {
        if (map.myMedals == 0)
            return 4;

        return 5;
    } else {
        bool targetAuthor = S_Target == TargetMedal::Author;
        bool targetGold   = S_Target == TargetMedal::Gold;
        bool targetSilver = S_Target == TargetMedal::Silver;

        switch (map.myMedals) {
            case 4:  return S_Target + 1;
            case 3:  return targetAuthor ? 0 : S_Target + 1;
            case 2:  return targetAuthor ? 0 : targetGold ? 1 : S_Target + 1;
            case 1:  return targetAuthor ? 0 : targetGold ? 1 : targetSilver ? 2 : S_Target + 1;
            default: return S_Target;
        }
    }
}

void SetLoadedTitle() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.LoadedManiaTitle is null) {
        loadedTitle = -1;
        loadedTitleName = "None";
        return;
    }

    string titleId = App.LoadedManiaTitle.TitleId;

    if (titleId == "TMCanyon@nadeo") {
        loadedTitle = 0;
        loadedTitleName = "Canyon";
    } else if (titleId == "TMStadium@nadeo") {
        loadedTitle = 1;
        loadedTitleName = "Stadium";
    } else if (titleId == "TMValley@nadeo") {
        loadedTitle = 2;
        loadedTitleName = "Valley";
    } else if (titleId == "TMLagoon@nadeo") {
        loadedTitle = 3;
        loadedTitleName = "Lagoon";
    }
}

void SetMP4Colors() {
    colorCanyon  = Text::FormatOpenplanetColor(S_ColorCanyon);
    colorStadium = Text::FormatOpenplanetColor(S_ColorStadium);
    colorValley  = Text::FormatOpenplanetColor(S_ColorValley);
    colorLagoon  = Text::FormatOpenplanetColor(S_ColorLagoon);

    switch (loadedTitle) {
        case 0:  colorLoadedTitle = colorCanyon;  break;
        case 1:  colorLoadedTitle = colorStadium; break;
        case 2:  colorLoadedTitle = colorValley;  break;
        case 3:  colorLoadedTitle = colorLagoon;  break;
        default: colorLoadedTitle = "";
    }
}

void RefreshRecords() { }

#endif