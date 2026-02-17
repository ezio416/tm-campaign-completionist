// c 2024-01-01
// m 2025-03-14

dictionary@           allMaps           = dictionary();
Campaign::Campaign@[] campaigns;
UI::Font@             fontHeader;
UI::Font@             fontSubHeader;
bool                  hasPlayPermission = false;
const string          pluginColor       = "\\$0F0";
const string          pluginIcon        = Icons::Check;
Meta::Plugin@         pluginMeta        = Meta::ExecutingPlugin();
const string          pluginTitle       = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
const float           scale             = UI::GetScale();
const float           indentWidth       = scale * 20.0f;
string                script;

void Main() {
    if (!(hasPlayPermission = Permissions::PlayLocalMap())) {
        const string msg = "This plugin requires Club access";
        UI::ShowNotification(PluginTitle(), msg, vec4(1.0f, 0.1f, 0.1f, 0.8f), 15000);
        throw(msg);
    }

    startnew(GetMapsAsync);
    startnew(PBLoop);

    Color::SetAll();

    // IO::FileSource file("src/ML.Script.txt");
    // script = "\n<script><!--\n\n" + file.ReadToEnd() + "\n--></script>\n";
    // MLHook::InjectManialinkToMenu("CampaignCompletionist", script, true);
}

void Render() {
    if (false
        || !hasPlayPermission
        || !S_WindowDetached
        || (S_WindowHideWithGame && !UI::IsGameUIVisible())
        || (S_WindowHideWithOP && !UI::IsOverlayShown())
    )
        return;

    if (UI::Begin(
        PluginTitle() + "###campcomp-main",
        S_WindowDetached,
        UI::WindowFlags::None
    ))
        RenderWindow(Windows::Source::Detached);
    UI::End();
}

void RenderMenu() {
    if (!hasPlayPermission || !UI::BeginMenu(pluginTitle))
        return;

    RenderWindow(Windows::Source::Menu);

    UI::EndMenu();
}

void GetMapsAsync() {
    try {
        campaigns = {};
        allMaps.DeleteAll();

        Http::Nadeo::GetMapsSeasonalAsync();
        Http::Nadeo::GetMapsWeeklyAsync();
        Http::Nadeo::GetMapsTotdAsync();

        string[]@ keys = allMaps.GetKeys();
        Manager::GetMapInfosAsync(keys);
        GetWarriorsAsync(keys);

        // Ordering of PB checking matters
        // Trust Nadeo's servers over anything local
        PB::Load();
        if (!S_Init) {
            Manager::GetPBsAsync(keys);
            Http::Nadeo::GetPBsAsync(keys);
            S_Init = true;
        }
        PB::SaveAll();

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
            Map::Get(uids[i]).timeWarrior = wm;
            total++;
        }
    }

    trace("GetWarriorsAsync " + total + "/" + allMaps.GetSize() + " maps done after " + (Time::Now - start) + "ms");
#endif
}

void GetWarriorsAsync() {
    GetWarriorsAsync(allMaps.GetKeys());
}

void PBLoop() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    while (true) {
        sleep(500);

        if (App.RootMap is null || App.Editor !is null)
            continue;

        Map::Map@ map = Map::Get(App.RootMap.EdChallengeId);
        if (map is null)
            continue;

        const uint prevPb = map.pb;
        map.GetPBAsync();
        if (prevPb != map.pb) {
            trace("PBLoop " + map.uid + " new pb " + Time::Format(map.pb));
            PB::SaveAll();
        }
    }
}
