// c 2024-01-04
// m 2024-01-04

#if MP4

void Render() {
    if (!S_Debug)
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    UI::Begin(title + " debug", S_Debug);
        if (UI::Button("back to main menu"))
            startnew(ReturnToMenu);

        UI::BeginDisabled(loadingTitlepack);
        UI::SameLine();
        if (UI::Button("back to title select"))
            startnew(ReturnToTitleSelect);
        UI::EndDisabled();

        if (UI::BeginCombo("titlepack", tostring(S_Titlepack))) {
            for (int i = -1; i < 4; i++) {
                Titlepack selected = Titlepack(i);
                if (UI::Selectable(tostring(selected), S_Titlepack == selected))
                    S_Titlepack = selected;
            }
            UI::EndCombo();
        }

        UI::BeginDisabled(
            loadingTitlepack ||
            S_Titlepack == Titlepack::None ||
            (atTitleSelect && App.LoadedManiaTitle !is null && loadedTitleName == tostring(S_Titlepack))
        );
        UI::SameLine();
        if (UI::Button("Load"))
            startnew(LoadTitlepack);
        UI::EndDisabled();

        if (UI::BeginTable("##table", 6)) {
            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("map", UI::TableColumnFlags::WidthFixed, 120.0f);
            UI::TableSetupColumn("PB", UI::TableColumnFlags::WidthFixed, 100.0f);
            UI::TableSetupColumn("authorTime", UI::TableColumnFlags::WidthFixed, 110.0f);
            UI::TableSetupColumn("medals", UI::TableColumnFlags::WidthFixed, 70.0f);
            UI::TableSetupColumn("mxid", UI::TableColumnFlags::WidthFixed, 60.0f);
            UI::TableSetupColumn("uid");
            UI::TableHeadersRow();

            for (uint i = 0; i < maps.Length; i++) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text(maps[i].nameClean);

                UI::TableNextColumn();
                UI::Text(PosNegColor(maps[i].myTime));

                UI::TableNextColumn();
                UI::Text(PosNegColor(maps[i].authorTime));

                UI::TableNextColumn();
                UI::Text(PosNegColor(maps[i].myMedals, false));

                UI::TableNextColumn();
                UI::Text(PosNegColor(maps[i].mxid, false));

                UI::TableNextColumn();
                UI::Text(maps[i].uid);
            }

            UI::EndTable();
        }
    UI::End();
}

#elif TURBO

void Render() {
    if (!S_Debug)
        return;

    UI::Begin(title + " debug", S_Debug);
        if (UI::Button("ReturnToMenu"))
            startnew(ReturnToMenu);

        if (UI::BeginTable("##table", 6)) {
            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("map", UI::TableColumnFlags::WidthFixed, 120.0f);
            UI::TableSetupColumn("PB", UI::TableColumnFlags::WidthFixed, 100.0f);
            UI::TableSetupColumn("stmTime", UI::TableColumnFlags::WidthFixed, 110.0f);
            UI::TableSetupColumn("medals", UI::TableColumnFlags::WidthFixed, 70.0f);
            UI::TableSetupColumn("uid");
            UI::TableHeadersRow();

            for (uint i = 0; i < maps.Length; i++) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text(maps[i].nameClean);

                UI::TableNextColumn();
                UI::Text(PosNegColor(maps[i].myTime));

                UI::TableNextColumn();
                UI::Text(PosNegColor(maps[i].superTrackmasterTime));

                UI::TableNextColumn();
                UI::Text(PosNegColor(maps[i].myMedals, false));

                UI::TableNextColumn();
                UI::Text(maps[i].uid);
            }

            UI::EndTable();
        }
    UI::End();
}

#endif