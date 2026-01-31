#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\_MarketAction.ahk

class _CreateOffer extends _MarketAction
{
    static MINIMUM_MARKET_FEE := 20
    static MAXIMUM_MARKET_FEE := 1000000
    static MARKET_FEE := "0.02"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return true
    * @throws
    */
    run()
    {
        this.priceValidations()

        this.log(txt("Criando oferta com preço de: ", "Creating offer with price of: ") this.price ".")

        this.resetPriceAndAmount()

        this.selectRadio(this.offer.getType())

        try {
            this.inputPrice()
            this.selectAmount()
            this.selectAnonymous()
        } catch e {
            this.resetPriceAndAmount()

            switch (e.What) {
                case "AmountValidationException":
                    throw e ; throw to log as ignored
            }

            this.logException(e, this.offer.getItemName())

            throw e
        }

        this.createOffer()
        this.offerCreated()
    }

    /**
    * @return void
    * @throws
    */
    priceValidations()
    {
        if (!this.price) {
            throw Exception("o preço da oferta deve ser maior do que 0.", "the offer price must be greater than 0.")
        }

        _Validation.number("this.price", this.price)
    }

    /**
    * @param string type
    * @return void
    * @throws
    */
    selectRadio(type)
    {
        checked := ims("images_market.inputs.radio." type)
        if (checked.loopSearch().found()) {
            return
        }

        position := (type == "buy") ? _MarketPositions.buyRadioButton() : _MarketPositions.sellRadioButton()

        position.click()
        sleep(100, 200)

        if (checked.loopSearch().notFound()) {
            string := _Str.quoted(_A.upperFirst(type))
            throw Exception("Falha ao selecionar o radio " string ".", "Failed to select the " string " radio.")
        }
    }

    /**
    * @return void
    * @throws
    */
    selectAnonymous()
    {
        if (!this.settings("createAnonymousOffers")) {
            this.log(txt("Opção de criar oferta como ""Anonymous"" está desativada.", "Option to create offer as ""Anonymous"" is disabled."))
            return
        }

            new _CheckboxCheck("images_market.inputs.checkbox.anonymous.checked", "images_market.inputs.checkbox.anonymous.unchecked")
            .setLogger(this.logger)
            .run()
    }

    /**
    * @return void
    */
    inputPrice()
    {
        this.log(txt("Preenchendo o preço da oferta.", "Filling the offer price."))

        _MarketPositions.piecePriceInput().click()
        sleep(50, 100)

        Send(this.price)
        sleep(50, 100)

        _Market.selectItemOnList(this.offer)
        sleep(50, 100)

        this.validatePiecePrice()

        this.selectedAmount := this.readSelectedAmount()
        if (this.selectedAmount == 0) {
            throw Exception(txt("A quantidade selecionada é 0.", "The selected amount is 0."))
        }
    }

    /**
    * @return void
    */
    selectAmount()
    {
        action := new _SelectAmount(this.offer.getAmount(), _MarketPositions.decreaseCreateOfferAmount(), _MarketPositions.increaseCreateOfferAmount())
            .setLogger(this.logger)

        itemUnitAmount := this.offer.settings("itemUnitAmount")
        if (itemUnitAmount > 1) {
            action.setUnitAmount(itemUnitAmount)
        }

        action.run()

        this.selectedAmount := this.readSelectedAmount()

        this.offer.validateSelectedAmount(this.selectedAmount)
    }

    readSelectedAmount()
    {
        return new _ReadSelectedAmount(new _CreateOfferSelectedAmountArea())
            .setLogger(this.logger)
        ; .debug()
            .run()
    }

