// c 2024-01-01
// m 2024-01-02

string accountId;
bool allTarget = false;
CTrackMania@ App;
string audienceCore = "NadeoServices";
string audienceLive = "NadeoLiveServices";
string currentUid;
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
            "\\$0F0" + Icons::Play + "\\$G Next: " + (
                !gettingDone ? "still getting data..." : nextMap !is null ? nextMap.date + ": " +
                    (S_ColorMapName ? nextMap.nameColored : nextMap.nameClean) +
                    (nextMap.uid == currentUid ? " (current)" : ""): "you're done!"
            ),
            "",
            false,
            gettingDone && !loadingMap && !allTarget && nextMap !is null && nextMap.uid != currentUid
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
        default:                  targetColor = "\\$F00";
    }
}

void Loop() {
    if (App.RootMap is null) {
        currentUid = "";
        return;
    }

    if (!S_Enabled || loadingMap)
        return;

    currentUid = App.RootMap.MapInfo.MapUid;

    if (
        !mapsByUid.Exists(currentUid) ||
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

    Map@ map = cast<Map@>(mapsByUid[currentUid]);
    map.myTime = ScoreMgr.Map_GetRecord_v2(userId, currentUid, "PersonalBest", "", "TimeAttack", "");
    map.myMedals = ScoreMgr.Map_GetMedal(userId, currentUid, "PersonalBest", "", "TimeAttack", "");

    SetNextMap();

    if (nextMap.uid != currentUid) {
        trace("target met, next map...");
        startnew(CoroutineFunc(nextMap.Play));
    } else
        sleep(10000);
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