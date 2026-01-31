#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

/**
* @property _Coordinates coordinates
* @property string inheritorClassName
*/
class _AbstractClientArea extends _BaseClass
{
    __Init() {
        classLoaded("TibiaClient", TibiaClient)
        ; classLoaded("ClientAreas", ClientAreas)
        classLoaded("ImagesConfig", ImagesConfig)
        classLoaded("_Coordinates", _Coordinates)
        classLoaded("_Validation", _Validation)
    }

    __New(inheritorClass := "")
    {
        this.inheritorClassName := inheritorClass.__Class
        guardAgainstAbstractClassInstance(inheritorClass, this)

        this.validateDependencies()

        if (!this.isInitialized()) {
            this.initialize()
        }
    }

    /**
    * @abstract
    * @throws
    */
    setupArea()
    {
        abstractMethod()
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
    * @throws
    */
    afterSetupValidations()
    {
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        abstractMethod()
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        abstractMethod()
    }

    /**
    * @abstract
    * @return void
    */
    unsetInitialized()
    {
        abstractMethod()
    }

    /**
    * @abstract
    * @return void
    */
    afterInitialization()
    {
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        abstractMethod()
    }

    /**
    * @return void
    * @throws
    */
    validateDependencies()
    {
        _Validation.empty("TibiaClientID", TibiaClientID)
        _Validation.number("WindowWidth", WindowWidth)
    }

    /**
    * @return void
    */
    initialize()
    {
        this.beforeSetupValidations()

        try {
            this.setupArea()
        } catch e {
            _Logger.exception(e, this.inheritorClassName ".setupArea()")
            throw e
        }

        _Validation.instanceOf("this.getCoordinates()", this.getCoordinates(), _Coordinates)
        try {
            this.getCoordinates().validate()
        } catch e {
            throw Exception("Invalid coordinates for area: " this.__Class "`n" e.Message)
        }

        this.afterSetupValidations()

        this.setInitialized()
        this.afterInitialization()
    }

    /**
    * @param string type
    * @return int
    */
    get(type)
    {
        return this["get" type]()
    }

    /**
    * @return string
    */
    getName()
    {
        return this.NAME
    }

    /**
    * @return int
    */
    getX1()
    {
        return this.getCoordinates().getX1()
    }

    /**
    * @return int
    */
    getY1()
    {
        return this.getCoordinates().getY1()
    }

    /**
    * @return int
    */
    getX2()
    {
        return this.getCoordinates().getX2()
    }

    /**
    * @return int
    */
    getY2()
    {
        return this.getCoordinates().getY2()
    }

    /**
    * @return _Coordinates
    */
    getCoordinates()
    {
        return this.coordinates
    }

    /**
    * @return _Coordinate
    */
    getC1()
    {
        return new _Coordinate(this.getCoordinates().getX1(), this.getCoordinates().getY1())
    }

    /**
    * @return _Coordinate
    */
    getC2()
    {
        return new _Coordinate(this.getCoordinates().getX2(), this.getCoordinates().getY2())
    }

    /**
    * @param _Coordinates coordinates
    * @return this
    */
    setCoordinates(coordinates)
    {
        _Validation.instanceOf("coordinates", coordinates, _Coordinates)

        this.coordinates := coordinates

        if (this.coordinates.getX2() > WindowWidth) {
            this.coordinates.setX2(WindowWidth - 5)
        }

        if (this.coordinates.getY2() > WindowHeight) {
            this.coordinates.setY2(WindowHeight - 5)
        }

        className := this.inheritorClassName
        if (!className) {
            return this
        }

        name := %className%.NAME
        if (!name) {
            return this
        }

        ClientAreas[name] := {}
            , ClientAreas[name].x1 := this.coordinates.getX1()
            , ClientAreas[name].y1 := this.coordinates.getY1()
            , ClientAreas[name].x2 := this.coordinates.getX2()
            , ClientAreas[name].y2 := this.coordinates.getY2()

        return this
    }

    /**
    * @return int
    */
    getW()
    {
        return this.getWidth()
    }

    /**
    * @return int
    */
    getH()
    {
        return this.getHeight()
    }

    /**
    * @return int
    */
    getWidth()
    {
        return this.getCoordinates().getWidth()
    }

    /**
    * @return int
    */
    getHeight()
    {
        return this.getCoordinates().getHeight()
    }

    /**
    * @param string msg
    * @return void
    * @throws
    */
    exception(msg)
    {
        throw Exception(msg, -2)
    }

    /**
    * @return void
    * @msgbox
    */
    debug()
    {
        if (!this.coordinates) {
            throw Exception("Coordinates not set for area: " this.__Class)
        }

        this.coordinates.debug(this.__Class, false)
    }

    /**
    * @return void
    * @throws
    */
    setupFromIni()
    {
        _Validation.empty("DefaultProfile", DefaultProfile)

        IniRead, X1, %DefaultProfile%, % this.NAME, % this.NAME "X1", %A_Space%
        IniRead, Y1, %DefaultProfile%, % this.NAME, % this.NAME "Y1", %A_Space%
        IniRead, X2, %DefaultProfile%, % this.NAME, % this.NAME "X2", %A_Space%
        IniRead, Y2, %DefaultProfile%, % this.NAME, % this.NAME "Y2", %A_Space%

        if (!X1 || !Y1 || !X2 || !Y2) {
            throw exception(txt("Defina a área na tela primeiro para poder vê-la.", "Set the area on screen first to be able to see it."))
        }

        c1 := new _Coordinate(X1, Y1)
        c2 := new _Coordinate(X2, Y2)

        coordinates :=  new _Coordinates(c1, c2)
        this.setCoordinates(coordinates)
    }

    setManualScreenArea(color := "Red", transparency := 180, defaultY2 := "")
    {
        setSystemCursor("IDC_CROSS")
        CoordMode, Mouse,Screen
        WinActivate()
        ; WinSet, TransColor, EEAA99
        ;Gui, screen_box:+Resize

        Loop {
            Tooltip, % LANGUAGE = "PT-BR" ? "Clique(sem segurar) ou ""Espaço"" para desenhar um retângulo e setar a área.`n""Esc"" para cancelar." : "Click(without holding) or ""Space"" to draw a retangle and set the area.`n""Esc"" to cancel."
            Sleep, 30
            if (GetKeyState("LButton"))
                break
            if (GetKeyState("Space"))
                break

            if (GetKeyState("Esc")) {
                Tooltip
                restoreCursor()
                return false
            }
        }

        MouseGetPos, MX, MY
        KeyWait, LButton, T2
        Tooltip
        Gui, screen_box:Destroy
        Gui, screen_box:+alwaysontop -Caption +Border +ToolWindow +LastFound
        gui, screen_box:Color, %color%
        Gui, screen_box:+Lastfound
        WinSet, Transparent, %transparency% ; Else Add transparency

        /**
        move the mouse to the end of the minimum position
        */
        if (this.MIN_WIDTH > 0 OR this.MIN_HEIGHT > 0) {
            MouseGetPos, MXend, MYend
            w := abs(MX - MXend)
            h := abs(MY - MYend)
            MouseMove, MXend + this.MIN_WIDTH, MYend + this.MIN_HEIGHT
        }

        if (defaultY2) {
            MouseGetPos, x, y
            MouseMove, x, defaultY2
        }

        CoordMode, Mouse,Screen
        Loop {
            Sleep, 25
            if (GetKeyState("LButton"))
                break
            if (GetKeyState("Space"))
                break
            if (GetKeyState("Esc")) {
                Gui, screen_box:Destroy
                restoreCursor()
                return false
            }
            MouseGetPos, MXend, MYend

            w := abs(MX - MXend)
            h := abs(MY - MYend)

            if (w < this.MIN_WIDTH)
                w := this.MIN_WIDTH
            if (h < this.MIN_HEIGHT)
                h := this.MIN_HEIGHT
            if ( MX < MXend )
                X := MX
            Else
                X := MXend
            if ( MY < MYend )
                Y := MY
            Else
                Y := MYend
            Gui, screen_box:Show, x%X% y%Y% w%w% h%h%
        }

        MouseGetPos, MXend, MYend

        Gui, screen_box:Destroy
        restoreCursor()

        X1 := MX - WindowX
        Y1 := MY - WindowY
        X2 := MXend - WindowX
        Y2 := MYend - WindowY
        w := abs(X2 - X1)

        if (w < this.MIN_WIDTH) {
            X2 := X1 + this.MIN_WIDTH
        }

        IniWrite, % X1, %DefaultProfile%, % this.NAME, % this.NAME "X1"
        IniWrite, % Y1, %DefaultProfile%, % this.NAME, % this.NAME "Y1"
        IniWrite, % X2, %DefaultProfile%, % this.NAME, % this.NAME "X2"
        IniWrite, % Y2, %DefaultProfile%, % this.NAME, % this.NAME "Y2"

        this.setupFromIni()

        this.showOnScreen()
    }

    /**
    * @return void
    * @throws
    */
    showOnScreen(color := "Green", transparency := 170)
    {
        try {
            this.destroyInstance()
            instance := new this()

            X1 := instance.getX1()
            Y1 := instance.getY1()
            X2 := instance.getX2()
            Y2 := instance.getY2()

            if (!X1 || !Y1 || !X2 || !Y2) {
                throw exception(txt("Defina a área na tela primeiro para poder vê-la.", "Set the area on screen first to be able to see it."))
            }

            WinActivate()
            X1 += WindowX, X2 += WindowX, Y1 += WindowY, Y2 += WindowY
            Gui, screen_box:Destroy
            Gui, screen_box: +alwaysontop -Caption +Border +ToolWindow +LastFound
            Gui, screen_box:Color, %color%
            Gui, screen_box:+Lastfound
            WinSet, Transparent, %transparency% ; Else Add transparency
            ; WinSet, TransColor, EEAA99
            Gui, screen_box:-Caption +Border
            w := X2 - X1
            h := Y2 - Y1

            try {
                Gui, screen_box:Show, x%X1% y%Y1% w%w% h%h%
            } catch {
                throw Exception(txt("Área inválida, defina novamente.", "Invalid area, set it again."))
                Gui, screen_box:Destroy
                Gui, Show
                return
            }

            Sleep, 1000
            Gui, screen_box:Destroy
            Gui, Show
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc)
        }
    }

