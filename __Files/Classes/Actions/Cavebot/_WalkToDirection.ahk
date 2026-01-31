
class _WalkToDirection extends _AbstractWalkAction
{
    static INSTANCE
    static TIME_LIMIT := 30

    static DEFAULT_TRIES := 8
    static AT_SEA_DEFAULT_TRIES := 20

    static REASON_COULD_NOT_WALK := "CouldNotWalk"

    static MODE_CLICK := "Click"
    static MODE_PRESS_KEY := "Press"
    static MODE_HOLD_KEY := "Hold"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @param _MapCoordinate destination
    * @param array<BoundFunc> arrivedCallables
    * @param array<BoundFunc> abortCallables
    * @return bool - `false` to skip waypoint, true otherwise
    */
    __New(destination, arrivedCallables, abortCallables)
    {
        base.__New(destination, arrivedCallables, abortCallables)

        this.setWalkWithClickDistance(4)
        this.setMaxTries(this.resolveMaxTries())
        this.setWalkWithClickMaxTries(3)
        this.setAddToSpecialAreaOnFail(false)


        this.setFailedToWalkByClick(false)
        this.failedToWalkByClickCount := 0

        this.isMarker := CavebotScript.isMarker()

        this.mode := ""
    }

    /**
    * @return bool
    * @throws
    */
    run()
    {
        try {
            return this._run()
        } catch e {
            this.handleException(e, this)
            throw e
        } finally {
            this.destination.deleteTimer()
        }
    }

    /**
    * @return bool
    */
    _run()
    {
        this.destination.initializeTimer()

        this.lastDistanceX := ""
        this.lastDistanceY := ""
        this.charStuckCounter := 0
        this.currentDirection := ""

        this.initialDistance := this.destination.getDistance(posx, posy)
        this.initialDistanceFlag := false
        this.lastChangedDistanceFlag := false

        this.resolveCharacterStuckTimer()

        if (this.walk()) {
            this.disableIsTrapped()

            return true
        }

        /**
        * try to walk again in case it was trapped by creatures around
        */
        if (TargetingEnabled && this.handleIsTrappedIfCreaturesAround()) {
            if (this.walk()) {
                this.disableIsTrapped()

                return true
            }
        }

        return false
    }

    disableIsTrapped()
    {
        if (targetingSystemObj.isTrapped) {
            this.logInfo(txt("Desativando estado de situação de trap.", "Disabling trap situation state."))
            targetingSystemObj.isTrapped := false
        }
    }

    /**
    * walk to a direction until stopped, arrived or need to change direction
    * @return bool
    */
    walk()
    {
        this.setLoopAndStopCallables()

        Loop, % this.maxTries {
                new _WaitDisconnected()

            _Logger.log(this.__Class, txt("Tentativas: ", "Tries: ") A_Index "/" this.maxTries)

            if (callables(this.stopCallables, true)) {
                return true
            }

            if (!this.failedToWalkByClick && this.shouldWalkWithClick()) {
                if (this.walkWithClick()) {
                    return true
                }
            }

            if (this.walkWithArrow()) {
                return true
            }
        }

        this.handleDestinationNotReached()

        return false
    }

    handleIsTrappedIfCreaturesAround()
    {
        creaturesAround := TargetingSystem.searchLifeBars()
        if (!creaturesAround.Count()) {
            return false
        }

        _CavebotTrappedEvent.handle()

        return true
    }

    /**
    * @return void
    */
    setLoopAndStopCallables()
    {
        this.loopCallables := {}
        this.loopCallables.Push(this.sleepAndSetLastDistance.bind(this))

        this.stopCallables := {}
        this.stopCallables.Push(this.getCharPosAndDist.bind(this))
        this.stopCallables.Push(this.runCallables.bind(this))
    }

