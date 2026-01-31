#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_MinimapJson.ahk

global tibiaMapX1
global tibiaMapY1
global tibiaMapX2
global tibiaMapY2

global minimapCropImageArea1
global minimapCropImageArea2
global minimapCropImageArea3
global minimapCropImageArea4
global minimapCropImageArea5
global minimapCropImageArea6
global minimapCropImageArea7
global minimapCropImageArea8
global minimapCropImageArea9

global minimapWidth
global minimapHeight

/**
* @property _Coordinate center
* @property _Coordinate centerRelative
* @property _Coordinates markerArea
* @property _Coordinates floorArea
*/
class _MinimapArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "minimapArea"

    static MINIMAP_WIDTH := 108
    static MINIMAP_HEIGHT := 111

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @singleton
    */
    __New()
    {
        if (_MinimapArea.INSTANCE) {
            return _MinimapArea.INSTANCE
        }

        base.__New(this)

        _MinimapArea.INSTANCE := this
    }

    /**
    * @abstract
    * @throws
    */
    beforeSetupValidations()
    {
        classLoaded("CavebotScript", CavebotScript)
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        if (OldbotSettings.uncompatibleModule("cavebot")) {
            this.setCoordinates(new _WindowArea().getCoordinates())
            return
        }

        if (isTibia13() && !isRubinot()) {
            this.setupAreaTibia13()
        } else {
            this.setupAreaOthers()

            this.adjustMinimapBorders()
            ;this.debug()
            this.setCenterRelative(new _Coordinate(this.getWidth() / 2, this.getHeight() / 2))
        }

        if (CavebotScript.isMarker()) {
            this.setupMarkerMode()
        }

        this.afterSetupValidations()

        if (this.options("debug")) {
            this.debug()
        }
    }

    /**
    * @abstract
    * @throws
    */
    afterSetupValidations()
    {
        if (OldbotSettings.uncompatibleModule("cavebot")) {
            return
        }

        _Validation.instanceOf("this.centerRelative", this.getCenterRelative(), _Coordinate)
        _Validation.instanceOf("this.center", this.getCenter(), _Coordinate)
        if (CavebotScript.isMarker()) {
            _Validation.instanceOf("this.markerArea", this.getMarkerArea(), _Coordinates)
        }
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _MinimapArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _MinimapArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _MinimapArea.INSTANCE := ""
        _MinimapArea.INITIALIZED := false
    }

    /**
    * @return void
    * @throws
    */
    setupAreaTibia13()
    {
        this.setCenterRelative(new _Coordinate(_MinimapArea.MINIMAP_WIDTH / 2, _MinimapArea.MINIMAP_HEIGHT / 2))

        if (!scriptSettingsObj.charCoordsFromMemory) {
            this.setMinimapCropImageAreas()
        }

        _search := new _ImageSearch()
            .setFile("MinimapPositionSearcher")
            .setFolder(ImagesConfig.minimapFolder)
            .search()

        if (_search.notFound()) {
            this.minimapNotFoundException()
        }

        c1 := new _Coordinate(_search.getX(), _search.getY())
            .subX(118)
            .subY(51)
        c2 := new _Coordinate(c1.getX(), c1.getY())
            .addX(_MinimapArea.MINIMAP_WIDTH)
            .addY(_MinimapArea.MINIMAP_HEIGHT)

        coordinates := new _Coordinates(c1, c2)
        this.setCoordinates(coordinates)

        this.setupOtherTibia13Areas()
    }

    /**
    * @return void
    */
    setupOtherTibia13Areas()
    {
        this.center := new _Coordinate(this.getX1(), this.getY1())
            .addX(this.getCenterRelative().getX())
            .addY(this.getCenterRelative().getY())

        c1 := new _Coordinate(this.getX2(), this.getY1())
            .addX(30)
            .addY(38)
        c2 := new _Coordinate(this.getX2(), this.getY2())
            .addX(56)
            .addY(8)

        this.floorArea := new _Coordinates(c1, c2)

        this.setMinimapCropAreas()
    }

    searchBaseImage()
    {
        image := ImagesConfig.minimapFolder "\" this.areaSetup("baseImage")

        _Validation.fileExists("image", image)

        return new _ImageSearch()
            .setPath(image)
            .setVariation(this.areaSetup("baseImageVariation"))
        ; .setDebug(true)
            .search()
    }

    /**
    * @return void
    * @throws
    */
    setupAreaOthers()
    {
        _search := this.searchBaseImage()

        if (_search.notFound()) {
            this.minimapNotFoundException()
        }

        if (this.options("moveMouseToMinimapPosition")) {
            _search.setClickOffsets(50)
                .moveMouse(true)
        }

        c1 := new _Coordinate(_search.getX(), _search.getY())
            .addX(this.areaSetup("offsetFromBaseImagePositionX", 0))
            .addY(this.areaSetup("offsetFromBaseImagePositionY", 0))

        if (this.areaSetup("fixedMinimapY1") > 0) {
            c1.setY(this.areaSetup("fixedMinimapY1"))
        }

        width := this.areaSetup("width", 108)
        height := this.areaSetup("height", 111)

        _Validation.number("width", width)
        _Validation.number("height", height)

        c2 := new _Coordinate(c1.getX(), c1.getY())
            .addX(width)
            .addY(height)

        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)
        ; this.debug()

        this.setupMinimapWidth()
        ; this.debug()
        this.setupMinimapHeight()
        ; this.debug()
    }

    /**
    * @return void
    * @throws
    */
    adjustMinimapBorders()
    {
        if (!this.options("dontAdjustMinimapHeightWaypoint")) {
            this.adjustMinimapHeight(250)
        }

        ; this.getCoordinates().setX1(this.getX1() + 1)
        ; this.getCoordinates().setY1(this.getY1() + 1)
        ; this.getCoordinates().setX2(this.getX2() - 1)

        _Validation.number("this.getWidth()", this.getWidth())
        _Validation.number("this.getHeight()", this.getHeight())

        this.center := new _Coordinate(this.getX1(), this.getY1())
            .addX(this.getWidth() / 2)
            .addY(this.getHeight() / 2)

        this.setMinimapCropAreas()
    }

    /**
    * @return void
    * @throws
    */
    setupMinimapWidth()
    {
        if (!this.areaSetup("getWidth")) {
            return
        }

        image := ImagesConfig.minimapFolder "\" this.areaSetup("widthImage")

        _Validation.fileExists("image", image)
        _Validation.number("widthImageVariation", variation := this.areaSetup("widthImageVariation", 50))

        _search := new _ImageSearch()
            .setPath(image)
            .setVariation(variation)
            .setTransColor("0")
        ; .setDebugResult(1)
            .search()

        if (_search.notFound()) {
            throw Exception(txt("Imagem to setup ""WidthImage"" não encontrada na tela.`nCertifique-se de que os botões do Minimapa(botões de zoom) estão visíveis e tente novamente.", "Minimap setup image ""WidthImage"" not found on screen.`nEnsure that the Minimap buttons(zoom buttons) are visible and try again." ("`n" image) ))
        }

        this.getCoordinates().setX2(_search.getX() + (this.areaSetup("offsetFromWidthImagePositionX")))
    }

    /**
    * @return void
    * @throws
    */
    setupMinimapHeight()
    {
        if (!this.areaSetup("getHeight")) {
            return
        }

        image := ImagesConfig.minimapFolder "\" this.areaSetup("heightImage")

        _Validation.fileExists("image", image)
        _Validation.number("heightImageVariation", variation := this.areaSetup("heightImageVariation", 50))

        _search := new _ImageSearch()
            .setPath(image)
            .setVariation(variation)
            .setTransColor("0")
        ; .setDebug()
            .search()

        if (_search.notFound()) {
            throw Exception(txt("Imagem to setup ""heightImage"" não encontrada na tela.`nCertifique-se de que os botões do Minimapa(botões de zoom) estão visíveis e tente novamente.", "Minimap setup image ""heightImage"" not found on screen.`nEnsure that the Minimap buttons(zoom buttons) are visible and try again." ("`n" image) ))
        }


        offset := this.areaSetup("offsetFromHeightImagePositionY")
        this.getCoordinates().setY2(_search.getY() + offset)
    }

    /**
    * @return void
    * @throws
    */
    minimapNotFoundException()
    {
        throw Exception(txt("Houve um problema ao localizar o minimapa, certifique-se de que:`n1) O minimapa está 100% visível`n2) O cliente do Tibia está no idioma INGLÊS.", "There was a problem to find the minimap, ensure that:`n1) The minimap is 100% visible.`n2) The Tibia client is in ENGLISH language."))
    }

    /**
    * @return void
    */
    setMinimapCropAreas()
    {
        windowArea := new _WindowArea()
        if (isTibia13()) {
            this.minimapCropLeft := this.getX1(), this.minimapCropRight := abs(this.getX2() - windowArea.getWidth()), this.minimapCropUp := this.getY1() + 5, this.minimapCropDown := abs(windowArea.getHeight() - this.getY2()) + 6
            return
        }

        neededWidth := 106
        neededHeight := 98
        neededDistanceCenterX := 54
        neededDistanceCenterY := 50

        currentTopDifference := abs(this.getCenter().getY() - this.getY1())
        up := currentTopDifference - neededDistanceCenterY

        currentLeftDifference := abs(this.getCenter().getX() - this.getX1())
        left := currentLeftDifference - neededDistanceCenterX

        currentRightDifference := abs(this.getCenter().getX() - this.getX2())
        right := abs(currentRightDifference - (neededWidth - neededDistanceCenterX)) - 1 ; 106 px

        currentDownDifference := abs(this.getCenter().getY() - this.getY2())
        down := abs(currentDownDifference - (neededHeight - neededDistanceCenterY)) ; 98 px

        this.minimapCropLeft := this.getX1() + left
            , this.minimapCropRight := abs(this.getX2() - windowArea.getWidth()) + right
            , this.minimapCropUp := this.getY1() + up
            , this.minimapCropDown := abs(windowArea.getHeight() - this.getY2()) + down
    }

    /**
    * @return _Coordinates
    */
    getMarkerArea()
    {
        return this.markerArea
    }

    /**
    * @return _Coordinates
    */
    getFloorArea()
    {
        return this.floorArea
    }

    /**
    * @return _Coordinate
    */
    getCenter()
    {
        return this.center
    }

    /**
    * @return _Coordinate
    */
    getCenterRelative()
    {
        return this.centerRelative
    }

    /**
    * @param _Coordinate coordinate
    * @return this
    */
    setCenterRelative(coordinate)
    {
        this.centerRelative := coordinate
        return this
    }

    /**
    * @return void
    * @throws
    */
    setupMarkerMode()
    {
        markerImageWidth := this.areaSetup("markerImageWidth", 7)
        markerImageHeight := this.areaSetup("markerImageHeight", 5)
        markerAreaOffsetX1 := this.areaSetup("markerAreaOffsetX1", -1)
        markerAreaOffsetY1 := this.areaSetup("markerAreaOffsetY1", -1)
        markerAreaOffsetX2 := this.areaSetup("markerAreaOffsetX2", 0)
        markerAreaOffsetY2 := this.areaSetup("markerAreaOffsetY2", 0)

        _Validation.number("markerImageWidth", markerImageWidth)
        _Validation.number("markerImageHeight", markerImageHeight)

        _Validation.instanceOf("this.centerRelative", this.getCenterRelative(), _Coordinate)

        windowArea := new _WindowArea()

        this.minimapCropLeft := this.getX1(), this.minimapCropRight := abs(this.getX2() - windowArea.getWidth()), this.minimapCropUp := this.getY1(), this.minimapCropDown := abs(windowArea.getHeight() - this.getY2())

        this.getCenterRelative().setX(this.getX1() + (abs(this.getX1() - this.getX2()) / 2))
        this.getCenterRelative().setY(this.getY1() + (abs(this.getY1() - this.getY2()) / 2))

        modifierX := (markerImageWidth / 2) + (abs(markerAreaOffsetX1))
        modifierY := (markerImageHeight / 2) + (abs(markerAreaOffsetY1))

        c1 := new _Coordinate(this.getCenterRelative().getX(), this.getCenterRelative().getY())
            .subX(modifierX)
            .subY(modifierY)
        c2 := new _Coordinate(this.getCenterRelative().getX(), this.getCenterRelative().getY())
            .addX(markerImageWidth / 2)
            .addX(markerAreaOffsetX2)
            .addY(markerImageHeight / 2)
            .addY(markerAreaOffsetY2)

        this.markerArea := new _Coordinates(c1, c2)
        ; this.markerArea.debug()
    }

    /**
    * @return void
    */
    adjustMinimapHeight(height)
    {
        diff := this.calculateMinimapHeightDiff(height)
        if (diff = 0) {
            return
        }

        c1 := new _Coordinate(this.getX1(), this.getY2())
            .addX(this.areaSetup("offsetHeightAdjustX", 2))
            .addY(this.areaSetup("offsetHeightAdjustY", 3))


        c2 := new _Coordinate(c1.getX(), c1.getY())

        if (diff < 0) {
            c2.subY(abs(diff))
        } else {
            c2.addY(diff)
        }

        ; c1.debug()
        ; c2.debug()
        c1.drag(c2)

        Sleep, 75
        MouseMove(CHAR_POS_X, CHAR_POS_Y)
        Sleep, 25

        this.setupAreaOthers()
        ; this.debug()
    }

    /**
    * @param height int
    * @return int
    */
    calculateMinimapHeightDiff(height)
    {
        currentHeight := abs(this.getY2() - this.getY1())
            , diff := height - currentHeight
            , diff := (abs(diff) > 0 && abs(diff) <= 2) ? 0 : diff
        return diff
    }

    /**
    * @return void
    * @throws
    */
    setMinimapCropImageAreas()
    {
        global
        this.minimapAreasSize := 35 ; tamanho proximo que a foto vai ter
        this.var := 35

        /**
        minimap center
        56 x 56
        */
        minimapCropImageArea1 := []
        minimapCropImageArea1["up"] := this.var - 14
        minimapCropImageArea1["down"] := this.var - 14
        minimapCropImageArea1["left"] := this.var - 10
        minimapCropImageArea1["right"] := this.var - (isTibia13() = true ? 10 : 28)

        /**
        minimap center
        */
        minimapCropImageArea2 := []
        minimapCropImageArea2["up"] := this.var - 8
        minimapCropImageArea2["down"] := this.var - 8
        minimapCropImageArea2["left"] := this.var - 9
        minimapCropImageArea2["right"] := this.var - 7
        /**
        minimap center
        36 x 36
        */
        minimapCropImageArea3 := []
        minimapCropImageArea3["up"] := this.var - 4
        minimapCropImageArea3["down"] := this.var - 4
        minimapCropImageArea3["left"] := this.var
        minimapCropImageArea3["right"] := this.var

        /**
        minimap ankh left
        20 x 46
        */
        minimapCropImageArea4 := []
        minimapCropImageArea4["up"] := this.getCenterRelative().getY() - this.minimapAreasSize + 4
        minimapCropImageArea4["down"] := this.getCenterRelative().getY() - 31
        minimapCropImageArea4["left"] := this.getCenterRelative().getX() - 18
        minimapCropImageArea4["right"] := this.getCenterRelative().getX() - 2

        /**
        minimap ankh right
        20 x 46
        */
        minimapCropImageArea5 := []
        minimapCropImageArea5["up"] := minimapArea4["up"]
        minimapCropImageArea5["down"] := minimapArea4["down"]
        minimapCropImageArea5["right"] := this.getCenterRelative().getX() - this.minimapAreasSize + 15
        minimapCropImageArea5["left"] := this.getCenterRelative().getX()

        /**
        minimap ankh down
        ----+---
        |______|
        46 x 20

        */
        minimapCropImageArea6 := []
        minimapCropImageArea6["up"] := this.getCenterRelative().getY() - 6
        minimapCropImageArea6["down"] := this.getCenterRelative().getY() - this.minimapAreasSize + 9
        minimapCropImageArea6["right"] := this.getCenterRelative().getX() - 23
        minimapCropImageArea6["left"] := this.getCenterRelative().getX() - 23

        /**
        minimap ankh up
        ----------
        |___+___|
        46 x 20

        */
        minimapCropImageArea7 := []
        minimapCropImageArea7["up"] := this.getCenterRelative().getY() - this.minimapAreasSize + 11
        minimapCropImageArea7["down"] := (this.getCenterRelative().getY()) - 8
        minimapCropImageArea7["right"] := minimapCropImageArea6["right"]
        minimapCropImageArea7["left"] := minimapCropImageArea6["left"]

        /**
        cruz vertical
        20 x 46
        */
        minimapCropImageArea8 := []
        minimapCropImageArea8["up"] := this.var - 9
        minimapCropImageArea8["down"] := this.var - 9
        minimapCropImageArea8["left"] := this.var + 9
        minimapCropImageArea8["right"] := this.var + 7

        /**
        cruz horizontal
        46 x 20
        */
        minimapCropImageArea9 := []
        minimapCropImageArea9["up"] := this.var + 3
        minimapCropImageArea9["down"] := this.var + 1
        minimapCropImageArea9["left"] := this.var - 4
        minimapCropImageArea9["right"] := this.var - 6

        ; msgbox, % serialize(minimapArea10)
        ; showArea := true
        if (showArea = true) {
            number := 10
            TibiaClient.getClientArea()
            mousemove, WindowX + this.getX1() + minimapCropImageArea%number%["left"], WindowY + this.getY1() + minimapCropImageArea%number%["up"]
            msgbox, % "a " serialize(minimapArea%number%)
            mousemove, WindowX + this.getX2() - minimapCropImageArea%number%["right"], WindowY + this.getY2() - minimapCropImageArea%number%["down"]
            msgbox, b
        }
    }

    images(key, default := "")
    {
        return _MinimapJson.exists() ? new _MinimapJson().get("images." key, default) : new _CavebotJson().get("minimap.images." key, default)
    }

    areaSetup(key, default := "")
    {
        return _MinimapJson.exists() ? new _MinimapJson().get("areaSetup." key, default) : new _CavebotJson().get("minimap.areaSetup." key, default)
    }

    /**
    * @abstract
    * @return _ClientJson
    */
    clientJson()
    {
        return _MinimapJson.exists() ? new _MinimapJson() : new _CavebotJson()
    }
}