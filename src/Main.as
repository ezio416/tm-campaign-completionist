// c 2024-01-01
// m 2024-01-02

CTrackMania@ App;
string audienceCore = "NadeoServices";
string audienceLive = "NadeoLiveServices";
bool loadingMap = false;
Map@[] maps;
dictionary mapsDict;
string title = "\\$FA0" + Icons::CalendarO + "\\$G TOTD Grinder";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Main() {
    @App = cast<CTrackMania@>(GetApp());

    NadeoServices::AddAudience(audienceCore);
    NadeoServices::AddAudience(audienceLive);

    GetTOTDs();
}

void GetTOTDs() {
    while (!NadeoServices::IsAuthenticated(audienceLive))
        yield();

    Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
    while (coro.IsRunning())
        yield();

    Net::HttpRequest@ req = NadeoServices::Get(
        audienceLive,
        NadeoServices::BaseURLLive() + "/api/token/campaign/month?length=999&offset=0"
    );
    req.Start();
    while (!req.Finished())
        yield();

    int code = req.ResponseCode();
    if (code != 200) {
        warn("error getting maps: " + code + "; " + req.Error() + "; " + req.String());
        return;
    }

    Json::Value@ monthList = Json::Parse(req.String())["monthList"];

    for (int i = monthList.Length - 1; i >= 0; i--) {
        Json::Value@ days = monthList[i]["days"];

        for (uint j = 0; j < days.Length; j++) {
            Map@ map = Map(monthList[i]["year"], monthList[i]["month"], days[j]);

            if (map.uid.Length > 0) {
                maps.InsertLast(map);
                mapsDict.Set(map.uid, @map);
            }
        }
    }

    GetMapInfo();
}

class Map {
    uint   authorTime;
    uint   bronzeTime;
    string date;
    string downloadUrl;
    uint   goldTime;
    string id;
    uint   myMedals = 0;
    uint   myTime;
    string nameClean;
    string nameColored;
    string nameRaw;
    uint   silverTime;
    string uid;

    Map() { }
    Map(int year, int month, Json::Value@ day) {
        date = year + "-" + ZPad2(month) + "-" + ZPad2(day["monthDay"]);
        uid = day["mapUid"];
    }
}

string ZPad2(int num) {
    return num < 10 ? "0" + num : tostring(num);
}

void GetMapInfo() {
    while (!NadeoServices::IsAuthenticated(audienceCore))
        yield();

    uint index = 0;
    string url;

    while (index < maps.Length - 1) {
        url = NadeoServices::BaseURLCore() + "/maps/?mapUidList=";

        for (uint i = index; i < maps.Length; i++) {
            index = i;

            if (url.Length < 8192)
                url += maps[i].uid + ",";
            else
                break;
        }

        Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
        while (coro.IsRunning())
            yield();

        print("getting map info (" + (index + 1) + "/" + maps.Length + ")");

        Net::HttpRequest@ req = NadeoServices::Get(audienceCore, url);
        req.Start();
        while (!req.Finished())
            yield();

        int code = req.ResponseCode();
        if (code != 200) {
            warn("error getting map info: " + code + "; " + req.Error() + "; " + req.String());
            return;
        }

        Json::Value@ json = Json::Parse(req.String());
        for (uint i = 0; i < json.Length; i++) {
            Map@ map = cast<Map@>(mapsDict[json[i]["mapUid"]]);

            map.authorTime  = json[i]["authorScore"];
            map.bronzeTime  = json[i]["bronzeScore"];
            map.downloadUrl = json[i]["fileUrl"];
            map.goldTime    = json[i]["goldScore"];
            map.id          = json[i]["mapId"];
            map.nameRaw     = json[i]["name"];
            map.silverTime  = json[i]["silverScore"];

            map.nameClean = StripFormatCodes(map.nameRaw);
            map.nameColored = ColoredString(map.nameRaw);

            // print(map.nameColored + ": \\$G" + Time::Format(map.authorTime));
        }
    }

    for (uint i = 0; i < maps.Length; i++) {
    // string[]@ keys = mapsDict.GetKeys();
    // for (uint i = 0; i < keys.Length; i++) {
        Map@ map = maps[i];
        // Map@ map = cast<Map@>(mapsDict[keys[i]]);
        print(map.date + " " + map.nameColored + "\\$G: " + Time::Format(map.authorTime));
    }
}

uint64 latestNandoRequest = 0;

void NandoRequestWait() {
    if (latestNandoRequest == 0) {
        latestNandoRequest = Time::Now;
        return;
    }

    while (Time::Now - latestNandoRequest < 1000)
        yield();

    latestNandoRequest = Time::Now;
}

// courtesy of "Play Map" plugin - https://github.com/XertroV/tm-play-map
// void PlayNext() {
//     if (nextUrl == "") {
//         Meta::PluginCoroutine@ urlCoro = startnew(GetMapInfoCoro);
//         while (urlCoro.IsRunning())
//             yield();

//         gettingMapInfo = false;

//         if (downloadUrl == "") {
//             warn("can't play: blank url for " + nextDate);
//             return;
//         }
//     }

//     if (loadingMap)
//         return;

//     loadingMap = true;

//     trace("loading TOTD for " + nextDate + " for playing");

//     if (!Permissions::PlayLocalMap()) {
//         warn("paid access required - can't load map for " + nextDate);
//         loadingMap = false;
//         return;
//     }

//     ReturnToMenu();

//     App.ManiaTitleControlScriptAPI.PlayMap(nextUrl, "TrackMania/TM_PlayMap_Local", "");

//     const uint64 waitToPlayAgain = 5000;
//     const uint64 now = Time::Now;
//     while (Time::Now - now < waitToPlayAgain)
//         yield();

//     loadingMap = false;
// }

// courtesy of "BetterTOTD" plugin - https://github.com/XertroV/tm-better-totd
// void ReturnToMenu() {
//     if (App.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed)
//         App.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit);

//     App.BackToMainMenu();

//     while (!App.ManiaTitleControlScriptAPI.IsReady)
//         yield();
// }