

class _AbstractWalkAction extends _AbstractAction
{
    /**
    * @param _MapCoordinate destination
    * @param ?array<BoundFunc> arrivedCallables
    * @param ?array<BoundFunc> abortCallables
    */
    __New(destination, arrivedCallables := "", abortCallables := "")
    {
        this.destination := destination
        this.arrivedCallables := arrivedCallables
        this.abortCallables := abortCallables

        this.destination.triedToWalk := true

        this.isMarker := CavebotScript.isMarker()

        this.validations()

        _Logger.SET_CALLBACK(this.logger.bind(this))
    }

    /**
    * @abstract
    * @throws
    */
    validations()
    {
        _Validation.instanceOf("this.destination", this.destination)
        if (this.abortCallables) {
            _Validation.isObject("this.abortCallables", this.abortCallables)
        }

        if (this.arrivedCallables) {
            _Validation.isObject("this.arrivedCallables", this.arrivedCallables)
        }
    }

    /**
    * @return bool
    */
    runCallables()
    {
        if (this.destination.arrived()) {
            if (this.destination.triedToWalk && this.destination.arrivedReason == _MapCoordinate.ARRIVED_DIFFERENT_FLOOR) {
                Sleep, % new _CavebotIniSettings().get("changeFloorDelay")
            }

            return true
        }

        if (this.destination.isIgnored() || this.destination.isSkipped()) {
            return true
        }

        timeLimit := this.destination.isWalkArrow() ? _WalkAstarPath.TIME_LIMIT : _WalkByMapClick.TIME_LIMIT

        if (this.destination.elapsedTimer() >= timeLimit) {
            this.destination.setIgnored("Walking limit: " timeLimit)
            _Logger.info("Ignorando waypoint", "Ignoring waypoint", "Reached time limit: " timeLimit " seconds")
            return true
        }

        if (callables(this.arrivedCallables, true)) {
            return true
        }

        if (callables(this.abortCallables, true)) {
            return false
        }

        if (!this.isMarker && new CavebotIniSettings().get("useSpecialAreasToWalk")) {
            try {
                this.destination.guardAgainstNonWalkableSpecialArea()
            } catch e {
                this.destination.setIgnored("notWalkableSpecialArea")
                _Logger.info(txt("Ignorando waypoint", "Ignoring waypoint"), e.Message)
                return true
            }
        }

        this.destination.triedToMove := true

        return false
    }

    /**
    * @param string identifier
    * @param string msg
    * @return void
    */
    logger(identifier, msg)
    {
        writeCavebotLog(identifier, msg)
    }
}