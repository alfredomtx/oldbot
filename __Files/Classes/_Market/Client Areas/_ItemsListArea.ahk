#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _ItemsListArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "itemsListArea"

    static WIDTH := 159
    static HEIGHT := 242

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @singleton
    */
    __New()
    {
        if (_ItemsListArea.INSTANCE) {
            return _ItemsListArea.INSTANCE
        }

        base.__New(this)

        _ItemsListArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        area := new _FirstMarketItemArea()

        c1 := _Coordinate.FROM(area.getC1())

        c2 := _Coordinate.FROM(c1)
            .addX(this.WIDTH)
            .addY(this.HEIGHT)

        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _ItemsListArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _ItemsListArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _ItemsListArea.INSTANCE := ""
        _ItemsListArea.INITIALIZED := false
    }
}