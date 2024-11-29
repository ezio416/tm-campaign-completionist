// c 2024-10-30
// m 2024-11-28

Queue queue;

class Queue {
    private Map@[] _maps;

    Mode        generatedMode   = Mode::Unknown;
    MapOrder    generatedOrder  = MapOrder::Normal;
    // Season   generatedSeason = Season::Unknown;
    int         generatedSeries = -1;
    TargetMedal generatedTarget = TargetMedal::None;

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
                && !map.MetTarget(S_Target)
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

    void Sort() {
        if (S_Order == MapOrder::Normal)
            return;

        if (S_Order == MapOrder::Reverse)
            _maps.Reverse();

        if (S_Order == MapOrder::ClosestAbs) {
            ;
        }

        if (S_Order == MapOrder::ClosestRel) {
            ;
        }

        if (S_Order == MapOrder::Random) {
            Map@[] remaining = _maps;

            _maps = { };
            int index = -1;

            while (remaining.Length > 0) {
                index = Math::Rand(0, remaining.Length);
                _maps.InsertLast(remaining[index]);
                remaining.RemoveAt(index);
            }
        }
    }
}
