// c 2024-10-30
// m 2024-10-30

Queue queue;

class Queue {
    private Map@[] _maps;
    private Map@   _next;

    uint get_Length() {
        return _maps.Length;
    }

    Map@ get_next() {
        if (Length == 0)
            return null;

        return _maps[0];
    }

    Map@ get_opIndex(int idx) {
        return _maps[idx];
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
                // && map.series == S_Series & map.series
            )
                _maps.InsertLast(@map);
        }

        Sort();
    }

    void Sort() {
        if (S_Order == MapOrder::Normal)
            return;

        if (S_Order == MapOrder::Reverse)
            _maps.Reverse();
    }
}
