/**
* @property _Coordinates coords
* @property _BitmapImage screenBitmap
*/
class _BitmapEngine
{
    __Delete()
    {
        this.screenBitmap.dispose()
    }

    __Init()
    {
        classLoaded("_Timer", _Timer)
        classLoaded("_BitmapImage", _BitmapImage)
        _Validation.empty("TibiaClientID", TibiaClientID)
        _Validation.empty("_WindowArea", _WindowArea)
        return

        WinGetPos,,, w, h, ahk_id %TibiaClientID%
        c := new _Coordinates()

        c.setX1(0)
        c.setY1(0)
        c.setX2(w)
        c.setY2(h)
        elapses := {}

        loop, 5 {
            timer := new _Timer()

            loop, 1000 {
                bitmap := this.getClientBitmap()
                ; bitmap := this.Gdip_BitmapFromHWND(TibiaClientID, 0, 0, w, h)
                ; bitmap := this.getClientBitmap()
                ; m(Gdip_SetBitmapToClipboard(bitmap))
                ; Gdip_DisposeImage(bitmap), DeleteObject(bitmap)
                this.disposeBitmap(bitmap)
            }

            ; m("elapsed", timer.elapsed())
            elapses.push(timer.elapsed())
        }
        m(elapses)

    }

    /**
    * @param ?_Coordinates|_AbstractClientArea coords
    * @param ?string identifier
    * @return _BitmapImage
    * @throws
    */
    getBitmap(coords := "", identifier := "")
    {
        if (!coords) {
            coords := new _WindowArea().getCoordinates()
        } else {
            if (instanceOf(coords, _AbstractClientArea)) {
                coords := coords.getCoordinates()
            }
        }

        this.guardAgainstInvalidCoordinates(coords)

        try {
            ; _Logger.log(A_ThisFunc, identifier)
            return new _BitmapImage(this.Gdip_BitmapFromHWND2(TibiaClientID, coords.getX1(), coords.getY1(), coords.getW(), coords.getH()))
                .setIdentifier(identifier)
            return this.screenBitmap
        } catch e {
            _Logger.exception(e, A_ThisFunc ".Gdip_BitmapFromHWND2", identifier)
            throw e
        }
    }

    /**
    * @param _Coordinates coords
    * @return _BitmapImage
    * @throws
    */
    getClientBitmap(coords := "", identifier := "")
    {
        this.screenBitmap.dispose(), this.screenBitmap := ""

        try {
            this.screenBitmap := this.getBitmap(coords, identifier)
            return this.screenBitmap
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            throw e
        }
    }

    guardAgainstInvalidCoordinates(coords)
    {
        _Validation.instanceOf("coords", coords, _Coordinates)

        if (coords.getX2() = 0 || coords.getX2() > WindowWidth) {
            coords.setX2(WindowWidth)
        }

        if (coords.getY2() = 0 || coords.getY1() > WindowHeight) {
            coords.setY2(WindowHeight)
        }

        if (coords.getX2() <= coords.getX1()) {
            throw Exception("Invalid X coordinates, x1: " coords.getX1() ", x2: " coords.getX2())
        }

        if (coords.getY2() <= coords.getY1()) {
            throw Exception("Invalid Y coordinates, y1: " coords.getY1() ", y2: " coords.getY2())
        }
    }

    /**
    * @param int bitmap
    * @return bool
    * @throws
    */
    isValidBitmap(bitmap)
    {
        try {
            Gdip_GetPixel(bitmap, 1, 1, A_ThisFunc)
        } catch e {
            throw e
        }

        return true
    }

    /**
    * @param int bitmap
    * @return void
    */
    disposeBitmap(bitmap := "")
    {
        if (bitmap = "") {
            return
        }

        Gdip_DisposeImage(bitmap), DeleteObject(bitmap), bitmap := ""
    }

    /**
    * @param int hBitmap
    * @return void
    */
    disposeHBitmap(hBitmap := "")
    {
        if (hBitmap == "") {
            return
        }

        DeleteObject(hBitmap), hBitmap := ""
    }

    Gdip_BitmapFromHWND2(hwnd, x, y, w, h)
    {
        VarSetCapacity(bi, 40, 0)                ; sizeof(bi) = 40
            , NumPut(       40, bi,  0,   "uint") ; Size
            , NumPut( w, bi,  4,   "uint") ; Width
            , NumPut(-h, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
            , NumPut(        1, bi, 12, "ushort") ; Planes
            , NumPut(       32, bi, 14, "ushort") ; BitCount / BitsPerPixel

        ; Retrieve the device context for the screen.
        sdc := DllCall("GetWindowDC", "ptr", hwnd, "ptr")
            , hdc := DllCall("CreateCompatibleDC", "ptr", sdc, "UPtr")
            , hBitmap := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", 0, "ptr", 0, "uint", 0, "ptr")
            , obm := DllCall("SelectObject", "ptr", hdc, "ptr", hBitmap, "ptr")

        ; Copies a portion of the screen to a new device context.
        DllCall("gdi32\BitBlt"
            , "ptr", hdc, "int", 0, "int", 0, "int", w, "int", h
            , "ptr", sdc, "int", x, "int", y, "uint", 0x00CC0020) ; SRCCOPY

        ; Convert the hBitmap to a Bitmap using a built in function as there is no transparency.
        DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", hBitmap, "ptr", 0, "ptr*", pBitmap)
            , ReleaseDC(sdc, hwnd)
            , SelectObject(hdc, obm)
            , DeleteObject(hBitmap)
            , DeleteDC(hdc)

        return pBitmap
    }
}