// c 2024-01-02
// m 2024-01-02

enum TargetMedal {
    Author,
    Gold,
    Silver,
    Bronze,
    JustFinish
}

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Target Medal"]
TargetMedal S_Target = TargetMedal::Author;

[Setting category="General" name="Colored map name in menu"]
bool S_ColorMapName = false;