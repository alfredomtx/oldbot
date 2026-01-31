#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Offer Handler\_AcceptOfferHandler.ahk

class _CreateBuyOfferHandler extends _CreateOfferHandler
{
    static CSV_FILE := "created_buy_offers.csv"

    __New(offer)
    {
        _Validation.instanceOf("offer", offer, _CreateBuyItemOffer)
        base.__New(offer, "buy")
    }


    /**
    * @return void
    * @throws
    */ 
    doesNotOwnOffer()
    {
        try {
            this.balanceCondition()
        } catch e {
            this.cancelOfferIfHasLastCreated()

            throw e
        }
    }
}