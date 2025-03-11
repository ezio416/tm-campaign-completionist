// c 2024-01-01
// m 2025-03-11

dictionary@   allMaps           = dictionary();
Campaign@[]   campaigns;
bool          hasPlayPermission = false;
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
                "Paid access is required to play maps, but you can still track your progress on the current Nadeo Campaign",
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

        Files::LoadPBs();
        if (!S_Init) {
            Manager::GetPBsAsync(keys);
            API::Nadeo::GetPBsAsync(keys);
            S_Init = true;
        }
        Files::SavePBs();

    } catch {
        const string info = getExceptionInfo();
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
        yield();

    uint wm;
    for (uint i = 0; i < uids.Length; i++) {
        if (Driven((wm = WarriorMedals::GetWMTime(uids[i])))) {
            cast<Map@>(allMaps[uids[i]]).timeWarrior = wm;
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

        if (App.RootMap is null || !allMaps.Exists(App.RootMap.EdChallengeId))
            continue;

        Map@ map = cast<Map@>(allMaps[App.RootMap.EdChallengeId]);

        const uint prevPb = map.pb;

        map.GetPBAsync();

        if (prevPb != map.pb) {
            trace("PBLoop " + map.uid + " new pb " + Time::Format(map.pb));
            Files::SavePB(map);
        }
    }
}
