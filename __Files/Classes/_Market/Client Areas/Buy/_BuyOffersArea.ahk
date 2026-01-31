#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _BuyOffersArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "buyOffersArea"

    static OFFERS_AREA_HEIGHT := 170

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_BuyOffersArea.INSTANCE) {
            return _BuyOffersArea.INSTANCE
        }

        base.__New(this)

        _BuyOffersArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        area := new _MarketWindowArea()
        sellArea := new _SellOffersArea()

        c1 := new _Coordinate(sellArea.getC1().getX(), area.getC1().getY())
            .addY(isWideMarket() ? 259 : 222)

        c2 := _Coordinate.FROM(c1)
            .addX(_MarketWindowArea.OFFERS_AREA_WIDTH)
            .addY(_MarketWindowArea.OFFERS_AREA_HEIGHT)

        coordinates := new _Coordinates(c1, c2)

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
        return _BuyOffersArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _BuyOffersArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _BuyOffersArea.INSTANCE := ""
        _BuyOffersArea.INITIALIZED := false
    }
}