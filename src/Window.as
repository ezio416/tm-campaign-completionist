// c 2024-10-24
// m 2024-11-01

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

    if (S_Mode == Mode::Campaign) {
        // UI::AlignTextToFramePadding();
        // UI::Text("ID Type:");

        // UI::SameLine();
        // if (UI::RadioButton("Club (0-5 digits)", S_CustomSource == CustomSource::Club))
        //     S_CustomSource = CustomSource::Club;

        // UI::SameLine();
        // if (UI::RadioButton("TMX (0-6 digits)", S_CustomSource == CustomSource::TMX))
        //     S_CustomSource = CustomSource::TMX;

        int id = 0;
        const string cid = "TMX Campaign ID";
        // UI::SetNextItemWidth(widthAvail / scale - Draw::MeasureString(cid).x);
        UI::AlignTextToFramePadding();
        UI::Text(cid);
        UI::SameLine();
        UI::SetNextItemWidth(UI::GetContentRegionAvail().x / scale);
        UI::InputInt("##inputint-campid", id);

        UI::Separator();
    } else {
        if (S_Mode == Mode::Seasonal) {
            SectionSeries();
            UI::Separator();
        }
    }

    SectionTarget();
    UI::Separator();

    // SectionFilters();
    // UI::Separator();

    SectionOrder();
    UI::Separator();

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

    if (UI::BeginTable("##table-nextmap-header", 3, UI::TableFlags::None)) {
        UI::TableSetupColumn("next", UI::TableColumnFlags::WidthFixed);
        UI::TableSetupColumn("name", UI::TableColumnFlags::WidthStretch);
        UI::TableSetupColumn("author", UI::TableColumnFlags::WidthFixed);

        UI::TableNextRow();

        UI::TableNextColumn();
        UI::Text("\\$888Next:");

        UI::TableNextColumn();
        UI::PushFont(fontHeader);

        string nextName   = "???";
        string nextAuthor = "???";

        if (queue.next !is null) {
            nextAuthor = queue.next.authorDisplayName;

            if (queue.next.name !is null)
                nextName = S_ColoredMapNames ? queue.next.name.formatted : queue.next.name.stripped;

            // if (queue.next.authorName.Length > 0)
            //     nextAuthor = queue.next.authorName;
            // else if (queue.next.authorId.Length > 0)
            //     nextAuthor = "\\$I\\$666" + queue.next.authorId.SubStr(0, 8) + "...";
        }

        // const string mapName = "$S$082Map $I$S$80FName $Z$0DDWhichisalong $S$I$GName $I$FF0Indeed.";
        // const string mapName = "$n[Mini-Trial] $g$C6CC$C8Al$B98o$BB6s$AC4e$AE2 $9F0Q$9F0u$8E3a$7D5r$6C8t$5BAe$4ADr$39Fs";
        // nextName = S_ColoredMapNames ? Text::OpenplanetFormatCodes(mapName) : Text::StripFormatCodes(mapName);

        const float textWidth = Draw::MeasureString(nextName, fontHeader).x;

        UI::SetCursorPos(UI::GetCursorPos() + vec2((UI::GetContentRegionAvail().x - textWidth) * 0.5f, 0.0f));
        UI::Text(nextName);
        UI::PopFont();

        UI::TableNextColumn();
        // nextAuthor = "A.Very.Long.Player.Username";
        // nextAuthor = "Ezio.TM";
        UI::Text("\\$888by " + nextAuthor);

        UI::EndTable();
    }

    // target
    // pb
    // delta
    // play
    // skip
    // bookmark

    UI::Text("Queue: " + queue.Length);

    if (queue.Length > 0) {
        string text = "Generated: mode " + colorMedalAuthor + tostring(queue.generatedMode);
        string jsonText = '{"mode":' + queue.generatedMode + ",";

        if (queue.generatedMode == Mode::Seasonal) {
            text += "\\$G | series " + colorMedalAuthor + tostring(queue.generatedSeries);
            // text += "\\$G | series " + colorMedalAuthor + ();
            jsonText += '"series":' + queue.generatedSeries + ",";
        }

        // "\\$G | season " + colorMedalAuthor + tostring(queue.generatedSeason)

        text += "\\$G | target " + colorMedalAuthor + tostring(queue.generatedTarget)
            + "\\$G | order " + colorMedalAuthor + tostring(queue.generatedOrder);

        jsonText += '"target":' + queue.generatedTarget + ',"order":' + queue.generatedOrder + "}";

        UI::Text(text);
        HoverTooltip(jsonText);
    }

    if (UI::BeginTable("##table-queue", 5, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("#",      UI::TableColumnFlags::WidthFixed, scale * 40.0f);
        UI::TableSetupColumn("Map");
        UI::TableSetupColumn(queue.generatedMode == Mode::Seasonal ? "Series" : "Author");
        UI::TableSetupColumn("Target", UI::TableColumnFlags::WidthFixed, scale * 80.0f);
        UI::TableSetupColumn("PB",     UI::TableColumnFlags::WidthFixed, scale * 80.0f);
        UI::TableHeadersRow();

        UI::ListClipper clipper(queue.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                if (uint(i + 1) == queue.Length)
                    break;

                Map@ map = queue[i + 1];

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::Text(tostring(i + 2));

                UI::TableNextColumn();
                UI::Text(map.name !is null ? map.name.formatted : "");
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
                // UI::Text(Time::Format(123456));
                UI::Text("--:--.---");
            }
        }

        UI::PopStyleColor();
        UI::EndTable();
    }

    // if (UI::BeginChild("##child-queue")) {
    //     for (uint i = 0; i < queue.Length; i++) {
    //         Map@ map = queue[i];

    //         UI::Text(map.name !is null ? map.name.stripped : map.uid);
    //     }
    // }
    // UI::EndChild();
}

