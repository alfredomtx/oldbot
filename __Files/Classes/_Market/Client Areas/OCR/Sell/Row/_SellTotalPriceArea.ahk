#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractTotalPriceArea.ahk

class _SellTotalPriceArea extends _AbstractTotalPriceArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "sellTotalPriceArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_SellTotalPriceArea.INSTANCE) {
            return _SellTotalPriceArea.INSTANCE
        }

        base.__New(this)

        _SellTotalPriceArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _SellTotalPriceArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _SellTotalPriceArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _SellTotalPriceArea.INSTANCE := ""
        _SellTotalPriceArea.INITIALIZED := false
    }
}