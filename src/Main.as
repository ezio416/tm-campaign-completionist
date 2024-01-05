// c 2024-01-01
// m 2024-01-04

string     accountId;
bool       allTarget       = false;
string     audienceCore    = "NadeoServices";
string     audienceLive    = "NadeoLiveServices";
string     colorMedalAuthor;
string     colorMedalBronze;
string     colorMedalGold;
string     colorMedalNone;
string     colorMedalSilver;
string     colorTarget;
string     currentUid;
bool       gettingNow      = false;

#if TMNEXT

Mode       lastMode        = S_Mode;

#endif

Map@[]     maps;
dictionary mapsByUid;
Map@[]     mapsCampaign;
dictionary mapsCampaignById;
dictionary mapsCampaignByUid;
Map@[]     mapsRemaining;
Map@[]     mapsTotd;
dictionary mapsTotdById;
dictionary mapsTotdByUid;
uint       metTargetTotal  = 0;
Map@       nextMap;
bool       playPermission  = false;
uint       progressCount   = 0;
uint       progressPercent = 0;
string     title           = "\\$F82" + Icons::CalendarO + "\\$G Campaign Completionist";

void Main() {

#if TMNEXT

    if (!Permissions::PlayLocalMap()) {
        warn("plugin requires paid access to play maps");
        UI::ShowNotification(title, "Paid access (at least standard) is required to play maps", vec4(1.0f, 0.1f, 0.1f, 0.8f));
        return;
    }

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    accountId = App.LocalPlayerInfo.WebServicesUserId;

    NadeoServices::AddAudience(audienceCore);
    NadeoServices::AddAudience(audienceLive);
#elif MP4

    GetTitlepacks();

#endif

    playPermission = true;
    OnSettingsChanged();
    GetMaps();

    while (true) {
        Loop();
        yield();
    }
}

#if MP4

void Update(float) {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    atTitleSelect = App.RootMap is null &&
        App.ActiveMenus.Length > 0 &&
        App.ActiveMenus[0] !is null &&
        App.ActiveMenus[0].CurrentFrame !is null &&
        App.ActiveMenus[0].CurrentFrame.Id.GetName() == "FrameManiaPlanetMain";
}

#endif

