#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Offer Handler\_AcceptOfferHandler.ahk

class _SellOfferHandler extends _AcceptOfferHandler
{
    static CSV_FILE := "accepted_sell_offers.csv"

    __New(offer)
    {
        _Validation.instanceOf("offer", offer, _BuyItemOffer)
        base.__New(offer, "sell")
    }

    /**
    * @abstract
    */
    validateSelectedAmount()
    {
        _Logger.log(A_ThisFunc)

        amount := this.offer.getAmount()
        if (amount && this.selectedAmount > amount) {
            throw Exception(txt("A quantidade selecionada é maior que a quantidade da oferta", "Selected amount is higher than the offer amount") " (" this.selectedAmount " > " amount ")")
        }
    }
    ;#endregion
}