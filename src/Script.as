// c 2025-03-12
// m 2025-03-16

namespace Script {
    void PlayCampaignAsync(Campaign::Campaign@ campaign) {
        if (campaign is null || campaign.maps.GetSize() == 0)
            return;

        Map::Map@[] needsInfo;
        string[]    urls;

        string[]@ uids = campaign.maps.GetKeys();
        for (uint i = 0; i < uids.Length; i++) {
            Map::Map@ map = cast<Map::Map@>(campaign.maps[uids[i]]);

            if (map !is null && map.url.Length == 0)
                needsInfo.InsertLast(map);
        }

        Manager::GetMapInfosAsync(needsInfo);

        for (uint i = 0; i < uids.Length; i++) {
            Map::Map@ map = cast<Map::Map@>(campaign.maps[uids[i]]);
            if (map is null)
                continue;

            if (map.url.Length == 0) {
                warn("PlayCampaignAsync blank url at index " + i);
                continue;
            }

            urls.InsertLast(map.url);
        }

        PlayMapListAsync(urls, campaign.id, campaign.name);
    }

    void PlayMapAsync(const string &in url, const string &in name = "") {
        if (!hasPlayPermission || url.Length == 0)
            return;

        trace("S:PlayMapAsync " + url);

#if DEPENDENCY_MLHOOK
        if (Meta::GetPluginFromID("MLHook").Enabled) {
            print(name);
            if (name.Length > 0)
                MLHook::Queue_Menu_SendCustomEvent(
                    "Event_UpdateLoadingScreen",
                    { "$0F0$I$N$S" + PluginName() + " - $G$I$M$S" + name }
                );

            MLHook::Queue_Menu_SendCustomEvent(
                "CampComp.PlayMap",
                { url }
            );
        }
#endif

        // ReturnToMenu();

        // MLHook::InjectManialinkToMenu("CampComp", script, true);
        // MLHook::InjectManialinkToPlayground("CampComp", script, true);

        // WaitIsReadyAsync();
        // cast<CTrackMania@>(GetApp()).ManiaTitleControlScriptAPI.PlayMap(
        //     url,
        //     "TrackMania/TM_PlayMap_Local",
        //     ""
        // );
        // WaitIsReadyAsync();
    }

    void PlayMapListAsync(MwFastBuffer<wstring> urls, int id, const string &in name = "") {
        if (id < 1) {
            error("S:PlayMapListAsync bad id");
            return;
        }

#if !DEPENDENCY_MLHOOK
        error("S:PlayMapListAsync MLHook is required to load campaigns");
        return;
#endif

        if (!Meta::GetPluginFromID("MLHook").Enabled) {
            error("S:PlayMapListAsync MLHook is disabled");
            return;
        }

        if (!hasPlayPermission || urls.Length == 0)
            return;

        trace("S:PlayMapListAsync " + urls.Length + " maps");

        for (uint i = 0; i < urls.Length; i++) {
            if (urls[i].Length == 0)
                warn("url at index " + i + " is blank");
        }

        // -1 none
        // 0  quarterly
        // 1  monthly
        // 2  club
        // 3  royal
        // 5  weekly
        const int type = 0;

        const string settings =
            "<root>"
                "<setting name=\"S_CampaignId\" value=\"" + id + "\" type=\"integer\"/>"
                "<setting name=\"S_CampaignType\" value=\"" + type + "\" type=\"integer\"/>"
                "<setting name=\"S_CampaignIsLive\" value=\"0\" type=\"boolean\"/>"
            "</root>"
        ;
        print(settings);

        if (name.Length > 0)
            MLHook::Queue_Menu_SendCustomEvent(
                "Event_UpdateLoadingScreen",
                { "$0F0$I$N$S" + PluginName() + " - $G$I$M$S" + name }
            );

        ReturnToMenu();

        MLHook::Queue_Menu_SendCustomEvent("TMNext_CampaignStore_Action_LoadCampaign", { tostring(id) });

        WaitIsReadyAsync();
        cast<CTrackMania@>(GetApp()).ManiaTitleControlScriptAPI.PlayMapList(
            urls,
            "TrackMania/TM_Campaign_Local",
            settings
        );
        WaitIsReadyAsync();
    }

    void PlayMapListAsync(string[]@ urls, int id, const string &in name = "") {
        if (urls.Length == 0)
            return;

        MwFastBuffer<wstring> _urls;

        for (uint i = 0; i < urls.Length; i++)
            _urls.Add(wstring(urls[i]));

        PlayMapListAsync(_urls, id, name);
    }

    void ReturnToMenu() {
        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        if (App.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed)
            App.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(
                CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit
            );

        App.BackToMainMenu();
    }

    void WaitIsReadyAsync() {
        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        while (!App.ManiaTitleControlScriptAPI.IsReady)
            yield();
    }
}

namespace ML {
    string BuildSimple(string[]@ includes, string[]@ code) {
        if (false
            || includes is null
            || code is null
            || code.Length == 0
        )
            return "";

        string ml = "<script><!--\n\n";

        if (includes !is null && includes.Length > 0) {
            for (uint i = 0; i < includes.Length; i++)
                ml += " " + includes[i] + "\n";
        }

        ml += "\nmain() {\n";

        for (uint i = 0; i < code.Length; i++)
            ml += "    " + code[i] + "\n";

        return ml + "}\n\n--></script>";
    }
}