void RenderMenu() {
    if (UI::BeginMenu(title)) {

#if TMNEXT || MP4

        if (UI::MenuItem(Icons::Question + " Auto Switch Maps", "", S_AutoSwitch))
            S_AutoSwitch = !S_AutoSwitch;

#endif
#if TMNEXT

        if (UI::BeginMenu((S_Mode == Mode::NadeoCampaign ? "\\$1D4" : "\\$19F") + Icons::ArrowsH + " Mode: " + (S_Mode == Mode::NadeoCampaign ? "Nadeo Campaign" : "Track of the Day"), !gettingNow)) {
            if (UI::MenuItem("\\$1D4" + Icons::Kenney::Car + " Nadeo Campaign")) {
                S_Mode = Mode::NadeoCampaign;
                OnSettingsChanged();
            }
            if (UI::MenuItem("\\$19F" + Icons::Calendar + " Track of the Day")) {
                S_Mode = Mode::TrackOfTheDay;
                OnSettingsChanged();
            }
            UI::EndMenu();
        }

#elif MP4

        if (UI::BeginMenu(colorLoadedTitle + Icons::Download + " Titlepack: " + loadedTitleName, !loadingTitlepack)) {
            if (UI::MenuItem(colorCanyon + Icons::Road + " Canyon", "", false, loadedTitleName != "Canyon")) {
                S_Titlepack = Titlepack::Canyon;
                startnew(LoadTitlepack);
            }
            if (UI::MenuItem(colorStadium + Icons::Gamepad + " Stadium", "", false, loadedTitleName != "Stadium")) {
                S_Titlepack = Titlepack::Stadium;
                startnew(LoadTitlepack);
            }
            if (UI::MenuItem(colorValley + Icons::Tree + " Valley", "", false, loadedTitleName != "Valley")) {
                S_Titlepack = Titlepack::Valley;
                startnew(LoadTitlepack);
            }
            if (UI::MenuItem(colorLagoon + Icons::Shower + " Lagoon", "", false, loadedTitleName != "Lagoon")) {
                S_Titlepack = Titlepack::Lagoon;
                startnew(LoadTitlepack);
            }
            UI::EndMenu();
        }

#endif

        if (UI::BeginMenu(colorTarget + Icons::Circle + " Target Medal: " + tostring(S_Target))) {

#if TURBO

            if (UI::MenuItem(colorMedalSuperTrackmaster+ Icons::Circle + " Super Trackmaster", "")) {
                S_Target = TargetMedal::SuperTrackmaster;
                OnSettingsChanged();
                startnew(SetNextMap);
            }
            if (UI::MenuItem(colorMedalSuperGold + Icons::Circle + " Super Gold", "")) {
                S_Target = TargetMedal::SuperGold;
                OnSettingsChanged();
                startnew(SetNextMap);
            }
            if (UI::MenuItem(colorMedalSuperSilver + Icons::Circle + " Super Silver", "")) {
                S_Target = TargetMedal::SuperSilver;
                OnSettingsChanged();
                startnew(SetNextMap);
            }
            if (UI::MenuItem(colorMedalSuperBronze + Icons::Circle + " Super Bronze", "")) {
                S_Target = TargetMedal::SuperBronze;
                OnSettingsChanged();
                startnew(SetNextMap);
            }
            if (UI::MenuItem(colorMedalTrackmaster + Icons::Circle + " Trackmaster", "")) {
                S_Target = TargetMedal::Trackmaster;
                OnSettingsChanged();
                startnew(SetNextMap);
            }

#else

            if (UI::MenuItem(colorMedalAuthor + Icons::Circle + " Author", "")) {
                S_Target = TargetMedal::Author;
                OnSettingsChanged();
                startnew(SetNextMap);
            }

#endif

            if (UI::MenuItem(colorMedalGold + Icons::Circle + " Gold", "")) {
                S_Target = TargetMedal::Gold;
                OnSettingsChanged();
                startnew(SetNextMap);
            }
            if (UI::MenuItem(colorMedalSilver + Icons::Circle + " Silver", "")) {
                S_Target = TargetMedal::Silver;
                OnSettingsChanged();
                startnew(SetNextMap);
            }
            if (UI::MenuItem(colorMedalBronze + Icons::Circle + " Bronze", "")) {
                S_Target = TargetMedal::Bronze;
                OnSettingsChanged();
                startnew(SetNextMap);
            }
            if (UI::MenuItem(colorMedalNone + Icons::Circle + " None", "")) {
                S_Target = TargetMedal::None;
                OnSettingsChanged();
                startnew(SetNextMap);
            }
            UI::EndMenu();
        }

        UI::MenuItem(
            Icons::Percent + " Progress: " + (gettingNow ? "..." : metTargetTotal + "/" + maps.Length + " (" + (maps.Length > 0 ? int(100 * metTargetTotal / maps.Length) : 0) + "%)"),
            "",
            false,
            false
        );

#if TMNEXT

        if (S_Mode == Mode::NadeoCampaign) {
            if (mapsCampaign.Length > 0)
                progressPercent = uint(100.0f * float(progressCount) / float(2 * mapsCampaign.Length));
            else
                progressPercent = 0;
        } else {
            if (mapsTotd.Length > 0)
                progressPercent = uint(100.0f * float(progressCount) / float(2 * mapsTotd.Length));
            else
                progressPercent = 0;
        }

#elif MP4

        progressPercent = uint(100.0f * float(progressCount) / 130.0f);

#else

        progressPercent = uint(100.0f * float(progressCount) / 400.0f);

#endif

        string nextText = "\\$0F0" + Icons::Play + "\\$G Next: ";
        if (gettingNow)
            nextText += "still getting data... (" + progressPercent + "%)";
        else if (nextMap !is null) {

#if TMNEXT

            nextText += S_Mode == Mode::NadeoCampaign ? "" : nextMap.date + ": ";
            nextText += S_ColorMapName ? nextMap.nameColored : nextMap.nameClean;

#else

            nextText += nextMap.nameClean;

#endif

            nextText += nextMap.uid == currentUid ? " (current)" : "";
        } else
            nextText += "you're done!";

#if TMNEXT || MP4

        if (UI::MenuItem(nextText, "", false, playPermission && !gettingNow && !loadingMap && !allTarget && nextMap !is null && nextMap.uid != currentUid))
            startnew(CoroutineFunc(nextMap.Play));

#else

        UI::MenuItem(nextText, "", false, false);

#endif

        if (S_AllMapsInMenu) {
            if (UI::BeginMenu(Icons::List + " Remaining Maps (" + mapsRemaining.Length + ")", !gettingNow)) {
                for (uint i = 0; i < mapsRemaining.Length; i++) {
                    Map@ map = mapsRemaining[i];
                // for (uint i = 0; i < maps.Length; i++) {
                //     Map@ map = maps[i];

#if TMNEXT || MP4
#if TMNEXT

                    if (UI::MenuItem(S_Mode == Mode::NadeoCampaign ? map.nameClean : map.date + ": " + (S_ColorMapName ? map.nameColored : map.nameClean), "", false, !loadingMap))

#elif MP4

                    if (UI::MenuItem(map.nameClean, "", false, !loadingMap))

#endif

                        startnew(CoroutineFunc(map.Play));

#endif

                }

                UI::EndMenu();
            }
        }

        UI::EndMenu();
    }
}

