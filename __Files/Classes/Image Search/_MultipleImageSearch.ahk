

class _MultipleImageSearch extends _ImageSearch
{
    __New(images)
    {
        base.__New(this)

        _Validation.isObject("images", images)
        this.images := images

        this.disposeScreenBitmapAfterSearch := false
        this.setDebug(false)

    }

    /**
    * @return this
    */
    search()
    {
        this.bitmapImageFound := ""

        try {
            this.getScreenBitmap()

            for _, filePath in this.images {
                this.setPath(filePath)

                base.setDebug(this.debug)

                base.search()

                if (this.found()) {
                    this.bitmapImageFound := this.getImageBitmap()
                    ; this.getResult().moveMouse(background := false)
                    return this
                }
            }
        } finally {
            this.disposeScreenBitmap()
        }

        return this
    }

    setDebug(value := true)
    {
        this.debug := value
        return this
    }

    /**
    * @return ?_BitmapImage
    */
    getImageFound()
    {
        return this.bitmapImageFound
    }
}