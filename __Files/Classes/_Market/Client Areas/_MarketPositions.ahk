
class _MarketPositions extends _BaseClass
{
    static AMOUNT_SLIDER_WIDTH := 138

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
    }

    firstSellOffer()
    {
        static coordinate
        return coordinate ? coordinate : coordinate := _Coordinate.FROM(new _SellNameArea().getC1())
            .addX(10)
            .addY(_AbstractRowArea.getHeight() / 2)
        ; .debug(,, A_ThisFunc)
    }

    firstBuyOffer()
    {
        static coordinate
        return coordinate ? coordinate : coordinate := _Coordinate.FROM(new _BuyNameArea().getC1())
            .addX(10)
            .addY(_AbstractRowArea.getHeight() / 2)
        ; .debug(,, A_ThisFunc)
    }

    decreaseCreateOfferAmount()
    {
        static coordinate
        return coordinate ? coordinate : coordinate := _Coordinate.FROM(new _PiecePriceArea().getC1())
            .addX(5)
            .subY(15)
        ; .debug(,, A_ThisFunc)
    }

    increaseCreateOfferAmount()
    {
        static coordinate
        return coordinate ? coordinate : coordinate := _Coordinate.FROM(this.decreaseCreateOfferAmount())
            .addX(this.AMOUNT_SLIDER_WIDTH)
        ; .debug(,, A_ThisFunc)
    }

    decreaseSellAmount()
    {
        static coordinate
        return coordinate ? coordinate : coordinate := _Coordinate.FROM(new _SellSelectedAmountArea().getC1())
            .addX(60)
            .addY(4)
    }

    decreaseBuyAmount()
    {
        static coordinate
        return coordinate ? coordinate : coordinate := _Coordinate.FROM(new _BuySelectedAmountArea().getC1())
            .addX(60)
            .addY(4)
        ; .debug(,, A_ThisFunc)
    }

    increaseSellAmount()
    {
        static coordinate
        return coordinate ? coordinate : coordinate := _Coordinate.FROM(this.decreaseSellAmount())
            .addX(this.AMOUNT_SLIDER_WIDTH)
        ; .debug(,, A_ThisFunc)
    }

    increaseBuyAmount()
    {
        static coordinate
        return coordinate ? coordinate : coordinate := _Coordinate.FROM(this.decreaseBuyAmount())
            .addX(this.AMOUNT_SLIDER_WIDTH)
        ; .debug(,, A_ThisFunc)
    }

    firstItem()
    {
        static coordinate
        return coordinate ? coordinate : coordinate := _Coordinate.FROM(new _FirstMarketItemArea().getC1())
            .addX(new _FirstMarketItemArea().getWidth() / 2)
            .addY(new _FirstMarketItemArea().getHeight() / 2)
        ; .debug(,, A_ThisFunc)
    }

    piecePriceInput()
    {
        static coordinate
        return coordinate ? coordinate : coordinate := _Coordinate.FROM(new _PiecePriceArea().getC1())
            .addX(new _PiecePriceArea().getWidth() / 2)
            .addY(new _PiecePriceArea().getHeight() / 2)
        ; .debug(,, A_ThisFunc)
    }

    sellRadioButton()
    {
        static coordinate
        return coordinate ? coordinate : coordinate := _Coordinate.FROM(new _BalanceArea().getC2())
            .addX(55)
            .subY(115)
            ; .debug(,, A_ThisFunc)
    }

    buyRadioButton()
    {
        static coordinate
        return coordinate ? coordinate : coordinate := _Coordinate.FROM(this.sellRadioButton())
            .addY(20)
        ; .debug(,, A_ThisFunc)
    }
}