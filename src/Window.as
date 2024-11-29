// c 2024-10-24
// m 2024-11-28

const string shadow = "\\$S";

void RenderWindowDetached() {
    if (false
        || !S_WindowDetached
        || (S_WindowHideWithGame && !UI::IsGameUIVisible())
        || (S_WindowHideWithOP && !UI::IsOverlayShown())
    )
        return;

    int flags = UI::WindowFlags::NoFocusOnAppearing;
    if (S_WindowAutoResize)
        flags |= UI::WindowFlags::AlwaysAutoResize;

    if (UI::Begin(pluginTitle, S_WindowDetached, flags))
        Window(WindowSource::Detached);

    UI::End();
}

enum WindowSource {
    Settings,
    Menu,
    Detached,
    Unknown
}

void Window(WindowSource source = WindowSource::Unknown) {
    if (source == WindowSource::Menu || source == WindowSource::Detached) {
        if (UI::BeginChild("##child-window"))
            WindowContent(source);
        UI::EndChild();

        return;
    }

    WindowContent(source);
}

void WindowContent(WindowSource source = WindowSource::Unknown) {
    const float widthAvail = UI::GetContentRegionAvail().x;

    if (true
        && (source != WindowSource::Menu     || S_ShowSettingsInMenu)
        && (source != WindowSource::Detached || S_ShowSettingsInDetached)
    ) {
        WindowSettings(source);
        UI::Separator();
    }

    SectionMode();
    UI::Separator();

    if (S_Mode == Mode::Seasonal || S_Mode == Mode::Club) {
        SectionSeries();
        UI::Separator();
    }

    SectionTarget();
    UI::Separator();

    SectionOrder();
    UI::Separator();

    if (API::progress > 0.0f) {
        UI::PushStyleColor(UI::Col::PlotHistogram, UI::HSV(GayHue(3000), 1.0f, 1.0f));
        UI::ProgressBar(API::progress, vec2(widthAvail, scale * 5.0f));
        UI::PopStyleColor();

        HoverTooltip(Text::Format("%.1f%%", API::progress * 100.0f));
    }

    UI::BeginDisabled(API::requesting);
    if (UI::Button(Icons::Refresh + " Generate", vec2(widthAvail, scale * 30.0f)))
        queue.Generate();
    if (API::requesting)
        HoverTooltip("plugin is getting stuff, hold on...");
    // if (API::requesting && UI::IsItemHovered(UI::HoveredFlags::AllowWhenDisabled))
    //     UI::SetTooltip("plugin is getting stuff, hold on...");
    UI::EndDisabled();

    SectionOptions();
    UI::Separator();

    SectionGenerated();

    Map@ next = queue.next;

    if (queue.Length == 0 || next is null)
        return;

    UI::Separator();

    // if (UI::BeginTable("##table-nextmap-header", 3, UI::TableFlags::None)) {
    //     UI::TableSetupColumn("next", UI::TableColumnFlags::WidthFixed);
    //     UI::TableSetupColumn("name", UI::TableColumnFlags::WidthStretch);
    //     UI::TableSetupColumn("author", UI::TableColumnFlags::WidthFixed);

    //     UI::TableNextRow();

    //     UI::TableNextColumn();
    //     UI::Text("\\$888Next:");

    //     UI::TableNextColumn();
    //     UI::PushFont(fontHeader);

    //     string nextName   = "???";
    //     string nextAuthor = "???";

    //     if (next !is null) {
    //         nextAuthor = next.authorDisplayName;

    //         if (next.name !is null)
    //             nextName = S_ColoredMapNames ? next.name.formatted : next.name.stripped;
    //     }

    //     const float textWidth = Draw::MeasureString(nextName, fontHeader).x;

    //     UI::SetCursorPos(UI::GetCursorPos() + vec2((UI::GetContentRegionAvail().x - textWidth) * 0.5f, 0.0f));
    //     UI::Text(nextName);
    //     UI::PopFont();

    //     UI::TableNextColumn();
    //     UI::Text("\\$888by " + nextAuthor);

    //     UI::EndTable();
    // }

    // const vec2 pre = UI::GetCursorPos();

    UI::BeginGroup();

    UI::Text("\\$AAA" + shadow + "Next:");

    UI::PushFont(fontHeader);
    if (next.name is null)
        UI::Text(shadow + "???");
    else
        UI::Text(S_ColoredMapNames ? next.name.formatted : shadow + next.name.stripped);
    UI::PopFont();

    UI::PushFont(fontSubHeader);
    UI::Text(shadow + "\\$AAAby \\$G" + next.authorDisplayName);
    UI::PopFont();

    UI::EndGroup();
    UI::SameLine();

    const vec2 buttonSize = vec2(scale * 100.0f, scale * 50.0f);

    // UI::BeginGroup();

    UI::BeginDisabled(loadingMap);
    UI::SetCursorPos(UI::GetCursorPos() + vec2(scale * 50.0f, scale * 13.0f));
    if (UI::ButtonColored(shadow + Icons::Play + " Play##button-play-next", 0.33f, 0.6f, 0.6f, buttonSize))
        next.Play();
    UI::EndDisabled();

    UI::SameLine();
    UI::SetCursorPos(UI::GetCursorPos() + vec2(0.0f, scale * 13.0f));
    if (UI::ButtonColored(shadow + Icons::FastForward + " Skip##button-skip-next", 0.0f, 0.6f, 0.6f, buttonSize)) {
        next.skipped = true;
        queue.Next();
        Files::SaveMaps();
    }

    // UI::EndGroup();

    UI::SameLine();
    UI::BeginGroup();

#if DEPENDENCY_WARRIORMEDALS
    const uint wm = WarriorMedals::GetWMTime(next.uid);

    if (next.driven && next.pb < wm)
        UI::Text("PB:  " + Time::Format(next.pb));

    UI::Text(WarriorMedals::GetColorStr() + "Warrior:  \\$G" + Time::Format(wm) + "  " + next.TargetDelta(TargetMedal::Warrior));

    if (next.driven && next.pb == wm)
        UI::Text("PB:  " + Time::Format(next.pb));
#endif

    if (next.driven && next.pb < next.authorTime)
        UI::Text("PB:  " + Time::Format(next.pb));

    UI::Text(colorMedalAuthor + "Author:  \\$G" + Time::Format(next.authorTime) + "  " + next.TargetDelta(TargetMedal::Author));

    if (next.driven && next.pb >= next.authorTime && next.pb < next.goldTime)
        UI::Text("PB:  " + Time::Format(next.pb));

    UI::Text(colorMedalGold + "Gold:  \\$G" + Time::Format(next.goldTime) + "  " + next.TargetDelta(TargetMedal::Gold));

    if (next.driven && next.pb >= next.goldTime && next.pb < next.silverTime)
        UI::Text("PB:  " + Time::Format(next.pb));

    UI::Text(colorMedalSilver + "Silver:  \\$G" + Time::Format(next.silverTime) + "  " + next.TargetDelta(TargetMedal::Silver));

    if (next.driven && next.pb >= next.silverTime && next.pb < next.bronzeTime)
        UI::Text("PB:  " + Time::Format(next.pb));

    UI::Text(colorMedalBronze + "Bronze:  \\$G" + Time::Format(next.bronzeTime) + "  " + next.TargetDelta(TargetMedal::Bronze));

    if (next.driven && next.pb >= next.bronzeTime)
        UI::Text("PB:  " + Time::Format(next.pb));

    UI::EndGroup();

//     if (queue.generatedTarget != TargetMedal::None) {
//         string targetNextText;

//         switch (queue.generatedTarget) {
//             case TargetMedal::Bronze:
//                 targetNextText = colorMedalBronze + "Bronze\\$G:  " + Time::Format(next.bronzeTime);
//                 break;
//             case TargetMedal::Silver:
//                 targetNextText = colorMedalSilver + "Silver\\$G:  " + Time::Format(next.silverTime);
//                 break;
//             case TargetMedal::Gold:
//                 targetNextText = colorMedalGold + "Gold\\$G:  " + Time::Format(next.goldTime);
//                 break;
//             case TargetMedal::Author:
//                 targetNextText = colorMedalAuthor + "Author\\$G:  " + Time::Format(next.authorTime);
//                 break;
// #if DEPENDENCY_WARRIORMEDALS
//             case TargetMedal::Warrior:
//                 targetNextText = WarriorMedals::GetColorStr() + "Warrior\\$G:  " + Time::Format(WarriorMedals::GetWMTime(next.uid));
//                 break;
// #endif
//             default:;
//         }

        // if (next.driven)
            // targetNextText += "  " + next.TargetDelta(queue.generatedTarget);

        // UI::SameLine();
        // UI::SetCursorPos(pre + vec2((widthAvail - Draw::MeasureString(targetNextText).x) * 0.5f, 0.0f));
        // UI::SetCursorPos(pre + vec2(widthAvail - Draw::MeasureString(targetNextText).x, 0.0f));
        // UI::Text(targetNextText);
    // }

    // UI::SetCursorPos(UI::GetCursorPos() + vec2(scale * 20.0f, 0.0f));
    // UI::SetCursorPos(UI::GetCursorPos() + vec2((UI::GetContentRegionAvail().x - Draw::MeasureString()) * 0.5f, 0.0f));
    // UI::BeginGroup();

    // if (next.pb == uint(-1))
    //     UI::Text("PB: \\$444-:--.---");
    // else if (next.pb == 0)
    //     UI::Text("PB: \\$888-:--.---");
    // else
    //     UI::Text("PB: " + Time::Format(next.pb));

    // UI::Text("PB: " + Time::Format(next.pb));
    // UI::Text("PB: " + Time::Format(next.pb));

    // UI::EndGroup();
    // UI::SameLine();

    // UI::SameLine();
    // UI::SetCursorPos(UI::GetCursorPos() + vec2(UI::GetContentRegionAvail().x - scale * 100.0f, 0.0f));
    // UI::BeginGroup();

    // UI::BeginDisabled(loadingMap);
    // if (UI::Button(Icons::Play + " Play"))
    //     next.Play();
    // UI::EndDisabled();

    // next.bookmarked = UI::Checkbox("Bookmark", next.bookmarked);

    // next.skipped = UI::Checkbox("Skip", next.skipped);

    // UI::EndGroup();

    if (UI::BeginTable("##table-queue", 5, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("#",      UI::TableColumnFlags::WidthFixed, scale * 40.0f);
        UI::TableSetupColumn("Map");
        UI::TableSetupColumn(queue.generatedMode == Mode::Seasonal ? "Series" : "Author");
        UI::TableSetupColumn("Target", UI::TableColumnFlags::WidthFixed, scale * 80.0f);
        UI::TableSetupColumn("PB",     UI::TableColumnFlags::WidthFixed, scale * 140.0f);
        UI::TableHeadersRow();

        UI::ListClipper clipper(queue.Length - 1);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                Map@ map = queue[i + 1];

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::Text(tostring(i + 2));

                UI::TableNextColumn();
                UI::Text(map.name !is null ? (S_ColoredMapNames ? map.name.formatted : map.name.stripped) : "");
                // UI::Text(map.name !is null ? map.name.formatted : "\\$I\\$666" + map.uid.SubStr(0, 8) + "...");

                UI::TableNextColumn();
                if (queue.generatedMode == Mode::Seasonal)
                    UI::Text(tostring(map.series));
                else
                    UI::Text(map.authorDisplayName);

                UI::TableNextColumn();
                uint target;
                switch (queue.generatedTarget) {
                    case TargetMedal::Author:
                        target = map.authorTime;
                        break;
                    case TargetMedal::Gold:
                        target = map.goldTime;
                        break;
                    case TargetMedal::Silver:
                        target = map.silverTime;
                        break;
                    case TargetMedal::Bronze:
                        target = map.bronzeTime;
                        break;
                    case TargetMedal::None:
                        target = 0;
                        break;
                }
                UI::Text(target > 0 ? Time::Format(target) : "");

                UI::TableNextColumn();
                if (map.pb == uint(-1))
                    UI::Text("\\$444-:--.---");
                else if (map.pb == 0)
                    UI::Text("\\$888-:--.---");
                else
                    UI::Text(Time::Format(map.pb) + "  " + map.TargetDelta(queue.generatedTarget));
            }
        }

        UI::PopStyleColor();
        UI::EndTable();
    }
}