    /**
    * @return void
    */
    handleDestinationNotReached()
    {
        _Logger.info(this.__Class, txt("Não foi possível chegar ao destino após " this.maxTries " tentativas", "Could not reach destination after" this.maxTries " tries"))

        this.destination.setFailedReason(this.REASON_COULD_NOT_WALK)

        ; close any possible pop up windows that may be blocking walking
        Loop, 2 {
            Send("Esc")
        }
    }

    /**
    * @return bool
    */
    walkWithClick()
    {
        this.mode := this.MODE_CLICK

        breakCallables := {}
        breakCallables.Push(this.checkCharacterStuck.bind(this))

        this.walkWithClickTries := 0

        Loop,  {
            this.walkWithClickTries++
            if (this.walkWithClickTries > this.walkWithClickMaxTries) {
                break
            }

            place := this.destination.shouldClickOnMinimap() ? "minimap" : "sqm"

            _Logger.info("Cavebot", txt("Clicando no waypoint no " place ", tentativas:", "Clicking on waypoint on the " place ", tries:") "  " this.walkWithClickTries "/" this.walkWithClickMaxTries ".")

            this.destination.click(debug := false)

            if (this.movingLoop(breakCallables)) {
                ; only stop walking if it was more than 1 sqm away from the destination, so it walks faster sqm by sqm
                if (!this.isMarker && (distX > 1 || distY > 1)) {
                        new _StopWalking()
                }

                return true
            }
        }

        this.logInfo(txt("Andando até o waypoint pelas setas...", "Walking to waypoint using arrow keys..."))

        this.setFailedToWalkByClick(true)
        this.failedToWalkByClickCount++

        return false
    }

    /**
    * @return bool
    */
    walkWithArrow()
    {
        breakCallables := {}
        breakCallables.Push(this.checkToggleAxis.bind(this))

        this.changeCurrentDirection()

        if (this.shouldWalkSingleSqms()) {
            this.mode := this.MODE_PRESS_KEY

            breakCallables.Push(this.shouldWalkWithClick.bind(this))

            this.updateCharAndLastDistance()
            this.pressArrowKey(this.currentDirection)

            return this.movingLoop(breakCallables)
        }

        this.mode := this.MODE_HOLD_KEY

        breakCallables.Push(this.checkStopWalkingHoldingKey.bind(this))

        this.holdArrowKey(this.currentDirection)

        try {
            return this.movingLoop(breakCallables)
        } finally {
            this.arrowKey.release()
        }
    }

    /**
    * @param array<BoundFunc> breakCallables
    * @return bool - `true` to stop parent/outer loop, `false` to break parent loop
    */
    movingLoop(breakCallables)
    {
        this.timeStuck.reset()

        Loop, {
            if (callables(this.stopCallables, true)) {
                this.logInfo("Stop walking")
                this.stopWalkingDelay()

                return true
            }

            if (callables(breakCallables, true)) {
                break
            }

            callables(this.loopCallables)
        }

        return false
    }

    /**
    * @return void
    */
    stopWalkingDelay()
    {
        delay := new _CavebotIniSettings().get("stopWalkingDelay")
        sleep(delay, delay + 25) ; delay to wait for the character to stop walking
    }

    /**
    * @return bool
    */
    checkStopWalkingHoldingKey()
    {
        if (this.shouldWalkWithClick()) {
            this.arrowKey.release()
            this.stopWalkingDelay()
            this.logInfo("Stop walking - to click from distance")

            return true
        }

        if (this.shouldWalkSingleSqms()) {
            this.arrowKey.release()
            this.stopWalkingDelay()
            this.logInfo("Stop walking - to single sqm")

            return true
        }

        return false
    }

    /**
    * @return bool
    */
    checkToggleAxis()
    {
        if (this.shouldToggleAxis()) {
            this.toggleAxis()
            this.logInfo("New direction, axis: " this.axis)
            return true
        }

        return false
    }

