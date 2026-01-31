#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\_OcrArea.ahk

class _CreateOfferSelectedAmountArea extends _OcrArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "createOfferSelectedAmountArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_CreateOfferSelectedAmountArea.INSTANCE) {
            return _CreateOfferSelectedAmountArea.INSTANCE
        }

        base.__New(this)

        _CreateOfferSelectedAmountArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        area := new _PiecePriceArea()

        c1 := _Coordinate.FROM(area.getC1())
            .subX(7)
            .subY(37)

        c2 := _Coordinate.FROM(c1)
            .addX(_AbstractSelectedAmountArea.SELECTED_AMOUNT_WIDTH)
            .addY(_AbstractRowArea.ROW_HEIGHT)

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
        return _CreateOfferSelectedAmountArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _CreateOfferSelectedAmountArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _CreateOfferSelectedAmountArea.INSTANCE := ""
        _CreateOfferSelectedAmountArea.INITIALIZED := false
    }
}