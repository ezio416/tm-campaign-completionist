// c 2024-01-02
// m 2024-11-09

// enum CustomSource {
//     Club,
//     TMX
// }

// enum ExtraFilters {
//     Played   = 1,
//     Unplayed = 2
// }

enum MapOrder {
    Normal,
    Reverse,
    ClosestAbs,
    ClosestRel,
    Random
}

enum Mode {
    Seasonal,
    TrackOfTheDay,
    Campaign,
    Unknown
}

enum Season {  // update every season
    Summer_2020,
    Fall_2020,
    Winter_2021,
    Spring_2021,
    Summer_2021,
    Fall_2021,
    Winter_2022,
    Spring_2022,
    Summer_2022,
    Fall_2022,
    Winter_2023,
    Spring_2023,
    Summer_2023,
    Fall_2023,
    Winter_2024,
    Spring_2024,
    Summer_2024,
    Fall_2024,
    All,
    Unknown = 18
}

enum Series {
    White   = 1,
    Green   = 2,
    Blue    = 4,
    Red     = 8,
    Black   = 16,
    Unknown = 32
}

enum TargetMedal {
    None,
    Bronze,
    Silver,
    Gold,
    Author,
#if DEPENDENCY_WARRIORMEDALS
    Warrior,
#endif
}

[Setting hidden] bool           S_AutoSwitch             = true;
[Setting hidden] bool           S_ColoredMapNames        = false;
[Setting hidden] vec3           S_ColorDelta0001to0100   = vec3(0.0f,  1.0f,  1.0f);
[Setting hidden] vec3           S_ColorDelta0101to0250   = vec3(0.0f,  0.6f,  1.0f);
[Setting hidden] vec3           S_ColorDelta0251to0500   = vec3(0.3f,  0.0f,  1.0f);
[Setting hidden] vec3           S_ColorDelta0501to1000   = vec3(0.7f,  0.0f,  1.0f);
[Setting hidden] vec3           S_ColorDelta1001to2000   = vec3(1.0f,  0.0f,  0.8f);
[Setting hidden] vec3           S_ColorDelta2001to3000   = vec3(1.0f,  0.0f,  0.3f);
[Setting hidden] vec3           S_ColorDelta3001to5000   = vec3(1.0f,  0.3f,  0.0f);
[Setting hidden] vec3           S_ColorDelta5001Above    = vec3(1.0f,  0.6f,  0.0f);
[Setting hidden] vec3           S_ColorDeltaUnder        = vec3(0.0f,  1.0f,  0.0f);
[Setting hidden] vec3           S_ColorMedalAuthor       = vec3(0.17f, 0.75f, 0.0f);
[Setting hidden] vec3           S_ColorMedalBronze       = vec3(0.69f, 0.5f,  0.0f);
[Setting hidden] vec3           S_ColorMedalGold         = vec3(1.0f,  0.97f, 0.0f);
[Setting hidden] vec3           S_ColorMedalNone         = vec3(1.0f,  0.5f,  1.0f);
[Setting hidden] vec3           S_ColorMedalSilver       = vec3(0.75f, 0.75f, 0.75f);
[Setting hidden] vec3           S_ColorSeasonAll         = vec3(0.5f,  0.0f,  0.8f);
[Setting hidden] vec3           S_ColorSeasonFall        = vec3(1.0f,  0.5f,  0.0f);
[Setting hidden] vec3           S_ColorSeasonSpring      = vec3(0.3f,  0.9f,  0.3f);
[Setting hidden] vec3           S_ColorSeasonSummer      = vec3(1.0f,  0.8f,  0.0f);
[Setting hidden] vec3           S_ColorSeasonUnknown     = vec3(1.0f,  0.5f,  1.0f);
[Setting hidden] vec3           S_ColorSeasonWinter      = vec3(0.0f,  1.0f,  1.0f);
[Setting hidden] vec3           S_ColorSeriesAll         = vec3(0.5f,  0.0f,  0.8f);
[Setting hidden] vec3           S_ColorSeriesBlack       = vec3(0.4f,  0.4f,  0.4f);
[Setting hidden] vec3           S_ColorSeriesBlue        = vec3(0.24f, 0.39f, 1.0f);
[Setting hidden] vec3           S_ColorSeriesGreen       = vec3(0.43f, 0.98f, 0.63f);
[Setting hidden] vec3           S_ColorSeriesRed         = vec3(1.0f,  0.0f,  0.0f);
[Setting hidden] vec3           S_ColorSeriesUnknown     = vec3(1.0f,  0.5f,  1.0f);
[Setting hidden] vec3           S_ColorSeriesWhite       = vec3(1.0f,  1.0f,  1.0f);
// [Setting hidden] CustomSource   S_CustomSource           = CustomSource::Club;
// [Setting hidden] int            S_Filter                 = ExtraFilters::Played | ExtraFilters::Unplayed;
[Setting hidden] bool           S_NotifyStarter          = true;
[Setting hidden] bool           S_OnlyCurrentCampaign    = false;
[Setting hidden] MapOrder       S_Order                  = MapOrder::Normal;
[Setting hidden] Mode           S_Mode                   = Mode::Seasonal;
[Setting hidden] bool           S_SaveSettingsOnClose    = true;
[Setting hidden] int            S_Series                 = 31;  // white | ... | black
[Setting hidden] bool           S_ShowSettingsInDetached = false;
[Setting hidden] bool           S_ShowSettingsInMenu     = false;
[Setting hidden] TargetMedal    S_Target                 = TargetMedal::Author;
[Setting hidden] int            S_TimeLimit              = 0;
[Setting hidden] bool           S_WindowAutoResize       = false;
[Setting hidden] bool           S_WindowDetached         = false;
[Setting hidden] bool           S_WindowHideWithGame     = true;
[Setting hidden] bool           S_WindowHideWithOP       = true;

