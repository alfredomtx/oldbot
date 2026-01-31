#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Item Offer\_CreateItemOffer.ahk

class _CreateSellItemOffer extends _CreateItemOffer
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(item)
    {
        base.__New(item, "sell", "sell")
    }

    rejectOffer(price)
    {
        this.guardAgainstZeroCoverPrice()

        coverPrice := this.getOfferCreationPrice(price)
        targetPrice := this.getPrice()

        if (coverPrice < targetPrice) {
            throw Exception(txt("O preço para cobrir a oferta(" coverPrice ") é menor do que o preço limite(" targetPrice ").", "The price to cover the offer(" coverPrice ") is lower than the limit price(" targetPrice ")."), "OfferPriceException")
        }
    }

    /**
    * @param int balance
    * @return void
    * @throws
    */
    balanceCondition(balance)
    {
        ; sell offer does not have balance condition
    }

    ;#region Getters
    /**
    * @return int
    */
    getOfferCreationPrice(currentPrice)
    {
        noOfferPrice := base.getOfferCreationPrice(currentPrice)
        if (currentPrice > noOfferPrice) {
            return noOfferPrice
        }

        coverAmount := this.settings("coverOfferAmount")

        return currentPrice ? currentPrice - coverAmount : noOfferPrice
    }

    getDisplayAction()
    {
        return txt("oferta de venda", "sell offer")
    }

    getActionIdentifier()
    {
        return "sellOffer"
    }
    ;#endregion
}