#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_GUI.ahk

class _MarketbotHUD extends _GUI
{
    static WINDOW_TITLE := "Marketbot HUD"
    static TIMERS_ENABLED := false

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @param ?string title
    */
    __New()
    {
        if (_MarketbotHUD.INSTANCE) {
            return _MarketbotHUD.INSTANCE
        }

        base.__New("marketbotHud", this.resolveTitle())

        if (A_IsCompiled) {
            _MarketbotHUD.TIMERS_ENABLED := true
        }
        ; _MarketbotHUD.TIMERS_ENABLED := true

        this.guiW := 500
        this.textW := 100
        this.editW := 70

        this.paddingLeft := 5
        this.paddingRight := 10

        this.guiButtons := {}


        this.onCreate(this.create.bind(this))
            .y(10).h(325)
            .minHeight(100)
        ; .maxHeight(800)
            .minWidth(this.guiW)
            .maxWidth(this.guiW + 10)
            .alwaysOnTop()
            .noActivate()
            .scrollable()
            .afterCreate(this.setTimers.bind(this))

        ; if (!A_IsCompiled) {
        ;     this.y(A_ScreenHeight - 300)
        ;         .x(A_ScreenWidth - this.guiW - 10)
        ; }

        _MarketbotHUD.INSTANCE := this
    }

    resolveTitle()
    {
        return new _MarketbotLicense().isPremium() ? this.WINDOW_TITLE " (Premium)" : this.WINDOW_TITLE " (FREE)"
    }

    close()
    {
        ExitApp
        msgbox, 64,, % txt("Desative o Marketbot para fechar essa janela.", "Disable Marketbot to close this window.")
        this.open(close := false)
    }

    /**
    * @abstract
    * @return void
    */
    create()
    {
        this.startTime := new _Timer()

        _AbstractControl.SET_DEFAULT_GUI(this)

        this.createControls()
        this.updateLogsSize()

        _AbstractControl.RESET_DEFAULT_GUI()

    }

    handleException(e)
    {
        try {
            this.lastError.set(StrReplace(e.Message, "`n", " "))
        } catch e{
            _Logger.exception(e, A_ThisFunc)
        }
    }


    ;#Region Controls
    /**
    * @return void
    */
    createControls()
    {
        this.mainControls()

        this.buttons()

        this.itemsProgress()
    }

    mainControls()
    {
        w := 95
            new _Text().title("Logs:") 
            .x(this.paddingLeft).y()
            .add()

        this.logs := new _Edit().name("logs")
            .xp().y().w(this.guiW - this.paddingRight).r(10)
            .readOnly()
            .add()

            new _Text().title(txt("Sessão:", "Session:"))
            .xs().y()
            .add()

        this.session := new _Text().title(0)
            .xadd().yp().w(150)
            .add()


        w := 180
        this.fees := new _Button().title(0)
            .x(this.guiW - (w + 5)).yp().w(w).h(20)
            .icon(_Icon.get(_Icon.UNDO), "a1 l1 b1 r5 s14")
            .event(this.resetFees.bind(this))
            .add()
        this.guiButtons.push(this.fees)


        w := 80
        this.errors := new _Button().title(0)
            .x(this.fees.getX() - (w + 5)).yp().w(w).h(20)
            .icon(_Icon.get(_Icon.WARNING), "a1 l1 b1 r5 s14")
            .event(this.openErrors.bind(this))
            .disabled()
            .add()
        this.guiButtons.push(this.errors)
    }

