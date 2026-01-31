
global HELMET_X
global HELMET_Y

/**
*/
class _HelmetArea extends _AbstractEquipmentArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "helmetArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_HelmetArea.INSTANCE) {
            return _HelmetArea.INSTANCE
        }

        base.__New(this)

        _HelmetArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        ; TODO: create abstract class for this type of area without empty slot image
        area := new _EquipmentArea()

        c1 := new _Coordinate(area.getX1(), area.getY1())
            .addX(35)
            .subY(3)

        c2 := c1.CLONE()
            .addX(40)
            .addY(40)
        coordinates := new _Coordinates(c1, c2)
        if (ItemRefillSystem.itemRefillJsonObj.options.debug = true) {
            coordinates.debug()
        }

        this.setCoordinates(coordinates)
        this.areaFound := true

        center := this.getCoordinates().getCenter()

        HELMET_X := center.getX()
        HELMET_Y := center.getY()
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _HelmetArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _HelmetArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    unsetInitialized() {
        _HelmetArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @return string
    */
    resolveImageFolder() {
        return "amulet"
    }
}