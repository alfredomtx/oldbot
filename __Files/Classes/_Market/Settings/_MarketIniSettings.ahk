#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Ini\_AbstractIniSettings.ahk

class _MarketIniSettings extends _AbstractIniSettings
{
    static INSTANCE
    static IDENTIFIER := "marketbot"

    static INI_FILE := "market_settings.ini"

    __New()
    {
        if (_MarketIniSettings.INSTANCE) {
            return _MarketIniSettings.INSTANCE
        }

        base.__New()

        _MarketIniSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _MarketIniSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes[i := "item"] := new _DefaultString("", i)
        this.attributes[i := "marketbotEnabled"] := new _DefaultBoolean(false, i)
        this.attributes[i := "simulation"] := new _DefaultBoolean(true, i)
        this.attributes[i := "autoStart"] := new _DefaultBoolean(false, i)
        this.attributes[i := "pauseOnError"] := new _DefaultBoolean(false, i)
        this.attributes[i := "acceptOfferConfirmation"] := new _DefaultBoolean(true, i)
        this.attributes[i := "createOfferConfirmation"] := new _DefaultBoolean(true, i)
        this.attributes[i := "cancelOfferConfirmation"] := new _DefaultBoolean(true, i)
        this.attributes[i := "finishedItemConfirmation"] := new _DefaultBoolean(true, i)
        this.attributes[i := "finishedAllItemsConfirmation"] := new _DefaultBoolean(false, i)
        this.attributes[i := "runActionConfirmation"] := new _DefaultBoolean(true, i)
    }

    /**
    * @param string key
    */
    read(key) 
    {
        return _Ini.read(key, this.getIdentifier(), "", _Folders.MARKET_ROOT "\" _MarketIniSettings.INI_FILE)
    }

    /**
    * @param string key
    * @param mixed value
    * @return void
    */
    write(key, value)
    {
        _Ini.write(key, value, this.getIdentifier(), _Folders.MARKET_ROOT "\" _MarketIniSettings.INI_FILE)
    }
}