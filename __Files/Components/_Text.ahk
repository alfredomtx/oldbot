class _Text extends _AbstractControl
{
    static CONTROL := "Text"
    static LAST := ""

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        base.__New(_Text.CONTROL)
    }

    /**
    * @return this
    */
    add()
    {
        base.add()

        _Text.LAST := this

        return this
    }

    /**
    * @return this
    */
    bold()
    {
        this.font("Bold")

        return this
    }

    /**
    * @return this
    */
    underline()
    {
        this.font("underline")

        return this
    }

    /**
    * @return this
    */
    link()
    {
        this.underline()
        this.color("blue")

        return this
    }

    /**
    * @return void
    */
    onEvent()
    {
    }

    /**
    * @return this
    */
    alignRight()
    {
        this.option("Right")

        return this
    }
}
