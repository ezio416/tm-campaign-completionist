// c 2024-01-02
// m 2024-01-08

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
bool S_AutoSwitch = true;

[Setting hidden]
Mode S_Mode = Mode::NadeoCampaign;

[Setting hidden]
TargetMedal S_Target = TargetMedal::Author;


[Setting category="General" name="Notify when starter access is detected"]
bool S_NotifyStarter = true;

[Setting category="General" name="Only show the current 25 Nadeo Campaign maps" description="Always true for starter access"]
bool S_OnlyCurrentCampaign = false;

[Setting category="General" name="Show a list of all remaining maps"]
bool S_AllMapsInMenu = false;

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