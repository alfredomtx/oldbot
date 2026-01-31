#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Ini\_AbstractIniSettings.ahk

identifier := _LauncherIniSettings.getIdentifier()
%identifier%Ini := {}

class _LauncherIniSettings extends _AbstractIniSettings
{
    static INSTANCE
    static IDENTIFIER := "launcher"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        if (_LauncherIniSettings.INSTANCE) {
            return _LauncherIniSettings.INSTANCE
        }

        base.__New()

        _LauncherIniSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _LauncherIniSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes["autoUpdate"] := new _DefaultBoolean(1, "autoUpdate")
        this.attributes["autoOpen"] := new _DefaultBoolean(1, "autoOpen")
    }
}