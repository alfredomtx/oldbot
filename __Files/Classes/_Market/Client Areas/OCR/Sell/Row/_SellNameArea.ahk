#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractNameArea.ahk

class _SellNameArea extends _AbstractNameArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "sellNameArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_SellNameArea.INSTANCE) {
            return _SellNameArea.INSTANCE
        }

        base.__New(this)

        _SellNameArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _SellNameArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _SellNameArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _SellNameArea.INSTANCE := ""
        _SellNameArea.INITIALIZED := false
    }
}