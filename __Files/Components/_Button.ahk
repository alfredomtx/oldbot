
class _Button extends _AbstractControl
{
    static CONTROL := "Button"

    __New()
    {
        base.__New(_Button.CONTROL)

        this.enableAfterEvent := true
    }

    /**
    * @abstract
    * @param int CtrlHwnd
    * @param string GuiEvent
    * @param int EventInfo
    * @param ?int ErrLevel
    * @return void
    * @msgbox
    */
    onEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        this.disable()

        try {
            if (this.isGosubEvent()) {
                this.handleGosubEvent()
            } else {
                this.handleFunctionAndCallback(this._event, this)
            }
        } catch e {
            this.msgboxException(e, A_ThisFunc)
        }

        if (this.enableAfterEvent && this.exists()) {
            this.enable()
        }
    }

    /**
    * @param int CtrlHwnd
    * @param string GuiEvent
    * @param int EventInfo
    * @param ?int ErrLevel
    * @return void
    * @throws
    */
    handleFunction(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        if (this.handleGosubEvent()) {
            return 
        }

        callback := "", e := ""
        try {
            function := this._event
            callback := %function%()
        } catch e {
            _Logger.exception(e, A_ThisFunc, this.getControlID())
        }

        this.handleCallback(callback)

        if (e) {
            throw e
            _Logger.msgboxException(48, e, A_ThisFunc, this.getControlID())
        }
    }

    /**
    * @return this
    */
    keepDisabled()
    {
        this.enableAfterEvent := false
        return this
    }
}
