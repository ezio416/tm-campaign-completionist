// c 2024-10-09
// m 2025-03-10

class FormattedString {
    string formatted;
    string lower;
    string raw;
    string stripped;

    FormattedString(const string &in raw) {
        if (raw.Length == 0)
            throw("FormattedString: blank");

        this.raw = raw;
        formatted = CleanString(Text::OpenplanetFormatCodes(raw));
        lower     = CleanString(stripped.ToLower());
        stripped  = CleanString(Text::StripFormatCodes(raw));
    }

    string opImplConv() const {
        return stripped;
    }
}

string CleanString(const string &in input) {
    return ReplaceBadQuotes(input.Trim());
}

string ReplaceBadQuotes(const string &in input) {
    return input.Replace("‘", "'").Replace("’", "'").Replace("“", "\"").Replace("”", "\"");
}
