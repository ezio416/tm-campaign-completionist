// c 2024-01-08
// m 2024-01-16

void RenderDebug() {
    if (!S_Debug)
        return;

    UI::Begin(title + " Debug", S_Debug, UI::WindowFlags::None);
        UI::BeginTabBar("##tabs");
            Tab_MapsDebug(mapsCampaign, Mode::NadeoCampaign);
            Tab_MapsDebug(mapsTotd,     Mode::TrackOfTheDay);
        UI::EndTabBar();
    UI::End();
}

void Tab_MapsDebug(Map@[]@ mapsDebug, Mode mode) {
    if (!UI::BeginTabItem(mode == Mode::NadeoCampaign ? "Campaign" : "TOTD"))
        return;

    if (UI::BeginTable("##table", mode == Mode::NadeoCampaign ? 10 : 11, UI::TableFlags::ScrollY)) {
        UI::TableSetupScrollFreeze(0, 1);
        if (mode == Mode::TrackOfTheDay)
            UI::TableSetupColumn("Date", UI::TableColumnFlags::WidthFixed, 100.0f);
        UI::TableSetupColumn("Map",    UI::TableColumnFlags::WidthFixed, 200.0f);
        UI::TableSetupColumn("author", UI::TableColumnFlags::WidthFixed, 80.0f);
        UI::TableSetupColumn("gold",   UI::TableColumnFlags::WidthFixed, 80.0f);
        UI::TableSetupColumn("silver", UI::TableColumnFlags::WidthFixed, 80.0f);
        UI::TableSetupColumn("bronze", UI::TableColumnFlags::WidthFixed, 80.0f);
        UI::TableSetupColumn("pb",     UI::TableColumnFlags::WidthFixed, 80.0f);
        UI::TableSetupColumn("medals", UI::TableColumnFlags::WidthFixed, 80.0f);
        UI::TableSetupColumn("id",     UI::TableColumnFlags::WidthFixed, 400.0f);
        UI::TableSetupColumn("uid",    UI::TableColumnFlags::WidthFixed, 350.0f);
        UI::TableSetupColumn("downloadUrl");
        UI::TableHeadersRow();

        UI::ListClipper clipper(mapsDebug.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                Map@ map = mapsDebug[i];

                UI::TableNextRow();

                if (mode == Mode::TrackOfTheDay) {
                    UI::TableNextColumn();
                    UI::Text(map.date);
                }

                UI::TableNextColumn();
                UI::Text(map.nameClean);

                UI::TableNextColumn();
                UI::Text(TimeFormatColored(map.authorTime));

                UI::TableNextColumn();
                UI::Text(TimeFormatColored(map.goldTime));

                UI::TableNextColumn();
                UI::Text(TimeFormatColored(map.silverTime));

                UI::TableNextColumn();
                UI::Text(TimeFormatColored(map.bronzeTime));

                UI::TableNextColumn();
                UI::Text(TimeFormatColored(map.myTime));

                UI::TableNextColumn();
                UI::Text(TimeFormatColored(map.myMedals, false));

                UI::TableNextColumn();
                if (UI::Selectable(map.id, false))
                    IO::SetClipboard(map.id);
                HoverTooltip("click to copy to clipboard");

                UI::TableNextColumn();
                if (UI::Selectable(map.uid, false))
                    IO::SetClipboard(map.uid);
                HoverTooltip("click to copy to clipboard");

                UI::TableNextColumn();
                if (UI::Selectable(map.downloadUrl, false))
                    IO::SetClipboard(map.downloadUrl);
                HoverTooltip("click to copy to clipboard");
            }
        }

        UI::EndTable();
    }

    UI::EndTabItem();
}