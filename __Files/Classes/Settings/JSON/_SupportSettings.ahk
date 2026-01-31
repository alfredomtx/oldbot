#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\JSON\_AbstractJsonSettings.ahk

class _SupportSettings extends _AbstractJsonSettings
{
    static INSTANCE
    static IDENTIFIER := "support"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        if (_SupportSettings.INSTANCE) {
            return _SupportSettings.INSTANCE
        }

        base.__New()

        _SupportSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _SupportSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes["magnifier.transparency"] := new _DefaultValue(_Magnifier.TRANSPARENCY_MAX, _Magnifier.TRANSPARENCY_MIN, _Magnifier.TRANSPARENCY_MAX, "transparency")
        this.attributes["magnifier.width"] := new _DefaultValue(_Magnifier.WIDTH_MIN, _Magnifier.WIDTH_MIN, _Magnifier.WIDTH_MAX, "width")
        this.attributes["magnifier.height"] := new _DefaultValue(_Magnifier.HEIGHT_MIN, _Magnifier.HEIGHT_MIN, _Magnifier.HEIGHT_MAX, "height")
        this.attributes["magnifier.zoom"] := new _DefaultValue(_Magnifier.ZOOM_MAX, _Magnifier.ZOOM_MIN, _Magnifier.ZOOM_MAX, "height")
        this.attributes["magnifier.zoom"] := new _DefaultValue(_Magnifier.ZOOM_MAX, _Magnifier.ZOOM_MIN, _Magnifier.ZOOM_MAX, "height")

        this.attributes["autoEatFood"] := new _DefaultBoolean(false, "autoEatFood")
        this.attributes["eatFood.hotkey"] := new _DefaultValue("")
    }

    /**
    * @param string name
    * @param mixed value
    * @param null|string|function nested
    * @return void
    */
    submit(name, value, nested := "")
    {
        ; _Validation.empty("nested", nested)

        base.submit(name, value, nested)
    }
}