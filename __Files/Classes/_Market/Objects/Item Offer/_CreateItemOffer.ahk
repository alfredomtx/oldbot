#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Item Offer\_ItemOffer.ahk

class _CreateItemOffer extends _ItemOffer
{
    offerFulfilledEvent(amount)
    {
        this.incrementFulfilledAmount(amount)
    }

    resetProgress()
    {
        this.settings("createdBuyOfferAmount", 0)
        this.settings("createdSellOfferAmount", 0)
    }

    unsetLastCreated()
    {
        this.settings("last" _A.upperFirst(this.type) "Offer", 0)
    }

    /**
    * @return void
    */
    deleteCreated()
    {
        settings := new _MarketItemSettings()

        this.unsetLastCreated()

        settings.delete("last" this.type "OfferEndsAt", this.item)
        settings.delete("last" this.type "OfferCreated", this.item)
        settings.delete("last" this.type "OfferAmount", this.item)
        settings.delete("last" this.type "OfferPrice", this.item)
        settings.delete("last" this.type "OfferTotalPrice", this.item)
    }


    /**
    * @param int amount
    * @return void
    * @throws
    */
    validateSelectedAmount(selectedAmount)
    {
        amount := this.getAmount()

        if (amount == 0) {
            return 
        }

        if (selectedAmount > amount) {
            throw Exception(txt("A quantidade selecionada pelo bot é maior do que o esperado: " amount ", selecionado: " selectedAmount, "The amount selected by the bot is greater than expected: " amount ", selected: " selectedAmount), "HigherValidationException")
        }

        if (this.settings(this.type "OfferExclusiveAmount")) {
            amount := this.settings(this.type "OfferAmountExclusive")
            if (selectedAmount < amount) {
                throw Exception(txt("A quantidade selecionada pelo bot é menor do que o esperado: " amount ", selecionado: " selectedAmount, "The amount selected by the bot is less than expected: " amount ", selected: " selectedAmount), "AmountValidationException")
            }
            if (selectedAmount != amount) {
                throw Exception(txt("A quantidade selecionada pelo bot é diferente do que o esperado: " amount ", selecionado: " selectedAmount, "The amount selected by the bot is different than expected: " amount ", selected: " selectedAmount), "DifferentAmountException")
            }
        }
    }

    /**
    * @return void
    * @throws
    */
    guardAgainstZeroCoverPrice()
    {
        if (!this.getPrice()) {
            throw Exception(txt("O preço limite para cobrir a oferta não pode ser 0.", "The limit price to cover the offer cannot be 0."))
        }
    }

    guardAgainstMissingNoOfferPrice()
    {
        if (this.settings("no" this.type "OfferPrice") == "") {
            throw Exception("O preço para quando não houver nenhuma oferta não foi configurado, defina o preço nas configurações do item.", "The price for when there are no offers has not been set, set the price in the item settings.")
        }
    }

    ;#region Getters
    getOfferCreationAmount()
    {
        if (this.settings(this.type "OfferMaximumAmount")) {
            return 0
        }

        if (this.settings(this.type "OfferDefinedAmount")) {
            return this.settings(this.type "OfferAmount")
        }

        if (this.settings(this.type "OfferExclusiveAmount")) {
            return this.settings(this.type "OfferAmountExclusive")
        }

        throw Exception("Invalid " this.type " offer amount settings.")
    }

    /**
    * @return int
    */
    getOfferCreationPrice(currentPrice)
    {
        this.guardAgainstMissingNoOfferPrice()

        return this.settings("no" this.type "OfferPrice")
    }

    getFulfilledAmountKey()
    {
        return "created" this.type "OfferAmount"
    }

    /**
    * @return bool
    */
    getLastCreated()
    {
        return this.settings("last" this.type "Offer")
    }

    /**
    * @return ?string
    */
    getLastCreatedEndsAt()
    {
        return this.settings("last" this.type "OfferEndsAt")
    }

    /**
    * @return ?int
    */
    getLastCreatedAmount()
    {
        return this.settings("last" this.type "OfferAmount")
    }

    /**
    * @return ?int
    */
    getLastCreatedPrice()
    {
        return this.settings("last" this.type "OfferPrice")
    }
    ;#endregion

    ;#region Setters
    /**
    * @param int value
    * @return this
    */
    setLastCreated(value)
    {
        _Validation.bool("value", value)
        this.settings("last" _A.upperFirst(this.type) "Offer", value)

        return this
    }

    /**
    * @param int value
    * @return this
    */
    setLastCreatedEndsAt(value)
    {
        _Validation.string("value", value)
        this.settings("last" _A.upperFirst(this.type) "OfferEndsAt", value)

        return this
    }

    /**
    * @param int value
    * @return this
    */
    setLastCreatedAmount(value)
    {
        _Validation.number("value", value)
        this.settings("last" _A.upperFirst(this.type) "OfferAmount", value)

        return this
    }

    /**
    * @param int value
    * @return this
    */
    setLastCreatedPrice(value)
    {
        _Validation.number("value", value)
        this.settings("last" _A.upperFirst(this.type) "OfferPrice", value)

        return this
    }
    ;#endregion

    ;#region Predicates
    /**
    * @return bool
    */
    hasLastCreated()
    {
        return this.settings("last" this.type "Offer")
    }
    ;#endregion

}