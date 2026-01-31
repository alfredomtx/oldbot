

global MemoryManager

class _AbstractModule extends _BaseClass
{
    static INI_PAUSED_SECTION := "modules_paused"

    static MESSAGE_PAUSE := "pause"
    static MESSAGE_UNPAUSE := "unpause"

    __New()
    {
        guardAgainstInstantiation(this)
    }

    /**
    * @abstract
    */
    functions()
    {
        abstractMethod()
    }

    run()
    {
        _Logger.log(A_ThisFunc, this.IDENTIFIER)

        this.beforeRun()

        for _, function in this.functions()
        {
            function.run()
        }
    }

    enableFunction(function)
    {
        _Logger.log(A_ThisFunc, this.IDENTIFIER ": " function.IDENTIFIER)
        this.getSettings().submit(_AbstractSettings.ENABLED_KEY, 1, function.IDENTIFIER)
        this.start()
    }

    disableFunction(function)
    {
        _Logger.log(A_ThisFunc, this.IDENTIFIER ": " function.IDENTIFIER)
        this.getSettings().submit(_AbstractSettings.ENABLED_KEY, 0, function.IDENTIFIER)
        this.stop()
    }

    /**
    * @param _AbstractModuleFunction function
    * @return bool
    */
    isEnabled(function)
    {
        ; _Logger.info(A_ThisFunc, function.IDENTIFIER ": " boolToString(value))
        value := this.getSettings().get(_AbstractSettings.ENABLED_KEY, function.IDENTIFIER)
        return bool(value)
    }

    /**
    * Checks whether the module has any function enabled, if so, return true to not close the process
    * @abstract
    * @return bool
    */
    hasFunctionEnabled()
    {
        for _, functionClass in this.functions()
        {
            if (this.isEnabled(functionClass)) {
                ; _Logger.log(A_ThisFunc, functionClass.IDENTIFIER)
                return true
            }
        }

        ; _Logger.log(A_ThisFunc, "false")
        return false
    }

    /**
    * @return void
    */
    start()
    {
        _Logger.log(A_ThisFunc, this.IDENTIFIER)
        this.validations()
        this.EXE.start()
    }

    /**
    * @return void
    */
    stop()
    {
        _Logger.log(A_ThisFunc, this.IDENTIFIER)
        if (!this.hasFunctionEnabled()) {
            this.onExit()
        }
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

        _Ravendawn.checkSettingsAndWarnIfRequired(false)
    }

    /**
    * @return _AbstractSettings
    */
    getSettings()
    {
        if (!this.instance) {
            _Validation.empty("this.SETTINGS_CLASS", this.SETTINGS_CLASS)
            class := this.SETTINGS_CLASS
            this.instance := new %class%()
        }

        return this.instance
    }

    checkOldBotRunning(message := true)
    {
        if (!A_IsCompiled) {
            return
        }

        if (!_OldBotExe.isRunning()) {
            if (message) {
                Msgbox, 48,, OldBot is not opened.
            }
            ExitApp
        }
    }

    /**
    * Function to be called when the module is being stopped
    * @remarks should not throw exceptions
    * @return void
    */
    onExit()
    {
        try {
            _Logger.log(A_ThisFunc, this.IDENTIFIER)

            for _, function in this.functions()
            {
                try {
                    function.onExit()
                } catch e {
                    _Logger.msgboxExceptionOnLocal(e, A_ThisFunc)
                }
            }

            this.EXE.stop()
        } catch e {
            _Logger.msgboxExceptionOnLocal(e, A_ThisFunc)
        }
    }

