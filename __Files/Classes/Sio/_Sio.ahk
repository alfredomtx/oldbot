
/**
* @static
*/
Class _Sio extends _BaseClass
{
    static IDENTIFIER := "sioFriend"
    static CHECKBOX
    static STATE_HANDLER := _SioSettings.__Class

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        ; guardAgainstAbstractInstantiation(this) 
    }

    /**
    * Checks whether the module has any function enabled, if so, return true to not close the process
    * @abstract
    * @return bool
    */
    hasFunctionEnabled()
    {
        for sioName, atributes in sioFriendObj {
            if (atributes.enabled) {
                return true
            }
        }

        return false
    }

    /**
    * @param _Checkbox checkbox
    * @param mixed value
    * @return void
    */
    toggle(checkbox, value)
    {
        playerName := new _SioGUI().getPlayerName() 

        if (value = 0) {
            this.turnOff(playerName)
            return
        } 

        try {
            this.beforeRun()

            this.turnOn(playerName)
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc)
            return this.abort.bind(this, playerName)
        }
    }

    /**
    * Disable checkbox and turn off
    * @return void
    */
    abort(playerName)
    {
        _Sio.CHECKBOX.uncheck()
        this.syncCheckboxState(playerName)

        this.turnOff(playerName)
    }

    syncCheckboxState(playerName)
    {
        guiInstance := new _SioGUI()

        _Sio.CHECKBOX.setSyncState(guiInstance.syncCheckboxState.bind(guiInstance, _Sio.CHECKBOX, playerName))
            .syncState()
    }

    /**
    * Turns off without changing checkbox state
    * @return void
    */
    turnOff(playerName)
    {
        this.saveState(playerName)
        this.syncCheckboxState(playerName)
        this.updateUiElements(playerName)

        if (!this.hasFunctionEnabled()) {
            _SioFriendExe.stop()
        }
    }

    /**
    * @return void
    */
    turnOn(playerName)
    {
        this.saveState(playerName)
        this.syncCheckboxState(playerName)
        this.updateUiElements(playerName)

        _SioFriendExe.start()
    }

    /**
    * Save the current state (enabled/disabled)
    * @return void
    */
    saveState(nested)
    {
        static stateHandlerInstance
        if (!stateHandlerInstance) {
            class := _Sio.STATE_HANDLER
            stateHandlerInstance := new %class%()
        }

        name := _Sio.CHECKBOX.getName()

        stateHandlerInstance.submit(name, _Sio.CHECKBOX.get(), nested)
    }

    /**
    * Update any other UI elements that is not the main checkbox
    * @return void
    */
    updateUiElements(playerName)
    {
            new _SioGUI().updateSioRow(playerName)
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
    }

    /**
    * @return void
    * @throws
    */
    validations()
    {
        try {
            TibiaClient.checkClientSelected()
        } catch e {
            throw Exception(e.Message, 2)
        }

        playerName := new _SioGUI().getPlayerName() 

        if (empty(sioFriendObj[playerName].image)) {
            throw Exception(txt("Não há imagem do nome para esse player """ playerName """.`n`nClique no botão ""Capturar imagem do Player"".", "There is no image of the name for this player """ playerName """.`n`nClick on ""Get player image"" button."))
        }
    }

    /**
    * @return void
    * @throws
    */
    setup()
    {

    }

    saveSioFriend(saveCavebotScript := true)
    {
        scriptFile.sioFriend := sioFriendObj
        if (saveCavebotScript = true)
            CavebotScript.saveSettings(A_ThisFunc)
    }
}