#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\JSON\_AbstractJsonSettings.ahk

class _CavebotSettings extends _AbstractJsonSettings
{
    static INSTANCE
    static IDENTIFIER := "cavebot"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        if (_CavebotSettings.INSTANCE) {
            return _CavebotSettings.INSTANCE
        }

        base.__New()

        _CavebotSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _CavebotSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        ;#region Shared
        delay := isTibia74() ? 800 : 600
        if (false) {
            delay := 1000
        }

        this.attributes[i := "characterStuckTime"] := new _DefaultValue(delay, 600, 1000, i).setType(lang("ms", false))
        ;#endregion

        this.attributes["walkArrowDelay"] := new _DefaultValue(75, 1, 1000, "walkArrowDelay").setType(lang("ms", false))
    }
}