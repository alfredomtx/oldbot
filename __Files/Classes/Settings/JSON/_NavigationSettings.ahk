#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\JSON\_AbstractJsonSettings.ahk

class _NavigationSettings extends _AbstractJsonSettings
{
    static INSTANCE
    static IDENTIFIER := "navigation"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        if (_NavigationSettings.INSTANCE) {
            return _NavigationSettings.INSTANCE
        }

        base.__New()

        _NavigationSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _NavigationSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes[_Follower.CHECKBOX_NAME] := new _DefaultValue(0)
        this.attributes[_Navigation.CHECKBOX_NAME] := new _DefaultValue(0)

        this.attributes["distance"] := new _DefaultValue(1, 0, 50)
        this.attributes[i := "showLeaderWaypoints"] := new _DefaultBoolean(true, i)
        this.attributes[i := "showFollowerWaypoints"] := new _DefaultBoolean(true, i)

        this.attributes["walkCommandHotkey"] := new _DefaultValue("")
        this.attributes["standCommandHotkey"] := new _DefaultValue("")
        this.attributes["useCommandHotkey"] := new _DefaultValue("")
        this.attributes["useRopeCommandHotkey"] := new _DefaultValue("")
        this.attributes["useShovelCommandHotkey"] := new _DefaultValue("")
        this.attributes["action1CommandHotkey"] := new _DefaultValue("")
        this.attributes["action2CommandHotkey"] := new _DefaultValue("")
        this.attributes["action3CommandHotkey"] := new _DefaultValue("")
    }
}