#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Item Offer\_CreateItemOffer.ahk

class _CreateBuyItemOffer extends _CreateItemOffer
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(item)
    {
        base.__New(item, "buy", "buy")
    }

    /**
    * @abstract
    * @param int price
    * @return void
    * @throws
    */
    rejectOffer(price)
    {
        this.guardAgainstZeroCoverPrice()

        targetPrice := this.getPrice()

        if (price > targetPrice) {
            throw Exception(txt("O preço para cobrir a oferta(" price ") é maior do que o preço limite(" targetPrice ").", "The price to cover the offer(" price ") is higher than the limit price(" targetPrice ")."), "OfferPriceException")
        }
    }

    ;#region Getters

    /**
    * @return int
    */
    getOfferCreationPrice(currentPrice)
    {
        noOfferPrice := base.getOfferCreationPrice(currentPrice)
        if (currentPrice < noOfferPrice) {
            return noOfferPrice
        }

        coverAmount := this.settings("coverOfferAmount")

        return currentPrice ? currentPrice + coverAmount : noOfferPrice
    }

    getDisplayAction()
    {
        return txt("oferta de compra", "buy offer")
    }

    getActionIdentifier()
    {
        return "buyOffer"
    }
    ;#endregion
}