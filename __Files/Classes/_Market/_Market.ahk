#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Module Functions\_AbstractModuleFunction.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

class _Market extends _AbstractModuleFunction
{
    static IDENTIFIER := "market"
    static DISPLAY_NAME := "Market"
    static MODULE := _MarketModule


    static ANTI_IDLE_MINUTES := 5
    static ITEMS_LIMIT := 10
    static TEMP_IMAGE := A_Temp "\_market_offer.png"

    static ERRORS := {}

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @return void
    */
    run()
    {
        try {
            if (A_IsCompiled && !this.isEnabled()) {
                return
            }

            this.fetchLicense()
            this.openHud()
            this.setInitialLogs()

            if (new _MarketIniSettings().get("autoStart")) {
                this.execute()
            }

            this.updateLogsTimer()
        } catch e {
            this.logException(e, A_ThisFunc)
        }
    }

    /**
    * @return void
    */
    execute()
    {
        this.hud.startButton.disable()
        this.hud.pauseButton.enable()

        if (new _MarketItemCollection().enabled().isEmpty()) {
            this.log("Marketbot", txt("Nenhum item habilitado.", "No items enabled."))
            return
        }

        this.antiIdleTimer := new _Timer()

        Loop, {
            try {
                    new _WaitDisconnected(5000)

                this.openMarket()
                this.checkOffers()
                this.checkAntiIdle()

                sleep(400, 1000)
            } catch e {
                this.logException(e, A_ThisFunc)
            } finally {
                Sleep, 1000
            }
        }
    }

    checkOffers()
    {
        items := new _MarketItemCollection().enabled().items()

        for, _, item in items {
            offer := new _UserOffer(item)
                .setLogger(this.log.bind(this))
                .setExceptionLogger(this.logException.bind(this))

            if (!offer.isEnabled()) {
                continue
            }

            if (this.indexLimit(A_Index)) {
                this.log("Marketbot", txt("Limite de itens ativos atingido:", "Enabled items limit reached: ") " " this.license.items() ".")
                break
            }

            try {
                offer.beforeChecked()
            } catch e {
                this.log("[" offer.itemName "]", e.Message)
                continue
            }

            this.searchItem(offer)

            this.handleOffer(offer.buy)
            this.handleOffer(offer.sell)
            this.handleOffer(offer.buyOffer)
            this.handleOffer(offer.sellOffer)

            offer.afterChecked()

            if (new _MarketIniSettings().get("finishedAllItemsConfirmation")) {
                this.log("Marketbot", txt("Itens finalizados, confirme a mensagem para continuar.", "Items finished, confirm the message to continue."))
                Msgbox, 64, % txt("Confirme para continuar", "Confirm to continue"), % txt("Ações finalizadas para todos os itens.", "Actions finished for all the item.")
            }
        }
    }

    handleOffer(offer)
    {
        this.guardAgainstDisconnected()

        if (!this.isMarketWindowOpen()) {
            this.marketWindowNotFoundException()
        }

        if (offer.isEnabled() && new _MarketIniSettings().get("runActionConfirmation")) {
            action := offer.getDisplayAction()
            this.log("Marketbot", txt("Iniciar ação de " action ", confirme a mensagem para continuar.", "Start " action " action, confirm the message to continue."))
            Msgbox, 64, % txt("Confirme para continuar", "Confirm to continue") " - " offer.itemName, % txt("Iniciar ação de " action " para o item ", "Start " action " action for the item " ) " " _Str.quoted(offer.itemName) "."
        }

        try {
            switch (offer.__Class) {
                case _CreateBuyItemOffer.__Class:
                    handler := new _CreateBuyOfferHandler(offer)
                case _CreateSellItemOffer.__Class:
                    handler := new _CreateSellOfferHandler(offer)
                case _BuyItemOffer.__Class:
                    handler := new _SellOfferHandler(offer)
                case _SellItemOffer.__Class:
                    handler := new _BuyOfferHandler(offer)
                default:
                    throw Exception(txt("Tipo de oferta não suportado: ", "Unsupported offer type: ") offer.__Class)
            }

            handler.setExceptionLogger(this.logException.bind(this))
                .run()
        } catch e {
            this.logException(e, offer.getItemName())
        }
    }

