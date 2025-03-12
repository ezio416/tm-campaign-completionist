// c 2025-03-03
// m 2025-03-11

void RenderWindow() {
    UI::BeginDisabled(Http::Nadeo::requesting);
    if (UI::Button("Get Maps"))
        startnew(GetMapsAsync);
    if (UI::Button("A:GetPBsAsync"))
        startnew(Http::Nadeo::GetPBsAsync);
    UI::EndDisabled();

    if (UI::Button("M:GetPBsAsync"))
        startnew(Manager::GetPBsAsync);
}
