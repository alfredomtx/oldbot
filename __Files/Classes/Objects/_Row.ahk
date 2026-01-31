
/**
* @property array<string> columns
*/
class _Row extends _BaseClass
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(selected := false) {
        this.selected := selected
        this.checked := false
        this.columns := {}
        this.options := {}

        this.number := ""
    }

    /**
    * @param string value
    * @return this
    */
    add(value)
    {
        this.columns.Push(value)
        return this
    }

    /**
    * @return array<string>
    */
    get()
    {
        return this.columns
    }

    /**
    * @param string value
    * @return this
    */
    addOption(value)
    {
        this.options.Push(value)
        return this
    }

    /**
    * @return string
    */
    getOptions()
    {
        return _Arr.concat(this.options, " ")
    }

    /**
    * @return bool
    */
    isSelected()
    {
        return this.selected
    }

    /**
    * @return bool
    */
    isChecked()
    {
        return this.checked
    }

    /**
    * @return this
    */
    setSelected(value)
    {
        this.selected := value ? true : false
        return this
    }

    /**
    * @return this
    */
    setChecked(value )
    {
        this.checked := value ? true : false
        return this
    }

    /**
    * @return ?int
    */
    getNumber()
    {
        return this.number
    }

    /**
    * @return int value
    */
    setNumber(value)
    {
        this.number := value
        return this
    }

    /**
    * @return string
    */
    getText()
    {
        return this.text
    }

    /**
    * @return string value
    */
    setText(value)
    {
        this.text := value
        return this
    }
}