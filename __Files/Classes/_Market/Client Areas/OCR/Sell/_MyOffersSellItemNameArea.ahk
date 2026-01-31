#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Abstract\_AbstractMyOffersItemNameArea.ahk


class _MyOffersSellItemNameArea extends _AbstractMyOffersItemNameArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "myOffersSellItemNameArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_MyOffersSellItemNameArea.INSTANCE) {
            return _MyOffersSellItemNameArea.INSTANCE
        }

        base.__New(this)

        _MyOffersSellItemNameArea.INSTANCE := this
    }

    getImageName()
    {
        return "sell_offers"
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _MyOffersSellItemNameArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _MyOffersSellItemNameArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _MyOffersSellItemNameArea.INSTANCE := ""
        _MyOffersSellItemNameArea.INITIALIZED := false
    }
}