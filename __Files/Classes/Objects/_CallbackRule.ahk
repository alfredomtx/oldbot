#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Objects\_ControlRule.ahk

class _CallbackRule extends _ControlRule
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }


    __New(identifier := "")
    {
        this.identifier := identifier
        this._callback := ""
    }

    /**
    * @param mixed value
    * @return bool
    * @throws
    */
    evaluate(value)
    {
        return this._callback.call(value)
    }


    callback(value)
    {
        _Validation.function("value", value)
        this._callback := value

        return this
    }
}