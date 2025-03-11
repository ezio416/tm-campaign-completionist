// c 2024-01-02
// m 2025-03-10

enum MapSeries {
    White,
    Green,
    Blue,
    Red,
    Black,
    Unknown
}

class Map {
    Campaign@        campaign;
    string           id;
    int              monthDay   = -1;
    FormattedString@ name;
    uint             pb         = uint(-1);
    int              position   = -1;
    MapSeries        series     = MapSeries::Unknown;
    uint             timeAuthor = uint(-1);
    uint             timeBronze = uint(-1);
    uint             timeGold   = uint(-1);
    uint             timeSilver = uint(-1);
    string           uid;
    string           url;
    int              weekDay    = -1;

    bool             gettingInfo = false;
    bool             loading     = false;

    string get_date() {
        if (campaign is null || campaign.type != CampaignType::Totd)
            return "";

        return campaign.name.stripped + "-" + monthDay;
    }

    Map(Json::Value@ json) {
        if (!JsonExt::CheckType(json))
            throw("bad map: " + Json::Write(json));

        uid = JsonExt::GetString(json, "mapUid");

        if (json.HasKey("day")) {  // totd
            weekDay = JsonExt::GetInt(json, "day");
            monthDay = JsonExt::GetInt(json, "monthDay");
        } else {  // seasonal/weekly
            position = JsonExt::GetInt(json, "position");
        }
    }

    void GetInfoAsync() {
        if (gettingInfo)
            return;

        gettingInfo = true;

        const uint64 start = Time::Now;
        trace("getting info for '" + uid + "'");

        try {
            if (uid.Length != 26 && uid.Length != 27)
                throw("bad uid: '" + uid + "'");

            CGameManiaAppTitle@ Title = cast<CTrackMania@>(GetApp()).MenuManager.MenuCustom_CurrentManiaApp;

            CWebServicesTaskResult_NadeoServicesMapScript@ task = Title.DataFileMgr.Map_NadeoServices_GetFromUid(
                Title.UserMgr.Users[0].Id,
                uid
            );
            while (task.IsProcessing)
                yield();

            if (task.HasFailed || !task.HasSucceeded || task.Map is null) {
                if (Title !is null && Title.DataFileMgr !is null)
                    Title.DataFileMgr.TaskResult_Release(task.Id);

                throw("task failed: '" + uid + "'");
            }

            @name      = FormattedString(task.Map.Name);
            timeAuthor = task.Map.AuthorScore;
            timeGold   = task.Map.GoldScore;
            timeSilver = task.Map.SilverScore;
            timeBronze = task.Map.BronzeScore;
            url        = task.Map.FileUrl;

            trace("got info for '" + uid + "' (" + name.stripped + ") after " + (Time::Now - start) + "ms");

            if (Title !is null && Title.DataFileMgr !is null)
                Title.DataFileMgr.TaskResult_Release(task.Id);

        } catch {
            warn("GetInfoAsync failed on '" + uid + "' after " + (Time::Now - start) + "ms: " + getExceptionInfo());
        }

        gettingInfo = false;
    }

    void PlayAsync() {
        if (!hasPlayPermission || loading)
            return;

        if (url.Length == 0) {
            GetInfoAsync();

            if (url.Length == 0) {
                warn("can't play " + name.stripped + ": blank url");
                return;
            }
        }

        loading = true;
        trace("loading " + name.stripped);

#if DEPENDENCY_MLHOOK
    if (Meta::GetPluginFromID("MLHook").Enabled)
        MLHook::Queue_Menu_SendCustomEvent(
            "Event_UpdateLoadingScreen",
            {"$0F0$I$N$SCampaign Completionist - $G$I$M$S" + name.raw}
        );
#endif

        ReturnToMenuAsync();

        CTrackMania@ App = cast<CTrackMania@>(GetApp());
        App.ManiaTitleControlScriptAPI.PlayMap(url, "TrackMania/TM_PlayMap_Local", "");

        sleep(5000);

        loading = false;
    }
}

void AddMap(Map@ map) {
    if (!allMaps.Exists(map.uid))
        allMaps.Set(map.uid, @map);
    else
        warn("duplicate uid: " + map.uid);
}

void GetInfosAsync() {
    const uint64 start = Time::Now;
    trace("getting info for " + allMaps.GetSize() + " maps");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    try {
        MwFastBuffer<wstring> MapUidList;
        string[]@ uids = allMaps.GetKeys();
        if (uids.Length == 0)
            throw("no maps");
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
            Map@ map = cast<Map@>(allMaps[reqMap.Uid]);

            map.timeAuthor = reqMap.AuthorScore;
            map.timeGold   = reqMap.GoldScore;
            map.timeSilver = reqMap.SilverScore;
            map.timeBronze = reqMap.BronzeScore;
            @map.name      = FormattedString(reqMap.Name);
        }

        trace("got info for " + task.MapList.Length + " maps after " + (Time::Now - start) + "ms");

        if (Title !is null && Title.DataFileMgr !is null)
            Title.DataFileMgr.TaskResult_Release(task.Id);

    } catch {
        warn("GetInfosAsync failed after " + (Time::Now - start) + "ms: " + getExceptionInfo());
    }
}

void ReturnToMenuAsync() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed)
        App.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(
            CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit
        );

    App.BackToMainMenu();

    while (!App.ManiaTitleControlScriptAPI.IsReady)
        yield();
}
