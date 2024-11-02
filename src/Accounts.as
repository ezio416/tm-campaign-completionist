// c 2024-10-08
// m 2024-11-01

Accounts accounts;

class Accounts {
    private dictionary@ data = dictionary();

    void Add(const string &in id) {
        if (id.Length > 0 && !data.Exists(id))
            data.Set(id, "");
    }

    void Add(const string &in id, const string &in name) {
        if (id.Length > 0)
            data.Set(id, name);
    }

    void AddAsync(const string &in id) {
        if (id.Length > 0)
            data.Set(id, NadeoServices::GetDisplayNameAsync(id));
    }

    string Get(const string &in id, bool empty = true) {
        if (id.Length == 0 || !data.Exists(id))
            return empty ? "" : id;

        return string(data[id]);
    }

    void Refresh() {
        startnew(CoroutineFunc(RefreshAsync));
    }

    void RefreshAsync() {
        trace("refreshing account names...");
        data = NadeoServices::GetDisplayNamesAsync(data.GetKeys());
        trace("refreshed account names");
    }
}
