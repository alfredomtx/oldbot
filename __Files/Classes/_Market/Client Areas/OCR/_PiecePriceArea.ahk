#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\_OcrArea.ahk

class _PiecePriceArea extends _OcrArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "piecePriceArea"

    static PIECE_PRICE_OFFSET_X := 82
    static PIECE_PRICE_OFFSET_Y := -3
    static PIECE_PRICE_WIDTH := 80
    static PIECE_PRICE_HEIGHT := 14

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_PiecePriceArea.INSTANCE) {
            return _PiecePriceArea.INSTANCE
        }

        base.__New(this)

        _PiecePriceArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        search := this.searchImage("images_market.texts.piece_price", new _MarketWindowArea())

        c1 := _Coordinate.FROM(search.getResult())
            .addX(this.PIECE_PRICE_OFFSET_X)
            .addY(this.PIECE_PRICE_OFFSET_Y)

        c2 := _Coordinate.FROM(c1)
            .addX(this.PIECE_PRICE_WIDTH)
            .addY(this.PIECE_PRICE_HEIGHT)

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
        return _PiecePriceArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _PiecePriceArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _PiecePriceArea.INSTANCE := ""
        _PiecePriceArea.INITIALIZED := false
    }
}