// void SectionFilters() {
//     UI::AlignTextToFramePadding();
//     UI::Text("Filters:");

//     UI::SameLine();
//     MapFilter filter = MapFilter::Played;
//     if (UI::Checkbox(tostring(filter), S_Filter & filter == filter))
//         S_Filter |= filter;
//     else
//         S_Filter &= (S_Filter ^ filter);

//     UI::SameLine();
//     filter = MapFilter::Unplayed;
//     if (UI::Checkbox(tostring(filter), S_Filter & filter == filter))
//         S_Filter |= filter;
//     else
//         S_Filter &= (S_Filter ^ filter);
// }

void SectionOptions() {
    if (S_TimeLimit > 0)
        S_AutoSwitch = true;

    if (UI::CollapsingHeader(Icons::Sliders + " More Options")) {
        UI::Indent(indentWidth);

        SectionTimeLimit();

        UI::Separator();

        UI::BeginDisabled(S_TimeLimit > 0);
        S_AutoSwitch = UI::Checkbox("Auto Switch Map", S_AutoSwitch);
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

    UI::SameLine();
    if (UI::RadioButton(Icons::Random, S_Order == MapOrder::Random))
        S_Order = MapOrder::Random;
    HoverTooltip("Random");

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
}

void SectionMode() {
    UI::AlignTextToFramePadding();
    UI::Text("Mode:");

    // UI::SameLine();
    // ModeFilter filter = ModeFilter::Seasonal;
    // if (UI::Checkbox(tostring(filter), S_Mode & filter == filter))
    //     S_Mode |= filter;
    // else
    //     S_Mode &= (S_Mode ^ filter);

    // UI::SameLine();
    // filter = ModeFilter::Totd;
    // if (UI::Checkbox(tostring(filter), S_Mode & filter == filter))
    //     S_Mode |= filter;
    // else
    //     S_Mode &= (S_Mode ^ filter);

    // for (int i = 0; i <= Mode::Unknown; i++) {
    //     Mode mode = Mode(i);

    //     UI::SameLine();
    //     if (UI::RadioButton(tostring(mode).Replace("_", " "), S_Mode == mode))
    //         S_Mode = mode;
    // }

    int styles = 0;

    UI::SameLine();
    styles += PushCheckboxStyles(vec3(0.0f, 0.6f, 0.0f));
    if (UI::RadioButton("Seasonal", S_Mode == Mode::Seasonal))
        S_Mode = Mode::Seasonal;

    UI::SameLine();
    styles += PushCheckboxStyles(vec3(0.0f, 0.6f, 1.0f));
    if (UI::RadioButton("Track of the Day", S_Mode == Mode::TrackOfTheDay))
        S_Mode = Mode::TrackOfTheDay;

    UI::SameLine();
    styles += PushCheckboxStyles(vec3(0.9f, 0.4f, 0.0f));
    UI::BeginDisabled();
    if (UI::RadioButton("Other Campaign", S_Mode == Mode::Campaign))
        S_Mode = Mode::Campaign;
    UI::EndDisabled();

    UI::PopStyleColor(styles);
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
    UI::Text("Target:");

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