    searchItem(offer)
    {
        item := offer.getItemName()

        searchName := offer.settings("searchUsingAnotherName") ? offer.settings("itemSearchName") : item

        this.log("Marketbot", txt("Procurando item: ", "Searching item: ") _Str.quoted(item))

        Loop, 2 {
            this.guardAgainstDisconnected()
            searchInput := ims("images_market.inputs.searchInput").loopSearch()

            if (searchInput.notFound()) {
                this.log("Marketbot", txt("Limpando campo de busca do item.", "Clearing item search field."))

                button := ims("images_market.buttons.clear_search_input").search()
                if (button.notFound()) {
                    this.handlePossibleConnectionLost()

                    button := ims("images_market.buttons.clear_search_input").search()
                    if (button.notFound()) {
                        throw Exception(txt("Falha ao limpar campo de busca do item.", "Failed to clear item search field."))
                    }
                }

                button.setClickOffsets(4)
                    .click()

                sleep(200, 400)
            }

            searchInput.loopSearch()

            if (searchInput.notFound()) {
                throw Exception(txt("Campo de busca do item não localizado.", "Item search field not found."))
            }

            searchInput.setClickOffsets(4)
                .click()

            sleep(150, 250)

            Send(searchName)
            sleep(500, 700)

            this.selectItemOnList(offer)
            sleep(400, 600)

            if (this.isItemSelected()) {
                return
            }
        }

        throw Exception(txt("Falha ao pesquisar e selecionar o item: ", "Failed to search and select the item: ") _Str.quoted(item))
    }

    selectItemOnList(offer)
    {
        positionOnList := offer.settings("itemPositionOnList")
        coordinate := _MarketPositions.firstItem().clone()

        if (positionOnList > 1) {
            position := positionOnList - 1

            this.log("Marketbot", txt("Selecionando item na lista na posição: ", "Selecting item on the list at position: ") positionOnList)

            coordinate.addY(new _FirstMarketItemArea().getHeight() * position)
        }

        coordinate.click()
    }

    handlePossibleConnectionLost()
    {
        Sleep, 1000
        this.openMarket()
            new _WaitDisconnected(5000)
    }

    checkAntiIdle()
    {
        if (this.antiIdleTimer.minutes() <= this.ANTI_IDLE_MINUTES) {
            return
        }

        this.log(A_ThisFunc, this.antiIdleTimer.minutes() "/" this.ANTI_IDLE_MINUTES " min")

        this.runAntiIdle()
    }

    runAntiIdle()
    {
        this.log(A_ThisFunc)

        this.guardAgainstDisconnected()

        this.antiIdleTimer.reset()

        this.closeMarket()

        ; TODO: anti idle without holding modifier keys
            new _AntiIdle().run()
    }

    closeMarket()
    {
        this.log(A_ThisFunc)

        Loop, 4 {
            Send("Esc")
            sleep(100, 300)
        }
    }

    openMarket()
    {
        if (this.isMarketWindowOpen()) {
            return
        }

        this.openDepot()

        Loop, 3 {
            ims("images_market.others.locker").search().click("Right")
            sleep(500)
            if (this.isMarketWindowOpen()) {
                return
            }
        }

        ; close any window that might be open
        Loop, 3 {
            Send("Esc")
            sleep(75, 150)
        }

        this.marketWindowNotFoundException()
    }

    openDepot()
    {
        this.log("Marketbot", txt("Abrindo depot.", "Opening depot."))

        Loop, 2 {
            Send("Esc") ; close any existing window
            sleep(40, 75)
        }

        if (!new _OpenDepotAroundAction().run()) {
            this.marketWindowNotFoundException()
        }
    }

    indexLimit(index)
    {
        return index > new _MarketbotLicense().items()
    }

