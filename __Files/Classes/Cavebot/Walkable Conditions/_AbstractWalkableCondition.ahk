
class _AbstractWalkableCondition extends _BaseClass
{
    __New(x, y, z, params := "")
    {
        _Validation.number("x", x, Number)
        _Validation.number("y", y, Number)
        _Validation.number("z", z, Number)

        this.x := x
        this.y := y
        this.z := z
        this.params := params ? params : {}
    }

    /**
    * @param string key
    * @param string value
    * @return this
    */
    setParam(key, value)
    {
        this.params[key] := value
        return this
    }

    /**
    * @return bool
    */
    handle()
    {
        abstractMethod()
    }
}