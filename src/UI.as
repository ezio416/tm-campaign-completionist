// c 2024-11-29
// m 2024-11-29

namespace UIExt {
    void HoverTooltip(const string &in msg, bool allowDisabled = true) {
        if (!UI::IsItemHovered(allowDisabled ? UI::HoveredFlags::AllowWhenDisabled : UI::HoveredFlags::None))
            return;

        UI::BeginTooltip();
        UI::Text(msg);
        UI::EndTooltip();
    }
}
