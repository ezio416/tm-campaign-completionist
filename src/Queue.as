// c 2024-10-30
// m 2024-12-01

Queue q;

class Queue {
    private Map@[] _maps;

    Mode        generatedMode   = Mode::Unknown;
    MapOrder    generatedOrder  = MapOrder::Normal;
    // Season   generatedSeason = Season::Unknown;
    int         generatedSeries = -1;
    TargetMedal generatedTarget = TargetMedal::None;
    bool        sorting         = false;

    uint get_Length() {
        return _maps.Length;
    }

    Map@ get_next() {
        if (Length == 0)
            return null;

        return _maps[0];
    }

    Map@ get_opIndex(int idx) {
        try {
            return _maps[idx];
        } catch {
            return null;
        }
    }

    int Find(Map@ map) {
        return _maps.FindByRef(map);
    }

    void Generate() {
        _maps = { };

        for (uint i = 0; i < mapsArr.Length; i++) {
            Map@ map = mapsArr[i];

            // if (S_Mode == Mode::Seasonal)

            if (true
                && map.mode == S_Mode
                && !map.skipped
                && map.Delta(S_Target) > 0
                && (false
                    || S_Mode != Mode::Seasonal
                    || map.series == map.series & S_Series
                )
            )
                _maps.InsertLast(@map);
        }

        Sort();

        generatedMode = S_Mode;
        generatedOrder = S_Order;
        generatedSeries = S_Series;
        generatedTarget = S_Target;
    }

    void GetPBs() {
        for (uint i = 0; i < Length; i++)
            this[i].GetPBFromManager();

        Files::SaveMaps();
    }

    void GetPBsAsync() {
        for (uint i = 0; i < Length; i++) {
            Map@ map = this[i];

            const uint pre = map.pb;
            map.GetPBFromManagerAsync();

            if (pre != map.pb)
                Files::SaveMaps();
        }
    }

    void GetPBsMultipleAsync() {
        string[] uids;

        for (uint i = 0; i < Length; i++)
            uids.InsertLast(this[i].uid);

        API::GetPBsAsync(uids);
    }

    Map@ Next() {
        if (Length == 0)
            return null;

        _maps.RemoveAt(0);

        return next;
    }

    /*
    Pops last element if `i` is negative
    Pops element at `i` if `i` is not negative
    Returns null if `i` is out of range
    */
    Map@ Pop(int i = -1) {
        if (i >= int(Length) || Length == 0)
            return null;

        Map@ map;

        if (i < 0) {
            @map = _maps[Length - 1];
            _maps.RemoveAt(Length - 1);
        } else {
            @map = _maps[i];
            _maps.RemoveAt(i);
        }

        return map;
    }

