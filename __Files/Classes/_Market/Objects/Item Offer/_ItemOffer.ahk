
class _ItemOffer extends _BaseClass
{
    static RATE_LIMIT_INI_FILE := A_Temp "\cd.ini"

    __New(item, type, areaIdentifier)
    {
        this.item := item
        this.itemName := _A.lowerCase(item)
        this.type := type 
        this.areaIdentifier := areaIdentifier 
        this.enabled := true
        this.amount := 0
        this.fulfilledAmount := 0
        this.fulfilledAmountLimit := 0
        this.price := 0
    }

    /**
    * @return void
    * @throws
    */
    enforceActionCooldown()
    {
        return ; disabled for now

        action := this.getActionIdentifier()
        cooldown := new _MarketCooldown(this.item, _MarketCooldown.ACTION_TYPE_COOLDOWN,"last" action "Checked")
        elapsed := cooldown.elapsed()

        if (cooldown.has()) {
            throw Exception("Cooldown " txt("de", "of") " " elapsed "/" cooldown.limit() txt(" minutos para realizar ações de " _Str.quoted(this.getDisplayAction()) " novamente.", " minutes to perform " _Str.quoted(this.getDisplayAction()) " actions again."))
        }
    }

    /**
    * @param int balance
    * @return void
    * @throws
    */
    balanceCondition(balance)
    {
        price := this.getPrice()
        if (balance < price) {
            throw Exception(txt("balance(" balance ") é menor do que o preço da oferta(" price ").", "balance(" balance ") is lower than the offer price(" price ")."))
        }

        type := this.getActionIdentifier()
        if (!this.settings(type "BalanceCondition")) {
            return true
        }

        amount := this.settings(type "BalanceAmount")

        if (amount > 0 && balance < amount) {
            throw Exception(txt("balance(" balance ") é menor do que o valor mínimo de " amount " gp.", "balance(" balance ") is lower than the minimum value of " amount " gp."))
        }
    }

    readFulfilledAmount()
    {
        this.setFulfilledAmount(this.settings(this.getFulfilledAmountKey()))

        return this.getFulfilledAmount()
    }

    writeFulfilledAmount(amount)
    {
        _Validation.number("amount", amount)
        this.setFulfilledAmount(amount)

        this.settings(this.getFulfilledAmountKey(), this.getFulfilledAmount())
    }

    incrementFulfilledAmount(amount)
    {
        currentAmount := this.settings(this.getFulfilledAmountKey())
        _Validation.number("currentAmount", currentAmount)

        this.writeFulfilledAmount(currentAmount + amount)
    }

    incrementAmount(key, amount)
    {
        currentAmount := this.settings(key)
        _Validation.number("currentAmount", currentAmount)

        newAmount := currentAmount + amount
            new _MarketItemSettings().submit(key, newAmount, this.item)

        return newAmount
    }

    offerFulfilledEvent(amount)
    {
        abstractMethod()
    }

    settings(key, value := "")
    {
        if (value != "") {
            return new _MarketItemSettings().submit(key, value, this.item)
        }

        return new _MarketItemSettings().get(key, this.item)
    }

    /**
    * @throws
    */
    updateLastChecked()
    {
        _Ini.write("last" this.getActionIdentifier() "Checked", A_TickCount, this.item, this.RATE_LIMIT_INI_FILE)
    }

    resetProgress()
    {
        abstractMethod()
    }

    /**
    * @abstract
    * @param int price
    * @return void
    * @throws
    */
    rejectOffer(price)
    {
        abstractMethod()
    }

    ;#region Getters
    getActionIdentifier()
    {
        abstractMethod()
    }

    getItem()
    {
        return this.item
    }

    getItemName()
    {
        return this.itemName
    }

    getType()
    {
        return this.type
    }

    getAreaIdentifier()
    {
        return this.areaIdentifier
    }

    getAmount()
    {
        return this.amount
    }

    getFulfilledAmount()
    {
        return this.fulfilledAmount
    }

    getFulfilledAmountLimit()
    {
        return this.fulfilledAmountLimit
    }

    getPrice()
    {
        return this.price
    }

    getDisplayAmount()
    {
        return this.amount == 0 ? txt("todos", "all") : this.amount
    }

    getFulfilledAmountKey()
    {
        abstractMethod()
    }
    ;#endregion


    ;#region Setters
    setAmount(amount)
    {
        _Validation.number("amount", amount)
        this.amount := amount

        return this
    }

    setFulfilledAmount(amount)
    {
        _Validation.number("amount", amount)
        this.fulfilledAmount := amount

        return this
    }

    setFulfilledAmountLimit(amount)
    {
        _Validation.number("amount", amount)
        this.fulfilledAmountLimit := amount

        return this
    }

    setPrice(price)
    {
        _Validation.number("price", price)
        this.price := price

        return this
    }

    setEnabled(enabled)
    {
        _Validation.bool("enabled", enabled)
        this.enabled := enabled

        return this
    }
    ;#endregion

    ;#region Predicates
    isEnabled()
    {
        return this.enabled
    }

    hasAmountBeenFulfilled()
    {
        if (this.getFulfilledAmountLimit() == 0) {
            return false
        }

        return this.getFulfilledAmount() >= this.getFulfilledAmountLimit() 
    }
    ;#endregion
}