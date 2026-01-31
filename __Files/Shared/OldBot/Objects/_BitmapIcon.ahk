#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Objects\_Icon.ahk

class _BitmapIcon extends _Icon
{
    __New(bitmap)
    {
        _Validation.instanceOf("bitmap", bitmap, _BitmapImage)

        this.bitmap := bitmap
    }

    FROM_ITEM(itemName)
    {
        item := itemsImageObj[itemName]
        if (!item) {
            return
        }

        bitmap := new _BitmapImage(item.image_full)

        return new _BitmapIcon(bitmap)
    }

    getBitmap()
    {
        return this.bitmap
    }
}