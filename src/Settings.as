// c 2024-01-01
// m 2025-03-12

[Setting hidden]
bool S_Init = false;  // used to grab all PBs at boot if never done before

[Setting hidden] bool S_WindowAutoResize   = false;
[Setting hidden] bool S_WindowDetached     = false;
[Setting hidden] bool S_WindowHideWithGame = true;
[Setting hidden] bool S_WindowHideWithOP   = true;

[SettingsTab name="Campaign Completionist" icon="Check" order=0]
void SettingsTab_RenderWindow() {
    if (!hasPlayPermission) {
        UI::Text(Icons::FrownO + " Sorry, you need Club Access " + Icons::FrownO);
        return;
    }

    RenderWindow(Windows::Source::Settings);
}

namespace Settings {
    void Render() {
        if (!UI::CollapsingHeader(Icons::Cogs + " Settings"))
            return;

        UI::Indent(indentWidth);

        Colors::Render();

        UI::Indent(-indentWidth);
    }

    namespace Colors {
        void Render() {
            if (!UI::CollapsingHeader(Icons::PaintBrush + " Colors"))
                return;

            UI::Indent(indentWidth);

            Medals::Render();

            UI::Indent(-indentWidth);
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
    }
}
