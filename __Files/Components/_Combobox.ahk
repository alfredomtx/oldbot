class _Combobox extends _AbstractListableControl
{
    static CONTROL := "Combobox"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        base.__New(_Combobox.CONTROL)
    }

    /**
    * @abstract
    * @param int CtrlHwnd
    * @param string GuiEvent
    * @param int EventInfo
    * @param ?int ErrLevel
    * @return this
    */
    onEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        this.runOnEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel)
    }

    /**
    * @abstract
    * @return string
    */
    defaultOptions()
    {
    }
}