    buttons()
    {
        w := 73
        pl := 2

        this.startButton := new _Button().title("Inici&ar", "St&art")
            .xs().y().w(w)
            .event(_Market.execute.bind(_Market))
            .tt("Iniciar o Marketbot.", "Start the Marketbot.")
            .icon(_Icon.get(_Icon.CHECK_ROUND_WHITE), "a0 l3 b0 t1 s14")
            .keepDisabled()
            .add()
        this.guiButtons.push(this.startButton)

        this.reloadButton := new _Button().title("R&eabrir", "R&eopen")
            .xadd(pl).yp().w(w)
            .icon(_Icon.get(_Icon.RELOAD), "a0 l3 b0 t1 s14")
            .tt("Recarregar(reabrir) o Marketbot.", "Reload(reopen) the Marketbot.")
            .event(this.reload.bind(this))
            .keepDisabled()
            .add()
        this.guiButtons.push(this.reloadButton)

        this.pauseButton := new _Button().title("&" txt("Pausar", "Pause"))
            .xadd(pl).yp().w(w)
            .event(this.pause.bind(this))
            .tt("Pausar o Marketbot.", "Pause Marketbot.")
            .disabled()
            .add()
        this.guiButtons.push(this.pauseButton)

        this.unpauseButton := new _Button().title("Despa&usar", "&Unpause")
            .xadd(pl).yp().w(w)
            .tt("Despausar o Marketbot.", "Unpause Marketbot.")
            .disabled()
            .event(this.unpause.bind(this))
            .keepDisabled()
            .add()
        this.guiButtons.push(this.unpauseButton)

        this.logsButton := new _Button()
            .xadd(pl).yp().w(95)
            .icon(_Icon.get(_Icon.DELETE), "a0 l3 b0 t1 s14")
            .tt("Limpar o arquivo de logs para liberar espaço em disco.", "Clear the logs file to free up disk space.")
            .event(this.deleteLogs.bind(this))
            .disabled()
            .add()
        this.guiButtons.push(this.logsButton)

        this.scannedButton := new _Button().title("Escaneados", "Scanned")
            .xadd(pl).yp().w(93)
            .icon(_Icon.get(_Icon.EYE), "a0 l2 b0 t1 s18")
            .tt(txt("Abrir arquivo CSV de ofertas scaneadas.`nTodas as ofertas que o bot escaneia e analisa são salvas nesse arquivo.", "Open CSV file of scanned offers.`nAll the offers that the bot scans and analyse are in this file.") "`n(" _ScannedOffer.CSV_FILE ")")
            .event(this.openCsvFile.bind(this, _ScannedOffer.CSV_FILE))
            .add()
        this.guiButtons.push(this.scannedButton)
    }

    itemsProgress()
    {
        items := new _MarketItemCollection().enabled().items()

        if (!items.Count()) {
            return
        }

        this.itemX := this.paddingLeft + 10
        this.itemWidth := 120

        this.progressHeight := 18
        this.progressWidth := 80

        this.createColumns()

        index := 1
        for, number, item in new _MarketItemCollection().items() {
            if (!this.setting(item, "enabled")) {
                continue
            }

            if (_Market.indexLimit(index)) {
                break
            }

            this.itemProgress(item, number)
            index++
        }
    }

