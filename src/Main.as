// c 2024-01-01
// m 2024-11-29

const string  pluginColor = "\\$0F0";
const string  pluginIcon  = Icons::Check;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

// string       accountId;
// bool         allTarget         = false;
// const string audienceCore      = "NadeoServices";
// const string audienceLive      = "NadeoLiveServices";
// string       colorSeason;
// string       colorSeries;
// string       colorTarget;
// string       currentUid;
UI::Font@    fontHeader;
UI::Font@    fontSmall;
UI::Font@    fontSmol;
UI::Font@    fontSubHeader;
// bool         gettingNow        = false;
bool         hasPlayPermission = false;
// string       iconSeason;
bool         loadingMap        = false;
dictionary@  maps              = dictionary();
Map@[]       mapsArr;
// Map@[]       mapsCampaign;
// dictionary@  mapsCampaignById  = dictionary();
// dictionary@  mapsCampaignByUid = dictionary();
// Map@[]       mapsRemaining;
// Map@[]       mapsTotd;
// dictionary@  mapsTotdById      = dictionary();
// dictionary@  mapsTotdByUid     = dictionary();
// uint         metTargetTotal    = 0;
// Map@         nextMap;
const float  scale             = UI::GetScale();
const string shadow            = "\\$S";
const float  indentWidth       = scale * 20.0f;
// const uint   seasonCount       = 18;  // update every season

void Main() {
    if (!(hasPlayPermission = Permissions::PlayLocalMap())) {
        warn("This plugin requires paid access");

        if (S_NotifyStarter)
            UI::ShowNotification(pluginTitle, "Paid access is required", vec4(1.0f, 0.1f, 0.1f, 0.8f));

        return;
    }

    @fontHeader    = UI::LoadFont("DroidSans.ttf", 26);
    // @fontSmall     = UI::LoadFont("DroidSans.ttf", 12);
    // @fontSmol      = UI::LoadFont("DroidSans.ttf", 8);
    @fontSubHeader = UI::LoadFont("DroidSans.ttf", 20);

    // lastMode = S_Mode;
    // lastOnlyCurrentCampaign = S_OnlyCurrentCampaign;
    // lastSeason = S_Season;
    // lastSeries = S_Series;
    // lastMenuExcludeSkips = S_MenuExcludeSkips;
    OnSettingsChanged();

    // accountId = GetApp().LocalPlayerInfo.WebServicesUserId;

    // NadeoServices::AddAudience(audienceCore);
    // NadeoServices::AddAudience(audienceLive);

    // LoadBookmarks();
    // yield();
    // LoadSkips();
    // yield();

    API::GetMapsAsync();

    // while (true) {
    //     Loop();
    //     yield();
    // }
}

void Render() {
    if (!hasPlayPermission)
        return;

    RenderWindowDetached();
}

void RenderMenu() {
    if (!hasPlayPermission || !UI::BeginMenu(pluginTitle))
        return;

    Window(WindowSource::Menu);

    UI::EndMenu();
}

