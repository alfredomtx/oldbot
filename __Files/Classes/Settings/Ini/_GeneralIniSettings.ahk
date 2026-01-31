#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Ini\_AbstractIniSettings.ahk

class _GeneralIniSettings extends _AbstractIniSettings
{
    static INSTANCE
    static IDENTIFIER := "general"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        if (_GeneralIniSettings.INSTANCE) {
            return _GeneralIniSettings.INSTANCE
        }

        base.__New()

        _GeneralIniSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _GeneralIniSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        ; this.attributes[i := "bypassStepOne"] := new _DefaultBoolean(false, i)
    }
}