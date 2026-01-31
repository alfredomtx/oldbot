#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Ini\_AbstractIniSettings.ahk

identifier := _CavebotIniSettings.getIdentifier()
%identifier%Ini := {}

class _CavebotIniSettings extends _AbstractIniSettings
{
    static INSTANCE
    static IDENTIFIER := "cavebot"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        if (_CavebotIniSettings.INSTANCE) {
            return _CavebotIniSettings.INSTANCE
        }

        base.__New()

        _CavebotIniSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _CavebotIniSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        ;#region Shared
        this.attributes[i := "pauseHotkey"] := new _DefaultString("+End", i)
        this.attributes[i := "unpauseHotkey"] := new _DefaultString("!End", i)

        this.attributes[i := "addActionWithExamples"] := new _DefaultBoolean(true, i)
        this.attributes[i := "setWaypointChangesOnCavebot"] := new _DefaultBoolean(true, i)
        this.attributes[i := "showPath"] := new _DefaultBoolean(false, i)
        this.attributes[i := "useSpecialAreasToWalk"] := new _DefaultBoolean(false, i)

        this.attributes[i := "changeFloorDelay"] := new _DefaultValue(200, 200, 1000, i).setType(lang("ms", false))
        this.attributes[i := "stopWalkingDelay"] := new _DefaultValue(50, 50, 1000, i).setType(lang("ms", false))
        this.attributes[i := "walkDelay"] := new _DefaultValue(125, 125, 1000, i).setType(lang("ms", false))

        this.attributes[i := "turnChatOffAfterMessages"] := new _DefaultBoolean(true, i)
        ;#endregion


        this.attributes[i := "adjustMinimapAddWaypoint"] := new _DefaultBoolean(true, i)
        this.attributes[i := "startGmOnScreenAlert"] := new _DefaultBoolean(false, i)
    }

}