#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Ini\_AbstractIniSettings.ahk

identifier := _HealingIniSettings.getIdentifier()
%identifier%Ini := {}

class _HealingIniSettings extends _AbstractIniSettings
{
    static INSTANCE
    static IDENTIFIER := "healing"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        if (_HealingIniSettings.INSTANCE) {
            return _HealingIniSettings.INSTANCE
        }

        base.__New()

        _HealingIniSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _HealingIniSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes["delayAfterUseItem"] := new _DefaultValue(250, 100, 2000, "delayAfterUseItem").setType(lang("ms", false))
    }
}