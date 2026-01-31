#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Item Offer\_ItemOffer.ahk

class _SellItemOffer extends _ItemOffer
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(item)
    {
        base.__New(item, "sell", "buy")
    }

    rejectOffer(price)
    {
        if (price < this.getPrice()) {
            throw Exception(txt("preço da oferta é menor do que o preço desejado", "offer price is lower than the desired price") " (" price " < " this.getPrice() ")")
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

    offerFulfilledEvent(amount)
    {
        this.incrementFulfilledAmount(amount)
    }

    resetProgress()
    {
        this.settings("soldAmount", 0)
    }

    ;#region Getters
    getFulfilledAmountKey()
    {
        return "soldAmount"
    }

    getDisplayAction()
    {
        return txt("vender", "sell")
    }

    getActionIdentifier()
    {
        return "sell"
    }
    ;#endregion
}