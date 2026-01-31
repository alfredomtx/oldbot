#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractRowArea.ahk

class _AbstractAmountArea extends _AbstractRowArea
{
    static AMOUNT_OFFSET_X := -5
    static AMOUNT_WIDTH := 58

    getImageName()
    {
        return "amount"
    }

    getOffsetX()
    {
        return this.AMOUNT_OFFSET_X
    }

    getWidth()
    {
        return this.AMOUNT_WIDTH
    }
}