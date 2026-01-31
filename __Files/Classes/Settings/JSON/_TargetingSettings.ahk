#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\JSON\_AbstractJsonSettings.ahk

class _TargetingSettings extends _AbstractJsonSettings
{
    static INSTANCE
    static IDENTIFIER := "targeting"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        if (_TargetingSettings.INSTANCE) {
            return _TargetingSettings.INSTANCE
        }

        base.__New()

        _TargetingSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _TargetingSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}
        this.attributes[i := "huntAssistMode"] := new _DefaultBoolean(false, i)

        this.attributes[i := "antiKs"] := new _DefaultEnum(_AntiKS.STATE_DISABLED, _AntiKS.states(), i)
        this.attributes[i := "antiKsVariation"] := new _DefaultValue(v := 30, 1, v, i)
    }
}