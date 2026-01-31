#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractSelectedAmountArea.ahk

class _SellSelectedAmountArea extends _AbstractSelectedAmountArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "sellSelectedAmountArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New(debugArea := false)
    {
        if (_SellSelectedAmountArea.INSTANCE) {
            return _SellSelectedAmountArea.INSTANCE
        }

        this.debugArea := debugArea

        base.__New(this)

        _SellSelectedAmountArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _SellSelectedAmountArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _SellSelectedAmountArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _SellSelectedAmountArea.INSTANCE := ""
        _SellSelectedAmountArea.INITIALIZED := false
    }
}