string       colorDelta0001to0100;
string       colorDelta0101to0250;
string       colorDelta0251to0500;
string       colorDelta0501to1000;
string       colorDelta1001to2000;
string       colorDelta2001to3000;
string       colorDelta3001to5000;
string       colorDelta5001Above;
string       colorDeltaUnder;
string       colorMedalAuthor;
string       colorMedalBronze;
string       colorMedalGold;
string       colorMedalNone;
string       colorMedalSilver;
string       colorSeasonAll;
string       colorSeasonFall;
string       colorSeasonSpring;
string       colorSeasonSummer;
string       colorSeasonUnknown;
string       colorSeasonWinter;
string       colorSeriesAll;
string       colorSeriesBlack;
string       colorSeriesBlue;
string       colorSeriesGreen;
string       colorSeriesRed;
string       colorSeriesUnknown;
string       colorSeriesWhite;
const string iconSeasonAll     = Icons::ListAlt;
const string iconSeasonFall    = Icons::Leaf;
const string iconSeasonSpring  = Icons::Tree;
const string iconSeasonSummer  = Icons::Sun;
const string iconSeasonUnknown = Icons::QuestionCircle;
const string iconSeasonWinter  = Icons::SnowflakeO;

bool   lastOnlyCurrentCampaign = S_OnlyCurrentCampaign;
bool[] settingsOpen            = { false, false, false };

[SettingsTab name="Campaign Completionist" icon="Check" order=0]
void SettingsTab_RenderWindow() {
    if (hasPlayPermission)
        Window(WindowSource::Settings);

    else
        UI::Text("sorry, you need club access :(");
}

void WindowSettings(WindowSource source = WindowSource::Unknown) {
    const bool save = S_SaveSettingsOnClose && source != WindowSource::Unknown;

    if (save && uint(source) >= settingsOpen.Length)
        return;

    if (!UI::CollapsingHeader(Icons::Cogs + " Settings")) {
        if (save && settingsOpen[int(source)]) {
            settingsOpen[int(source)] = false;
            Meta::SaveSettings();
        }

        return;
    }

    if (save) {
        HoverTooltip(Icons::Times + " Close to Save " + Icons::FloppyO);
        settingsOpen[int(source)] = true;
    }

    UI::Indent(indentWidth);

    SectionGeneral();
    SectionWindow();
    SectionColors();

    UI::Indent(-indentWidth);
}

