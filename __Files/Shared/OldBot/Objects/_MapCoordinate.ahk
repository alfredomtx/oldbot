global NON_WALKABLE_COORDINATES := []
global BLACKLISTED_COORDINATES := []

/**
* @property int x
*
* @property int y
* @property int z
* @property int w
* @property int h
* @property int setPathFails
* @property int clicks
*
* @property bool ignored
* @property bool skipped
* @property bool triedToWalk
*
* @property string identifier
* @property string failedReason
* @property string arrivedReason
*
* @property array<string, mixed> options
*/
class _MapCoordinate extends _MapCoordinate.Getters
{
    static PRESS_ESC_BEFORE_CLICK := "pressEscBeforeClick"
    static ARRIVED_DIFFERENT_FLOOR := "differentFloor"
    static ARRIVED_SAME_CHAR_POS := "sameCharPos"

    static OPTION_TIMEOUT := "timeout"
    static TIMEOUT_SECONDS := 60

    static TIMERS_ENABLED := true

    static VISIBLE := {}

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New(x, y, z, w := "", h := "")
    {
        _Validation.mapCoordinates(A_ThisFunc, x, y, z)
        _Validation.numberOrEmpty("w", w)
        _Validation.numberOrEmpty("h", h)

        if (!A_IsCompiled) {
            _MapCoordinate.TIMERS_ENABLED := false
        }

        this.x := x
        this.y := y
        this.z := z
        this.w := w ? w : 1
        this.h := h ? h : 1
        this.guiId := this.x "," this.y "," this.z "," this.w "," this.h

        this.triedToWalk := false
        this.timerInitialized := false

        this.setPathFails := 0
        this.clicks := 0
        this.clicksAtSamePosition := 0
        this.identifier := ""

        this.isMarker := CavebotScript.isMarker()

        this.ignoredReasons := {}
        this.skippedReasons := {}

        this.setDefaultOptions()
        this.setWalkArrow(!jsonConfig("cavebot.options.walkWithMapClicks"))


        this.resetClicks()
    }

    /**
    * @return bool
    */
    arrived()
    {
        if (this.isMarker) {
            return _CavebotByImage.checkArrivedOnMarker()
        }

        if (this.isDifferentFloor()) {
            this.arrivedReason := this.ARRIVED_DIFFERENT_FLOOR
            this.deleteTimer()
            return true
        }

        if (posx = this.x && posy = this.y) {
            this.arrivedReason := this.ARRIVED_SAME_CHAR_POS
            this.deleteTimer()
            return true
        }

        if (this.isInRange()) {
            this.deleteTimer()
            return true
        }

        return false
    }

    toString()
    {
        return this.x "," this.y "," this.z "," this.w "," this.h
    }

    /**
    * @return this
    */
    resetClicks()
    {
        this.clicks := 0
        return this
    }

    /**
    * @return this
    * @throws
    */
    clickOnSqm(debug := false)
    {
            new _MapCoordinate(this.getCenterX(), this.getCenterY(), this.getZ())
            .getSqmPosition()
            .click(button := "Left", repeat := 1, delay := "", debug)
        ; this.getSqmPosition().click(button := "Left", repeat := 1, delay := "", debug)
        this.clicks++

        return this
    }

    clickOnMinimap(debug := false)
    {
        coords := this.toScreenCoordinate()
        if (debug) {
            coords.debug()
        }

        ; stop walking before clicking
        if (this.options[this.PRESS_ESC_BEFORE_CLICK]) {
            Loop, 2 {
                Send("Esc")
            }
        }

        Sleep, 50

        coords.click()
        this.clicks++

        ; added to see if stop dragging the minimap after click
        if (backgroundMouseInput){
            Loop, 1 {
                ClickButtonUp("Left", coords.getX(), coords.getY())
                Sleep, 35
            }
        }

        Sleep, 50
        MouseMove(CHAR_POS_X, CHAR_POS_Y)
    }

    /**
    * @return this
    * @throws
    */
    click(debug := false)
    {
        ; used for Persistents to not click if Cavebot is clicking on minimap
        IniWrite, 1, %DefaultProfile%, others_cavebot, CavebotClickingOnMinimap

        try {
            if (this.isMarker) {
                _CavebotByImage.clickOnMarker()
                this.clicks++
                return
            }

            if (this.shouldClickOnMinimap()) {
                this.clickOnMinimap(debug)
            } else {
                this.clickOnSqm(debug)
            }
        } finally {
            IniWrite, 0, %DefaultProfile%, others_cavebot, CavebotClickingOnMinimap

        }
    }