    /**
    * @return void
    * @exitApp
    */
    fetchLicense()
    {
        try {
            this.license := new _MarketbotLicense()
        } catch e {
            this.logException(e, identifier := "Failed to get license")
            _Logger.msgboxException(16, e, A_ThisFunc, identifier)
            ExitApp
        }
    }

    /**
    * @return void
    * @exitApp
    */
    openHud()
    {
        try {
            this.hud := new _MarketbotHUD().open(close := false)
        } catch e {
            _Logger.msgboxException(16, e, A_ThisFunc, identifier)
            this.logException(e, identifier := "Failed to open Marketbot HUD")
            ExitApp
        }
    }

    marketWindowNotFoundException()
    {
        throw Exception(txt("Janela do Market não localizada, certifique-se de que o char está ao lado de um depot para que o bot consiga abrir o Market.", "Market window not found, make sure the char is next to a depot so the bot can open the Market."), "MarketWindowNotFoundException")
    }

    log(identifier, msg := "")
    {
        _Logger.log(identifier, msg)

        this.appendLog(identifier " | " msg)
    }

    logException(e, identifier := "Marketbot")
    {
        try {
            disconnected := isDisconnected()
            if (disconnected) {
                e.Message .= " (" txt("Char desconectado", "Character disconnected") ")"
            }
        } catch e {
            _Logger.exception(e, "isDisconnected", "Failed to check if disconnected")
        }

        this.appendLog("[ERROR] " identifier " | " e.message)

        this.pushError(e.Message, identifier)

        try {
            this.pauseOnException(e, disconnected)
        } catch e {
            _Logger.msgboxException(16, e, A_ThisFunc, "Failed to pause on exception")
        }
    }

    pushError(msg, identifier)
    {
        try {
            timestamp := A_Hour ":" A_Min ":" A_Sec
            _Market.ERRORS.Push("[" timestamp "] " identifier " | " msg)
            this.hud.errors.enable()
        } catch e {
            _Logger.exception(e, A_ThisFunc, "Failed to push error")
        }
    }

    appendLog(msg)
    {
        try {
            this.hud.logs.append(msg)
        } catch e {
            _Logger.exception(e, A_ThisFunc, "Failed to append hud logs")
        }
    }

