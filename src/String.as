// c 2024-10-09
// m 2025-03-10

class String {
    string formatted;
    string lower;
    string raw;
    string stripped;

    String(const string &in raw) {
        if (raw.Length == 0)
            throw("String: blank");

        this.raw = raw;
        formatted = Strings::Clean(Text::OpenplanetFormatCodes(raw));
        lower     = Strings::Clean(stripped.ToLower());
        stripped  = Strings::Clean(Text::StripFormatCodes(raw));
    }

    string opImplConv() const {
        return stripped;
    }
}

namespace Strings {
    string Clean(const string &in input) {
        return ReplaceBadQuotes(input.Trim());
    }

    string ReplaceBadQuotes(const string &in input) {
        return input.Replace("‘", "'").Replace("’", "'").Replace("“", "\"").Replace("”", "\"");
    }
}
