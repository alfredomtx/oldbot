#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractRowArea.ahk

class _AbstractEndsAtArea extends _AbstractRowArea
{
    static ENDS_AT_OFFSET_X := -2
    static ENDS_AT_WIDTH := 150

    getImageName()
    {
        return "ends_at"
    }

    getOffsetX()
    {
        return this.ENDS_AT_OFFSET_X
    }

    getWidth()
    {
        return this.ENDS_AT_WIDTH
    }
}