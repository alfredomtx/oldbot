#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

/**
* @property ?string identifier
* @property int bitmap
* @property int hBitmap
*/
class _BitmapImage
{
    static SOURCE_CLIPBOARD := "clipboard"

    __Delete() {
        this.dispose()
    }

    /**
    * @param int|string source
    * @throws
    */
    __New(source := "")
    {
        this.fileName := ""
        this.fileDir := ""

        this.createFromSource(source)


        if (!this.bitmap) {
            throw Exception("Bitmap was not created from source: " source, -1)
        }
    }

    /**
    * @param string source
    */
    createFromSource(source)
    {
        if source is number
        {
            this.bitmap := source
            return
        }

        if (InStr(source, "iVBOR") || InStr(source, "/9j/")) {
            this.fromBase64(source)
            return
        }

        if (source = _BitmapImage.SOURCE_CLIPBOARD) {
            return this.fromClipboard()
        }

        this.fromFile(source)
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return this.identifier
    }

    /**
    * @return ?string
    */
    getFileName()
    {
        return this.fileName
    }

    /**
    * @return ?string
    */
    getFileDir()
    {
        return this.fileDir
    }

    /**
    * @param string identifier
    * @return this
    */
    setIdentifier(identifier)
    {
        this.identifier := identifier
        return this
    }

    /**
    * @return int bitmap
    */
    get()
    {
        return this.bitmap
    }

    /**
    * @return int
    */
    getHBitmap()
    {
        /*
        for some reason caching the hbitmap is not working properly with listview(blank image)
        */
        ; if (this.hBitmap) {
        ;     return this.hBitmap
        ; }
        this.disposeHBitmap()

        if (!this.get()) {
            throw Exception("Trying to create HBitmap with empty bitmap.")
        }

        this.hBitmap := Gdip_CreateHBITMAPFromBitmap(this.get())

        return this.hBitmap
    }

    /**
    * @return void
    */
    dispose()
    {
        this.disposeHBitmap(), this.disposeBitmap()
    }

    /**
    * @return void
    */
    disposeBitmap()
    {
        if (!this.bitmap) {
            return
        }

        Gdip_DisposeImage(this.bitmap), DeleteObject(this.bitmap), this.bitmap := ""
    }

    /**
    * @return void
    */
    disposeHBitmap()
    {
        if (!this.hBitmap) {
            return
        }

        DeleteObject(this.hBitmap), this.hBitmap := ""
    }

    /**
    * @return bool
    */
    isValid()
    {
        if (!this.get()) {
            return false
        }

        try {
            _BitmapEngine.isValidBitmap(this.get())
        } catch {
            this.dispose()
            return false
        }

        return true
    }

    /**
    * @param int bitmap
    * @return bool
    */
    isInvalid()
    {
        return !this.isValid()
    }

    /**
    * @param string filePath
    * @return void
    * @throws
    */
    fromFile(filePath)
    {
        _Validation.fileExists("filePath", filePath)

        try {
            this.bitmap := Gdip_CreateBitmapFromFile(filePath)
            SplitPath, % filePath, fileName, fileDir
            this.fileName := fileName
            this.fileDir := fileDir
        } catch e {
            _Logger.exception(e, A_ThisFunc ".Gdip_CreateBitmapFromFile", filePath)
            throw e
        }
    }

    /**
    * @return void
    * @throws
    */
    fromClipboard()
    {
        try {
            this.bitmap := Gdip_CreateBitmapFromClipboard()
        } catch e {
            _Logger.exception(e, A_ThisFunc ".Gdip_CreateBitmapFromClipboard")
            throw e
        }

        if (this.isInvalid()) {
            this.dispose()
            throw Exception("Invalid bitmap from clipboard")
        }

    }

    /**
    * @param string base64
    * @return void
    * @throws
    */
    fromBase64(base64)
    {
        try {
            this.bitmap := GdipCreateFromBase64(base64)
        } catch e {
            _Logger.exception(e, A_ThisFunc ".GdipCreateFromBase64", base64)
            throw e
        }

        return this.bitmap
    }

    /**
    * @return string
    * @throws
    */
    toBase64()
    {
        try {
            return Gdip_EncodeBitmapTo64string(this.bitmap, "png", 100)
        } catch e {
            _Logger.exception(e, A_ThisFunc ".GdipCreateFromBase64", base64)
            throw e
        }
    }