void SectionColors() {
    if (!UI::CollapsingHeader(Icons::PaintBrush + " Colors"))
        return;

    UI::Indent(indentWidth);

    if (UI::Button("Reset to default##colors")) {
        pluginMeta.GetSetting("S_ColoredMapNames").Reset();

        Meta::SaveSettings();
    }

    S_ColoredMapNames = UI::Checkbox(
        "Show map names in color",
        S_ColoredMapNames
    );

    SectionColorsDeltas();
    SectionColorsMedals();
    SectionColorsSeasons();
    SectionColorsSeries();

    UI::Indent(-indentWidth);
}

void SectionColorsDeltas() {
    if (!UI::CollapsingHeader(Icons::ThermometerHalf + " Deltas"))
        return;

    UI::Indent(indentWidth);

    UI::TextWrapped("Deltas describe buckets of time your PB falls into based on the target time.");

    if (UI::Button("Reset to default##deltas")) {
        pluginMeta.GetSetting("S_ColorDeltaUnder").Reset();
        pluginMeta.GetSetting("S_ColorDelta0001to0100").Reset();
        pluginMeta.GetSetting("S_ColorDelta0101to0250").Reset();
        pluginMeta.GetSetting("S_ColorDelta0251to0500").Reset();
        pluginMeta.GetSetting("S_ColorDelta0501to1000").Reset();
        pluginMeta.GetSetting("S_ColorDelta1001to2000").Reset();
        pluginMeta.GetSetting("S_ColorDelta2001to3000").Reset();
        pluginMeta.GetSetting("S_ColorDelta3001to5000").Reset();
        pluginMeta.GetSetting("S_ColorDelta5001Above").Reset();

        Meta::SaveSettings();
    }

    if (S_ColorDeltaUnder != (S_ColorDeltaUnder = UI::InputColor3("Achieved", S_ColorDeltaUnder)))
        colorDeltaUnder = Text::FormatOpenplanetColor(S_ColorDeltaUnder);

    if (S_ColorDelta0001to0100 != (S_ColorDelta0001to0100 = UI::InputColor3("+0.001 - 0.100", S_ColorDelta0001to0100)))
        colorDelta0001to0100 = Text::FormatOpenplanetColor(S_ColorDelta0001to0100);

    if (S_ColorDelta0101to0250 != (S_ColorDelta0101to0250 = UI::InputColor3("+0.101 - 0.250", S_ColorDelta0101to0250)))
        colorDelta0101to0250 = Text::FormatOpenplanetColor(S_ColorDelta0101to0250);

    if (S_ColorDelta0251to0500 != (S_ColorDelta0251to0500 = UI::InputColor3("+0.251 - 0.500", S_ColorDelta0251to0500)))
        colorDelta0251to0500 = Text::FormatOpenplanetColor(S_ColorDelta0251to0500);

    if (S_ColorDelta0501to1000 != (S_ColorDelta0501to1000 = UI::InputColor3("+0.501 - 1.000", S_ColorDelta0501to1000)))
        colorDelta0501to1000 = Text::FormatOpenplanetColor(S_ColorDelta0501to1000);

    if (S_ColorDelta1001to2000 != (S_ColorDelta1001to2000 = UI::InputColor3("+1.001 - 2.000", S_ColorDelta1001to2000)))
        colorDelta1001to2000 = Text::FormatOpenplanetColor(S_ColorDelta1001to2000);

    if (S_ColorDelta2001to3000 != (S_ColorDelta2001to3000 = UI::InputColor3("+2.001 - 3.000", S_ColorDelta2001to3000)))
        colorDelta2001to3000 = Text::FormatOpenplanetColor(S_ColorDelta2001to3000);

    if (S_ColorDelta3001to5000 != (S_ColorDelta3001to5000 = UI::InputColor3("+3.001 - 5.000", S_ColorDelta3001to5000)))
        colorDelta3001to5000 = Text::FormatOpenplanetColor(S_ColorDelta3001to5000);

    if (S_ColorDelta5001Above != (S_ColorDelta5001Above = UI::InputColor3("Skill Issue", S_ColorDelta5001Above)))
        colorDelta5001Above = Text::FormatOpenplanetColor(S_ColorDelta5001Above);

    UI::Indent(-indentWidth);
}

