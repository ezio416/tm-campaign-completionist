// c 2024-01-08
// m 2024-01-15

void RenderDebug() {
    if (!S_Debug)
        return;

    UI::Begin(title + " Debug", S_Debug, UI::WindowFlags::None);
        UI::BeginTabBar("##tabs");
#if TMNEXT
            Tab_MapsDebug(mapsCampaign, Mode::NadeoCampaign);
            Tab_MapsDebug(mapsTotd,     Mode::TrackOfTheDay);
#elif MP4
            Tab_MapsDebug(maps);
#endif
        UI::EndTabBar();
    UI::End();
}

#if TMNEXT
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
                UI::Text(map.id);

                UI::TableNextColumn();
                UI::Text(map.uid);

                UI::TableNextColumn();
                UI::Text(map.downloadUrl);
            }
        }

        UI::EndTable();
    }

    UI::EndTabItem();
}

void MapsToJson(Mode mode) {
    trace("MapsToJson: " + tostring(mode) + " starting");

    if (mode == Mode::NadeoCampaign) {
        if (mapsCampaign.Length == 0) {
            warn("MapsToJson: no campaign maps!");
            return;
        }
    } else {
        if (mapsTotd.Length == 0) {
            warn("MapsToJson: no TOTD maps!");
            return;
        }
    }

    Json::Value@ mapsForJson = Json::Object();

    Map@[]@ mapsToSave = mode == Mode::NadeoCampaign ? mapsCampaign : mapsTotd;

    for (uint i = 0; i < mapsToSave.Length; i++) {
        Map@ map = mapsToSave[i];

        Json::Value@ mapJson = Json::Object();

        mapJson["authorTime"]  = map.authorTime;
        mapJson["bronzeTime"]  = map.bronzeTime;
        mapJson["downloadUrl"] = map.downloadUrl;
        mapJson["goldTime"]    = map.goldTime;
        mapJson["id"]          = map.id;
        mapJson["nameRaw"]     = map.nameRaw.Trim();
        mapJson["silverTime"]  = map.silverTime;
        mapJson["uid"]         = map.uid;

        if (mode == Mode::TrackOfTheDay)
            mapJson["date"]    = map.date;

        mapsForJson[ZPad4(i)] = mapJson;
    }

    Json::ToFile(IO::FromDataFolder("/Plugins/CampaignCompletionist/next_" + (mode == Mode::NadeoCampaign ? "campaign" : "totd") + "_raw.json"), mapsForJson);

    trace("MapsToJson: " + tostring(mode) + " done");
}

#elif MP4
    void Tab_MapsDebug(Map@[]@ mapsDebug) {
        ;
    }

#endif