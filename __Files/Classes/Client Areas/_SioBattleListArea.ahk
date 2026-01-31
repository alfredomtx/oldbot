#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client Areas\_BattleListArea.ahk

/**
* @property _Coordinates pixelArea
* @property _Coordinate position
*/
class _SioBattleListArea extends _BattleListArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "sioBattleListArea"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @singleton
    */
    __New()
    {
        if (_SioBattleListArea.INSTANCE) {
            return _SioBattleListArea.INSTANCE
        }

        base.__New(this)

        _SioBattleListArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance() {
        _SioBattleListArea.INITIALIZED := false
        _SioBattleListArea.INSTANCE := ""
    }

    /**
    * @abstract
    * @throws
    */
    beforeSetupValidations()
    {
        classLoaded("_SioSystem", _SioSystem)
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        if (isTibia13()) {
            this.setupTibia13Area()
        } else {
            this.setupAreaOthers()
        }

        this.setupPixelArea()

        this.setCreaturePosition()

        if (new _SioSystem().sioFriendJsonObj.options.debug) {
            this.getCoordinates().debug()
        }
    }

    /**
    * @abstract
    * @throws
    */
    afterSetupValidations()
    {
        _Validation.instanceOf("this.creaturePositions.1", this.creaturePositions.1, _Coordinates)

        _ := new _BattleListArea().checkBattleListButtons(this.getCoordinates(), "Sio Battle List")
        _Validation.instanceOf("this.getPixelArea()", this.getPixelArea(), _Coordinates)

    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _SioBattleListArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _SioBattleListArea.INITIALIZED := true
    }

    /**
    * @return void
    */
    setupAreaOthers() {
        coordinates := new _BattleListArea().getCoordinates()
        this.setCoordinates(coordinates)
    }

    setupPixelArea()
    {
        coordinates := new _BattleListPixelArea().getCoordinates()

        this.setPixelArea(coordinates)
    }

    /**
    * @return void
    * @throws
    * @msgbox
    */
    searchBattleListTitle()
    {
        _search := new _ImageSearch()
            .setFile(new _SioSystem().sioFriendJsonObj.battleListSetup.baseImage)
            .setFolder(ImagesConfig.sioFolder)
            .setVariation(TargetingSystem.targetingJsonObj.battleListImages.baseImageVariation)
            .setDebug(new _SioSystem().sioFriendJsonObj.options.debug)
            .search()

        if (_search.found()) {
            this.position := _search.getResult()
            return
        }

        msg := txt("Não foi possivel localizar o ""Sio"" Battle List na tela, crie esse battle list adicional e tente novamente.", "It was not possible find the ""Sio"" Battle List on screen, create this additional battle list and try again.")

        msgbox_image(msg, ImagesConfig.folder "\GUI\Others\battlelist_sio.png")

        throw Exception(msg)
    }

    /**
    * @param _Coordinates coordinates
    * @return this
    */
    setPixelArea(coordinates) {
        this.pixelArea := coordinates
        return this
    }

    /**
    * @return _Coordinates
    */
    getPixelArea() {
        return this.pixelArea
    }
}