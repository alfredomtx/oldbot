#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractAmountArea.ahk

class _SellAmountArea extends _AbstractAmountArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "sellAmountArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New(debugArea := false)
    {
        if (_SellAmountArea.INSTANCE) {
            return _SellAmountArea.INSTANCE
        }

        this.debugArea := debugArea

        base.__New(this)


        _SellAmountArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _SellAmountArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _SellAmountArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _SellAmountArea.INSTANCE := ""
        _SellAmountArea.INITIALIZED := false
    }
}