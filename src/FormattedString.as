// c 2024-10-09
// m 2024-10-10

class FormattedString {
    string formatted;
    string lower;
    string raw;
    string stripped;

    FormattedString(const string &in raw) {
        this.raw = raw;
        formatted = Text::OpenplanetFormatCodes(raw);
        stripped = Text::StripFormatCodes(raw);
        lower = stripped.ToLower();
    }
}
