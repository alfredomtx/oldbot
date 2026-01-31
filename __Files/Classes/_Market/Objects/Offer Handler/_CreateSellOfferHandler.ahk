#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Offer Handler\_OfferHandler.ahk

class _CreateSellOfferHandler extends _CreateOfferHandler
{
    static CSV_FILE := "created_sell_offers.csv"

    __New(offer)
    {
        _Validation.instanceOf("offer", offer, _CreateSellItemOffer)
        base.__New(offer, "sell")
    }

    /**
    * @return void
    * @throws
    */ 
    doesNotOwnOffer()
    {
        try {
            ; this.guardAgainstZeroItems()
        } catch e {
            if (e.What == "NoItemsException") {
                this.cancelOfferIfHasLastCreated()
            }

            throw e
        }
    }
}
