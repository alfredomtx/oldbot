
/**
* @property int number
*/
class _NavigationAction extends _AbstractNavigationAction
{
    __New(number)
    {
        _Validation.number("number", number)

        this.number := number
    }

    /**
    * @return string
    */
    toString()
    {
        return "action|" this.number
    }

    /**
    * @return string
    */
    toMessage()
    {
        return this.__Class "|" this.number
    }

    /**
    * @return int
    */
    getNumber()
    {
        return this.number
    }
}