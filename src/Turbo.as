// c 2024-01-04
// m 2024-01-04

#if TURBO

void GetMaps() {
    ;
}

void Render() {
    if (!S_Debug)
        return;

    UI::Begin(title + " debug", S_Debug);
        if (UI::Button("ReturnToMenu"))
            startnew(ReturnToMenu);
    UI::End();
}

#endif