void OnSettingsChanged() {

#if TMNEXT

    if (lastMode != S_Mode) {
        lastMode = S_Mode;
        startnew(GetMaps);
    }

#endif

#if TURBO

    colorMedalSuperTrackmaster = "\\" + Text::FormatGameColor(S_ColorMedalSuperTrackmaster);
    colorMedalSuperGold        = "\\" + Text::FormatGameColor(S_ColorMedalSuperGold);
    colorMedalSuperSilver      = "\\" + Text::FormatGameColor(S_ColorMedalSuperSilver);
    colorMedalSuperBronze      = "\\" + Text::FormatGameColor(S_ColorMedalSuperBronze);
    colorMedalTrackmaster      = "\\" + Text::FormatGameColor(S_ColorMedalTrackmaster);

#else

    colorMedalAuthor = "\\" + Text::FormatGameColor(S_ColorMedalAuthor);

#endif

    colorMedalGold   = "\\" + Text::FormatGameColor(S_ColorMedalGold);
    colorMedalSilver = "\\" + Text::FormatGameColor(S_ColorMedalSilver);
    colorMedalBronze = "\\" + Text::FormatGameColor(S_ColorMedalBronze);
    colorMedalNone   = "\\" + Text::FormatGameColor(S_ColorMedalNone);

#if MP4

    SetMP4Colors();

#endif

    switch (S_Target) {

#if TURBO

        case TargetMedal::SuperTrackmaster: colorTarget = colorMedalSuperTrackmaster; break;
        case TargetMedal::SuperGold:        colorTarget = colorMedalSuperGold;        break;
        case TargetMedal::SuperSilver:      colorTarget = colorMedalSuperSilver;      break;
        case TargetMedal::SuperBronze:      colorTarget = colorMedalSuperBronze;      break;
        case TargetMedal::Trackmaster:      colorTarget = colorMedalTrackmaster;      break;

#else

        case TargetMedal::Author: colorTarget = colorMedalAuthor; break;

#endif

        case TargetMedal::Gold:   colorTarget = colorMedalGold;   break;
        case TargetMedal::Silver: colorTarget = colorMedalSilver; break;
        case TargetMedal::Bronze: colorTarget = colorMedalBronze; break;
        default:                  colorTarget = colorMedalNone;
    }
}

void Loop() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

