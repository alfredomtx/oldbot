#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Ini\_AbstractIniSettings.ahk

identifier := _OldBotIniSettings.getIdentifier()
%identifier%Ini := {}

class _OldBotIniSettings extends _AbstractIniSettings
{
    static INSTANCE
    static IDENTIFIER := "oldbot"
    static FILE_PATH := "oldbot_settings.ini"

    static VERSION_STABLE := "stable"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        if (_OldBotIniSettings.INSTANCE) {
            return _OldBotIniSettings.INSTANCE
        }

        base.__New()

        _OldBotIniSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _OldBotIniSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes["receiveBetaVersions"] := new _DefaultBoolean(false, "receiveBetaVersions")
        this.attributes["preferredVersion"] := new _DefaultValue(this.VERSION_STABLE)
        this.attributes["keyPressDelay"] := new _DefaultValue(25, 1, 200, "keyPressDelay").setType(lang("ms", false))
        this.attributes["keyPressRandomDelay"] := new _DefaultValue(75, 1, 200, "keyPressRandomDelay").setType(lang("ms", false))
        this.attributes[i := "lastSelectedTab"] := new _DefaultString("", i)

        this.attributes[i := "showAlerts"] := new _DefaultBoolean(true, i)
        this.attributes[i := "showAutoSpells"] := new _DefaultBoolean(true, i)
        this.attributes[i := "showFishing"] := new _DefaultBoolean(true, i)
        this.attributes[i := "showHealing"] := new _DefaultBoolean(true, i)
        this.attributes[i := "showHotkeys"] := new _DefaultBoolean(true, i)
        this.attributes[i := "showItemRefill"] := new _DefaultBoolean(true, i)
        this.attributes[i := "showLooting"] := new _DefaultBoolean(true, i)
        this.attributes[i := "showNavigation"] := new _DefaultBoolean(true, i)
        this.attributes[i := "showPersistent"] := new _DefaultBoolean(true, i)
        this.attributes[i := "showReconnect"] := new _DefaultBoolean(true, i)
        this.attributes[i := "showSio"] := new _DefaultBoolean(true, i)
        this.attributes[i := "showSupport"] := new _DefaultBoolean(true, i)
        this.attributes[i := "showTargeting"] := new _DefaultBoolean(true, i)
        this.attributes[i := "toggleAllModules"] := new _DefaultBoolean(true, i)
    }

    /**
    * @param string key
    * @param ?string section
    * @param ?mixed default
    */
    read(key, section := "", default := "")
    {
        return _Ini.read(key, section ? section : this.getIdentifier(), default, this.FILE_PATH)
    }

    /**
    * @param string key
    * @param mixed value
    * @param ?string section
    * @return void
    */
    write(key, value, section := "")
    {
        _Ini.write(key, value, section ? section : this.getIdentifier(), this.FILE_PATH)
    }
}