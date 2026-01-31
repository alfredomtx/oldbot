#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_AbstractControl.ahk

/**
* @property bool _loadAfterAdd
* @property BoundFunc syncStateCallback
*/
class _AbstractStatefulControl extends _AbstractControl
{
    static DEBOUNCE_INTERVAL := 300
    static DEFAULT_STATE_HANDLER := ""

    __New(type)
    {
        base.__New(type)

        this.debounceInterval := this.DEBOUNCE_INTERVAL

        this._loadAfterAdd := true
    }

    /**
    * @param _AbstractSettings class
    * @return this
    */
    state(class)
    {
        _Validation.instanceOf("state", class, _AbstractSettings)
        this.stateHandler := class

        return this
    }

    /**
    * @param _AbstractSettings class
    * @return void
    */
    SET_DEFAULT_STATE(class)
    {
        _Validation.instanceOf("state", class, _AbstractSettings)
        this.DEFAULT_STATE_HANDLER := class
    }

    /**
    * @return void
    */
    RESET_DEFAULT_STATE()
    {
        this.DEFAULT_STATE_HANDLER := ""
    }

    /**
    * @return this
    */
    add()
    {
        if (!this.stateHandler && this.DEFAULT_STATE_HANDLER) {
            this.stateHandler := this.DEFAULT_STATE_HANDLER
        }

        if (this.stateHandler && instanceOf(this, _AbstractListableControl) && !this.getTitle()) {
            this.handleListableTitle()
            return this
        }

        this.addControlNameIfMissing()

        base.add()

        if (this.stateHandler && this._loadAfterAdd) {
            try {
                this.load()
            } catch e {
                _Logger.msgboxException(48, e, A_ThisFunc, this.getControlID())
            }
        }

        return this
    }

    addControlNameIfMissing()
    {
        if (!this.stateHandler || this.getName()) {
            return
        }
        name := this.getNestedName()

        if (name) {
            this.name(name)
        }
    }

    handleListableTitle()
    {
        options := ""
        for _, listOption in this._list {
            options .= listOption.getName() "|" (listOption.isSelected() ? "|" : "")
        }

        this.title(options)

        base.add()

    }

    /**
    * @param int CtrlHwnd
    * @param string GuiEvent
    * @param int EventInfo
    * @param ?int ErrLevel
    * @return void
    * @msgbox
    */
    runOnEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        try {
            this.handleCallback(this._beforeEvent, this)

            this.handleEventFunction(CtrlHwnd, GuiEvent, EventInfo, ErrLevel)

            this.submitSettings()

            this.handleAfterSubmit()
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc, this.getControlID())
        } finally {
            this.handleCallback(this._afterEvent, this)
        }
    }

    /**
    * @param BoundFunc value
    * @return this
    */
    beforeEvent(value)
    {
        _Validation.function("value", value)
        this._beforeEvent := value
        return this
    }

    /**
    * @param BoundFunc value
    * @return this
    */
    afterEvent(value)
    {
        _Validation.function("value", value)
        this._afterEvent := value
        return this
    }

    /**
    * @return void
    * @throws
    */
    handleAfterSubmit()
    {
        if (!this._afterSubmit) {
            return
        }

        if (_A.isArray(this._afterSubmit)) {
            for _, function in this._afterSubmit {
                this.handleFunctionAndCallback(function, this, this.get())
            }

            return
        }

        this.handleFunctionAndCallback(this._afterSubmit, this, this.get())
    }

    /**
    * @param int CtrlHwnd
    * @param string GuiEvent
    * @param int EventInfo
    * @param ?int ErrLevel
    * @return void
    */
    debounceEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        if (this.fn) {
            fn := this.fn
            SetTimer, % fn, Delete
        }

        this.fn := this.runOnEvent.bind(this, CtrlHwnd, GuiEvent, EventInfo, ErrLevel)

        fn := this.fn
        interval := this.debounceInterval
        SetTimer, % fn, -%interval%
    }

    setDebounceInterval(value)
    {
        this.debounceInterval := value

        return this
    }

    /**
    * @return this
    * @throws
    */
    setLoadedValue()
    {
        try {
            name := this.getNestedName()
            value := this.getStateHandlerInstance().get(name)

            if (instanceOf(this, _AbstractCheckableControl)) {
                value := value ? true : false
            }

            this.setWithoutEvent(value)
        } catch e {
            throw e
        }
    }

    /**
    * @throws
    */
    getNestedName()
    {
        nested := this.getNested()
        ; if (instanceOf(this.stateHandler, _MemorySettings)) {
        ;     nested :=
        ; }

        name := this.getName()

        return nested ? nested "." name : name
    }

    /**
    * @return this
    * @throws
    */
    load()
    {
        this.ensureControlExists(A_ThisFunc)

        try {
            this.setLoadedValue()
        } catch e {
            throw e
        }

        return this
    }

    /**
    * @param string|BoundFunc value
    * @return this
    */
    nested(value)
    {
        this.prefix(value)
        this._nested := value

        return this
    }

    /**
    * @return string
    * @throws
    */
    getNested()
    {
        nested := this._nested
        if (isFunction(nested)) {
            try {
                nested := nested.Call()
            } catch e {
                throw e
            }
        }

        return nested ? nested : ""
    }

    /**
    * @return _AbstractSettings
    */
    getStateHandlerInstance()
    {
        className := this.stateHandler.__Class
        return new %className%()
    }

    /**
    * @return void
    * @throws
    */
    submitSettings()
    {
        if (!this.validateRule()) {
            return
        }

        try {
            this.performValidation()
        } catch e {
            msgbox, 48, % "Validation: " this.getControlID(), % e.Message, 20
            return
        }

        if (!this.stateHandler) {
            return
        }

        _Validation.empty("this.stateHandler", this.stateHandler)

        ; OldBotSettings.disableGuisLoading()

        try {
            this.stateHandlerSet(this.get())
        } catch e {
            _Logger.exception(e, A_ThisFunc, "Nested: " nested " | " this.getControlID())
            throw e
        } finally {
            ; OldBotSettings.enableGuisLoading()
        }

        return this
    }

    stateHandlerSet(value)
    {
        nested := this.getNested()
        this.getStateHandlerInstance().submit(this.getName(), value, nested)
    }

    /**
    * @return bool
    */
    validateRule()
    {
        if (!this._rule) {
            return true
        }

        value := this.get()
        try {
            if (this._rule.evaluate(value)) {
                return true
            }
        } catch e {
            Msgbox, 48, % "Validation - " this.getControlID(), % e.Message
            return false
        }

        ruleValue := this._rule.getValue(value)
        if (value == ruleValue) {
            return true
        }

        this.setWithoutEvent(ruleValue)

        return true
    }

    /**
    * @return void
    * @throws
    */
    performValidation()
    {
        if (!this._validation) {
            return
        }
    }

    /**
    * @param BoundFunc value
    * @return this
    */
    setSyncState(value)
    {
        _Validation.empty("value", value, -3)
        _Validation.function("syncStateCallback", value)

        this.syncStateCallback := value
        return this
    }

    /**
    * @return void
    * @throws
    */
    syncState()
    {
        if (!this.syncStateCallback) {
            return
        }

        this.disable()
        try {
            function := this.syncStateCallback
            %function%()
        } catch e {
            _Logger.exception(e, A_ThisFunc, this.getControlID())
            throw e
        } finally {
            this.enable()
        }

        return this
    }

    /**
    * @param bool value
    * @return this
    */
    loadAfterAdd(value)
    {
        this._loadAfterAdd := value

        return this
    }
}
