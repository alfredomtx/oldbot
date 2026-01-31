#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\libraries\TT.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\Traits\HasGuiOptions.ahk

/**
* @property bool enableAfterEvent
* @property array iconData
*/
class _AbstractControl extends _GuiControlOptions
{
    static DEFAULT_GUI := "CavebotGUI"
    static LAST_ADDED := ""
    static ICONS := {}

    __Init()
    {
        static initialized
        if (initialized) {
            return
        }

        initialized := true

        global TT:=TT("Icon=1 MAXWIDTH=300 AUTOPOP=20 NoFade ")
        ; TT := TT("Balloon NoFade NoAnimate NoPrefix AlwaysTip Icon=1","TT ToolTip Text","TT ToolTip Title") ;create a ToolTip
        TT.SetDelayTime(3,0) ; delay initial ToolTip
    }

    __New(type)
    {
        this.type := type
        this._gui := this.DEFAULT_GUI

        this._tt := ""
        this._x := ""
        this._y := ""
        this._title := ""
        this._rule := ""
        this._placeholder := ""
        this._parent := ""
        this.iconData := ""

        this._styles := {}
        this._options := {}

        this.created := false
    }

    SET_DEFAULT_GUI_NAME(name)
    {
        this.DEFAULT_GUI := name
    }

    SET_DEFAULT_GUI(gui)
    {
        this.DEFAULT_GUI := gui.getId()
        this._guiClass := gui
    }

    RESET_DEFAULT_GUI()
    {
        this.DEFAULT_GUI := "CavebotGUI"
        this._gui := ""
        this._guiClass := ""
    }

    /**
    * @return this
    */
    add()
    {
        global
        local controlHwnd

        if (!this.handleGuiClass()){
            return this
        }

        this.resolveControlName()

        this.applyFontStyles()

        try {
            opt :=this._positionAndSize() " " this._variables() " " this.getOptions()
            Gui, % this.guiPrefix() "Add", % this.type, % opt " +HwndOutputVar", % this._title
            this.created := true
            _AbstractControl.LAST_ADDED := this
        } catch e {
            this.msgboxException(e, A_ThisFunc)
        }

        ; this._hwnd := this.getHwnd()
        this._hwnd := OutputVar


        if (this._styles.Count()) {
            Gui, % this.guiPrefix() "Font",
        }

        this.addTooltip()

        this.addPlaceholder()

        if (this._value) {
            this.setWithoutEvent(this._value)
        }

        this.addCallback()

        if (this.iconData) {
            this.addIcon(this.iconData, this.iconData.options)
        }

        return this
    }

    applyFontStyles()
    {
        if (!this._styles.Count()) {
            return
        }

        styles := this._styles.Clone()
        stylesString := ""
        if (this._styles.color) {
            stylesString .= "c" this._styles.color " "
            styles.Delete("color")
        }

        stylesString .= _Arr.concat(_Arr.keys(styles), " ")

        Gui, % this.guiPrefix() "Font", % stylesString
    }

    handleGuiClass()
    {
        if (!this._guiClass) {
            return true
        }

        this._guiClass.addControl(this)

        return true
    }


    /**
    * @return void
    */
    addTooltip()
    {
        global TT
        if (!this._tt) {
            return
        }

        TT.Add(this._hwnd, this._tt)
    }

    /**
    * @return void
    */
    addPlaceholder()
    {
        if (!this._placeholder) {
            return
        }

        this.setEditCueBanner(this._hwnd, this._placeholder)
    }

    /**
    * @return int
    */
    getHwnd()
    {
        return this._hwnd
        GuiControlGet, controlHwnd, % this.guiPrefix() "Hwnd", % this.getControlID()
        return controlHwnd
    }

    /**
    * @return ?_AbstractControl
    */
    getLastAdded()
    {
        return _AbstractControl.LAST_ADDED
    }

    /**
    * @return void
    */
    resolveControlName()
    {
        if (!this._name) {

            if (instanceOf(this, _Radio)) {
                return
            }
            /*
            TODO: use hwnd when there is no control
            */
            this._control := this._gui "_" this.randomId()
        } else  {
            this._control := this.getControlID()
        }
    }

    /**
    * @return string
    */
    randomId()
    {
        return A_TickCount "" random(1, 9999999) "" random(1, 9999999)
    }