void SectionColorsMedals() {
    if (!UI::CollapsingHeader(Icons::Circle + " Medals"))
        return;

    UI::Indent(indentWidth);

    if (UI::Button("Reset to default##medals")) {
        pluginMeta.GetSetting("S_ColorMedalAuthor").Reset();
        pluginMeta.GetSetting("S_ColorMedalBronze").Reset();
        pluginMeta.GetSetting("S_ColorMedalGold").Reset();
        pluginMeta.GetSetting("S_ColorMedalNone").Reset();
        pluginMeta.GetSetting("S_ColorMedalSilver").Reset();

        Meta::SaveSettings();
    }

    if (S_ColorMedalAuthor != (S_ColorMedalAuthor = UI::InputColor3("Author", S_ColorMedalAuthor)))
        colorMedalAuthor = Text::FormatOpenplanetColor(S_ColorMedalAuthor);

    if (S_ColorMedalGold != (S_ColorMedalGold = UI::InputColor3("Gold", S_ColorMedalGold)))
        colorMedalGold = Text::FormatOpenplanetColor(S_ColorMedalGold);

    if (S_ColorMedalSilver != (S_ColorMedalSilver = UI::InputColor3("Silver", S_ColorMedalSilver)))
        colorMedalSilver = Text::FormatOpenplanetColor(S_ColorMedalSilver);

    if (S_ColorMedalBronze != (S_ColorMedalBronze = UI::InputColor3("Bronze", S_ColorMedalBronze)))
        colorMedalBronze = Text::FormatOpenplanetColor(S_ColorMedalBronze);

    if (S_ColorMedalNone != (S_ColorMedalNone = UI::InputColor3("None", S_ColorMedalNone)))
        colorMedalNone = Text::FormatOpenplanetColor(S_ColorMedalNone);

    UI::Indent(-indentWidth);
}

void SectionColorsSeasons() {
    if (!UI::CollapsingHeader(Icons::SnowflakeO + " Seasons"))
        return;

    UI::Indent(indentWidth);

    if (UI::Button("Reset to default##seasons")) {
        pluginMeta.GetSetting("S_ColorSeasonAll").Reset();
        pluginMeta.GetSetting("S_ColorSeasonFall").Reset();
        pluginMeta.GetSetting("S_ColorSeasonSpring").Reset();
        pluginMeta.GetSetting("S_ColorSeasonSummer").Reset();
        pluginMeta.GetSetting("S_ColorSeasonUnknown").Reset();
        pluginMeta.GetSetting("S_ColorSeasonWinter").Reset();

        Meta::SaveSettings();
    }

    if (S_ColorSeasonWinter != (S_ColorSeasonWinter = UI::InputColor3("Winter / Jan-Mar", S_ColorSeasonWinter)))
        colorSeasonWinter = Text::FormatOpenplanetColor(S_ColorSeasonWinter);

    if (S_ColorSeasonSpring != (S_ColorSeasonSpring = UI::InputColor3("Spring / Apr-Jun", S_ColorSeasonSpring)))
        colorSeasonSpring = Text::FormatOpenplanetColor(S_ColorSeasonSpring);

    if (S_ColorSeasonSummer != (S_ColorSeasonSummer = UI::InputColor3("Summer / Jul-Sep", S_ColorSeasonSummer)))
        colorSeasonSummer = Text::FormatOpenplanetColor(S_ColorSeasonSummer);

    if (S_ColorSeasonFall != (S_ColorSeasonFall = UI::InputColor3("Fall / Oct-Dec", S_ColorSeasonFall)))
        colorSeasonFall = Text::FormatOpenplanetColor(S_ColorSeasonFall);

    if (S_ColorSeasonAll != (S_ColorSeasonAll = UI::InputColor3("All##seasons", S_ColorSeasonAll)))
        colorSeasonAll = Text::FormatOpenplanetColor(S_ColorSeasonAll);

    if (S_ColorSeasonUnknown != (S_ColorSeasonUnknown = UI::InputColor3("Unknown##seasons", S_ColorSeasonUnknown)))
        colorSeasonUnknown = Text::FormatOpenplanetColor(S_ColorSeasonUnknown);

    UI::Indent(-indentWidth);
}

