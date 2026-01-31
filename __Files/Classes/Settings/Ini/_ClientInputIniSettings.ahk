#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Ini\_AbstractIniSettings.ahk

identifier := _ClientInputIniSettings.getIdentifier()
%identifier%Ini := {}

class _ClientInputIniSettings extends _AbstractIniSettings
{
    static INSTANCE
    static IDENTIFIER := "clientInput"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        if (_ClientInputIniSettings.INSTANCE) {
            return _ClientInputIniSettings.INSTANCE
        }

        base.__New()

        _ClientInputIniSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _ClientInputIniSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes["writeMessagesWithPasteAction"] := new _DefaultBoolean(false, "writeMessagesWithPasteAction")
        this.attributes["defaultMenuClickMethod"] := new _DefaultBoolean(true, "defaultMenuClickMethod")
        this.attributes["classicControlDisabled"] := new _DefaultBoolean(false, "classicControlDisabled")
    }
}