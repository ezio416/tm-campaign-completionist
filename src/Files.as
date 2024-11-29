// c 2024-11-09
// m 2024-11-28

Map@[] mapsFromFile;

namespace Files {
    const string mapFile = IO::FromStorageFolder("maps.json");

    void LoadMaps() {
        const uint64 start = Time::Now;
        trace("loading maps from file...");

        mapsFromFile = { };

        Json::Value@ file;
        try {
            @file = Json::FromFile(mapFile);
        } catch {
            error("error loading maps from file after " + (Time::Now - start) + "ms: " + getExceptionInfo());
            return;
        }

        if (JsonExt::CheckType(file, Json::Type::Array)) {
            for (uint i = 0; i < file.Length; i++) {
                Map@ map = Map(file[i], true);
                mapsFromFile.InsertLast(@map);
            }

            for (uint i = 0; i < mapsFromFile.Length; i++) {
                Map@ map = mapsFromFile[i];
                accounts.Add(map.authorId);

                if (maps.Exists(map.uid)) {
                    Map@ existing = cast<Map@>(maps[map.uid]);

                    if (existing !is null)
                        existing.UpdateDetails(map);
                }
            }
        }

        trace("loaded " + mapsFromFile.Length + " maps from file after " + (Time::Now - start) + "ms");
    }

    void SaveMaps() {
        const uint64 start = Time::Now;
        trace("saving maps to file...");

        Json::Value@ j = Json::Array();

        for (uint i = 0; i < mapsArr.Length; i++)
            j.Add(mapsArr[i].ToJson());

        try {
            Json::ToFile(mapFile, j, true);
            trace("saved " + mapsArr.Length + " maps to file after " + (Time::Now - start) + "ms");
        } catch {
            error("error saving maps to file after " + (Time::Now - start) + "ms: " + getExceptionInfo());
        }
    }
}
