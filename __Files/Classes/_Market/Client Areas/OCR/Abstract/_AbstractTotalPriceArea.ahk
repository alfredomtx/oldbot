#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractRowArea.ahk

class _AbstractTotalPriceArea extends _AbstractRowArea
{
    static TOTAL_PRICE_OFFSET_X := -9
    static TOTAL_PRICE_WIDTH := 83

    getImageName()
    {
        return "total_price"
    }

    getOffsetX()
    {
        return this.TOTAL_PRICE_OFFSET_X
    }

    getWidth()
    {
        return this.TOTAL_PRICE_WIDTH
    }
}