void SectionColorsSeries() {
    if (!UI::CollapsingHeader(Icons::Columns + " Series"))
        return;

    UI::Indent(indentWidth);

    if (UI::Button("Reset to default##series")) {
        pluginMeta.GetSetting("S_ColorSeriesAll").Reset();
        pluginMeta.GetSetting("S_ColorSeriesBlack").Reset();
        pluginMeta.GetSetting("S_ColorSeriesBlue").Reset();
        pluginMeta.GetSetting("S_ColorSeriesGreen").Reset();
        pluginMeta.GetSetting("S_ColorSeriesRed").Reset();
        pluginMeta.GetSetting("S_ColorSeriesUnknown").Reset();
        pluginMeta.GetSetting("S_ColorSeriesWhite").Reset();

        Meta::SaveSettings();
    }

    if (S_ColorSeriesWhite != (S_ColorSeriesWhite = UI::InputColor3("White", S_ColorSeriesWhite)))
        colorSeriesWhite = Text::FormatOpenplanetColor(S_ColorSeriesWhite);

    if (S_ColorSeriesGreen != (S_ColorSeriesGreen = UI::InputColor3("Green", S_ColorSeriesGreen)))
        colorSeriesGreen = Text::FormatOpenplanetColor(S_ColorSeriesGreen);

    if (S_ColorSeriesBlue != (S_ColorSeriesBlue = UI::InputColor3("Blue", S_ColorSeriesBlue)))
        colorSeriesBlue = Text::FormatOpenplanetColor(S_ColorSeriesBlue);

    if (S_ColorSeriesRed != (S_ColorSeriesRed = UI::InputColor3("Red", S_ColorSeriesRed)))
        colorSeriesRed = Text::FormatOpenplanetColor(S_ColorSeriesRed);

    if (S_ColorSeriesBlack != (S_ColorSeriesBlack = UI::InputColor3("Black", S_ColorSeriesBlack)))
        colorSeriesBlack = Text::FormatOpenplanetColor(S_ColorSeriesBlack);

    if (S_ColorSeriesAll != (S_ColorSeriesAll = UI::InputColor3("All##series", S_ColorSeriesAll)))
        colorSeriesAll = Text::FormatOpenplanetColor(S_ColorSeriesAll);

    if (S_ColorSeriesUnknown != (S_ColorSeriesUnknown = UI::InputColor3("Unknown##series", S_ColorSeriesUnknown)))
        colorSeriesUnknown = Text::FormatOpenplanetColor(S_ColorSeriesUnknown);

    UI::Indent(-indentWidth);
}

void SectionGeneral() {
    if (!UI::CollapsingHeader(Icons::Sliders + " General"))
        return;

    UI::Indent(indentWidth);

    if (UI::Button("Reset to default##general")) {
        pluginMeta.GetSetting("S_NotifyStarter").Reset();
        pluginMeta.GetSetting("S_OnlyCurrentCampaign").Reset();
        pluginMeta.GetSetting("S_SaveSettingsOnClose").Reset();

        Meta::SaveSettings();
    }

    S_NotifyStarter = UI::Checkbox(
        "Notify when Starter Access is detected",
        S_NotifyStarter
    );

    UI::BeginDisabled(!hasPlayPermission);
    S_OnlyCurrentCampaign = UI::Checkbox(
        "Only show the current 25 seasonal campaign maps",
        S_OnlyCurrentCampaign
    );
    UI::EndDisabled();

    SectionSettings();

    UI::Indent(-indentWidth);
}

void SectionSettings() {
    if (!UI::CollapsingHeader(Icons::Cog + "\\$I\\$AAA Settings About Settings"))
        return;

    UI::Indent(indentWidth);

    // UI::Text("\\$I\\$AAAThis section holds settings about the settings themselves.");

    S_SaveSettingsOnClose = UI::Checkbox(
        "Save settings when the top 'Settings' menu is closed",
        S_SaveSettingsOnClose
    );

    S_ShowSettingsInDetached = UI::Checkbox(
        "Show settings in the detached window",
        S_ShowSettingsInDetached
    );

    S_ShowSettingsInMenu = UI::Checkbox(
        "Show settings in the menu panel",
        S_ShowSettingsInMenu
    );

    UI::Indent(-indentWidth);
}

