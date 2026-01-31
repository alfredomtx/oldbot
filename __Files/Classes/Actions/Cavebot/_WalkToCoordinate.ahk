global CURRENT_WALK_TO_COORDINATE := ""

class _WalkToCoordinate extends _AbstractWalkAction
{
    static INSTANCE

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @param _MapCoordinate destination
    * @param array<callable> arrivedCallables
    * @param array<callable> abortCallables
    *
    * @return bool
    */
    __New(destination, arrivedCallables, abortCallables)
    {
        base.__New(destination, arrivedCallables, abortCallables)
    }

    /**
    * @return bool
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
        this.validations()

        _Logger.info("Cavebot", "Walking to " this.destination.toString() " (distance: " this.destination.getDistance(posx, posy) ")")

        /*
        FLOW:
        - walk by click
        - walk by astar path with arrow
        - walk to direction by arrow
        */
        this.walkByMapClick := new _WalkUsingMapClick(this.destination, this.arrivedCallables, this.abortCallables)
            .setWalkWithClickMaxTries(3)

        if (this.walkByMapClick.run()) {
            return true
        }

        if (new _WalkAstarPath(this.destination, this.arrivedCallables, this.abortCallables)) {
            return true
        }

        this.walkToDirection := new _WalkToDirection(this.destination, this.arrivedCallables, this.abortCallables)
            .setMaxTries(10)
            .setFailedToWalkByClick(true)

        if (this.walkToDirection.run()) {
            return true
        }

        ; try to walk again before ignoring if failed to set path due to being too far before
        if (this.destination.setPathFailReason == _AstarPath.FAIL_COORD_TOO_FAR) {
            if (new _WalkAstarPath(this.destination, this.arrivedCallables, this.abortCallables)) {
                return true
            }
        }

        ; failed to walk by click and by arrow
        this.destination.setIgnored(txt("Não foi possivel chegar ao destino", "It was not possible to reach the destination"))

        return false
    }

    pausedByTargetingEvent()
    {
        this.destination.pauseTimer()

            new _ReleaseArrowKeys()

        this.walkByMapClick.pausedByTargetingEvent()
    }

    unpausedByTargetingEvent()
    {
        this.destination.unpauseTimer()
    }
}