// c 2024-01-02
// m 2024-11-28

bool Driven(uint time) {
    return time != uint(-1) && time != 0;
}

float GayHue(uint cycleTimeMs = 5000, float offset = 0.0f, bool reverse = false) {
    const float h = float(Time::Now % cycleTimeMs) / float(cycleTimeMs) + offset;
    const float normal = h - Math::Floor(h);

    if (reverse)
        return 1.0f - normal;

    return normal;
}

void GetAllPBsAsync() {
    for (uint i = 0; i < mapsArr.Length; i++) {
        Map@ map = mapsArr[i];

        const uint pre = map.pb;
        map.GetPBFromManagerAsync();

        if (pre != map.pb)
            Files::SaveMaps();
    }
}

// void GetAllPBsAsync() {
    // const uint64 start = Time::Now;
    // trace("getting all PBs");

    // trace("getting PBs for campaign maps (" + mapsCampaign.Length + ")");
    // GetAllPBsForMapSet(@mapsCampaign);

    // trace("getting PBs for TOTD maps (" + mapsTotd.Length + ")");
    // GetAllPBsForMapSet(@mapsTotd);

    // trace("getting all PBs done after " + (Time::Now - start) + "ms");

    // gettingNow = false;
// }

// void GetAllPBsForMapSet(Map@[]@ maps) {
    // uint64 lastYield = Time::Now;
    // const uint64 maxFrameTime = 50;

    // for (uint i = 0; i < maps.Length; i++) {
    //     Map@ map = maps[i];

    //     if (map is null)
    //         continue;

    //     map.GetPB();

    //     const uint64 now = Time::Now;
    //     if (now - lastYield > maxFrameTime) {
    //         lastYield = now;
    //         yield();
    //     }
    // }
// }

// void HoverTooltip(const string &in msg) {
    // if (!UI::IsItemHovered())
    //     return;

    // UI::BeginTooltip();
    //     UI::Text(msg);
    // UI::EndTooltip();
// }

// void Notify() {
    // switch (S_Target) {
    //     case TargetMedal::Author: NotifyAuthor(); break;
    //     case TargetMedal::Gold:   NotifyGold();   break;
    //     case TargetMedal::Silver: NotifySilver(); break;
    //     case TargetMedal::Bronze: NotifyBronze(); break;
    //     default:                  NotifyNone();
    // }
// }

// void NotifyAuthor() {
    // UI::ShowNotification(title, "Author achieved!" + (S_AutoSwitch ? " Switching map..." : ""), vec4(S_ColorMedalAuthor.x, S_ColorMedalAuthor.y, S_ColorMedalAuthor.z, 0.8f));
// }

// void NotifyGold() {
    // UI::ShowNotification(title, "Gold achieved!" + (S_AutoSwitch ? " Switching map..." : ""), vec4(S_ColorMedalGold.x, S_ColorMedalGold.y, S_ColorMedalGold.z, 0.8f));
// }

// void NotifySilver() {
    // UI::ShowNotification(title, "Silver achieved!" + (S_AutoSwitch ? " Switching map..." : ""), vec4(S_ColorMedalSilver.x, S_ColorMedalSilver.y, S_ColorMedalSilver.z, 0.8f));
// }

// void NotifyBronze() {
    // UI::ShowNotification(title, "Bronze achieved!" + (S_AutoSwitch ? " Switching map..." : ""), vec4(S_ColorMedalBronze.x, S_ColorMedalBronze.y, S_ColorMedalBronze.z, 0.8f));
// }

// void NotifyNone() {
    // UI::ShowNotification(title, "Map finished!" + (S_AutoSwitch ? " Switching map..." : ""), vec4(S_ColorMedalNone.x, S_ColorMedalNone.y, S_ColorMedalNone.z, 0.8f));
// }

// void NotifyTimeNeeded(bool pb) {
    // if (
    //     S_NotifyAfterRun == NotifyAfterRun::Never ||
    //     (S_NotifyAfterRun == NotifyAfterRun::OnlyAfterPB && !pb)
    // )
    //     return;

    // int target = 0;

    // switch (S_Target) {
    //     case TargetMedal::Author: target = nextMap.authorTime; break;
    //     case TargetMedal::Gold:   target = nextMap.goldTime;   break;
    //     case TargetMedal::Silver: target = nextMap.silverTime; break;
    //     case TargetMedal::Bronze: target = nextMap.bronzeTime; break;
    //     default:;
    // }

    // const string text = (pb ? "Better, but y" : "Not fast enough! Y") + "ou still need " + Time::Format(int(nextMap.myTime) - target) + " for " + tostring(S_Target);
    // trace(text);
    // UI::ShowNotification(title, text, vec4(S_ColorTimeNeeded.x, S_ColorTimeNeeded.y, S_ColorTimeNeeded.z, 0.8f));
// }

// courtesy of "BetterTOTD" plugin - https://github.com/XertroV/tm-better-totd
void ReturnToMenu() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed)
        App.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit);

    App.BackToMainMenu();

    while (!App.ManiaTitleControlScriptAPI.IsReady)
        yield();
}

// string SeriesColor(Series s) {
    // switch (s) {
    //     case Series::White: return Text::FormatOpenplanetColor(S_ColorSeriesWhite);
    //     case Series::Green: return Text::FormatOpenplanetColor(S_ColorSeriesGreen);
    //     case Series::Blue:  return Text::FormatOpenplanetColor(S_ColorSeriesBlue);
    //     case Series::Red:   return Text::FormatOpenplanetColor(S_ColorSeriesRed);
    //     case Series::Black: return Text::FormatOpenplanetColor(S_ColorSeriesBlack);
    //     default: return "";
    // }
// }

// string TimeFormatColored(uint u, bool format = true) {
    // if (u > 0)
    //     return "\\$0F0" + (format ? Time::Format(u) : tostring(u));

    // return "\\$G0" + (format ? ":00.000" : "");
// }

// bool Undriven(uint pb) {
//     return pb == 0 || pb == uint(-1);
// }

string ZPad2(int num) {
    return (num < 10 ? "0" : "") + num;
}

string ZPad4(int num) {
    return (num < 10 ? "000" : num < 100 ? "00" : num < 1000 ? "0" : "") + num;
}
