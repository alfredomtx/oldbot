class _HotkeyPresser extends _BaseClass
{
    static THREAD

    start()
    {
        this.THREAD := new _Thread()
            .setData({"hotkey": "b"})
            .setCode(this.getCode())
            .start()
    }

    stop()
    {
        this.THREAD.stop()
    }

    checked(control)
    {
        this.start()
    }

    unchecked(control)
    {
        this.stop()
    }

    getCode()
    {
        static code
        if (code) {
            return code
        }

        code := "
            (
                ; Send(data.hotkey)
                msgbox % data.hotkey
            )"
        return code
    }
}