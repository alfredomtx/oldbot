
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\Read\_ReadText.ahk

class _ReadInteger extends _ReadText
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(clientArea)
    {
        base.__New(clientArea)

        this.numbersOnly(true)
        this.increaseDpi(true)
    }

    /**
    * @return string
    * @throws
    */
    run()
    {
        try {
            return this.sanitizeAsInteger(base.run())
        } catch e {
            if (e.What == "EmptyString") {
                this.increaseDpi(false)

                return this.sanitizeAsInteger(base.run())
            }
        }
    }

    /**
    * @return ?int
    * @throws
    */
    sanitizeAsInteger(string)
    {
        static replaces 

        ; replace letters that look like numbers
        if (!replaces) {
            replaces := {}
            replaces["O"] := "0"
        }

        _Logger.log(A_ThisFunc, "string: " string)

        StringCaseSense, On
        for, char, replace in replaces {
            string := StrReplace(string, char, replace)
        }
        StringCaseSense, Off

        if (string = "") {
            throw Exception("Empty string", "EmptyString")
        }

        numeric := ""
        Loop, Parse, string  ; Loop through each character in the string
        {
            If A_LoopField is Number  ; Check if the current character is numeric
                numeric .= A_LoopField  ; If it is, add it to the numeric string
        }

        if numeric is not number
        {
            throw Exception("Invalid number: " numeric, "InvalidNumber")
        }

        _Logger.log(A_ThisFunc, "numeric: " numeric)

        return numeric
    }

    increaseDpi(value := true)
    {
        this._increaseDpi := value

        return this
    }
}