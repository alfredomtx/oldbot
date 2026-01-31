#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\_OcrArea.ahk

class _AbstractRowArea extends _OcrArea
{
    static ROW_HEIGHT := 16

    getImageName()
    {
        abstractMethod()
    }

    getOffsetX()
    {
        abstractMethod()
    }

    getWidth()
    {
        abstractMethod()
    }

    getHeight()
    {
        return this.ROW_HEIGHT
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        nameArea := InStr(this.__Class, "Buy", true) ? new _BuyNameArea() : new _SellNameArea()

        search := this.searchImage("images_market.table." this.getImageName(), InStr(this.__Class, "Buy", true) ? new _BuyOffersArea() : new _SellOffersArea())

        c1 := new _Coordinate(search.getX(), nameArea.getY1())
            .addX(this.getOffsetX())

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