    createColumns()
    {
        h := 18
        this.boughtColumn := this.itemX + this.itemWidth - 5
        this.soldColumn := this.boughtColumn + this.progressWidth + 5
        this.buyOffersColumn := this.soldColumn + this.progressWidth + 5
        this.sellOffersColumn := this.buyOffersColumn + this.progressWidth + 5

        iconSettings := "a0 l1 b1 s16"

            new _Text().title(txt("Progresso por item", "Progress by item"))
            .xs().yadd(7)
            .option("Section")
            .font("s11")
            .add()

        btn := new _Button().title(txt("Comprado", "Bought")) 
            .x(this.boughtColumn).ys(10).w(this.progressWidth).h(h)
            .center()
            .event(this.openCsvFile.bind(this, _SellOfferHandler.CSV_FILE))
            .tt(txt("Abrir arquivo CSV de itens comprados", "Open CSV file of bought items") "`n(" _SellOfferHandler.CSV_FILE ")")
            .icon(_Icon.get(_Icon.EYE), iconSettings)
            .add()
        this.guiButtons.push(btn)

        btn := new _Button().title(txt("Vendido", "Sold")) 
            .x(this.soldColumn).yp().w(this.progressWidth).h(h)
            .center()
            .event(this.openCsvFile.bind(this, _BuyOfferHandler.CSV_FILE))
            .tt(txt("Abrir arquivo CSV de itens vendidos", "Open CSV file of sold items") "`n(" _BuyOfferHandler.CSV_FILE ")")
            .icon(_Icon.get(_Icon.EYE), iconSettings)
            .add()
        this.guiButtons.push(btn)

        btn := new _Button().title("Buy Offers")
            .x(this.buyOffersColumn).yp().w(this.progressWidth).h(h)
            .center()
            .event(this.openCsvFile.bind(this, _CreateBuyOfferHandler.CSV_FILE))
            .tt(txt("Abrir arquivo CSV de ofertas de compra criadas", "Open CSV file of created buy offers") "`n(" _CreateBuyOfferHandler.CSV_FILE ")")
            .icon(_Icon.get(_Icon.EYE), iconSettings)
            .add()
        this.guiButtons.push(btn)

        btn := new _Button().title("Sell Offers")
            .x(this.sellOffersColumn).yp().w(this.progressWidth).h(h)
            .center()
            .event(this.openCsvFile.bind(this, _CreateSellOfferHandler.CSV_FILE))
            .tt(txt("Abrir arquivo CSV de ofertas de venda criadas", "Open CSV file of created sell offers") "`n(" _CreateSellOfferHandler.CSV_FILE ")")
            .icon(_Icon.get(_Icon.EYE), iconSettings)
            .add()
        this.guiButtons.push(btn)
    }


    itemProgress(item, number)
    {
        this[item] := {}
        itemName := _Str.quoted(_A.lowerCase(item))

        offer := this.cachedOffer(item)

            new _Text().title(number) 
            .x(this.itemX - 11).yadd(5).w(15)
            .font("s7")
            .color("gray")
            .center()
            .add()

        this[item].nameText := new _Text().title(_A.lowerCase(item)) 
            .xadd(3).yp(-1).w(this.itemWidth)
        ; .x(this.itemX).yadd(5).w(this.itemWidth)
            .option("section")
            .add()

        this.cooldownProgress(offer)

        this.progress("boughtProgress", offer.buy, this.boughtColumn)
        this.progress("soldProgress", offer.sell, this.soldColumn, "68e679")
        this.progress("buyOffersProgress", offer.buyOffer, this.buyOffersColumn)
        this.progress("sellOffersProgress", offer.sellOffer, this.sellOffersColumn, "68e679")

        this.resetProgressbutton(this.resetProgress.bind(this, item), offer.sell)
        ; .tt(txt("Resetar progresso de " itemName " vendido.", "Reset sold " itemName " progress."))
            .tt(txt("Resetar progresso do " itemName , "Reset progress of " itemName))

        this.updateProgresses(item)
        fn := this.updateProgresses.bind(this, item)
        ; if (A_IsCompiled) {

        if (_MarketbotHUD.TIMERS_ENABLED) {
            SetTimer, % fn, 1000
        }
        ; }

        return
        fn := this.randomProgresses.bind(this, item)

        ; SetTimer, % fn, 1000
        SetTimer, % fn, -1000
    }

    resetProgressButton(event, itemOffer)
    {
        btn := new _Button()
            .xadd(2).yp(-5).h(22).w(22)
            .icon(_Icon.get(_Icon.UNDO), "a0 l2 b0 s14")
            .event(event)
        ; .disabled(!itemOffer.isEnabled())
            .add()
        this.guiButtons.push(btn)

        return btn
    }

