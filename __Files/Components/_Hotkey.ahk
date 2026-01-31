#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_AbstractControl.ahk

class _Hotkey extends _AbstractStatefulControl
{
    static CONTROL := "Hotkey"
    static DEBOUNCE_INTERVAL := 500

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        base.__New(_Hotkey.CONTROL)
    }

    /**
    * @abstract
    * @param int CtrlHwnd
    * @param string GuiEvent
    * @param int EventInfo
    * @param ?int ErrLevel
    * @return void
    */
    onEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        this.debounceEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel)
    }

    /**
    * @return this
    */
    noModifiers()
    {
        this.option("Limit128")
        return this
    }

    /**
    * When setting a value programatically by control.set(), the hotkey control is not triggering its event
    * @return this
    * @throws
    */
    set(value)
    {
        base.set(value)
        this.onEvent(this.getHwnd(), this._event, 0)

        return this
    }

    parent(control := "")
    {
        base.parent(control)

        if (empty(this.getY())) {
            this.yp(-3)
        }

        return this
    }
}
