// c 2024-01-02
// m 2024-01-07

void Notify() {
    switch (S_Target) {
        case TargetMedal::Author: NotifyAuthor(); break;
        case TargetMedal::Gold:   NotifyGold(); break;
        case TargetMedal::Silver: NotifySilver(); break;
        case TargetMedal::Bronze: NotifyBronze(); break;
        default:                  NotifyNone();
    }
}

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

// courtesy of "BetterTOTD" plugin - https://github.com/XertroV/tm-better-totd
void ReturnToMenu() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed)
        App.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit);

    App.BackToMainMenu();

    while (!App.ManiaTitleControlScriptAPI.IsReady)
        yield();
}

string ZPad2(int num) {
    return (num < 10 ? "0" : "") + num;
}

string ZPad4(int num) {
    return (num < 10 ? "000" : num < 100 ? "00" : num < 1000 ? "0" : "") + num;
}