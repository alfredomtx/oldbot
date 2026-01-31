#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Positions\_AbstractPosition.ahk

global CHAR_POS_X
global CHAR_POS_Y

/**
* @property _Coordinates charArea
* @property _Coordinate position
*/
class _CharPosition extends _AbstractPosition
{
    static INITIALIZED := false
    static NAME := "charPosition"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @singleton
    */
    __New()
    {
        if (_CharPosition.INSTANCE) {
            return _CharPosition.INSTANCE
        }

        base.__New(this)

        _CharPosition.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _CharPosition.INSTANCE := ""
        _CharPosition.INITIALIZED := false
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupPosition()
    {
        if (isTibia13() && !isRubinot()) {
            position := this.setupTibia13Area()
        } else {
            position := this.setupUserDefinedArea()
        }

        _Validation.instanceOf("this.getCharArea()", this.getCharArea(), _Coordinates)

        this.setPosition(position)

        global CHAR_POS_X := this.getX()
        global CHAR_POS_Y := this.getY()

        if (CavebotSystem.cavebotJsonObj.options.debugCharArea OR debugCharPosition) {
            this.debug()
        }
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _CharPosition.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _CharPosition.INITIALIZED := true
    }

    /**
    * @return int
    */
    getX()
    {
        return this.getPosition().getX()
    }

    /**
    * @return int
    */
    getY()
    {
        return this.getPosition().getY()
    }

    /**
    * @return _Coordinates
    */
    setupTibia13Area()
    {
        classLoaded("_ActionBarArea", _ActionBarArea)
        actionBarArea := new _ActionBarArea()

        c1 := new _Coordinate(actionBarArea.getX1(), 35)
            .addX(-18)
        c2 := new _Coordinate(actionBarArea.getX2(), actionBarArea.getY1())
            .addX(27)
            .addY(-11)
        charAreaCoords := new _Coordinates(c1, c2)

        _search := this.searchCustomisableBar(actionBarArea)
        if (_search.found()) {
            charAreaCoords.setY1(_search.getResult().y + 38)
        }

        this.setCharArea(charAreaCoords)

        return this.getCharacterPosition(this.getCharArea())
    }

    /**
    * @return _Coordinates
    */
    setupUserDefinedArea()
    {
        if (OldbotSettings.settingsJsonObj.options.entireGameWindowArea) {
            this.setCharArea(new _WindowArea().getCoordinates())

            return this.getCharacterPosition(this.getCharArea())
        }

        if (OldbotSettings.settingsJsonObj.options.gameWindowHeight = true) {
            if (TibiaClient.getClientIdentifier() = "pokexgames") {
                this.adjustScreenHeightPXG()
            }
        }

        _Validation.empty("DefaultProfile", DefaultProfile)

        IniRead, X1, %DefaultProfile%, % _GameWindowArea.INI_CONFIG, % _GameWindowArea.NAME "X1", %A_Space%
        IniRead, Y1, %DefaultProfile%, % _GameWindowArea.INI_CONFIG, % _GameWindowArea.NAME "Y1", %A_Space%
        IniRead, X2, %DefaultProfile%, % _GameWindowArea.INI_CONFIG, % _GameWindowArea.NAME "X2", %A_Space%
        IniRead, Y2, %DefaultProfile%, % _GameWindowArea.INI_CONFIG, % _GameWindowArea.NAME "Y2", %A_Space%

        stringVideo := txt("`n`nAssista o vídeo tutorial ""Primeiros Passos"" em 4:58 para aprender como setar a área.", "`n`nCheck video tutorial ""Primeiros Passos"" at 4:58 to learn how to set the area.")
        /**
        if X1 starts more than half the client it's wrong
        */
        valid := true, msg := ""

        height := abs(Y1 - Y2)
        if (!X2 || !Y2) {
            throw Exception(txt("A área da Game Window n�o foi setada.", "The Game Window area was not set.") stringVideo)
        }

        ;if (X1 > (new _WindowArea().getWidth() / 2)) {
        ;    valid := false
        ;    msg := txt("Ponto inicial do Game Window área � inválido.",  "Invalid initial point of game window area.") stringVideo
        ;} else if (X2 < X1) {
        if (X2 < X1) {
            valid := false
            msg := txt("Crie a área da ESQUERDA(inicio) para a DIREITA(fim).", "Create the area from LEFT(start) to RIGHT(end).") stringVideo
        } else if (height < _GameWindowArea.MIN_HEIGHT) {
            valid := false
            msg := txt("Altura da Game Window Area está muito pequena(menor do que " _GameWindowArea.MIN_HEIGHT "px).", "Height of the game window area is too small(less than " _GameWindowArea.MIN_HEIGHT "px).") stringVideo
        }

        if (!valid) {
            IniDelete, % DefaultProfile, % _GameWindowArea.INI_CONFIG, _GameWindowArea.NAME "X1"
            IniDelete, % DefaultProfile, % _GameWindowArea.INI_CONFIG, _GameWindowArea.NAME "Y1"
            IniDelete, % DefaultProfile, % _GameWindowArea.INI_CONFIG, _GameWindowArea.NAME "X2"
            IniDelete, % DefaultProfile, % _GameWindowArea.INI_CONFIG, _GameWindowArea.NAME "Y2"
            ; openURL("https://youtu.be/9IYJeWFSsUQ?t=298")
            throw Exception(msg)
        }

        if (!X1) {
            ; openURL("https://youtu.be/9IYJeWFSsUQ?t=298")
            throw Exception("""Game Window Area"" " txt("não setada.", "not set.") stringVideo)
        }

        c1 := new _Coordinate(X1, Y1)
        c2 := new _Coordinate(X2, Y2)

        coords :=  new _Coordinates(c1, c2)

        this.setCharArea(coords)

        return this.getCharacterPosition(this.getCharArea())
    }

    /**
    * @return _Coordinates
    */
    getCharArea()
    {
        return this.charArea
    }

    /**
    * @param _Coordinates area
    */
    setCharArea(area)
    {
        this.charArea := area
        return this
    }

    /**
    * @param _ActionBarArea actionBarArea
    * @return _ImageSearch
    */
    searchCustomisableBar(actionBarArea)
    {
        c1 := new _Coordinate(actionBarArea.getX1(), 0)
        c2 := new _Coordinate(actionBarArea.getX2(), 100)
            .addX(25)
        coords := new _Coordinates(c1, c2)

        return new _ImageSearch()
            .setFile("xp_boost_button_customisable_bars.png")
            .setFolder(ImagesConfig.charAreaFolder)
            .setVariation(60)
            .setCoordinates(coords)
            .search()
    }

    /**
    * @param _Coordinates coordinates
    * @return _Coordinate
    */
    getCharacterPosition(coordinates)
    {
        return new _Coordinate(coordinates.getX1() + coordinates.getX2(), coordinates.getY1() + coordinates.getY2())
            .div(2)
    }

    /**
    * @return void
    * @throws
    */
    adjustScreenHeightPXG() {
        vars := ""
        try {
            vars := ImageClick({"image": "screen_height_ball.png"
                    , "directory": ImagesConfig.othersFolder "\pxg"
                    , "variation": 40
                    , "funcOrigin": A_ThisFunc
                    , "debug": false})
        } catch e {
            throw e
        }
        if (!vars.x) {
            writeCavebotLog("WARNING", "Auto adjust game window height image not found", 1)
            return
        }
        desireHeight := 500

        currentHeight := vars.y - 7
        differenceHeight := currentHeight - desireHeight


        if (differenceHeight = 7)
            return
        Gui, CavebotLogs:Hide
        writeCavebotLog("Cavebot", "Adjusting game window height, difference: " differenceHeight)

        WinActivate()
        MouseGetPos, mouseX, mouseY
        if (differenceHeight < 0) {
            y := vars.y + abs(differenceHeight)
        } else {
            y := vars.y - differenceHeight
        }


        mousemove(vars.x, currentHeight)
        ; msgbox, a %currentHeight%
        Click, Down
        Sleep, 50
        WinActivate()
        Sleep, 100
        mousemove(vars.x, y)
        ; msgbox, b
        Sleep, 150
        Click, Up
        MouseMove, mouseX, mouseY
        ; msgbox, c
        Gui, CavebotLogs:Show

        writeCavebotLog("WARNING", "Game window height has been adjusted automatically, you should confirm if the Game Window Area is correct now")

        vars := ""
        try {
            vars := ImageClick({"image": "screen_height_ball.png"
                    , "directory": ImagesConfig.othersFolder "\pxg"
                    , "variation": 40
                    , "funcOrigin": A_ThisFunc
                    , "debug": false})
        } catch e {
            throw e
        }

        if (!vars.x) {
            return
        }
        currentHeight := vars.y - 7
        differenceHeight := currentHeight - desireHeight

        if (abs(differenceHeight) > 7)
            writeCavebotLog("ERROR", "Game window height was not adjusted correctly, difference: " differenceHeight)
    }
}