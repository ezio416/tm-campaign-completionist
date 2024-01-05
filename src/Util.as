// c 2024-01-02
// m 2024-01-04

void Notify() {
    switch (S_Target) {

#if TURBO

        case TargetMedal::SuperTrackmaster: NotifySuperTrackmaster(); break;
        case TargetMedal::SuperGold:        NotifySuperGold();        break;
        case TargetMedal::SuperSilver:      NotifySuperSilver();      break;
        case TargetMedal::SuperBronze:      NotifySuperBronze();      break;
        case TargetMedal::Trackmaster:      NotifyTrackmaster();      break;

#else

        case TargetMedal::Author: NotifyAuthor(); break;

#endif

        case TargetMedal::Gold:   NotifyGold();   break;
        case TargetMedal::Silver: NotifySilver(); break;
        case TargetMedal::Bronze: NotifyBronze(); break;
        default:                  NotifyNone();
    }
}

#if TURBO

void NotifySuperTrackmaster() {
    UI::ShowNotification(title, "Super Trackmaster achieved!", vec4(S_ColorMedalSuperTrackmaster.x, S_ColorMedalSuperTrackmaster.y, S_ColorMedalSuperTrackmaster.z, 0.8f));
}

void NotifySuperGold() {
    UI::ShowNotification(title, "Super Gold achieved!", vec4(S_ColorMedalSuperGold.x, S_ColorMedalSuperGold.y, S_ColorMedalSuperGold.z, 0.8f));
}

void NotifySuperSilver() {
    UI::ShowNotification(title, "Super Silver achieved!", vec4(S_ColorMedalSuperSilver.x, S_ColorMedalSuperSilver.y, S_ColorMedalSuperSilver.z, 0.8f));
}

void NotifySuperBronze() {
    UI::ShowNotification(title, "Super Bronze achieved!", vec4(S_ColorMedalSuperBronze.x, S_ColorMedalSuperBronze.y, S_ColorMedalSuperBronze.z, 0.8f));
}

void NotifyTrackmaster() {
    UI::ShowNotification(title, "Trackmaster achieved!", vec4(S_ColorMedalTrackmaster.x, S_ColorMedalTrackmaster.y, S_ColorMedalTrackmaster.z, 0.8f));
}

void NotifyGold() {
    UI::ShowNotification(title, "Gold achieved!", vec4(S_ColorMedalGold.x, S_ColorMedalGold.y, S_ColorMedalGold.z, 0.8f));
}

void NotifySilver() {
    UI::ShowNotification(title, "Silver achieved!", vec4(S_ColorMedalSilver.x, S_ColorMedalSilver.y, S_ColorMedalSilver.z, 0.8f));
}

void NotifyBronze() {
    UI::ShowNotification(title, "Bronze achieved!", vec4(S_ColorMedalBronze.x, S_ColorMedalBronze.y, S_ColorMedalBronze.z, 0.8f));
}

void NotifyNone() {
    UI::ShowNotification(title, "Map finished!", vec4(S_ColorMedalNone.x, S_ColorMedalNone.y, S_ColorMedalNone.z, 0.8f));
}

#else

void NotifyAuthor() {
    UI::ShowNotification(title, "Author achieved! Switching map...", vec4(S_ColorMedalAuthor.x, S_ColorMedalAuthor.y, S_ColorMedalAuthor.z, 0.8f));
}

void NotifyGold() {
    UI::ShowNotification(title, "Gold achieved! Switching map...", vec4(S_ColorMedalGold.x, S_ColorMedalGold.y, S_ColorMedalGold.z, 0.8f));
}

void NotifySilver() {
    UI::ShowNotification(title, "Silver achieved! Switching map...", vec4(S_ColorMedalSilver.x, S_ColorMedalSilver.y, S_ColorMedalSilver.z, 0.8f));
}

void NotifyBronze() {
    UI::ShowNotification(title, "Bronze achieved! Switching map...", vec4(S_ColorMedalBronze.x, S_ColorMedalBronze.y, S_ColorMedalBronze.z, 0.8f));
}

void NotifyNone() {
    UI::ShowNotification(title, "Map finished! Switching map...", vec4(S_ColorMedalNone.x, S_ColorMedalNone.y, S_ColorMedalNone.z, 0.8f));
}

#endif

void NotifyTrace(const string &in msg) {
    trace(msg);
    UI::ShowNotification(title, msg, vec4(0.4f, 0.4f, 0.4f, 0.8f));
}

void NotifyWarn(const string &in msg, bool log = true) {
    if (log)
        warn(msg);

    UI::ShowNotification(title, msg, vec4(0.9f, 0.6f, 0.0f, 0.8f));
}

string PosNegColor(bool b) {
    return b ? "\\$0F0true" : "\\$F00false";
}

string PosNegColor(uint u, bool format = true) {
    if (u > 0)
        return "\\$0F0" + (format ? Time::Format(u) : tostring(u));

    if (u < 0)
        return "\\$F00" + (format ? Time::Format(Math::Abs(u)) : tostring(Math::Abs(u)));

    return "\\$G0";
}

#if TMNEXT || MP4

// courtesy of "BetterTOTD" plugin - https://github.com/XertroV/tm-better-totd
void ReturnToMenu() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed)
        App.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit);

    App.BackToMainMenu();

    while (!App.ManiaTitleControlScriptAPI.IsReady)
        yield();
}

#endif

string ZPad2(int num) {
    return (num < 10 ? "0" : "") + num;
}

string ZPad3(int num) {
    return (num < 10 ? "00" : num < 100 ? "0" : "") + num;
}