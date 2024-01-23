// c 2024-01-01
// m 2024-01-23

string       accountId;
bool         allTarget          = false;
const string audienceCore       = "NadeoServices";
const string audienceLive       = "NadeoLiveServices";
bool         club               = false;
string       colorSeries;
string       colorTarget;
string       currentUid;
bool         gettingNow         = false;
Map@[]       maps;
Map@[]       mapsCampaign;
dictionary@  mapsCampaignById   = dictionary();
dictionary@  mapsCampaignByUid  = dictionary();
Map@[]       mapsRemaining;
Map@[]       mapsTotd;
dictionary@  mapsTotdById       = dictionary();
dictionary@  mapsTotdByUid      = dictionary();
uint         metTargetTotal     = 0;
Map@         nextMap;
const string title              = "\\$0F0" + Icons::Check + "\\$G Campaign Completionist";

void Main() {
    if (Permissions::PlayLocalMap())
        club = true;
    else {
        warn("Club access required to play maps");

        if (S_NotifyStarter)
            UI::ShowNotification(title, "Club access is required to play maps, but you can still track your progress on the current Nadeo Campaign", vec4(1.0f, 0.1f, 0.1f, 0.8f));
    }

    lastMode = S_Mode;
    lastOnlyCurrentCampaign = S_OnlyCurrentCampaign;
    OnSettingsChanged();

    accountId = GetApp().LocalPlayerInfo.WebServicesUserId;

    NadeoServices::AddAudience(audienceCore);
    NadeoServices::AddAudience(audienceLive);

    LoadBookmarks();

    GetMaps();

    while (true) {
        Loop();
        yield();
    }
}