    shouldClickOnMinimap()
    {
        static verticalSqms, horizontalSqms

        if (this.isMarker) {
            return true
        }

        ; if (isRubinot()) {
        ;     return false
        ; }

        verticalSqms := OldbotSettings.settingsJsonObj.options.horizontalSqms
        horizontalSqms := OldbotSettings.settingsJsonObj.options.verticalSqms

        return this.getDistanceX(posx) > horizontalSqms || this.getDistanceY(posy) > verticalSqms
    }

    /**
    * @return _Coordinate
    */
    toScreenCoordinate()
    {
        coord := realCoordsToMinimapScreen(this.getCenterX(), this.getCenterY())

        return new _Coordinate(coord.x, coord.y)
    }

    /**
    * @return this
    */
    initializeTimer()
    {
        if (!_MapCoordinate.TIMERS_ENABLED) {
            return
        }

        this.resetTimer()

        this.createTimer()
    }

    createTimer()
    {
        if (!this.timerFunction) {
            this.timerFunction := this.tickTimer.bind(this)
        }

        this.deleteTimer()

        fn := this.timerFunction
        SetTimer, % fn, 1000, 98

        /**
        * a last resort to delete the tick timer when it is not deleted
        */
        fn := this.deleteTimer.bind(this)
        SetTImer, % fn, % "-" this.options[this.OPTION_TIMEOUT] * 1000, 99

        this.timerInitialized  := true

        return this
    }

    /**
    * @return this
    */
    pauseTimer()
    {
        if (!this.timerFunction) {
            return this
        }

        fn := this.timerFunction
        SetTimer, % fn, Off

        return this
    }

    /**
    * @return this
    */
    unpauseTimer()
    {
        if (!this.timerFunction) {
            return this
        }

        if (!this.timerInitialized) {
            this.initializeTimer()

            return this
        }

        this.createTimer()

        return this
    }

    /**
    * @return this
    */
    deleteTimer()
    {
        fn := this.tickTimer.bind(this)
        SetTimer, % fn, Delete

        if (!this.timerFunction) {
            return this
        }

        fn := this.timerFunction
        SetTimer, % fn, Delete
        return this
    }

    timerTimeout()
    {
        _Logger.error("Timout reached", this.identifier)
        this.deleteTimer()

        fn := this.tickTimer.bind(this)
        SetTimer, % fn, Delete
    }

    /**
    * @return void
    */
    tickTimer()
    {
        if (this.timer = "" && _MapCoordinate.TIMERS_ENABLED) {
            throw Exception("Timer not initialized", A_ThisFunc)
        }

        this.timer++
        _Logger.info(this.identifier, "Timer: " this.timer "s, distance: " this.getDistance(posx, posy))

        if (this.timer > this.options[this.OPTION_TIMEOUT]) {
            this.timerTimeout()
        }
    }

    /**
    * @return this
    */
    resetTimer()
    {
        this.timer := 0

        return this
    }


    /**
    * @return ?int
    */
    elapsedTimer()
    {
        if (this.timer = "" && _MapCoordinate.TIMERS_ENABLED) {
            throw Exception("Timer not initialized")
        }

        return this.timer
    }

    showOnScreenFor(time, interval, color := "", title := "")
    {
        showTimer := this.showCoordinateFromTimer.bind(this, color, title)
        showTimer.Call()

        SetTimer, % showTimer, Delete
        SetTimer, % showTimer, % interval

        fn := this.stopShowFromTimer.bind(this, showTimer)
        SetTimer, % fn, -%time%
    }

    showCoordinateFromTimer(color, title, getCharCoordinate := true)
    {
        _Logger.log(A_ThisFunc)
        if (getCharCoordinate) {
            _CharCoordinate.GET()
        }
        this.showOnScreen(color, title)
    }

    stopShowFromTimer(timer)
    {
        this.destroyOnScreen()
        SetTimer, % timer, Delete
    }

