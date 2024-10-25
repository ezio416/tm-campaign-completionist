// c 2024-10-24
// m 2024-10-25

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
    if (true
        && (source != WindowSource::Menu     || S_ShowSettingsInMenu)
        && (source != WindowSource::Detached || S_ShowSettingsInDetached)
    ) {
        WindowSettings(source);

        UI::Separator();
    }

    SectionTarget();
    UI::Separator();
    SectionSeries();
    UI::Separator();
    SectionFilters();
    UI::Separator();
    SectionOrder();
    UI::Separator();
    SectionTimeLimit();
    UI::Separator();
}

void SectionFilters() {
    UI::AlignTextToFramePadding();
    UI::Text("Filters:");

    UI::SameLine();
    if (UI::Checkbox("Played", S_Filter & MapFilter::Played == MapFilter::Played))
        S_Filter |= MapFilter::Played;
    else
        S_Filter = S_Filter & (S_Filter ^ MapFilter::Played);

    UI::SameLine();
    if (UI::Checkbox("Unplayed", S_Filter & MapFilter::Unplayed == MapFilter::Unplayed))
        S_Filter |= MapFilter::Unplayed;
    else
        S_Filter = S_Filter & (S_Filter ^ MapFilter::Unplayed);
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

    UI::SameLine();
    if (UI::RadioButton(Icons::Random, S_Order == MapOrder::Random))
        S_Order = MapOrder::Random;
    HoverTooltip("Random");

    UI::SameLine();
    if (UI::RadioButton(Icons::Crosshairs, S_Order == MapOrder::ClosestAbs))
        S_Order = MapOrder::ClosestAbs;
    HoverTooltip("Closest (absolute)");

    UI::SameLine();
    if (UI::RadioButton(Icons::Percent, S_Order == MapOrder::ClosestRel))
        S_Order = MapOrder::ClosestRel;
    HoverTooltip("Closest (relative)");
}

void SectionSeries() {
    UI::AlignTextToFramePadding();
    UI::Text("Series:");

    int styleColors = 0;

    UI::SameLine();
    styleColors += PushRadioButtonStyles(S_ColorSeriesWhite);
    if (UI::RadioButton("White", S_Series == CampaignSeries::White))
        S_Series = CampaignSeries::White;

    UI::SameLine();
    styleColors += PushRadioButtonStyles(S_ColorSeriesGreen);
    if (UI::RadioButton("Green", S_Series == CampaignSeries::Green))
        S_Series = CampaignSeries::Green;

    UI::SameLine();
    styleColors += PushRadioButtonStyles(S_ColorSeriesBlue);
    if (UI::RadioButton("Blue", S_Series == CampaignSeries::Blue))
        S_Series = CampaignSeries::Blue;

    UI::SameLine();
    styleColors += PushRadioButtonStyles(S_ColorSeriesRed);
    if (UI::RadioButton("Red", S_Series == CampaignSeries::Red))
        S_Series = CampaignSeries::Red;

    UI::SameLine();
    styleColors += PushRadioButtonStyles(S_ColorSeriesBlack);
    if (UI::RadioButton("Black", S_Series == CampaignSeries::Black))
        S_Series = CampaignSeries::Black;

    UI::SameLine();
    styleColors += PushRadioButtonStyles(S_ColorSeriesAll);
    if (UI::RadioButton("All", S_Series == CampaignSeries::All))
        S_Series = CampaignSeries::All;

    UI::SameLine();
    styleColors += PushRadioButtonStyles(S_ColorSeriesUnknown);
    if (UI::RadioButton("Unknown", S_Series == CampaignSeries::Unknown))
        S_Series = CampaignSeries::Unknown;

    UI::PopStyleColor(styleColors);
}

void SectionTarget() {
    UI::AlignTextToFramePadding();
    UI::Text("Target:");

    int styleColors = 0;

    UI::SameLine();
    styleColors += PushRadioButtonStyles(S_ColorMedalAuthor);
    if (UI::RadioButton("Author", S_Target == TargetMedal::Author))
        S_Target = TargetMedal::Author;

    UI::SameLine();
    styleColors += PushRadioButtonStyles(S_ColorMedalGold);
    if (UI::RadioButton("Gold", S_Target == TargetMedal::Gold))
        S_Target = TargetMedal::Gold;

    UI::SameLine();
    styleColors += PushRadioButtonStyles(S_ColorMedalSilver);
    if (UI::RadioButton("Silver", S_Target == TargetMedal::Silver))
        S_Target = TargetMedal::Silver;

    UI::SameLine();
    styleColors += PushRadioButtonStyles(S_ColorMedalBronze);
    if (UI::RadioButton("Bronze", S_Target == TargetMedal::Bronze))
        S_Target = TargetMedal::Bronze;

    UI::SameLine();
    styleColors += PushRadioButtonStyles(S_ColorMedalNone);
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
    DrawPresetButton("25m",  1500);
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

int PushRadioButtonStyles(vec3 color) {
    UI::PushStyleColor(UI::Col::FrameBg,        vec4(color * 0.2f, 1.0f));
    UI::PushStyleColor(UI::Col::FrameBgHovered, vec4(color * 0.5f, 1.0f));
    UI::PushStyleColor(UI::Col::FrameBgActive,  vec4(color * 0.8f, 1.0f));
    UI::PushStyleColor(UI::Col::CheckMark,      vec4(color,        1.0f));
    UI::PushStyleColor(UI::Col::Text,           vec4(color,        1.0f));

    return 5;
}
