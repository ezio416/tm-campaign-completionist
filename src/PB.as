// c 2024-10-22
// m 2025-03-11

namespace PB {
    bool         loaded = false;
    const string path   = IO::FromStorageFolder("pbs.json").Replace("\\", "/");
    Json::Value@ pbs    = Json::Object();

    void Add(Map@ map) {
        if (map !is null && map.driven)
            pbs[map.uid] = map.pb;
    }

    void Add(const string &in uid) {
        Add(Maps::Get(uid));
    }

    uint Get(const string &in uid) {
        return pbs.HasKey(uid) ? JsonExt::GetUint(pbs, uid) : uint(-1);
    }

    uint Get(Map@ map) {
        return map !is null ? Get(map.uid) : uint(-1);
    }

    void Load() {
        const uint64 start = Time::Now;
        trace("P:Load");

        if (!IO::FileExists(path)) {
            warn("P:Load not found");
            @pbs = Json::Object();
            loaded = true;
            return;
        }

        try {
            @pbs = Json::FromFile(path);
        } catch {
            error("P:Load failed: " + getExceptionInfo());
            @pbs = Json::Object();
        }

        if (!JsonExt::CheckType(pbs)) {
            error("P:Load wrong type");
            @pbs = Json::Object();
        }

        uint missing = 0;
        string[]@ uids = pbs.GetKeys();
        string uid;

        for (uint i = 0; i < uids.Length; i++) {
            uid = uids[i];
            if (!allMaps.Exists(uid)) {
                warn("P:Load missing key in maps: " + uid);
                missing++;
                continue;
            }

            Map@ map = Maps::Get(uid);
            if (map is null) {
                warn("P:Load map is null: " + uid);
                continue;
            }

            const uint score = JsonExt::GetUint(pbs, uid);
            if (Driven(score))
                map.pb = score;
        }

        loaded = true;
        trace("P:Load " + pbs.Length + (missing > 0 ? " (" + missing + " missing)" : "") + " done after " + (Time::Now - start) + "ms");
    }

    void Save(Map@ map) {
        if (map !is null) {
            Add(map);
            SaveAll();
        }
    }

    void Save(const string &in uid) {
        Save(Maps::Get(uid));
    }

    void SaveAll() {
        if (!loaded)
            return;

        const uint64 start = Time::Now;
        trace("P:SaveAll " + pbs.Length);

        try {
            Json::ToFile(path, pbs, true);
            trace("P:SaveAll " + pbs.Length + " done after " + (Time::Now - start) + "ms");
        } catch {
            error("P:SaveAll " + pbs.Length + " failed after " + (Time::Now - start) + "ms: " + getExceptionInfo());
        }
    }
}
