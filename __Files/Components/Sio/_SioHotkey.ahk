class _SioHotkey extends _AbstractSioControl
{
    /**
    * @return _Hotkey
    */
    __New()
    {
        instance := base.__New(_Hotkey.__Class)

        instance.rule(new _HotkeyRule())

        return instance
    }
}