void SectionGenerated() {
    string text = "Generated: mode " + colorMedalAuthor + tostring(queue.generatedMode);
    string jsonText = '{"mode":' + queue.generatedMode + ",";

    if (queue.generatedMode == Mode::Seasonal) {
        text += "\\$G | series " + colorMedalAuthor + tostring(queue.generatedSeries);
        jsonText += '"series":' + queue.generatedSeries + ",";
    }

    // "\\$G | season " + colorMedalAuthor + tostring(queue.generatedSeason)

    text += "\\$G | target " + colorMedalAuthor + tostring(queue.generatedTarget)
        + "\\$G | order " + colorMedalAuthor + tostring(queue.generatedOrder)
        + "\\$G | queue " + colorMedalAuthor + queue.Length;

    jsonText += '"target":' + queue.generatedTarget + ',"order":' + queue.generatedOrder + "}";

    // UI::SetCursorPos(UI::GetCursorPos() + vec2((UI::GetContentRegionAvail().x - Draw::MeasureString(text).x) * 0.5f, 0.0f));
    UI::Text(text);
    HoverTooltip(jsonText);
}

void SectionOptions() {
    if (S_TimeLimit > 0)
        S_AutoSwitch = true;

    if (UI::CollapsingHeader(Icons::Sliders + " More Options")) {
        UI::Indent(indentWidth);

        SectionTimeLimit();

        UI::Separator();

        UI::BeginDisabled(S_TimeLimit > 0);
        S_AutoSwitch = UI::Checkbox("Switch map automatically", S_AutoSwitch);
        UI::EndDisabled();
        HoverTooltipSetting("When target is achieved.\n\\$IAlways on for a time limit.", vec2(scale * -5.0f, 0.0f));

        UI::Indent(-indentWidth);
    }
}

