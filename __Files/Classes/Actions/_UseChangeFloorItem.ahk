

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\_AbstractAction.ahk

class _UseChangeFloorItem extends _AbstractAction
{
    static CHANGE_FLOOR_DELAY := 500

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param _MapCoordinate coordinate
    * @return bool
    * @throws
    */
    __New(coordinate, item)
    {
        try {
            this.validations()

            sqmPosition := coordinate.getSqmPosition()

            if (_CavebotScript.isMarker() OR !OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection) {
                return this.handleMarkerMode(item)
            }

            Loop, 3 {
                if (A_Index > 1) {
                    CavebotWalker.getCharCoords()
                }

                ; checar se o andar (floor) mudou após subir a escada
                if (coordinate.isDifferentFloor()) {
                    return true
                }

                if (!new _UseItemOnSqm(sqmPosition, item)) {
                    return false
                }

                if (item = "shovel") {
                    CavebotWalker.getCharCoords()
                    sqmPosition.click() ; click on the SQM to walk to it
                }

                Sleep, % this.CHANGE_FLOOR_DELAY
            }
        } catch e {
            this.handleException(e, this)
            throw e
        }

        return false
    }

    /**
    * @return bool
    */
    handleMarkerMode(item)
    {
        global posz, tab, Waypoint

        success := this.useChangeFloorItemMarker(item)

        if (OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection) {
            return success
        }

        /**
        set posz as the waypoint one
        */
        if (success) {
            switch item {
                case "Rope":
                    posz := waypointsObj[tab][Waypoint].coordinates.z - 1
                case "Shovel":
                    posz := waypointsObj[tab][Waypoint].coordinates.z + 1
            }
        }

        return success
    }

    /**
    * @return bool
    */
    useChangeFloorItemMarker(item)
    {
        Loop, 3 {
            _CavebotByImage.saveLastMinimapPosition()

            ; checar se o andar (floor) mudou após subir a escada
            if (!_CavebotByImage.isInTheSameLastPositionMinimap()) {
                return true
            }

            sqmPosition := _CavebotWalker.getSqmPosMarker()
            _CavebotWalker.dragItemFromSqmToChar(sqmPosition)

            if (!new _UseItemOnSqm(sqmPosition, item)) {
                return false
            }

            if (item = "Shovel") {
                sqmPosition.click()
                Sleep, % this.CHANGE_FLOOR_DELAY * 2
            }

            Sleep, % this.CHANGE_FLOOR_DELAY

            ; check if the floor changed after climbing the ladder
            if (!_CavebotByImage.isInTheSameLastPositionMinimap()) {
                return true
            }
        }
    }

    /**
    * @abstract
    * @throws
    */
    validations()
    {
    }
}