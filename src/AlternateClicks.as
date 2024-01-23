// c 2024-01-23
// m 2024-01-23

const string bookmarkedFile = IO::FromStorageFolder("bookmarks.json");
Json::Value@ bookmarkedUids = Json::Object();
Map@[]       mapsBookmarked;
Map@[]       mapsSkipped;
const string skippedFile    = IO::FromStorageFolder("skips.json");
Json::Value@ skippedUids    = Json::Object();

void ClickAction(bool skipped, bool bookmarked, const string &in uid) {
    if (UI::IsItemHovered()) {
        if (S_MenuClickHover) {
            UI::BeginTooltip();
            UI::Text(Icons::Kenney::MouseLeftButton + " play, " + Icons::Kenney::MouseAlt + (skipped ? " un-" : " ") + "skip, " + Icons::Kenney::MouseRightButton + (bookmarked ? " un-" : " ") + "bookmark");
            UI::EndTooltip();
        }

        if (UI::IsMouseReleased(UI::MouseButton::Middle)) {
            if (skipped)
                RemoveSkip(uid);
            else
                AddSkip(uid);
        }

        if (UI::IsMouseReleased(UI::MouseButton::Right)) {
            if (bookmarked)
                RemoveBookmark(uid);
            else
                AddBookmark(uid);
        }
    }
}

void AddBookmark(const string &in uid) {
    bookmarkedUids[uid] = 0;
    SaveBookmarks();
    startnew(SetNextMap);
}

void AddSkip(const string &in uid) {
    skippedUids[uid] = 0;
    SaveSkips();
    startnew(SetNextMap);
}

void RemoveBookmark(const string &in uid) {
    bookmarkedUids.Remove(uid);
    SaveBookmarks();
    startnew(SetNextMap);
}

void RemoveSkip(const string &in uid) {
    skippedUids.Remove(uid);
    SaveSkips();
    startnew(SetNextMap);
}

void LoadBookmarks() {
    if (!IO::FileExists(bookmarkedFile))
        return;

    trace("loading " + bookmarkedFile);

    try {
        bookmarkedUids = Json::FromFile(bookmarkedFile);
    } catch {
        warn("failed loading bookmarks: " + getExceptionInfo());
    }
}

void LoadSkips() {
    if (!IO::FileExists(skippedFile))
        return;

    trace("loading " + skippedFile);

    try {
        skippedUids = Json::FromFile(skippedFile);
    } catch {
        warn("failed loading skips: " + getExceptionInfo());
    }
}

void SaveBookmarks() {
    trace("saving " + bookmarkedFile);

    try {
        Json::ToFile(bookmarkedFile, bookmarkedUids);
    } catch {
        warn("error saving bookmarks: " + getExceptionInfo());
    }
}

void SaveSkips() {
    trace("saving " + skippedFile);

    try {
        Json::ToFile(skippedFile, skippedUids);
    } catch {
        warn("error saving skips: " + getExceptionInfo());
    }
}