#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\Read\_ReadText.ahk

class _ReadAmount extends _ReadInteger
{
    __New(clientArea)
    {
        base.__New(clientArea)

        this.increaseDpi(false)
    }

    /**
    * @return string
    * @throws
    */
    run()
    {
        try {
            return base.run()
        } catch e {
            if (e.What == "EmptyString") {
                this.increaseDpi(true)

                return base.run()
            }
        }
    }
}