// void RenderMenu() {
    // if (UI::BeginMenu(title)) {
    //     if (hasPlayPermission) {
    //         if (S_MenuAutoSwitch && UI::MenuItem("\\$S" + Icons::ArrowsH + " Auto Switch Maps", "", S_AutoSwitch))
    //             S_AutoSwitch = !S_AutoSwitch;

    //         if (UI::MenuItem(
    //             S_Mode == Mode::NadeoCampaign ? "\\$1D4\\$S" + Icons::Kenney::Car + " Mode: Nadeo Campaign" : "\\$19F\\$S" + Icons::Calendar + " Mode: Track of the Day",
    //             "",
    //             false,
    //             !gettingNow
    //         )) {
    //             S_Mode = S_Mode == Mode::NadeoCampaign ? Mode::TrackOfTheDay : Mode::NadeoCampaign;
    //             OnSettingsChanged();
    //         }

    //         if (S_MenuOnlyCurrentCampaign && S_Mode == Mode::NadeoCampaign && UI::MenuItem("\\$S" + Icons::ClockO + " Only Current Season", "", S_OnlyCurrentCampaign)) {
    //             S_OnlyCurrentCampaign = !S_OnlyCurrentCampaign;
    //             startnew(SetNextMap);
    //         }
    //     } else {
    //         UI::MenuItem("\\$1D4\\$S" + Icons::ArrowsH + " Mode: Nadeo Campaign", "", false, false);

    //         if (S_Mode == Mode::TrackOfTheDay)
    //             S_Mode = Mode::NadeoCampaign;
    //     }

    //     if (S_MenuSeason && hasPlayPermission) {
    //         if (S_Mode == Mode::NadeoCampaign && !S_OnlyCurrentCampaign && UI::BeginMenu(colorSeason + "\\$S" + iconSeason + " Season: " + (tostring(S_Season).Replace("_", " ")))) {
    //             if (UI::MenuItem(colorSeasonAll + "\\$S" + iconSeasonAll + " All", "", S_Season == Season::All, S_Season != Season::All)) {
    //                 S_Season = Season::All;
    //                 OnSettingsChanged();
    //             }
    //             if (UI::MenuItem(colorSeasonUnknown + "\\$S" + iconSeasonUnknown + " Unknown", "", S_Season == Season::Unknown, S_Season != Season::Unknown)) {
    //                 S_Season = Season::Unknown;
    //                 OnSettingsChanged();
    //             }

    //             UI::Separator();

    //             for (uint i = 0; i < seasonCount; i++) {
    //                 const Season season = Season(i + 2);
    //                 const string seasonStr = tostring(season);
    //                 const string[]@ seasonParts = seasonStr.Split("_");
    //                 const string seasonName = seasonParts[0];
    //                 const string seasonYear = seasonParts[1];

    //                 string color;
    //                 string icon;

    //                 if (seasonName == "Winter") {
    //                     color = colorSeasonWinter;
    //                     icon = iconSeasonWinter;
    //                 } else if (seasonName == "Spring") {
    //                     color = colorSeasonSpring;
    //                     icon = iconSeasonSpring;
    //                 } else if (seasonName == "Summer") {
    //                     color = colorSeasonSummer;
    //                     icon = iconSeasonSummer;
    //                 } else {
    //                     color = colorSeasonFall;
    //                     icon = iconSeasonFall;
    //                 }

    //                 if (UI::MenuItem(color + "\\$S" + icon + " " + seasonName + " " + seasonYear, "", S_Season == season, S_Season != season)) {
    //                     S_Season = season;
    //                     OnSettingsChanged();
    //                 }
    //             }

    //             UI::EndMenu();

    //         } else if (S_Mode == Mode::TrackOfTheDay) {
    //             string seasonMonths = "\\$S";

    //             if (S_Season == Season::All)
    //                 seasonMonths += iconSeasonAll + " Season: All";
    //             else if (S_Season == Season::Unknown)
    //                 seasonMonths += iconSeasonUnknown + " Season: Unknown";
    //             else {
    //                 const string seasonName = tostring(S_Season);
    //                 const string seasonYear = seasonName.SubStr(seasonName.Length - 4, 4);

    //                 if (seasonName.StartsWith("Winter"))
    //                     seasonMonths += iconSeasonWinter + " Season: Jan-Mar " + seasonYear;
    //                 else if (seasonName.StartsWith("Spring"))
    //                     seasonMonths += iconSeasonSpring + " Season: Apr-Jun " + seasonYear;
    //                 else if (seasonName.StartsWith("Summer"))
    //                     seasonMonths += iconSeasonSummer + " Season: Jul-Sep " + seasonYear;
    //                 else
    //                     seasonMonths += iconSeasonFall + " Season: Oct-Dec " + seasonYear;
    //             }

    //             if (UI::BeginMenu(colorSeason + seasonMonths)) {
    //                 if (UI::MenuItem(colorSeasonAll + "\\$S" + iconSeasonAll + " All", "", S_Season == Season::All, S_Season != Season::All)) {
    //                     S_Season = Season::All;
    //                     OnSettingsChanged();
    //                 }
    //                 if (UI::MenuItem(colorSeasonUnknown + "\\$S" + iconSeasonUnknown + " Unknown", "", S_Season == Season::Unknown, S_Season != Season::Unknown)) {
    //                     S_Season = Season::Unknown;
    //                     OnSettingsChanged();
    //                 }

    //                 UI::Separator();

    //                 for (uint i = 0; i < seasonCount; i++) {
    //                     const Season season = Season(i + 2);
    //                     const string seasonStr = tostring(season);
    //                     const string[]@ seasonParts = seasonStr.Split("_");
    //                     const string seasonName = seasonParts[0];
    //                     const string seasonYear = seasonParts[1];

    //                     string color;
    //                     string icon;
    //                     string seasonNameTotd;

    //                     if (seasonName == "Winter") {
    //                         color = colorSeasonWinter;
    //                         icon = iconSeasonWinter;
    //                         seasonNameTotd = " Jan-Mar ";
    //                     } else if (seasonName == "Spring") {
    //                         color = colorSeasonSpring;
    //                         icon = iconSeasonSpring;
    //                         seasonNameTotd = " Apr-Jun ";
    //                     } else if (seasonName == "Summer") {
    //                         color = colorSeasonSummer;
    //                         icon = iconSeasonSummer;
    //                         seasonNameTotd = " Jul-Sep ";
    //                     } else {
    //                         color = colorSeasonFall;
    //                         icon = iconSeasonFall;
    //                         seasonNameTotd = " Oct-Dec ";
    //                     }

    //                     if (UI::MenuItem(color + "\\$S" + icon + seasonNameTotd + seasonYear, "", S_Season == season, S_Season != season)) {
    //                         S_Season = season;
    //                         OnSettingsChanged();
    //                     }
    //                 }

    //                 UI::EndMenu();
    //             }
    //         }
    //     }

    //     if (S_MenuSeries && S_Mode == Mode::NadeoCampaign && UI::BeginMenu(colorSeries + "\\$S" + Icons::Columns + " Series: " + tostring(S_Series))) {
    //         if (UI::MenuItem(colorSeriesAll + "\\$S" + Icons::Columns + " All", "", S_Series == CampaignSeries::All, S_Series != CampaignSeries::All)) {
    //             S_Series = CampaignSeries::All;
    //             OnSettingsChanged();
    //         }

    //         UI::Separator();

    //         if (UI::MenuItem(colorSeriesWhite + "\\$S" + Icons::Columns + " White", "", S_Series == CampaignSeries::White, S_Series != CampaignSeries::White)) {
    //             S_Series = CampaignSeries::White;
    //             OnSettingsChanged();
    //         }
    //         if (UI::MenuItem(colorSeriesGreen + "\\$S" + Icons::Columns + " Green", "", S_Series == CampaignSeries::Green, S_Series != CampaignSeries::Green)) {
    //             S_Series = CampaignSeries::Green;
    //             OnSettingsChanged();
    //         }
    //         if (UI::MenuItem(colorSeriesBlue + "\\$S" + Icons::Columns + " Blue", "", S_Series == CampaignSeries::Blue, S_Series != CampaignSeries::Blue)) {
    //             S_Series = CampaignSeries::Blue;
    //             OnSettingsChanged();
    //         }
    //         if (UI::MenuItem(colorSeriesRed + "\\$S" + Icons::Columns + " Red", "", S_Series == CampaignSeries::Red, S_Series != CampaignSeries::Red)) {
    //             S_Series = CampaignSeries::Red;
    //             OnSettingsChanged();
    //         }
    //         if (UI::MenuItem(colorSeriesBlack + "\\$S" + Icons::Columns + " Black", "", S_Series == CampaignSeries::Black, S_Series != CampaignSeries::Black)) {
    //             S_Series = CampaignSeries::Black;
    //             OnSettingsChanged();
    //         }

    //         UI::EndMenu();
    //     }

    //     if (S_MenuRefresh && UI::MenuItem("\\$S" + Icons::Refresh + " Refresh Records", "", false, !gettingNow))
    //         startnew(RefreshRecords);

    //     if (UI::BeginMenu(colorTarget + "\\$S" + Icons::Circle + " Target Medal: " + tostring(S_Target))) {
    //         if (UI::MenuItem(colorMedalAuthor + "\\$S" + Icons::Circle + " Author", "", S_Target == TargetMedal::Author, S_Target != TargetMedal::Author)) {
    //             S_Target = TargetMedal::Author;
    //             OnSettingsChanged();
    //             startnew(SetNextMap);
    //         }
    //         if (UI::MenuItem(colorMedalGold + "\\$S" + Icons::Circle + " Gold", "", S_Target == TargetMedal::Gold, S_Target != TargetMedal::Gold)) {
    //             S_Target = TargetMedal::Gold;
    //             OnSettingsChanged();
    //             startnew(SetNextMap);
    //         }
    //         if (UI::MenuItem(colorMedalSilver + "\\$S" + Icons::Circle + " Silver", "", S_Target == TargetMedal::Silver, S_Target != TargetMedal::Silver)) {
    //             S_Target = TargetMedal::Silver;
    //             OnSettingsChanged();
    //             startnew(SetNextMap);
    //         }
    //         if (UI::MenuItem(colorMedalBronze + "\\$S" + Icons::Circle + " Bronze", "", S_Target == TargetMedal::Bronze, S_Target != TargetMedal::Bronze)) {
    //             S_Target = TargetMedal::Bronze;
    //             OnSettingsChanged();
    //             startnew(SetNextMap);
    //         }
    //         if (UI::MenuItem(colorMedalNone + "\\$S" + Icons::Circle + " None", "", S_Target == TargetMedal::None, S_Target != TargetMedal::None)) {
    //             S_Target = TargetMedal::None;
    //             OnSettingsChanged();
    //             startnew(SetNextMap);
    //         }
    //         UI::EndMenu();
    //     }

    //     UI::MenuItem(
    //         "\\$S" + Icons::Percent + " Progress: " + (gettingNow ? "..." : metTargetTotal + "/" + maps.Length + " (" + (maps.Length > 0 ? int(100 * metTargetTotal / maps.Length) : 100) + "%)"),
    //         "",
    //         false,
    //         false
    //     );

    //     bool nextMapBookmarked = false;

    //     string nextText = "\\$0F0\\$S" + Icons::Play + "\\$FFF Next: ";

    //     if (gettingNow)
    //         nextText += "\\$AAA\\$Sstill getting data...";
    //     else if (nextMap !is null) {
    //         nextMapBookmarked = bookmarkedUids.HasKey(nextMap.uid);

    //         if (S_MenuBookmarkIcons)
    //             nextText += "\\$Z\\$S" + (nextMapBookmarked ? Icons::Bookmark : Icons::BookmarkO) + " ";

    //         if (S_MenuTargetDelta)
    //             nextText += "\\$Z" + nextMap.targetDelta;

    //         nextText += S_Mode == Mode::NadeoCampaign ? "" : nextMap.date + ": ";
    //         nextText += "\\$Z" + (S_ColorMapNames ? nextMap.nameColored : nextMap.nameClean);
    //         nextText += nextMap.uid == currentUid ? "\\$Z\\$S (current)" : "";
    //     } else
    //         nextText += "you're done!";

    //     if (UI::MenuItem(nextText, "", false, hasPlayPermission && !gettingNow && !loadingMap && !allTarget && nextMap !is null && nextMap.uid != currentUid))
    //         startnew(CoroutineFunc(nextMap.Play));

    //     if (nextMap !is null)
    //         ClickAction(false, nextMapBookmarked, nextMap.uid);

    //     if (S_MenuAllMaps && mapsRemaining.Length > 0 && UI::BeginMenu("\\$S" + Icons::List + " Remaining (" + mapsRemaining.Length + ")", !gettingNow)) {
    //         for (uint i = 0; i < mapsRemaining.Length; i++) {
    //             Map@ map = mapsRemaining[i];

    //             if (i > 0 && map.season != mapsRemaining[i - 1].season)
    //                 UI::Separator();

    //             const bool skipped = skippedUids.HasKey(map.uid);
    //             const bool bookmarked = bookmarkedUids.HasKey(map.uid);

    //             string remainingText;

    //             if (S_MenuSkipIcons)
    //                 remainingText += "\\$S" + (skipped ? Icons::Times : Icons::CircleO) + (S_MenuBookmarkIcons ? "" : " ");

    //             if (S_MenuBookmarkIcons)
    //                 remainingText += "\\$Z\\$S" + (bookmarked ? Icons::Bookmark : Icons::BookmarkO) + " ";

    //             if (S_MenuTargetDelta)
    //                 remainingText += "\\$Z" + map.targetDelta;

    //             remainingText += S_Mode == Mode::NadeoCampaign ? map.nameClean : map.date + ": " + (S_ColorMapNames ? map.nameColored : map.nameClean);

    //             if (UI::MenuItem(remainingText, "", false, hasPlayPermission))
    //                 startnew(CoroutineFunc(map.Play));

    //             ClickAction(skipped, bookmarked, map.uid);
    //         }

    //         UI::EndMenu();
    //     }

    //     if (S_MenuAllSkips && mapsSkipped.Length > 0 && UI::BeginMenu("\\$S" + Icons::Times + " Skipped (" + mapsSkipped.Length + ")", !gettingNow)) {
    //         for (uint i = 0; i < mapsSkipped.Length; i++) {
    //             Map@ map = mapsSkipped[i];

    //             if (i > 0 && map.season != mapsSkipped[i - 1].season)
    //                 UI::Separator();

    //             string skippedText;

    //             const bool bookmarked = bookmarkedUids.HasKey(map.uid);

    //             if (S_MenuBookmarkIcons)
    //                 skippedText += "\\$S" + (bookmarked ? Icons::Bookmark : Icons::BookmarkO) + " ";

    //             if (S_MenuTargetDelta)
    //                 skippedText += "\\$Z" + map.targetDelta;

    //             skippedText += S_Mode == Mode::NadeoCampaign ? map.nameClean : map.date + ": " + (S_ColorMapNames ? map.nameColored : map.nameClean);

    //             if (UI::MenuItem(skippedText, "", false, hasPlayPermission))
    //                 startnew(CoroutineFunc(map.Play));

    //             ClickAction(true, bookmarked, map.uid);
    //         }

    //         UI::EndMenu();
    //     }

    //     if (S_MenuAllBookmarks && mapsBookmarked.Length > 0 && UI::BeginMenu("\\$S" + Icons::Bookmark + " Bookmarked (" + mapsBookmarked.Length + ")", !gettingNow)) {
    //         for (uint i = 0; i < mapsBookmarked.Length; i++) {
    //             Map@ map = mapsBookmarked[i];

    //             if (i > 0 && map.season != mapsBookmarked[i - 1].season)
    //                 UI::Separator();

    //             string bookmarkedText;

    //             const bool skipped = skippedUids.HasKey(map.uid);

    //             if (S_MenuSkipIcons)
    //                 bookmarkedText += "\\$S" + (skipped ? Icons::Times : Icons::CircleO) + " ";

    //             if (S_MenuTargetDelta)
    //                 bookmarkedText += "\\$Z" + map.targetDelta;

    //             bookmarkedText += S_Mode == Mode::NadeoCampaign ? map.nameClean : map.date + ": " + (S_ColorMapNames ? map.nameColored : map.nameClean);

    //             if (UI::MenuItem(bookmarkedText, "", false, hasPlayPermission))
    //                 startnew(CoroutineFunc(map.Play));

    //             ClickAction(skipped, true, map.uid);
    //         }

    //         UI::EndMenu();
    //     }

    //     UI::EndMenu();
    // }