    beforeRun()
    {
        if (A_IsCompiled) {
            if (!this.hasFunctionEnabled()) {
                _Logger.log(A_ThisFunc, this.IDENTIFIER ": no function enabled, exiting")
                ExitApp
            }
        }

        this.checkOldBotRunning()

        _Ini.delete(this.IDENTIFIER, this.INI_PAUSED_SECTION)


        fn := this.handleMessage.bind(this)
        OnMessage(0x4a, fn) ; 0x4a is WM_COPYDATA

        _Validation.empty("this.EXE", this.EXE)
        this.EXE.writePID()
        fn := this.onExit.bind(this)
        OnExit(fn)


        if (TibiaClient.getClientAreaFunctions(StrReplace(A_ScriptName, ".exe", "")) = false) {
            return false
        }

        /*
        If client is disconnected, loop until it is connected again
        or exitapp if tibia window doesn't exist anymore
        */
        ; if (A_IsCompiled) {
        if (this.__Class != _ReconnectModule.__Class && this.__Class != _MarketModule.__Class) {
            TibiaClient.isDisconnectedLoopWaitOrExit(this.IDENTIFIER)
        }
        ; }

        classLoaded("_MemoryManager", _MemoryManager)
        global MemoryManager := new _MemoryManager(injectOnStart := true) ; before all other classes

        /*
        after all initial functions loadings
        */
        Random, R, 0, 400

        if (A_IsCompiled) {
            fn := this.verifyFunctionsFromExe.bind(this)
            SetTimer, % fn, % 4000 + R
            fn := this.checkClientClosedMinimized.bind(this)
            SetTimer, % fn, % 2000 + R
        }

        Process, Priority,, High

        return true
    }

    /**
    * @return string
    */
    getWindowTitle()
    {
        abstractMethod()
    }

    pauseMessage()
    {
        return this.sendMessage(this.MESSAGE_PAUSE)
    }

    sendMessage(string, timeout := 2000)
    {
        try {
            _Logger.log(A_ThisFunc, "Window: " this.getWindowTitle() " | Data:" string)
            return Send_WM_COPYDATA(string, this.getWindowTitle(), timeout)
        } catch e {
            _Logger.exception(e, A_ThisFunc, "Window: " this.getWindowTitle() " | Data:" string)
            throw e
        }
    }

    /**
    * @param int wParam
    * @param int lParam
    * @return bool
    */
    handleMessage(wParam, lParam)
    {
        StringAddress := NumGet(lParam + 2*A_PtrSize) ; Retrieves the CopyDataStruct's lpData member.
        CopyOfData := StrGet(StringAddress) ; Copy the string out of the structure.

        data := CopyOfData
        CopyOfData := "", StringAddress := ""

        _Logger.log(A_ThisFunc, data)

        switch (data) {
            case this.MESSAGE_PAUSE:
                return this.pause()
            case this.MESSAGE_UNPAUSE:
                return this.unpause()
        }

        return false
    }

    /**
    * @return void
    */
    onPause()
    {
    }

    /**
    * @return void
    */
    onUnpause()
    {
    }

    /**
    * @return bool
    */
    unpause()
    {
        Critical, On
        if (A_IsPaused)
        {
            Pause, Off

            this.onUnpause()
        }

        try {
            _Ini.delete(this.IDENTIFIER, this.INI_PAUSED_SECTION)
        } catch e {
            _Logger.exception(e, A_ThisFunc, "_Ini.delete")
        }

        Critical, Off
        return true
    }

    /**
    * @return bool
    */
    pause()
    {
        Critical, On

        try {
            _Ini.write(this.IDENTIFIER, true, this.INI_PAUSED_SECTION)
        } catch e {
            _Logger.exception(e, A_ThisFunc, "_Ini.write")
        }

        try {
            this.onPause()
        } catch e {
            _Logger.exception(e, A_ThisFunc, "this.onPause()")
        }

        Critical, Off
        Pause
        return true
    }
    verifyFunctionsFromExe()
    {
        try {
            CavebotScript.loadSpecificSettingFromExe(this.IDENTIFIER, currentScript, A_ScriptName)

        } catch e {
            if (!A_IsCompiled) {
                _Logger.exception(e, A_ThisLabel, currentScript)
            }
        }
    }

    checkClientClosedMinimized()
    {
        TibiaClient.isClientClosed(false, this.IDENTIFIER) ; check if client is closed and reload if true
        TibiaClient.isClientMinimized(true)
    }
}