    /**
    * @return int
    */
    getWidth()
    {
        return this.getW()
    }

    /**
    * @return int
    * @throws
    */
    getW()
    {
        try {
            return Gdip_GetImageWidth( this.get() )
        } catch e {
            _Logger.exception(e, A_ThisFunc ".Gdip_GetImageWidth", this.getIdentifier())
            throw e
        }
    }

    /**
    * @return int
    */
    getHeight()
    {
        return this.getH()
    }

    /**
    * @return int
    * @throws
    */
    getH()
    {
        try {
            return Gdip_GetImageHeight( this.get() )
        } catch e {
            _Logger.exception(e, A_ThisFunc ".Gdip_GetImageHeight", this.getIdentifier())
            throw e
        }
    }

    /**
    * @param ?bool msgbox
    * @return void
    * @msgbox
    */
    debug(msgbox := true, msg := "")
    {
        this.toClipboard()
        if (msgbox) {
            Gui, Carregando:Destroy
            msgbox, % "Bitmap to clipboard: " this.bitmap (msg ? "`n`n" msg : "")
        }
    }

    /**
    * @return void
    * @throws
    */
    toClipboard()
    {
        try {
            Gdip_SetBitmapToClipboard(this.bitmap)
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            throw e
        }
    }

    /**
    * @return this
    */
    shrink(shrinkRight := 4, shrinkBottom := 4)
    {
        ; Get the original width and height of the image
        ; Get the original image dimensions
        width := this.getW()
        height := this.getH()

        ; Calculate new dimensions
        newWidth := width - shrinkRight
        newHeight := height - shrinkBottom

        ; Calculate scaling factors
        scaleX := newWidth / width
        scaleY := newHeight / height

        ; Create a new smaller image
        newBitmap := Gdip_CreateBitmap(newWidth, newHeight)

        ; Create a graphics object for the new image
        graphics := Gdip_GraphicsFromImage(newBitmap)

        ; Set interpolation mode to high quality
        Gdip_SetInterpolationMode(graphics, 7) ; InterpolationModeHighQuality

        ; Scale and draw the original image onto the new image
        Gdip_DrawImage(graphics, this.bitmap, 0, 0, newWidth, newHeight)
        ; Gdip_SetBitmapToClipboard(newBitmap)
        Gdip_DeleteGraphics(graphics)

        this.dispose()

        this.bitmap := newBitmap

        return this
    }

    /**
    * @return this
    */
    cropSelf(left, right, up := 0, down := 0)
    {
        bitmap := this.crop(left, right, up, down)
        this.dispose()

        this.bitmap := bitmap
        ; this.toClipboard()

        return this
    }

    /**
    * @return _BitmapImage
    * @throws
    */
    crop(left, right, up, down)
    {
        _Validation.number(left)
        _Validation.number(right)
        _Validation.number(up)
        _Validation.number(down)

        if (left > this.getW() || right > this.getW()) {
            throw Exception("Horizontal crop too wide: " left ", " right " of " this.getW())
        }

        if (left + right > this.getW()) {
            throw Exception("Combined horizontal crop too wide: " left + right " of " this.getW())
        }

        if (up > this.getH() || down > this.getH()) {
            throw Exception("Vertical crop too wide: " up ", " down " of " this.getH())
        }

        if (up + down > this.getH()) {
            throw Exception("Combined vertical crop too wide: " up + down " of " this.getH())
        }

        try {
            bitmap := Gdip_CropBitmap(this.get(), left, right, up, down, false)
            return bitmap
        } catch e {
            _Logger.exception(e, A_ThisFunc ".Gdip_CropBitmap", left "," right "," up "," down)
            this.dispose()
            throw e
        }
    }

