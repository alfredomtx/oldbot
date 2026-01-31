

class _MultipleBitmapSearch extends _BitmapImageSearch
{
    __New(bitmaps)
    {
        base.__New(this)

        _Validation.isObject("bitmaps", bitmaps)
        this.bitmaps := bitmaps

        this.disposeScreenBitmapAfterSearch := false
    }

    /**
    * @return this
    */
    search()
    {
        this.anyFound := false

        try {
            this.getScreenBitmap()

            for _, bitmap in this.bitmaps {
                this.setBitmap(bitmap)

                base.search()

                if (this.found()) {
                    ; this.getResult().moveMouse(background := false)
                    this.anyFound := true
                    return this
                }
            }
        } finally {
            this.disposeScreenBitmap()
        }

        return this
    }

    isAnyFound()
    {
        return this.anyFound
    }
}