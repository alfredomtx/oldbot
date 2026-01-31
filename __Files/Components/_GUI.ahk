#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\Traits\HasGuiOptions.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IComponents.ahk

/**
* @property ?int _x
* @property ?int _y
* @property ?int _w
* @property ?int _h
* 
* @property ?string _name
* @property ?string _title
* 
* CALLBACKS
* @property BoundFunc _create 
* @property BoundFunc _afterCreate 
* @property BoundFunc _onClose 
* 
*/
class _GUI extends _BaseClass
{
    static INSTANCES := {}
    static INSTANCES_BY_NAME := {}
    static INI_SECTION := "gui_windows"

    __Init()
    {
        static validated
        if (validated) {
            return
        }

        validated := true

        classLoaded("_DefaultValue", _DefaultValue)
        classLoaded("_Logger", _Logger)
        classLoaded("HasGuiOptions", HasGuiOptions)
    }

    __New(name := "", title := "")
    {
        if (name && _GUI.INSTANCES_BY_NAME.HasKey(name)) {
            instance := _GUI.INSTANCES_BY_NAME[name]
            instance.close()

            ; throw Exception("GUI with name """ name """ already exists")
        }

        this._created := false
        this._name := name
        this._title := title

        this.controls := {}
        this._options := {}
    }

    /**
    * @abstract
    * @return this
    */
    open(close := true)
    {
        ; try {
        this.handleCallback(this._onCreateValidations, "onCreateValidations")
        ; } catch e {
        ;     _Logger.msgboxException(16, e, this.getId())
        ;     return
        ; }

        if (close) { ; can't for filtering
            this.close()
        }

        Gui, New, +HwndGuiHwnd 
        this._id := GuiHwnd

        this.gui("Default")

        if (this._ownDiaglogs){
            Gui +OwnDialogs
        }

        if (this._options.Count()) {
            Gui, % this.getOptions()
        }

        this.minSize()
        this.maxSize()

        try {
            this.handleCallback(this._create, "create")
        } catch e {
            _Logger.msgboxException(16, e, this.getId())
            return this
        }


        this._created := true
        ; Gui +LastFound +0x80000  ; Add WS_SYSMENU style (0x80000) to remove maximize button

        guiOptions := this.getGuiOptions() 
        Gui, % "Show", % guiOptions " " this._noActivate " ", % this._title

        try {
            this.afterGuiShow()
        } catch e {
            _Logger.msgboxException(16, e, this.getId())
            return this
        }

        return this
    }

    /**
    * @return void
    */
    maxSize()
    {
        width := ""
        if (this._maxWidth) {
            width := this._maxWidth
        }

        height := ""
        if (this._maxHeight) {
            height := this._maxHeight
        }

        if (width || height) {
            this.gui("+Resize +MaxSize" width "x" height)
        }
    }

    /**
    * @return void
    */
    minSize()
    {
        width := ""
        if (this._MinWidth) {
            width := this._MinWidth
        }

        height := ""
        if (this._MinHeight) {
            height := this._MinHeight
        }

        if (width || height) {
            this.gui("+Resize +MinSize" width "x" height)
        }
    }

    ownDialogs()
    {
        this._ownDiaglogs := true

        return this
    }

    show(title := "")
    {
        if (!title) {
            this.gui("Show")
            return this
        }

        Gui, % this.guiPrefix() "Show" ,, % title
    }

    hide()
    {
        this.gui("hide")
    }

    afterGuiShow()
    {
        _GUI.INSTANCES[this.getId()] := this
        name := this.getName()
        _GUI.INSTANCES_BY_NAME[this.getName()] := this

        this.handleCallback(this._afterCreate, "afterCreate")
    }

    /**
    * @abstract
    * @return void
    */
    close(resetCreated := true)
    {
        if (!this.exists()) {
            return
        }

        if (this._onClose) {
            this.handleCallback(this._onClose, "onClose")
        }

        this.savePosition()
        this.destroy(resetCreated)

    }

    destroy(resetCreated := true)
    {
        this.gui("Destroy")
        _GUI.INSTANCES.Delete(this.getId())
        _GUI.INSTANCES_BY_NAME.Delete(this.getName())

        if (resetCreated) {
            this._created := false
        }
    }

    setDefault()
    {
        this.gui("Default")
    }

    gui(command, extra := "")
    {
        if (extra) {
            this.ensureGuiExists(A_ThisFunc, command " " extra)
            Gui, % this.guiPrefix() "" command, % extra
            return
        }

        Gui, % this.guiPrefix() "" command
    }

    /**
    * @throws
    */
    ensureGuiExists(identifier, extra := "")
    {
        if (this.exists()) {
            return
        }

        throw Exception("Performing action on gui that has not been created: " this.getName() ", identifier: " identifier ", extra: " extra)
    }

    /**
    * @return string
    */
    guiPrefix()
    {
        return this.getId() ":"
        ; return this.getName() ":"
    }

    getGuiOptions()
    {
        static options 
        if (!options) {
            options := {}
            options.Push("x")
            options.Push("y")
        }

        this.readPosition()

        guiOptions := ""
        for key, option in options {
            value := this["_" option]
            if (!empty(value)) {
                guiOptions .= " " option "" value
            }
        }

        w := this.getWidth()
        guiOptions .= w ? " w" w : ""
        h := this.getHeight()
        guiOptions .= h ? " h" h : ""


        return guiOptions
    }

    /**
    * @param function callback
    * @return void
    * @throws
    */
    handleCallback(callback, identifier := "")
    {
        if (!callback) {
            return
        }

        try {
            return %callback%()
        } catch e {
            ; _Logger.msgboxException(16, e, this.getName(), this._title)
            _Logger.exception(e, A_ThisFunc, identifier, this.getName())
            throw e
        }
    }

    addControl(control)
    {
        if (!control.getParent()) {
            return
        }

        this.controls[control.getName()] := control.getParent().getTitle()
    }

    /**
    * @return this
    */
    alwaysOnTop()
    {
        this.options("+AlwaysOnTop")

        return this
    }

    /**
    * @return this
    */
    noActivate()
    {
        this._noActivate := "NoActivate"

        return this
    }

    /**
    * @return this
    */
    toolWindow()
    {
        this.options("+ToolWindow")

        return this
    }

    /**
    * @return this
    */
    scrollable()
    {
        ; this.option("+0x300000") ; WS_VSCROLL | WS_HSCROLL
        this.option("+0x200000") ; WS_VSCROLL

        return this
    }

    filter()
    {
        this.close(false)
        this.open(false)
    }

    readPosition()
    {
        pos := StrSplit(_Ini.read(this.getIniName(), this.INI_SECTION), "|")

        if (pos.1) {
            this.x(pos.1)
        }
        if (pos.2) {
            this.y(pos.2)
        }

        if (empty(this._x) && this._defaultX) {
            this._x := this._defaultX
        }

        if (empty(this._y) && this._defaultY) {
            this._y := this._defaultY
        }

        if (!this._x) {
            this._x := new _DefaultValue("", 0, A_ScreenWidth - (this.getWidth() + 10)).resolve(x)
        }

        if (!this._y) {
            this._y := new _DefaultValue("", 0, A_ScreenHeight - (this.getHeight() + 30)).resolve(y)
        }
    }

    savePosition()
    {
        if (!this.exists()) {
            return
        }

        WinGetPos, x, y,,, % "ahk_id " this.getId()
        if (x < -3000 OR y < -3000)
            return
        if (x != "" && y != "") {
            _Ini.write(this.getIniName(), x "|" y, this.INI_SECTION)
        }
    }

    border()
    {
        this.option("+Border")

        return this
    }

    withoutMinimizeButton()
    {
        this.option("-MinimizeBox")
        return this
    }

    withoutWindowButtons()
    {
        this.option("-SysMenu")
        return this
    }

    withoutCaption()
    {
        this.option("-Caption")
        return this
    }

    /**
    * @param string value
    * @param ?string extra
    * @return this
    */
    option(value, extra := "")
    {
        value := extra ? value "" extra : value
        this._options["" value ""] := true

        return this
    }

    /**
    * @param array<string> options
    * @return this
    */
    options(options*)
    {
        for _, option in options {
            this._options["" option ""] := true
        }

        return this
    }

    /**
    * @param string value
    * @return this
    */
    removeOption(value)
    {
        this._options.Delete("" value "")

        return this
    }

    /**
    * @return ?string
    */
    defaultOptions()
    {
    }

    /**
    * @return this
    */
    disable()
    {
        this.gui("+Disabled")
        return this
    }

    /**
    * @return this
    */
    enable()
    {
        this.gui("-Disabled")
        return this
    }

    ;#region Getters
    getId()
    {
        return this._id
    }

    getName()
    {
        return this._name ? this._name : "main"
    }

    getIniName()
    {
        return this._iniName ? this._iniName : this.getName()
    }

    getTitle()
    {
        return this._title
    }

    getWidth()
    {
        return this.getW()
    }

    getHeight()
    {
        return this.getH()
    }

    getW()
    {
        return this._w ? this._w : ""
    }

    getH()
    {
        return this._h ? this._h : ""
    }

    getX()
    {
        return this._x ? this._x : ""
    }

    getY()
    {
        return this._y ? this._y : ""
    }

    getFilter()
    {
        if (!this._created) {
            return
        }

        try {
            return this.handleCallback(this._filter, "filter")
        } catch e {
            _Logger.msgboxException(16, e, this.getId())
            return
        }
    }

    /**
    * @return string
    */
    getOptions()
    {
        string := ""
        for option, state in this._options {
            if (state == false) {
                continue
            }

            string .= option " "
        }

        string .= this.defaultOptions()

        return string
    }
    ;#endregion



    ;#region Setters
    /**
    * @return this
    */
    x(x)
    {
        this._x := x
        return this 
    }

    /**
    * @return this
    */
    y(y)
    {
        this._y := y
        return this 
    }

    /**
    * @return this
    */
    w(value)
    {
        this._w := value
        return this 
    }

    /**
    * @return this
    */
    title(value)
    {
        this._title := value
        return this 
    }

    /**
    * @return this
    */
    iniName(value)
    {
        this._iniName := value
        return this 
    }

    /**
    * @return this
    */
    h(value)
    {
        this._h := value
        return this 
    }
    /**
    * @return this
    */
    preventEscape()
    {
        this._preventEscape := true
        return this 
    }

    setFilter(callback)
    {
        this._filter := callback
        return this
    }

    onCreate(callback)
    {
        _Validation.function("callback", callback)
        this._create := callback

        return this
    }

    onClose(callback)
    {
        _Validation.function("callback", callback)
        this._onClose := callback

        return this
    }

    onCreateValidations(callback)
    {
        _Validation.function("callback", callback)
        this._onCreateValidations := callback

        return this
    }

    afterCreate(callback)
    {
        _Validation.function("callback", callback)
        this._afterCreate := callback

        return this
    }

    defaultX(value) 
    {
        this._defaultX := value 

        return this
    }

    defaultY(value) 
    {
        this._defaultY := value 

        return this
    }

    maxWidth(value) 
    {
        this._maxWidth := value 

        return this
    }

    maxHeight(value) 
    {
        this._maxHeight := value 

        return this
    }

    minWidth(value) 
    {
        this._minWidth := value 

        return this
    }

    minHeight(value) 
    {
        this._minHeight := value 

        return this
    }
    ;#endregion

    ;#region Predicates
    /**
    * @return bool
    */
    isCreated()
    {
        return this._created ? true : false
    }

    /**
    * @return bool
    */
    exists()
    {
        return WinExist("ahk_id" this.getId()) ? true : false
    }
    ;#endregion
}

