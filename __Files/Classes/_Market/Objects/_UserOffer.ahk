
class _UserOffer extends _Loggable
{
    static ITEM_COOLDOWN_KEY := "lastItemCooldownCheck"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(item)
    {
        this.item := item
        this.itemName := _A.lowerCase(item)

        this.instantiateBuyAndSell()
        this.instantiateBuyAndSellOffer()
    }

    beforeChecked()
    {
        if (!this.hasOffersEnabled()) {
            throw Exception(txt("Ofertas desabilitadas.", "Offers disabled."))
        }

        this.enforceItemCooldown()
    }

    afterChecked()
    {
        this.updateItemCooldown()

        if (new _MarketIniSettings().get("finishedItemConfirmation")) {
            this.log("Marketbot | " txt("Item finalizado, confirme a mensagem para continuar.", "Item finished, confirm the message to continue."))
            Msgbox, 64, % txt("Confirme para continuar", "Confirm to continue") " - " this.itemName, % txt("Ações finalizadas para o item ", "Actions finished for item " ) " " _Str.quoted(this.itemName) "."
        }
    }

    /**
    * @return void
    * @throws
    */
    enforceItemCooldown()
    {
        cooldown := this.cooldown()
        elapsed := cooldown.elapsed()

        if (cooldown.has()) {
            throw Exception(txt("Cooldown de ", "Cooldown of ") elapsed "/" cooldown.limit() " " txt("minutos para checar o item novamente.", "minutes to check the item again."), "CooldownException")
        }
    }

    elapsedCooldownSeconds()
    {
        return this.cooldown().elapsedSeconds()
    }

    cooldownSeconds()
    {
        return this.cooldown().limitSeconds()
    }

    cooldown()
    {
        if (this._cooldown) {
            return this._cooldown
        }

        limit := new _MarketbotLicense().cooldown()

        return this._cooldown := new _MarketCooldown(this.item, limit, this.ITEM_COOLDOWN_KEY)
    }

    updateItemCooldown()
    {
        return this.cooldown().write(A_TickCount)
    }

    instantiateBuyAndSell()
    {
        this.buy := new _BuyItemOffer(this.item)
            .setEnabled(this.settings("buyItem"))
            .setPrice(this.settings("buyPrice") ? this.settings("buyPrice") : 0)
            .setAmount(this.settings("buyAll") ? 0 : this.settings("buyAmount"))

        this.buy.setFulfilledAmount(this.settings("boughtAmount"))
            .setFulfilledAmountLimit(this.buy.getAmount())

        this.sell := new _SellItemOffer(this.item)
            .setEnabled(this.settings("sellItem"))
            .setPrice(this.getSellPrice())
            .setAmount(this.settings("sellAll") ? 0 : this.settings("sellAmount"))

        this.sell.setFulfilledAmount(this.settings("soldAmount"))
            .setFulfilledAmountLimit(this.sell.getAmount())
    }

    instantiateBuyAndSellOffer()
    {
        this.buyOffer := new _CreateBuyItemOffer(this.item)
            .setEnabled(this.settings("createBuyOffer"))
            .setPrice(this.getBuyOfferPrice())
            .setFulfilledAmount(this.settings("createdBuyOfferAmount"))
            .setFulfilledAmountLimit(this.settings("buyOfferCreationLimit") ? this.settings("buyOfferCreationLimitAmount") : 0)

        this.buyOffer.setAmount(this.buyOffer.getOfferCreationAmount())

        this.sellOffer := new _CreateSellItemOffer(this.item)
            .setEnabled(this.settings("createSellOffer"))
            .setPrice(this.getSellOfferPrice())
            .setAmount(this.settings("sellOfferMaximumAmount") ? 0 : this.settings("sellOfferAmount"))
            .setFulfilledAmount(this.settings("createdSellOfferAmount"))
            .setFulfilledAmountLimit(this.settings("sellOfferCreationLimit") ? this.settings("sellOfferCreationLimitAmount") : 0)

        this.sellOffer.setAmount(this.sellOffer.getOfferCreationAmount())
    }

    settings(key)
    {
        return new _MarketItemSettings().get(key, this.item)
    }

    resetProgress()
    {
        this.buy.resetProgress()
        this.sell.resetProgress()
        this.buyOffer.resetProgress()
        this.sellOffer.resetProgress()
    }

    ;#region Getters - Price
    getBuyOfferPrice()
    {
        return this.settings("buyOfferPrice") ? this.settings("buyOfferPrice") : 0
    }

    getSellPrice()
    {
        price :=  this.isProfitByPrice() ? this.settings("sellPrice") : (this.buy.getPrice() + this.getPercentagePrice())

        return price ? price : 0
    }

    getSellOfferPrice()
    {
        price :=  this.isOfferProfitByPrice() ? this.settings("sellOfferPrice") : (this.getBuyOfferPrice() + this.getOfferPercentagePrice())

        return price ? price : 0
    }
    ;#endregion

    ;#region Getters
    getItem()
    {
        return this.item
    }

    getItemName()
    {
        return this.itemName
    }

    getProfit()
    {
        return this.sell.getPrice() - this.buy.getPrice()
    }

    getOfferProfit()
    {
        return this.getSellOfferPrice() - this.getBuyOfferPrice()
    }

    getProfitPercentage()
    {
        return this.settings("sellPercentage")
    }

    getOfferProfitPercentage()
    {
        return this.settings("sellOfferPercentage")
    }

    getPercentagePrice()
    {
        return (this.buy.getPrice() * this.getProfitPercentage()) / 100
    }

    getOfferPercentagePrice()
    {
        return (this.getBuyOfferPrice() * this.getOfferProfitPercentage()) / 100
    }
    ;#endregion

    ;#region Setters
    ;#endregion

    ;#region Predicates
    hasOffersEnabled()
    {
        return this.buy.isEnabled() || this.sell.isEnabled() || this.buyOffer.isEnabled() || this.sellOffer.isEnabled()
    }

    isEnabled()
    {
        return this.settings("enabled")
    }

    isProfitByPrice()
    {
        return this.settings("profitByPrice")
    }

    isProfitByPercentage()
    {
        return this.settings("profitByPercentage")
    }

    isOfferProfitByPrice()
    {
        return this.settings("offerProfitByPrice")
    }

    isOfferProfitByPercentage()
    {
        return this.settings("offerProfitByPercentage")
    }
    ;#endregion
}