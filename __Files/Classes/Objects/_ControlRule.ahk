/**
* @property string identifier
*/
class _ControlRule extends _BaseClass
{
    static NOT_EMPTY := "notEmpty"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(identifier := "")
    {
        this.identifier := identifier
        this._rule := ""
        this._type := ""
    }

    /**
    * @param string rule
    * @return this
    */
    rule(rule)
    {
        static allowedRules
        if (!allowedRules) {
            allowedRules := [_ControlRule.NOT_EMPTY]
            _Validation.true(rule, _Arr.search(allowedRules, rule))
        }

        this._rule := rule

        return this
    }

    /**
    * @param _DefaultValue value
    * @return _ControlRule
    */
    fromDefaultValue(value)
    {
        return new this(value.identifier)
            .min(value.min)
            .max(value.max)
            .type(value.type)
    }

    /**
    * @param _DefaultValue defaultValue
    * @return this
    */
    default(defaultValue) 
    {
        this._min := defaultValue.min
        this._max := defaultValue.max
        this._default := defaultValue.default
        this._type := defaultValue.type

        return this
    }

    min(value)
    {
        this._min := value
        return this
    }

    max(value)
    {
        this._max := value
        return this
    }

    type(value)
    {
        this._type := value
        return this
    }

    getMin()
    {
        return this._min
    }

    getMax()
    {
        return this._max
    }

    getType()
    {
        return this._type
    }

    getDefault()
    {
        return this._default
    }

    /**
    * @param mixed value
    * @return bool
    * @throws
    */
    evaluate(value)
    {
        switch (this._rule) {
            case _ControlRule.NOT_EMPTY:
                if (empty(value)) {
                    throw Exception(txt("O valor nâo pode ser vazio.", "The value can't be empty."))
                }

                return true
        }

        if (this._min && !this.evaluateMin(value)) {
            return false
        }

        if (this._max && !this.evaluateMax(value)) {
            return false
        }

        return true
    }

    getValue(value)
    {
        switch (this._rule) {
            case _ControlRule.NOT_EMPTY:
                return value
        }

        if (this._min && this.evaluateMin(value)) {
            return this._min
        }

        if (this._max && this.evaluateMax(value)) {
            return this._max
        }

        return value
    }

    evaluateMin(value)
    {
        return (empty(value) || value < this._min)
    }

    evaluateMax(value)
    {
        return (value > this._max)
    }
}