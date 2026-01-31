#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _FirstMarketItemArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "firstMarketItemArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_FirstMarketItemArea.INSTANCE) {
            return _FirstMarketItemArea.INSTANCE
        }

        base.__New(this)

        _FirstMarketItemArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        items := ims("images_market.window.items").search()
        if (items.notFound()) {
            throw Exception(_Str.quoted("Items") " not found")
        }

        c1 := new _Coordinate(items.getX(), items.getY())
            .addX(1)
            .addY(17)

        c2 := _Coordinate.FROM(c1)
            .addX(146)
            .addY(36)

        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _FirstMarketItemArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _FirstMarketItemArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _FirstMarketItemArea.INSTANCE := ""
        _FirstMarketItemArea.INITIALIZED := false
    }
}