    /**
    * @param ?string color
    * @return this
    */
    showOnScreen(color := "", title := "", guiId := "")
    {
        static gameWindowArea, sqmSize
        ; timer := new _Timer()
        if (!gameWindowArea) {
            gameWindowArea := new _GameWindowArea()
            sqmSize := gameWindowArea.getSqmSize()
        }

        if (!posz) {
            _CharCoordinate.GET()
        }

        if (posz != this.z) {
            this.destroyOnScreen()
            return false
        }

        relativeSqmPos := realCoordsToMinimapRelative(this.x, this.y)
            , this.widthSqm := sqmSize * this.w
            , this.heightSqm := sqmSize * this.h
            , this.sqmX := WindowX + CHAR_POS_X - (sqmSize / 2)
            , this.sqmY := WindowY + CHAR_POS_Y - (sqmSize / 2)
            , charsLimit := this.w > 1 ? 19 : 7

        (relativeSqmPos.X < 0) ? (this.sqmX -= sqmSize * abs(relativeSqmPos.X)) : (this.sqmX += sqmSize * relativeSqmPos.X)
        (relativeSqmPos.Y < 0) ? (this.sqmY -= sqmSize * abs(relativeSqmPos.Y)) : (this.sqmY += sqmSize * relativeSqmPos.Y)

        if (!this.guardAgainstOutOfBoundsShowOnScreen(sqmSize)) {
            return
        }

        this.adjustSizeWhenOutOfScreenToShow()

        ; this.guiId := guiId ? guiId : this.x "," this.y "," this.z "," this.w "," this.h "," this.identifier
        this.guiId := guiId ? guiId : this.x "," this.y "," this.z "," this.w "," this.h

        if (this.hwnd && _MapCoordinate.VISIBLE[this.hwnd]) {
            this.winMove(this.hwnd)
            return this
        }

        ; if (this.guiId && _MapCoordinate.VISIBLE[this.guiId]) {
        ;     this.winMove(_MapCoordinate.VISIBLE[this.guiId])
        ;     return this
        ; }

        this.createShowOnScreenGui(color, title)

        ; _Logger.log(A_ThisFunc, "Elapsed: " timer.elapsed())

        return this
    }

    /**
    * @return void
    */
    winMove(hwnd)
    {
        WinMove, % "ahk_id " hwnd,, this.sqmX, this.sqmY, this.widthSqm, this.heightSqm
        ; WinShow, % "ahk_id " hwnd
    }

    /**
    * @return this
    */
    destroyOnScreen()
    {
        if (this.hwnd && _MapCoordinate.VISIBLE[this.hwnd]) {
            try {
                Gui, % _MapCoordinate.VISIBLE[this.hwnd] ":Default"
                Gui, Destroy
            } catch {
            }

            _MapCoordinate.VISIBLE.Delete(this.hwnd)
        }

        ; if (this.guiId && _MapCoordinate.VISIBLE[this.guiId]) {
        ;     try {
        ;         Gui, % _MapCoordinate.VISIBLE[this.guiId] ":Default"
        ;         Gui, Destroy
        ;     } catch {
        ;         ; _Logger.exception(e, A_ThisFunc, this.guiId)
        ;     }

        ;     _MapCoordinate.VISIBLE.Delete(this.guiId)
        ; }

        return this
    }

    /**
    * @return array
    */
    getGuiData()
    {
        return {"sqmX": this.sqmX, "sqmY": this.sqmY, "widthSqm": this.widthSqm, "heightSqm": this.heightSqm}
    }

    /**
    * @param string color
    * @param ?string title
    * @return void
    */
    createShowOnScreenGui(color, title := "")
    {
        Gui, New, +HwndGuiHwnd
        this.hwnd := GuiHwnd
        _MapCoordinate.VISIBLE[this.hwnd] := GuiHwnd

        ; if (this.guiId) {
        ;     _MapCoordinate.VISIBLE[this.guiId] := GuiHwnd
        ; }

        ; Gui, %GuiHwnd%:Default
        Gui, +alwaysontop -Caption +Border +ToolWindow +LastFound +E0x20 ; +E0x20 = click through window when trasparent

        Gui, Font, % "bold c" (color = "" ? "Black" : "White")
        Gui, Add, Text, x1 y1, % title ? title : this.identifier

        Gui, Color, % color
        WinSet, Transparent, 130

        Gui, Show,% "w" this.widthSqm " h" this.heightSqm " x" this.sqmX " y" this.sqmY " NoActivate", SQM_GUI
    }

