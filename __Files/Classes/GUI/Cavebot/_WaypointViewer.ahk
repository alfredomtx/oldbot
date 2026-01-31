Class _WaypointViewer extends _BaseClass
{
    static QUICK_SHOW_DELAY := 1500
    static AUTO_SHOW_TIMER := 50

    __New()
    {
    }

    checkboxes()
    {
        this.w := 34

        Gui, CavebotGUI:Font, Bold

        this.quickShowWaypointsCheckbox()
        this.showWaypointsCheckbox()

        Gui, CavebotGUI:Font, Norm
        Gui, CavebotGUI:Font, 
    }

    quickShowWaypointsCheckbox()
    {
        this.quickShowCheckbox := new _Button().name("quickShowWaypoints")
            .x("+1").y("p+0").w(this.w).h(24)
            .disabled(scriptSettingsObj.cavebotFunctioningMode = "markers")
            .tt("Mostra na tela os waypoints selecionados por " this.QUICK_SHOW_DELAY " milissegundos", "Show on screen the selected waypoints for " this.QUICK_SHOW_DELAY " milliseconds")
            .icon(_Icon.get(_Icon.SQUARE), "l1 s22")
            .event(this.quickShowWaypoints.bind(this))
            .add()
    }

    showWaypointsCheckbox()
    {
        this.autoShowCheckbox := new _Checkbox().name("showWaypoints")
            .x("+1").y("p+0").w(this.w).h(24)
            .disabled(scriptSettingsObj.cavebotFunctioningMode = "markers")
            .tt("Mostra constantemente na tela o waypoint atual ou os waypoints selecionados.", "Show on screen constantly the current waypoint or the selected waypoints.")
            .option("0x1000")
            .event(this.autoShowWaypoints.bind(this))
            .icon(_Icon.get(_Icon.EYE), "s26")
            .add()
    }

    beforeShowWaypoints()
    {
        _Validation.connected()
        TibiaClient.checkClientSelected()
    }

    quickShowWaypoints()
    {
        try {
            this.beforeShowWaypoints()
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc)
            return 
        }

        this.autoShowCheckbox.uncheck()

        this.setWaypointsToShow()

        this.showWaypoints()

        fn := this.stopShowingWaypoints.bind(this)
        SetTimer, % fn, Delete
        SetTimer, % fn, % "-" this.QUICK_SHOW_DELAY
    }

    stopShowingWaypoints()
    {
        this.deleteShowWaypointsTimer()
        _MapCoordinate.HIDE_ALL()
        this.waypointsToShow := {}
    }

    autoShowWaypoints(checkbox, value)
    {
        this.stopShowingWaypoints()

        if (!value) {
            return
        }

        try {
            this.beforeShowWaypoints()
        } catch e {
            checkbox.uncheck()
            _Logger.msgboxException(48, e, A_ThisFunc)
            return 
        }

        this.setWaypointsToShow()

        this.runAutoShowWaypoints()

    }

    runAutoShowWaypoints()
    {
        fn := this.getShowTimer()
        SetTimer, % fn, % this.AUTO_SHOW_TIMER
    }

    getShowTimer()
    {
        static timer
        if (timer) {
            return timer
        }

        return timer := this.showWaypoints.bind(this)
    }

    deleteShowWaypointsTimer()
    {
        fn := this.getShowTimer()
        SetTimer, % fn, Delete
    }

    /**
    * @param ?string waypoint
    * @param ?string tabName
    * @return void
    */
    setWaypointsToShow(waypoint := "" , tabName := "")
    {
        if (waypoint && tabName) {
            this.setFromCurrentWaypoint(waypoint, tabName)
            return
        }

        selectedWaypoints := WaypointHandler.getSelectedWaypoints(false)
        if (!selectedWaypoints) {
            if (scriptSettingsObj.startTab && scriptSettingsObj.startTab = tab) {
                selectedWaypoints := _Arr.wrap(scriptSettingsObj.startWaypoint)
            }
        }

        if (!IsObject(this.waypointsToShow[tab])) {
            this.waypointsToShow[tab] := {}
        }

        for _, wp in selectedWaypoints
        {
            this.waypointsToShow[tab][wp] := true
        }
    }

    setWaypoint(tab, waypoint)
    {
        if (!IsObject(this.waypointsToShow[tab])) {
            this.waypointsToShow[tab] := {}
        }

        this.waypointsToShow[tab][waypoint] := true
    }

    setFromCurrentWaypoint(waypoint, tabName)
    {
        if (!this.autoShowCheckbox.get()) {
            return
        }

        if (!IsObject(this.waypointsToShow[tabName])) {
            this.waypointsToShow[tabName] := {}
        }

        this.waypointsToShow[tabName][waypoint] := true
    }

    showWaypoints()
    {
        if (!this.waypointsToShow) {
            _MapCoordinate.HIDE_ALL()
            return
        }

        if (this.waypointsToShow) {
            try {
                _CharCoordinate.GET()
            } catch e {
                _Logger.exception(e, A_ThisFunc)
                this.autoShowCheckbox.uncheck()
                return
            }
        }

        waypointsWithError := {}
        for tabName, waypoints in this.waypointsToShow
        {
            for waypointNumber, _ in waypoints
            {
                wp := waypointsObj[tabName][waypointNumber]
                c := wp.coordinates

                switch wp.type {
                    case "Action": Color := "red"
                    case "Stand": Color := "blue"
                    case "Walk": Color := "0x2babab"
                    default: Color := "purple"
                }

                type := StrLen(wp.type) > 10 ? SubStr(wp.type, 1, charsLimit) "..." : wp.type
                    , label := StrLen(wp.label) > 10 ? SubStr(wp.label, 1, charsLimit) "..." : wp.label

                try {
                    guiId := c.z "|" c.x "|" c.y	"|" wp.rangeX "|" wp.rangeY "|" tabName "|" waypointNumber
                    coord := new _MapCoordinate(c.x, c.y, c.z, wp.rangeX, wp.rangeY)	
                    coord.showOnScreen(Color, waypointNumber ": " type "`n" tabName "`n" label, guiId)
                } catch e {
                    if (!IsObject(waypointsWithError[tabName])) {
                        waypointsWithError[tabName] := {}
                    }

                    waypointsWithError[tabName][waypointNumber] := true
                }
            }
        }

        for tabName, waypoints in waypointsWithError
        {
            for waypointNumber, _ in waypoints
            {
                this.waypointsToShow[tabName].Delete(waypointNumber)
            }
        }
    }

    waypointChanged()
    {
        _MapCoordinate.HIDE_ALL()
    }

}