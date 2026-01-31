#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractRowArea.ahk

class _AbstractNameArea extends _AbstractRowArea
{
    static NAME_WIDTH := 128

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        marketArea := new _MarketWindowArea()

        search := this.searchImage("images_market.table.name", InStr(this.__Class, "Buy", true) ? new _BuyOffersArea() : new _SellOffersArea())
        c1 := _Coordinate.FROM(search.getResult())
            .subX(2)
            .addY(this.ROW_HEIGHT + 1)

        c2 := _Coordinate.FROM(c1)
            .addX(this.NAME_WIDTH)
            .addY(this.getHeight())

        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)
        if (this.debugArea) {
            this.debug()
        }
    }
}