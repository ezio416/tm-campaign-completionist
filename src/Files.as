// c 2024-10-22
// m 2025-03-11

Json::Value@ pbs = Json::Object();

namespace Files {
    bool         loaded  = false;
    const string pbsPath = IO::FromStorageFolder("pbs.json").Replace("\\", "/");

    void AddPB(const string &in uid, uint pb) {
        if (pb == uint(-1) || pb == 0)
            return;

        // print("F:AddPB " + uid + " " + pb);
        pbs[uid] = pb;
    }

    void AddPB(Map@ map) {
        if (map is null)
            return;

        AddPB(map.uid, map.pb);
    }

    uint GetPB(const string &in uid) {
        if (pbs.HasKey(uid))
            return JsonExt::GetUint(pbs, uid);

        return uint(-1);
    }

    void LoadPBs() {
        const uint64 start = Time::Now;
        trace("F:LoadPBs");

        if (!IO::FileExists(pbsPath)) {
            warn("F:LoadPBs not found");
            @pbs = Json::Object();
            loaded = true;
            return;
        }

        try {
            @pbs = Json::FromFile(pbsPath);
        } catch {
            error("F:LoadPBs failed: " + getExceptionInfo());
            @pbs = Json::Object();
        }

        if (!JsonExt::CheckType(pbs)) {
            error("F:LoadPBs wrong type");
            @pbs = Json::Object();
        }

        uint missing = 0;
        string[]@ uids = pbs.GetKeys();
        string uid;

        for (uint i = 0; i < uids.Length; i++) {
            uid = uids[i];
            if (!allMaps.Exists(uid)) {
                warn("F:LoadPBs missing key in maps: " + uid);
                missing++;
                continue;
            }

            Map@ map = GetMap(uid);
            if (map is null) {
                warn("F:LoadPBs map is null: " + uid);
                continue;
            }

            const uint score = JsonExt::GetUint(pbs, uid);
            if (Driven(score))
                map.pb = score;
        }

        loaded = true;
        trace("F:LoadPBs " + pbs.Length + (missing > 0 ? " (" + missing + " missing)" : "") + " done after " + (Time::Now - start) + "ms");
    }

    void SavePB(const string &in uid, uint pb) {
        AddPB(uid, pb);
        SavePBs();
    }

    void SavePB(Map@ map) {
        if (map is null)
            return;

        SavePB(map.uid, map.pb);
    }

    void SavePB(const string &in uid) {
        SavePB(GetMap(uid));
    }

    void SavePBs() {
        if (!loaded)
            return;

        const uint64 start = Time::Now;
        trace("F:SavePBs " + pbs.Length);

        try {
            Json::ToFile(pbsPath, pbs, true);
            trace("F:SavePBs " + pbs.Length + " done after " + (Time::Now - start) + "ms");
        } catch {
            error("F:SavePBs " + pbs.Length + " failed after " + (Time::Now - start) + "ms: " + getExceptionInfo());
        }
    }

    void SavePBsWaitForInitAsync() {
        while (!init)
            yield();

        SavePBs();
    }
}
