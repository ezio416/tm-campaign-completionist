// c 2024-11-29
// m 2024-11-30

class RaceTime {
    private uint _val = uint(-1);

    RaceTime() { }
    RaceTime(uint u) { _val = u; }

    bool get_driven() {
        return Driven(_val);
    }

    bool get_invalid() {
        return _val == uint(-1);
    }

    bool get_valid() {
        return _val != uint(-1);
    }

    uint opCast()     { return _val; }
    uint opConv()     { return _val; }
    uint opImplCast() { return _val; }
    uint opImplConv() { return _val; }

    uint opAdd(uint u) { return _val + u; }
    uint opAdd(RaceTime@ other) { return _val + other; }

    uint opSub(uint u) { return _val - u; }
    uint opSub(RaceTime@ other) { return _val - other; }

    int opCmp(RaceTime@ other) {
        return _val - other;
    }

    void opAddAssign(uint u)  { _val += u; }
    void opSubAssign(uint u)  { _val -= u; }
    void opMulAssign(uint u)  { _val *= u; }
    void opDivAssign(uint u)  { _val /= u; }
    void opModAssign(uint u)  { _val %= u; }
    void opPowAssign(uint u)  { _val **= u; }
    void opAndAssign(uint u)  { _val &= u; }
    void opOrAssign(uint u)   { _val |= u; }
    void opXorAssign(uint u)  { _val ^= u; }
    void opShlAssign(uint u)  { _val <<= u; }
    void opShrAssign(uint u)  { _val >>= u; }
    void opUShrAssign(uint u) { _val >>>= u; }

    uint opPostDec() { return _val--; }
    uint opPostInc() { return _val++; }
    uint opPreDec()  { return --_val; }
    uint opPreInc()  { return ++_val; }

    void Invalidate() {
        _val = uint(-1);
    }

    void NotDriven() {
        _val = 0;
    }

    string ToString() {
        return Time::Format(_val);
    }
}
