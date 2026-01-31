
class _AcceptOfferHandler extends _OfferHandler
{
    __New(offer, type)
    {
        base.__New(offer, type)

        pt := "data,item,nome do player,quantidade,preço,preço total,expiração,quantidade aceita,preço aceito,quantidade desejada,preço desejado,balance"
        en := "date,item,player name,amount,price,total price,ends at,accepted amount,accepted price,target amount,target price,balance"

        this.csv := new _Csv(_Csv.PATH(this.CSV_FILE), txt(pt, en))
    }

    /**
    * @return bool
    */
    run()
    {
        try {
            this.shouldIgnoreOffer()
            this.guardAgainstZeroItems()
        } catch e {
            switch (e.What) {
                case "NoItemsException":
                    if (this.offer.getType() == "sell") {
                        this.ignoreLog(e.Message)

                        return false
                    }
                case "DisabledException":
                    return false
                default: 
                    this.ignoreLog(e.Message)

                    return false
            }
        }

        return this.runActionsOrIgnore()
    }

    /**
    * @return bool
    */
    runActionsOrIgnore()
    {
        this.scanOffer()

        try {
            this.offer.rejectOffer(this.scannedOffer.getPrice())

            return this.actOnOffer()
        } catch e {
            this.ignoreLog(e.Message)

            return false
        }
    }

    /**
    * @return bool
    */
    actOnOffer()
    {
        this.balanceCondition()

        this.selectFirstOffer()

        if (!this.beforeAcceptingOffer()) {
            return false
        }

        this.selectAmount()

        this.selectedAmount := this.readSelectedAmount()
        this.validateSelectedAmount()

        this.acceptOffer()

        return true
    }

    readSelectedAmount()
    {
        return new _ReadSelectedAmount(this.class(_BuySelectedAmountArea, _SellSelectedAmountArea))
            .setLogger(this.bindLogger())
            .run()
    }

    beforeAcceptingOffer()
    {
        _Logger.log(A_ThisFunc)

        selectedAmount := this.readSelectedAmount()
        if (selectedAmount == 0) {
            this.info(txt("Não é possível aceitar a oferta, quantidade zero selecionada.", "Can't accept offer, zero amount selected."))
            ; if (!this.simulation) {
            return false
            ; }
        }

        if (!this.canAcceptOffer()) {
            this.info(txt("Não é possivel aceitar a oferta", "Can't accept offer"))
            ; if (!this.simulation) {
            return false
            ; }
        }

        return true
    }

    canAcceptOffer()
    {
        return this.acceptButton().search().found()
    }

    selectFirstOffer()
    {
        _Logger.log(A_ThisFunc)
        position := this.type == "sell" ? _MarketPositions.firstSellOffer() : _MarketPositions.firstBuyOffer()
        position.click()
        sleep(50, 100)
    }

    selectAmount()
    {
        increasePosition := this.type == "buy" ? _MarketPositions.increaseBuyAmount() : _MarketPositions.increaseSellAmount()
        decreasePosition := this.type == "buy" ? _MarketPositions.decreaseBuyAmount() : _MarketPositions.decreaseSellAmount()

            new _SelectAmount(this.offer.getAmount(), decreasePosition, increasePosition, this.scannedOffer.getAmount())
            .setLogger(this.bindLogger())
            .run()
    }

    acceptButton()
    {
        return ims("images_market.buttons.accept.enabled", {"area": this.class(_BuyOffersArea, _SellOffersArea).getName(), "cache": false})
    }

    acceptOffer()
    {
        this.info(txt("Aceitando oferta", "Accepting offer") ".")

        button := this.acceptButton().search()
        if (!this.simulation && button.notFound()) {
            return
        }

        string := _A.upperFirst(this.offer.getDisplayAction()) " " 
        string .= this.selectedAmount " " _Str.quoted(this.offer.getItemName()) " " txt("a", "at") " " this.scannedOffer.getPrice() " gp " txt("cada", "each") 
        string .= ", total: " (this.selectedAmount * this.scannedOffer.getPrice()) " gp."
        this.info(string)

        if (!this.handleUserConfirmation(string)) {
            return
        }

        if (!this.simulation) {
            button.setClickOffsets(10)
            button.click()
        }

        this.handleConfirmationMessage()

        string := txt("Oferta aceita", "Offer accepted") (this.simulation ? txt(" (simulação)", " (simulation)") : "") "."
        this.info(string)

        this.offer.offerFulfilledEvent(this.selectedAmount)

        this.logOffer()
    }

    handleUserConfirmation(string)
    {
        if (new _MarketIniSettings().get("acceptOfferConfirmation")) {
            msg := string "`n`n" txt("Prosseguir e aceitar a oferta?", "Proceed and accept the offer?")
            if (this.simulation) {
                msg .= "`n`n(" txt("modo de simulação está ativado, a oferta não será realmente aceita", "simulation mode is enabled, the offer won't really be accepted") ")"
            }

            Msgbox, 68, % txt("Confirmação", "Confirmation") " - " this.offer.itemName, % msg
            IfMsgBox, No
            {
                this.info(txt("Mensagem de confirmação de oferta rejeitada.", "Offer confirmation message rejected."))
                return false
            }
        }

        return true
    }

    handleConfirmationMessage()
    {
        _Logger.log(A_ThisFunc)

        if (this.simulation) {
            return true
        }

        sleep(100, 200)

        Loop, 5  {
            if (ims("images_market.predicates.confirmation_message").search().found()) {
                Send("Enter")
                sleep(75, 125)

                return true
            }

            sleep, 250

        }

        this.info("WARNING: Confirmation message not found")

        return false
    }

    getNoOffersException()
    {
        return "IgnoreException"
    }

    logOffer()
    {
        ; "item,player_name,amount,price,total_price,ends_at,accepted_amount,accepted_price,target_amount,target_price"
        this.csv.log(this.toCsv())
    }

    /**
    * @abstract
    */
    toCsv()
    {
        return now() "," this.scannedOffer.getItem() "," this.scannedOffer.getPlayerName() "," this.scannedOffer.getAmount() "," this.scannedOffer.getPrice() "," this.scannedOffer.getTotalPrice() "," this.scannedOffer.getEndsAt() "," this.selectedAmount "," this.scannedOffer.getPrice() * this.selectedAmount "," this.offer.getAmount() "," this.offer.getPrice() "," this.balance
    }
}