class _Listbox extends _AbstractListableControl
{
    static CONTROL := "Listbox"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        base.__New(_Listbox.CONTROL)
    }

    add()
    {
        if (this._list) && (!this.getH() && !this.getR()) {
            this.r(this._list.Count())
        }

        base.add()

        return this
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
}
