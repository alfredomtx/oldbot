#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\_OcrArea.ahk

class _MyOffersCancelBuyButtonArea extends _OcrArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "myOffersCancelBuyButtonArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_MyOffersCancelBuyButtonArea.INSTANCE) {
            return _MyOffersCancelBuyButtonArea.INSTANCE
        }

        base.__New(this)

        _MyOffersCancelBuyButtonArea.INSTANCE := this
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
            .addY(area.getHeight() / 2)
            .subY(50)

        c2 := _Coordinate.FROM(c1)
            .addX(_MarketWindowArea.CANCEL_BUTTON_WIDTH)
            .addY(110)

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
        return _MyOffersCancelBuyButtonArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _MyOffersCancelBuyButtonArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _MyOffersCancelBuyButtonArea.INSTANCE := ""
        _MyOffersCancelBuyButtonArea.INITIALIZED := false
    }
}