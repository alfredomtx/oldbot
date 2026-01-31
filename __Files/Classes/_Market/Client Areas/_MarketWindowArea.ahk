#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _MarketWindowArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "marketWindowArea"

    static OFFERS_AREA_WIDTH
    static OFFERS_AREA_HEIGHT
    static OFFERS_AREA_OFFSET_X
    static OFFERS_AREA_OFFSET_Y

    static CANCEL_BUTTON_WIDTH := 75

    static IS_WIDE

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_MarketWindowArea.INSTANCE) {
            return _MarketWindowArea.INSTANCE
        }

        base.__New(this)

        _MarketWindowArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        title := ims("images_market.window.title").search()
        if (title.notFound()) {
            throw Exception(txt("Janela do Market não localizada.", "Market window not found."))
        }

        close := ims("images_market.buttons.close").search()
        if (close.notFound()) {
            throw Exception("Botão ""Close"" não encontrado.", """Close"" button not found.")
        }

        distance := abs(title.getX() - close.getX())

        _MarketWindowArea.IS_WIDE := distance > 400

        rubinotWidth := 1000
        taleonWidth := 750
        rubinotHeight := 645
        taleonHeight := 545
        rubinotOffersWidth := 800
        taleonOffersWidth := 550

        _MarketWindowArea.OFFERS_AREA_WIDTH := isWideMarket() ? 800 : 550
        _MarketWindowArea.OFFERS_AREA_HEIGHT := isWideMarket() ? 223 : 160
        _MarketWindowArea.OFFERS_AREA_OFFSET_X := 185
        _MarketWindowArea.OFFERS_AREA_OFFSET_Y := isWideMarket() ? 28 : 41

        offsetFromTitle := isWideMarket() ? 477 : 352
        c1 := _Coordinate.FROM(title.getResult())
            .subX(offsetFromTitle)

        c2 := _Coordinate.FROM(c1)
            .addX(isWideMarket() ? rubinotWidth : taleonWidth)
            .addY(isWideMarket() ? rubinotHeight : taleonHeight)

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
        return _MarketWindowArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _MarketWindowArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _MarketWindowArea.INSTANCE := ""
        _MarketWindowArea.INITIALIZED := false
    }
}