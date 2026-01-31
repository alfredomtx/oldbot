#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\_Loggable.ahk

class _ReadBalance extends _Loggable
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return ?int
    */
    run()
    {
        this.log(txt("Lendo balance...", "Reading balance..."))
        balance := new _ReadInteger(new _BalanceArea()).run()
        this.log("Balance: " balance " gp.")

        return balance
    }
}