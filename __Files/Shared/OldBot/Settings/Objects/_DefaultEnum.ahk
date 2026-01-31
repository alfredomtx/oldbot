#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Objects\_DefaultValue.ahk

class _DefaultEnum extends _DefaultValue
{
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @param string default
    * @param array<string> values
    * @param ?string identifier
    */
    __New(default, values, identifier := "")
    {
        _Validation.stringOrNumber("default", default)
        _Validation.stringOrNumber("values", _Arr.first(values))

        this.values := values

        base.__New(default)
            .setIdentifier(identifier)
    }

    /**
    * @param mixed value
    * @return mixed
    */
    resolve(value)
    {
        if (empty(value)) {
            return this.default
        }

        for _, enum in this.values {
            if (value == enum) {
                return value
            }
        }

        return this.default
    }

    /**
    * @return array<string>
    */
    getValues()
    {
        return this.values
    }
}