    pauseOnException(e, disconnected)
    {
        switch (e.What) {
            case "MarketWindowNotFoundException":
                return
        }

        if (!new _MarketIniSettings().get("pauseOnError")) {
            return
        }

        if (disconnected) {
            this.log("Pause on error", txt("Char desconectado.", "Character disconnected."))
            return
        }

        this.log("Marketbot", txt("Configuração de ""Pausar em caso de erro"" ativa, pausando Marketbot.", """Pause on error"" setting active, pausing Marketbot."))
        sleep(10000)
        this.hud.pause()
        Pause
    }

    ensureFolderExists()
    {
        folder := _Folders.MARKET_ROOT
        if (!FileExist(folder)) {
            FileCreateDir, % folder
        }

        if (!FileExist(folder)) {
            msgbox, 16, % txt("Erro", "Error"), % txt("Não foi possível criar a pasta do Marketbot.", "Failed to create Marketbot folder.") "`n" A_WorkingDir "\" folder
        }
    }

    setInitialLogs()
    {
        if (new _MarketIniSettings().get("autoStart")) {
            this.hud.logs.set(txt("Iniciando Marketbot...", "Starting Marketbot..."))
        } else {
            this.hud.logs.set(txt("Clique no botão ""Iniciar"" para começar.", "Click the ""Start"" button to begin."))
        }

        this.hud.logs.append("`n" txt("OBS: o seu char precisa estar ao lado de um depot para o bot abrir o Market e funcionar.", "PS: your char needs to be next to a depot for the bot to open the Market and work."))

        if (new _MarketIniSettings().get("simulation")) {
            this.hud.logs.append("[" txt("Modo de simulação", "Simulation mode") "] " txt("O bot não realizará nenhuma ação de fato ao criar/cancelar/aceitar ofertas.", "The bot will not actually perform any action when creating/canceling/accepting offers."))
        }

        hasConfirmation := false
        if (new _MarketIniSettings().get("acceptOfferConfirmation")) {
            this.hud.logs.append("[" txt("Mensagem de confirmação", "Confimation message") "] " txt("O bot exibirá uma mensagem de confirmação ao aceitar ofertas.", "The bot will display a confirmation message when accepting offers."))
            hasConfirmation := true

        }

        if (new _MarketIniSettings().get("createOfferConfirmation")) {
            this.hud.logs.append("[" txt("Mensagem de confirmação", "Confimation message") "] " txt("O bot exibirá uma mensagem de confirmação ao criar ofertas.", "The bot will display a confirmation message when creating offers."))
            hasConfirmation := true

        }

        if (new _MarketIniSettings().get("cancelOfferConfirmation")) {
            this.hud.logs.append("[" txt("Mensagem de confirmação", "Confimation message") "] " txt("O bot exibirá uma mensagem de confirmação ao cancelar ofertas.", "The bot will display a confirmation message when canceling offers."))
            hasConfirmation := true

        }

        if (new _MarketIniSettings().get("finishedItemConfirmation")) {
            this.hud.logs.append("[" txt("Mensagem de confirmação", "Confimation message") "] " txt("O bot exibirá uma mensagem ao finalizar ações de um item.", "The bot will display a message when finishing actions of an item."))
            hasConfirmation := true
        }

        if (new _MarketIniSettings().get("finishedAllItemsConfirmation")) {
            this.hud.logs.append("[" txt("Mensagem de confirmação", "Confimation message") "] " txt("O bot exibirá uma mensagem ao finalizar ações de todos os itens.", "The bot will display a message when finishing actions of all items."))
            hasConfirmation := true
        }

        if (new _MarketIniSettings().get("runActionConfirmation")) {
            this.hud.logs.append("[" txt("Mensagem de confirmação", "Confimation message") "] " txt("O bot exibirá uma mensagem antes de iniciar cada ação para o item.", "The bot will display a message before starting each action for the item."))
            hasConfirmation := true
        }

        if (hasConfirmation) {
            this.hud.logs.append("[" txt("Mensagem de confirmação", "Confimation message") "] " txt("Obs: você pode desativar as mensagens de confirmação nas configurações do Marketbot.", "PS: you can disable the confirmation messages in the Marketbot settings."))
        }
    }

    ;#region Timers
    /**
    * @return void
    */
    updateLogsTimer()
    {
        fn := this.hud.updateLogsSize.bind(this.hud)

        SetTimer, % fn, Delete
        SetTimer, % fn, 10000, -99
    }
    ;#endregion
    ;#region Getters
    ;#endregion

    ;#region Setters
    ;#endregion

    ;#region Predicates
    itemLimitExceeded()
    {
        return new _MarketItemCollection().enabled().count() > new _MarketbotLicense().items()
    }

    isMarketWindowOpen()
    {
        return ims("images_market.window.title").search().found()
    }

    isItemSelected()
    {
        return ims("images_market.predicates.selectedItem").search().found()
    }
    ;#endregion

    ;#region Events
    onPause()
    {
        this.log(A_ThisFunc, "Paused")
    }
    ;#endregion

    ;#region Guards
    guardAgainstDisconnected()
    {
        if (isDisconnected()) {
            throw Exception(txt("Char desconectado", "Char disconnected"))
        }
    }

    guardAgainstItemLimitExceeded()
    {
        license := new _MarketbotLicense()
        allowed := license.items()
        if (_Market.itemLimitExceeded()) {
            msg := txt("O limite de " allowed " itens ativo foi atingido, desative algum(ns) items para continuar.", "The limit of " allowed " active items has been reached, disable some item(s) to continue.")

            if (license.isPremium()) {
            } else {
                msg .= "`n`n" txt("Você pode adquirir uma licença Premium para aumentar o limite de itens ativos.", "You can purchase a Premium license to increase the active items limit.")
            }

            throw Exception(msg)
        }
    }
    ;#endregion
}