// c 2025-03-03
// m 2025-03-11

void RenderWindow() {
    UI::BeginDisabled(API::Nadeo::requesting);
    if (UI::Button("Get Maps"))
        startnew(GetMapsAsync);
    if (UI::Button("A:GetPBsAsync"))
        startnew(API::Nadeo::GetPBsAsync);
    UI::EndDisabled();

    if (UI::Button("M:GetPBsAsync"))
        startnew(Manager::GetPBsAsync);
}
