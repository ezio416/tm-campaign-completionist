// c 2024-01-08
// m 2025-03-11

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

    int cols = 10;
#if DEPENDENCY_WARRIORMEDALS
    cols++;
#endif

    if (UI::BeginTabItem("Maps")) {
        if (UI::BeginTable("##table-maps", cols, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));
            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("uid",     UI::TableColumnFlags::WidthFixed, scale * 250.0f);
            UI::TableSetupColumn("name",    UI::TableColumnFlags::WidthFixed, scale * 200.0f);
            UI::TableSetupColumn("camp",    UI::TableColumnFlags::WidthFixed, scale * 120.0f);
#if DEPENDENCY_WARRIORMEDALS
            UI::TableSetupColumn("warrior", UI::TableColumnFlags::WidthFixed, scale * 70.0f);
#endif`
            UI::TableSetupColumn("author",  UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("gold",    UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("silver",  UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("bronze",  UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("pb",      UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("medals",  UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("play",    UI::TableColumnFlags::WidthFixed, scale * 30.0f);
            UI::TableHeadersRow();

            string[]@ uids = allMaps.GetKeys();
            UI::ListClipper clipper(uids.Length);
            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    Map@ map = GetMap(uids[i]);

                    UI::TableNextRow();

                    UI::TableNextColumn();
                    UI::AlignTextToFramePadding();
                    UI::Text(map.uid);

                    UI::TableNextColumn();
                    UI::Text(map.name !is null ? map.name.formatted : "???");

                    UI::TableNextColumn();
                    UI::Text(map.campaign.name);

#if DEPENDENCY_WARRIORMEDALS
                    UI::TableNextColumn();
                    UI::Text(Driven(map.timeWarrior) ? Time::Format(map.timeWarrior) : "");
#endif

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.timeAuthor));

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.timeGold));

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.timeSilver));

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.timeBronze));

                    UI::TableNextColumn();
                    UI::Text(map.pbFmt);

                    UI::TableNextColumn();
                    UI::Text(map.medals > -1 ? tostring(map.medals) : "");

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
