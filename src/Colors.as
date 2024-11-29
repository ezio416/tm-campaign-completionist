// c 2024-11-29
// m 2024-11-29

// [Setting hidden] vec3 S_ColorDelta0001to0100 = vec3(0.0f,  1.0f,  1.0f);
// [Setting hidden] vec3 S_ColorDelta0101to0250 = vec3(0.0f,  0.6f,  1.0f);
// [Setting hidden] vec3 S_ColorDelta0251to0500 = vec3(0.3f,  0.0f,  1.0f);
// [Setting hidden] vec3 S_ColorDelta0501to1000 = vec3(0.7f,  0.0f,  1.0f);
// [Setting hidden] vec3 S_ColorDelta1001to2000 = vec3(1.0f,  0.0f,  0.8f);
// [Setting hidden] vec3 S_ColorDelta2001to3000 = vec3(1.0f,  0.0f,  0.3f);
// [Setting hidden] vec3 S_ColorDelta3001to5000 = vec3(1.0f,  0.3f,  0.0f);
// [Setting hidden] vec3 S_ColorDelta5001Above  = vec3(1.0f,  0.6f,  0.0f);
// [Setting hidden] vec3 S_ColorDeltaUnder      = vec3(0.0f,  1.0f,  0.0f);

[Setting hidden] vec3 S_ColorDeltaUnder      = vec3(0.0f,  1.0f,  0.0f);  // achieved
[Setting hidden] vec3 S_ColorDelta0001to0100 = vec3(0.91f, 0.58f, 0.0f);
[Setting hidden] vec3 S_ColorDelta0101to0250 = vec3(0.83f, 0.32f, 0.0f);
[Setting hidden] vec3 S_ColorDelta0251to0500 = vec3(0.88f, 0.16f, 0.0f);
[Setting hidden] vec3 S_ColorDelta0501to1000 = vec3(0.76f, 0.0f,  0.29f);
[Setting hidden] vec3 S_ColorDelta1001to2000 = vec3(0.85f, 0.0f,  0.66f);
[Setting hidden] vec3 S_ColorDelta2001to3000 = vec3(0.65f, 0.0f,  1.0f);
[Setting hidden] vec3 S_ColorDelta3001to5000 = vec3(0.39f, 0.3f,  1.0f);
[Setting hidden] vec3 S_ColorDelta5001Above  = vec3(0.0f,  0.44f, 1.0f);  // skill issue

[Setting hidden] vec3 S_ColorMedalAuthor     = vec3(0.17f, 0.75f, 0.0f);
[Setting hidden] vec3 S_ColorMedalBronze     = vec3(0.69f, 0.5f,  0.0f);
[Setting hidden] vec3 S_ColorMedalGold       = vec3(1.0f,  0.97f, 0.0f);
[Setting hidden] vec3 S_ColorMedalNone       = vec3(1.0f,  0.5f,  1.0f);
[Setting hidden] vec3 S_ColorMedalSilver     = vec3(0.75f, 0.75f, 0.75f);

[Setting hidden] vec3 S_ColorModeClub        = vec3(1.0f,  0.7f,  0.0f);
[Setting hidden] vec3 S_ColorModeCustom      = vec3(0.7f,  0.0f,  0.0f);
[Setting hidden] vec3 S_ColorModeSeasonal    = vec3(0.0f,  0.6f,  0.0f);
[Setting hidden] vec3 S_ColorModeTmx         = vec3(0.43f, 1.0f,  0.63f);
[Setting hidden] vec3 S_ColorModeTotd        = vec3(0.0f,  0.6f,  1.0f);

[Setting hidden] vec3 S_ColorSeasonAll       = vec3(0.5f,  0.0f,  0.8f);
[Setting hidden] vec3 S_ColorSeasonFall      = vec3(1.0f,  0.5f,  0.0f);
[Setting hidden] vec3 S_ColorSeasonSpring    = vec3(0.3f,  0.9f,  0.3f);
[Setting hidden] vec3 S_ColorSeasonSummer    = vec3(1.0f,  0.8f,  0.0f);
[Setting hidden] vec3 S_ColorSeasonUnknown   = vec3(1.0f,  0.5f,  1.0f);
[Setting hidden] vec3 S_ColorSeasonWinter    = vec3(0.0f,  1.0f,  1.0f);

[Setting hidden] vec3 S_ColorSeriesAll       = vec3(0.5f,  0.0f,  0.8f);
[Setting hidden] vec3 S_ColorSeriesBlack     = vec3(0.4f,  0.4f,  0.4f);
[Setting hidden] vec3 S_ColorSeriesBlue      = vec3(0.24f, 0.39f, 1.0f);
[Setting hidden] vec3 S_ColorSeriesGreen     = vec3(0.43f, 0.98f, 0.63f);
[Setting hidden] vec3 S_ColorSeriesRed       = vec3(1.0f,  0.0f,  0.0f);
[Setting hidden] vec3 S_ColorSeriesUnknown   = vec3(1.0f,  0.5f,  1.0f);
[Setting hidden] vec3 S_ColorSeriesWhite     = vec3(1.0f,  1.0f,  1.0f);

