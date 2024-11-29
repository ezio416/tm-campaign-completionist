// c 2024-11-29
// m 2024-11-29

enum MapOrder {
    Normal,
    Reverse,
    ClosestAbs,
    ClosestRel,
    Random
}

enum Mode {
    Seasonal,
    TOTD,
    Club,
    TMX,
    Custom,
    Unknown
}

enum Season {  // update every season
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
    Fall_2024,
    Unknown,
    All,
}

enum Series {
    White   = 1,
    Green   = 2,
    Blue    = 4,
    Red     = 8,
    Black   = 16,
    Unknown = 32
}

enum TargetMedal {
    None,
    Bronze,
    Silver,
    Gold,
    Author,
#if DEPENDENCY_WARRIORMEDALS
    Warrior,
#endif
}