    progress(identifier, offer, x, green := false)
    {
        item := offer.getItem()

        this[item][identifier] := new _Progress()
            .x(x).ys(-1).w(this.progressWidth).h(this.progressHeight)

        if (!offer.isEnabled()) {
            this[item][identifier].option("Backgroundd35b5b")
                .add()

            this.progressText(offer, identifier "Text")

            return
        }

        this[item][identifier].option("Range0-" (offer.getFulfilledAmountLimit() ? offer.getFulfilledAmountLimit() : 100))

        (green) ? this[item][identifier].green() : this[item][identifier].option(_Progress.BACKGROUND)

        this[item][identifier].add()

        this.progressText(offer, identifier "Text")
    }

    cooldownProgress(offer)
    {
        item := offer.getItem()

        this[item].cooldownBar := new _Progress()
            .xs(-1).yp(12).w(this.itemWidth - 15).h(5)
            .option("Range0-" offer.cooldownSeconds())
            .option(_Progress.BACKGROUND)
            .add()

        this.updateCooldownProgress(offer)
    }

    progressText(offer, identifier)
    {
        this[offer.getItem()][identifier] := new _Text()
        ; .title(isEnabled ? "" : txt("Desabilitado", "Disabled"))
        ; .title(offer.isEnabled() ? "" : "❌ " txt("Desabilitado", "Disabled"))
            .title(offer.isEnabled() ? "" : "❌")
            .xp().yp((this.progressHeight / 2) - 6).w(this.progressWidth)
            .option("BackgroundTrans")
            .center()
            .add()
    }
    ;#Endregion

    ;#region Controls Functions
    openCsvFile(fileName)
    {
        try {
            path := _Csv.PATH(fileName)
            Run, % A_WorkingDir "\" path
        } catch e {
            _Logger.msgboxException(e, A_ThisFunc, path)
        }
    }

    openErrors()
    {
        global

        string := _A.join(_Market.ERRORS, "`n")

        Gui, ErrorsGUI:Destroy
        Gui, ErrorsGUI:+AlwaysOnTop -MinimizeBox
        Gui, ErrorsGUI:Add, Edit, vErrorsLog x10 y5 w500 h300 ReadOnly,
        Gui, ErrorsGUI:Show,, Marketbot Errors log 
        GuiControl, ErrorsGUI:, ErrorsLog, % string

    }

    resetFees()
    {
        Msgbox, 68, % txt("Resetar gastos com taxas", "Reset fees"), % txt("Deseja realmente resetar a informação dos gastos com taxas?", "Do you really want to reset the fees information?")
        ifMsgbox, No
        {
            return
        }

        for, _, item in new _MarketItemCollection().items() {
                new _MarketItemSettings().submit("totalFees", 0, item)
        }

        this.updateFees()
    }

    updateLogsSize()
    {
        try {
            size := this.getLogsSize()
            this.logsButton.set("Logs (" size " MB)")
            if (size > 0) {
                this.logsButton.enable()
            }
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }
    }

    getLogsSize()
    {
        try {
            FileGetSize, size, % _OfferHandler.LOGS_PATH, M

            ; size := Format("{:0.2f}", size / 1000)
        } catch {
            size := 0
        }

        return size
    }

    deleteLogs()
    {
        try {
            FileDelete, % _OfferHandler.LOGS_PATH
        } catch {
        }

        this.logs.set("LOGS CLEARED")

        this.updateLogsSize()
    }

    resetProgress(item)
    {
        itemName := _Str.quoted(_A.lowerCase(item))
        msgbox, 52, % txt("Resetar contagem do item", "Reset item count"), % txt("Deseja realmente resetar a contagem de ofertas do item " itemName "?`n`nAo resetar a contagem, o bot realizará novas compras/vendas caso disponível.", "Do you really want to reset the offer count of the item " itemName "?`n`nBy resetting the count, the bot will perform new purchases/sales if available.")
        IfMsgBox, yes
        {

            offer := this.cachedOffer(item)
            offer.resetProgress()

            this.updateProgresses(item)
        }
    }

