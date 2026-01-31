

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

/**
* @property ?int x
* @property ?int y
* @property bool defaultClickMethod
*/
class _Coordinate extends _BaseClass
{
    static DEFAULT_CLICK_REPEAT_DELAY := 50

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New(x := "", y := "")
    {
        if (x && empty(y) || empty(x) && y) {
            throw exception("Missing one of coordinates value, x: " x ", y: " y)
        }

        this.setX(x)
        this.setY(y)

        this.defaultClickMethod := true
    }

    /**
    * @return _Coordinate
    */
    CLONE()
    {
        return new this(this.getX(), this.getY())
    }

    /**
    * @param _Coordinate instance
    * @return _Coordinate
    */
    FROM(instance)
    {
        _Validation.instanceOf("instance", instance, _Coordinate)
        return new this(instance.getX(), instance.getY())
    }

    /**
    * @param array<string, int> array
    * @param ?int number
    * @return _Coordinates
    */
    FROM_ARRAY(array, number := 1)
    {
        return new this(array["x" number], array["y" number])
    }

    /**
    * @param bool allowEmpty
    * @return void
    * @throws
    */
    validate(allowEmpty := true, errorLvl := 0)
    {
        if (allowEmpty) {
            if (this.x < 0 && this.x != "") || (this.y < 0 && this.y != "") {
                throw Exception("Invalid coordinates, x: " this.x ", y: " this.y, errorLvl)
            }

            return
        }

        if (this.x < 0) || (this.y < 0) {
            throw Exception("Invalid coordinates, x: " this.x ", y: " this.y, errorLvl)
        }
    }

    /**
    * @param string type
    * @return ?int
    */
    get()
    {
        return this["get" type]()
    }

    /**
    * @param string type
    * @param ?int value
    * @return this
    * @throws
    */
    set(type, value := "")
    {
        this["set" type](value)
        return this
    }

    /**
    * @return int
    */
    getX()
    {
        return this.x
    }

    /**
    * @return int
    */
    getY()
    {
        return this.y
    }

    /**
    * @param int value
    * @return this
    * @throws
    */
    setX(value)
    {
        _Validation.numberOrEmpty("value", value)
        this.x := value

        return this
    }

    /**
    * @return this
    * @throws
    */
    setY(value)
    {
        _Validation.numberOrEmpty("value", value)
        this.y := value

        return this
    }

    /**
    * @param int value
    * @return this
    */
    add(value)
    {
        this.addX(value)
        this.addY(value)

        return this
    }

    /**
    * @param int value
    * @return this
    * @throws
    */
    addX(value)
    {
        _Validation.numberOrEmpty("value", value)
        this.x += value

        return this
    }

    /**
    * @param int value
    * @return this
    * @throws
    */
    addY(value)
    {
        _Validation.numberOrEmpty("value", value)
        this.y += value

        return this
    }

    /**
    * @param int value
    * @return this
    */
    sub(value)
    {
        this.subX(value)
        this.subY(value)

        return this
    }

    /**
    * @param int value
    * @return this
    * @throws
    */
    subX(value)
    {
        _Validation.number("value", value)
        this.x -= value

        return this
    }

    /**
    * @param int value
    * @return this
    * @throws
    */
    subY(value)
    {
        _Validation.number("value", value)
        this.y -= value

        return this
    }

    /**
    * @param int value
    * @return this
    */
    div(value)
    {
        this.divX(value)
        this.divY(value)

        return this
    }

    /**
    * @param int value
    * @return this
    * @throws
    */
    divX(value)
    {
        _Validation.numberOrEmpty("value", value)
        this.x := this.x / value

        return this
    }

    /**
    * @param int value
    * @return this
    * @throws
    */
    divY(value)
    {
        _Validation.numberOrEmpty("value", value)
        this.y := this.y / value

        return this
    }

    /**
    * @return int
    */
    getClickX()
    {
        return this.getX() + this.getClickOffsetX()
    }

    /**
    * @return int
    */
    getClickY()
    {
        return this.getY() + this.getClickOffsetY()
    }