// }

void OnSettingsChanged() {
    SetDeltaColors();
    SetMedalColors();
    SetModeColors();
    SetSeasonColors();
    SetSeriesColors();
}

// void Loop() {
    // if (!hasPlayPermission) {
    //     if (S_AutoSwitch)
    //         S_AutoSwitch = false;

    //     if (S_MenuAutoSwitch)
    //         S_MenuAutoSwitch = false;

    //     if (S_MenuOnlyCurrentCampaign)
    //         S_MenuOnlyCurrentCampaign = false;

    //     if (S_Mode == Mode::TrackOfTheDay)
    //         S_Mode = Mode::NadeoCampaign;

    //     if (!S_OnlyCurrentCampaign)
    //         S_OnlyCurrentCampaign = true;
    // }

    // CTrackMania@ App = cast<CTrackMania@>(GetApp());

    // if (App.RootMap is null) {
    //     currentUid = "";
    //     return;
    // }

    // if (loadingMap)
    //     return;

    // currentUid = App.RootMap.EdChallengeId;

    // if (false
    //     || nextMap is null
    //     || nextMap.uid != currentUid
    //     || App.Network is null
    //     || App.Network.ClientManiaAppPlayground is null
    //     || App.Network.ClientManiaAppPlayground.ScoreMgr is null
    //     || App.Network.ClientManiaAppPlayground.UI is null
    //     || App.Network.ClientManiaAppPlayground.UI.UISequence != CGamePlaygroundUIConfig::EUISequence::Finish
    //     || App.UserManagerScript is null
    //     || App.UserManagerScript.Users.Length == 0
    // )
    //     return;

    // trace("run finished, getting PB on current map");

    // const uint prevTime = nextMap.myTime;

    // sleep(500);  // allow game to process PB, 500ms should be enough time

    // if (false
    //     || App.Network.ClientManiaAppPlayground is null
    //     || App.Network.ClientManiaAppPlayground.ScoreMgr is null
    //     || App.UserManagerScript is null
    //     || App.UserManagerScript.Users.Length == 0
    // )
    //     return;

    // nextMap.GetPB();

    // SetNextMap();

    // if (nextMap is null)
    //     return;  // finished all maps

    // if (nextMap.uid != currentUid) {
    //     Notify();

    //     if (S_AutoSwitch && hasPlayPermission) {
    //         startnew(CoroutineFunc(nextMap.Play));
    //         sleep(10000);  // give some time for next map to load before checking again
    //     }
    // } else
    //     NotifyTimeNeeded(prevTime == 0 || nextMap.myTime < prevTime);

    // try {
    //     while (false
    //         || App.Network.ClientManiaAppPlayground.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::Finish
    //         || App.Network.ClientManiaAppPlayground.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::EndRound
    //     )
    //         yield();
    // } catch { }
