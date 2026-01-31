#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_AbstractCheckableControl.ahk

/**
* @WARNING: only works with two radios for the group, using binary value 0 and 1 for the state
*/
class _Radio extends _AbstractCheckableControl
{
    static CONTROL := "Radio"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        base.__New(_Radio.CONTROL)

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
        this.disable()

        value := this.get()

        this.runOnEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel)

        /*
        autohotkey takes care of unchecking the other radio box, but setting the state manually is needed
        */
        for _, control in this._related {
            control.stateHandlerSet(!value)
            control.setWithoutEvent(!value)
        }

        this.enable()
    }

    related(controls*)
    {
        this._related := {}
        for _, control in controls {
            _Validation.instanceOf("control", control, _Radio)

            this._related.Push(control)
        }

        return this
    }
}
