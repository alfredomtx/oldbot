#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

/**
* @property array<string, bool> _options
*/
class HasGuiOptions extends _BaseClass
{
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

    /**
    * @return ?string
    */
    defaultOptions()
    {
    }
}