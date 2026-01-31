class _Notification extends _BaseClass
{
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        this.title("OldBot")
        this.icon(1)
        this.timeout(8)
    }

    title(value)
    {
        this._title := value

        return this
    }

    message(value)
    {
        this._message := value

        return this
    }

    timeout(value)
    {
        this._timeout := value

        return this
    }

    icon(value)
    {
        this._icon := value

        return this
    }

    info()
    {
        this.icon(1)
        return this
    }

    warning()
    {
        this.icon(2)
        return this
    }

    error()
    {
        this.icon(3)
        return this
    }

    show() 
    {
        _Validation.empty("this._message", this._message)

        Menu Tray, Icon
        TrayTip, % this._title, % this._message,, % this._icon

        fn := this.hide.bind(this)
        SetTimer, % fn, Delete
        t := "-" (this._timeout * 1000)
        SetTimer, % fn, % t
    }

    hide()
    {
        TrayTip ; Attempt to hide it the normal way.
        if (SubStr(A_OSVersion,1,3) = "10.") {
            Menu Tray, NoIcon
            Sleep 200 ; It may be necessary to adjust this sleep.
            Menu Tray, Icon
        }
    }
}