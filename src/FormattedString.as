// c 2024-10-09
// m 2024-11-28

class FormattedString {
    string formatted;
    string lower;
    string raw;
    string stripped;

    FormattedString(const string &in raw) {
        this.raw = raw;
        formatted = CleanString(Text::OpenplanetFormatCodes(raw));
        stripped = CleanString(Text::StripFormatCodes(raw));
        lower = CleanString(stripped.ToLower());
    }
}

string CleanString(const string &in input) {
    return ReplaceBadQuotes(input.Trim());
}

string ReplaceBadQuotes(const string &in input) {
    return input.Replace("‘", "'").Replace("’", "'").Replace("“", "\"").Replace("”", "\"");
}
