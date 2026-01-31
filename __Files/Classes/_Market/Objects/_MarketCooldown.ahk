
class _MarketCooldown extends _BaseClass
{
    static RATE_LIMIT_INI_FILE := A_Temp "\cd.ini"

    static ACTION_TYPE_COOLDOWN := 2

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(item, limit, key)
    {
        this.item := item
        this._limit := limit
        this.key := key

        this.license := new _MarketbotLicense()
    }

    write(value)
    {
        _Validation.number("value", value)

        return _Ini.write(this.key, value, this.item, this.RATE_LIMIT_INI_FILE)
    }

    read()
    {
        return _Ini.read(this.key, this.item, "", this.RATE_LIMIT_INI_FILE)
    }

    elapsed()
    {
        lastCheck := this.read()
        if (empty(lastCheck)) {
            return -1
        }

        return new _Timer(lastCheck).minutes()
    }

    elapsedSeconds()
    {
        return this.elapsed() * 60
    }

    limitSeconds()
    {
        return this.limit() * 60
    }

    ;#region Getters
    limit()
    {
        return this._limit
    }
    ;#endregion

    ;#region Setters
    has()
    {
        elapsed := this.elapsed()
        if (elapsed < 0) {
            return false
        }

        return elapsed < this.limit()
    }
    ;#endregion

    ;#region Predicates
    ;#endregion

    ;#region Factory
    ;#endregion
}