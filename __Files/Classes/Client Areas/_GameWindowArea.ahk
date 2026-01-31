#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

global WINDOW_SIZE_LEVEL
global SQM_SIZE
global SQM_SIZE_HALF
global SQM_SIZE_DOUBLE
global SQM_SQUARE_GUI

/**
* @property _Coordinates consoleMessagesArea
* @property int sqmSize
*/
class _GameWindowArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "gameWindowArea"

    static INI_CONFIG := "gameWindow"
    static MIN_HEIGHT := 300
    static MIN_WIDTH := 400

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @singleton
    */
    __New()
    {
        if (_GameWindowArea.INSTANCE) {
            return _GameWindowArea.INSTANCE
        }

        base.__New(this)

        _GameWindowArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _GameWindowArea.INSTANCE := ""
        _GameWindowArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @throws
    */
    beforeSetupValidations()
    {
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        coordinates := this.setupCalculatedArea()
        this.setCoordinates(coordinates)
        ; this.debug()

        global SQM_SIZE := this.getSqmSize()

        this.setupSqmSizes()

        this.setConsoleStatusMessagesAreas()

        this.setCharPositionSQMs()
    }

    /**
    * @abstract
    * @throws
    */
    afterSetupValidations()
    {
        _Validation.instanceOf("this.getConsoleMessagesArea()", this.getConsoleMessagesArea(), _Coordinates)
        _Validation.number("SQM_SQUARE_GUI", SQM_SQUARE_GUI)
        _Validation.number("SQM_SIZE", SQM_SIZE)
        _Validation.number("SQM_SIZE_HALF", SQM_SIZE_HALF)
        _Validation.number("SQM_SIZE_DOUBLE", SQM_SIZE)
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _GameWindowArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _GameWindowArea.INITIALIZED := true
    }

    /**
    * @return _Coordinates
    */
    setupCalculatedArea()
    {
        classLoaded("_CharPosition", _CharPosition)
        charArea := new _CharPosition().getCharArea()

        this.setSqmSize(Ceil(charArea.getHeight() * 0.09))

        if (OldbotSettings.settingsJsonObj.options.sqmSizeModifier > 0) {
            this.setSqmSize(Ceil(charArea.getHeight() * OldbotSettings.settingsJsonObj.options.sqmSizeModifier))
        }

        _Validation.empty("CHAR_POS_X", CHAR_POS_X)
        _Validation.empty("CHAR_POS_Y", CHAR_POS_Y)

        if (OldbotSettings.settingsJsonObj.options.entireGameWindowArea) {
            return charArea
        }

        verticalSqms := 7
        horizontalSqms := 5

        if (OldbotSettings.settingsJsonObj.options.verticalSqms) {
            verticalSqms := OldbotSettings.settingsJsonObj.options.verticalSqms
        }

        if (OldbotSettings.settingsJsonObj.options.horizontalSqms) {
            horizontalSqms := OldbotSettings.settingsJsonObj.options.horizontalSqms
        }

        sqmSize := this.getSqmSize()

        c1 := new _Coordinate(CHAR_POS_X, CHAR_POS_Y)
            .addX(-(sqmSize * verticalSqms) )
            .addY(-(sqmSize * horizontalSqms) )
            .addX(-(sqmSize / 2))
            .addY(-(sqmSize / 2))
            .addX(3)
            .addY(2)
        c2 := new _Coordinate(CHAR_POS_X, CHAR_POS_Y)
            .addX(sqmSize * verticalSqms)
            .addY(sqmSize * horizontalSqms)
            .addX(sqmSize / 2)
            .addY(sqmSize / 2)
            .addX(-4)
            .addY(-3)

        return new _Coordinates(c1, c2)
    }

    /**
    * @return void
    */
    setupSqmSizes()
    {
        global
        if (this.getHeight() > 250) && (this.getHeight() < 600) {
            if (this.getHeight() > 300) OR (this.getHeight() < 360) {
                WINDOW_SIZE_LEVEL := 2
            }
        } else if (this.getHeight() > 690) && (this.getHeight() < 720) {
            WINDOW_SIZE_LEVEL := 3
        }

        /**
        calculate sqm size to work without display integral multiples
        but it messes with monster corpses images
        */

        SQM_SIZE_HALF := this.getSqmSize() / 2
        SQM_SIZE_DOUBLE := this.getSqmSize() * 2

        SQM_SQUARE_GUI := this.getSqmSize() - 2

        if (CavebotSystem.cavebotJsonObj.options.debugCharArea = true) {
            msgbox, % "this.getHeight() = " this.getHeight() "`n" "sizeSQM = " this.getSqmSize() "`n"
        }
    }

    /**
    * @return void
    */
    setConsoleStatusMessagesAreas()
    {
        _Validation.empty("CHAR_POS_X", CHAR_POS_X)
        _Validation.empty("SQM_SIZE", SQM_SIZE)

        /**
        there is no way images must be 102px width
        */
        c1 := new _Coordinate(CHAR_POS_X, this.getY2())
            .addX(-75)
            .addY(-13)
        c2 := new _Coordinate(c1.getX(), this.getY2())
            .addX(160)
            .addY(2)

        this.consoleMessagesArea := new _Coordinates(c1, c2)
    }

    /**
    * @param int value
    * @return this
    */
    setSqmSize(value)
    {
        _Validation.higher(value, 0)
        this.sqmSize := value
        return this
    }

    /**
    * @return int
    */
    getSqmSize()
    {
        return this.sqmSize
    }

    /**
    * @return _Coordinates
    */
    getConsoleMessagesArea()
    {
        return this.consoleMessagesArea
    }

    getMinWidth()
    {
        if (OldbotSettings.settingsJsonObj.gameWindow.area.minWidth) {
            return OldbotSettings.settingsJsonObj.gameWindow.area.minWidth
        }

        return _GameWindowArea.MIN_WIDTH
    }

    getMinHeight()
    {
        if (OldbotSettings.settingsJsonObj.gameWindow.area.minHeight) {
            return OldbotSettings.settingsJsonObj.gameWindow.area.minHeight
        }

        return _GameWindowArea.MIN_HEIGHT
    }

    /**
    * @return void
    */
    setCharPositionSQMs()
    {
        global
        _Validation.number("CHAR_POS_X", CHAR_POS_X)
        _Validation.number("SQM_SIZE", SQM_SIZE)

        /**
        1               29
        2               25
        3            19 20 21
        4        17  07 08 09  18
        5  27 23 15  04 05 06  16 24 28
        6        13  01 02 03  14
        7            10 11 12
        8               22
        9               26
        */

        /**
        SQMS da row 6
        */
        SQM1X := CHAR_POS_X - SQM_SIZE
            , SQM1Y := CHAR_POS_Y + SQM_SIZE
            , SQM2X := CHAR_POS_X
            , SQM2Y := CHAR_POS_Y + SQM_SIZE
            , SQM3X := CHAR_POS_X + SQM_SIZE
            , SQM3Y := CHAR_POS_Y + SQM_SIZE
        ; <=
        SQM13X := CHAR_POS_X - (SQM_SIZE * 2), SQM13Y := SQM1Y
        ; =>
        SQM14X := CHAR_POS_X + (SQM_SIZE * 2), SQM14Y := SQM1Y

        /**
        SQMS da row 5
        */
        SQM4X := CHAR_POS_X - SQM_SIZE
            , SQM4Y := CHAR_POS_Y
            , SQM5X := CHAR_POS_X
            , SQM5Y := CHAR_POS_Y
            , SQM6X := CHAR_POS_X + SQM_SIZE
            , SQM6Y := CHAR_POS_Y
        ; <=
        SQM15X := CHAR_POS_X - (SQM_SIZE * 2), SQM15Y := SQM4Y
            , SQM23X := CHAR_POS_X - (SQM_SIZE * 3), SQM23Y := SQM4Y
            , SQM27X := CHAR_POS_X - (SQM_SIZE * 4), SQM27Y := SQM4Y
        ; =>
        SQM16X := CHAR_POS_X + (SQM_SIZE * 2), SQM16Y := SQM4Y
            , SQM24X := CHAR_POS_X + (SQM_SIZE * 3), SQM24Y := SQM4Y
            , SQM28X := CHAR_POS_X + (SQM_SIZE * 4), SQM28Y := SQM4Y

        /**
        SQMS da row 4
        */
        SQM7X := CHAR_POS_X - SQM_SIZE
            , SQM7Y := CHAR_POS_Y - SQM_SIZE
            , SQM8X := CHAR_POS_X
            , SQM8Y := CHAR_POS_Y - SQM_SIZE
            , SQM9X := CHAR_POS_X + SQM_SIZE
            , SQM9Y := CHAR_POS_Y - SQM_SIZE
        ; <=
        SQM17X := CHAR_POS_X - (SQM_SIZE * 2), SQM17Y := SQM7Y
        ; =>
        SQM18X := CHAR_POS_X + (SQM_SIZE * 2), SQM18Y := SQM7Y

        /**
        SQMS da row 3
        */
        SQM19X := SQM1X, SQM19Y := CHAR_POS_Y - (SQM_SIZE * 2)
            , SQM20X := SQM2X, SQM20Y := CHAR_POS_Y - (SQM_SIZE * 2)
            , SQM21X := SQM3X, SQM21Y := CHAR_POS_Y - (SQM_SIZE * 2)

        /**
        SQMS da row 2
        */
        SQM25X := SQM2X, SQM25Y := CHAR_POS_Y - (SQM_SIZE * 3)

        /**
        SQMS da row 2
        */
        SQM29X := SQM2X, SQM29Y := CHAR_POS_Y - (SQM_SIZE * 4)

        /**
        SQMS da row 7
        */
        SQM10X := SQM1X, SQM10Y := CHAR_POS_Y + (SQM_SIZE * 2)
            , SQM11X := SQM2X, SQM11Y := CHAR_POS_Y + (SQM_SIZE * 2)
            , SQM12X := SQM3X, SQM12Y := CHAR_POS_Y + (SQM_SIZE * 2)

        /**
        SQMS da row 8
        */
        SQM22X := SQM2X, SQM22Y := CHAR_POS_Y + (SQM_SIZE * 3)

        /**
        SQMS da row 9
        */
        SQM26X := SQM2X, SQM26Y := CHAR_POS_Y + (SQM_SIZE * 4)



        Loop, 29 {
            SQM%A_Index%X_X1 := SQM%A_Index%X - (SQM_SIZE / 2)
                , SQM%A_Index%X_X2 := SQM%A_Index%X_X1 + SQM_SIZE
                , SQM%A_Index%Y_Y1 := SQM%A_Index%Y - (SQM_SIZE / 2)
                , SQM%A_Index%Y_Y2 := SQM%A_Index%Y_Y1 + SQM_SIZE
        }

        ; criar a variavel global dos sqms
        Loop, 29 {
            CriarVariavel("SQM" A_Index "X", SQM%A_Index%X)
                , CriarVariavel("SQM" A_Index "Y", SQM%A_Index%Y)
                , CriarVariavel("SQM" A_Index "X_X1", SQM%A_Index%X_X1)
                , CriarVariavel("SQM" A_Index "Y_Y1", SQM%A_Index%Y_Y1)
                , CriarVariavel("SQM" A_Index "X_X2", SQM%A_Index%X_X2)
                , CriarVariavel("SQM" A_Index "Y_Y2", SQM%A_Index%Y_Y2)
            ; MouseMove, WindowX + SQM%A_Index%X_X1, WindowY + SQM%A_Index%Y_Y1
            ; msgbox, SQM%A_Index%X_X1
            ; MouseMove, WindowX + SQM%A_Index%X_X2, WindowY + SQM%A_Index%Y_Y2
            ; msgbox, SQM%A_Index%X_X2
        }

        SQMSWX := SQM1X
        SQMSWY := SQM1Y

        SQMSX := SQM2X
        SQMSY := SQM2Y

        SQMSEX := SQM3X
        SQMSEY := SQM3Y

        SQMWX := SQM4X
        SQMWY := SQM4Y

        SQMCX := SQM5X
        SQMCY := SQM5Y

        SQMEX := SQM6X
        SQMEY := SQM6Y

        SQMNWX := SQM7X
        SQMNWY := SQM7Y

        SQMNX := SQM8X
        SQMNY := SQM8Y

        SQMNEX := SQM9X
        SQMNEY := SQM9Y
    }

}