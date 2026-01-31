#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractMyOffersItemNameArea.ahk

class _MyOffersBuyItemNameArea extends _AbstractMyOffersItemNameArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "myOffersBuyItemNameArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_MyOffersBuyItemNameArea.INSTANCE) {
            return _MyOffersBuyItemNameArea.INSTANCE
        }

        base.__New(this)

        _MyOffersBuyItemNameArea.INSTANCE := this
    }

    getImageName()
    {
        return "buy_offers"
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _MyOffersBuyItemNameArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _MyOffersBuyItemNameArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _MyOffersBuyItemNameArea.INSTANCE := ""
        _MyOffersBuyItemNameArea.INITIALIZED := false
    }
}