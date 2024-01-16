// c 2024-01-02
// m 2024-01-15

#if TMNEXT

enum Mode {
    NadeoCampaign,
    TrackOfTheDay
}

[Setting hidden]
Mode S_Mode = Mode::NadeoCampaign;
Mode lastMode = S_Mode;

#elif MP4

enum Titlepack {
    None = -1,
    Canyon,
    Stadium,
    Valley,
    Lagoon
}

[Setting hidden]
Titlepack S_Titlepack = Titlepack::None;

#endif

enum TargetMedal {
    Author,
    Gold,
    Silver,
    Bronze,
    None
}

[Setting hidden]
TargetMedal S_Target = TargetMedal::Author;

#if TMNEXT

[Setting category="General" name="Notify when starter access is detected"]
bool S_NotifyStarter = true;

[Setting category="General" name="Automatically switch maps when target is reached" description="Always disabled for starter"]
bool S_AutoSwitch = true;

#elif MP4

[Setting category="General" name="Automatically switch maps when target is reached"]
bool S_AutoSwitch = true;

[Setting category="General" name="Select opponent automatically when joining map" description="Only works when loading a map in 'local' mode. I'm not sure how to load it that way consistently, so this won't always work."]
bool S_AutoOpponent = true;

enum OpponentSelection {
    None,
    TargetMedal
}

[Setting category="General" name="Auto-opponent selection"]
OpponentSelection S_OpponentSelection = OpponentSelection::None;

#endif
#if TMNEXT

[Setting category="General" name="Show 'Auto Switch' button" description="Always disabled for starter"]
bool S_MenuAutoSwitch = true;

#elif MP4

[Setting category="General" name="Show 'Auto Switch' button"]
bool S_MenuAutoSwitch = true;

#endif
#if TMNEXT

[Setting category="General" name="Only show the current 25 Nadeo Campaign maps" description="Always enabled for starter"]
bool S_OnlyCurrentCampaign = false;
bool lastOnlyCurrentCampaign = S_OnlyCurrentCampaign;

[Setting category="General" name="Show 'Only Current Campaign' button"]
bool S_MenuOnlyCurrentCampaign = true;

#endif

[Setting category="General" name="Show 'Refresh Records' button"]
bool S_MenuRefresh = true;

[Setting category="General" name="Show a list of all remaining maps"]
bool S_MenuAllMaps = true;

enum NotifyAfterRun {
    Never,
    OnlyAfterPB,
    Always
}

[Setting category="General" name="Notify of time still needed after a run"]
NotifyAfterRun S_NotifyAfterRun = NotifyAfterRun::OnlyAfterPB;


[Setting category="Colors" name="Colored map names"]
bool S_ColorMapNames = false;

[Setting category="Colors" name="'Time still needed' notification" color]
vec3 S_ColorTimeNeeded = vec3(1.0f, 0.1f, 0.5f);

[Setting category="Colors" name="Author medal" color]
vec3 S_ColorMedalAuthor = vec3(0.17f, 0.75f, 0.0f);

[Setting category="Colors" name="Gold medal" color]
vec3 S_ColorMedalGold = vec3(1.0f, 0.97f, 0.0f);

[Setting category="Colors" name="Silver medal" color]
vec3 S_ColorMedalSilver = vec3(0.75f, 0.75f, 0.75f);

[Setting category="Colors" name="Bronze medal" color]
vec3 S_ColorMedalBronze = vec3(0.69f, 0.5f, 0.0f);

[Setting category="Colors" name="No medal" color]
vec3 S_ColorMedalNone = vec3(1.0f, 0.0f, 1.0f);

#if MP4

[Setting category="Colors" name="Canyon" color]
vec3 S_ColorCanyon = vec3(0.8f, 0.5f, 0.1f);

[Setting category="Colors" name="Stadium" color]
vec3 S_ColorStadium = vec3(0.3f, 0.3f, 0.8f);

[Setting category="Colors" name="Valley" color]
vec3 S_ColorValley = vec3(0.1f, 0.8f, 0.1f);

[Setting category="Colors" name="Lagoon" color]
vec3 S_ColorLagoon = vec3(0.1f, 0.8f, 0.8f);

#endif


[Setting category="Debug" name="Show debug window"]
bool S_Debug = false;