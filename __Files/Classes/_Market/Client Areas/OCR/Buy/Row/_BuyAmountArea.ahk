#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractAmountArea.ahk

class _BuyAmountArea extends _AbstractAmountArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "buyAmountArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New(debugArea := false)
    {
        if (_BuyAmountArea.INSTANCE) {
            return _BuyAmountArea.INSTANCE
        }

        this.debugArea := debugArea

        base.__New(this)

        _BuyAmountArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _BuyAmountArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _BuyAmountArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _BuyAmountArea.INSTANCE := ""
        _BuyAmountArea.INITIALIZED := false
    }
}