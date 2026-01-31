#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Ini\_AbstractIniSettings.ahk

class _MarketItemSettings extends _AbstractIniSettings
{
    static INSTANCE
    static IDENTIFIER := "marketItems"

    static DATA := {}

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        if (_MarketItemSettings.INSTANCE) {
            return _MarketItemSettings.INSTANCE
        }

        base.__New()

        _MarketItemSettings.INSTANCE := this
    }

    getIniPath()
    {
        return new _MarketSettings().profilePath()
    }

    /**
    * @return void
    */
    loadSettings()
    {
        _MarketItemSettings.DATA := ReadINI(this.getIniPath())
        items := this.getObject()

        _Validation.isObject("this.attributes", this.attributes)

        for item, _ in items {
            for key, _ in this.attributes {
                try {
                    this.loadSingleSetting(this.resolveNestedKey(key, item))
                } catch e {
                    if (e.Message == "continue") {
                        continue
                    }

                    throw e
                }
            }
        }
    }

    /**
    * @param string key
    * @return void
    * @throws
    */
    loadSingleSetting(key)
    {
        try {
            value := this.get(key)
        } catch e {
            if (e.What == this.EXCEPTION_NO_SUCH_KEY) {
                throw Exception("continue")
            }

            throw e
        }

        if (empty(value)) {
            throw Exception("continue")
        }

        this.set(key, value)
    }

    /**
    * @param string key
    * @param string section
    */
    read(key, section)
    {
        return _Ini.read(key, section, "", this.getIniPath())
    }

    /**
    * @param string key
    * @param string section
    */
    delete(key, section)
    {
        return _Ini.delete(key, section, this.getIniPath())
    }

    /**
    * @param string key
    * @param mixed value
    * @return void
    */
    write(key, value, section)
    {
        _Ini.write(key, value, section, this.getIniPath())
    }

    /**
    * @return void
    */
    save()
    {
    }

    deleteSection(section, write := true)
    {
        this.getObject().Delete(section)
        if (write) {
            _Ini.deleteSection(section, this.getIniPath())
        }
    }

    ;#region Getters
    /**
    * @param string key
    * @param null|string|function nested
    * @return string
    */
    get(key, nested := "")
    {
        key := this.resolveNestedKey(key, nested)

        return this.getDefaultValue(key)
    }

    /**
    * @param string key - can be json-like nested (e.g. "key1.key2.key3")
    * @return string
    * @throws
    */
    getCurrentValue(key)
    {
        if (!_A.has(this.getObject(), key)) {
            split := _A.split(key, ".")
            return this.read(_A.last(split), _A.first(split))
        }

        return _A.get(this.getObject(), key)
    }

    /**
    * @param string key
    * @return ?string
    */
    getDefaultValue(key)
    {
        value := this.getCurrentValue(key)
        attribute := this.getAttribute(_A.last(_A.split(key, ".")))

        return attribute ? attribute.resolve(value) : value
    }

    /**
    * @return object
    */
    getObject()
    {
        return _MarketItemSettings.DATA
    }

    getKeys()
    {
        return _A.keys(this.getObject())
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _MarketItemSettings.IDENTIFIER
    }
    ;#endregion


    ;#region Setters
    /**
    * Set the value in the object in memory
    * @param string key - can be json-like nested (e.g. "key1.key2.key3")
    * @param mixed value
    * @return void
    */
    set(key, value)
    {
        _A.set(this.getObject(), key, value)
    }

    /**
    * @param string key
    * @param mixed value
    * @return void
    */
    submit(key, value, nested := "")
    {
        dotKey := this.resolveNestedKey(key, nested)
        this.set(dotKey, value)

        this.write(key, value, nested)
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes[i := "enabled"] := new _DefaultBoolean(true, i)

        ;#Region Actions
        this.attributes[i := "buyItem"] := new _DefaultBoolean(false, i)
        this.attributes[i := "sellItem"] := new _DefaultBoolean(false, i)
        this.attributes[i := "createBuyOffer"] := new _DefaultBoolean(true, i)
        this.attributes[i := "createSellOffer"] := new _DefaultBoolean(true, i)

        this.attributes[i := "lastBuyChecked"] := new _DefaultString("", i)
        this.attributes[i := "lastSellChecked"] := new _DefaultString("", i)
        this.attributes[i := "lastBuyOfferChecked"] := new _DefaultString("", i)
        this.attributes[i := "lastSellOfferChecked"] := new _DefaultString("", i)
        ;#Endregion

        ;#Region Price
        this.attributes[i := "buyPrice"] := new _DefaultValue("", "", 1000000000, i)
        this.attributes[i := "buyOfferPrice"] := new _DefaultValue("", "", 1000000000, i)
        this.attributes[i := "noBuyOfferPrice"] := new _DefaultValue("", "", 1000000000, i)
        this.attributes[i := "noSellOfferPrice"] := new _DefaultValue("", "", 1000000000, i)

        this.attributes[i := "sellPrice"] := new _DefaultValue("", "", 1000000000, i)
        this.attributes[i := "sellOfferPrice"] := new _DefaultValue("", "", 1000000000, i)
        ;#Endregion

        ;#Region Amount
        this.attributes[i := "buyAmount"] := new _DefaultValue(1, 1, 9999, i)
        this.attributes[i := "sellAmount"] := new _DefaultValue(1, 1, 9999, i)
        this.attributes[i := "buyOfferCreationLimitAmount"] := new _DefaultValue(1, 1, 9999, i)
        this.attributes[i := "sellOfferCreationLimitAmount"] := new _DefaultValue(1, 1, 9999, i)
        this.attributes[i := "buyBalanceAmount"] := new _DefaultValue("", 0, 999999999, i)

        ; offer
        this.attributes[i := "createAnonymousOffers"] := new _DefaultBoolean(true, i)
        this.attributes[i := "searchUsingAnotherName"] := new _DefaultBoolean(false, i)
        this.attributes[i := "itemSearchName"] := new _DefaultString("", i)

        this.attributes[i := "coverOfferAmount"] := new _DefaultValue(1, 1, 1000000000, i)
        this.attributes[i := "itemUnitAmount"] := new _DefaultValue(1, 1, 100, i)
        this.attributes[i := "itemPositionOnList"] := new _DefaultValue(1, 1, 5, i)

        this.attributes[i := "buyFees"] := new _DefaultValue(0, 0, 100000000000, i)
        this.attributes[i := "sellFees"] := new _DefaultValue(0, 0, 100000000000, i)
        this.attributes[i := "totalFees"] := new _DefaultValue(0, 0, 100000000000, i)
        this.attributes[i := "buyOfferBalanceAmount"] := new _DefaultValue("", 0, 999999999, i)

        this.attributes[i := "buyOfferAmount"] := new _DefaultValue(1, 1, 9999, i)
        this.attributes[i := "buyOfferAmountExclusive"] := new _DefaultValue(1, 1, 9999, i)
        this.attributes[i := "sellOfferAmount"] := new _DefaultValue(1, 1, 9999, i)
        this.attributes[i := "sellOfferAmountExclusive"] := new _DefaultValue(1, 1, 9999, i)

        ; marketbot
        this.attributes[i := "boughtAmount"] := new _DefaultValue(0, 0, 999999999, i)
        this.attributes[i := "soldAmount"] := new _DefaultValue(0, 0, 999999999, i)
        this.attributes[i := "createdBuyOfferAmount"] := new _DefaultValue(0, 0, 999999999, i)
        this.attributes[i := "createdSellOfferAmount"] := new _DefaultValue(0, 0, 999999999, i)
        ;#Endregion

        ;#Region Buy Options
        this.attributes[i := "buyAll"] := new _DefaultBoolean(false, i)
        this.attributes[i := "buyAmountAndStop"] := new _DefaultBoolean(true, i)
        this.attributes[i := "buyOfferCreationLimit"] := new _DefaultBoolean(false, i)
        this.attributes[i := "sellOfferCreationLimit"] := new _DefaultBoolean(false, i)
        this.attributes[i := "buyBalanceCondition"] := new _DefaultBoolean(false, i)

        ; offer
        this.attributes[i := "buyOfferMaximumAmount"] := new _DefaultBoolean(false, i)
        this.attributes[i := "buyOfferDefinedAmount"] := new _DefaultBoolean(true, i)
        this.attributes[i := "buyOfferExclusiveAmount"] := new _DefaultBoolean(false, i)
        this.attributes[i := "buyOfferBalanceCondition"] := new _DefaultBoolean(false, i)

        this.attributes[i := "sellOfferMaximumAmount"] := new _DefaultBoolean(false, i)
        this.attributes[i := "sellOfferDefinedAmount"] := new _DefaultBoolean(true, i)
        this.attributes[i := "sellOfferExclusiveAmount"] := new _DefaultBoolean(false, i)
        ;#Endregion

        ;#Region Sell Options
        ; price
        this.attributes[i := "profitByPrice"] := new _DefaultBoolean(true, i)
        this.attributes[i := "profitByPercentage"] := new _DefaultBoolean(false, i)
        this.attributes[i := "sellPercentage"] := new _DefaultValue(20, 2, 999, i)

        this.attributes[i := "offerProfitByPrice"] := new _DefaultBoolean(true, i)
        this.attributes[i := "offerProfitByPercentage"] := new _DefaultBoolean(false, i)
        this.attributes[i := "sellOfferPercentage"] := new _DefaultValue(20, 2, 999, i)

        ; amount
        this.attributes[i := "sellAll"] := new _DefaultBoolean(true, i)
        this.attributes[i := "sellAmountAndStop"] := new _DefaultBoolean(false, i)
        ;#Endregion

        ;#Region Created Offer
        ; buy
        this.attributes[i := "lastBuyOffer"] := new _DefaultBoolean(false, i)
        this.attributes[i := "lastBuyOfferPrice"] := new _DefaultValue("", 0, 100000000000, i)
        this.attributes[i := "lastBuyOfferTotalPrice"] := new _DefaultValue("", 0, 100000000000, i)
        this.attributes[i := "lastBuyOfferAmount"] := new _DefaultValue("", 1, 9999, i)
        this.attributes[i := "lastBuyOfferEndsAt"] := new _DefaultString("", i)
        ;sell
        this.attributes[i := "lastSellOffer"] := new _DefaultBoolean(false, i)
        this.attributes[i := "lastSellOfferPrice"] := new _DefaultValue("", 0, 100000000000, i)
        this.attributes[i := "lastSellOfferTotalPrice"] := new _DefaultValue("", 0, 100000000000, i)
        this.attributes[i := "lastSellOfferAmount"] := new _DefaultValue("", 1, 9999, i)
        this.attributes[i := "lastSellOfferEndsAt"] := new _DefaultString("", i)
        ;#Endregion

        ;#Region Marketbot
        ;#Endregion
    }
    ;#endregion
}