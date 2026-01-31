#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Ini\_AbstractIniSettings.ahk

identifier := _InterfaceIniSettings.getIdentifier()
%identifier%Ini := {}

class _InterfaceIniSettings extends _AbstractIniSettings
{
    static INSTANCE
    static IDENTIFIER := "interface"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        if (_InterfaceIniSettings.INSTANCE) {
            return _InterfaceIniSettings.INSTANCE
        }

        base.__New()

        _InterfaceIniSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _InterfaceIniSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes[i := "autoCheckClientSettings"] := new _DefaultBoolean(true, i)
    }
}