void SectionOrder() {
    UI::AlignTextToFramePadding();
    UI::Text("Order:");

    UI::SameLine();
    if (UI::RadioButton(Icons::ArrowRight, S_Order == MapOrder::Normal))
        S_Order = MapOrder::Normal;
    HoverTooltip("Normal");

    UI::SameLine();
    if (UI::RadioButton(Icons::ArrowLeft, S_Order == MapOrder::Reverse))
        S_Order = MapOrder::Reverse;
    HoverTooltip("Reverse");

    UI::BeginDisabled();

    UI::SameLine();
    if (UI::RadioButton(Icons::Crosshairs, S_Order == MapOrder::ClosestAbs))
        S_Order = MapOrder::ClosestAbs;
    HoverTooltip("Closest (absolute)");

    UI::SameLine();
    if (UI::RadioButton(Icons::Percent, S_Order == MapOrder::ClosestRel))
        S_Order = MapOrder::ClosestRel;
    HoverTooltip("Closest (relative)");

    UI::EndDisabled();

    UI::SameLine();
    if (UI::RadioButton(Icons::Random, S_Order == MapOrder::Random))
        S_Order = MapOrder::Random;
    HoverTooltip("Random");
}

void SectionMode() {
    UI::AlignTextToFramePadding();
    UI::Text("Mode:");

    int styles = 0;

    UI::SameLine();
    styles += PushCheckboxStyles(S_ColorModeSeasonal);
    if (UI::RadioButton("Seasonal", S_Mode == Mode::Seasonal))
        S_Mode = Mode::Seasonal;

    UI::SameLine();
    styles += PushCheckboxStyles(S_ColorModeTotd);
    if (UI::RadioButton("Track of the Day", S_Mode == Mode::TOTD))
        S_Mode = Mode::TOTD;

    UI::PopStyleColor(styles);
    styles = 0;
    UI::BeginDisabled();

    UI::SameLine();
    styles += PushCheckboxStyles(S_ColorModeTmx);
    if (UI::RadioButton("TMX", S_Mode == Mode::TMX))
        S_Mode = Mode::TMX;

    UI::SameLine();
    styles += PushCheckboxStyles(S_ColorModeClub);
    if (UI::RadioButton("Club", S_Mode == Mode::Club))
        S_Mode = Mode::Club;

    UI::SameLine();
    styles += PushCheckboxStyles(S_ColorModeCustom);
    if (UI::RadioButton("Custom", S_Mode == Mode::Custom))
        S_Mode = Mode::Custom;

    UI::PopStyleColor(styles);
    UI::EndDisabled();
}