    /**
    * @param ?int sleep
    * @return void
    */
    sleepAndSetLastDistance(sleep := 25)
    {
        sleep, % sleep

        this.setLastDistance()
    }

    /**
    * @return void
    */
    setLastDistance()
    {
        this.lastDistanceX := this.distX
        this.lastDistanceY := this.distY
    }

    /**
    * @return bool
    */
    checkCharacterStuck()
    {
        if (!this.isCharacterStuck()) {
            return false
        }

        this.initialDistanceFlag := false
        this.lastChangedDistanceFlag := false
        this.logInfo("Char is stuck, axis: " this.axis ", time: " this.characterStuckTime)

        return true
    }

    /**
    * @return void
    */
    getCharPosAndDist()
    {
        if (this.isMarker) {
            minimapArea := new _MinimapArea()
            _search := _CavebotByImage.searchMarker()

            this.distX := minimapArea.getCenterRelative().getX() - _search.getX()
            this.distY := minimapArea.getCenterRelative().getY() - _search.getY()

            return
        }

        _CharCoordinate.GET()
        this.distX := posx - this.destination.getCenterX()
        this.distY := posy - this.destination.getCenterY()
    }

    /**
    * @return void
    */
    updateCharAndLastDistance()
    {
        this.getCharPosAndDist()
        this.setLastDistance()
    }

    /**
    * @return void
    */
    toggleAxis()
    {
        this.axis := this.axis = "X" ? "Y" : "X"
    }

    /**
    * @return void
    */
    changeCurrentDirection()
    {
        if (!this.axis) {
            this.axis := (abs(this.distX) > abs(this.distY)) ? "X" : "Y"
        }

        switch (this.axis) {
            case "X":
                this.currentDirection := this.chooseDirection("Right", "Left", "X")

            default:
                this.currentDirection := this.chooseDirection("Down", "Up", "Y")
        }
    }

    /**
    * @param string key
    * @return void
    */
    pressArrowKey(key)
    {
        if (this.arrowKey) {
            this.arrowKey.release()
        }

        ; delay := new _CavebotIniSettings().get("walkDelay")
        this.logInfo(key)
            new _Key(key).press()
    }

    /**
    * @param string key
    * @return void
    */
    holdArrowKey(key)
    {
        if (this.arrowKey) {
            this.arrowKey.release()
        }

        this.logInfo(key)
        this.arrowKey := new _Key(key).hold()
    }

    /**
    * @param string low
    * @param string high
    * @param string axis
    * @return string
    */
    chooseDirection(low, high, axis)
    {
        if (this["dist" axis] < 0) {
            return low
        }

        if (this["dist" axis] > 0) {
            return high
        }

        switch (axis) {
                ; is stuck trying to go up/down and the distX is 0, so need to go left/right
            case "X":
                return random(0, 1) ? "Right" : "Left"
                ; is stuck trying to go left/right and the distY is 0, so need to go up/down
            default:
                return random(0, 1) ? "Up" : "down"
        }
    }

    /**
    * @return int
    */
    resolveMaxTries()
    {
        return this.isCharacterAtSea() ? this.AT_SEA_DEFAULT_TRIES : this.DEFAULT_TRIES
    }

    /**
    * @return void
    */
    resolveCharacterStuckTimer()
    {
        static characterStuckTime
        if (!characterStuckTime) {
            characterStuckTime := new _CavebotSettings().get("characterStuckTime")
        }

        this.characterStuckTime := characterStuckTime

        if (this.isCharacterAtSea()) {
            this.characterStuckTime := 2000
        }
    }

    /**
    * @param string msg
    * @return void
    */
    logInfo(msg)
    {
        _Logger.info(this.mode, msg)
    }

    ;#Region Predicates
    /**
    * @return bool
    */
    isCharacterAtSea()
    {
        if (!isRavendawn()) {
            return false
        }

        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFile("repair")
                .setFolder(_Folders.FISHING_SKILLS_FOLDER)
                .setVariation(50)
                .setTransColor("0")
                .setArea(new _SkillBarArea())
        }

