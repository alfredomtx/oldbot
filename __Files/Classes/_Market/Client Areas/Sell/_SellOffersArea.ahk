#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _SellOffersArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "sellOffersArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_SellOffersArea.INSTANCE) {
            return _SellOffersArea.INSTANCE
        }

        base.__New(this)

        _SellOffersArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        area := new _MarketWindowArea()

        c1 := _Coordinate.FROM(area.getC1())
            .addX(_MarketWindowArea.OFFERS_AREA_OFFSET_X)
            .addY(_MarketWindowArea.OFFERS_AREA_OFFSET_Y)

        c2 := _Coordinate.FROM(c1)
            .addX(_MarketWindowArea.OFFERS_AREA_WIDTH)
            .addY(_MarketWindowArea.OFFERS_AREA_HEIGHT)

        coordinates := new _Coordinates(c1, c2)
        ; .debug()

        this.setCoordinates(coordinates)
        if (this.debugArea) {
            this.debug()
        } 
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _SellOffersArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _SellOffersArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _SellOffersArea.INSTANCE := ""
        _SellOffersArea.INITIALIZED := false
    }
}