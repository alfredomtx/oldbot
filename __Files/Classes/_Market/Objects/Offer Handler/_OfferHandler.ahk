
class _OfferHandler extends _Loggable
{
    static MARKET_FOLDER := "Market"
    static LOGS_FILE := "market_logs.txt"
    static LOGS_PATH := "Market\" _OfferHandler.LOGS_FILE

    __New(offer, type)
    {
        _Validation.instanceOf("offer", offer, _ItemOffer)

        this.offer := offer
        this.type := type
        this.simulation := new _MarketIniSettings().get("simulation")
    }

    /**
    * @return bool
    */
    balanceCondition()
    {
        this.readBalance()

        this.offer.balanceCondition(this.balance)

        return true
    }

    /**
    * @return void
    */
    scanOffer()
    {
        this.scannedOffer := new _ScanOffer(this.offer)
            .setLogger(this.bindLogger())
            .run()
    }

    /**
    * @return void
    */
    readBalance()
    {
        this.balance := new _ReadBalance()
            .setLogger(this.bindLogger())
            .run()
    }

    /**
    * @return void
    */
    clickWithCtrl(coordinate, count := 1)
    {
        Loop, % count {
            coordinate.clickWithModifier("Ctrl")
            sleep(40, 75)
        }
    }

    /**
    * @return string
    */
    class(buy, sell)
    {
        return this.offer.getAreaIdentifier() == "buy" ? new buy() : new sell()
    }

    /**
    * @return BoundFunc
    */
    bindLogger()
    {
        return this.info.bind(this)
    }

    /**
    * @param string reason
    * @return void
    */
    ignoreLog(reason)
    {
        this.info(txt("Ignorado, motivo", "Ignored, reason") ": " reason)
    }

    /**
    * @return void
    */
    info(msg, write := true)
    {
        item := _A.lowerCase(this.offer.getItem())
        type := ucfirst(this.type)
        type := (type = "buy") ? txt("Oferta de Compra", "Buy offer") : txt("Oferta de Venda", "Sell offer")

        _Market.log(type, "[" item "] " msg)

        if (write) {
            FileAppend, % type " | [" item "] " msg "`n", % _OfferHandler.LOGS_PATH
        }
    }

    guardAgainstZeroItems()
    {
        if (this.hasZeroItems()) {
            throw Exception(txt("você não possui nenhum item para venda.", "you do not have any item to sell."), "NoItemsException")
        }
    }


    settings(key, value := "")
    {
        if (value != "") {
            return new _MarketItemSettings().submit(key, value, this.offer.getItem())
        }

        return new _MarketItemSettings().get(key, this.offer.getItem())
    }


    ;#region Predicates
    /**
    * @return void
    * @throws
    */
    shouldIgnoreOffer()
    {
        displayAction := this.offer.getDisplayAction()
        if (!this.offer.isEnabled()) {
            throw Exception(txt(displayAction " do item desativada.", displayAction " item is disabled."), "DisabledException")
        }

        this.offer.enforceActionCooldown()

        if (this.offer.hasAmountBeenFulfilled()) {
            throw Exception(txt("quantidade de " displayAction " desejada(" this.offer.getFulfilledAmountLimit() ") já foi atingida, resete o progresso do item para realizar mais ações de " displayAction ".", "desired " displayAction " amount(" this.offer.getFulfilledAmountLimit() ") has been reached, reset the item progress to perform more " displayAction " actions."), "IgnoreException")
        }

        if (this.noOffersAvailable()) {
            sleep(500)
            if (this.noOffersAvailable()) {
                throw Exception(txt("nenhuma oferta disponível.", "no offers available."), "NoOffersException")
            } else {
                this.info(txt("OFERTAS DISPONÍVEIS NOVAMENTE.", "OFFERS AVAILABLE AGAIN."))
            }
        }
    }

    hasZeroItems()
    {
        return false
        /**
        * TODO: fixme
        */
        return ims("images_market.predicates.zero_items").search().found()
    }

    /**
    * @return bool
    */
    noOffersAvailable()
    {
        return ims("images_market.predicates.no_offers_available", {"area": this.class(_BuyOffersArea, _SellOffersArea).getName(), "cache": false})
            .search()
            .found()
    }
    ;#endregion
}