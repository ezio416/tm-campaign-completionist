// c 2024-10-24
// m 2024-11-30

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
        Settings::Render(source);
        // UI::Separator();
    }

    UI::SeparatorText("Mode");
    SectionMode();
    // UI::Separator();

    if (S_Mode == Mode::Seasonal || S_Mode == Mode::Club) {
        UI::SeparatorText("Series");
        SectionSeries();
        // UI::Separator();
    }

    UI::SeparatorText("Medal");
    SectionTarget();
    // UI::Separator();

    UI::SeparatorText("Order");
    SectionOrder();
    // UI::Separator();

    if (API::progress > 0.0f) {
        UI::PushStyleColor(UI::Col::PlotHistogram, UI::HSV(GayHue(3000), 1.0f, 1.0f));
        UI::ProgressBar(API::progress, vec2(widthAvail, scale * 5.0f));
        UI::PopStyleColor();

        UIExt::HoverTooltip(Text::Format("%.1f%%", API::progress * 100.0f));
    }

    UI::BeginDisabled(API::requesting || q.sorting);
    if (UI::Button(shadow + Icons::Refresh + " Generate", vec2(widthAvail, scale * 30.0f)))
        q.Generate();
    if (API::requesting)
        UIExt::HoverTooltip("plugin is getting stuff, hold on...");
    // if (API::requesting && UI::IsItemHovered(UI::HoveredFlags::AllowWhenDisabled))
    //     UI::SetTooltip("plugin is getting stuff, hold on...");
    UI::EndDisabled();

    SectionOptions();
    // UI::Separator();

    // SectionGenerated();

    q.Render();
}

void SectionGenerated() {
    string text = "Generated:";
    // text += " mode " + colorMedalAuthor + tostring(queue.generatedMode);
    // string jsonText = '{"mode":' + queue.generatedMode + ",";

    if (q.generatedMode == Mode::Seasonal) {
        text += "\\$G | series " + colorMedalAuthor + tostring(q.generatedSeries);
        // jsonText += '"series":' + queue.generatedSeries + ",";
    }

    // "\\$G | season " + colorMedalAuthor + tostring(queue.generatedSeason)

    text += "\\$G | target " + colorMedalAuthor + tostring(q.generatedTarget)
        + "\\$G | order " + colorMedalAuthor + tostring(q.generatedOrder)
        // + "\\$G | queue " + colorMedalAuthor + queue.Length
    ;

    // jsonText += '"target":' + queue.generatedTarget + ',"order":' + queue.generatedOrder + "}";

    // UI::SetCursorPos(UI::GetCursorPos() + vec2((UI::GetContentRegionAvail().x - Draw::MeasureString(text).x) * 0.5f, 0.0f));
    UI::Text(text);
    // HoverTooltip(jsonText);
}

void SectionMode() {
    int styles = PushCheckboxStyles(S_ColorModeSeasonal);
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
    if (UI::RadioButton(Icons::ArrowRight, S_Order == MapOrder::Normal))
        S_Order = MapOrder::Normal;
    UIExt::HoverTooltip("Normal");

    UI::SameLine();
    if (UI::RadioButton(Icons::ArrowLeft, S_Order == MapOrder::Reverse))
        S_Order = MapOrder::Reverse;
    UIExt::HoverTooltip("Reverse");

    UI::SameLine();
    if (UI::RadioButton(Icons::Crosshairs, S_Order == MapOrder::ClosestAbs))
        S_Order = MapOrder::ClosestAbs;
    UIExt::HoverTooltip("Closest (absolute)");

    UI::BeginDisabled();

    UI::SameLine();
    if (UI::RadioButton(Icons::Percent, S_Order == MapOrder::ClosestRel))
        S_Order = MapOrder::ClosestRel;
    UIExt::HoverTooltip("Closest (relative)");

    UI::EndDisabled();

    UI::SameLine();
    if (UI::RadioButton(Icons::Random, S_Order == MapOrder::Random))
        S_Order = MapOrder::Random;
    UIExt::HoverTooltip("Random");
}

void SectionSeries() {
    int styleColors = PushCheckboxStyles(S_ColorSeriesWhite);
    MapSeries filter = MapSeries::White;
    if (UI::Checkbox(tostring(filter), S_Series & filter == filter))
        S_Series |= filter;
    else
        S_Series &= (S_Series ^ filter);

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorSeriesGreen);
    filter = MapSeries::Green;
    if (UI::Checkbox(tostring(filter), S_Series & filter == filter))
        S_Series |= filter;
    else
        S_Series &= (S_Series ^ filter);

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorSeriesBlue);
    filter = MapSeries::Blue;
    if (UI::Checkbox(tostring(filter), S_Series & filter == filter))
        S_Series |= filter;
    else
        S_Series &= (S_Series ^ filter);

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorSeriesRed);
    filter = MapSeries::Red;
    if (UI::Checkbox(tostring(filter), S_Series & filter == filter))
        S_Series |= filter;
    else
        S_Series &= (S_Series ^ filter);

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorSeriesBlack);
    filter = MapSeries::Black;
    if (UI::Checkbox(tostring(filter), S_Series & filter == filter))
        S_Series |= filter;
    else
        S_Series &= (S_Series ^ filter);

    UI::SameLine();
    styleColors += PushCheckboxStyles(S_ColorSeriesUnknown);
    filter = MapSeries::Unknown;
    if (UI::Checkbox(tostring(filter), S_Series & filter == filter))
        S_Series |= filter;
    else
        S_Series &= (S_Series ^ filter);

    UI::PopStyleColor(styleColors);
}

void SectionTarget() {
    int styleColors = PushCheckboxStyles(S_ColorMedalAuthor);
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
