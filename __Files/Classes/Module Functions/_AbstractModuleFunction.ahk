
class _AbstractModuleFunction extends _AbstractModuleFunction.Getters
{
    __New()
    {
        guardAgainstInstantiation(this)
    }

    /**
    * @param _Checkbox checkbox
    * @param mixed value
    * @return void
    */
    toggleEvent(checkbox, value)
    {
        this.toggle(value)
    }

    /**
    * @return void
    */
    toggleWithEvent()
    {
        value := !this.MODULE.isEnabled(this)

        if (value) {
            this.enable()
        } else {
            this.disable()
        }
    }

    /**
    * @param _Checkbox checkbox
    * @param mixed value
    * @return void
    */
    toggle(value := "")
    {
        this.beforeToggle()

        if (value = "") {
            value := !this.MODULE.isEnabled(this)
        }

        if (!value) {
            this.stop()
        } else {
            try {
                this.start()
            } catch e {
                _Logger.msgboxException(48, e, A_ThisFunc)
                this.disable()
            }
        }

        this.afterToggle()
    }

    /**
    * Disable checkbox and turn off
    * @return void
    */
    disable()
    {
        _Logger.log(A_ThisFunc, this.IDENTIFIER)
        try {
            this.CHECKBOX.uncheck()
            this.MODULE.disableFunction(this)
        } catch {
            ; swallow because it can be callled when the gui is not existent yet(when loading script)
        }
        restoreCursor()
    }

    /**
    * @return void
    */
    enable()
    {
        _Logger.log(A_ThisFunc, this.IDENTIFIER)
        try {
            this.CHECKBOX.check()
            this.MODULE.enableFunction(this)
        } catch {
            ; swallow because it can be callled when the gui is not existent yet(when loading script)
        }
        restoreCursor()
    }

    /**
    * Turns off without changing checkbox state
    * @return void
    */
    stop()
    {
        _Logger.log(A_ThisFunc, this.IDENTIFIER)
        this.MODULE.stop()
    }

    /**
    * @return void
    */
    start()
    {
        _Logger.log(A_ThisFunc, this.IDENTIFIER)
        this.validations()
        this.MODULE.start()
    }

    /**
    * @return void
    */
    beforeToggle()
    {
        ; OldBotSettings.disableGuisLoading()
    }

    /**
    * @return void
    */
    afterToggle()
    {
        ; OldBotSettings.enableGuisLoading()
    }

    /**
    * @return void
    * @throws
    */
    validations()
    {
    }

    /**
    * @param string message
    * @throws
    */
    exception(message, extra := "")
    {
        ; throw Exception(message, this.DISPLAY_NAME " (" this.IDENTIFIER ")")
        throw Exception(message, this.DISPLAY_NAME)
    }

    /**
    * Function to be called when the module is being stopped
    * @remarks should not throw exceptions
    * @return void
    */
    onExit()
    {
        _Logger.log(A_ThisFunc, this.__Class)
    }

    class Getters extends _AbstractModuleFunction.Setters
    {
        /**
        * @param string key
        * @return string
        */
        getSetting(key)
        {
            return this.MODULE.getSettings().get(key)
        }
    }

    class Setters extends _AbstractModuleFunction.Predicates
    {
    }

    class Predicates extends _AbstractModuleFunction.Factory
    {
        /**
        * Checks whether the module has any function enabled, if so, return true to not close the process
        * @abstract
        * @return bool
        */
        isEnabled()
        {
            return this.MODULE.isEnabled(this)
        }

    }

    class Factory extends _AbstractModuleFunction.Base
    {
    }

    class Base extends _BaseClass
    {
    }
}
