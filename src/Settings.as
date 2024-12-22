// c 2024-01-02
// m 2024-11-25

enum Mode {
    NadeoCampaign,
    TrackOfTheDay
}

[Setting hidden]
Mode S_Mode = Mode::NadeoCampaign;
Mode lastMode = S_Mode;

enum TargetMedal {
    Author,
    Gold,
    Silver,
    Bronze,
    None
}

[Setting hidden]
TargetMedal S_Target = TargetMedal::Author;


[Setting category="General" name="Notify when Starter Access is detected"]
bool S_NotifyStarter = true;

[Setting category="General" name="Automatically switch maps when target is reached" description="Always disabled for Starter Access"]
bool S_AutoSwitch = true;

[Setting category="General" name="Show 'Auto Switch' button" description="Always disabled for Starter Access"]
bool S_MenuAutoSwitch = true;

[Setting category="General" name="Only show the current 25 Nadeo Campaign maps" description="Always enabled for Starter Access (only first 10 maps)"]
bool S_OnlyCurrentCampaign = false;
bool lastOnlyCurrentCampaign = S_OnlyCurrentCampaign;

[Setting category="General" name="Show 'Only Current Campaign' button" description="Always disabled for Starter Access"]
bool S_MenuOnlyCurrentCampaign = true;

enum Season {  // update every season
    All,
    Unknown,
    Summer_2020,
    Fall_2020,
    Winter_2021,
    Spring_2021,
    Summer_2021,
    Fall_2021,
    Winter_2022,
    Spring_2022,
    Summer_2022,
    Fall_2022,
    Winter_2023,
    Spring_2023,
    Summer_2023,
    Fall_2023,
    Winter_2024,
    Spring_2024,
    Summer_2024,
    Fall_2024
}

[Setting category="General" name="Season to show" description="Tracks of the Day are categorized into 3-month periods which may differ slightly from the time periods of Nadeo Campaigns. Does nothing for Starter Access"]
Season S_Season = Season::All;
Season lastSeason = S_Season;

[Setting category="General" name="Show 'Season' menu" description="Does nothing for Starter Access"]
bool S_MenuSeason = true;

enum CampaignSeries {
    All,
    White,
    Green,
    Blue,
    Red,
    Black
}

[Setting category="General" name="Campaign series to show"]
CampaignSeries S_Series = CampaignSeries::All;
CampaignSeries lastSeries = S_Series;

[Setting category="General" name="Show 'Series' menu"]
bool S_MenuSeries = true;

const string[] seriesWhite = { "01", "02", "03", "04", "05" };
const string[] seriesGreen = { "06", "07", "08", "09", "10" };
const string[] seriesBlue  = { "11", "12", "13", "14", "15" };
const string[] seriesRed   = { "16", "17", "18", "19", "20" };
const string[] seriesBlack = { "21", "22", "23", "24", "25" };

// [Setting category="General" name="Show 'Refresh Records' button"]
// bool S_MenuRefresh = true;

[Setting category="General" name="Show a list of remaining maps"]
bool S_MenuAllMaps = true;

[Setting category="General" name="Show hover text for clicking" description="Left-click to play, middle-click to skip, right-click to bookmark"]
bool S_MenuClickHover = true;

[Setting category="General" name="Show skip icons"]
bool S_MenuSkipIcons = true;

[Setting category="General" name="Exclude skipped maps from 'remaining maps'"]
bool S_MenuExcludeSkips = true;
bool lastMenuExcludeSkips = S_MenuExcludeSkips;

[Setting category="General" name="Show a list of skipped maps"]
bool S_MenuAllSkips = true;

[Setting category="General" name="Show bookmark icons"]
bool S_MenuBookmarkIcons = true;

[Setting category="General" name="Show a list of bookmarked maps"]
bool S_MenuAllBookmarks = true;

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

[Setting category="Colors" name="All seasons" color]
vec3 S_ColorSeasonAll = vec3(1.0f, 0.4f, 1.0f);
string colorSeasonAll;
const string iconSeasonAll = Icons::ListAlt;

[Setting category="Colors" name="Unknown season" color]
vec3 S_ColorSeasonUnknown = vec3(1.0f, 0.0f, 0.0f);
string colorSeasonUnknown;
const string iconSeasonUnknown = Icons::QuestionCircle;

[Setting category="Colors" name="Winter/Jan-Mar" color]
vec3 S_ColorSeasonWinter = vec3(0.0f, 1.0f, 1.0f);
string colorSeasonWinter;
const string iconSeasonWinter = Icons::SnowflakeO;

[Setting category="Colors" name="Spring/Apr-Jun" color]
vec3 S_ColorSeasonSpring = vec3(0.3f, 0.9f, 0.3f);
string colorSeasonSpring;
const string iconSeasonSpring = Icons::Tree;

[Setting category="Colors" name="Summer/Jul-Sep" color]
vec3 S_ColorSeasonSummer = vec3(1.0f, 0.8f, 0.0f);
string colorSeasonSummer;
const string iconSeasonSummer = Icons::Sun;

[Setting category="Colors" name="Fall/Oct-Dec" color]
vec3 S_ColorSeasonFall = vec3(1.0f, 0.5f, 0.0f);
string colorSeasonFall;
const string iconSeasonFall = Icons::Leaf;

[Setting category="Colors" name="All series" color]
vec3 S_ColorSeriesAll = vec3(1.0f, 0.4f, 1.0f);
string colorSeriesAll;

[Setting category="Colors" name="White series" color]
vec3 S_ColorSeriesWhite = vec3(1.0f, 1.0f, 1.0f);
string colorSeriesWhite;

[Setting category="Colors" name="Green series" color]
vec3 S_ColorSeriesGreen = vec3(0.0f, 1.0f, 0.0f);
string colorSeriesGreen;

[Setting category="Colors" name="Blue series" color]
vec3 S_ColorSeriesBlue = vec3(0.4f, 0.8f, 1.0f);
string colorSeriesBlue;

[Setting category="Colors" name="Red series" color]
vec3 S_ColorSeriesRed = vec3(1.0f, 0.0f, 0.0f);
string colorSeriesRed;

[Setting category="Colors" name="Black series" color]
vec3 S_ColorSeriesBlack = vec3(0.4f, 0.4f, 0.4f);
string colorSeriesBlack;

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
