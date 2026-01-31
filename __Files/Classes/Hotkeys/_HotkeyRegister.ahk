/**
* @static
*/
class _HotkeyRegister extends _BaseClass
{
    static ACTIVE_HOTKEYS := {}

    __New()
    {
        ; guardAgainstAbstractInstantiation(this)
    }

    showActive()
    {
        msgbox, 64,, % se(this.ACTIVE_HOTKEYS)
    }

    /**
    * @param string hotkey
    * @param BoundFunc callback
    * @param string identifier
    * @return void
    * @msgbox
    */
    register(htk, callback, identifier, oldHotkey := "")
    {
        _Validation.function("callback", callback)

        if (!empty(oldHotkey)) {
            this.unregister(oldHotkey)
        }

        if (empty(htk)) {
            return
        }

        try { 
            fn := this.clientOrWindowCondition.bind(this)
            Hotkey If, % fn
            Hotkey, % htk, % callback, % "On"
            this.ACTIVE_HOTKEYS[htk] := identifier
        } catch e {
            _Logger.msgboxException(16, e, A_ThisFunc, htk)
        }
    }

    /**
    * @param string hotkey
    * @return void
    */
    unregister(htk)
    {
        if (empty(htk)) {
            return
        }

        try {
            Hotkey, % htk, % "Off"
            this.ACTIVE_HOTKEYS.Delete(htk)
        } catch e {
            _Logger.exception(e, A_ThisFunc, htk)
        }
    }

    /**
    * @param _Hotkey|Function control
    * @param Function callback
    * @param string identifier
    * @param _Hotkey|Function|null oldHotkey
    * @return void
    */
    registerFromControl(control, callback, identifier, oldHotkey := "")
    {
        if (isFunction(control)) {
            control := %control%()
        }

        _Validation.instanceOf("control", control, _Hotkey)

        newHotkey := control.get()
        ; if (InStr(newHotkey, "^") || InStr(newHotkey, "!") || InStr(newHotkey, "+")) {
        ;     return
        ; }

        if (isFunction(oldHotkey)) {
            oldHotkey := %oldHotkey%()
        }

        this.register(newHotkey, callback, identifier, oldHotkey)
    }

    /**
    * @return bool
    */
    clientOrWindowCondition()
    {
        return WinActive("ahk_class AutoHotkeyGUI") || WinActive("ahk_id " TibiaClientID)
    }

}