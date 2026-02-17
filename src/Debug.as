// c 2024-01-08
// m 2025-03-21

[SettingsTab name="Debug" icon="Bug" order=1]
void RenderDebug() {
    ;

    UI::Separator();

    if (UI::BeginTable("##table-debug-buttons", 2)) {
        UI::TableSetupColumn("name", UI::TableColumnFlags::WidthFixed, scale * 100.0f);

        UI::TableNextRow();

        UI::TableNextColumn();
        UI::AlignTextToFramePadding();
        UI::Text("Main");

        UI::TableNextColumn();
        UI::BeginDisabled(Http::Nadeo::requesting);
        if (UI::Button("GetMapsAsync"))
            startnew(GetMapsAsync);
        UI::EndDisabled();

        UI::SameLine();
        UI::BeginDisabled(
#if DEPENDENCY_WARRIORMEDALS
            false
#endif
        );
        if (UI::Button("GetWarriorsAsync"))
            startnew(GetWarriorsAsync);
        UI::EndDisabled();

        UI::TableNextRow();

        UI::TableNextColumn();
        UI::AlignTextToFramePadding();
        UI::Markdown("```\nHttp::Nadeo::\n```");

        UI::TableNextColumn();
        UI::BeginDisabled(Http::Nadeo::requesting);
        if (UI::Button("GetPBsAsync##hn"))
            startnew(Http::Nadeo::GetPBsAsync);
        UI::EndDisabled();

        UI::TableNextRow();

        UI::TableNextColumn();
        UI::AlignTextToFramePadding();
        UI::Markdown("```\nManager::\n```");

        UI::TableNextColumn();
        if (UI::Button("GetPBsAsync##m"))
            startnew(Manager::GetPBsAsync);

        UI::TableNextRow();

        UI::TableNextColumn();
        UI::AlignTextToFramePadding();
        UI::Markdown("```\nPB::\n```");

        UI::TableNextColumn();
        if (UI::Button("Load"))
            PB::Load();
        UI::SameLine();
        UI::BeginDisabled(!PB::loaded);
        if (UI::Button("SaveAll"))
            PB::SaveAll();
        UI::EndDisabled();

        UI::EndTable();
    }

    UI::Separator();

    UI::BeginTabBar("tabbar-debug");

    if (UI::BeginTabItem("Campaigns (" + campaigns.Length + ")###debug-tab-campaigns")) {
        if (UI::BeginTable("##table-campaigns", 5, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));
            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("name",   UI::TableColumnFlags::WidthFixed, scale * 120.0f);
            UI::TableSetupColumn("type",   UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("season", UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("year",   UI::TableColumnFlags::WidthFixed, scale * 50.0f);
            UI::TableSetupColumn("maps",   UI::TableColumnFlags::WidthFixed, scale * 50.0f);
            // UI::TableSetupColumn("play",   UI::TableColumnFlags::WidthFixed, scale * 30.0f);
            UI::TableHeadersRow();

            UI::ListClipper clipper(campaigns.Length);
            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    Campaign::Campaign@ campaign = campaigns[i];

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

                    // UI::TableNextColumn();
                    // if (UI::Button(Icons::Play + "##" + campaign.uid))
                    //     startnew(CoroutineFunc(campaign.PlayAsync));
                }
            }

            UI::PopStyleColor();
            UI::EndTable();
        }

        UI::EndTabItem();
    }

    int cols = 11;
#if DEPENDENCY_WARRIORMEDALS
        cols++;
#endif

    if (UI::BeginTabItem("Maps (" + allMaps.GetSize() + ")###debug-tab-maps")) {
        if (UI::BeginTable("##table-maps", cols, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));
            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("campaign", UI::TableColumnFlags::WidthFixed, scale * 120.0f);
            UI::TableSetupColumn("pos",      UI::TableColumnFlags::WidthFixed, scale * 30.0f);
            UI::TableSetupColumn("uid",      UI::TableColumnFlags::WidthFixed, scale * 250.0f);
            UI::TableSetupColumn("name",     UI::TableColumnFlags::WidthFixed, scale * 200.0f);
#if DEPENDENCY_WARRIORMEDALS
                UI::TableSetupColumn("warrior",  UI::TableColumnFlags::WidthFixed, scale * 70.0f);
#endif
            UI::TableSetupColumn("author",   UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("gold",     UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("silver",   UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("bronze",   UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("pb",       UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("play",     UI::TableColumnFlags::WidthFixed, scale * 30.0f);
            UI::TableSetupColumn("url",      UI::TableColumnFlags::WidthFixed, scale * 300.0f);
            UI::TableHeadersRow();

            string[]@ uids = allMaps.GetKeys();
            UI::ListClipper clipper(uids.Length);
            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    Map::Map@ map = Map::Get(uids[i]);

                    UI::TableNextRow();

                    UI::TableNextColumn();
                    UI::Text(map.campaign.name);

                    UI::TableNextColumn();
                    UI::Text(tostring(map.position));

                    UI::TableNextColumn();
                    UI::AlignTextToFramePadding();
                    UI::Text(map.uid);

                    UI::TableNextColumn();
                    UI::Text(map.name !is null ? (S_ColorMapNames ? map.name.formatted : map.name) : "???");

#if DEPENDENCY_WARRIORMEDALS
                        UI::TableNextColumn();
                        if (Driven(map.timeWarrior))
                            UI::Text(colorMedalWarrior + Time::Format(map.timeWarrior));
#endif

                    UI::TableNextColumn();
                    if (Driven(map.timeAuthor))
                        UI::Text(colorMedalAuthor + Time::Format(map.timeAuthor));

                    UI::TableNextColumn();
                    if (Driven(map.timeGold))
                        UI::Text(colorMedalGold + Time::Format(map.timeGold));

                    UI::TableNextColumn();
                    if (Driven(map.timeSilver))
                        UI::Text(colorMedalSilver + Time::Format(map.timeSilver));

                    UI::TableNextColumn();
                    if (Driven(map.timeBronze))
                        UI::Text(colorMedalBronze + Time::Format(map.timeBronze));

                    UI::TableNextColumn();
                    UI::Text(Color::Get(map.medals) + map.pbFmt);

                    UI::TableNextColumn();
                    UI::BeginDisabled(map.loading);
                    if (UI::Button(Icons::Play + "##" + map.uid))
                        startnew(CoroutineFunc(map.PlayAsync));
                    UI::EndDisabled();

                    UI::TableNextColumn();
                    UI::Text(map.url);
                }
            }

            UI::PopStyleColor();
            UI::EndTable();
        }

        UI::EndTabItem();
    }

    UI::EndTabBar();
}
