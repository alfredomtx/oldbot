class _AbstractListableControl extends _AbstractStatefulControl
{
    /**
    * @abstract
    * @return this
    * @throws
    */
    setLoadedValue()
    {
        try {
            name := this.getNestedName()
            value := this.getStateHandlerInstance().get(name)

            if (empty(value)) {
                this.chooseString(A_Space)
                return this
            }

            this.chooseString(value)
        } catch e {
            throw e
        }

        return this
    }

    /**
    * @abstract
    * @param array<_ListOption> list
    * @return this
    */
    list(list)
    {
        this._list := list

        if (isFunction(list)) {
            this._list := list.Call()
        }

        if (!this.exists()) {
            return this
        }

        this.set("|")

        if (!this._list.MaxIndex()) {
            return
        }

        _Validation.instanceOf("this._list", _Arr.first(this._list), _ListOption)

        options := ""
        selected := ""
        for _, listOption in this._list {
            options .= listOption.getName() "|"
            if (listOption.isSelected()) {
                selected := listOption
            }
        }

        this.set(options)

        if (selected) {
            this.chooseString(selected.getName())
        }

        return this
    }

    /**
    * @abstract
    * @return string
    */
    defaultOptions()
    {
        return " Sort"
    }

}
