#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractSelectedAmountArea.ahk

class _BuySelectedAmountArea extends _AbstractSelectedAmountArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "buySelectedAmountArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New(debugArea := false)
    {
        if (_BuySelectedAmountArea.INSTANCE) {
            return _BuySelectedAmountArea.INSTANCE
        }

        this.debugArea := debugArea

        base.__New(this)


        _BuySelectedAmountArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _BuySelectedAmountArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _BuySelectedAmountArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _BuySelectedAmountArea.INSTANCE := ""
        _BuySelectedAmountArea.INITIALIZED := false
    }
}