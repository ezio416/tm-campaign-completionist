// c 2024-01-02
// m 2025-03-11

bool Driven(uint time) {
    return time != uint(-1) && time != 0;
}

void HoverTooltip(const string &in msg) {
    if (!UI::IsItemHovered(UI::HoveredFlags::AllowWhenDisabled))
        return;

    UI::BeginTooltip();
    UI::Text(msg);
    UI::EndTooltip();
}

string PluginName() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.SystemConfig.DesiredLanguageId == "**" || App.SystemConfig.DesiredLanguageId == "en-US")
        return pluginMeta.Name;

    if (App.SystemConfig.DesiredLanguageId == "cs-CZ")
        return "Doplňovačka Kampaně";
    if (App.SystemConfig.DesiredLanguageId == "de-DE")
        return "Kampagnen-Komplettist";
    if (App.SystemConfig.DesiredLanguageId == "es-ES")
        return "Completista de Campaña";
    if (App.SystemConfig.DesiredLanguageId == "fr-FR")
        return "Complétionniste de Campagne";
    if (App.SystemConfig.DesiredLanguageId == "it-IT")
        return "Completista della Campagna";
    // if (App.SystemConfig.DesiredLanguageId == "ja-JP")
    //     return "キャンペーン完了者";
    // if (App.SystemConfig.DesiredLanguageId == "ko-KR")
    //     return "캠페인 완성자";
    if (App.SystemConfig.DesiredLanguageId == "nl-NL")
        return "Campagne-Completist";
    if (App.SystemConfig.DesiredLanguageId == "pl-PL")
        return "Ukończenie Kampanii";
    if (App.SystemConfig.DesiredLanguageId == "pt-BR")
        return "Campanha Completista";
    if (App.SystemConfig.DesiredLanguageId == "ru-RU")
        return "Завершитель Кампании";
    if (App.SystemConfig.DesiredLanguageId == "tr-TR")
        return "Kampanya Tamamlayıcısı";
    // if (App.SystemConfig.DesiredLanguageId == "zh-CN")
    //     return "";
    // if (App.SystemConfig.DesiredLanguageId == "zh-TW")
    //     return "";

    return pluginMeta.Name;
}

string PluginTitle() {
    return pluginColor + pluginIcon + "\\$G " + PluginName();
}

void ReturnToMenuAsync() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed)
        App.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(
            CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit
        );

    App.BackToMainMenu();

    while (!App.ManiaTitleControlScriptAPI.IsReady)
        yield();
}
