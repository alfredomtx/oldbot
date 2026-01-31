#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractPriceArea.ahk

class _SellPriceArea extends _AbstractPriceArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "sellPriceArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_SellPriceArea.INSTANCE) {
            return _SellPriceArea.INSTANCE
        }

        base.__New(this)

        _SellPriceArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _SellPriceArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _SellPriceArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _SellPriceArea.INSTANCE := ""
        _SellPriceArea.INITIALIZED := false
    }
}