    /**
    * @param _Coordinates cropArea
    * @param _Coordinates bitmapArea
    * @return _BitmapImage
    * @throws
    */
    cropFromArea(bitmapArea, cropArea)
    {
        _Validation.instanceOf("bitmapArea", bitmapArea, _Coordinates)
        _Validation.instanceOf("cropArea", cropArea, _Coordinates)
        _Validation.equals(this.getW(), bitmapArea.getWidth())
        _Validation.equals(this.getH(), bitmapArea.getHeight())

        up := cropArea.getY1() - bitmapArea.getY1()
        down := abs(bitmapArea.getY2() - cropArea.getY2())
        left := cropArea.getX1()
        right := abs(bitmapArea.getX2() - cropArea.getX2())
        return this.crop(left, right, up, down)
    }

    /**
    * @param string filePath
    * @return this
    * @throws
    */
    save(filePath)
    {
        _Validation.empty("filePath", filePath)
        _Validation.number("this.get()", this.get())

        if (!InStr(filePath, ".png")) {
            throw Exception("Missing "".png"" extension: " filePath)
        }

        try {
            FileDelete, % filePath
        } catch {
        }

        try {
            Gdip_SaveBitmapToFile(this.get(), filePath, 100)
        } catch e {
            _Logger.exception(e, A_ThisFunc ".Gdip_SaveBitmapToFile", filePath)
            throw e
        }

        return this
    }

    /**
    * @param _Coordinate coordinate
    * @return hex
    * @throws
    */
    getPixel(coordinate)
    {
        _Validation.instanceOf("coordinate", coordinate, _Coordinate)
            , coordinate.validate(false)
            , x := coordinate.getX(), y := coordinate.getY()

        if (x > this.getW()) {
            throw exception("X outside limit: " x "/" this.getW(), this.getIdentifier())
        }

        if (y > this.getH()) {
            throw exception("Y outside limit: " y "/" this.getH(), this.getIdentifier())
        }

        try {
            pixColor := ConvertARGB(Gdip_GetPixel(this.get(), x, y, A_ThisFunc))
            SetFormat, Integer, D

            ; if (pixColor = "0x0") {
            ;     throw Exception("Invalid pixel result on get pixel, x: " x ", " y, this.getIdentifier())
            ; }
        } catch e {
            _Logger.exception(e, A_ThisFunc, se(coordinate))
            throw e
        }

        return pixColor
    }

    /**
    * @param _Coordinate coordinate
    * @param hex color
    * @return this
    * @throws
    */
    setPixel(coordinate, color)
    {
        try {
            Gdip_SetPixel(this.get(), coordinate.getX(), coordinate.getY(), color)
        } catch e {
            _Logger.exception(e, A_ThisFunc, this.getIdentifier())
            throw e
        }
    }

    /**
    * @param BoundFunc callback
    * @return this
    */
    iteratePixels(callback)
    {
        w := this.getW()
        h := this.getH()

        x := 0
        loop, % w {
            y := 0
            if (x > w) {
                break
            }

            loop, % h {
                coordinate := new _Coordinate(x, y)
                pixel := this.getPixel(coordinate)
                callback.Call(this, pixel, coordinate)

                if (y > h) {
                    break
                }

                y++
            }

            x++
        }

        return this
    }

    getDpi()
    {
        return {"x": Gdip_GetImageHorizontalResolution(this.get()), "y": Gdip_GetImageVerticalResolution(this.get())}
    }

    increaseDpi(value)
    {
        dpi := this.getDpi()

        ; Calculate the scale factor
        scaleFactorX := value / dpi.x
        scaleFactorY := value / dpi.y

        ; Get the current dimensions of the image
        width := this.getW()
        height := this.getH()

        ; Calculate the new dimensions
        newWidth := Round(width * scaleFactorX)
        newHeight := Round(height * scaleFactorY)


        pResizedBitmap := Gdip_CreateBitmap(newWidth, newHeight)

        ; Create a graphics object from the resized bitmap
        pGraphics := Gdip_GraphicsFromImage(pResizedBitmap)

        ; Set interpolation mode to high quality for resizing
        Gdip_SetInterpolationMode(pGraphics, 7)  ; 7 = HighQualityBicubic

        ; Draw the original image onto the resized bitmap
        Gdip_DrawImage(pGraphics, this.get(), 0, 0, newWidth, newHeight)

        ; Set the new DPI
        Gdip_BitmapSetResolution(pResizedBitmap, value, value)

        Gdip_DeleteGraphics(pGraphics)
        this.dispose()

        this.bitmap := pResizedBitmap

        return this

    }
}