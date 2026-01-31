class _Magnifier extends _BaseClass
{
    static CHECKBOX
    static CHECKBOX_NAME := "magnifierEnabled"

    static DELAY := 50
    static ANTIALIZE := 1
    static TOOLBAR := 0

    static TRANSPARENCY_MIN := 125
    static TRANSPARENCY_MAX := 254

    static WIDTH_MIN := 30
    static WIDTH_MAX := 178
    static HEIGHT_MIN := 34
    static HEIGHT_MAX := 74
    static ZOOM_MIN := 0.5
    static ZOOM_MAX := 1

    static hdd_frame := ""
    static hdc_frame := ""
    static hdc_buffer := ""
    static hbm_buffer := ""
    static PrintScreenID := ""

    static ID := ""

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    createGui()
    {
        ; global 
        global magnifierGuiX, magnifierGuiY
        this.disable()

        this.readSettings()
        this.ID := A_Now + random(1, 10000)

        width := this.getSetting("width")
        height := this.getSetting("height")

        guiName := "MagnifierGUI" + this.ID
        ; Gui, %guiName%:Destroy
        ; Gui, %guiName%: +HwndMagnifierGUIHwnd 
        Gui, %guiName%:+AlwaysOnTop +Owner -Border +E0x20

        Gui, %guiName%: Show, % "NoActivate w" width " h" height " x" magnifierGuiX " y" magnifierGuiY, PrintScreen
        Sleep, 50

        WinGet, PrintScreenID, id, PrintScreen
        this.PrintScreenID := PrintScreenID
        PrintScreenID := ""
        this.setTransparency()

        ;retrieve the unique ID number (HWND/handle) of that window
        WinGet, PrintSourceID, id 

        this.hdd_frame := GetDC()
        this.hdc_frame := GetDC(this.PrintScreenID)

        this.hdc_buffer := CreateCompatibleDC(this.hdc_frame)
        this.hbm_buffer := CreateCompatibleBitmap(this.hdc_frame, width, height)


        this.repaint()
        SetTimer, Repaint, Delete
        SetTimer, Repaint, % this.DELAY, -99
    }

    repaint()
    {
        global magnifierX, magnifierY
        WinGetPos, wx, wy, ww, wh , % "ahk_id " this.PrintScreenID

        wh2 := wh - this.TOOLBAR
        zoom := this.getSetting("zoom")

        SetStretchBltMode(this.hdc_frame, 4 * this.ANTIALIZE)

        StretchBlt(this.hdc_frame, 0, this.TOOLBAr, ww, wh - this.TOOLBAR, this.hdd_frame, magnifierX-(ww / 2 / zoom), magnifierY -( wh2 / 2/zoom), ww / zoom, wh2 / zoom, 0xCC0020) ; SRCCOPY

        ; DllCall("gdi32.dll\StretchBlt", UInt,this.hdc_frame, Int,0, Int,this.TOOLBAR, Int,ww, Int,wh - this.TOOLBAR
        ;     , UInt,this.hdd_frame, Int
        ;     , magnifierX-(ww / 2 / zoom)
        ;     , Int,magnifierY -( wh2 / 2/zoom), Int,ww / zoom, Int,wh2 / zoom ,UInt,0xCC0020) ; SRCCOPY
    }

    handleExit()
    {
        global
        DeleteObject(this.hbm_buffer)
        DeleteDC(this.hdc_frame )
        DeleteDC(this.hdd_frame )
        DeleteDC(this.hdc_buffer)
        this.hdd_frame := ""
        this.hdc_frame := ""
        this.hdc_buffer := ""
        this.hbm_buffer := ""
        this.PrintScreenID := ""
    }

    /**
    * @param _Checkbox checkbox
    * @param mixed value
    * @return void
    */
    toggle(checkbox, value)
    {
        if (value = 0) {
            this.disable()
            return
        } 

        this.createGui()
    }

    disable()
    {
        ; global 
        SetTimer, Repaint, Delete
        Sleep, % this.DELAY
        this.handleExit()
        guiName := "MagnifierGUI" + this.ID
        Gui, %guiName%:Destroy
        WinClose, PrintScreen
    }

    setTransparency()
    {
        WinSet, Transparent , % this.getSetting("transparency"), PrintScreen
    }

    /**
    * @param string name
    * @return mixed
    */
    getSetting(name)
    {
        static class
        if (!class) {
            class := new _SupportSettings()
        }

        return class.get(name, "magnifier")
    }

    readSettings()
    {
        global

        IniRead, magnifierGuiX, %DefaultProfile%, magnifier, magnifierGuiX, % A_ScreenWidth / 2
        IniRead, magnifierGuiY, %DefaultProfile%, magnifier, magnifierGuiY, % A_ScreenHeight / 2

        IniRead, magnifierX, %DefaultProfile%, magnifier, magnifierX, % 0
        IniRead, magnifierY, %DefaultProfile%, magnifier, magnifierY, % 0
        IniRead, magnifierTransparence, %DefaultProfile%, magnifier, transparency, % 254
    }

    setPosition()
    {
        global
        CoordMode, Mouse, Screen                
        MouseGetPos, magnifierX, magnifierY             ;  position of mouse
        magnifierX += 20
        magnifierY += 18

        IniWrite, %magnifierX%, %DefaultProfile%, magnifier, magnifierX
        IniWrite, %magnifierY%, %DefaultProfile%, magnifier, magnifierY
    }

    setGuiPosition()
    {
        global
        CoordMode, Mouse, Screen                
        MouseGetPos, magnifierGuiX, magnifierGuiY
        IniWrite, %magnifierGuiX%, %DefaultProfile%, magnifier, magnifierGuiX
        IniWrite, %magnifierGuiY%, %DefaultProfile%, magnifier, magnifierGuiY

        WinMove, % "ahk_id " this.PrintScreenID,, magnifierGuiX, magnifierGuiY
    }

    applySetting(control, value)
    {
        if (!_Magnifier.CHECKBOX.get()) {
            return
        }

        this.createGui()
    }
}