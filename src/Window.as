// c 2025-03-03
// m 2025-03-03

void RenderWindow() {
    UI::BeginDisabled(API::Nadeo::requesting);
    if (UI::Button("Get Maps"))
        startnew(API::Nadeo::GetMapsAsync);
    UI::EndDisabled();
}