void SectionSeries() {
    UI::AlignTextToFramePadding();
    UI::Text("Series:");

    int styleColors = 0;

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorSeriesWhite);
    Series filter = Series::White;
    if (UI::Checkbox(tostring(filter), S_Series & filter == filter))
        S_Series |= filter;
    else
        S_Series &= (S_Series ^ filter);

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorSeriesGreen);
    filter = Series::Green;
    if (UI::Checkbox(tostring(filter), S_Series & filter == filter))
        S_Series |= filter;
    else
        S_Series &= (S_Series ^ filter);

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorSeriesBlue);
    filter = Series::Blue;
    if (UI::Checkbox(tostring(filter), S_Series & filter == filter))
        S_Series |= filter;
    else
        S_Series &= (S_Series ^ filter);

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorSeriesRed);
    filter = Series::Red;
    if (UI::Checkbox(tostring(filter), S_Series & filter == filter))
        S_Series |= filter;
    else
        S_Series &= (S_Series ^ filter);

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorSeriesBlack);
    filter = Series::Black;
    if (UI::Checkbox(tostring(filter), S_Series & filter == filter))
        S_Series |= filter;
    else
        S_Series &= (S_Series ^ filter);

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorSeriesUnknown);
    filter = Series::Unknown;
    if (UI::Checkbox(tostring(filter), S_Series & filter == filter))
        S_Series |= filter;
    else
        S_Series &= (S_Series ^ filter);

    UI::PopStyleColor(styleColors);
}