    /**
    * @param int sqmSize
    * @return bool
    */
    guardAgainstOutOfBoundsShowOnScreen(sqmSize)
    {
        static values, x2, y2
        if (!values) {
            values := true

            x2 := WindowX + windowWidth
            y2 := WindowY + windowHeight
        }

        if (this.sqmY + this.heightSqm + sqmSize < WindowY) {
            return false
        }

        if (this.sqmX + this.widthSqm  + sqmSize < WindowX) {
            return false
        }

        if (this.sqmX - sqmSize > x2) {
            return false
        }

        if (this.sqmY - sqmSize > y2) {
            return false
        }

        return true
    }

    /**
    * @return void
    */
    adjustSizeWhenOutOfScreenToShow()
    {
        diffLeft := this.sqmX - windowX
        if (diffLeft < 0) {
            this.sqmX := windowX
            this.widthSqm -= abs(diffLeft)
        }

        diffRight := (this.sqmX + this.widthSqm) - (windowX + windowWidth)
        if (diffRight > 0) {
            this.widthSqm -= abs(diffRight)
        }

        diffUp := this.sqmY - windowY
        if (diffUp < 0) {
            this.sqmY := windowY
            this.heightSqm -= abs(diffUp)
        }

        diffDown := (this.sqmY + this.heightSqm) - (windowY + windowHeight)
        if (diffDown > 0) {
            this.heightSqm -= abs(diffDown)
        }
    }

    /**
    * @return void
    */
    hideOnScreen()
    {
        ID := this.hwnd
        try {
            Gui, SQMGUI%ID%: Hide
            ; Gui, SQMGUI%ID%: Destroy
        } catch e {
            _Logger.exception(e, A_ThisFunc, ID)
        }
        ; _MapCoordinate.VISIBLE[ID] := ""
    }

    /**
    * @param int range
    * @return void
    */
    blacklistLoop(range)
    {
        Loop, % range {
            index := A_Index - 1
            this.blacklist(this.x + A_Index, this.y, this.z)
            this.blacklist(this.x, this.y, this.z)
            this.blacklist(this.x, this.y + A_Index, this.z)

            this.blacklist(this.x + A_Index, this.y + A_Index, this.z)

            this.blacklist(this.x, this.y - A_Index, this.z)
            this.blacklist(this.x - A_Index, this.y - A_Index, this.z)
            this.blacklist(this.x + A_Index, this.y - A_Index, this.z)

            this.blacklist(this.x - A_Index, this.y, this.z)
            this.blacklist(this.x - A_Index, this.y + A_Index, this.z)
        }
    }

    /**
    * @param int range
    * @return void
    */
    blacklistLoopShow(range)
    {
        Loop, % range {
            index := A_Index - 1
            this.blacklistAndShow(this.x + A_Index, this.y, this.z)
            this.blacklistAndShow(this.x, this.y, this.z)
            this.blacklistAndShow(this.x, this.y + A_Index, this.z)

            this.blacklistAndShow(this.x + A_Index, this.y + A_Index, this.z)

            this.blacklistAndShow(this.x, this.y - A_Index, this.z)
            this.blacklistAndShow(this.x - A_Index, this.y - A_Index, this.z)
            this.blacklistAndShow(this.x + A_Index, this.y - A_Index, this.z)

            this.blacklistAndShow(this.x - A_Index, this.y, this.z)
            this.blacklistAndShow(this.x - A_Index, this.y + A_Index, this.z)
        }
    }

    blacklist(x, y, z)
    {
        BLACKLISTED_COORDINATES[z, x, y] := 1
    }

    blacklistAndShow(x, y, z, color := "Red")
    {
        this.blacklist(x, y, z)
            new _MapCoordinate(x, y, z).showOnScreen(color)
    }

    /**
    * @return void
    */
    HIDE_ALL()
    {
        return this.DESTROY_ALL()
        t := new _Timer()
        for ID, value in _MapCoordinate.VISIBLE {
            try {
                Gui,% ID ":Hide"
            } catch e {
                ; _Logger.exception(e, A_ThisFunc, ID)
            }
        }
        ; _MapCoordinate.VISIBLE := {}
        _Logger.log(A_ThisFunc, "elapsed: " t.elapsed() "ms " A_BatchLines ", count: " count)
    }