        _search := searchCache

        return _search.search().found()
    }

    /**
    * @return bool
    */
    isCharacterStuck()
    {
        if (this.distX != this.lastDistanceX || this.distY != this.lastDistanceY) {
            this.timeStuck.reset()
            return false
        }

        if (!this.timeStuck) {
            this.timeStuck := new _Timer()
        }

        t := this.timeStuck.elapsed()
        if (t > this.characterStuckTime) {
            this.timeStuck.reset()
            this.charStuckCounter++
            return true
        }

        return false
    }

    /**
    * @return bool
    */
    isDistancingFromDestination()
    {
        currentDistance := this.destination.getDistance(posx, posy)
        tolerance := 2

        if (currentDistance < this.initialDistance) {
            this.initialDistance := this.destination.getDistance(posx, posy)
        }

        if (!this.initialDistanceFlag && currentDistance >= this.initialDistance + tolerance) {
            this.lastChangedDistance := this.destination.getDistance(posx, posy)
            this.initialDistanceFlag := true
            return true
        }

        if (!this.lastChangedDistanceFlag && this.lastChangedDistance && currentDistance >= this.initialDistance + tolerance) {
            this.lastChangedDistanceFlag := true
            return true
        }

        return false
    }

    /**
    * @return bool
    */
    shouldWalkWithClick()
    {
        if (this.failedToWalkByClick) {
            return false
        }

        this.clickDistance := this.destination.getDistance(posx, posy)
        if (this.clickDistance <= this.walkWithClickDistance && this.clickDistance > 1) {
            ; _Logger.info(A_ThisFunc, "distance: " this.clickDistance " <= " this.walkWithClickDistance)
            return true
        }

        return false
    }

    /**
    * @return bool
    */
    shouldChangeDirection()
    {
        if (this.axis = "X" && this.distX = 0) {
            return true
        }

        if (this.axis = "Y" && this.distY = 0) {
            return true
        }

        return false
    }

    /**
    * @return bool
    */
    shouldToggleAxis()
    {
        if (this.shouldChangeDirection()) {
            if (this.mode == this.MODE_HOLD_KEY) {
                this.arrowKey.release()
                this.logInfo("Releasing key")
            }

            this.logInfo("Should change direction, axis: " this.axis)

            return true
        }

        if (this.checkCharacterStuck()) {
            return true
        }

        if (this.isDistancingFromDestination()) {
            this.logInfo("Distancing from destination, axis: " this.axis)

            return true
        }

        return false
    }

    /**
    * @return bool
    */
    shouldWalkSingleSqms(distance := 2)
    {
        if (this.isMarker) {
            return true
        }

        currentDistance := this.destination.getDistance(posx, posy)
        if (currentDistance <= distance) {
            ; _Logger.info(A_ThisFunc, "distance: " currentDistance " <= " distance)
            return true
        }

        return false
    }
    ;#Endregion

    ;#Region Setters
    setWalkWithClickDistance(value)
    {
        this.walkWithClickDistance := value

        return this
    }

    /**
    * @param bool value
    * @return this
    */
    setFailedToWalkByClick(value)
    {
        this.failedToWalkByClick := value

        return this
    }

    /**
    * @param int value
    * @return this
    */
    setMaxTries(value)
    {
        this.maxTries := value

        return this
    }

    /**
    * @param int value
    * @return this
    */
    setWalkWithClickMaxTries(value)
    {
        this.walkWithClickMaxTries := value

        return this
    }


    /**
    * @param int value
    * @return this
    */
    setWalkWithClickTries(value)
    {
        this.walkWithClickTries := value

        return this
    }

    /**
    * @param bool value
    * @return this
    */
    setAddToSpecialAreaOnFail(value)
    {
        this.addToSpecialAreaOnFail := value

        return this
    }

    ;#Endregion
}