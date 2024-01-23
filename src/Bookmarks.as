// c 2024-01-23
// m 2024-01-23

const string bookmarkedFile = IO::FromStorageFolder("bookmarks.json");
Json::Value@ bookmarkedUids = Json::Object();
Map@[]       mapsBookmarked;

void BookmarkAction(bool bookmarked, const string &in uid) {
    if (UI::IsItemHovered()) {
        if (S_MenuBookmarkHover) {
            UI::BeginTooltip();
            UI::Text("click to play, right-click to " + (bookmarked ? "remove " : "") + "bookmark");
            UI::EndTooltip();
        }

        if (UI::IsMouseReleased(UI::MouseButton::Right)) {
            if (bookmarked) {
                bookmarkedUids.Remove(uid);
                SaveBookmarks();
                startnew(SetNextMap);
            } else {
                bookmarkedUids[uid] = 0;
                SaveBookmarks();
                startnew(SetNextMap);
            }
        }
    }
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

void SaveBookmarks() {
    trace("saving " + bookmarkedFile);

    try {
        Json::ToFile(bookmarkedFile, bookmarkedUids);
    } catch {
        warn("error saving bookmarks: " + getExceptionInfo());
    }
}