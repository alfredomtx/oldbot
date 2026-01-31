/**
* @property string _date
* @property int _items
*/
class _MarketbotLicense extends _BaseClass
{
    static INSTANCE

    static CACHED_DATE := "date"
    static CACHED_ITEMS := "items"
    static CACHED_COOLDOWN := "cooldown"

    static LAST_CHECK := "lastCheck"

    static FREE_ITEMS := 3
    static PREMIUM_ITEMS := 100

    static FREE_ITEM_COOLDOWN := 60
    static FREE_ITEM_COOLDOWN_HOURS := 1
    static PREMIUM_ITEM_COOLDOWN := 5

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __Init()
    {
        static validated
        if (validated) {
            return
        }

        classLoaded("_MarketbotRequest", _MarketbotRequest)
        classLoaded("_Logger", _Logger)
        classLoaded("_Ini", _Ini)
        classLoaded("_Validation", _Validation)

        validated := true
    }

    /**
    * @throws
    */
    __New()
    {
        if (_MarketbotLicense.INSTANCE) {
            return _MarketbotLicense.INSTANCE
        }

        this.get()

        _MarketbotLicense.INSTANCE := this
    }

    /**
    * @return bool
    */
    cachedLicense()
    {
        if (!A_IsCompiled) {
            this.setDate("2025-09-06")
            ; this.setDate("2024-09-06")
                .setItems(this.PREMIUM_ITEMS)
                .setCooldown(0.1)

            return true
        }

        lastCheck := _Ini.read(this.LAST_CHECK, "cache")
        email := _Ini.read("email", "cache")
        if (loginEmail) {
            if (email && email != loginEmail) {
                return false
            }
        }

        if (!lastCheck || lastCheck != A_MDay) {
            return false
        }

        date := _Ini.read(this.CACHED_DATE, "cache")
        items := _Ini.read(this.CACHED_ITEMS, "cache")
        cooldown := _Ini.read(this.CACHED_COOLDOWN, "cache")

        if (!date || !items) {
            return false
        }

        this.setDate(date)
            .setItems(items)
            .setCooldown(cooldown)

        return true
    }

    /**
    * @return void
    * @throws
    */
    get(cached := true)
    {
        if (cached && this.cachedLicense()) {
            return
        }

        response := this.fetch()

        date := response.date
        items := response.items
        cooldown := response.cooldown

        _Ini.write(this.CACHED_DATE, date, "cache")
        _Ini.write(this.CACHED_ITEMS, items, "cache")
        _Ini.write(this.CACHED_COOLDOWN, cooldown, "cache")
        _Ini.write(this.LAST_CHECK, A_MDay, "cache")
        _Ini.write("email", loginEmail, "cache")

        this.setDate(date)
            .setItems(items)
            .setCooldown(cooldown)
    }

    /**
    * @return void
    * @throws
    */
    fetch()
    {
        try {
            response := new _MarketbotRequest().execute()
        } catch e {
            try {
                response := new _MarketbotRequest().execute()
            } catch e {
                _Logger.exception(e, A_ThisFunc)
                throw e
            }
        }

        if (!response) {
            _Logger.log("response", se(response))
            throw Exception(txt("Falha ao obter licença do Marketbot.", "Failed to get Marketbot license."))
        }

        return response
    }

    /**
    * Returns a large number of days for open-source release (no expiration)
    * @return int
    */
    days()
    {
        return 99999
    }

    ;#region Getters
    date()
    {
        return this._date
    }

    /**
    * Returns unlimited items for open-source release
    * @return int
    */
    items()
    {
        return 999999
    }

    /**
    * Returns minimum cooldown for open-source release
    * @return int
    */
    cooldown()
    {
        return 0
    } 

    ;#endregion

    ;#region Setters
    setDate(value)
    {
        this._date := value

        return this
    }

    setItems(value)
    {
        _Validation.number("value", value)
        this._items := value

        return this
    }

    setCooldown(value)
    {
        this._cooldown := value

        return this
    }
    ;#endregion

    ;#region Predicates
    /**
    * Always returns true for open-source release
    * @return bool
    */
    isPremium()
    {
        return true
    }
    ;#endregion
}