string colorDelta0001to0100;
string colorDelta0101to0250;
string colorDelta0251to0500;
string colorDelta0501to1000;
string colorDelta1001to2000;
string colorDelta2001to3000;
string colorDelta3001to5000;
string colorDelta5001Above;
string colorDeltaUnder;
string colorMedalAuthor;
string colorMedalBronze;
string colorMedalGold;
string colorMedalNone;
string colorMedalSilver;
string colorModeClub;
string colorModeCustom;
string colorModeSeasonal;
string colorModeTmx;
string colorModeTotd;
string colorSeasonAll;
string colorSeasonFall;
string colorSeasonSpring;
string colorSeasonSummer;
string colorSeasonUnknown;
string colorSeasonWinter;
string colorSeriesAll;
string colorSeriesBlack;
string colorSeriesBlue;
string colorSeriesGreen;
string colorSeriesRed;
string colorSeriesUnknown;
string colorSeriesWhite;

string GetColor(TargetMedal medal) {
    switch (medal) {
        case TargetMedal::None:
            return colorMedalNone;

        case TargetMedal::Bronze:
            return colorMedalBronze;

        case TargetMedal::Silver:
            return colorMedalSilver;

        case TargetMedal::Gold:
            return colorMedalGold;

        case TargetMedal::Author:
            return colorMedalAuthor;

#if DEPENDENCY_WARRIORMEDALS
        case TargetMedal::Warrior:
            return WarriorMedals::GetColorStr();
#endif

        default:
            return "";
    }
}

string GetColor(Mode mode) {
    switch (mode) {
        case Mode::Club:
            return colorModeClub;

        case Mode::Custom:
            return colorModeCustom;

        case Mode::Seasonal:
            return colorModeSeasonal;

        case Mode::TMX:
            return colorModeTmx;

        case Mode::TOTD:
            return colorModeTotd;

        default:
            return "";
    }
}

void SetDeltaColors() {
    colorDeltaUnder      = Text::FormatOpenplanetColor(S_ColorDeltaUnder);
    colorDelta0001to0100 = Text::FormatOpenplanetColor(S_ColorDelta0001to0100);
    colorDelta0101to0250 = Text::FormatOpenplanetColor(S_ColorDelta0101to0250);
    colorDelta0251to0500 = Text::FormatOpenplanetColor(S_ColorDelta0251to0500);
    colorDelta0501to1000 = Text::FormatOpenplanetColor(S_ColorDelta0501to1000);
    colorDelta1001to2000 = Text::FormatOpenplanetColor(S_ColorDelta1001to2000);
    colorDelta2001to3000 = Text::FormatOpenplanetColor(S_ColorDelta2001to3000);
    colorDelta3001to5000 = Text::FormatOpenplanetColor(S_ColorDelta3001to5000);
    colorDelta5001Above  = Text::FormatOpenplanetColor(S_ColorDelta5001Above);
}

void SetMedalColors() {
    colorMedalAuthor = Text::FormatOpenplanetColor(S_ColorMedalAuthor);
    colorMedalBronze = Text::FormatOpenplanetColor(S_ColorMedalBronze);
    colorMedalGold   = Text::FormatOpenplanetColor(S_ColorMedalGold);
    colorMedalNone   = Text::FormatOpenplanetColor(S_ColorMedalNone);
    colorMedalSilver = Text::FormatOpenplanetColor(S_ColorMedalSilver);
}

void SetModeColors() {
    colorModeClub     = Text::FormatOpenplanetColor(S_ColorModeClub);
    colorModeCustom   = Text::FormatOpenplanetColor(S_ColorModeCustom);
    colorModeSeasonal = Text::FormatOpenplanetColor(S_ColorModeSeasonal);
    colorModeTmx      = Text::FormatOpenplanetColor(S_ColorModeTmx);
    colorModeTotd     = Text::FormatOpenplanetColor(S_ColorModeTotd);
}

void SetSeasonColors() {
    colorSeasonAll     = Text::FormatOpenplanetColor(S_ColorSeasonAll);
    colorSeasonFall    = Text::FormatOpenplanetColor(S_ColorSeasonFall);
    colorSeasonSpring  = Text::FormatOpenplanetColor(S_ColorSeasonSpring);
    colorSeasonSummer  = Text::FormatOpenplanetColor(S_ColorSeasonSummer);
    colorSeasonUnknown = Text::FormatOpenplanetColor(S_ColorSeasonUnknown);
    colorSeasonWinter  = Text::FormatOpenplanetColor(S_ColorSeasonWinter);
}

void SetSeriesColors() {
    colorSeriesAll     = Text::FormatOpenplanetColor(S_ColorSeriesAll);
    colorSeriesBlack   = Text::FormatOpenplanetColor(S_ColorSeriesBlack);
    colorSeriesBlue    = Text::FormatOpenplanetColor(S_ColorSeriesBlue);
    colorSeriesGreen   = Text::FormatOpenplanetColor(S_ColorSeriesGreen);
    colorSeriesRed     = Text::FormatOpenplanetColor(S_ColorSeriesRed);
    colorSeriesUnknown = Text::FormatOpenplanetColor(S_ColorSeriesUnknown);
    colorSeriesWhite   = Text::FormatOpenplanetColor(S_ColorSeriesWhite);
}
