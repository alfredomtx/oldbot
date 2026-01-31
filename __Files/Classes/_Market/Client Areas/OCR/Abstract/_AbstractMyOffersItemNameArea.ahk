#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\_OcrArea.ahk

class _AbstractMyOffersItemNameArea extends _OcrArea
{
    getImageName()
    {
        abstractMethod()
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        search := this.searchImage("images_market.texts.my_offers." this.getImageName(), new _MarketWindowArea())

        c1 := _Coordinate.FROM(search.getResult())
            .addX(2)
            .addY(41)

        c2 := _Coordinate.FROM(c1)
            .addX(180)
            .addY(isWideMarket() ? 226 : 165)

        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)
        if (this.debugArea) {
            this.debug()
        }
    }
}