    void Render() {
        if (sorting || _maps.Length == 0 || next is null)
            return;

        string sepText = "Queue: ";
        const string reset = "\\$G";

        sepText += GetColor(generatedMode) + tostring(generatedMode) + reset + " | ";
        sepText += GetColor(generatedTarget) + tostring(generatedTarget) + reset + " | ";

        sepText += "\\$AAA" + Length + reset + " maps | ";
        sepText += "\\$AAA" + tostring(generatedOrder) + reset + " order";

        UI::PushFont(fontSubHeader);
        UI::SeparatorText(sepText);
        UI::PopFont();

        const vec2 buttonSize = vec2(scale * 40.0f);

        UI::BeginGroup();

        UI::BeginDisabled(loadingMap);
        if (UI::ButtonColored(shadow + Icons::Play + "##button-next-play", 0.33f, 0.6f, 0.6f, buttonSize))
            next.Play();
        UIExt::HoverTooltip("Play \"" + (next.name !is null ? next.name.stripped : "Map") + "\"");
        UI::EndDisabled();

        if (UI::ButtonColored(shadow + Icons::Heartbeat + "##button-next-tmio", 0.57f, 0.83f, 0.81f, buttonSize))
            OpenBrowserURL("https://trackmania.io/#/leaderboard/" + next.uid);
        UIExt::HoverTooltip("trackmania.io");

        UI::EndGroup();
        UI::SameLine();
        UI::SetCursorPos(UI::GetCursorPos() + vec2(scale * -4.0f, 0.0f));
        UI::BeginGroup();

        if (UI::ButtonColored(shadow + Icons::FastForward + "##button-next-skip", 0.0f, 0.6f, 0.6f, buttonSize)) {
            next.skipped = true;
            Files::SaveMaps();
            Next();
        }
        UIExt::HoverTooltip("Skip \"" + (next.name !is null ? next.name.stripped : "Map") + "\"");

        if (UI::ButtonColored(shadow + Icons::Exchange + "##button-next-tmx", 0.39f, 0.57f, 0.8f, buttonSize)) {
            ;
        }
        UIExt::HoverTooltip("trackmania.exchange");

        UI::EndGroup();
        UI::SameLine();
        UI::SetCursorPos(UI::GetCursorPos() + vec2(scale * -4.0f, 0.0f));
        UI::BeginGroup();

        if (UI::ButtonColored(shadow + (next.bookmarked ? Icons::Bookmark : Icons::BookmarkO) + "##button-next-bookmark", 0.15f, 0.6f, 0.6f, buttonSize)) {
            next.bookmarked = !next.bookmarked;
            Files::SaveMaps();
        }
        UIExt::HoverTooltip("Bookmark \"" + (next.name !is null ? next.name.stripped : "Map") + "\"");

        // if (UI::ButtonColored(shadow + Icons::Question + "##button-next-idk", 0.85f, 0.6f, 0.6f, buttonSize)) {
        //     ;
        // }

        UI::EndGroup();
        UI::SameLine();
        UI::BeginGroup();

        UI::Text("\\$AAA" + shadow + "Next:");

        UI::PushFont(fontHeader);
        if (next.name is null)
            UI::Text(shadow + "???");
        else
            UI::Text(S_ColoredMapNames ? next.name.formatted : shadow + next.name.stripped);
        UI::PopFont();

        UI::PushFont(fontSubHeader);
        UI::Text(shadow + "\\$AAAby " + reset + next.authorDisplayName);
        UI::PopFont();

        UI::EndGroup();

        UI::SameLine();
        UI::SetCursorPos(UI::GetCursorPos() + vec2(scale * 20.0f, scale * 10.0f));
        UI::BeginGroup();

        uint count = 0;

#if DEPENDENCY_WARRIORMEDALS
        RaceTime wm = WarriorMedals::GetWMTime(next.uid);
        const string wmCol = WarriorMedals::GetColorStr();

        if (true
            && next.driven
            && wm.driven
            && next.pb < wm
        ) {
            UI::Text(shadow + wmCol + "PB:  " + reset + tostring(next.pb));
            count++;
        }

        UI::Text(shadow + wmCol + "Warrior:  " + reset + tostring(wm) + "  " + next.DeltaColored(TargetMedal::Warrior));
        count++;
#endif

        if (true
            && next.driven
#if DEPENDENCY_WARRIORMEDALS
            && wm.driven
            && next.pb >= wm
#endif
            && next.pb < next.authorTime
        ) {
            UI::Text(shadow
#if DEPENDENCY_WARRIORMEDALS
                + (next.pb == wm ? wmCol : colorMedalAuthor)
#else
                + colorMedalAuthor
#endif
                + "PB:  " + reset + tostring(next.pb)
            );
            count++;
        }

        UI::Text(shadow + colorMedalAuthor + "Author:  " + reset + tostring(next.authorTime) + "  " + next.DeltaColored(TargetMedal::Author));
        count++;

        if (true
            && next.driven
            && next.pb >= next.authorTime
            && next.pb < next.goldTime
        ) {
            UI::Text(shadow + "PB:  " + tostring(next.pb));
            count++;
        }

        if (count == 3) {
            UI::EndGroup();
            UI::SameLine();
            UI::SetCursorPos(UI::GetCursorPos() + vec2(scale * 10.0f));
            UI::BeginGroup();
        }

        UI::Text(shadow + colorMedalGold + "Gold:  " + reset + tostring(next.goldTime) + "  " + next.DeltaColored(TargetMedal::Gold));
        count++;

        if (count == 3) {
            UI::EndGroup();
            UI::SameLine();
            UI::SetCursorPos(UI::GetCursorPos() + vec2(scale * 10.0f));
            UI::BeginGroup();
        }

        if (true
            && next.driven
            && next.pb >= next.goldTime
            && next.pb < next.silverTime
        )
            UI::Text(shadow + "PB:  " + tostring(next.pb));

        UI::Text(shadow + colorMedalSilver + "Silver:  " + reset + tostring(next.silverTime) + "  " + next.DeltaColored(TargetMedal::Silver));

        if (next.driven && next.pb >= next.silverTime && next.pb < next.bronzeTime)
            UI::Text(shadow + "PB:  " + tostring(next.pb));

        UI::Text(shadow + colorMedalBronze + "Bronze:  " + reset + tostring(next.bronzeTime) + "  " + next.DeltaColored(TargetMedal::Bronze));

        if (true
            && next.driven
            && next.pb >= next.bronzeTime
        )
            UI::Text(shadow + "PB:  " + tostring(next.pb));

        UI::EndGroup();

        RenderTable();
    }

