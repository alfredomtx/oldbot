

class _AbstractNavigation extends _BaseClass
{
    run()
    {
        abstractMethod()
    }

    turnOff()
    {
        abstractMethod()
    }

    turnOn()
    {
        abstractMethod()
    }

    /**
    * Disable checkbox and turn of
    * @return void
    */
    abort()
    {
        this.CHECKBOX.uncheck()
        this.turnOff()
    }

    setup()
    {
        abstractMethod()
    }

    /**
    * @param _Checkbox checkbox
    * @param mixed value
    * @return void
    */
    toggle(checkbox, value)
    {
        if (value = 0) {
            this.turnOff()
            return
        } 

        try {
            this.beforeRun()

            this.turnOn()
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc)
            return this.abort.bind(this)
        }
    }

    /**
    * Save the current state (enabled/disabled)
    * @return void
    */
    saveState()
    {
        name := this.CHECKBOX.getName()

            new _NavigationSettings().submit(name, this.CHECKBOX.get())

        this.CHECKBOX.syncShortcut()
    }

    /**
    * @return void
    */
    beforeRun()
    {
        static init
        if (!init) {
            init := true
            this.setup()
        }

        this.validations()
        this.intializeCommonAreas()
    }

    /**
    * @return void
    * @throws
    */
    validations()
    {
        _Validation.true("isMemoryCoords", CavebotScript.isMemoryCoords())
        _Validation.true("isCoordinate", CavebotScript.isCoordinate())
        _Validation.connected()
    }

    intializeCommonAreas()
    {
            new _GameWindowArea()
            new _CharPosition()
            new _MinimapArea()
            new _SideBarsArea()
    }
}