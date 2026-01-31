
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\_MarketAction.ahk

class _CancelOffer extends _MarketAction
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return void
    */
    run()
    {
        this.log(txt("Cancelando ", "Canceling ") this.offer.getDisplayAction() )
        this.myOffers()
        this.marketButton()

        try {
            if (this.hasNoOffers()) {
                this.log(txt("Não há oferta de " this.offer.getDisplayAction() " criada.", "There is no " this.offer.getDisplayAction() " offer created."))
                return
            }

            itemRow := this.selectOffer()
            this.cancel(itemRow)
        } finally {
            Send("Esc") ; go back to market
        }
    }

    selectOffer()
    {
        t1 := new _Timer()
        this.log(txt("Localizando oferta do item nas suas ofertas...", "Locating item offer in your offers..."))

        itemRow := this.findItemRow(t1)

        elapsed := "(" lang("elapsed", false) ": " t1.seconds() " sec)."
        if (!itemRow) {
            this.offer.deleteCreated()

            throw Exception(txt("Falha ao encontrar oferta do item nas suas ofertas", "Failed to find item offer in your offers") " " elapsed)
        }

        this.itemFound(itemRow, elapsed)

        this.log(lang("elapsed") ": " t1.seconds() " sec.")

        return itemRow
    }

    /**
    * @return _AbstractMyOffersItemNameArea
    */
    offersArea()
    {
        return this.offer.getType() == "buy" ? new _MyOffersBuyItemNameArea() : new _MyOffersSellItemNameArea()
    }

    /**
    * @return bool
    */
    hasNoOffers()
    {
        return ims("images_market.predicates.no_created_offers." this.offer.getType())
            .search()
            .found()
    }

    findItemRow(t1)
    {
        offers := new _ReadText(this.offersArea())
            .withBreaklines(true)
            .run()

        if (!InStr(offers, this.offer.getItemName())) {
            elapsed := "(" lang("elapsed", false) ": " t1.seconds() " sec)"

            throw Exception(txt("Oferta do item não encontrada nas suas ofertas.", "Item offer not found in your offers.") " " elapsed, "OfferNotFoundException")
        }

        _Logger.info(A_ThisFunc, "offers", offers)

        rows := _A.filter(StrSplit(offers, "`n"))

        itemRow := {}
        for index, itemName in rows
        {
            if (InStr(itemName, this.offer.getItemName())) {
                itemRow.push(index)
            }
        }

        if (itemRow.Count() > 1) {
            throw Exception(_A.upperFirst(this.offer.getDisplayAction()) ": " txt("Item encontrado mais de uma vez nas suas ofertas, é necessário ter somente 1 oferta do item para o bot cancelar. Cancele as ofertas excedentes manualmente.", "Item found more than once in your offers, it is necessary to have only 1 offer of the item for the bot to cancel. Cancel the excess offers manually."), "MultipleOffersException")
        }

        return _A.first(itemRow)
    }

    itemFound(itemRow, elapsed)
    {
        this.log(txt("Oferta do item encontrada na linha ", "Item offer found in row ") itemRow " " elapsed)

        area := this.offersArea()
        coordinate := new _Coordinate(area.getC1().getX(), area.getC1().getY())
            .addX(10)
            .addY(_AbstractRowArea.ROW_HEIGHT * itemRow)
            .subY(_AbstractRowArea.ROW_HEIGHT / 2)

        Loop, 2 {
            coordinate.click()
            sleep(50, 100)
        }
    }

    cancel(itemRow)
    {
        button := this.cancelOfferButton()

        displayAction := txt("Cancelar", "Cancel") " " this.offer.getDisplayAction()
        string := displayAction " " txt("na linha", "in the row") " " itemRow ".`n" txt("Oferta de ", "Offer of ")
        string .= this.offer.getLastCreatedAmount() "(original) " _Str.quoted(this.offer.getItemName()) " " txt("a", "at") " " this.offer.getLastCreatedPrice() " gp " txt("cada", "each") 
        string .= ", " txt("expiração", "expiration") ": " this.offer.getLastCreatedEndsAt()
        this.log(string)

        if (!this.handleUserConfirmation(string)) {
            return
        }

        if (!this.simulation) {
            button.setClickOffsets(10)
            button.click()
        }

        try {
            this.handleConfirmationMessage()

            string := txt("Oferta cancelada", "Offer canceled") (this.simulation ? txt(" (simulação)", " (simulation)") : "") "."
            this.log(string)
        } finally {
            this.offer.deleteCreated()
        }

    }

    /**
    * @return void
    * @throws
    */
    handleConfirmationMessage()
    {
        _Logger.log(A_ThisFunc)

        if (this.simulation) {
            return
        }

        sleep(200, 300)

        if (isWideMarket()) {
            ; rubinot does not have confirmation message
            sleep(250, 350)

            this.searchAndClickOkButton()

            return
        }

        Loop, 5 {
            if (ims("images_market.predicates.offer_cancelled").search().found()) {
                Send("Enter")
                sleep(200, 300)

                return
            }

            sleep, 100
        }

        msg := txt("Mensagem de confirmação não localizada", "Confirmation message not found")
        t := clientIdentifier()
        if (clientIdentifier() == "taleon") {
            throw Exception(msg)
        } else {
            this.log(msg)
        }
    }

    handleUserConfirmation(string)
    {
        if (new _MarketIniSettings().get("cancelOfferConfirmation")) {
            msg := string "`n`n" txt("Prosseguir e cancelar a oferta?", "Proceed and cancel the offer?")
            if (this.simulation) {
                msg .= "`n`n(" txt("modo de simulação está ativado, a oferta não será realmente cancelada", "simulation mode is enabled, the offer won't really be canceled") ")"
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

    zeroCreatedOffers(type)
    {
        _search := ims("images_market.predicates.zero_created_" type "_offers")
        if (_search.search().found()) {
            return true
        }
    }

    myOffers()
    {
        _search := ims("images_market.buttons.my_offers").search()
        if (_search.notFound()) {
            throw Exception("Botão ""My offers"" não encontrado.", """My offers"" button not found.")
        }

        _search.click()
        sleep(300, 500)
    }

    marketButton()
    {
        _search := ims("images_market.buttons.market").search()
        if (_search.notFound()) {
            throw Exception("Botão ""Market"" não encontrado.", """Market"" button not found.")
        }

        return _search
    }

    cancelOfferButton()
    {
        area := this.offer.type == "buy" ? _MyOffersCancelBuyButtonArea.NAME : _MyOffersCancelSellButtonArea.NAME
        _search := ims("images_market.buttons.cancel_offer.enabled", {"area": area, "cache": false})
            .loopSearch()

        if (_search.notFound()) {
            throw Exception("Botão ""Cancel offer"" não encontrado.", """Cancel offer"" button not found.")
        }

        return _search
    }

    ;#region Getters
    ;#endregion

    ;#region Setters
    ;#endregion

    ;#region Predicates
    ;#endregion

    ;#region Factory
    ;#endregion
}