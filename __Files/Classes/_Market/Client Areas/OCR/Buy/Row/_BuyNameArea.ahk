#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractNameArea.ahk


class _BuyNameArea extends _AbstractNameArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "buyNameArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_BuyNameArea.INSTANCE) {
            return _BuyNameArea.INSTANCE
        }

        base.__New(this)

        _BuyNameArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _BuyNameArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _BuyNameArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _BuyNameArea.INSTANCE := ""
        _BuyNameArea.INITIALIZED := false
    }
}