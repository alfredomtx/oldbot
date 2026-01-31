#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractRowArea.ahk

class _AbstractPriceArea extends _AbstractRowArea
{
    static PRICE_OFFSET_X := -8
    static PRICE_WIDTH := 83

    getImageName()
    {
        return "piece_price"
    }

    getOffsetX()
    {
        return this.PRICE_OFFSET_X
    }

    getWidth()
    {
        return this.PRICE_WIDTH
    }
}