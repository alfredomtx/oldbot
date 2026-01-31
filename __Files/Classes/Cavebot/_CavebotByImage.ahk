
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

/**
* @property _BitmapImage lastPositionBitmap
* @property _BitmapImage currentPositionBitmap
*/
class _CavebotByImage extends _BaseClass
{
    static MARKER_VARIATION := 60

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    ; __Init() {
    ;     classLoaded("_CavebotWalker", _CavebotWalker)
    ; }

    /**
    * @return _Coordinates
    */
    getPositionArea() {
        static positionArea
        if (positionArea) {
            return positionArea
        }

        sizeFromCenter := 50

        minimapArea := new _MinimapArea()
        center := minimapArea.getCenter()

        c1 := new _Coordinate(center.getX(), center.getY())
            .sub(sizeFromCenter)
        c2 := new _Coordinate(center.getX(), center.getY())
            .add(sizeFromCenter)

        return new _Coordinates(c1, c2)
    }

    /**
    * @return void
    */
    saveLastMinimapPosition() {
        this.lastPositionBitmap.dispose()
        this.lastPositionBitmap :=_BitmapEngine.getBitmap(this.getPositionArea())
        ; this.lastPositionBitmap.debug()
    }

    /**
    * @return ?_BitmapImage
    */
    getLastPositionBitmap() {
        return this.lastPositionBitmap
    }

    /**
    * @return bool
    */
    isInTheSameLastPositionMinimap() {
        static searchCache
        if (!searchCache) {
            searchCache := new _BitmapImageSearch()
                .setArea(new _MinimapArea())
                .setVariation(5)
        }

        if (!this.getLastPositionBitmap()) {
            writeCavebotLog("ERROR", A_ThisFunc " | Empty last char minimap pos")
            return false
        }

        try {
            _search := searchCache
                .setBitmap(this.getLastPositionBitmap())
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }

        return _search.found()
    }

    /**
    * @return _AbstractBitmapSearch
    * @throws
    */
    searchMarker() {
        try {
            if (waypointsObj[tab][Waypoint].image) {
                return new _Base64ImageSearch()
                    .setImage(new _Base64Image(tab "." Waypoint, waypointsObj[tab][Waypoint].image))
                    .setArea(new _MinimapArea())
                    .setVariation(_CavebotByImage.MARKER_VARIATION)
                    .search()
            }
        } catch e {
            _Logger.exception(e, A_ThisFunc, "image: " waypointsObj[tab][Waypoint].image)
            throw e
        }

        try {
            if (!waypointsObj[tab][Waypoint].marker) {
                throw Exception("Waypoint " tab "." Waypoint " of type " WaypointHandler.getAtribute("type", Waypoint, Tab) " without marker")
            }

            return new _ImageSearch()
                .setFile(waypointsObj[tab][Waypoint].marker)
                .setFolder(ImagesConfig.minimapMarkersFolder)
                .setVariation(_CavebotByImage.MARKER_VARIATION)
                .setArea(new _MinimapArea())
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, "marker: " waypointsObj[tab][Waypoint].marker)
            throw e
        }
    }

    /**
    * @return void
    */
    clickOnMarker()
    {
        try {
            _search := this.searchMarker()
            if (_search.notFound()) {
                return false
            }
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }

        _CavebotWalker.clickMinimap(_search.getX() , _search.getY())

        return true
    }

    /**
    * @return bool
    */
    checkArrivedOnMarker() {
        try {
            _search := _CavebotByImage.searchMarker()

            if (_search.notFound()) {
                return true
            }

            if (!waypointsObj[tab][Waypoint].marker) {
                return false
            }

            /**
            if marker is right in the center of the minimap
            */
            _search := new _ImageSearch()
                .setFile(waypointsObj[tab][Waypoint].marker)
                .setFolder(ImagesConfig.minimapFolder "\Markers")
                .setCoordinates(new _MinimapArea().getMarkerArea())
                .setVariation(_CavebotByImage.MARKER_VARIATION)
                .search()

            return _search.found()
        } catch e {
            _Logger.exception(e, A_ThisFunc)

            return false
        }
    }
}