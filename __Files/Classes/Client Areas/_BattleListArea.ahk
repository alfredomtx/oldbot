#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_TargetingJson.ahk

/**
* @property array<_Coordinates> creaturePositions
* @property _Coordinate position
* @property _Coordinate attackPosition
* @property int height
*/
class _BattleListArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "battleListArea"

    static MIN_HEIGHT := 100
    static MIN_WIDTH := 200

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @param object inheritorClass
    * @singleton
    */
    __New(inheritorClass := "")
    {
        static INSTANCE
        if (INSTANCE && !inheritorClass) {
            return INSTANCE
        }

        base.__New(inheritorClass ? inheritorClass : this)

        if (inheritorClass) {
            return this
        }

        INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        if (jsonConfig("targeting", "battleListSetup", "manualArea")) {
            this.setupFromIni()
        } else {
            if (isTibia13()) {
                this.setupTibia13Area()
            } else {
                this.setupAreaOthers()
            }
        }

        this.setAttackPosition()
        this.setCreaturePosition()

        if (TargetingSystem.targetingJsonObj.options.debug) {
            this.debug()
        }
    }

    /**
    * @abstract
    * @throws
    */
    afterSetupValidations()
    {
        this.checkBattleListButtons()
        _Validation.instanceOf("this.creaturePositions.1", this.creaturePositions.1, _Coordinates)
        _Validation.instanceOf("this.attackPosition", this.attackPosition, _Coordinate)
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _BattleListArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _BattleListArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _BattleListArea.INSTANCE := ""
        _BattleListArea.INITIALIZED := false
    }

    /**
    * @return void
    */
    setupTibia13Area()
    {
        this.searchBattleListTitle()

        if (this.setup("getHeight")) {
            this.battleWindowHeight()
        } else {
            this.height := this.setup("height")
        }

        _Validation.number("this.height", this.height)

        c1 := new _Coordinate(this.position.getX(), this.position.getY())
            .subX(2)
            .subY(1)

        c2 := new _Coordinate(c1.getX(), c1.getY())
            .addX(158)
            .addY(this.height)

        coordinates := new _Coordinates(c1, c2)
        ; coordinates.debug()

        this.setCoordinates(coordinates)
    }

    /**
    * @return void
    */
    setupAreaOthers()
    {
        this.searchBattleListTitle()

        getHeight := this.setup("getHeight")
        if (getHeight = true) {
            this.battleWindowHeight()

            _Validation.number("this.height", this.height)
        }

        c1 := new _Coordinate(this.position.getX(), this.position.getY())
            .addX(this.setup("offsetFromBaseImagePositionX", -10))
            .addY(this.setup("offsetFromBaseImagePositionY", 0))

        c2 := new _Coordinate(c1.getX(), c1.getY())
            .addX(this.setup("width", 175))
            .addY(getHeight = true ? this.height : this.setup("height", 250))

        coordinates := new _Coordinates(c1, c2)
        ; coordinates.debug()

        this.setCoordinates(coordinates)
    }

    /**
    * @return void
    * @throws
    * @msgbox
    */
    searchBattleListTitle()
    {
        folder := jsonConfig("targeting", "battleListImages", "baseImageFolderName")
        _search := new _ImageSearch()
            .setFile(TargetingSystem.targetingJsonObj.battleListImages.baseImage)
            .setFolder(folder ? ImagesConfig[folder] : ImagesConfig.battleListTitleFolder)
            .setVariation(TargetingSystem.targetingJsonObj.battleListImages.baseImageVariation)
        ; .setDebug(TargetingSystem.targetingJsonObj.options.debug)
        ; .debug()
            .search()

        if (_search.notFound()) {
            SendModifier("Ctrl", "B")

            Loop, 4 {
                Sleep, 100
                if (_search.search().found()) {
                    break
                }
            }

            if (_search.notFound()) {
                text := txt("O Battle List não foi encontrado.`nCertifique-se de que o Batlle List esta aberto e tente novamente.`n`nPara abrir o Battle List padrão, feche todos as janelas de Battle List abertas e pressione Ctrl + B." , "The Battle List was not found.`nMake sure that the Battle List is openedand try again.`n`nTo open the default Battle List, close all the Battle List Windows opened and press Ctrl + B.")

                Gui, Carregando:Destroy
                msgbox_image(text, "Data\Files\Images\GUI\Others\default_battlelist.png", 6)
                throw Exception(text)
            }
        }

        this.position := _search.getResult()
    }

    /**
    * @return void
    * @throws
    * @msgbox
    */
    battleWindowHeight()
    {
        _Validation.number("this.position.getX()", this.position.getX())

        heightLimit := 400

        c1 := new _Coordinate(this.position.getX() - 10, this.position.getY())
        c2 := new _Coordinate(this.position.getX() + 25, this.position.getY() + heightLimit)

        _search := new _ImageSearch()
            .setFile("battle_border")
            .setFolder(ImagesConfig.battleListFolder)
            .setVariation(35)
            .setTransColor("0")
            .setCoordinates(new _Coordinates(c1, c2))
            .search()

        Loop, 3 {
            Sleep, 100
            if (_search.search().found()) {
                break
            }
        }

        if (_search.notFound()) {
            msg := txt("Houve um problema reconhecer o TAMANHO do Battle List. Certifique-se de que o Battle List está aberto e tente novamente. Se estiver muito grande(maior que " heightLimit " pixels de altura), diminua o tamanho do Battle.", "There was a problem recognizing the SIZE of the Battle List. Make sure that the Battle List is opened and try again. If it is too big(more than " heightLimit " pixels of height), decrease the size of the Battle.")
            Gui, Carregando:Destroy
            msgbox_image(msg, "Data\Files\Images\GUI\Others\default_battlelist.png", 8)
            throw Exception(msg)
        }

        _search.getResult().y += 8

        this.height := abs(this.position.y - _search.getResult().y) - 10
    }

    /**
    * @return void
    */
    setAttackPosition()
    {
        this.attackPosition := new _Coordinate(this.getX1(), this.getY1())
            .addX(15)
            .addX(this.setup("attackOffsetX", 5))
            .addY(20)
            .addY(this.setup("attackOffsetY", 15))

        ; if (debugFunc) {
        ;     this.attackPosition.debug()
        ; }
    }

    /**
    * @return void
    */
    setCreaturePosition()
    {
        this.creaturePositions := {}

        creaturePositionHeight := 22

        startCoord := new _Coordinate(this.getX1(), this.getY1())
            .addX(23)
            .addY(13)

        c1 := new _Coordinate(startCoord.getX(), startCoord.getY())
        c2 := new _Coordinate(this.getX2(), c1.getY())
            .addY(creaturePositionHeight)
            .subX(3)
        coordinates := new _Coordinates(c1, c2)
        ; coordinates.debug()

        this.creaturePositions[1] := coordinates

        Loop, 16 {
            index := A_Index + 1
            c1 := new _Coordinate(this.creaturePositions[A_Index].getX1(), this.creaturePositions[A_Index].getY2())
            c2 := new _Coordinate(this.getX2(), c1.getY())
                .addY(creaturePositionHeight)

            if (c2.getY() > this.getY2() + 10) {
                break
            }

            coordinates := new _Coordinates(c1, c2)
            ; coordinates.debug()

            this.creaturePositions[index] := coordinates
        }
    }

    /**
    * @param ?_Coordinates coordinates
    * @param string identifier
    * @throws
    * @msgbox
    */
    checkBattleListButtons(coordinates := "", identifier := "Targeting")
    {
        classLoaded("TargetingSystem", TargetingSystem)

        if (!TargetingSystem.targetingJsonObj.battleListImages.battleListButtonsVisible) {
            return
        }

        if (coordinates) {
            _Validation.empty("identifier", identifier)
            _Validation.instanceOf("coordinates", coordinates, _Coordinates)
        } else {
            coordinates := this.getCoordinates()
        }

        Loop, % (TargetingSystem.targetingJsonObj.battleListImages.battleListButtonsVisible2 ? 2 : 1) {
            image := (A_Index = 2) ? TargetingSystem.targetingJsonObj.battleListImages.battleListButtonsVisible2 : TargetingSystem.targetingJsonObj.battleListImages.battleListButtonsVisible

            _search := this.searchBattleListButton(image, coordinates)

            if (_search.found()) {
                _search.setClickOffsetX(_search.getImageBitmap().getW() / 2)
                    .setClickOffsetY(_search.getImageBitmap().getH() - 6)
                    .click()

                Sleep, 75
                MouseMove(CHAR_POS_X, CHAR_POS_Y)

                _search.search()
                if (_search.found()) {
                    this.msgboxImageBattleListButtons(identifier, image)
                }
            }
        }
    }

    /**
    * @param string image
    * @param _Coordinates coordinates
    * @return _ImageSearch
    */
    searchBattleListButton(image, coordinates)
    {
        return new _ImageSearch()
            .setFile(image)
            .setFolder(ImagesConfig.battleListButtonsFolder)
            .setVariation(TargetingSystem.targetingJsonObj.battleListImages.battleListButtonsVisibleVariation)
            .setCoordinates(coordinates)
            .search()
    }

    /**
    * @param string identifier
    * @throws
    */
    msgboxImageBattleListButtons(identifier, image)
    {
        image := ImagesConfig.battleListButtonsFolder "/" image

        if (!InStr(image, ".png")) {
            image .= ".png"
        }

        if (isTibia13()) {
            image := ImagesConfig.GUIfolder "/Others/" "battlelist_buttons.png"
        }

        msg := txt("Os botões do Battle List devem estar ocultos para o " identifier " e outras funções funcionarem corretamente. Oculte-os para continuar.", "Battle List buttons must be hidden for the " identifier " and other functions to work properly. Hide it to continue.")

        msgbox_image(msg, image, 3)

        throw exception(msg)
    }

    /**
    * @return void
    * @throws
    * @msgbox
    */
    checkBattleListTooSmall()
    {
        if (!isTibia13or14()) {
            return
        }

        c1 := new _Coordinate(this.getX1(), this.getY1())
            .addX(155)
            .subY(5)
        c2 := new _Coordinate(this.getX2(), c1.getY())
            .addX(20)
            .addY(65)
        coordinates := new _Coordinates(c1, c2)

        try {
            _search := new _ImageSearch()
                .setFile("battlelist_small")
                .setFolder(ImagesConfig.targetingFolder)
                .setVariation(20)
                .setCoordinates(coordinates)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }

        if (_search.notFound()) {
            return
        }

        ; msgbox, %FoundX%, %FoundY%
        msg := txt("A janela do Battle List está muito pequena, é necessário que apareça a barra de vida do monstro na borda inferior da janela.", "The Battle List window is too small, it's needed to appear the life bar of the monster on the bottom edge of the window.")
        Gui, Carregando:Destroy
        msgbox_image(msg, "Data\Files\Images\GUI\Others\battlelist_small.png", 3)

        throw exception(msg)
    }

    /**
    * @param int index
    * @return _Coordinate
    * @throws
    */
    getCreaturePosition(index) {
        if (!this.creaturePositions[index]) {
            throw exception("No creature position at index " index)
        }

        return this.creaturePositions[index]
    }

    /**
    * @param int y
    * @return index
    * @throws
    */
    getCreaturePositionIndex(y) {
        for index, coordinates in this.creaturePositions
        {
            if (y >= coordinates.getY1() && y <= coordinates.getY2()) {
                return index
            }
        }

        throw Exception("No creature position at y: " y)
    }

    /**
    * @return _Coordinate
    */
    getAttackPosition()
    {
        return this.attackPosition
    }

    /**
    * @return _Coordinate
    */
    getPosition() {
        return this.position
    }

    /**
    * @return int
    */
    getHeight() {
        return this.height
    }

    /**
    * @abstract
    * @return _ClientJson
    */
    clientJson()
    {
        return new _TargetingJson()
    }

    setup(key, default := "")
    {
        return this.json("battleListSetup." key, default)
    }
}