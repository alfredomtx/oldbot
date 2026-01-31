

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

/**
* @property int x1
* @property int y1
* @property int x2
* @property int y2
*/
class _Coordinates extends _BaseClass
{
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @param ?_Coordinate coordinate1
    * @param ?_Coordinate coordinate2
    * @throws
    */
    __New(coordinate1 := "", coordinate2 := "")
    {
        if (coordinate1) {
            this.setX1(coordinate1.getX())
            this.setY1(coordinate1.getY())
        }

        if (coordinate2) {
            this.setX2(coordinate2.getX())
            this.setY2(coordinate2.getY())
        }
    }

    /**
    * @return _Coordinates
    */
    CLONE()
    {
        return new this(this.getC1(), this.getC2())
    }

    /**
    * @param _Coordinates instance
    * @return _Coordinates
    */
    FROM(instance)
    {
        _Validation.instanceOf("instance", instance, _Coordinates)
        return new this(instance.getC1(), instance.getC2())
    }

    /**
    * @param array<string, int> array
    * @return _Coordinates
    */
    FROM_ARRAY(array)
    {
        return new this(_Coordinate.FROM_ARRAY(array, 1), _Coordinate.FROM_ARRAY(array, 2))
    }

    /**
    * @return this
    * @throws
    */
    validate()
    {
        if (this.x1 < 0 || this.y1 < 0 || this.x2 < 0 || this.y2 < 0) {
            throw Exception("Invalid coordinates, x1: " this.x1 ", y1: " this.y1 ", x2: " this.x2 ", y2: " this.y2)
        }

        if (this.x2 > WindowWidth) {
            throw Exception("Invalid coordinates x2: " this.x2 ", WindowWidth: " WindowWidth)
        }

        if (this.y2 > WindowHeight) {
            throw Exception("Invalid coordinates y2: " this.y2 ", WindowHeight: " WindowHeight)
        }

        if (this.x1 = this.x2) {
            throw Exception("x1 same as x2")
        }

        if (this.y1 = this.y2) {
            throw Exception("y1 same as y2")
        }

        return this
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
    * @param string type
    * @param int value
    * @return this
    * @throws
    */
    set(type, value)
    {
        this["set" type](value)
        return this
    }

    /**
    * @return _Coordinate
    */
    getC1()
    {
        return new _Coordinate(this.x1, this.y1)
    }

    /**
    * @return _Coordinate
    */
    getC2()
    {
        return new _Coordinate(this.x2, this.y2)
    }

    /**
    * @return _Coordinate
    */
    getCenter()
    {
        return new _Coordinate(this.x1, this.y1)
            .addX(this.getW() / 2)
            .addY(this.getH() / 2)
    }

    /**
    * @return int
    */
    getX1()
    {
        return this.x1
    }

    /**
    * @return int
    */
    getY1()
    {
        return this.y1
    }

    /**
    * @return int
    */
    getX2()
    {
        return this.x2
    }

    /**
    * @return int
    */
    getY2()
    {
        return this.y2
    }

    /**
    * @return int
    */
    getW()
    {
        return abs(this.getX2() - this.getX1())
    }

    /**
    * @return int
    */
    getH()
    {
        return abs(this.getY2() - this.getY1())
    }

    /**
    * @param int value
    * @return this
    * @throws
    */
    setX1(value)
    {
        _Validation.number("value", value)
        this.x1 := value

        return this
    }

    /**
    * @return this
    * @throws
    */
    setY1(value)
    {
        _Validation.number("value", value)
        this.y1 := value

        return this
    }

    /**
    * @return this
    * @throws
    */
    setX2(value)
    {
        _Validation.number("value", value)
        this.x2 := value

        return this
    }

    /**
    * @return this
    * @throws
    */
    setY2(value)
    {
        _Validation.number("value", value)
        this.y2 := value

        return this
    }

    /**
    * @return int
    */
    getWidth()
    {
        return abs(this.getX2() - this.getX1())
    }

    /**
    * @return int
    */
    getHeight()
    {
        return abs(this.getY2() - this.getY1())
    }

    /**
    * @param ?string msg
    * @return this
    * @msgbox
    */
    debug(msg := "", debugCoordinates := false)
    {
        this.validate()
        msg := msg ? msg ": ": ""

        _BitmapEngine.getClientBitmap(this).debug(true, msg)
        if (!debugCoordinates) {
            return this
        }

        _ := new _Coordinate(this.getX1(), this.getY1())
            .debug(msg "x1", "y1")
        _ := new _Coordinate(this.getX2(), this.getY2())
            .debug(msg "x2", "y2")

        return this
    }

    /**
    * @param int value
    * @return this
    */
    addX1(value)
    {
        this.getC1().addX(value)
        return this
    }

    /**
    * @param int value
    * @return this
    */
    addY1(value)
    {
        this.getC1().addY(value)
        return this
    }

    /**
    * @param int value
    * @return this
    */
    addX2(value)
    {
        this.getC2().addX(value)
        return this
    }

    /**
    * @param int value
    * @return this
    */
    addY2(value)
    {
        this.getC2().addY(value)
        return this
    }
}