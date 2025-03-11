// c 2024-01-01
// m 2025-03-10

dictionary@   allMaps           = dictionary();
Campaign@[]   campaigns;
bool          hasPlayPermission = false;
const string  pluginColor       = "\\$0F0";
const string  pluginIcon        = Icons::Check;
Meta::Plugin@ pluginMeta        = Meta::ExecutingPlugin();
const string  pluginTitle       = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
const float   scale             = UI::GetScale();

void Main() {
    if (Permissions::PlayLocalMap())
        hasPlayPermission = true;
    else {
        warn("Paid access required to play maps");

        if (S_NotifyStarter)
            UI::ShowNotification(
                pluginTitle,
                "Paid access is required to play maps, but you can still track your progress on the current Nadeo Campaign",
                vec4(1.0f, 0.1f, 0.1f, 0.8f)
            );
    }

    // GetInfosAsync();
}

void Render() {
    if (false
        || !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    if (UI::Begin(pluginTitle, S_Enabled, UI::WindowFlags::None))
        RenderWindow();
    UI::End();
}

void RenderMenu() {
    if (UI::MenuItem(pluginTitle, "", S_Enabled))
        S_Enabled = !S_Enabled;
}
