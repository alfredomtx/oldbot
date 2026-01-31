#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\JSON\_AbstractJsonSettings.ahk

class _FishingSettings extends _AbstractJsonSettings
{
    static INSTANCE
    static IDENTIFIER := "fishing"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        if (_FishingSettings.INSTANCE) {
            return _FishingSettings.INSTANCE
        }

        base.__New()

        _FishingSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _FishingSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes["enabled"] := new _DefaultBoolean(false, "enabled")
        this.attributes["delay"] := new _DefaultValue(500, 100, 600000, "delay")
        this.attributes["rodHotkey"] := new _DefaultValue("")
        this.attributes["pauseHotkey"] := new _DefaultValue("")
        this.attributes["pressEsc"] := new _DefaultBoolean(false, "pressEsc")

        this.attributes["withFreeSlot"] := new _DefaultBoolean(false, "withFreeSlot")
        this.attributes["ifNoFish"] := new _DefaultBoolean(false, "ifNoFish")
        this.attributes["capCondition"] := new _DefaultBoolean(false, "capCondition")
        this.attributes["ignoreIfWaypointTab"] := new _DefaultBoolean(false, "ignoreIfWaypointTab")

        this.attributes["capAmount"] := new _DefaultValue(50, 1, 10000, "capAmount")
        this.attributes["waypointTab"] := new _DefaultValue("")

    }
}