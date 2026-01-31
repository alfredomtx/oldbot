#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_AbstractControl.ahk

class _Slider extends _AbstractStatefulControl
{
    static CONTROL := "Slider"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        base.__New(_Slider.CONTROL)

        this.option("AltSubmit")
        this.option("Line", 1)
        this.option("Page", 10)
        this.option("Thick", 16)
        this.option("TickInterval", 2)
        this.option("ToolTipBottom")
    }

    /**
    * @abstract
    * @return void
    */
    onEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        this.debounceEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel)
    }
}
