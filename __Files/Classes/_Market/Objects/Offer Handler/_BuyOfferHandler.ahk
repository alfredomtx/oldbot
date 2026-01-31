#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Offer Handler\_AcceptOfferHandler.ahk

class _BuyOfferHandler extends _AcceptOfferHandler
{
    static CSV_FILE := "accepted_buy_offers.csv"

    __New(offer)
    {
        _Validation.instanceOf("offer", offer, _SellItemOffer)
        base.__New(offer, "buy")
    }

    /**
    * @abstract
    */
    validateSelectedAmount()
    {
    }
}