    /**
    * @return void
    */
    DESTROY_ALL()
    {
        ; t := new _Timer()
        winGet, winList, list, % "SQM_GUI"

        count := 0
        Loop, %winList% {
            ; WinClose, % "ahk_id " winList%A_Index%
            try {
                Gui, % winList%A_Index% ": Destroy"
            } catch e {
                ; _Logger.error(A_ThisFunc, e.message, winList%A_Index%)
            }

            count++
        }

        _MapCoordinate.VISIBLE := {}

        ; _Logger.log(A_ThisFunc, "elapsed: " t.elapsed() "ms " A_BatchLines ", count: " count)
    }

    /**
    * @return void
    */
    SHOW_NON_WALKABLE()
    {
        for z, xy in BLACKLISTED_COORDINATES
        {
            for x, yv in xy
            {
                for y, value in yv {
                    if (value) {
                            new _MapCoordinate(x, y, z).showOnScreen()
                    }
                }
            }
        }
    }

    /**
    * @return _BitmapImage
    * @throws
    */
    getBitmap()
    {
        c1 := this.getSqmPosition()
            .subX(SQM_SIZE / 2)
            .subY(SQM_SIZE / 2)

        c2 := new _ScreenPosition(c1.getX() + SQM_SIZE, c1.getY() + SQM_SIZE)

        area := new _Coordinates(c1, c2)

        return _BitmapEngine.getBitmap(area)
    }

    /**
    * @return string
    * @throws
    */
    getBase64Image()
    {
        bitmap := this.getBitmap()

        base64 := bitmap.toBase64()

        bitmap.dispose()

        return base64
    }

    class Getters extends _MapCoordinate.Setters
    {
        /**
        * @return int
        */
        getX()
        {
            return this.x
        }

        /**
        * @return int
        */
        getY()
        {
            return this.y
        }

        /**
        * @return int
        */
        getCenterX()
        {
            if (isOdd(this.w)) {
                return this.x + (this.w - 1) / 2
            }

            return this.x
        }

        /**
        * @return int
        */
        getCenterY()
        {
            if (isOdd(this.h)) {
                return this.y + (this.h - 1) / 2
            }

            return this.y
        }

        /**
        * @return int
        */
        getZ()
        {
            return this.z
        }

        /**
        * @return int
        */
        getW()
        {
            return this.w
        }

        /**
        * @return int
        */
        getH()
        {
            return this.h
        }

        /**
        * @param int x
        * @param int y
        * @return int
        */
        getDistance(x, y)
        {
            static minimapArea

            if (CavebotScript.isMarker()) {
                if (!minimapArea) {
                    minimapArea := new _MinimapArea()
                }

                _search := _CavebotByImage.searchMarker()

                distX := minimapArea.getCenterRelative().getX() - _search.getX()
                distY := minimapArea.getCenterRelative().getY() - _search.getY()

                return Sqrt((distX ** 2) + (distY ** 2))

            }

            return Sqrt(((this.getCenterX() - x)**2) + ((this.getCenterY() - y)**2))
        }


        /**
        * @param int x
        * @return int
        */
        getDistanceX(x)
        {
            return abs(this.getCenterX() - x)
        }

        /**
        * @param int y
        * @return int
        */
        getDistanceY(y)
        {
            return abs(this.getCenterY() - y)
        }

        /**
        * @return ?string
        */
        getWalkArrowReason()
        {
            return this.walkByArrowReason
        }

        /**
        * @return ?string
        */
        getIgnoredReason()
        {
            return this.ignored
        }

        /**
        * @return _ScreenPosition
        * @throws
        */
        getSqmPosition()
        {
            return _ScreenPosition.SQM_FROM_MAP_COORDINATE(this)
        }

        /**
        * @return _Coordinate
        */
        getDistanceFromCharPos(abs := true)
        {
            x := posx - this.getX(), y := posy - this.getY()

            return new _Coordinate(abs ? abs(x) : x, abs ? abs(y) : y)
        }

        /**
        * @param _MapCoordinate coordinate
        * @return _Coordinate
        */
        getDistanceFromOther(coordinate)
        {
            return new _Coordinate(abs(coordinate.getX() - this.getX()), abs(coordinate.getY() - this.getY()))
        }

