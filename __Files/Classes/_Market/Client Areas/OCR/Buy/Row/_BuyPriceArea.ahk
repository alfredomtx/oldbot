#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractPriceArea.ahk

class _BuyPriceArea extends _AbstractPriceArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "buyPriceArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New(debugArea := false)
    {
        if (_BuyPriceArea.INSTANCE) {
            return _BuyPriceArea.INSTANCE
        }


        base.__New(this)

        _BuyPriceArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _BuyPriceArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _BuyPriceArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _BuyPriceArea.INSTANCE := ""
        _BuyPriceArea.INITIALIZED := false
    }
}