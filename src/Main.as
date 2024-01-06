// c 2024-01-01
// m 2024-01-04

string accountId;
bool allTarget = false;
string audienceCore = "NadeoServices";
string audienceLive = "NadeoLiveServices";
string colorMedalAuthor;
string colorMedalBronze;
string colorMedalGold;
string colorMedalNone;
string colorMedalSilver;
string colorTarget;
string currentUid;
bool gettingNow = false;
Mode lastMode = S_Mode;
Map@[] maps;
dictionary mapsByUid;
Map@[] mapsCampaign;
dictionary mapsCampaignById;
dictionary mapsCampaignByUid;
Map@[] mapsRemaining;
Map@[] mapsTotd;
dictionary mapsTotdById;
dictionary mapsTotdByUid;
uint metTargetTotal = 0;
Map@ nextMap;
bool playPermission = false;
uint progressCount = 0;
uint progressPercent = 0;
string title = "\\$0F0" + Icons::Check + "\\$G Campaign Completionist";

void Main() {
    if (!Permissions::PlayLocalMap()) {
        warn("plugin requires paid access to play maps");
        UI::ShowNotification(title, "Paid access (at least standard) is required to play maps", vec4(1.0f, 0.1f, 0.1f, 0.8f));
        return;
    }

    playPermission = true;

    OnSettingsChanged();

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    accountId = App.LocalPlayerInfo.WebServicesUserId;

    NadeoServices::AddAudience(audienceCore);
    NadeoServices::AddAudience(audienceLive);

    GetMaps();

    while (true) {
        Loop();
        yield();
    }
}

void RenderMenu() {
    if (UI::BeginMenu(title)) {
        if (UI::MenuItem(Icons::Question + " Auto Switch Maps", "", S_Enabled))
            S_Enabled = !S_Enabled;

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

        if (UI::BeginMenu(colorTarget + Icons::Circle + " Target Medal: " + tostring(S_Target))) {
            if (UI::MenuItem(colorMedalAuthor + Icons::Circle + " Author", "")) {
                S_Target = TargetMedal::Author;
                OnSettingsChanged();
                startnew(SetNextMap);
            }
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
            Icons::Percent + " Progress: " + (gettingNow ? "..." : metTargetTotal + "/" + maps.Length + " (" + (int(100 * metTargetTotal / maps.Length)) +"%)"),
            "",
            false,
            false
        );

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

        string nextText = "\\$0F0" + Icons::Play + "\\$G Next: ";
        if (gettingNow)
            nextText += "still getting data... (" + progressPercent + "%)";
        else if (nextMap !is null) {
            nextText += S_Mode == Mode::NadeoCampaign ? "" : nextMap.date + ": ";
            nextText += S_ColorMapName ? nextMap.nameColored : nextMap.nameClean;
            nextText += nextMap.uid == currentUid ? " (current)" : "";
        } else
            nextText += "you're done!";

        if (UI::MenuItem(nextText, "", false, playPermission && !gettingNow && !loadingMap && !allTarget && nextMap !is null && nextMap.uid != currentUid))
            startnew(CoroutineFunc(nextMap.Play));

        if (S_AllMapsInMenu) {
            if (UI::BeginMenu(Icons::List + " Remaining Maps (" + mapsRemaining.Length + ")", !gettingNow)) {
                for (uint i = 0; i < mapsRemaining.Length; i++) {
                    Map@ map = mapsRemaining[i];

                    if (UI::MenuItem(S_Mode == Mode::NadeoCampaign ? map.nameRaw : map.date + ": " + (S_ColorMapName ? map.nameColored : map.nameClean), ""))
                        startnew(CoroutineFunc(map.Play));
                }

                UI::EndMenu();
            }
        }

        UI::EndMenu();
    }
}

void OnSettingsChanged() {
    if (lastMode != S_Mode) {
        lastMode = S_Mode;
        startnew(GetMaps);
    }

    colorMedalAuthor = "\\" + Text::FormatGameColor(S_ColorMedalAuthor);
    colorMedalGold   = "\\" + Text::FormatGameColor(S_ColorMedalGold);
    colorMedalSilver = "\\" + Text::FormatGameColor(S_ColorMedalSilver);
    colorMedalBronze = "\\" + Text::FormatGameColor(S_ColorMedalBronze);
    colorMedalNone   = "\\" + Text::FormatGameColor(S_ColorMedalNone);

    switch (S_Target) {
        case TargetMedal::Author: colorTarget = colorMedalAuthor; break;
        case TargetMedal::Gold:   colorTarget = colorMedalGold;   break;
        case TargetMedal::Silver: colorTarget = colorMedalSilver; break;
        case TargetMedal::Bronze: colorTarget = colorMedalBronze; break;
        default:                  colorTarget = colorMedalNone;
    }
}

void Loop() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.RootMap is null || App.RootMap.MapInfo is null) {
        currentUid = "";
        return;
    }

    if (!S_Enabled || loadingMap)
        return;

    currentUid = App.RootMap.MapInfo.MapUid;

    if (
        nextMap is null ||
        nextMap.uid != currentUid ||
        App.Network is null ||
        App.Network.ClientManiaAppPlayground is null ||
        App.Network.ClientManiaAppPlayground.UI is null ||
        App.Network.ClientManiaAppPlayground.UI.UISequence != CGamePlaygroundUIConfig::EUISequence::Finish
    )
        return;

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

    uint prevTime = nextMap.myTime;

    nextMap.myTime = ScoreMgr.Map_GetRecord_v2(userId, currentUid, "PersonalBest", "", "TimeAttack", "");
    nextMap.myMedals = ScoreMgr.Map_GetMedal(userId, currentUid, "PersonalBest", "", "TimeAttack", "");

    Meta::PluginCoroutine@ coro = startnew(SetNextMap);
    while (coro.IsRunning())
        yield();

    if (nextMap.uid != currentUid) {
        Notify();
        startnew(CoroutineFunc(nextMap.Play));
        sleep(10000);
    } else {
        bool pb = prevTime == 0 || nextMap.myTime < prevTime;

        print(nextMap.myTime + " ; " + prevTime);
        print("pb: " + pb);

        if (S_NotifyEveryRun || (S_NotifyAfterPB && pb))
            NotifyDifference(pb);
    }
}

void SetNextMap() {
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

        mapsRemaining.InsertLast(maps[i]);

        if (nextMap is null)
            @nextMap = maps[i];
    }

    if (metTargetTotal == maps.Length) {
        allTarget = true;
        trace("congrats, you've met your target on all maps!");
    } else {
        allTarget = false;
        if (nextMap !is null)
            trace("next map: " + nextMap.date + ": " + nextMap.nameClean);
    }
}