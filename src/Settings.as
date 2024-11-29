// c 2024-01-02
// m 2024-11-29

[Setting hidden] bool        S_AutoSwitch             = true;
[Setting hidden] bool        S_ColoredMapNames        = false;
[Setting hidden] bool        S_NotifyStarter          = true;
[Setting hidden] MapOrder    S_Order                  = MapOrder::Normal;
[Setting hidden] Mode        S_Mode                   = Mode::Seasonal;
[Setting hidden] bool        S_SaveSettingsOnClose    = true;
[Setting hidden] int         S_Series                 = 31;  // white | ... | black
[Setting hidden] bool        S_ShowSettingsInDetached = false;
[Setting hidden] bool        S_ShowSettingsInMenu     = false;
[Setting hidden] TargetMedal S_Target                 = TargetMedal::Author;
[Setting hidden] int         S_TimeLimit              = 0;
[Setting hidden] bool        S_WindowAutoResize       = false;
[Setting hidden] bool        S_WindowDetached         = false;
[Setting hidden] bool        S_WindowHideWithGame     = true;
[Setting hidden] bool        S_WindowHideWithOP       = true;

[SettingsTab name="Campaign Completionist" icon="Check" order=0]
void SettingsTab_RenderWindow() {
    if (!hasPlayPermission) {
        UI::Text(Icons::FrownO + " Sorry, you need Club Access " + Icons::FrownO);
        return;
    }

    Window(WindowSource::Settings);
}

namespace Settings {
    bool[] open = { false, false, false };

    void Render(WindowSource source = WindowSource::Unknown) {
        const int  s    = int(source);
        const bool save = S_SaveSettingsOnClose && source != WindowSource::Unknown;

        if (save && s >= int(Settings::open.Length))
            return;

        if (!UI::CollapsingHeader(Icons::Cogs + " Settings")) {
            if (save && Settings::open[s]) {
                Settings::open[s] = false;
                Meta::SaveSettings();
            }

            return;
        }

        if (save) {
            UIExt::HoverTooltip(Icons::Times + " Close to Save " + Icons::FloppyO);
            Settings::open[s] = true;
        }

        UI::Indent(indentWidth);

        Settings::General::Render();
        Settings::Window::Render();
        Settings::Colors::Render();

        UI::Indent(-indentWidth);
    }

    namespace Colors {
        void Render() {
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

            Deltas::Render();
            Medals::Render();
            Modes::Render();
            Seasons::Render();
            Series::Render();

            UI::Indent(-indentWidth);
        }

        namespace Deltas {
            void Render() {
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
        }

        namespace Medals {
            void Render() {
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
        }

        namespace Modes {
            void Render() {
                if (!UI::CollapsingHeader(Icons::Gamepad + " Modes"))
                    return;

                UI::Indent(indentWidth);

                if (UI::Button("Reset to default##modes")) {
                    pluginMeta.GetSetting("S_ColorModeClub").Reset();
                    pluginMeta.GetSetting("S_ColorModeCustom").Reset();
                    pluginMeta.GetSetting("S_ColorModeSeasonal").Reset();
                    pluginMeta.GetSetting("S_ColorModeTmx").Reset();
                    pluginMeta.GetSetting("S_ColorModeTotd").Reset();

                    Meta::SaveSettings();
                }

                if (S_ColorModeSeasonal != (S_ColorModeSeasonal = UI::InputColor3("Seasonal campaign", S_ColorModeSeasonal)))
                    colorModeSeasonal = Text::FormatOpenplanetColor(S_ColorModeSeasonal);

                if (S_ColorModeTotd != (S_ColorModeTotd = UI::InputColor3("Track of the Day", S_ColorModeTotd)))
                    colorModeTotd = Text::FormatOpenplanetColor(S_ColorModeTotd);

                if (S_ColorModeTmx != (S_ColorModeTmx = UI::InputColor3("Trackmania.exchange", S_ColorModeTmx)))
                    colorModeTmx = Text::FormatOpenplanetColor(S_ColorModeTmx);

                if (S_ColorModeClub != (S_ColorModeClub = UI::InputColor3("Club campaign", S_ColorModeClub)))
                    colorModeClub = Text::FormatOpenplanetColor(S_ColorModeClub);

                if (S_ColorModeCustom != (S_ColorModeCustom = UI::InputColor3("Custom list", S_ColorModeCustom)))
                    colorModeCustom = Text::FormatOpenplanetColor(S_ColorModeCustom);

                UI::Indent(-indentWidth);
            }
        }

        namespace Seasons {
            void Render() {
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
        }

        namespace Series {
            void Render() {
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
        }
    }

    namespace General {
        void Render() {
            if (!UI::CollapsingHeader(shadow + Icons::Sliders + " General"))
                return;

            UI::Indent(indentWidth);

            if (UI::Button(shadow + "Reset to default##general")) {
                pluginMeta.GetSetting("S_NotifyStarter").Reset();

                Meta::SaveSettings();
            }

            S_NotifyStarter = UI::Checkbox(
                shadow + "Notify when Starter Access is detected",
                S_NotifyStarter
            );

            MetaSettings::Render();

            UI::Indent(-indentWidth);
        }

        namespace MetaSettings {
            void Render() {
                if (!UI::CollapsingHeader(shadow + Icons::Cog + " Meta \\$I\\$AAA(settings about settings)"))
                    return;

                UI::Indent(indentWidth);

                if (UI::Button(shadow + "Reset to default##general-meta")) {
                    pluginMeta.GetSetting("S_SaveSettingsOnClose").Reset();
                    pluginMeta.GetSetting("S_ShowSettingsInDetached").Reset();
                    pluginMeta.GetSetting("S_ShowSettingsInMenu").Reset();

                    Meta::SaveSettings();
                }

                S_SaveSettingsOnClose = UI::Checkbox(
                    shadow + "Save settings when the top 'Settings' menu is closed",
                    S_SaveSettingsOnClose
                );

                S_ShowSettingsInDetached = UI::Checkbox(
                    shadow + "Show settings in the detached window",
                    S_ShowSettingsInDetached
                );

                S_ShowSettingsInMenu = UI::Checkbox(
                    shadow + "Show settings in the menu panel",  // REMOVE THIS ///////////////////////////////////////////////
                    S_ShowSettingsInMenu
                );

                UI::Indent(-indentWidth);
            }
        }
    }

    namespace Window {
        void Render() {
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
    }
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

// const string[] seriesWhite = { "01", "02", "03", "04", "05" };
// const string[] seriesGreen = { "06", "07", "08", "09", "10" };
// const string[] seriesBlue  = { "11", "12", "13", "14", "15" };
// const string[] seriesRed   = { "16", "17", "18", "19", "20" };
// const string[] seriesBlack = { "21", "22", "23", "24", "25" };
