#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\JSON\_AbstractJsonSettings.ahk

class _RunemakerSettings extends _AbstractJsonSettings
{
    static INSTANCE
    static IDENTIFIER := "runemaker"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        if (_RunemakerSettings.INSTANCE) {
            return _RunemakerSettings.INSTANCE
        }

        base.__New()

        _RunemakerSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _RunemakerSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes[i := "enabled"] := new _DefaultBoolean(false, i)
        this.attributes[i := "manaPercent"] := new _DefaultValue(95, 1, 95, i)
        this.attributes[i := "rune"] := new _DefaultString("ultimate healing rune", i)
        this.attributes[i := "blankRune"] := new _DefaultString("blank rune", i)
        this.attributes[i := "spellHotkey"] := new _DefaultString("", i)
        this.attributes[i := "moveBlankToHand"] := new _DefaultBoolean(true, i)
        this.attributes[i := "openNextBackpack"] := new _DefaultBoolean(false, i)
        this.attributes[i := "logoutWithoutBlankRune"] := new _DefaultBoolean(false, i)

        this.attributes[i := "moveRunePosition.enabled"] := new _DefaultBoolean(false, i)
        this.attributes[i := "moveRunePosition.x"] := new _DefaultString("", i)
        this.attributes[i := "moveRunePosition.y"] := new _DefaultString("", i)

        this.attributes[i := "antiIdle.enabled"] := new _DefaultBoolean(true, i)
        this.attributes[i := "eatFood.enabled"] := new _DefaultBoolean(true, i)
        this.attributes[i := "eatFood.food"] := new _DefaultString("fish", i)
        this.attributes[i := "pauseFishing.enabled"] := new _DefaultBoolean(false, i)

    }
}