void SectionTarget() {
    UI::AlignTextToFramePadding();
    UI::Text("Medal:");

    int styleColors = 0;

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorMedalAuthor);
    if (UI::RadioButton("Author", S_Target == TargetMedal::Author))
        S_Target = TargetMedal::Author;

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorMedalGold);
    if (UI::RadioButton("Gold", S_Target == TargetMedal::Gold))
        S_Target = TargetMedal::Gold;

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorMedalSilver);
    if (UI::RadioButton("Silver", S_Target == TargetMedal::Silver))
        S_Target = TargetMedal::Silver;

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorMedalBronze);
    if (UI::RadioButton("Bronze", S_Target == TargetMedal::Bronze))
        S_Target = TargetMedal::Bronze;

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorMedalNone);
    if (UI::RadioButton("Just Finish", S_Target == TargetMedal::None))
        S_Target = TargetMedal::None;

    UI::PopStyleColor(styleColors);
}

void SectionTimeLimit() {
    UI::AlignTextToFramePadding();
    UI::Text("Time limit per map (s):");

    UI::SameLine();
    const string fmt = Time::Format(int(S_TimeLimit * 1000));
    UI::SetNextItemWidth((UI::GetContentRegionAvail().x) / scale - Draw::MeasureString(fmt).x + (scale * 5.0f));
    S_TimeLimit = UI::InputInt(fmt + "###input-timelimit", S_TimeLimit, 10);
    if (S_TimeLimit < 0)
        S_TimeLimit = 0;

    DrawPresetButton("none", 0, false);
    DrawPresetButton("1m",   60);
    DrawPresetButton("2m",   120);
    DrawPresetButton("3m",   180);
    DrawPresetButton("5m",   300);
    DrawPresetButton("10m",  600);
    DrawPresetButton("15m",  900);
    DrawPresetButton("20m",  1200);
    DrawPresetButton("30m",  1800);
    DrawPresetButton("45m",  2700);
    DrawPresetButton("1h",   3600);
    DrawPresetButton("2h",   7200);
}

void DrawPresetButton(const string &in name, int num, bool offset = true) {
    if (offset) {
        UI::SameLine();
        UI::SetCursorPos(UI::GetCursorPos() + vec2(scale * -5.0f, 0.0f));
    }

    const bool current = S_TimeLimit == num;

    if (current)
        UI::PushStyleColor(UI::Col::Button, vec4());

    UI::BeginDisabled(current);
    if (UI::Button(name))
        S_TimeLimit = num;
    UI::EndDisabled();

    if (current)
        UI::PopStyleColor();
}

int PushCheckboxStyles(vec3 color) {
    UI::PushStyleColor(UI::Col::FrameBg,        vec4(color * 0.2f, 1.0f));
    UI::PushStyleColor(UI::Col::FrameBgHovered, vec4(color * 0.5f, 1.0f));
    UI::PushStyleColor(UI::Col::FrameBgActive,  vec4(color * 0.8f, 1.0f));
    UI::PushStyleColor(UI::Col::CheckMark,      vec4(color,        1.0f));
    UI::PushStyleColor(UI::Col::Text,           vec4(color,        1.0f));

    return 5;
}