// }

// void SetNextMap() {
    // while (gettingNow)
    //     yield();

    // trace("setting next map");

    // metTargetTotal = 0;
    // @nextMap = null;

    // mapsBookmarked = {};
    // mapsRemaining  = {};
    // mapsSkipped    = {};

    // if (!hasPlayPermission) {
    //     if (S_Mode == Mode::TrackOfTheDay)
    //         S_Mode = Mode::NadeoCampaign;

    //     if (!S_OnlyCurrentCampaign)
    //         S_OnlyCurrentCampaign = true;
    // }

    // maps = S_Mode == Mode::NadeoCampaign ? mapsCampaign : mapsTotd;

    // if (S_Mode == Mode::NadeoCampaign && S_OnlyCurrentCampaign && maps.Length >= 25)
    //     maps.RemoveRange(0, maps.Length - 25);

    // if (!hasPlayPermission)
    //     maps.RemoveRange(10, 15);

    // if (S_Season != Season::All) {
    //     for (int i = maps.Length - 1; i >= 0 ; i--) {
    //         if (maps[i].season != S_Season)
    //             maps.RemoveAt(i);
    //     }
    // }

    // if (S_Mode == Mode::NadeoCampaign && S_Series != CampaignSeries::All) {
    //     for (int i = maps.Length - 1; i >= 0 ; i--) {
    //         string mapNum = maps[i].nameClean.SubStr(maps[i].nameClean.Length - 2, 2);

    //         switch (S_Series) {
    //             case CampaignSeries::White:
    //                 if (seriesWhite.Find(mapNum) == -1)
    //                     maps.RemoveAt(i);
    //                 break;
    //             case CampaignSeries::Green:
    //                 if (seriesGreen.Find(mapNum) == -1)
    //                     maps.RemoveAt(i);
    //                 break;
    //             case CampaignSeries::Blue:
    //                 if (seriesBlue.Find(mapNum) == -1)
    //                     maps.RemoveAt(i);
    //                 break;
    //             case CampaignSeries::Red:
    //                 if (seriesRed.Find(mapNum) == -1)
    //                     maps.RemoveAt(i);
    //                 break;
    //             case CampaignSeries::Black:
    //                 if (seriesBlack.Find(mapNum) == -1)
    //                     maps.RemoveAt(i);
    //                 break;
    //             default:;
    //         }
    //     }
    // }

    // const uint target = 4 - S_Target;

    // for (uint i = 0; i < maps.Length; i++) {
    //     Map@ map = maps[i];

    //     map.SetTargetDelta();

    //     if (S_Target == TargetMedal::None) {
    //         if (map.myTime > 0) {
    //             metTargetTotal++;
    //             continue;
    //         }
    //     } else if (map.myMedals >= target) {
    //         metTargetTotal++;
    //         continue;
    //     }

    //     const bool skipped = skippedUids.HasKey(map.uid);

    //     if (skipped) {
    //         mapsSkipped.InsertLast(map);

    //         if (!S_MenuExcludeSkips)
    //             mapsRemaining.InsertLast(map);
    //     } else
    //         mapsRemaining.InsertLast(map);

    //     if (bookmarkedUids.HasKey(map.uid))
    //         mapsBookmarked.InsertLast(map);

    //     if (nextMap is null && !skipped)
    //         @nextMap = map;
    // }

    // if (metTargetTotal == maps.Length)
    //     allTarget = true;
    // else {
    //     allTarget = false;

    //     if (nextMap !is null)
    //         trace("next map: " + nextMap.date + ": " + nextMap.nameClean);
    // }
// }