    progressTextTitle(item, currentAmount, totalAmount, allText := "")
    {
        totalText := totalAmount == 0 ? (allText ? allText : txt("todos", "all")) : totalAmount

        return currentAmount " " txt("de", "of") " " totalText
    }

    updateProgresses(item)
    {
        offer := this.cachedOffer(item)

        this.updateProgressControl("boughtProgress", offer.buy)
        this.updateProgressControl("soldProgress", offer.sell)
        this.updateProgressControl("buyOffersProgress", offer.buyOffer, "♾️")
        this.updateProgressControl("sellOffersProgress", offer.sellOffer, "♾️")
    }

    updateCooldownProgress(offer)
    {
        item := offer.getItem()

        cooldown := offer.cooldownSeconds()
        elapsed := offer.elapsedCooldownSeconds()
        elapsed := elapsed < 0 ? 0 : elapsed

        text:= txt("Cooldown do item: ", "Item cooldown: ") elapsed "/" cooldown " " txt("segundos", "seconds")
        this[item].cooldownBar.set(elapsed > cooldown ? cooldown : elapsed)
            .resetTooltip()
            .tt(text)

        this[item].nameText.resetTooltip()
            .tt(text)
    }

    updateProgressControl(progressBarName, offer, allText := "")
    {
        item := offer.getItem()
        if (!offer.isEnabled()) {
            this[item][progressBarName].resetTooltip()
            this[item][progressBarName].tt(txt("Ação de " offer.getDisplayAction() " desabilitada para esse item.", "Action of " offer.getDisplayAction() " disabled for this item."))
            return
        }

        fulfilled := offer.readFulfilledAmount()
        fulfillLimit := offer.getFulfilledAmountLimit()
        if (fulfillLimit > 0) {
            this[item][progressBarName].set(fulfilled)
        }

        text := this.progressTextTitle(offer.getItem(), fulfilled, fulfillLimit, allText)
        this[item][progressBarName "Text"].set(text)

        if (fulfilled == fulfillLimit && fulfillLimit > 0) {
            tooltipText := txt("Limite atingido, o bot não irá mais realizar ações de " offer.getDisplayAction() " para esse item.`nResete o progresso do item caso queira que o bot realize as ações novamente.", "Limit reached, the bot will no longer perform " offer.getDisplayAction() " actions for this item.`nReset the item progress if you want the bot to perform the actions again.")
            this[item][progressBarName].resetTooltip()
            this[item][progressBarName].tt(tooltipText)
        }

        if (fulfillLimit == 0) {
            tooltipText := txt("O bot já realizou a ação de " offer.getDisplayAction() " " fulfilled " vez(es), não há limite de vezes configurado para esse item.", "The bot has already performed the " offer.getDisplayAction() " action " fulfilled " time(s), there is no limit set for this item.")
            this[item][progressBarName].resetTooltip()
            this[item][progressBarName].tt(tooltipText)
        } else {
            tooltipText := txt("O bot já realizou a ação de " offer.getDisplayAction() " " fulfilled " vez(es), o limite é de " fulfillLimit " vezes.`nSerá necessário resetar o progresso do item quando o limite for atingido caso queira que novas ações de " offer.getDisplayAction() " sejam feitas.", "The bot has already performed the " offer.getDisplayAction() " action " fulfilled " time(s), the limit is " fulfillLimit " times.`nYou will need to reset the item progress when the limit is reached if you want new " offer.getDisplayAction() " actions to be performed.")
            this[item][progressBarName].resetTooltip()
            this[item][progressBarName].tt(tooltipText)
        }
    }

    cachedOffer(item)
    {
        static offers := {}
        if (offers[item]) {
            return offers[item]
        }

        offers[item] := new _UserOffer(item)

        return offers[item]
    }

