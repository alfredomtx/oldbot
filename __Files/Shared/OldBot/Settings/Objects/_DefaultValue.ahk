
/**
* @property mixed default
* @property ?int min
* @property ?int max
* @property ?int max
* @property ?string identifier
* @property ?string type
* @property ?object sanitizer
*/
class _DefaultValue extends _BaseClass
{
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @param mixed default
    * @param ?int min
    * @param ?int max
    * @param ?int max
    * @param ?string identifier
    */
    __New(default, min := "", max := "", identifier := "")
    {
        this.default := default
        this.min := min
        this.max := max
        this.identifier := identifier
        this.sanitizer := ""
        this.type := ""
    }

    /**
    * @param string identifier
    * @return this
    */
    setIdentifier(identifier)
    {
        this.identifier := identifier

        return this
    }

    /**
    * @param _AbstractSettings class
    * @param string functionName
    * @return this
    */
    setSanitizer(class, functionName)
    {
        _Validation.instanceOf("class", class, _AbstractSettings)
        this.sanitizer := {"class": class, "function": functionName}

        return this
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

        if (this.min && value < this.min) {
            return this.min
        }

        if (this.max && value > this.max) {
            return this.max
        }

        if (this.sanitizer) {
            class := this.sanitizer.class

            value := class[this.sanitizer.function](value)
        }

        if (value || value == 0) {
            return value
        }
    }

    /**
    * @param string value
    * @return this
    */
    setType(value)
    {
        this.type := value
        return this
    }
}