#if MP4

    if (App.LoadedManiaTitle is null) {
        loadedTitle = -1;
        loadedTitleName = "None";
    } else {
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

    if (lastLoadedTitle != loadedTitle) {
        lastLoadedTitle = loadedTitle;

        switch (loadedTitle) {
            case 0: maps = mapsCanyon;  break;
            case 1: maps = mapsStadium; break;
            case 2: maps = mapsValley;  break;
            case 3: maps = mapsLagoon;  break;
            default: maps.RemoveRange(0, maps.Length);
        }

        SetMP4Colors();
        // GetRecordsFromReplays();
        GetRecordsFromLoadedCampaign(true);
        SetNextMap();
    }

#endif

    if (loadingMap)
        return;

#if TMNEXT || MP4

    if (!S_AutoSwitch)
        return;

    if (App.RootMap is null || App.RootMap.MapInfo is null) {
        currentUid = "";
        return;
    }

    currentUid = App.RootMap.MapInfo.MapUid;

#else

    if (App.Challenge is null || App.Challenge.MapInfo is null) {
        currentUid = "";
        return;
    }

    currentUid = App.Challenge.MapInfo.MapUid;

#endif

    if (
        nextMap is null
        || nextMap.uid != currentUid

#if TMNEXT

        || App.Network is null
        || App.Network.ClientManiaAppPlayground is null
        || App.Network.ClientManiaAppPlayground.UI is null
        || App.Network.ClientManiaAppPlayground.UI.UISequence != CGamePlaygroundUIConfig::EUISequence::Finish

#elif MP4

        || App.CurrentPlayground is null
        || App.CurrentPlayground.UIConfigs.Length == 0
        // || App.CurrentPlayground.UIConfigs[0].UISequence != CGamePlaygroundUIConfig::EUISequence::EndRound
        || !nextMap.ThisSessionPB()

#endif

    )
        return;

#if TMNEXT

    CGameUserManagerScript@ UserMgr = App.Network.ClientManiaAppPlayground.UserMgr;
    if (UserMgr is null)
        return;

    MwId userId;
    if (UserMgr.Users.Length > 0)
        userId = UserMgr.Users[0].Id;
    else
        userId.Value = uint(-1);

    CGameScoreAndLeaderBoardManagerScript@ ScoreMgr = App.Network.ClientManiaAppPlayground.ScoreMgr;
    if (ScoreMgr is null)
        return;

    trace("run finished, getting PB on current map");

    nextMap.myTime = ScoreMgr.Map_GetRecord_v2(userId, currentUid, "PersonalBest", "", "TimeAttack", "");
    nextMap.myMedals = ScoreMgr.Map_GetMedal(userId, currentUid, "PersonalBest", "", "TimeAttack", "");

#endif

    Meta::PluginCoroutine@ coro = startnew(SetNextMap);
    while (coro.IsRunning())
        yield();

    if (nextMap.uid != currentUid) {
        Notify();

#if TMNEXT || MP4

        startnew(CoroutineFunc(nextMap.Play));

#endif

        sleep(10000);
    }
}

void SetNextMap() {

#if MP4

    if (loadedTitle == -1) {
        // warn("no titlepack loaded, can't set next map");
        return;
    }

#endif

    while (gettingNow)
        yield();

    trace("setting next map");

    metTargetTotal = 0;
    @nextMap = null;
    uint target = 4 - S_Target;

    mapsRemaining.RemoveRange(0, mapsRemaining.Length);

    for (uint i = 0; i < maps.Length; i++) {
        if (S_Target == TargetMedal::None) {
            if (maps[i].myTime > 0) {
                metTargetTotal++;
                continue;
            }
        } else if (maps[i].myMedals >= target) {
            metTargetTotal++;
            continue;
        }

        // print("time of " + Time::Format(maps[i].myTime) + " on " + maps[i].nameClean + " not good enough for " + tostring(S_Target));
        mapsRemaining.InsertLast(maps[i]);

        if (nextMap is null)
            @nextMap = maps[i];
    }

    if (maps.Length > 0) {
        if (metTargetTotal == maps.Length) {
            allTarget = true;
            trace("congrats, you've met your target on all maps!");
        } else {
            allTarget = false;
            if (nextMap !is null)

#if TMNEXT

                trace("next map: " + (S_Mode == Mode::NadeoCampaign ? "" : nextMap.date + ": ") + nextMap.nameClean);

#elif MP4 || TURBO

                trace("next map: " + nextMap.nameClean);

#endif

        }
    } else
        warn("no maps!");
}