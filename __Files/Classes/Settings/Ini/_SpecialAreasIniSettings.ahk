#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Ini\_AbstractIniSettings.ahk

class _SpecialAreasIniSettings extends _AbstractIniSettings
{
    static INSTANCE
    static IDENTIFIER := "specialAreas"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        if (_SpecialAreasIniSettings.INSTANCE) {
            return _SpecialAreasIniSettings.INSTANCE
        }

        base.__New()

        _SpecialAreasIniSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _SpecialAreasIniSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes[i := "enabled"] := new _DefaultBoolean(true, i)
        this.attributes[i := "type"] := new _DefaultEnum(_SpecialArea.TYPE_BLOCKED_FISHING, [_SpecialArea.TYPE_BLOCKED
            , _SpecialArea.TYPE_BLOCKED_FISHING
            , _SpecialArea.TYPE_CHANGE_FLOOR
            , _SpecialArea.TYPE_NONE], i)
    }
}