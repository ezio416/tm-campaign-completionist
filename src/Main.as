// c 2024-01-01
// m 2024-01-02

string accountId;
bool allTarget = false;
CTrackMania@ App;
string audienceCore = "NadeoServices";
string audienceLive = "NadeoLiveServices";
bool gettingDone = false;
Map@[] maps;
dictionary mapsById;
dictionary mapsByUid;
uint metTargetTotal = 0;
Map@ nextMap;
string targetColor;
string title = "\\$F82" + Icons::CalendarO + "\\$G TOTD Completionist";

void RenderMenu() {
    if (UI::BeginMenu(title)) {
        UI::MenuItem(targetColor + Icons::Circle + " Target Medal: " + tostring(S_Target), "", false, false);
        UI::MenuItem(Icons::Percent + " Progress: " + (!gettingDone ? "..." : metTargetTotal + "/" + maps.Length + " (" + (int(100 * metTargetTotal / maps.Length)) +"%)"), "", false, false);

        if (UI::MenuItem(
            Icons::Play + " Next: " + (!gettingDone ? "still getting data..." : nextMap !is null ? nextMap.date + ": " + nextMap.nameClean : "you're done!"),
            "",
            false,
            gettingDone && nextMap !is null && !loadingMap && !allTarget
        ))
            startnew(CoroutineFunc(nextMap.Play));

        UI::EndMenu();
    }
}

void Main() {
    if (!Permissions::PlayLocalMap()) {
        warn("plugin requires paid access to play maps");
        return;
    }

    OnSettingsChanged();

    @App = cast<CTrackMania@>(GetApp());

    accountId = App.LocalPlayerInfo.WebServicesUserId;

    NadeoServices::AddAudience(audienceCore);
    NadeoServices::AddAudience(audienceLive);

    GetMaps();

    while (true) {
        Loop();
        yield();
    }
}

void OnSettingsChanged() {
    SetNextMap();

    switch (S_Target) {
        case TargetMedal::Author: targetColor = "\\$2B0"; break;
        case TargetMedal::Gold:   targetColor = "\\$FE0"; break;
        case TargetMedal::Silver: targetColor = "";       break;
        case TargetMedal::Bronze: targetColor = "\\$A70"; break;
        default:                  targetColor = "\\$F11";
    }
}

void Loop() {
    if (!S_Enabled || loadingMap || App.RootMap is null)
        return;

    string thisUid = App.RootMap.MapInfo.MapUid;

    if (
        !mapsByUid.Exists(thisUid) ||
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

    Map@ map = cast<Map@>(mapsByUid[thisUid]);
    map.myTime = ScoreMgr.Map_GetRecord_v2(userId, thisUid, "PersonalBest", "", "TimeAttack", "");
    map.myMedals = ScoreMgr.Map_GetMedal(userId, thisUid, "PersonalBest", "", "TimeAttack", "");

    SetNextMap();

    if (nextMap.uid != thisUid) {
        trace("target met, next map...");
        startnew(CoroutineFunc(nextMap.Play));
    }
}

void SetNextMap() {
    if (!gettingDone)
        return;

    trace("setting next map");

    metTargetTotal = 0;
    @nextMap = null;
    uint target = 4 - S_Target;

    for (uint i = 0; i < maps.Length; i++) {
        if (S_Target == TargetMedal::JustFinish) {
            if (maps[i].myTime > 0) {
                metTargetTotal++;
                continue;
            }
        } else if (maps[i].myMedals >= target) {
            metTargetTotal++;
            continue;
        }

        if (nextMap is null)
            @nextMap = maps[i];
    }

    if (metTargetTotal == maps.Length) {
        allTarget = true;
        trace("congrats, you've met your target on all maps!");
    } else if (nextMap !is null)
        trace("next map: " + nextMap.date + ": " + nextMap.nameClean);
}