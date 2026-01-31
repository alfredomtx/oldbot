/**
* @static
*/
class _Navigation extends _AbstractNavigation
{
    static TIMER_INTERVAL := 100
    static CHECKBOX_NAME := "leaderEnabled"
    static CHECKBOX

    static lastCoord := {}
    static targetWindows := {}

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        ; guardAgainstAbstractInstantiation(this)
    }

    run()
    {
        try {
            if (isDisconnected()) {
                this.out("DISCONNECTED")
                return
            }

            CavebotWalker.getCharCoords()

            distance := this.lastCoord.getDistance(posx, posy)
            ; _Logger.log(A_ThisFunc, "distance: " distance)
            if (distance = "") {
                this.lastCoord := new _MapCoordinate(posx, posy, posz, 1, 1)
                this.sendCoordinates(new _NavigationWalk())
            }

            if (this.lastCoord.getDistance(posx, posy) >= this.getSetting("distance")) {
                ; _Logger.log(A_ThisFunc, "sending coord: " posx "," posy ", d: " distance)
                this.sendCoordinates(new _NavigationWalk())
                this.lastCoord := new _MapCoordinate(posx, posy, posz, 1, 1)
                return
            }
        } catch e {
            this.handleException(e)
        }
    }

    /**
    * @return void
    * @throws
    */
    validations()
    {
        base.validations()
        if (!A_IsCompiled)
            return
        if (!this.targetWindows.Count()) {
            throw Exception(txt("Selecione uma janela na lista de Multi Client.", "Select a window on the Multi Client list."))
        }

        _Validation.number("this.getSetting(distance)", this.getSetting("distance"))
    }

    /**
    * @param string name
    * @return mixed
    */
    getSetting(name)
    {
        static class
        if (!class) {
            class := new _NavigationSettings()
        }

        return class.get(name)
    }

    /**
    * Turns off without changing checkbox state
    * @return void
    */
    turnOff()
    {
        OldBotSettings.disableGuisLoading()
        this.firstRun := false
        this.deleteTimer()

        _Follower.CHECKBOX.enable()

        this.saveState()

        OldBotSettings.enableGuisLoading()
    }

    /**
    * @return void
    */
    turnOn()
    {
        OldBotSettings.disableGuisLoading()

        _Follower.CHECKBOX.uncheck()
            .disable()

        this.saveState()

        this.firstRun := true

        this.setTimer()

        OldBotSettings.enableGuisLoading()
    }

    /**
    * @return void
    */
    setFollowerWindow(control, value, event := "", ErrLevel := "")
    {
        if (InStr(event, "E", true)) {
            return
        }

        this.targetWindows := _Arr.clone(control.getSelectedRows())
    }

    /**
    * @return void
    */
    setup()
    {
        static init
        if (init) {
            return
        }

        TibiaClient.getClientArea()
        CavebotWalker := new _CavebotWalker()

        init := true
    }

    /**
    * @return void
    */
    deleteTimer()
    {
        SetTimer, NavigationLeaderTimer, Delete
    }

    /**
    * @return void
    */
    setTimer()
    {
        this.deleteTimer()
        SetTimer, NavigationLeaderTimer, % _Navigation.TIMER_INTERVAL
    }

    /**
    * @param _NavigationAction action
    * @return void
    */
    sendCoordinates(action)
    {
        if (!this.targetWindows.Count()) {
            this.sendMessage(MAIN_GUI_TITLE, action)
            return
        }

        for _, window in this.targetWindows {
            this.sendMessage(window, action)
        }
    }

    /**
    * @param string windowTitle
    * @param _NavigationAction action
    * @return void
    */
    sendMessage(windowTitle, action)
    {
        static counter := 0
        counter++
        _Validation.instanceOf("action", action, _AbstractNavigationAction)

        OutputDebug(_Navigation.__Class, "Sending coords " this.lastCoord.toString() ", counter: " counter ", action: " action.toString() ", window: " windowTitle)
        Send_WM_COPYDATA(_Follower.__Class "|" this.lastCoord.toString() "," counter "|" action.toMessage(), windowTitle)
    }

    out(msg)
    {
        OutputDebug(_Navigation.__Class, msg)
    }

    /**
    * @return ?_MapCoordinate
    */
    getFromMousePosition()
    {
        ; setSystemCursor("IDC_CROSS")

        WinActivate()

        Loop {
            Tooltip, % txt("Click ou pressione ""Espaço""`n""Esc"" para cancelar", "Clique ou press ""Space""`n""Esc"" to cancel")
            Sleep, 25
            if (GetKeyState("LButton")) {
                break
            }

            if (GetKeyState("Space"))
                break
            if (GetKeyState("Esc")) {
                Tooltip
                ; restoreCursor()
                return false
            }
        }

        ; restoreCursor()
        Tooltip
        Gui, CavebotGUI:Show

        return _MapCoordinate.FROM_MOUSE_POS()
    }

    /**
    * @param Exception e
    * @return void
    * @msgbox
    * 
    */
    handleException(e)
    {
        _Logger.exception(e, A_ThisFunc)
        msgbox, 16, % _Follower.__Class, % e.Message "`n" e.What 
    }

    /**
    * @return void
    */
    standCommandHotkey()
    {
        function := this.standCommand()
        %function%()
    }

    /**
    * @return ?callable
    */
    standCommand()
    {
        try {
            return this.getSendCommand(new _NavigationStand(), 1)
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc)
        }
    }

    /**
    * @return void
    */
    walkCommandHotkey()
    {
        function := this.walkCommand()
        %function%()
    }

    /**
    * @return ?callable
    */
    walkCommand()
    {
        try {
            return this.getSendCommand(new _NavigationWalk(), 3)
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc)
        }
    }

    /**
    * @return void
    */
    useCommandHotkey()
    {
        function := this.useCommand()
        %function%()
    }

    /**
    * @return ?callable
    */
    useCommand()
    {
        try {
            return this.getSendCommand(new _NavigationUse(), 2)
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc)
        }
    }

    /**
    * @return void
    */
    useRopeCommandHotkey()
    {
        function := this.useRopeCommand()
        %function%()
    }

    /**
    * @return ?callable
    */
    useRopeCommand()
    {
        try {
            return this.getSendCommand(new _NavigationUseRope(), 2)
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc)
        }
    }

    /**
    * @return void
    */
    useShovelCommandHotkey()
    {
        function := this.useShovelCommand()
        %function%()
    }

    /**
    * @return ?callable
    */
    useShovelCommand()
    {
        try {
            return this.getSendCommand(new _NavigationUseShovel(), 2)
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc)
        }
    }

    /**
    * @return void
    */
    actionCommandHotkey(number)
    {
        function := this.actionCommand(number)
        %function%()
    }

    /**
    * @param int number
    * @return ?callable
    */
    actionCommand(number)
    {
        try {
            this.setup()

            return this.sendCoordinates.bind(this, new _NavigationAction(number))
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc)
        }
    }

    /**
    * @param _AbstractNavigationAction action
    * @return BoundFunc
    */
    getSendCommand(action, range := 1)
    {
        this.setup()

        if (!coordinate := this.getFromMousePosition()) {
            return
        }

        if (range == 3) {
            coordinate.x -= 1
            coordinate.y -= 1
        }

        coordinate.w := range
        coordinate.h := range

        if (this.getSetting("showLeaderWaypoints")) {
            coordinate.showOnScreenFor(2000, 50, "red", action.toString())
        }

        this.lastCoord := coordinate
        WinActivate()

        return this.sendCoordinates.bind(this, action)
    }


    sendFromMapViewer(action, coordinate)
    {
        this.lastCoord := coordinate
        this.sendCoordinates(action)
    }

    /**
    * @return void
    */
    resetFollowerWindows()
    {
        this.targetWindows := {}
    }
}
