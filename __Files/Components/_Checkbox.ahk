#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_AbstractCheckableControl.ahk

class _Checkbox extends _AbstractCheckableControl
{
    static CONTROL := "Checkbox"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        base.__New(_Checkbox.CONTROL)
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
        this.syncShortcut()
        this.runOnEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel)
        value := this.get()

        if (this._checkedEvent && value) {
            this.handleFunctionAndCallback(this._checkedEvent, this, value)
        }

        if (this._uncheckedEvent && !value) {
            this.handleFunctionAndCallback(this._uncheckedEvent, this, value)
        }

        this.syncShortcut()

        this.enable()
    }



    /**
    * GuiControl does not trigger event on Checkbox
    * @return this
    */
    set(value)
    {
        base.set(value)
        this.syncShortcut(value)
    }

    /**
    * @return this
    */
    button()
    {
        return this.option("0x1000")
    }

    /**
    * @return bool
    */
    hasShortcut()
    {
        name := this.getName()
        switch (name) {
            case _Navigation.CHECKBOX_NAME: return true
            case _Follower.CHECKBOX_NAME: return true
            case _Magnifier.CHECKBOX_NAME: return true
        }

        nested := this.getNested()
        identifier := nested ? nested : name

        stateClass := this.getStateHandlerInstance()

        for _, module in _Modules.getList()
        {
            if (module.SETTINGS_CLASS != stateClass.__Class) {
                continue
            }

            for _, function in module.functions()
            {
                if (identifier = _AbstractSettings.ENABLED_KEY && stateClass.IDENTIFIER = function.IDENTIFIER)  { ; fishing
                    return true
                }

                if (identifier = function.IDENTIFIER) {
                    return true
                }
            }
        }

        return false
    }

    /**
    * @return void
    */
    syncShortcut(value := "")
    {
        if (!this.hasShortcut()) {
            return
        }

        name := this.getName()
        nested := this.getNested()
        if (nested) {
            name := nested
        }

        if (name = _AbstractSettings.ENABLED_KEY) {
            name := this.getStateHandlerInstance().IDENTIFIER
        }

        checkbox_setvalue(name, value ? value : this.get())
    }
}
