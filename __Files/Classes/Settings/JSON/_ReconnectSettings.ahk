#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\JSON\_AbstractJsonSettings.ahk

class _ReconnectSettings extends _AbstractJsonSettings
{
    static INSTANCE
    static IDENTIFIER := "reconnect"

    static DELAY_MIN := 1
    static DELAY_MAX := 99999

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        if (_ReconnectSettings.INSTANCE) {
            return _ReconnectSettings.INSTANCE
        }

        base.__New()

        _ReconnectSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _ReconnectSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes["delay"] := new _DefaultValue(60, this.DELAY_MIN, this.DELAY_MAX, "delay")
    }
}