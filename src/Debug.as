// c 2024-01-08
// m 2024-10-24

[SettingsTab name="Debug" icon="Bug" order=1]
void SettingsTab_Debug() {
    UI::Text("maps: " + maps.Length);
    UI::Text("mapsCampaign: " + mapsCampaign.Length);
    UI::Text("mapsTotd: " + mapsTotd.Length);

    UI::BeginTabBar("##tabbar-debug");

    Tab_DebugMaps();
    Tab_DebugMapsCampaign();
    Tab_DebugMapsTotd();

    UI::EndTabBar();
}

void Tab_DebugMaps() {
    if (!UI::BeginTabItem("maps"))
        return;

    ;

    UI::EndTabItem();
}

void Tab_DebugMapsCampaign() {
    if (!UI::BeginTabItem("mapsCampaign"))
        return;

    if (UI::BeginTable("##table-mapsCampaign", 4, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(0.0f), 0.5f));

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("uid");
        UI::TableSetupColumn("season");
        UI::TableSetupColumn("name");
        UI::TableSetupColumn("dl url");
        UI::TableHeadersRow();

        UI::ListClipper clipper(mapsCampaign.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                Map@ map = mapsCampaign[i];

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::Text(map.uid);

                UI::TableNextColumn();
                UI::Text(tostring(map.season));

                UI::TableNextColumn();
                UI::Text((map.name !is null ? map.name.stripped : ""));

                UI::TableNextColumn();
                UI::Text(map.downloadUrl);
            }
        }

        UI::PopStyleColor();
        UI::EndTable();
    }

    UI::EndTabItem();
}

void Tab_DebugMapsTotd() {
    if (!UI::BeginTabItem("mapsTotd"))
        return;

    if (UI::BeginTable("##table-mapsTotd", 2, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(0.0f), 0.5f));

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("uid");
        UI::TableSetupColumn("date");
        UI::TableHeadersRow();

        UI::ListClipper clipper(mapsTotd.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                Map@ map = mapsTotd[i];

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::Text(map.uid);

                UI::TableNextColumn();
                UI::Text(map.date);
            }
        }

        UI::PopStyleColor();
        UI::EndTable();
    }

    UI::EndTabItem();
}

// void RenderDebug() {
    // if (!S_Debug)
    //     return;

    // UI::Begin(title + " Debug", S_Debug, UI::WindowFlags::None);
    //     UI::BeginTabBar("##tabs");
    //         Tab_MapsDebug(mapsCampaign, Mode::NadeoCampaign);
    //         Tab_MapsDebug(mapsTotd,     Mode::TrackOfTheDay);
    //     UI::EndTabBar();
    // UI::End();
// }

// void Tab_MapsDebug(Map@[]@ mapsDebug, Mode mode) {
    // if (!UI::BeginTabItem(mode == Mode::NadeoCampaign ? "Campaign" : "TOTD"))
    //     return;

    // if (UI::BeginTable("##table", mode == Mode::NadeoCampaign ? 13 : 14, UI::TableFlags::ScrollY)) {
    //     UI::TableSetupScrollFreeze(0, 1);
    //     UI::TableSetupColumn("Skipped", UI::TableColumnFlags::WidthFixed, 75.0f);
    //     UI::TableSetupColumn("Bookmarked", UI::TableColumnFlags::WidthFixed, 120.0f);
    //     UI::TableSetupColumn("Season",     UI::TableColumnFlags::WidthFixed, 135.0f);
    //     if (mode == Mode::TrackOfTheDay)
    //         UI::TableSetupColumn("Date",   UI::TableColumnFlags::WidthFixed, 100.0f);
    //     UI::TableSetupColumn("Map",        UI::TableColumnFlags::WidthFixed, 200.0f);
    //     UI::TableSetupColumn("author",     UI::TableColumnFlags::WidthFixed, 80.0f);
    //     UI::TableSetupColumn("gold",       UI::TableColumnFlags::WidthFixed, 80.0f);
    //     UI::TableSetupColumn("silver",     UI::TableColumnFlags::WidthFixed, 80.0f);
    //     UI::TableSetupColumn("bronze",     UI::TableColumnFlags::WidthFixed, 80.0f);
    //     UI::TableSetupColumn("pb",         UI::TableColumnFlags::WidthFixed, 80.0f);
    //     UI::TableSetupColumn("medals",     UI::TableColumnFlags::WidthFixed, 80.0f);
    //     UI::TableSetupColumn("id",         UI::TableColumnFlags::WidthFixed, 400.0f);
    //     UI::TableSetupColumn("uid",        UI::TableColumnFlags::WidthFixed, 350.0f);
    //     UI::TableSetupColumn("downloadUrl");
    //     UI::TableHeadersRow();

    //     UI::ListClipper clipper(mapsDebug.Length);
    //     while (clipper.Step()) {
    //         for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
    //             Map@ map = mapsDebug[i];

    //             UI::TableNextRow();

    //             UI::TableNextColumn();
    //             if (skippedUids.HasKey(map.uid)) {
    //                 if (UI::Selectable("     " + Icons::Times + "##skipped" + map.uid, false))
    //                     RemoveSkip(map.uid);
    //             } else {
    //                 if (UI::Selectable("     " + Icons::CircleO + "##unskipped" + map.uid, false))
    //                     AddSkip(map.uid);
    //             }

    //             UI::TableNextColumn();
    //             if (bookmarkedUids.HasKey(map.uid)) {
    //                 if (UI::Selectable("         " + Icons::Bookmark + "##bookmarked" + map.uid, false))
    //                     RemoveBookmark(map.uid);
    //             } else {
    //                 if (UI::Selectable("         " + Icons::BookmarkO + "##unbookmarked" + map.uid, false))
    //                     AddBookmark(map.uid);
    //             }

    //             UI::TableNextColumn();
    //             UI::Text(tostring(map.season));

    //             if (mode == Mode::TrackOfTheDay) {
    //                 UI::TableNextColumn();
    //                 UI::Text(map.date);
    //             }

    //             UI::TableNextColumn();
    //             UI::Text(map.nameClean);

    //             UI::TableNextColumn();
    //             UI::Text(TimeFormatColored(map.authorTime));

    //             UI::TableNextColumn();
    //             UI::Text(TimeFormatColored(map.goldTime));

    //             UI::TableNextColumn();
    //             UI::Text(TimeFormatColored(map.silverTime));

    //             UI::TableNextColumn();
    //             UI::Text(TimeFormatColored(map.bronzeTime));

    //             UI::TableNextColumn();
    //             UI::Text(TimeFormatColored(map.myTime));

    //             UI::TableNextColumn();
    //             UI::Text(TimeFormatColored(map.myMedals, false));

    //             UI::TableNextColumn();
    //             if (UI::Selectable(map.id, false))
    //                 IO::SetClipboard(map.id);
    //             HoverTooltip("click to copy to clipboard");

    //             UI::TableNextColumn();
    //             if (UI::Selectable(map.uid, false))
    //                 IO::SetClipboard(map.uid);
    //             HoverTooltip("click to copy to clipboard");

    //             UI::TableNextColumn();
    //             if (UI::Selectable(map.downloadUrl, false))
    //                 IO::SetClipboard(map.downloadUrl);
    //             HoverTooltip("click to copy to clipboard");
    //         }
    //     }

    //     UI::EndTable();
    // }

    // UI::EndTabItem();
// }