    /**
    * @return int
    */
    getClickOffsetX()
    {
        return this.clickOffsetX ? this.clickOffsetX : 0
    }

    /**
    * @return int
    */
    getClickOffsetY()
    {
        return this.clickOffsetY ? this.clickOffsetY : 0
    }

    /**
    * @param int offset
    * @return this
    */
    setClickOffsetX(offset)
    {
        return this.setClickOffset("X", offset)
    }

    /**
    * @param int offset
    * @return this
    */
    setClickOffsetY(offset)
    {
        return this.setClickOffset("Y", offset)
    }

    /**
    * @param int offset
    * @return this
    */
    setClickOffsets(offset)
    {
        _Validation.number("offset", offset)

        this.setClickOffsetX(offset)
        this.setClickOffsetY(offset)

        return this
    }

    /**
    * @param string type
    * @param ?int offset
    * @return this
    */
    setClickOffset(type, offset)
    {
        offset := offset ? offset : 0
        _Validation.number("offset", offset)

        this["clickOffset" type] := offset

        return this
    }

    /**
    * @return this
    * @msgbox
    */
    debug(string1 := "x", string2 := "y", extra := "")
    {
        Gui, Carregando:Destroy
        WinActivate()
        MouseMove(this.getX(), this.getY(), true, false)
        msgbox, % string1 ": " this.getX() ", " string2 ": " this.getY() (extra ? "`n" extra : "")

        return this
    }

    /**
    * @param ?string button
    * @param ?int repeat
    * @param ?int delay
    * @param ?bool debug
    * @return this
    */
    click(button := "Left", repeat := 1, delay := "", debug := false)
    {
        loop, % repeat {
            Click({"button": (button = "Left" ? "Left" : "Right"), "posX": this.getClickX(), "posY": this.getClickY(), "menuClickDefaultMethod": this.defaultClickMethod, "debug": debug})

            if (A_Index > 1) {
                Sleep, % delay ? delay : _Coordinate.DEFAULT_CLICK_REPEAT_DELAY
            }
        }

        return this
    }

    /**
    * @param string modifier
    * @param ?string button
    * @param ?int repeat
    * @param ?int delay
    * @param ?bool debug
    * @return this
    */
    clickWithModifier(modifier, button := "Left", repeat := 1, delay := "", debug := false)
    {
        loop, % repeat {
            MouseClickModifier(modifier, button, this.getClickX(), this.getClickY(), params.debug)

            if (A_Index > 1) {
                Sleep, % delay ? delay : _Coordinate.DEFAULT_CLICK_REPEAT_DELAY
            }
        }

        return this
    }

    /**
    * @param ?bool value
    * @return this
    */
    setDefaultClickMethod(value := false)
    {
        this.defaultClickMethod := value
        return this
    }

    /**
    * @param ?bool background
    * @param ?bool debug
    * @return void
    */
    moveMouse(background := true, debug := false)
    {
        if (background || debug) {
            MouseMove(this.getClickX(), this.getClickY(), debug)
            return
        }

        MouseMove, WindowX + this.getClickX(), WindowY + this.getClickY()
    }

    /**
    * @param _Coordinate destination
    * @param ?bool debug
    * @return void
    */
    drag(destination, debug := false)
    {
        MouseDrag(this.getClickX(), this.getClickY(), destination.getX(), destination.getY(),, debug)
    }

    /**
    * @param ?bool debug
    * @return bool
    */
    clickOnUse(debug := false)
    {
        return rightClickOnUse(this.getClickX(), this.getClickY(), debug)
    }

    /**
    * @return void
    */
    useMenu()
    {
        rightClickUse(this.getClickX(), this.getClickY())
    }

    /**
    * @return void
    */
    use()
    {
        rightClickUseClassicControl(this.getClickX(), this.getClickY())
    }

    /**
    * @return bool
    */
    useWithoutCtrl()
    {
        return rightClickUseWithoutPressingCtrl(this.getClickX(), this.getClickY())
    }

    /**
    * @return string
    */
    toString()
    {
        return this.getX() "," this.getY()
    }

}