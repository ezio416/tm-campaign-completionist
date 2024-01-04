// c 2024-01-03
// m 2024-01-03

#if MP4

string colorCanyon;
string colorSelectedTitle;
string colorStadium;
string colorValley;
string colorLagoon;
bool hasCanyon = false;
bool hasStadium = false;
bool hasValley = false;
bool hasLagoon = false;
Map@[] mapsCanyon;
Map@[] mapsStadium;
Map@[] mapsValley;
Map@[] mapsLagoon;

void GetTitlepacks() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    for (uint i = 0; i < App.ManiaTitles.Length; i++) {
        CGameManiaTitle@ title = App.ManiaTitles[i];
        if (title is null)
            continue;

        if (title.TitleId == "TMCanyon@nadeo") {
            hasCanyon = true;
            continue;
        }

        if (title.TitleId == "TMStadium@nadeo") {
            hasStadium = true;
            continue;
        }

        if (title.TitleId == "TMValley@nadeo") {
            hasStadium = true;
            continue;
        }

        if (title.TitleId == "TMLagoon@nadeo") {
            hasLagoon = true;
            continue;
        }
    }
}

void GetMaps() {
    Json::Value@ titleMaps;
    switch (S_Mode) {
        case Mode::Canyon:  @titleMaps = CanyonMaps();  break;
        case Mode::Stadium: @titleMaps = StadiumMaps(); break;
        case Mode::Valley:  @titleMaps = ValleyMaps();  break;
        case Mode::Lagoon:  @titleMaps = LagoonMaps();  break;
        default:;
    }

    for (uint i = 0; i < title.Length; i++) {
        ;
    }

    GetRecords();
}

void GetRecords() {
    ;

    trace("getting records done");
}

void SetMP4Colors() {
    colorCanyon  = "\\" + Text::FormatGameColor(S_ColorCanyon);
    colorStadium = "\\" + Text::FormatGameColor(S_ColorStadium);
    colorValley  = "\\" + Text::FormatGameColor(S_ColorValley);
    colorLagoon  = "\\" + Text::FormatGameColor(S_ColorLagoon);

    switch(S_Mode) {
        case Mode::Canyon:  colorSelectedTitle = colorCanyon;  break;
        case Mode::Stadium: colorSelectedTitle = colorStadium; break;
        case Mode::Valley:  colorSelectedTitle = colorValley;  break;
        case Mode::Lagoon:  colorSelectedTitle = colorLagoon;  break;
        default:;
    }
}

Json::Value@ CanyonMaps() {
    return Json::Parse(
        ""
    );
}

Json::Value@ StadiumMaps() {
    return Json::Parse(
        ""
    );
}

Json::Value@ ValleyMaps() {
    return Json::Parse(
        ""
    );
}

Json::Value@ LagoonMaps() {
    return Json::Parse(
        ""
    );
}

#endif