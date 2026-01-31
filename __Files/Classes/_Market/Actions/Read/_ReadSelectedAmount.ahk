#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\_Loggable.ahk

class _ReadSelectedAmount extends _Loggable
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(clientArea)
    {
        _Validation.instanceOf("clientArea", clientArea, _AbstractClientArea)

        this.clientArea := clientArea
        this.debug(false)
    }

    /**
    * @return ?int
    */
    run()
    {
        action := new _ReadAmount(this.clientArea)
            .debug(this._debug)

        try {
            amount := action.run()
        } catch e {
            /*
            when reading 0 amount, it may recognize as O and be ignored from the tesseract's char lists 
            so we need to try again reading it as a string
            */
            if (e.What == "InvalidNumber") {
                amount := action.sanitizeAsInteger(new _ReadText(this.clientArea).run())
            }
        }

        this.log(txt("Quantidade selecionada: ", "Selected amount: ") amount ".")

        return amount
    }

    debug(value := true)
    {
        this._debug := value

        return this
    }
}