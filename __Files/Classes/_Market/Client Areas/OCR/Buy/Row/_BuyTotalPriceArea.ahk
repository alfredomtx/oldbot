#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractTotalPriceArea.ahk

class _BuyTotalPriceArea extends _AbstractTotalPriceArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "buyTotalPriceArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_BuyTotalPriceArea.INSTANCE) {
            return _BuyTotalPriceArea.INSTANCE
        }

        base.__New(this)

        _BuyTotalPriceArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _BuyTotalPriceArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _BuyTotalPriceArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _BuyTotalPriceArea.INSTANCE := ""
        _BuyTotalPriceArea.INITIALIZED := false
    }
}