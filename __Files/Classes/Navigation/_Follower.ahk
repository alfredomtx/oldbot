/**
* @property _AbstractNavigationAction action
* @property _MapCoordinate targetCoord
*/
class _Follower extends _AbstractNavigation
{
    static CHECKBOX_NAME := "followerEnabled"
    static CHECKBOX

    static RECEIVED_COORDINATE
    static RUNNING_COORDINATE

    static RUNNING_COORDINATES := false

    static RUN_TIMER_INTERVAL := 200

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param string coordsString
    * @param ?int number
    * @param class action
    */
    receiveCoordinates(coordsString, action, number := "")
    {
        if (!new _NavigationSettings().get(_Follower.CHECKBOX_NAME)) {
            this.deleteTimer()
            return
        }

        _Follower.RECEIVED_COORDINATE := { "coord": coordsString, "action": action, "number": number}

        _logger.log(A_ThisFunc, "Received coords: " coordsString ", action: " action)
        _Logger.log(A_ThisFunc, "Last coords: " _Follower.RECEIVED_COORDINATE.coord ", action: " _Follower.RECEIVED_COORDINATE.action " | " _Follower.RECEIVED_COORDINATE.Count())

        this.initializeTimer()
    }

    /**
    * @return void
    */
    run()
    {
        if (_Follower.RUNNING_COORDINATES) {
            _Logger.log(A_ThisFunc, "Already running coords")
            return
        }

        try {
            if (_Follower.RUNNING_COORDINATE == _Follower.RECEIVED_COORDINATE) {
                _Logger.log(A_ThisFunc, "Stopping run timer")
                this.deleteTimer()
                return
            }

            _Follower.RUNNING_COORDINATES := true
            _Follower.RUNNING_COORDINATE := _Follower.RECEIVED_COORDINATE

            data := _Follower.RUNNING_COORDINATE
            ; for _, data in coordinates {

            coord := data.coord
            action := data.action
            number := data.number
            OutputDebug(_Follower.__Class, "Running coords " coord ", action: " action)

            action := new _NavigationActionFactory(action, number)
            if (this.isActionScript(action)) {
                this.runAction(action)

                return
            }

            coordinate := _MapCoordinate.FROM_STRING(coord)
                .setOption(_MapCoordinate.PRESS_ESC_BEFORE_CLICK, false)

            this.runCoordinate(coordinate, action)
            ; }
        } catch e {
            this.errorNotification(e)
            ; this.handleException(e)
        } finally {
            _Follower.RUNNING_COORDINATES := false
        }
    }

    /**
    * @param _MapCoordinate coordinate
    * @param _AbstractNavigationAction action
    * @return void
    */
    runCoordinate(coordinate, action)
    {
        if (isDisconnected()) {
                new _Notification().title("DISCONNECTED")
                .message("Follower is disconnected.")
                .show()

            return
        }

        char := _CharCoordinate.GET()

        if (this.shouldShowOnScreen()) {
            showTimer := coordinate.showCoordinateFromTimer.bind(coordinate, "blue", "follower`n" action.toString())
            showTimer.call()
            SetTimer, % showTimer, Delete
            SetTimer, % showTimer, 50

        }
        _Logger.log(A_ThisFunc, "coordinate: " coordinate.toString() ", char: " char.ToString())

        try {
            if (new _WalkToCoordinate(coordinate, this.arrivedCallables(), this.abortCallables()).run()) {
                _Logger.log(A_ThisFunc, "arrived at: " coordinate.toString() ", char: " char.ToString())
                if (this.shouldShowOnScreen()) {
                    coordinate.stopShowFromTimer(showTimer)
                }
                this.handleArrivedAction(coordinate, action)
            }
        } catch e {
            this.errorNotification(e)
        } finally {
            if (this.shouldShowOnScreen()) {
                coordinate.stopShowFromTimer(showTimer)
            }
        }
    }

    /**
    * @return this
    */
    initializeTimer()
    {
        if (!this.timerFunction) {
            this.timerFunction := this.run.bind(this)
        }

        this.deleteTimer()

        fn := this.timerFunction
        SetTimer, % fn, % this.RUN_TIMER_INTERVAL

        return this
    }

    /**
    * @return this
    */
    deleteTimer()
    {
        if (!this.timerFunction) {
            return this
        }

        fn := this.timerFunction
        SetTimer, % fn, Delete
        return this
    }

    errorNotification(e)
    {
        _Logger.exception(e, A_ThisFunc)

            new _Notification().title("Follower")
            .message(e.Message)
            .icon(16)
            .show()
    }

    /**
    * @param _AbstractNavigationAction action
    * @return void
    */
    runAction(action)
    {
        if (isDisconnected()) {
                new _Notification().title("DISCONNECTED").show()

            return
        }

        if (!waypointsObj.HasKey("Special")) {
            return
        }

        ActionScript.runactionwaypoint({1: "Navigation" action.getNumber(), 2: "Special"})
    }

    /**
    * @param _MapCoordinate coordinate
    * @param _AbstractNavigationAction action
    * @return void
    */
    handleArrivedAction(coordinate, action)
    {
        switch (action.__Class) {
            case _NavigationWalk.__Class, case _NavigationStand.__Class:
                return

            case _NavigationUse.__Class:
                _CavebotWalker.beforePerformUseActionSqm()
                    new _UseSqm(coordinate.getSqmPosition())

            case _NavigationUseRope.__Class:
                _CavebotWalker.beforePerformUseActionSqm()
                    new _UseChangeFloorItem(coordinate, "rope")

            case _NavigationUseShovel.__Class:
                _CavebotWalker.beforePerformUseActionSqm()
                    new _UseChangeFloorItem(coordinate, "shovel")
        }
    }

    /**
    * @return void
    */
    out(msg)
    {
        OutputDebug(_Follower.__Class, msg)
    }

    /**
    * @return void
    */
    turnOn()
    {
        OldBotSettings.disableGuisLoading()

        _Navigation.CHECKBOX.uncheck()
            .disable()

        this.saveState()

        OldBotSettings.enableGuisLoading()
    }

    /**
    * Turns off without changing checkbox state
    * @return void
    */
    turnOff()
    {
        OldBotSettings.disableGuisLoading()

        _Navigation.CHECKBOX.enable()
        this.saveState()

        OldBotSettings.enableGuisLoading()
    }

    setup()
    {
        global
        TibiaClient.getClientArea()
        CavebotHandler := new _CavebotHandler()
        CavebotSystem := new _CavebotSystem()
        CavebotWalker := new _CavebotWalker()
        CavebotSystem.adjustMinimap()
    }

    handleException(e)
    {
        _Logger.exception(e, A_ThisFunc)
        msgbox, 16, % _Follower.__Class, % e.Message "`n" e.What
    }

    /**
    * @return array
    */
    arrivedCallables()
    {
        return {}
    }

    /**
    * @return array
    */
    abortCallables()
    {
        return {}
    }

    ;#Region Predicates

    /**
    * @param _AbstractNavigationAction action
    * @return bool
    */
    shouldShowOnScreen()
    {
        return new _NavigationSettings().get("showFollowerWaypoints")
        static value
        if (value != "") {
            return value

        }

        return value := new _NavigationSettings().get("showFollowerWaypoints")
    }

    isActionScript(action)
    {
        return action.__Class = _NavigationAction.__Class
    }
    ;#Endregion
}