    /**
    * @return void
    * @throws
    */
    createOffer()
    {
        this.log(txt("Criando oferta.", "Creating offer."))
        createOffer := ims("images_market.buttons.create_offer").search()
        if (createOffer.notFound()) {
            throw Exception("Botão ""Create"" não encontrado.", """Create"" button not found.")
        }

        this.totalPrice := this.selectedAmount * this.price
        this.fee := this.calculateMarketFee(this.totalPrice)

        displayAction := _A.upperFirst(this.offer.getDisplayAction())
        string := this.buildLogString(displayAction)
        this.log(string)

        if (!this.handleUserConfirmation(string)) {
            return
        }

        if (!this.simulation) {
            createOffer.click()
            sleep(300, 500)
        }

        loop, 3 {
            try {
                e := ""
                this.validateOfferWasCreated()
                sleep(200, 300)
                break
            } catch e {
                sleep(300, 500)
            }
        }

        if (e) {
            throw e
        }

        string := displayAction " " txt("criada", "accepted") (this.simulation ? txt(" (simulação)", " (simulation)") : "") "."
        this.log(string)
    }

    buildLogString(displayAction)
    {
        string := displayAction " " txt("de", "of") "  " 
        string .= this.selectedAmount " " _Str.quoted(this.offer.getItemName()) " " txt("a", "at") " " this.price " gp " txt("cada", "each") 
        string .= ", total: " this.totalPrice " gp, " txt("taxa do market:", "market fee:") " " this.fee " gp."

        return string
    }

    /**
    * @return void
    */
    offerCreated()
    {
        try {
            this.offer.offerFulfilledEvent(1)

            if (this.simulation) {
                this.endsAt := txt("simulação", "simulation")
            } else {
                this.endsAt := _ReadText.ENDS_AT(this.offer.type)
            }
        } catch e {
            this.log("ERROR: " e.Message)
        }

        this.offer.incrementAmount(this.offer.type == "buy" ? "buyFees" : "sellFees", this.fee)
        this.offer.incrementAmount("totalFees", this.fee)

        this.offer.setLastCreated(true)
        this.offer.setLastCreatedEndsAt(this.endsAt)
        this.offer.setLastCreatedAmount(this.selectedAmount)
        this.offer.setLastCreatedPrice(this.price)

        try {
            this.balance := new _ReadBalance()
                .setLogger(this.logger)
                .run()
        } catch e {
            this.log("ERROR: " e.Message)
            this.balance := "ERROR"
        }

        this.csv.log(this.toCsv())
    }

    calculateMarketFee(totalPrice)
    {
        fee := Ceil(Round(totalPrice * this.MARKET_FEE, 2))
        if (fee < this.MINIMUM_MARKET_FEE) {
            return this.MINIMUM_MARKET_FEE
        }

        if (fee > this.MAXIMUM_MARKET_FEE) {
            return this.MAXIMUM_MARKET_FEE
        }

        return  fee
    }

    handleUserConfirmation(string)
    {
        if (new _MarketIniSettings().get("createOfferConfirmation")) {
            msg := string "`n`n" txt("Prosseguir e criar a oferta?", "Proceed and create the offer?")
            if (this.simulation) {
                msg .= "`n`n(" txt("modo de simulação está ativado, a oferta não será realmente criada", "simulation mode is enabled, the offer won't really be created") ")"
            }

            Msgbox, 68, % txt("Confirmação", "Confirmation") " - " this.offer.itemName, % msg
            IfMsgBox, No
            {
                this.log(txt("Mensagem de confirmação para criar " this.offer.getDisplayAction() " rejeitada.", "Confirmation message to create " this.offer.getDisplayAction() " rejected."))

                return false
            }
        }

        return true
    }

    /**
    * @return void
    */
    resetPriceAndAmount()
    {
        this.selectRadio("buy")
        this.selectRadio("sell")
    }

    toCsv()
    {
        return now() "," _Str.quoted(this.offer.itemName) "," this.selectedAmount "," this.price "," this.totalPrice "," _Str.quoted(this.endsAt) "," this.fee "," this.settings("totalFees") "," this.balance
    }

    ;#Region Validations
    /**
    * @return void
    * @throws
    */
    validateOfferWasCreated()
    {
        if (this.simulation) {
            return
        }

        this.searchAndClickOkButton()

        if (ims("images_market.buttons.create_offer").search().found()) {
            throw Exception("Falha ao criar a oferta, botão ""create offer"" localizado.", "Failed to create the offer, ""create offer"" button found.")
        }
    }

    /**
    * @return void
    * @throws
    */
    validatePiecePrice()
    {
        price := new _ReadInteger(new _PiecePriceArea())
        ; .debug()
            .run()

        if (price != this.price) {
            throw Exception("O preço preenchido pelo bot é inválido, esperado: " this.price ", encontrado: " price, "The price filled by the bot is invalid, expected: " this.price ", found: " price)
        }
    }
    ;#Endregion

    ;#Region Setters
    setPrice(price)
    {
        _Validation.number("price", price)
        this.price := price

        return this
    }

    setCsv(csv)
    {
        _Validation.instanceOf("csv", csv, _Csv)
        this.csv := csv
        return this
    }
    ;#Endregion
}