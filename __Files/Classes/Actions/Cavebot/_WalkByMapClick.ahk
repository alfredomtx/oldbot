

class _WalkByMapClick extends _AbstractWalkAction
{
    static TIME_LIMIT := 30
    static CLICKS_LIMIT := 30
    static CLICKS_SAME_POSITION_LIMIT := 3

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param _MapCoordinate destination
    */
    __New(destination, arrivedCallables := "", abortCallables := "")
    {
        base.__New(destination, arrivedCallables, abortCallables)

        ; this.lastCharCoords := {}

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
            new _WaitDisconnected()

        this.destination.initializeTimer()

        if (!this.beforeClick()) {
            return false
        }

        charCoords := _CharCoordinate.GET()

        ; if the char is moving, do not click
        if (this.destination.lastCharCoords && !this.destination.lastCharCoords.isSame(_MapCoordinate.FROM_CHAR(charCoords))) {
            this.destination.clicksAtSamePosition := 0
            Sleep, 400
            this.destination.lastCharCoords := _MapCoordinate.FROM_CHAR()
            return true
        }

        if (this.destination.lastCharCoords.isSame(_MapCoordinate.FROM_CHAR())) {
            this.destination.clicksAtSamePosition++

            if (this.destination.clicksAtSamePosition > this.CLICKS_SAME_POSITION_LIMIT) {
                this.destination.setWalkArrow(true)
                    .setWalkArrowReason("Exceeded " this.CLICKS_SAME_POSITION_LIMIT " clicks at the samme position")
                return false
            }
        }

        this.destination.click()
        ; if (!CavebotWalker.waypointClick()) {
        ;     return 
        ; }

        Sleep, 400
        this.destination.lastCharCoords := charCoords

        return true
    }

    /**
    * @return bool
    */
    beforeClick()
    {
        if (this.exceededTimeLimit()) {
            return false
        }

        if (this.exceededClicksLimit()) {
            return false
        }

        cavebotSystemObj.clicksOnSameCharPosition := 0 ; variable to control if clicked on the same waypoint and being in the same position

        return true
    }
    /**
    * @return bool
    */
    exceededClicksLimit()
    {
        if (this.destination.clicks <= this.CLICKS_LIMIT) {
            return false
        }

        this.destination.resetClicks()
            .ignore()
            .setIgnoreReason("clicksOnWaypointLimit")

        ; cavebotSystemObj.waypoints[tab][Waypoint].ignoringClicksOnWaypointLimit := true

        writeCavebotLog("Cavebot", txt("Mais de " this.CLICKS_LIMIT " cliques no waypoint, pulando waypoint", "More than " this.CLICKS_LIMIT " clicks on waypoint, skipping waypoint") )
        ; Waypoint++
        return true
    }

    /**
    * @return bool
    */
    exceededTimeLimit()
    {
        ; if walks 30 seconds to the same waypoint, force walk on arrow
        if (this.destination.elapsedTimer() < this.TIME_LIMIT) {
            return false
        }

        if (cavebotSystemObj.timeWalkingWaypoint < this.TIME_LIMIT) {
            return false
        }

            new _StopWalking()
        ; Send("Esc")
        ; Sleep, 50

        this.destination.setWalkArrow(true)
            .setWalkArrowReason("TimeWalkingToWaypoint")

        return true
    }

}