        /**
        * @return ?_SpecialArea
        */
        getSpecialArea()
        {
            return _SpecialAreas.get(this.getX(), this.getY(), this.getZ(), true)
        }

        /**
        * @return bool
        */
        getFailedReason()
        {
            return this.failedReason
        }
    }

    class Setters extends _MapCoordinate.Predicates
    {
        /**
        * @param string value
        * @return this
        */
        setIdentifier(value)
        {
            this.identifier := value
            return this
        }

        /**
        * @param string reason
        * @return this
        */
        setFailedReason(reason)
        {
            this.failedReason := reason
            return this
        }

        /**
        * @param string reason
        * @return this
        */
        setIgnored(reason)
        {
            this.ignored := reason
            return this
        }

        /**
        * @return this
        */
        setWalkArrow(value)
        {
            this.walkByArrow := value
            return this
        }

        /**
        * @param string reason
        * @return this
        */
        setWalkArrowReason(reason)
        {
            this.walkByArrowReason := reason
            return this
        }

        /**
        * @return void
        */
        setDefaultOptions()
        {
            this.options := {}
            this.options[this.PRESS_ESC_BEFORE_CLICK] := false
            this.options[this.OPTION_TIMEOUT] := this.TIMEOUT_SECONDS
        }

        /**
        * @param string option
        * @param mixed value
        * @return this
        */
        setOption(option, value)
        {
            this.options[option] := value
            return this
        }

        /**
        * @return this
        */
        setNonWalkable(value := true, range := 0)
        {
            NON_WALKABLE_COORDINATES[this.z, this.x, this.y] := value

            Loop, % range {
                NON_WALKABLE_COORDINATES[this.z, this.x + A_Index, this.y] := value
                NON_WALKABLE_COORDINATES[this.z, this.x - A_Index, this.y] := value
                NON_WALKABLE_COORDINATES[this.z, this.x, this.y + A_Index] := value
                NON_WALKABLE_COORDINATES[this.z, this.x, this.y - A_Index] := value
            }

            return this
        }

        /**
        * @return this
        */
        setBlacklisted(value := true, range := 0, show := false)
        {
            if (show) {
                this.blacklistAndShow(this.x, this.y, this.z, "blue")
                this.blacklistLoopShow(range)

                return this
            }

            this.blacklist(this.x, this.y, this.z)
            this.blacklistLoop(range)

            return this
        }

        /**
        * @param string reason
        * @return this
        */
        setIgnoreReason(reason)
        {
            this.ignoredReasons.Push(reason)
            return this
        }
    }

    class Predicates extends _MapCoordinate.Factory
    {
        /**
        * @return bool
        */
        isDifferentFloor()
        {
            return posz != this.z
        }

        /**
        * @return bool
        */
        isInRange()
        {
            if (this.isInRangeArea(posx, this.x, this.x + this.w - 1) && this.isInRangeArea(posy, this.y, this.y + this.h - 1)) {
                return true
            }

            return false
        }

        /**
        * @return bool
        */
        isInRangeArea(value, low, high)
        {
            if (value = low OR value = high) {
                return true
            }

            if value between %low% and %high%
                return true

            return false
        }

        /**
        * @return bool
        */
        isIgnored()
        {
            return (this.ignored) ? true : false
        }

        /**
        * @return bool
        */
        isSkipped()
        {
            return (this.skipped) ? true : false
        }

        /**
        * @param _MapCoordinate coord
        * @return bool
        */
        isSame(coord)
        {
            ; _Validation.instanceOf("coord", coord, _MapCoordinate)
            return this.x = coord.x && this.y = coord.y && this.z = coord.z
        }

        /**
        * @return bool
        */
        isCharacterPos()
        {
            return this.x = posx && this.y = posy && this.z = posz
        }

        /**
        * @return bool
        */
        isWalkArrow()
        {
            return this.walkByArrow ? true : false
        }

        /**
        * @return bool
        */
        isWalkable()
        {
            if (NON_WALKABLE_COORDINATES[this.z, this.x, this.y]) {
                return false
            }

            if (this.isBlacklisted()) {
                return false
            }

            return true
        }

        /**
        * @return bool
        */
        isBlacklisted()
        {
            if (BLACKLISTED_COORDINATES[this.z, this.x, this.y]) {
                return true
            }

            return false
        }

