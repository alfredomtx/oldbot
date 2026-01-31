
class _WalkAstarPath extends _AbstractWalkAction
{
    static TIME_LIMIT := 30

    static EXCEPTION_GENERATE_NEW_PATH := "GenerateNewPath"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param _MapCoordinate destination
    * @param array<callable> arrivedCallables
    * @param array<callable> abortCallables
    */
    __New(destination, arrivedCallables, abortCallables)
    {
        if (!scriptSettingsObj.charCoordsFromMemory) {
            return false
        }

        if (!new _CavebotIniSettings().get("useSpecialAreasToWalk")) {
            return false
        }

        base.__New(destination, arrivedCallables, abortCallables)

        this.showOnScreen := new _CavebotIniSettings().get("showPath")

        try {
            return this.run()
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
    run()
    {
        this.destination.initializeTimer()

        if (this.runCallables()) {
            return true
        }

        if (!this.beforeSetPath()) {
            return false
        }

        Loop, {
            path := this.getPath()
            if (!path) {
                return false
            }

            try {
                return this.runPathQueue(path)
            } catch e {
                if (e.What == this.EXCEPTION_GENERATE_NEW_PATH) {
                    if (this.showOnScreen) {
                        _MapCoordinate.HIDE_ALL()
                    }

                    continue
                }
            } finally {
                this.astarPath.destroyWaypointsOnScreen()
            }
        }
    }

    getPath()
    {
        timer := new _Timer()

        try {
            _CharCoordinate.GET()
            this.astarPath := new _AstarPath(this.destination)
                .setShowOnScreen(this.showOnScreen)

            path := this.astarPath.setPath()
        } catch e {
            if (!this.handleSetPathFail(e)) {
                return false
            }
        }

        _Logger.log("Cavebot", timer.elapsed() " ms setPath() - " path.Count() " sqms, fails: " this.destination.setPathFails " (" cavebotSystem.triesWalkToBlockedCoord ")")

        if (!this.handleEmptyPath(path)) {
            return false
        }

        return path
    }

    /**
    * @return bool
    */
    runPathQueue(path)
    {
        lastCoord := ""
        for index, mapCoord in path {
                new _WaitDisconnected()

            mapCoord.setIdentifier("Path - sqm: " index "/" path.Count())

            if (this.showOnScreen) {
                _CharCoordinate.GET()
                if (lastCoord) {
                    this.astarPath.destroyWaypointOnScreen(lastCoord.x, lastCoord.y, lastCoord.z)
                }

                this.astarPath.updateWaypointsOnScreen()
            }

            try {
                mapCoord.guardAgainstNonWalkableSpecialArea()
            } catch {
                _Logger.info("Path Walking", txt("Coordenada possui Special Area bloqueada, ", "Coordinate has blocked Special Area, ") "x:" mapCoord.x ", y:" mapCoord.y ", z:" mapCoord.z)
                throw Exception("", this.EXCEPTION_GENERATE_NEW_PATH)
            }

            action := new _WalkToDirection(mapCoord, this.arrivedCallables, this.abortCallables)
            if (action.run()) {
                lastCoord := mapCoord
                continue
            }

            this.handleSqmNotReached(mapCoord)
        }

        return true
    }

    handleSqmNotReached(mapCoord)
    {
        if (mapCoord.getFailedReason() != _WalkToDirection.REASON_COULD_NOT_WALK) {
            return
        }

        _Logger.info("Path Walking", txt("Adicionando Special Area bloqueada, ", "Adding blocked Special Area, ") "x:" mapCoord.x ", y:" mapCoord.y ", z:" mapCoord.z)
        specialArea := this.mapCoord.getSpecialArea()

        /**
        * Add Special Area with expiration 
        */

        ; TODO: add to special areas as blocked and generate a new path
        specialArea := specialArea ? specialArea : _SpecialArea.fromMapCoordinate(mapCoord)
        specialArea.setWalkable(false)
        specialArea.setType(_SpecialArea.TYPE_BLOCKED_AUTO_DETECTED)

        _SpecialAreas.addAutoDetected(specialArea, save := true, writeIni := true)

        throw Exception("", this.EXCEPTION_GENERATE_NEW_PATH)
    }


    handleReachedWalkLimit()
    {
        if (cavebotSystemObj.triesWalk <= cavebotSystemObj.triesWalkLimit) {
            return true
        }

        cavebotSystemObj.triesWalk := 1

        if (isCavebotExecutable()) {
            /**
            if fail to walk to the sqm and targeting is disabled by Action or Ignored Temporarily(ex: battle list empty not found)
            , there is a chance that there's a creature in the sqm
            in this case must enable targeting again temporarily to search for creatures 
            and return to NOT ADD COORD TO BLACKLIST yet
            and also consider that the char is trapped, to attack creatures checked with "onlyIfTrapped"
            */
            if (targetingSystemObj.targetingDisabled || targetingSystemObj.targetingIgnored.active)
                    && (!targetingSystemObj.isTrapped) {
                    CavebotSystem.runIsTrappedAction()
                /**
                this variable will be responsible to search for creatures even with targeting disabled
                and also search for creatures with option onlyIfTrapped checked
                */
                targetingSystemObj.isTrapped := true
                Sleep, 1000
                return false
            }
        }


        /**
        add the coord in the array of the ones blocked, so when generating path consider the coord non walkable
        also will consider non walkable when calling CavebotWalker.isCoordWalkable
        -- @ removed @ if targeting is enabled and is ignored temporarily, don't ignore to blacklist
        */
        _Logger.log("Cavebot", txt("Coordenadas x:" nextStepCoord.x ", y:" nextStepCoord.y " adicionadas na lista de coords bloqueadas", "Coordinates x:" nextStepCoord.x ", y:" nextStepCoord.y " added to blocked coords list") )
        cavebotSystemObj.blockedCoordinates[nextStepCoord.x, nextStepCoord.y, posz] := true

        _Logger.log("Cavebot - WARNING", txt("Tentou andar manualmente mais de " cavebotSystemObj.triesWalkLimit " vezes até a coordenada", "Tried to walk manually more than " cavebotSystemObj.triesWalkLimit " times to coordinate") " x:" nextStepCoord.x ", y:" nextStepCoord.y)

        /**
        if the coordinate that failed to walk manually is the same of the waypoint, skip this waypoint
        */
        if (nextStepCoord.x = this.destination.x && nextStepCoord.y = this.destination.y) {
            msg := "Blocked coordinate is the same as current waypoint, skipping to next waypoint"
            _Logger.log("Cavebot - WARNING", msg)
            throw exception(msg)
        }

        return false
    }

    handleBlockedCoordinate(nextStepCoord)
    {
        if (!this.destination.getSpecialArea().isBlocked()) {
            return true
        }

        if (!cavebotSystemObj.blockedCoordinates[nextStepCoord.x, nextStepCoord.y, posz]) {
            return true
        }

        /**
        for some reason setpath is not ignoring the blocked coord when generating path
        so need to abort here if the tries get too much
        */
        cavebotSystem.triesWalkToBlockedCoord++
        if (cavebotSystem.triesWalkToBlockedCoord > cavebotSystemObj.triesWalkLimit) {
            msg := "Tried too many times(" cavebotSystemObj.triesWalkLimit ") to walk to blocked SQM coord x: " nextStepCoord.x ", y: " nextStepCoord.y
            _Logger.log("Cavebot", msg)
            throw exception(msg)
        }

        return false
    }

    handleEmptyPath(path)
    {
        if (path.Count()) {
            return true
        }

        /**
        added on 23/02/2022, disable force walk in places where waypoint is too far, and setting path is failing(MaxIndex < 1)
        */
        ; this.destination.setWalkArrow(false)

        /**
        also return false to skip waypoint in case failed setpath more than once
        */  
        if (this.destination.setPathFails > 1) {
            return false
        }

        return false
    }

    /**
    * @return bool
    */
    handleSetPathFail(e)
    {
        this.destination.setPathFails++

        this.destination.setPathFailReason := e.What

        if (this.destination.setPathFails > 1) {
            if (e.What != "CustomMap") {
                _Logger.error("Path ERROR", e.Message)
            }

            this.destination.setIgnoreReason("set path failed")

            return false
        }

        if (this.destination.getWalkArrowReason() = "forcewalkarrow") {
            return false
        }

        /**
        if is the first time that setPath failed for this waypoint,
        try to walk by map again instead of skipping (returning false)
        */
        writeCavebotLog("Path WARNING", e.Message)
        ; this.destination.setWalkArrow(false)
        ;     .setWalkArrowReason("")

        if (!isCavebotExecutable()) {
            return true
        }

        _CavebotTrappedEvent.handle()

        return true
    }

    /**
    * @return bool
    */
    beforeSetPath()
    {
        #Include, __Files\Classes\Actions\Cavebot\WalkAstarPath\before_set_path.ahk

        cavebotSystemObj.triesWalk := 0
        cavebotSystem.triesWalkToBlockedCoord := 0



        return true
    }

}