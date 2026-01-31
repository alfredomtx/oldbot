class _Dropdown extends _AbstractListableControl
{
    static CONTROL := "DDL"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        base.__New(_Dropdown.CONTROL)
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
        this.disable()

        this.runOnEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel)

        this.enable()
    }

    /**
    * @abstract
    * @return string
    */
    defaultOptions()
    {
    }
}
