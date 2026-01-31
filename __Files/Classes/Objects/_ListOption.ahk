
/**
* @property string name
* @property bool selected
*/
class _ListOption extends _BaseClass
{
    static SEPARATOR := "@@@"
    __New(name, selected := false)
    {
        this.name := name
        this.selected := selected
    }

    /**
    * @param array<_ListOption> array
    * @return string
    */
    arrayToString(array) 
    {
        _Validation.instanceOf("array", _Arr.first(array), _ListOption)

        string := ""
        for _, listOption in array {
            string .= listOption.getName() "|" (listOption.isSelected() ? "|" : "")
            string .= this.SEPARATOR
        }

        return string
    }

    /**
    * @param string value
    * @return array<_ListOption> array
    */
    stringToArray(value)
    {
        array := {}
        if (!InStr(value, this.SEPARATOR)) {
            throw Exception("String missing """ this.SEPARATOR """ separator")
        }

        for _, option in StrSplit(value, this.SEPARATOR) {
            if (empty(option)) {
                continue
            }

            array.Push(new _ListOption(StrReplace(option, "|", "")))
        }

        return array
    }

    /**
    * @return string
    */
    getName()
    {
        return this.name
    }

    /**
    * @return bool
    */
    isSelected()
    {
        return this.selected
    }
}