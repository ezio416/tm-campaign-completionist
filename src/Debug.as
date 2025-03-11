// c 2024-01-08
// m 2025-03-10

[SettingsTab name="Debug" icon="Bug" order=1]
void RenderDebug() {
    UI::BeginTabBar("tabbar-debug");

    if (UI::BeginTabItem("Campaigns")) {
        if (UI::BeginTable("##table-campaigns", 5, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));
            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("name",   UI::TableColumnFlags::WidthFixed, 150.0f);
            UI::TableSetupColumn("type",   UI::TableColumnFlags::WidthFixed, 120.0f);
            UI::TableSetupColumn("season", UI::TableColumnFlags::WidthFixed, 120.0f);
            UI::TableSetupColumn("year",   UI::TableColumnFlags::WidthFixed, 100.0f);
            UI::TableSetupColumn("maps",   UI::TableColumnFlags::WidthFixed, 100.0f);
            UI::TableHeadersRow();

            UI::ListClipper clipper(campaigns.Length);
            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    Campaign@ campaign = campaigns[i];

                    UI::TableNextRow();

                    UI::TableNextColumn();
                    UI::Text(campaign.name.formatted);

                    UI::TableNextColumn();
                    UI::Text(tostring(campaign.type));

                    UI::TableNextColumn();
                    UI::Text(tostring(campaign.season));

                    UI::TableNextColumn();
                    UI::Text(tostring(campaign.year));

                    UI::TableNextColumn();
                    UI::Text(tostring(campaign.maps.GetSize()));
                }
            }

            UI::PopStyleColor();
            UI::EndTable();
        }

        UI::EndTabItem();
    }

    if (UI::BeginTabItem("Maps")) {
        if (UI::BeginTable("##table-maps", 8, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));
            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("uid",  UI::TableColumnFlags::WidthFixed, scale * 200.0f);
            UI::TableSetupColumn("name", UI::TableColumnFlags::WidthFixed, scale * 200.0f);
            UI::TableSetupColumn("camp", UI::TableColumnFlags::WidthFixed, scale * 200.0f);
            UI::TableSetupColumn("at",   UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("gt",   UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("st",   UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("bt",   UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("play", UI::TableColumnFlags::WidthFixed, scale * 30.0f);
            UI::TableHeadersRow();

            string[]@ uids = allMaps.GetKeys();
            UI::ListClipper clipper(uids.Length);
            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    Map@ map = cast<Map@>(allMaps[uids[i]]);

                    UI::TableNextRow();

                    UI::TableNextColumn();
                    UI::AlignTextToFramePadding();
                    UI::Text(map.uid);

                    UI::TableNextColumn();
                    UI::Text(map.name !is null ? map.name.formatted : "???");

                    UI::TableNextColumn();
                    UI::Text(map.campaign.name);

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.timeAuthor));

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.timeGold));

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.timeSilver));

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.timeBronze));

                    UI::TableNextColumn();
                    UI::BeginDisabled(map.loading);
                    if (UI::Button(Icons::Play + "##" + map.uid))
                        startnew(CoroutineFunc(map.PlayAsync));
                    UI::EndDisabled();
                }
            }

            UI::PopStyleColor();
            UI::EndTable();
        }

        UI::EndTabItem();
    }

    UI::EndTabBar();
}