void SectionWindow() {
    if (!UI::CollapsingHeader(Icons::WindowMaximize + " Window"))
        return;

    UI::Indent(indentWidth);

    if (UI::Button("Reset to default##window")) {
        // pluginMeta.GetSetting("S_WindowAutoResize").Reset();
        pluginMeta.GetSetting("S_WindowDetached").Reset();
        pluginMeta.GetSetting("S_WindowHideWithGame").Reset();
        pluginMeta.GetSetting("S_WindowHideWithOP").Reset();

        Meta::SaveSettings();
    }

    S_WindowDetached = UI::Checkbox(
        "Show a detached window",
        S_WindowDetached
    );

    if (S_WindowDetached) {
        UI::Indent(indentWidth);

        S_WindowHideWithGame = UI::Checkbox(
            "Show/hide with game UI",
            S_WindowHideWithGame
        );

        S_WindowHideWithOP = UI::Checkbox(
            "Show/hide with Openplanet UI",
            S_WindowHideWithOP
        );

        // S_WindowAutoResize = UI::Checkbox(
        //     "Auto-resize",
        //     S_WindowAutoResize
        // );

        UI::Indent(-indentWidth);
    }

    UI::Indent(-indentWidth);
}

void HoverTooltip(const string &in msg, bool allowDisabled = true) {
    if (!UI::IsItemHovered(allowDisabled ? UI::HoveredFlags::AllowWhenDisabled : UI::HoveredFlags::None))
        return;

    UI::BeginTooltip();
    UI::Text(msg);
    UI::EndTooltip();
}

void HoverTooltipSetting(const string &in msg, vec2 offset = vec2(), const string &in color = "666") {
    UI::SameLine();
    UI::SetCursorPos(UI::GetCursorPos() + offset);
    UI::Text("\\$" + color + Icons::QuestionCircle);
    if (!UI::IsItemHovered(UI::HoveredFlags::AllowWhenDisabled))
        return;

    UI::SetNextWindowSize(int(Math::Min(Draw::MeasureString(msg).x, 400.0f)), 0.0f);
    UI::BeginTooltip();
    UI::TextWrapped(msg);
    UI::EndTooltip();
}

// enum Mode {
//     NadeoCampaign,
//     TrackOfTheDay,
//     Unknown = 3
// }

// [Setting hidden]
// Mode S_Mode = Mode::NadeoCampaign;
// Mode lastMode = S_Mode;

// [Setting category="General" name="Season to show" description="Tracks of the Day are categorized into 3-month periods which may differ slightly from the time periods of Nadeo Campaigns. Does nothing for Starter Access"]
// Season S_Season = Season::All;
// Season lastSeason = S_Season;

// [Setting category="General" name="Show 'Season' menu" description="Does nothing for Starter Access"]
// bool S_MenuSeason = true;

// [Setting category="General" name="Campaign series to show"]
// CampaignSeries S_Series = CampaignSeries::All;
// CampaignSeries lastSeries = S_Series;

// const string[] seriesWhite = { "01", "02", "03", "04", "05" };
// const string[] seriesGreen = { "06", "07", "08", "09", "10" };
// const string[] seriesBlue  = { "11", "12", "13", "14", "15" };
// const string[] seriesRed   = { "16", "17", "18", "19", "20" };
// const string[] seriesBlack = { "21", "22", "23", "24", "25" };

// [Setting category="General" name="Show a list of remaining maps"]
// bool S_MenuAllMaps = true;

// [Setting category="General" name="Show hover text for clicking" description="Left-click to play, middle-click to skip, right-click to bookmark"]
// bool S_MenuClickHover = true;

// [Setting category="General" name="Exclude skipped maps from 'remaining maps'"]
// bool S_MenuExcludeSkips = true;
// bool lastMenuExcludeSkips = S_MenuExcludeSkips;

// [Setting category="General" name="Show a list of skipped maps"]
// bool S_MenuAllSkips = true;

// [Setting category="General" name="Show a list of bookmarked maps"]
// bool S_MenuAllBookmarks = true;

// [Setting category="General" name="Show time still needed for target"]
// bool S_MenuTargetDelta = false;

// enum NotifyAfterRun {
//     Never,
//     OnlyAfterPB,
//     Always
// }

// [Setting category="General" name="Notify of time still needed after a run"]
// NotifyAfterRun S_NotifyAfterRun = NotifyAfterRun::OnlyAfterPB;
