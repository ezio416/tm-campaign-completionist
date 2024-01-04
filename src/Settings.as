// c 2024-01-02
// m 2024-01-03

enum Mode {
#if TMNEXT
    NadeoCampaign,
    TrackOfTheDay,
#elif MP4
    None,
    Canyon,
    Stadium,
    Valley,
    Lagoon
#endif
}

enum TargetMedal {
    Author,
    Gold,
    Silver,
    Bronze,
    None
}


[Setting hidden]
bool S_Enabled = true;

[Setting hidden]
#if TMNEXT
Mode S_Mode = Mode::NadeoCampaign;
#elif MP4
Mode S_Mode = Mode::None;
#endif

[Setting hidden]
TargetMedal S_Target = TargetMedal::Author;


[Setting category="General" name="Show a list of all remaining maps"]
bool S_AllMapsInMenu = false;


[Setting category="Colors" name="Colored map name"]
bool S_ColorMapName = false;

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
[Setting category="Colors" name="Canyon"]
vec3 S_ColorCanyon = vec3(0.8f, 0.5f, 0.1f);

[Setting category="Colors" name="Stadium"]
vec3 S_ColorStadium = vec3(0.1f, 0.1f, 0.8f);

[Setting category="Colors" name="Valley"]
vec3 S_ColorValley = vec3(0.1f, 0.8f, 0.1f);

[Setting category="Colors" name="Lagoon"]
vec3 S_ColorLagoon = vec3(0.1f, 0.8f, 0.8f);
#endif