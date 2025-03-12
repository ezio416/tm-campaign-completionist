// c 2025-03-11
// m 2025-03-11

namespace Manager {
    void GetMapInfoAsync(Map@ map) {
        if (map is null)
            return;

        const uint64 start = Time::Now;
        trace("M:GetMapInfoAsync " + map.uid);

        try {
            if (map.uid.Length != 26 && map.uid.Length != 27)
                throw("bad uid: '" + map.uid + "'");

            CGameManiaAppTitle@ Title = cast<CTrackMania@>(GetApp()).MenuManager.MenuCustom_CurrentManiaApp;

            CWebServicesTaskResult_NadeoServicesMapScript@ task = Title.DataFileMgr.Map_NadeoServices_GetFromUid(
                Title.UserMgr.Users[0].Id,
                map.uid
            );
            while (task.IsProcessing)
                yield();

            if (task.HasFailed || !task.HasSucceeded || task.Map is null) {
                if (Title !is null && Title.DataFileMgr !is null)
                    Title.DataFileMgr.TaskResult_Release(task.Id);

                throw("task failed: '" + map.uid + "'");
            }

            @map.name      = String(task.Map.Name);
            map.timeAuthor = task.Map.AuthorScore;
            map.timeGold   = task.Map.GoldScore;
            map.timeSilver = task.Map.SilverScore;
            map.timeBronze = task.Map.BronzeScore;
            map.url        = task.Map.FileUrl;

            trace("M:GetMapInfoAsync " + map.uid + " (" + map.name + ") done after " + (Time::Now - start) + "ms");

            if (Title !is null && Title.DataFileMgr !is null)
                Title.DataFileMgr.TaskResult_Release(task.Id);

        } catch {
            warn("M:GetMapInfoAsync " + map.uid + " failed after " + (Time::Now - start) + "ms: " + getExceptionInfo());
        }
    }

    void GetMapInfoAsync(const string &in uid) {
        GetMapInfoAsync(Maps::Get(uid));
    }

    void GetMapInfosAsync(string[]@ uids) {
        if (uids is null || uids.Length == 0)
            return;

        const uint64 start = Time::Now;
        trace("M:GetMapInfosAsync " + uids.Length + " maps");

        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        try {
            MwFastBuffer<wstring> MapUidList;
            for (uint i = 0; i < uids.Length; i++)
                MapUidList.Add(wstring(uids[i]));

            CGameManiaAppTitle@ Title = App.MenuManager.MenuCustom_CurrentManiaApp;

            CWebServicesTaskResult_NadeoServicesMapListScript@ task = Title.DataFileMgr.Map_NadeoServices_GetListFromUid(
                Title.UserMgr.Users[0].Id,
                MapUidList
            );
            while (task.IsProcessing)
                yield();

            if (task.HasFailed || !task.HasSucceeded || task.MapList.Length == 0) {
                if (Title !is null && Title.DataFileMgr !is null)
                    Title.DataFileMgr.TaskResult_Release(task.Id);

                throw("task failed");
            }

            // print("\\$0F0got " + task.MapList.Length + " maps");

            for (uint i = 0; i < task.MapList.Length; i++) {
                CNadeoServicesMap@ reqMap = task.MapList[i];
                // print("got map '" + Text::OpenplanetFormatCodes(reqMap.Name) + "'");
                Map@ map = Maps::Get(reqMap.Uid);

                map.timeAuthor = reqMap.AuthorScore;
                map.timeGold   = reqMap.GoldScore;
                map.timeSilver = reqMap.SilverScore;
                map.timeBronze = reqMap.BronzeScore;
                @map.name      = String(reqMap.Name);
            }

            trace("M:GetMapInfosAsync " + task.MapList.Length + " maps after " + (Time::Now - start) + "ms");

            if (Title !is null && Title.DataFileMgr !is null)
                Title.DataFileMgr.TaskResult_Release(task.Id);

        } catch {
            warn("M:GetMapInfosAsync failed after " + (Time::Now - start) + "ms: " + getExceptionInfo());
        }
    }

    void GetMapInfosAsync() {
        GetMapInfosAsync(allMaps.GetKeys());
    }

    void GetPB(Map@ map) {
        if (map is null)
            return;

        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        if (false
            || App.MenuManager is null
            || App.MenuManager.MenuCustom_CurrentManiaApp is null
            || App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr is null
            || App.UserManagerScript is null
            || App.UserManagerScript.Users.Length == 0
            || App.UserManagerScript.Users[0] is null
        ) {
            map.pb = uint(-1);
            return;
        }

        const uint pb = App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr.Map_GetRecord_v2(
            App.UserManagerScript.Users[0].Id,
            map.uid,
            "PersonalBest",
            "",
            "TimeAttack",
            ""
        );
        if (pb != uint(-1))
            map.pb = pb;
    }

    void GetPB(const string &in uid) {
        GetPB(Maps::Get(uid));
    }

    void GetPBAsync(Map@ map) {
        if (map is null)
            return;

        const uint64 start = Time::Now;
        trace("M:GetPBAsync " + map.uid);

        try {
            CTrackMania@ App = cast<CTrackMania@>(GetApp());
            CGameManiaAppTitle@ Title = App.MenuManager.MenuCustom_CurrentManiaApp;

            MwFastBuffer<wstring> wsid;
            wsid.Add(Title.LocalUser.WebServicesUserId);

            CWebServicesTaskResult_MapRecordListScript@ task = Title.ScoreMgr.Map_GetPlayerListRecordList(
                App.UserManagerScript.Users[0].Id,
                wsid,
                map.uid,
                "PersonalBest",
                "",
                "TimeAttack",
                ""
            );
            while (task.IsProcessing)
                yield();

            if (task.HasFailed || !task.HasSucceeded) {
                if (Title !is null && Title.DataFileMgr !is null)
                    Title.DataFileMgr.TaskResult_Release(task.Id);

                throw("task failed: '" + map.uid + "'");
            }

            map.pb = task.MapRecordList.Length > 0 ? task.MapRecordList[0].Time : 0;

            trace("M:GetPBAsync " + map.uid + " (" + map.name + ") done after " + (Time::Now - start) + "ms");

            if (Title !is null && Title.DataFileMgr !is null)
                Title.DataFileMgr.TaskResult_Release(task.Id);

        } catch {
            warn("M:GetPBAsync " + map.uid + " failed after " + (Time::Now - start) + "ms: " + getExceptionInfo());
        }
    }

    void GetPBAsync(const string &in uid) {
        GetPBAsync(Maps::Get(uid));
    }

    void GetPBs(string[]@ uids) {
        if (uids is null || uids.Length == 0)
            return;

        for (uint i = 0; i < uids.Length; i++)
            GetPB(uids[i]);
    }

    void GetPBs() {
        GetPBs(allMaps.GetKeys());
    }

    void GetPBsAsync(string[]@ uids) {
        if (uids is null || uids.Length == 0)
            return;

        const uint64 start = Time::Now;
        trace("M:GetPBsAsync " + uids.Length + " maps");

        for (uint i = 0; i < uids.Length; i++)
            GetPBAsync(uids[i]);

        trace("M:GetPBsAsync " + uids.Length + " maps done after " + (Time::Now - start) + "ms");
    }

    void GetPBsAsync() {
        GetPBsAsync(allMaps.GetKeys());
    }
}