    /**
    * @abstract
    * @param int CtrlHwnd
    * @param string GuiEvent
    * @param int EventInfo
    * @param ?int ErrLevel
    * @return void
    */
    onEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        abstractMethod()
    }

    /**
    * @param int CtrlHwnd
    * @param string GuiEvent
    * @param int EventInfo
    * @param ?int ErrLevel
    * @return void
    * @throws
    */
    handleEventFunction(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        if (this.handleGosubEvent()) {
            return
        }

        this.handleFunctionAndCallback(this._event, this, this.get(), CtrlHwnd, GuiEvent, EventInfo, ErrLevel)
    }

    /**
    * @param BoundFunc function
    * @param mixed params*
    * @return void
    * @throws
    */
    handleFunctionAndCallback(function, params*)
    {
        if (!function || !isFunction(function)) {
            return
        }

        callback := "", e := ""
        try {
            callback := %function%(params*)
        } catch e {
            _Logger.exception(e, A_ThisFunc, this.getControlID())
        }

        this.handleCallback(callback)

        if (e) {
            throw e
        }
    }

    /**
    * @return true
    * @throws
    */
    handleGosubEvent()
    {
        if (!this._event || IsObject(this._event)) {
            return false
        }

        try {
            label := this._event
            gosub, %label%
        } catch e {
            _Logger.exception(e, A_ThisFunc, "Gosub: " this._event " | " this.getControlID())
            throw e
        }

        return true
    }

    /**
    * @param function callback
    * @param mixed params
    * @return void
    * @throws
    */
    handleCallback(callback, params := "")
    {
        if (!callback) {
            return
        }

        if (!IsFunction(callback)) {
            return
        }

        try {
            %callback%(params ? params : "")
        } catch e {
            _Logger.exception(e, A_ThisFunc, this.getControlID())
            throw e
        }
    }

    /**
    * @return int
    */
    getX()
    {
        return this._x
    }

    /**
    * @return int
    */
    getY()
    {
        return this._y
    }

    /**
    * @return int
    */
    getW()
    {
        return this._w
    }

    /**
    * @return int
    */
    getH()
    {
        return this._h
    }

    /**
    * @return int
    */
    getR()
    {
        return this._r
    }

    /**
    * @return int
    */
    getGuiX()
    {
        return this.controlGetPos().x
    }

    /**
    * @return int
    */
    getGuiY()
    {
        return this.controlGetPos().y
    }

    controlGetPos()
    {
        ControlGetPos, x, y, w, h,, % "ahk_id " this.getHwnd()
        return {x: x, y: y, w: w, h: h}
    }

    /**
    * @param array<bool|"Disabled"> values
    * @return this
    */
    disabled(values*)
    {
        empty := true
        for _, value in values {
            empty := false
            if (value = "Disabled" || value == true) {
                return this.option("Disabled")
            }
        }

        if (empty)  {
            return this.option("Disabled")
        }

        return this
    }

    /**
    * @param array<bool|"Hidden"> values
    * @return this
    */
    hidden(values*)
    {
        for _, value in values {
            if (value = "Hidden" || value == true) {
                this.option("Hidden")
                return this
            }
        }

        return this
    }

    /**
    * @return void
    */
    addCallback()
    {
        if (this.type = _Groupbox.CONTROL || this.type = _Progress.CONTROL) {
            return
        }

        try {
            this.ensureControlExists(A_ThisFunc)
        } catch e {
            _Logger.msgboxExceptionOnLocal(e, this.getName(), A_ThisFunc)
            return
        }

        fn := this.onEvent.bind(this)
        try  {
            GuiControl, % this.guiPrefix() "+g", % this.getHwnd(), % fn
        } catch e {
            _Logger.msgboxExceptionOnLocal(e, this.type " | " this.getHwnd(), A_ThisFunc)
        }
    }

    /**
    * @return void
    */
    removeCallback()
    {
        this.change("-g")
    }

    _size()
    {
        return (this._w ? " w" this._w : "") (this._h ? " h" this._h : "") (this._r ? " r" this._r : "")
    }

    /**
    * @return string
    */
    _positionAndSize()
    {
        return (this._x ? " x" this._x : "") " " (this._y ? " y" this._y "" : "") " " this._size()
    }

    /**
    * @return ?string
    */
    _variables()
    {
        if (!this._control) {
            return
        }

        return "v" this._control " hwnd" this._control
    }

    /**
    * @return void
    */
    setDefaultGui()
    {
        Gui, % this.guiPrefix() "Default"
    }

    /**
    * @return mixed
    * @throws
    */
    get(property := "")
    {
        if (!empty(property)) {
            this.has(property)

            return this["_" property]
        }

        try {
            GuiControlGet, value, % this.guiPrefix(), % this.getHwnd()
        } catch e {
            this.msgboxExceptionOnLocal(e, A_ThisFunc)
        }

        return value
    }

    /**
    * @throws
    */
    ensureControlExists(from := "")
    {
        if (this.exists()) {
            return
        }

        throw Exception("Performing action on control that has not been created:`n- name: " this.getName() "`n- id:" this.getControlID() "`n- from: " from)
    }

    /**
    * @throws
    */
    ensureControlHasName(from := "")
    {
        if (this._name) {
            return
        }

        throw Exception("Control does not have a ""name"": " this.getControlID() ", from: " from)
    }

    /**
    * @return this
    * @throws
    */
    setWithoutEvent(value)
    {
        this.removeCallback()

        try {
            GuiControl, % this.guiPrefix(), % this.getHwnd(), % value
        } catch e {
            throw Exception("Failed to set value to control: """ value """", this.getControlID())
        } finally {
            this.addCallback()
        }
    }

    /**
    * @return this
    * @throws
    */
    set(value)
    {
        try {
            this.ensureControlExists(A_ThisFunc)
        } catch e {
            _Logger.msgboxExceptionOnLocal(e, this.getName(), A_ThisFunc)
            return
        }

        try  {
            GuiControl, % this.guiPrefix(), % this.getControlID(), % value
        } catch e {
            throw Exception("Failed to set value to control: """ value """", this.getControlID())
        }

        return this
    }

    /**
    * @return string
    */
    getControlID()
    {
        return this._name ? this.getNameWithPrefix() : this._control
    }

    /**
    * @return string
    */
    getNameWithPrefix()
    {
        return this.getControlNamePrefix() "" this._name
    }

    /**
    * @return string
    */
    getControlNamePrefix()
    {
        prefix := this.getPrefix()
        return  prefix ? prefix "__" : ""
    }

    /**
    * @return ?string
    */
    getPrefix()
    {
        return this._prefix
    }

    /**
    * @return string
    */
    getName()
    {
        return StrReplace(this.getControlID(), this.getControlNamePrefix(), "")
    }

    /**
    * @return string
    */
    getTitle()
    {
        return this._title
    }

    /**
    * @return string
    */
    getTooltip()
    {
        return this._tt
    }

    /**
    * @return string
    */
    guiPrefix()
    {
        return this._gui ":"
    }

    /**
    * @param exception e
    * @param string origin
    * @return void
    */
    msgboxException(e, origin)
    {
        _Logger.msgboxException(48, e, origin, this.getControlID())
        return
        ; }

        msgbox, 48, % origin, % e.Message "`n- What: " e.What "`n- Extra: " e.Extra "`n- File: " e.File "`n- Line: " e.Line
    }

    /**
    * @param exception e
    * @param ?string extra
    * @return void
    */
    msgboxExceptionOnLocal(e, extra := "")
    {
        _Logger.exception(e, A_ThisFunc, this.getControlID() (extra ? " | " extra : ""))
        if (!A_IsCompiled) {
            msgbox, 48, % A_ThisFunc, % e.Message "`n" extra
        }
    }

    setEditCueBanner(HWND, Cue)
    {
        Static EM_SETCUEBANNER := (0x1500 + 1)

        return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
    }

    /**
    * @param object iconData
    * @param string options
    * @return this
    */
    icon(iconData, options := "s14")
    {
        this.iconData := {}
        this.iconData.options := options

        if (instanceOf(iconData, _BitmapIcon)) {
            this.iconData.dllName := iconData
        } else if (instanceOf(iconData, _Icon)) {
            this.iconData.dllName := iconData.dllName
            this.iconData.iconNumber := iconData.number

            if (!InStr(iconData.dllName, ".dll")) {
                try {
                    _Validation.fileExists("iconData.dllName", iconData.dllName)
                } catch e {
                    throw Exception("Icon file does not exist: " iconData.dllName)
                }
            }
        }

        if (this.isCreated()) {
            this.addIcon(this.iconData, this.iconData.options)
        }

        return this
    }

    /**
    * @param object iconData
    * @param string options
    * @return void
    */
    addIcon(iconData, options)
    {
        if (instanceOf(iconData, _BitmapIcon)) {
            this.handleIcon(this.resolveIconKey(), this.getHwnd(), iconData, 0, options)
        } else {
            this.handleIcon(this.resolveIconKey(), this.getHwnd(), iconData.dllName, iconData.iconNumber, options)
        }
    }

    /**
    * @return string
    * @throws
    */
    resolveIconKey()
    {
        name := this.getName()
        prefix := this.getPrefix()

        if (name && prefix) {
            return prefix "" name
        }

        if (!prefix) {
            if (this._guiClass) {
                prefix := this._guiClass.getName()
            } else {
                prefix := this._gui
            }
        }

        if (name && prefix) {
            return prefix "_" name
        }

        if (!isFunction(this._event)) {
            return prefix ? prefix "" this._event : this._event
        }

        title := this.getTitle()
        if (title) {
            return StrReplace(title, " ", "")
        }

        throw Exception("Could not resolve icon key for control: " this.getControlID())
    }

    /**
    * @param string ID
    * @param int hwnd
    * @param string file
    * @param int index
    * @param ?string options
    * @return void
    */
    handleIcon(ID, hwnd, file, index := 1, options := "")
    {
        this.destroyIcon()

        RegExMatch(options, "i)w\K\d+", W), (W="") ? W := 16 :
        RegExMatch(options, "i)h\K\d+", H), (H="") ? H := 16 :
        RegExMatch(options, "i)s\K\d+", S), S ? W := H := S :
        RegExMatch(options, "i)l\K\d+", L), (L="") ? L := 0 :
        RegExMatch(options, "i)t\K\d+", T), (T="") ? T := 0 :
        RegExMatch(options, "i)r\K\d+", R), (R="") ? R := 0 :
        RegExMatch(options, "i)b\K\d+", B), (B="") ? B := 0 :
        RegExMatch(options, "i)a\K\d+", A), (A="") ? A := 4 :
        Psz := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"
        VarSetCapacity( button_il, 20 + Psz, 0 )
        NumPut( _AbstractControl.ICONS["" ID ""] := DllCall( "ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1 ), button_il, 0, Ptr ) ; Width & Height
        NumPut( L, button_il, 0 + Psz, DW ) ; Left Margin
        NumPut( T, button_il, 4 + Psz, DW ) ; Top Margin
        NumPut( R, button_il, 8 + Psz, DW ) ; Right Margin
        NumPut( B, button_il, 12 + Psz, DW ) ; Bottom Margin
        NumPut( A, button_il, 16 + Psz, DW ) ; Alignment
        SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %hwnd%

        try {
            if (instanceOf(file, _BitmapIcon)) {
                IL_Add( _AbstractControl.ICONS["" ID ""], "HBITMAP:" file.getBitmap().getHBitmap(), 0xFFFFFF, 1) ; 0xFFFFFF to use with imanges insted of icons
            } else {
                IL_Add( _AbstractControl.ICONS["" ID ""], file, index )
            }
        } catch e {
            throw e
        }
    }

    destroyIcon()
    {
        ID := this.resolveIconKey()

        if (_AbstractControl.ICONS["" ID ""]) {
            IL_Destroy(_AbstractControl.ICONS["" ID ""])
            _AbstractControl.ICONS["" ID ""] := ""
        }

        return this

    }
}

class _GuiControlOptions extends _GuiControlStates
{
    /**
    * @param string action
    * @return this
    */
    change(action)
    {
        try {
            this.ensureControlExists(A_ThisFunc)
        } catch e {
            /**
            * TODO: throw exception
            */
            _Logger.exception(e, this.getName(), A_ThisFunc)
            ; _Logger.msgboxExceptionOnLocal(e, this.getName(), A_ThisFunc)
            return
        }

        try  {
            try {
                GuiControl, % this.guiPrefix() "" action, % this.getHwnd()
            } catch e {
                throw Exception("Failed to change control, action: """ action """", this.getHwnd())
            }

            switch action {
                case "Enable": this._options["Disabled"] := false
                case "Show": this._options["Hidden"] := false

                case "Disable": this._options["Disabled"] := true
                case "Hide": this._options["Hidden"] := true
            }
        } catch e {
            ; _Logger.exception(e, A_ThisFunc ", action: " action, this.getControlID())
            this.msgboxExceptionOnLocal(e, action)
        }

        return this
    }

    /**
    * @return this
    */
    disable()
    {
        return this.change("Disable")
    }

    /**
    * @return this
    */
    enable()
    {
        return this.change("Enable")
    }

    /**
    * @return this
    */
    show()
    {
        return this.change("Show")
    }

    /**
    * @return this
    */
    hide()
    {
        return this.change("Hide")
    }

    /**
    * @return this
    */
    center()
    {
        return this.option("Center")
    }

    /**
    * @return this
    */
    section()
    {
        return this.option("Section")
    }

    /**
    * @return this
    */
    focus()
    {
        return this.change("Focus")
    }

    unfocus()
    {
        SendMessage, 0x000E, 0, 0,, % "ahk_id " this.getHwnd() ;WM_GETTEXTLENGTH
        SendMessage, 0x00B1, ErrorLevel, ErrorLevel,, % "ahk_id " this.getHwnd() ;EM_SETSEL

        return this
    }

    /**
    * @return this
    */
    focused()
    {
        return this.option("0x1")
    }

    /**
    * @param int value
    * @return this
    */
    limit(value)
    {
        _Validation.number("value", value)

        return this.option("Limit", value)
    }

    /**
    * @param int min
    * @param int max
    * @return this
    */
    range(min, max)
    {
        _Validation.number("min", min)
        _Validation.number("max", max)

        return this.option("Range" min "-" max)
    }

    /**
    * @param int value
    * @return this
    */
    tickInterval(value)
    {
        _Validation.number("value", value)

        return this.option("TickInterval" value)
    }

    /**
    * @param string value
    * @return this
    */
    chooseString(value)
    {
        try {
            GuiControl, % this.guiPrefix() "ChooseString", % this.getControlID(), % value
        } catch e {
            throw Exception("Failed to choose string: """ value """", this.getControlID())
        }

        return this
    }

    getParent()
    {
        return this._parent
    }

    /**
    * @param ?_AbstractControl control
    * @return this
    */
    parent(control := "")
    {
        control := control ? control : _Text.LAST
        _Validation.instanceOf("control", control, _AbstractControl)
        this._parent := control

        if (empty(this.getTooltip())) {
            tooltip := this._parent.getTooltip()

            if (tooltip) {
                this.tt(tooltip)
            }
        }

        if (empty(this.getY())) {
            this.yp(-3)
        }

        return this
    }

    resetTooltip()
    {
        this._tt := ""

        return this
    }
}

class _GuiControlStates extends _GuiControlAttributes
{

    /**
    * @return bool
    */
    isCreated()
    {
        return this.created ? true : false
    }

    /**
    * @return bool
    */
    isDisabled()
    {
        return this._options["Disabled"] ? true : false
    }

    /**
    * @return bool
    */
    isHidden()
    {
        return this._options["Hidden"] ? true : false
    }
}

class _GuiControlAttributes extends HasPredicates_AbstractControl
{
    /**
    * @return this
    */
    gui(name)
    {
        this._gui := name
        return this
    }

    /**
    * @return this
    */
    x(x := "+5")
    {
        this._x := x
        return this
    }

    /**
    * @return this
    */
    y(y := "+5")
    {
        this._y := y
        return this
    }

    /**
    * @return this
    */
    xp(value := "")
    {
        if (value) {
            _Validation.number("value", value)
        }

        this._x := "p" value
        return this
    }

    /**
    * @return this
    */
    yp(value := "")
    {
        if (value) {
            _Validation.number("value", value)
        }

        this._y := "p" value
        return this
    }

    /**
    * @return this
    */
    xm(value := "")
    {
        if (value) {
            _Validation.number("value", value)
        }

        this._x := "m" value
        return this
    }

    /**
    * @return this
    */
    ym(value := "")
    {
        if (value) {
            _Validation.number("value", value)
        }

        this._y := "m" value
        return this
    }

    /**
    * @return this
    */
    xs(value := "")
    {
        if (value) {
            _Validation.number("value", value)
        }

        this._x := "s" value
        return this
    }

    /**
    * @return this
    */
    ys(value := "")
    {
        if (value) {
            _Validation.number("value", value)
        }

        this._y := "s" value
        return this
    }

    /**
    * @return this
    */
    xadd(value := 5)
    {
        if (value) {
            _Validation.number("value", value)
        }

        this._x := "+" value
        return this
    }

    /**
    * @return this
    */
    yadd(value := 5)
    {
        if (value) {
            _Validation.number("value", value)
        }

        this._y := "+" value
        return this
    }

    /**
    * @return this
    */
    xsub(value := 5)
    {
        if (value) {
            _Validation.number("value", value)
        }

        this._x := "-" value
        return this
    }

    /**
    * @return this
    */
    ysub(value := 5)
    {
        if (value) {
            _Validation.number("value", value)
        }

        this._y := "-" value
        return this
    }

    /**
    * @return this
    */
    xlast(value := 5)
    {
        this._x := _AbstractControl.getLastAdded().getGuiY() + value
        return this
    }

    /**
    * @return this
    */
    ylast(value := 5)
    {
        this._y := _AbstractControl.getLastAdded().getGuiY() + value
        return this
    }

    /**
    * @return this
    */
    size(value)
    {
        this.w(value)
        this.h(value)
        return this
    }

    /**
    * @return this
    */
    w(w)
    {
        this._w := w
        return this
    }

    /**
    * @return this
    */
    h(h)
    {
        this._h := h
        return this
    }

    /**
    * @return this
    */
    r(r)
    {
        this._r := r
        return this
    }

    /**
    * @param string text
    * @param ?string translation
    * @param ?string extra
    * @return this
    */
    tt(text, translation := "", extra := "")
    {
        if (this._tt) {
            this._tt .= "`n" (translation ? txt(text, translation) : text)
        } else {
            this._tt := translation ? txt(text, translation) : text
        }

        this._tt .= extra

        if (this.isCreated()) {
            this.addTooltip()
        }

        return this
    }

    /**
    * @param string text
    * @param ?string translation
    * @param ?string extra
    * @return this
    */
    title(text, translation := "", extra := "")
    {
        if (translation) {
            this._title := txt(text, translation) extra
        } else {
            this._title := text
        }

        return this
    }

    /**
    * @param string color
    * @return this
    */
    color(color)
    {
        this._styles.color := color
        return this
    }

    /**
    * @param string color
    * @return this
    */
    font(style)
    {
        this._styles[style] := true
        return this
    }

    /**
    * @param string name
    * @return this
    */
    name(name)
    {
        this._name := name
        return this
    }

    /**
    * @param string name
    * @return this
    */
    prefix(name)
    {
        this._prefix := name
        return this
    }

    /**
    * @param string|function value
    * @return this
    */
    event(value)
    {
        _Validation.empty(A_ThisFunc ".value", value)
        this._event := value
        return this
    }

    /**
    * @param string|function|array callback
    * @return this
    */
    afterSubmit(callback)
    {
        _Validation.empty("callback", callback)
        if (this._afterSubmit) {
            if (!_A.isArray(this._afterSubmit)) {
                this._afterSubmit := [this._afterSubmit]
            }

            this._afterSubmit.Push(callback)
            return this
        }

        this._afterSubmit := callback
        return this
    }

    /**
    * @return this
    */
    value(value)
    {
        this._value := value
        return this
    }

    /**
    * @param _ControlRule rule
    * @return this
    */
    rule(rule)
    {
        _Validation.instanceOf("rule", rule, _ControlRule)
        this._rule := rule
        return this
    }

    /**
    * @return ?_ControlRule
    */
    getRule()
    {
        return this._rule
    }

    /**
    * @return
    */
    validation(validation)
    {
        this._validation := validation
        return this
    }

    /**
    * @param string text
    * @param ?string translation
    * @return this
    */
    placeholder(text, translation := "")
    {
        if (translation) {
            this._placeholder := txt(text, translation)
        } else {
            this._placeholder := text
        }

        if (this.isCreated()) {
            this.addPlaceholder()
        }

        return this
    }
}

class HasPredicates_AbstractControl extends HasGuiOptions
{
    has(property)
    {
        key := "_" property
        if (!this.HasKey(key)) {
            throw Exception("Invalid property: """ key """" )
        }

        return this[key] ? true : false
    }

    exists()
    {
        try {
            GuiControlGet, controlHwnd, hwnd, % this.getHwnd()
            return controlHwnd ? true : false
        } catch {
            return false
        }
    }

    isGosubEvent()
    {
        return this._event && !isFunction(this._event)
    }
}