    randomProgresses(item)
    {
        offer := this.cachedOffer(item)
        if (offer.buy.isEnabled()) {
            this.setRandomFulfilledAmount(offer.buy)
        }

        if (offer.sell.isEnabled()) {
            this.setRandomFulfilledAmount(offer.sell)
        }

        if (offer.buyOffer.isEnabled()) {
            this.setRandomFulfilledAmount(offer.buyOffer)
        }

        if (offer.sellOffer.isEnabled()) {
            this.setRandomFulfilledAmount(offer.sellOffer)
        }

        this.updateProgresses(item)
    }

    setRandomFulfilledAmount(offer)
    {
        offer.writeFulfilledAmount(random(1, offer.getFulfilledAmountLimit() == 0 ? 100 : offer.getFulfilledAmountLimit()))
    }
    ;#Endregion

    setting(item, key)
    {
        return new _MarketItemSettings().get(key, item)
    }

    /**
    * @return void
    */
    onPause()
    {
        this.unpauseButton.enable()
        this.pauseButton.disable()
        this.logs.append("PAUSING")
        this.show(this.WINDOW_TITLE " - PAUSED")
    }

    /**
    * @return void
    */
    pause()
    {
        this.onPause()
        Pause
    }

    /**
    * @return void
    */
    onUnpause()
    {
        this.unpauseButton.disable()
        this.show(this.resolveTitle())
    }

    /**
    * @return void
    */
    unpause()
    {
        this.logs.append("UNPAUSING")
        if (A_IsPaused) {
            Pause, Off
            this.onUnpause()
        }
    }

    /**
    * @return void
    */
    reload()
    {
        Critical, On
        this.logs.append("RELOADING...")

        for _, button in this.guiButtons {
            button.disable()
        }

        Reload
        Pause
        Sleep, 30000
    }

    ;#Region Timers
    timer()
    {
        try {
            this.updateSession()
            this.updateErrors()
        } catch e {
            this.handleException(e)
        }
    }

    updateFees()
    {
        try {
            fees := 0
            tooltipText := txt("Gastos com taxas de criação de ofertas.`n`n", "Expenses with offer creation fees.`n`n")
            for, _, item in new _MarketItemCollection().enabled().items() {
                fees += this.setting(item, "totalFees")
                tooltipText .= _A.lowerCase(item) ": " this.setting(item, "totalFees") " gp`n"
            }

            this.fees.set(txt("Gastos em taxa:", "Fee expenses:") " " fees " gp")
            this.fees.resetTooltip()
            this.fees.tt(tooltipText)
        } catch e {
            this.handleException(e)
        }
    }

    updateCooldowns()
    {
        try {
            for, _, item in new _MarketItemCollection().enabled().items() {
                this.updateCooldownProgress(this.cachedOffer(item))
            }
        } catch e {
            this.handleException(e)
        }
    }

    updateErrors()
    {
        this.errors.set(txt("Erros:", "Errors:") " " _Market.ERRORS.Count())
    }

    updateSession()
    {
        hours := Format("{:0.0f}", Floor(this.startTime.hours()))
        minutes := Floor(this.startTime.minutes()) - (hours * 60)
        minutes := Format("{:0.0f}", minutes)
        seconds := Floor(this.startTime.seconds()) - (minutes * 60)
        seconds := Format("{:0.0f}", seconds)

        this.session.set(hours " h, " minutes " min, " seconds " sec")
    }
    ;#Endregion

    ;#region Getters
    ;#endregion

    ;#region Setters
    setTimers()
    {
        if (!_MarketbotHUD.TIMERS_ENABLED) {
            return
        }

        this.timers := {}

        fn := this.timer.bind(this)
        this.addTimer(fn, 1000)

        fn := this.updateFees.bind(this)
        this.addTimer(fn, 5000)

        fn := this.updateCooldowns.bind(this)
        this.addTimer(fn, 2000)
    }

    addTimer(fn, interval, priority := "")
    {
        fn.Call()
        this.timers.Push(fn)

        SetTimer, % fn, Delete
        if (priority) {
            SetTimer, % fn, % interval, % priority
        } else {
            SetTimer, % fn, % interval
        }
    }
    ;#endregion
}