        /**
        * @return bool
        */
        isVisibleOnMinimap()
        {
            distance := this.getDistanceFromCharPos()

            switch isTibia13() {
                case true:
                    if (distance.x >= 51)
                        return false
                    if (distance.y >= 52)
                        return false

                    /**
                    OTClientV8
                    */
                case false:
                    if (distance.x >= 80)
                        return false
                    if (distance.y >= 80)
                        return false

            }

            return true
        }
    }

    class Factory extends _MapCoordinate.Guards
    {
        /**
        * @param _MapCoordinate instance
        * @return _MapCoordinate
        */
        CLONE(instance)
        {
            _Validation.instanceOf("instance", instance, _MapCoordinate)
            return new this(instance.x, instance.y, instance.z, instance.w, instance.h)
        }

        /**
        * @return _MapCoordinate
        */
        FROM_CHAR()
        {
            return new this(posx, posy, posz, 1, 1)
        }

        FROM_STRING(string)
        {
            _Validation.empty("string", string)
            data := StrSplit(string, ",")
            return new this(data.1, data.2, data.3, data.4, data.5)
        }

        /**
        * @return _MapCoordinate
        */
        FROM_CAVEBOT()
        {
            if (CavebotScript.isMarker()) {
                return new this(0, 0, 0, 1, 1)
            }

            return new this(waypointsObj[tab][Waypoint].coordinates.x, waypointsObj[tab][Waypoint].coordinates.y, waypointsObj[tab][Waypoint].coordinates.z, waypointsObj[tab][Waypoint].rangeX, waypointsObj[tab][Waypoint].rangeY)
        }

        /**
        * @return _MapCoordinate
        */
        FROM_WAYPOINT(waypoint)
        {
            return new this(waypointsObj[tab][waypoint].coordinates.x, waypointsObj[tab][waypoint].coordinates.y, waypointsObj[tab][waypoint].coordinates.z, waypointsObj[tab][waypoint].rangeX, waypointsObj[tab][waypoint].rangeY)
        }

        /**
        * return the x and y coords from a position of the screen
        * @return _MapCoordinate
        */
        FROM_SCREEN_POS(screenPosX, screenPosY, getCharPos := true)
        {
            sqmsDist := getSqmDistanceByScreenPos(screenPosX, screenPosY)

            if (getCharPos) {
                _CharCoordinate.GET()
            }

            _Validation.empty("posx", posx)

            if (sqmsDist.x < 0)
                coordX := posx + abs(sqmsDist.x)
            else
                coordX := posx - sqmsDist.x
            if (sqmsDist.y < 0)
                coordY := posy + abs(sqmsDist.y)
            else
                coordY := posy - sqmsDist.y

            return new _MapCoordinate(coordX, coordY, posz)
        }

        /**
        * @return ?_MapCoordinate
        */
        FROM_MOUSE_POS(getCharPos := true)
        {
            CoordMode, Mouse, Screen

            MouseGetPos, mouseX, mouseY

            relativeX := abs(mouseX - windowX)
            relativeY := abs(mouseY - windowY)

            if (!this.guardAgainstMouseOutsideWindow(mouseX, mouseY)) {
                return
            }

            return _MapCoordinate.FROM_SCREEN_POS(relativeX, relativeY, getCharPos)
        }

    }

    class Guards extends _MapCoordinate.Base
    {
        /**
        * @return bool
        */
        guardAgainstMouseOutsideWindow(mouseX, mouseY)
        {
            sqmSize := new _GameWindowArea().getSqmSize()
            if (mouseX < windowX + (sqmSize / 2)) {
                return false
            }

            if (mouseY < windowY + (sqmSize / 2)) {
                return false
            }

            if (mouseY > windowY + windowHeight - (sqmSize / 2)) {
                return false
            }

            if (mouseX > windowX + windowWidth - (sqmSize / 2)) {
                return false
            }


            return true
        }
        /**
        * @return void
        * @throws
        */
        guardAgainstNonWalkableSpecialArea()
        {
            if (this.getSpecialArea().isWalkable() == false) {
                throw Exception(txt("Coordenada não é caminhável(walkable), tipo: ", "Coordinate is not walkable, type: ") this.getSpecialArea().getType())
            }
        }
    }

    class Base extends _Coordinate
    {
    }
}