void RenderMenu() {
    if (UI::BeginMenu(title)) {
        if (club) {
            if (S_MenuAutoSwitch && UI::MenuItem("\\$S" + Icons::Question + " Auto Switch Maps", "", S_AutoSwitch))
                S_AutoSwitch = !S_AutoSwitch;

            if (UI::MenuItem(
                S_Mode == Mode::NadeoCampaign ? "\\$1D4\\$S" + Icons::Kenney::Car + " Mode: Nadeo Campaign" : "\\$19F\\$S" + Icons::Calendar + " Mode: Track of the Day",
                "",
                false,
                !gettingNow
            )) {
                S_Mode = S_Mode == Mode::NadeoCampaign ? Mode::TrackOfTheDay : Mode::NadeoCampaign;
                OnSettingsChanged();
            }

            if (S_MenuOnlyCurrentCampaign && S_Mode == Mode::NadeoCampaign && UI::MenuItem("\\$S" + Icons::ClockO + " Only Current Campaign", "", S_OnlyCurrentCampaign)) {
                S_OnlyCurrentCampaign = !S_OnlyCurrentCampaign;
                startnew(SetNextMap);
            }
        } else {
            UI::MenuItem("\\$1D4\\$S" + Icons::ArrowsH + " Mode: Nadeo Campaign", "", false, false);

            if (S_Mode == Mode::TrackOfTheDay)
                S_Mode = Mode::NadeoCampaign;
        }

        if (S_MenuSeries && S_Mode == Mode::NadeoCampaign && UI::BeginMenu(colorSeries + "\\$S" + Icons::Columns + " Series: " + tostring(S_Series))) {
            if (UI::MenuItem(colorSeriesAll + "\\$S" + Icons::Columns + " All", "", S_Series == CampaignSeries::All, S_Series != CampaignSeries::All)) {
                S_Series = CampaignSeries::All;
                OnSettingsChanged();
            }
            if (UI::MenuItem(colorSeriesWhite + "\\$S" + Icons::Columns + " White", "", S_Series == CampaignSeries::White, S_Series != CampaignSeries::White)) {
                S_Series = CampaignSeries::White;
                OnSettingsChanged();
            }
            if (UI::MenuItem(colorSeriesGreen + "\\$S" + Icons::Columns + " Green", "", S_Series == CampaignSeries::Green, S_Series != CampaignSeries::Green)) {
                S_Series = CampaignSeries::Green;
                OnSettingsChanged();
            }
            if (UI::MenuItem(colorSeriesBlue + "\\$S" + Icons::Columns + " Blue", "", S_Series == CampaignSeries::Blue, S_Series != CampaignSeries::Blue)) {
                S_Series = CampaignSeries::Blue;
                OnSettingsChanged();
            }
            if (UI::MenuItem(colorSeriesRed + "\\$S" + Icons::Columns + " Red", "", S_Series == CampaignSeries::Red, S_Series != CampaignSeries::Red)) {
                S_Series = CampaignSeries::Red;
                OnSettingsChanged();
            }
            if (UI::MenuItem(colorSeriesBlack + "\\$S" + Icons::Columns + " Black", "", S_Series == CampaignSeries::Black, S_Series != CampaignSeries::Black)) {
                S_Series = CampaignSeries::Black;
                OnSettingsChanged();
            }

            UI::EndMenu();
        }

        if (S_MenuRefresh && UI::MenuItem("\\$S" + Icons::Refresh + " Refresh Records", "", false, !gettingNow))
            startnew(RefreshRecords);

        if (UI::BeginMenu(colorTarget + "\\$S" + Icons::Circle + " Target Medal: " + tostring(S_Target))) {
            if (UI::MenuItem(colorMedalAuthor + "\\$S" + Icons::Circle + " Author", "", S_Target == TargetMedal::Author, S_Target != TargetMedal::Author)) {
                S_Target = TargetMedal::Author;
                OnSettingsChanged();
                startnew(SetNextMap);
            }
            if (UI::MenuItem(colorMedalGold + "\\$S" + Icons::Circle + " Gold", "", S_Target == TargetMedal::Gold, S_Target != TargetMedal::Gold)) {
                S_Target = TargetMedal::Gold;
                OnSettingsChanged();
                startnew(SetNextMap);
            }
            if (UI::MenuItem(colorMedalSilver + "\\$S" + Icons::Circle + " Silver", "", S_Target == TargetMedal::Silver, S_Target != TargetMedal::Silver)) {
                S_Target = TargetMedal::Silver;
                OnSettingsChanged();
                startnew(SetNextMap);
            }
            if (UI::MenuItem(colorMedalBronze + "\\$S" + Icons::Circle + " Bronze", "", S_Target == TargetMedal::Bronze, S_Target != TargetMedal::Bronze)) {
                S_Target = TargetMedal::Bronze;
                OnSettingsChanged();
                startnew(SetNextMap);
            }
            if (UI::MenuItem(colorMedalNone + "\\$S" + Icons::Circle + " None", "", S_Target == TargetMedal::None, S_Target != TargetMedal::None)) {
                S_Target = TargetMedal::None;
                OnSettingsChanged();
                startnew(SetNextMap);
            }
            UI::EndMenu();
        }

        UI::MenuItem(
            "\\$S" + Icons::Percent + " Progress: " + (gettingNow ? "..." : metTargetTotal + "/" + maps.Length + " (" + (int(100 * metTargetTotal / maps.Length)) +"%)"),
            "",
            false,
            false
        );

        bool nextMapBookmarked = false;

        string nextText = "\\$0F0\\$S" + Icons::Play + "\\$FFF Next: \\$S";

        if (gettingNow)
            nextText += "\\$AAA\\$Sstill getting data...";
        else if (nextMap !is null) {
            nextMapBookmarked = bookmarkedUids.HasKey(nextMap.uid);

            if (S_MenuBookmarkIcons)
                nextText += "\\$S" + (nextMapBookmarked ? Icons::Bookmark : Icons::BookmarkO) + "\\$Z ";

            if (S_MenuTargetDelta)
                nextText += nextMap.targetDelta;

            nextText += S_Mode == Mode::NadeoCampaign ? "" : nextMap.date + ": ";
            nextText += "\\$Z" + (S_ColorMapNames ? nextMap.nameColored : nextMap.nameClean);
            nextText += nextMap.uid == currentUid ? "\\$Z\\$S (current)" : "";
        } else
            nextText += "you're done!";

        if (UI::MenuItem(nextText, "", false, club && !gettingNow && !loadingMap && !allTarget && nextMap !is null && nextMap.uid != currentUid))
            startnew(CoroutineFunc(nextMap.Play));

        if (nextMap !is null)
            BookmarkAction(nextMapBookmarked, nextMap.uid);

        if (S_MenuAllMaps && mapsRemaining.Length > 0 && UI::BeginMenu("\\$S" + Icons::List + " Remaining Maps (" + mapsRemaining.Length + ")", !gettingNow)) {
            for (uint i = 0; i < mapsRemaining.Length; i++) {
                Map@ map = mapsRemaining[i];

                bool bookmarked = bookmarkedUids.HasKey(map.uid);

                string remainingText = "\\$S";

                if (S_MenuBookmarkIcons)
                    remainingText += (bookmarked ? Icons::Bookmark : Icons::BookmarkO) + "\\$S ";

                if (S_MenuTargetDelta)
                    remainingText += map.targetDelta;

                remainingText += S_Mode == Mode::NadeoCampaign ? map.nameClean : map.date + ": " + (S_ColorMapNames ? map.nameColored : map.nameClean);

                if (UI::MenuItem(remainingText, "", false, club))
                    startnew(CoroutineFunc(map.Play));

                BookmarkAction(bookmarked, map.uid);
            }

            UI::EndMenu();
        }

        if (S_MenuAllBookmarks && mapsBookmarked.Length > 0 && UI::BeginMenu("\\$S" + Icons::List + " Bookmarked Maps (" + mapsBookmarked.Length + ")", mapsBookmarked.Length > 0)) {
            for (uint i = 0; i < mapsBookmarked.Length; i++) {
                Map@ map = mapsBookmarked[i];

                string bookmarkedText;

                if (S_MenuTargetDelta)
                    bookmarkedText += map.targetDelta;

                bookmarkedText += S_Mode == Mode::NadeoCampaign ? map.nameClean : map.date + ": " + (S_ColorMapNames ? map.nameColored : map.nameClean);

                if (UI::MenuItem(bookmarkedText, "", false, club))
                    startnew(CoroutineFunc(map.Play));

                BookmarkAction(true, map.uid);
            }

            UI::EndMenu();
        }

        UI::EndMenu();
    }
}

