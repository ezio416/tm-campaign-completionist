// c 2024-01-02
// m 2024-01-03

#if TMNEXT || MP4

[Setting hidden]
bool S_AutoSwitch = true;

#endif
#if TMNEXT

enum Mode {
    NadeoCampaign,
    TrackOfTheDay
}

[Setting hidden]
Mode S_Mode = Mode::NadeoCampaign;

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

#if TURBO

    SuperTrackmaster,
    SuperGold,
    SuperSilver,
    SuperBronze,
    Trackmaster,

#else

    Author,

#endif

    Gold,
    Silver,
    Bronze,
    None
}

[Setting hidden]

#if TURBO

TargetMedal S_Target = TargetMedal::Trackmaster;

#else

TargetMedal S_Target = TargetMedal::Author;

#endif

[Setting category="General" name="Show a list of all remaining maps"]
bool S_AllMapsInMenu = false;

#if MP4

[Setting category="General" name="Select opponent automatically when joining map" description="Only works when loading a map in 'local' mode. I'm not sure how to load it that way consistently, so this won't always work."]
bool S_AutoOpponent = true;

enum OpponentSelection {
    None,
    TargetMedal
}

[Setting category="General" name="Auto-opponent selection"]
OpponentSelection S_OpponentSelection = OpponentSelection::None;

#endif
#if MP4 || TURBO

[Setting category="General" name="Show debug window"]
bool S_Debug = false;

#elif TMNEXT

[Setting category="Colors" name="Colored map name"]
bool S_ColorMapName = false;

#endif
#if TURBO

[Setting category="Colors" name="Super Trackmaster medal" color]
vec3 S_ColorMedalSuperTrackmaster = vec3(0.0f, 1.0f, 1.0f);

[Setting category="Colors" name="Super Gold medal" color]
vec3 S_ColorMedalSuperGold = vec3(1.0f, 0.97f, 0.0f);

[Setting category="Colors" name="Super Silver medal" color]
vec3 S_ColorMedalSuperSilver = vec3(0.75f, 0.75f, 0.75f);

[Setting category="Colors" name="Super Bronze medal" color]
vec3 S_ColorMedalSuperBronze = vec3(0.69f, 0.5f, 0.0f);

[Setting category="Colors" name="Trackmaster medal" color]
vec3 S_ColorMedalTrackmaster = vec3(0.17f, 0.75f, 0.0f);

#else

[Setting category="Colors" name="Author medal" color]
vec3 S_ColorMedalAuthor = vec3(0.17f, 0.75f, 0.0f);

#endif

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