class _Groupbox extends _AbstractControl
{
    static CONTROL := "Groupbox"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        base.__New(_Groupbox.CONTROL)
    }

    /**
    * @return this
    */
    line()
    {
        this.title("")
            .h(8)
            .color("black")

        return this
    }

    onEvent()
    {
    }
}