void Render() {
    RenderDebug();
}

void OnSettingsChanged() {
    if (
        lastMode != S_Mode
        || lastOnlyCurrentCampaign != S_OnlyCurrentCampaign
        || lastSeries != S_Series
    ) {
        lastMode = S_Mode;
        lastOnlyCurrentCampaign = S_OnlyCurrentCampaign;
        lastSeries = S_Series;
        startnew(SetNextMap);
    }

    colorSeriesAll   = Text::FormatOpenplanetColor(S_ColorSeriesAll);
    colorSeriesWhite = Text::FormatOpenplanetColor(S_ColorSeriesWhite);
    colorSeriesGreen = Text::FormatOpenplanetColor(S_ColorSeriesGreen);
    colorSeriesBlue  = Text::FormatOpenplanetColor(S_ColorSeriesBlue);
    colorSeriesRed   = Text::FormatOpenplanetColor(S_ColorSeriesRed);
    colorSeriesBlack = Text::FormatOpenplanetColor(S_ColorSeriesBlack);

    switch (S_Series) {
        case CampaignSeries::All:   colorSeries = colorSeriesAll;   break;
        case CampaignSeries::White: colorSeries = colorSeriesWhite; break;
        case CampaignSeries::Green: colorSeries = colorSeriesGreen; break;
        case CampaignSeries::Blue:  colorSeries = colorSeriesBlue;  break;
        case CampaignSeries::Red:   colorSeries = colorSeriesRed;   break;
        case CampaignSeries::Black: colorSeries = colorSeriesBlack; break;
        default:;
    }

    colorMedalAuthor = Text::FormatOpenplanetColor(S_ColorMedalAuthor);
    colorMedalGold   = Text::FormatOpenplanetColor(S_ColorMedalGold);
    colorMedalSilver = Text::FormatOpenplanetColor(S_ColorMedalSilver);
    colorMedalBronze = Text::FormatOpenplanetColor(S_ColorMedalBronze);
    colorMedalNone   = Text::FormatOpenplanetColor(S_ColorMedalNone);

    switch (S_Target) {
        case TargetMedal::Author: colorTarget = colorMedalAuthor; break;
        case TargetMedal::Gold:   colorTarget = colorMedalGold;   break;
        case TargetMedal::Silver: colorTarget = colorMedalSilver; break;
        case TargetMedal::Bronze: colorTarget = colorMedalBronze; break;
        default:                  colorTarget = colorMedalNone;
    }

    colorDeltaSub01  = Text::FormatOpenplanetColor(S_ColorDeltaSub01);
    colorDelta01to05 = Text::FormatOpenplanetColor(S_ColorDelta01to05);
    colorDelta05to1  = Text::FormatOpenplanetColor(S_ColorDelta05to1);
    colorDelta1to2   = Text::FormatOpenplanetColor(S_ColorDelta1to2);
    colorDelta2to3   = Text::FormatOpenplanetColor(S_ColorDelta2to3);
    colorDeltaAbove3 = Text::FormatOpenplanetColor(S_ColorDeltaAbove3);

    for (uint i = 0; i < maps.Length; i++)
        maps[i].SetTargetDelta();
}

