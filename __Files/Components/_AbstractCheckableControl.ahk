class _AbstractCheckableControl extends _AbstractStatefulControl
{
    /**
    * @param string|function value
    * @return this
    */
    checkedEvent(value)
    {
        _Validation.empty(A_ThisFunc ".value", value)
        this._checkedEvent := value

        return this
    }

    /**
    * @param string|function value
    * @return this
    */
    uncheckedEvent(value)
    {
        _Validation.empty(A_ThisFunc ".value", value)
        this._uncheckedEvent := value

        return this
    }

    /**
    * @return this
    */
    check()
    {
        this.set(1)
        return this
    }

    /**
    * @return this
    */
    uncheck()
    {
        this.set(0)
        return this
    }

    /**
    * @return this
    */
    uncheckWithoutEvent()
    {
        base.set(0)
        return this
    }

    /**
    * @return this
    */
    toggle()
    {
        this.set(!this.get())
        return this
    }

    /**
    * GuiControl does not trigger event on Checkbox
    * @return this
    */
    set(value)
    {
        base.set(value)
        this.onEvent(this._hwnd, "Normal", 0)
    }

    /**
    * @return this
    */
    button()
    {
        return this.option("0x1000")
    }

    /**
    * @return this
    */
    value(value)
    {
        return base.value(value == true ? true : false)
    }
}