    /**
    * @abstract
    * @return _ClientJson
    */
    clientJson()
    {
        abstractMethod()
    }

    json(key, default := "")
    {
        return this.clientJson().get(key, default)
    }

    options(key, default := "")
    {
        return this.json("options." key, default)
    }

    test()
    {
        this.destroyInstance()
            new this().debug()
    }


    setupFromClientAreasJson(dotPath, width := "", height := "")
    {
        class := new _ClientAreasJson().get(dotPath ".setupClass")
        if (!class) {
            return
        }

        offsets := new _ClientAreasJson().get(dotPath ".offsets")
        if (!offsets) {
            throw Exception("Missing offsets for " _Str.quoted(this.getName()))
        }

        c1 := new %class%().getC1().CLONE()
            .addX(offsets.x)
            .addY(offsets.y)

        if (offsets.add.x) {
            c1.addX(offsets.add.x)
        }

        if (offsets.add.y) {
            c1.addY(offsets.add.y)
        }

        c2 := c1.CLONE()
        width := width ? width : new _ClientAreasJson().get(dotPath ".width")
        c2.addX(width)

        height := height ? height : new _ClientAreasJson().get(dotPath ".height")
        c2.addY(height)

        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)
        if (new _ClientAreasJson().get(dotPath ".debug")) {
            this.debug()
        }
    }
}