    void RenderTable() {
        if (!UI::BeginTable("##table-queue", 5, UI::TableFlags::RowBg | UI::TableFlags::ScrollY))
            return;

        UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("#",      UI::TableColumnFlags::WidthFixed, scale * 40.0f);
        UI::TableSetupColumn("Map");
        UI::TableSetupColumn(generatedMode == Mode::Seasonal ? "Series" : "Author");
        UI::TableSetupColumn("Target", UI::TableColumnFlags::WidthFixed, scale * 70.0f);
        UI::TableSetupColumn("PB",     UI::TableColumnFlags::WidthFixed, scale * 195.0f);
        UI::TableHeadersRow();

        UI::ListClipper clipper(_maps.Length - 1);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                Map@ map = _maps[i + 1];

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::Text(tostring(i + 2));

                UI::TableNextColumn();
                UI::Text(map.name !is null ? (S_ColoredMapNames ? map.name.formatted : map.name.stripped) : "");
                // UI::Text(map.name !is null ? map.name.formatted : "\\$I\\$666" + map.uid.SubStr(0, 8) + "...");

                UI::TableNextColumn();
                if (generatedMode == Mode::Seasonal)
                    UI::Text(tostring(map.series));
                else
                    UI::Text(map.authorDisplayName);

                UI::TableNextColumn();
                uint target;
                switch (generatedTarget) {
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
                else {
                    const float d = map.DeltaPercent(generatedTarget) * 100.0f;
                    UI::Text(Time::Format(map.pb) + "  " + map.DeltaColored(generatedTarget) + "  " + (d <= 0.0f ? "\\$0F0-" : "\\$F00+") + Text::Format("%.1f", d) + "%");
                }
            }
        }

        UI::PopStyleColor();
        UI::EndTable();
    }

    void Sort() {
        switch (S_Order) {
            case MapOrder::Normal:
                break;

            case MapOrder::Reverse:
                _maps.Reverse();
                break;

            case MapOrder::ClosestAbs:
                startnew(CoroutineFunc(SortClosestAbsAsync));
                break;

            case MapOrder::ClosestRel:
                startnew(CoroutineFunc(SortClosestRelAsync));
                break;

            case MapOrder::Random: {
                Map@[] remaining = _maps;
                _maps = { };

                int index;

                while (remaining.Length > 0) {
                    index = Math::Rand(0, remaining.Length);
                    _maps.InsertLast(remaining[index]);
                    remaining.RemoveAt(index);
                }

                break;
            }

            default:;
        }
    }

    void SortClosestAsync(MapOrder order) {  // insertion is terrible, replace this //////////////////////////////////////////////
        if (order != MapOrder::ClosestAbs && order != MapOrder::ClosestRel)
            return;

        while (sorting)
            yield();

        sorting = true;

        const uint64 start = Time::Now;
        trace("sorting " + _maps.Length + " maps (" + tostring(order) + ")...");

        uint64 lastYield = start, now;
        Map@[] sorted;

        for (uint i = 0; i < _maps.Length; i++) {
            if ((now = Time::Now) - lastYield > 50) {
                // trace("\\$Istill sorting... (" + i + "/" + _maps.Length + ")");
                lastYield = now;
                yield();
            }

            Map@ map = _maps[i];

            if (sorted.Length == 0 || !map.driven)
                sorted.InsertLast(@map);

            else {
                for (uint j = 0; j < sorted.Length; j++) {
                    Map@ existing = sorted[j];

                    if (order == MapOrder::ClosestAbs && map.Delta(S_Target) <= existing.Delta(S_Target)) {
                        sorted.InsertAt(j, @map);
                        break;
                    }

                    if (order == MapOrder::ClosestRel) {
                        if (map.DeltaPercent(S_Target) <= existing.DeltaPercent(S_Target)) {
                            sorted.InsertAt(j, @map);
                            break;
                        }
                    }
                }

                if (sorted.FindByRef(map) == -1)
                    sorted.InsertLast(@map);
            }
        }

        trace("sorted " + _maps.Length + " maps (" + tostring(order) + ") after " + (Time::Now - start) + "ms, swapping maps array");
        _maps = sorted;

        sorting = false;
    }

    void SortClosestAbsAsync() {
        SortClosestAsync(MapOrder::ClosestAbs);
    }

    void SortClosestRelAsync() {
        SortClosestAsync(MapOrder::ClosestRel);
    }
}
