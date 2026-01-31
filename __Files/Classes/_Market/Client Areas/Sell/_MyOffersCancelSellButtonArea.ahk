class _MyOffersCancelSellButtonArea extends _OcrArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "myOffersCancelSellButtonArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_MyOffersCancelSellButtonArea.INSTANCE) {
            return _MyOffersCancelSellButtonArea.INSTANCE
        }

        base.__New(this)

        _MyOffersCancelSellButtonArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        area := new _MarketWindowArea()

        ml := 10

        c1 := _Coordinate.FROM(area.getC1())
            .addX((area.getCoordinates().getWidth() - _MarketWindowArea.CANCEL_BUTTON_WIDTH) - ml)

        c2 := _Coordinate.FROM(c1)
            .addX(_MarketWindowArea.CANCEL_BUTTON_WIDTH)
            .addY(100)

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
        return _MyOffersCancelSellButtonArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _MyOffersCancelSellButtonArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _MyOffersCancelSellButtonArea.INSTANCE := ""
        _MyOffersCancelSellButtonArea.INITIALIZED := false
    }
}