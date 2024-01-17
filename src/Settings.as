// c 2024-01-02
// m 2024-01-16

enum Mode {
    NadeoCampaign,
    TrackOfTheDay
}

enum TargetMedal {
    Author,
    Gold,
    Silver,
    Bronze,
    None
}


[Setting hidden]
Mode S_Mode = Mode::NadeoCampaign;
Mode lastMode = S_Mode;

[Setting hidden]
TargetMedal S_Target = TargetMedal::Author;


[Setting category="General" name="Notify when Starter Access is detected"]
bool S_NotifyStarter = true;

[Setting category="General" name="Automatically switch maps when target is reached" description="Always disabled for Starter"]
bool S_AutoSwitch = true;

[Setting category="General" name="Show 'Auto Switch' button" description="Always disabled for Starter"]
bool S_MenuAutoSwitch = true;

[Setting category="General" name="Only show the current 25 Nadeo Campaign maps" description="Always enabled for Starter (only first 10 maps)"]
bool S_OnlyCurrentCampaign = false;
bool lastOnlyCurrentCampaign = S_OnlyCurrentCampaign;

[Setting category="General" name="Show 'Only Current Campaign' button" description="Always disabled for Starter"]
bool S_MenuOnlyCurrentCampaign = true;

[Setting category="General" name="Show 'Refresh Records' button"]
bool S_MenuRefresh = true;

[Setting category="General" name="Show a list of all remaining maps"]
bool S_MenuAllMaps = true;

[Setting category="General" name="Show time still needed for target"]
bool S_MenuTargetDelta = false;

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
string colorMedalAuthor;

[Setting category="Colors" name="Gold medal" color]
vec3 S_ColorMedalGold = vec3(1.0f, 0.97f, 0.0f);
string colorMedalGold;

[Setting category="Colors" name="Silver medal" color]
vec3 S_ColorMedalSilver = vec3(0.75f, 0.75f, 0.75f);
string colorMedalSilver;

[Setting category="Colors" name="Bronze medal" color]
vec3 S_ColorMedalBronze = vec3(0.69f, 0.5f, 0.0f);
string colorMedalBronze;

[Setting category="Colors" name="No medal" color]
vec3 S_ColorMedalNone = vec3(1.0f, 0.0f, 1.0f);
string colorMedalNone;

[Setting category="Colors" name="Time needed < 0.1s" color description="For the menu, not the notification"]
vec3 S_ColorDeltaSub01 = vec3(0.0f, 1.0f, 1.0f);
string colorDeltaSub01;

[Setting category="Colors" name="Time needed 0.1-0.5s" color description="For the menu, not the notification"]
vec3 S_ColorDelta01to05 = vec3(0.0f, 1.0f, 0.6f);
string colorDelta01to05;

[Setting category="Colors" name="Time needed 0.5-1s" color description="For the menu, not the notification"]
vec3 S_ColorDelta05to1 = vec3(0.5f, 1.0f, 0.0f);
string colorDelta05to1;

[Setting category="Colors" name="Time needed 1-2s" color description="For the menu, not the notification"]
vec3 S_ColorDelta1to2 = vec3(1.0f, 0.8f, 0.0f);
string colorDelta1to2;

[Setting category="Colors" name="Time needed 2-3s" color description="For the menu, not the notification"]
vec3 S_ColorDelta2to3 = vec3(1.0f, 0.5f, 0.0f);
string colorDelta2to3;

[Setting category="Colors" name="Time needed >= 3s" color description="For the menu, not the notification"]
vec3 S_ColorDeltaAbove3 = vec3(1.0f, 0.0f, 0.0f);
string colorDeltaAbove3;


[Setting category="Debug" name="Show debug window"]
bool S_Debug = false;