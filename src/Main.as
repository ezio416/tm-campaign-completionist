// c 2024-01-01
// m 2025-03-11

dictionary@   allMaps           = dictionary();
Campaign@[]   campaigns;
bool          hasPlayPermission = false;
bool          init              = false;
const string  pluginColor       = "\\$0F0";
const string  pluginIcon        = Icons::Check;
Meta::Plugin@ pluginMeta        = Meta::ExecutingPlugin();
const string  pluginTitle       = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
const float   scale             = UI::GetScale();

void Main() {
    if (Permissions::PlayLocalMap())
        hasPlayPermission = true;
    else {
        warn("Paid access required to play maps");

        if (S_NotifyStarter)
            UI::ShowNotification(
                pluginTitle,
                "Paid access is required to play maps, but you can still track your progress on"
                " the first 10 maps of current Nadeo Campaign and the current Weekly Shorts",
                vec4(1.0f, 0.1f, 0.1f, 0.8f)
            );
    }

    startnew(GetMapsAsync);
    startnew(PBLoop);
}

void Render() {
    if (false
        || !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    if (UI::Begin(PluginTitle() + "###campcomp-main", S_Enabled, UI::WindowFlags::None))
        RenderWindow();
    UI::End();
}

void RenderMenu() {
    if (UI::MenuItem(pluginTitle, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void GetMapsAsync() {
    try {
        campaigns = {};
        allMaps.DeleteAll();

        API::Nadeo::GetMapsSeasonalAsync();
        API::Nadeo::GetMapsWeeklyAsync();
        API::Nadeo::GetMapsTotdAsync();

        string[]@ keys = allMaps.GetKeys();
        Manager::GetMapInfosAsync(keys);
        GetWarriorsAsync(keys);

        // Ordering of PB checking matters
        // Trust Nadeo's servers over anything local
        Files::LoadPBs();
        if (!S_Init) {
            Manager::GetPBsAsync(keys);
            API::Nadeo::GetPBsAsync(keys);
            S_Init = true;
        }
        Files::SavePBs();

    } catch {
        const string info = "GetMapsAsync " + getExceptionInfo();
        error(info);
        UI::ShowNotification(
            PluginTitle(),
            info,
            vec4(1.0f, 0.2f, 0.0f, 1.0f),
            10000
        );
    }
}

void GetWarriorsAsync(string[]@ uids) {
#if DEPENDENCY_WARRIORMEDALS
    const uint64 start = Time::Now;
    trace("GetWarriorsAsync");

    uint total = 0;

    const dictionary@ warMaps = WarriorMedals::GetMaps();
    while (warMaps is null || warMaps.GetSize() == 0)
        yield();  // unlikely since GetMapInfosAsync takes so long

    uint wm;
    for (uint i = 0; i < uids.Length; i++) {
        if (Driven((wm = WarriorMedals::GetWMTime(uids[i])))) {
            GetMap(uids[i]).timeWarrior = wm;
            total++;
        }
    }

    trace("GetWarriorsAsync " + total + "/" + allMaps.GetSize() + " maps after " + (Time::Now - start) + "ms");
#endif
}

void PBLoop() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    while (true) {
        sleep(500);

        if (App.RootMap is null || App.Editor !is null)
            continue;

        Map@ map = GetMap(App.RootMap.EdChallengeId);
        if (map is null)
            continue;

        const uint prevPb = map.pb;
        map.GetPBAsync();
        if (prevPb != map.pb) {
            trace("PBLoop " + map.uid + " new pb " + Time::Format(map.pb));
            Files::SavePBs();
        }
    }
}
