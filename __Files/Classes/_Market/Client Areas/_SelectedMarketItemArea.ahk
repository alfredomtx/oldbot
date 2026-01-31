#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _SelectedMarketItemArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "selectedMarketItemArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_SelectedMarketItemArea.INSTANCE) {
            return _SelectedMarketItemArea.INSTANCE
        }

        base.__New(this)

        _SelectedMarketItemArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        area := new _BalanceArea()

        c1 := _Coordinate.FROM(area.getC1())
            .subX(40)
            .subY(61)

        c2 := _Coordinate.FROM(c1)
            .addX(162)
            .addY(36)

        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)
        ; this.debug()
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _SelectedMarketItemArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _SelectedMarketItemArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _SelectedMarketItemArea.INSTANCE := ""
        _SelectedMarketItemArea.INITIALIZED := false
    }
}