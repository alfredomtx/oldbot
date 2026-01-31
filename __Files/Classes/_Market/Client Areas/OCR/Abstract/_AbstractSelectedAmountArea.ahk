#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractRowArea.ahk

class _AbstractSelectedAmountArea extends _AbstractRowArea
{
    static SELECTED_AMOUNT_OFFSET_X := 54
    static SELECTED_AMOUNT_OFFSET_Y := -2
    static SELECTED_AMOUNT_WIDTH := 55

    getOffsetX()
    {
        return this.SELECTED_AMOUNT_OFFSET_X
    }

    getOffsetY()
    {
        return this.SELECTED_AMOUNT_OFFSET_Y
    }

    getWidth()
    {
        return this.SELECTED_AMOUNT_WIDTH
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        search := this.searchImage("images_market.texts.amount", InStr(this.__Class, "Buy", true) ? new _BuyOffersArea() : new _SellOffersArea())

        c1 := _Coordinate.FROM(search.getResult())
            .addX(this.getOffsetX())
            .addY(this.getOffsetY())

        c2 := _Coordinate.FROM(c1)
            .addX(this.getWidth())
            .addY(this.getHeight())

        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)

        if (this.debugArea) {
            this.debug()
        }
    }
}