class _Progress extends _AbstractControl
{
    static CONTROL := "Progress"

    static BACKGROUND := "Backgroundc7dcfc"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        base.__New(_Progress.CONTROL)

        this.h(20)
    }

    blue()
    {
        this.background(_Progress.BACKGROUND)
        return this
    }

    green()
    {
        this.option("c36da1d")
        this.option("Backgroundc7fcbf")
        return this
    }

    /**
    * @param int number
    * @return this
    */
    setProgress(number)
    {
        GuiControl, % this.guiPrefix(), % this.getControlID(), % number
        return this
    }

    onEvent()
    {
    }
}