void Loop() {
    if (!club) {
        if (S_AutoSwitch)
            S_AutoSwitch = false;

        if (S_MenuAutoSwitch)
            S_MenuAutoSwitch = false;

        if (S_MenuOnlyCurrentCampaign)
            S_MenuOnlyCurrentCampaign = false;

        if (S_Mode == Mode::TrackOfTheDay)
            S_Mode = Mode::NadeoCampaign;

        if (!S_OnlyCurrentCampaign)
            S_OnlyCurrentCampaign = true;
    }

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.RootMap is null || App.RootMap.MapInfo is null) {
        currentUid = "";
        return;
    }

    if (loadingMap)
        return;

    currentUid = App.RootMap.MapInfo.MapUid;

    if (nextMap is null
        || nextMap.uid != currentUid
        || App.Network is null
        || App.Network.ClientManiaAppPlayground is null
        || App.Network.ClientManiaAppPlayground.ScoreMgr is null
        || App.Network.ClientManiaAppPlayground.UI is null
        || App.Network.ClientManiaAppPlayground.UI.UISequence != CGamePlaygroundUIConfig::EUISequence::Finish
        || App.UserManagerScript is null
        || App.UserManagerScript.Users.Length == 0
    )
        return;

    trace("run finished, getting PB on current map");

    uint prevTime = nextMap.myTime;

    for (uint i = 0; i < 20; i++)
        yield();  // allow game to process PB

    nextMap.myTime = App.Network.ClientManiaAppPlayground.ScoreMgr.Map_GetRecord_v2(App.UserManagerScript.Users[0].Id, currentUid, "PersonalBest", "", "TimeAttack", "");
    nextMap.SetMedals();
    nextMap.SetTargetDelta();

    Meta::PluginCoroutine@ coro = startnew(SetNextMap);
    while (coro.IsRunning())
        yield();

    if (nextMap is null)
        return;  // finished all maps

    if (nextMap.uid != currentUid) {
        Notify();

        if (S_AutoSwitch && club) {
            startnew(CoroutineFunc(nextMap.Play));
            sleep(10000);  // give some time for next map to load before checking again
        }
    } else
        NotifyTimeNeeded(prevTime == 0 || nextMap.myTime < prevTime);

    try {
        while (
            App.Network.ClientManiaAppPlayground.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::Finish ||
            App.Network.ClientManiaAppPlayground.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::EndRound
        )
            yield();
    } catch {
        return;
    }
}

void SetNextMap() {
    while (gettingNow)
        yield();

    trace("setting next map");

    metTargetTotal = 0;
    @nextMap = null;
    uint target = 4 - S_Target;

    mapsBookmarked.RemoveRange(0, mapsBookmarked.Length);
    mapsRemaining.RemoveRange(0, mapsRemaining.Length);

    if (!club) {
        if (S_Mode == Mode::TrackOfTheDay)
            S_Mode = Mode::NadeoCampaign;

        if (!S_OnlyCurrentCampaign)
            S_OnlyCurrentCampaign = true;
    }

    maps = S_Mode == Mode::NadeoCampaign ? mapsCampaign : mapsTotd;

    if (S_Mode == Mode::NadeoCampaign && S_OnlyCurrentCampaign && maps.Length >= 25)
        maps.RemoveRange(0, maps.Length - 25);

    if (!club)
        maps.RemoveRange(10, 15);

    if (S_Mode == Mode::NadeoCampaign && S_Series != CampaignSeries::All) {
        for (int i = maps.Length - 1; i >= 0 ; i--) {
            string mapNum = maps[i].nameClean.SubStr(maps[i].nameClean.Length - 2, 2);

            switch (S_Series) {
                case CampaignSeries::White:
                    if (seriesWhite.Find(mapNum) == -1)
                        maps.RemoveAt(i);
                    break;
                case CampaignSeries::Green:
                    if (seriesGreen.Find(mapNum) == -1)
                        maps.RemoveAt(i);
                    break;
                case CampaignSeries::Blue:
                    if (seriesBlue.Find(mapNum) == -1)
                        maps.RemoveAt(i);
                    break;
                case CampaignSeries::Red:
                    if (seriesRed.Find(mapNum) == -1)
                        maps.RemoveAt(i);
                    break;
                case CampaignSeries::Black:
                    if (seriesBlack.Find(mapNum) == -1)
                        maps.RemoveAt(i);
                    break;
                default:;
            }
        }
    }

    for (uint i = 0; i < maps.Length; i++) {
        Map@ map = maps[i];

        map.SetTargetDelta();

        if (S_Target == TargetMedal::None) {
            if (map.myTime > 0) {
                metTargetTotal++;
                continue;
            }
        } else if (map.myMedals >= target) {
            metTargetTotal++;
            continue;
        }

        mapsRemaining.InsertLast(map);

        if (bookmarkedUids.HasKey(map.uid))
            mapsBookmarked.InsertLast(map);

        if (nextMap is null)
            @nextMap = map;
    }

    if (metTargetTotal == maps.Length) {
        allTarget = true;
        print("congrats, you've met your target on all maps!");
    } else {
        allTarget = false;
        if (nextMap !is null)
            trace("next map: " + nextMap.date + ": " + nextMap.nameClean);
    }
}