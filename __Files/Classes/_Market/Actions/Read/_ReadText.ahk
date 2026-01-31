
class _ReadText extends _BaseClass
{
    static SELECTED_GRAY_PIXEL := "0x585858"
    static SELECTED_NUMBER_PIXEL := "0xC0C0C0"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(clientArea)
    {
        _Validation.instanceOf("clientArea", clientArea, _AbstractClientArea)

        this.clientArea := clientArea
        this.numbersOnly(false)
        this._withBreaklines := false
        this._replaceBackground := true
    }

    /**
    * @param string type
    * @return string
    * 
    */
    ENDS_AT(type)
    {
        endsAt := new this(type == "buy" ? new _BuyEndsAtArea() : new _SellEndsAtArea()).run()

        endsAt := StrReplace(endsAt, ",", "")

        return endsAt
    }

    /**
    * @return string
    * @throws
    */
    run()
    {
        return this.sanitizeText(this.read())
    }

    /**
    * @return string
    */
    read()
    {
        bitmap := _BitmapEngine.getClientBitmap(this.clientArea.getCoordinates())
        if (this._replaceBackground) {
            bitmap.iteratePixels(this.paintBackgroundGray.bind(this))
        }

        if (this._debug) {
            ; bitmap.save(this.TEMP_IMAGE)
            bitmap.debug()
        }

        try {
            ocr := new _OCR()
            if (this._numbersOnly) {
                ocr.numbersOnly(this._numbersOnly)
            }

            if (this._increaseDpi) {
                ocr.increaseDpi()
            }

            if (this._psm) {
                ocr.psm(this._psm)
            }

            return ocr.run(bitmap)
        } finally {
            bitmap.dispose()
        }
    }

    /**
    * @param string string
    * @return string
    */
    sanitizeText(string)
    {
        return trim(this.replaceLinesAndSpaces(string))
    }

    /**
    * @param string string
    * @return string
    */
    replaceLinesAndSpaces(string)
    {
        replace := Array("`t")
        if (!this._withBreaklines) {
            replace.Push("`n")
        }

        for, _, char in replace {
            string := StrReplace(string, char, "")
        }

        return string
    }

    paintBackgroundGray(bitmap, pixel, coordinate)
    {
        if (pixel != this.SELECTED_NUMBER_PIXEL && pixel != "0xF4F4F4") {
            ; bitmap.setPixel(coordinate, this.SELECTED_GRAY_PIXEL)
            bitmap.setPixel(coordinate, "0x000000")
        }
        if (pixel == this.SELECTED_NUMBER_PIXEL) {
            ; bitmap.setPixel(coordinate, this.SELECTED_GRAY_PIXEL)
            bitmap.setPixel(coordinate, "0xFFFFFF")
        }
    }

    ;#Region Setters
    /**
    * @param bool value
    * @return this
    */
    debug(value := true)
    {
        this._debug := value

        return this
    }

    /**
    * @param bool value
    * @return this
    */
    numbersOnly(value)
    {
        this._numbersOnly := value

        return this
    }

    /**
    * @param int value
    * @return this
    */
    psm(value)
    {
        this._psm := value

        return this
    }

    /**
    * @param bool value
    * @return this
    */
    withBreaklines(value)
    {
        this._withBreaklines := value

        return this
    }
    ;#Endregion
}