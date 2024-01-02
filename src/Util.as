// c 2024-01-02
// m 2024-01-02

// courtesy of "BetterTOTD" plugin - https://github.com/XertroV/tm-better-totd
void ReturnToMenu() {
    if (App.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed)
        App.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit);

    App.BackToMainMenu();

    while (!App.ManiaTitleControlScriptAPI.IsReady)
        yield();
}

string ZPad2(int num) {
    return num < 10 ? "0" + num : tostring(num);
}