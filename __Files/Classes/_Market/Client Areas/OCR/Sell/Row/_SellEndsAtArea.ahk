#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractEndsAtArea.ahk

class _SellEndsAtArea extends _AbstractEndsAtArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "sellEndsAtArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_SellEndsAtArea.INSTANCE) {
            return _SellEndsAtArea.INSTANCE
        }

        base.__New(this)

        _SellEndsAtArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _SellEndsAtArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _SellEndsAtArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _SellEndsAtArea.INSTANCE := ""
        _SellEndsAtArea.INITIALIZED := false
    }
}