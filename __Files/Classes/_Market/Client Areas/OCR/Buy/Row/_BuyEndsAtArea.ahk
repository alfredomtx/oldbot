#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractEndsAtArea.ahk

class _BuyEndsAtArea extends _AbstractEndsAtArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "buyEndsAtArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_BuyEndsAtArea.INSTANCE) {
            return _BuyEndsAtArea.INSTANCE
        }

        base.__New(this)

        _BuyEndsAtArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _BuyEndsAtArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _BuyEndsAtArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _BuyEndsAtArea.INSTANCE := ""
        _BuyEndsAtArea.INITIALIZED := false
    }
}