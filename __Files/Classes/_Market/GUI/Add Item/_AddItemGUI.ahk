#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_GUI.ahk

class _AddItemGUI extends _GUI
{
    static INSTANCE
    static TOTAL_STEPS := 8
    static CURRENT_STEP := 1

    static STEP_ITEM := 1
    static STEP_ACTIONS := 2
    static STEP_BUY := 3
    static STEP_SELL := 4
    static STEP_BUY_OFFER := 5
    static STEP_SELL_OFFER := 6
    static STEP_ADVANCED := 7
    static STEP_SUMMARY := 8

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(item := "", step := "")
    {
        base.__New("addItem")

        if (item) {
            this.setItemName(item)
            this.CURRENT_STEP := step ? step : this.STEP_ACTIONS
        }

            new _MemorySettings().set("item", item)

        this.setTitle()

        this.guiW := 350
        this.guiH := 250
        this.textW := 100

        this.buttonsH := 30

        this.paddingLeft := 10
        this.paddingRight := 20

        this.priceWidth := 60
        this.amountWidth := 40

        this.onCreate(this.create.bind(this))
            .y(10).w(this.guiW)
        ; .h(this.guiH)
            .withoutMinimizeButton()
            .alwaysOnTop()
            .withoutWindowButtons()
    }

    #Include __Files\Classes\_Market\GUI\Add Item\step1.ahk
    #Include __Files\Classes\_Market\GUI\Add Item\step2.ahk
    #Include __Files\Classes\_Market\GUI\Add Item\step3.ahk
    #Include __Files\Classes\_Market\GUI\Add Item\step4.ahk
    #Include __Files\Classes\_Market\GUI\Add Item\step5.ahk
    #Include __Files\Classes\_Market\GUI\Add Item\step6.ahk
    #Include __Files\Classes\_Market\GUI\Add Item\step7.ahk
    #Include __Files\Classes\_Market\GUI\Add Item\step8.ahk

    ;#region GUI
    /**
    * @abstract
    * @return void
    */
    create()
    {
        _AbstractControl.SET_DEFAULT_GUI(this)
        _AbstractStatefulControl.SET_DEFAULT_STATE(_MarketItemSettings)

        this.createControls()

        _AbstractControl.RESET_DEFAULT_GUI()
        _AbstractStatefulControl.RESET_DEFAULT_STATE()
    }

    timer()
    {
    }

    /**
    * @return void
    */
    createControls()
    {
        this.formButtons := {}

        this.progressControls()

        this["step" this.CURRENT_STEP]()
    }
    ;#Endregion

    setTitle()
    {
        this.title(this.itemName ? "Item: " _A.lowerCase(this.itemName) : txt("Adicionar", "Add") " item")
    }

    setItemName(name)
    {
        this.itemName := _A.snakeCase(_A.lowerCase(name))
    }

    finish()
    {
        this.close()
        this.refreshItemList()
    }

    /**
    * @param int current
    * @return void
    */
    updateProgress()
    {
        this.progressBar.setProgress(this.CURRENT_STEP)
        this.progress.set(txt("Passo " this.CURRENT_STEP " de " this.TOTAL_STEPS, "Step " this.CURRENT_STEP " of " this.TOTAL_STEPS))
    }

    itemSetting(key)
    {
        return new _MarketItemSettings().get(key, this.itemName)
    }

    changeFormButtons(action)
    {
        for _, button in this.formButtons {
            try {
                button[action]()
            } catch {
                ; _Logger.msgboxExceptionOnLocal(e, action)
            }
        }
    }

    refreshItemList()
    {
            new _MarketbotGUI().refreshItemList()
    }

    loadItemList()
    {
            new _MarketbotGUI().loadItemList()
    }

    balanceValidation(type)
    {
        this[type "BalanceError"].hide()

        if (this.itemSetting(type "BalanceCondition") && this.itemSetting(type "BalanceAmount") <= 0) {
            this[type "BalanceError"].set(txt("Preencha o valor do balance.", "Fill the balance price.")).show()
            return false
        }

        return true
    }

    afterOpenStep()
    {
        Sleep, 300

        try {
            this.nextBtn.enable()
        } catch {
        }

        try {
            this.backBtn.enable()
        } catch {
        }
    }

    afterStepChangedEvent()
    {
        if (this["afterOpenStep" this.CURRENT_STEP]) {
            this["afterOpenStep" this.CURRENT_STEP]()
        } else {
            this.afterOpenStep()
        }

        this.loadItemList()
    }

    ;#Region Stepper
    nextStep()
    {
        if (this["validateStep" this.CURRENT_STEP] && !this["validateStep" this.CURRENT_STEP]()) {
            return
        }

        switch (this.CURRENT_STEP) {        
            case this.STEP_ITEM:
                this.setItemName(this.item.get())
                this.setTitle()
        }

        if (this.CURRENT_STEP == this.TOTAL_STEPS) {
            return
        }

        this.CURRENT_STEP++ 

        if (this.CURRENT_STEP == this.STEP_BUY && !this.itemSetting("buyItem")) {
            this.CURRENT_STEP++ 
        }

        if (this.CURRENT_STEP == this.STEP_SELL && !this.itemSetting("sellItem")) {
            this.CURRENT_STEP++ 
        }

        if (this.CURRENT_STEP == this.STEP_BUY_OFFER && !this.itemSetting("createBuyOffer")) {
            this.CURRENT_STEP++ 
        }

        if (this.CURRENT_STEP == this.STEP_SELL_OFFER && !this.itemSetting("createSellOffer")) {
            this.CURRENT_STEP++ 
        }

        if (GetKeyState("Ctrl")) {
            this.CURRENT_STEP := this.STEP_SUMMARY
        }

        this.formButtons := {}

        this.open()

        this.afterStepChangedEvent()
    }

    previousStep()
    {
        this.CURRENT_STEP-- 

        switch (this.CURRENT_STEP) {
            case this.STEP_ITEM:
                this.title("Add item")
        }

        if (this.CURRENT_STEP == this.STEP_SELL_OFFER && !this.itemSetting("createSellOffer")) {
            this.CURRENT_STEP--
        }

        if (this.CURRENT_STEP == this.STEP_BUY_OFFER && !this.itemSetting("createBuyOffer")) {
            this.CURRENT_STEP--
        }

        if (this.CURRENT_STEP == this.STEP_SELL && !this.itemSetting("sellItem")) {
            this.CURRENT_STEP--
        }

        if (this.CURRENT_STEP == this.STEP_BUY && !this.itemSetting("buyItem")) {
            this.CURRENT_STEP--
        }

        if (GetKeyState("Ctrl")) {
            this.CURRENT_STEP := this.STEP_ITEM
        }

        this.open()

        this.next.enable()

        this.afterStepChangedEvent()
    }
    ;#Endregion

    ;#Region Controls
    progressControls()
    {
        this.progressBar := new _Progress().name("progressBar")
            .x(this.paddingLeft).y().w(this.getW() - this.paddingRight).h(35)
            .option("Range0-" this.TOTAL_STEPS)
            .option(_Progress.BACKGROUND)
            .add()

        this.progress := new _Text()
            .xp((this.progressBar.getW() / 2) - 30).yp((this.progressBar.getH() / 2) - 6).w(100)
            .option("BackgroundTrans")
            .add()

        this.updateProgress()
    }

    backButton()
    {
        this.backBtn := new _Button().title("&Voltar", "&Back")
            .xs().yadd(2).w(this.guiW - this.paddingRight).h(this.buttonsH)
            .event(this.previousStep.bind(this))
            .disabled((this.CURRENT_STEP != this.STEP_ACTIONS && this.CURRENT_STEP != this.STEP_SUMMARY))
            .tt(txt("Clique segurando ""Ctrl"" para ir para o primeiro passo", "Hold ""Ctrl"" and click to go to the first step"))
            .add()

        this.formButtons.Push(this.backBtn)
    }

    nextButton(x := "", w := "", y := 20)
    {
        this.nextBtn := new _Button().title("Pró&ximo", "Ne&xt")
            .x(x ? x : "s+0").yadd(y).w(w ? w : (this.guiW - this.paddingRight)).h(this.buttonsH)
            .event(this.nextStep.bind(this))
            .focused()
            .disabled(this.CURRENT_STEP != this.STEP_ACTIONS)
            .tt(txt("Clique segurando ""Ctrl"" para ir para o último passo", "Hold ""Ctrl"" and click to go to the last step"))
            .add()

        this.formButtons.Push(this.nextBtn)
    }

    closeButton()
    {
        this.closeBtn := new _Button().title("&Fechar", "&Close")
            .xs().yadd(3).w(this.guiW - this.paddingRight).h(this.buttonsH)
            .event(this.finish.bind(this))
            .tt(txt("Fechar a janela", "Close the window"))
            .tt("[Esc]")
            .add()

        this.formButtons.Push(this.closeBtn)
    }

    titleText(text, y := 25)
    {
            new _Text().title(text)
            .xs().yadd(y)
            .font("s12")
            .add()
    }

    titleTextCentered(text, y := 25)
    {
            new _Text().title(text)
            .xs().yadd(y).w(this.guiW - this.paddingRight)
            .font("s12")
            .center()
            .add()
    }

    example(text)
    {
            new _Text().title(text)
            .color("Gray")
            .xs().yadd(1).w(this.guiW - this.paddingRight)
            .add()
    }

    text(text, x := 5)
    {
        return new _Text().title(text)
            .xadd(x).yp(2)
            .add()
    }

    errorText()
    {
        return new _Text()
            .xs().yadd(7).w(this.guiW - this.paddingRight)
            .color("Red")
            .add()
            .hide()
    }

    edit(name, placeholder, x := 5)
    {
        return new _Edit().name(name)
            .nested(this.itemName)
            .xadd(x).yp(-2).w(this.priceWidth).h(18)
            .placeholder(placeholder)
            .parent()
            .beforeEvent(this.changeFormButtons.bind(this, "disable"))
            .afterEvent(this.changeFormButtons.bind(this, "enable"))
            .rule(new _ControlRule().default(new _MarketItemSettings().getAttribute(name)))
    }

    price(name, placeholder, x := 5)
    {
        return this.edit(name, placeholder, x)
            .numeric()
            .add()
    }

    amount(controlName, tt := "")
    {
        return new _Edit().name(controlName)
            .xadd(1).yp(-2).w(this.amountWidth).h(18)
            .nested(this.itemName)
            .placeholder("10")
            .numeric()
            .tt(tt)
            .parent()
            .rule(new _ControlRule().default(new _MarketItemSettings().getAttribute("" controlName)))
            .beforeEvent(this.changeFormButtons.bind(this, "disable"))
            .afterEvent(this.changeFormButtons.bind(this, "enable"))
    }

    checkbox(name, title)
    {
        return new _Checkbox().name(name)
            .nested(this.itemName)
            .title(title)
            .xp().yadd(3)
            .beforeEvent(this.changeFormButtons.bind(this, "disable"))
            .afterEvent(this.changeFormButtons.bind(this, "enable"))
            .afterSubmit(this.refreshItemList.bind(this))
    }

    radio(name, title)
    {
        return new _Radio().name(name)
            .title(title)
            .xs().yadd(10)
            .nested(this.itemName)
            .beforeEvent(this.changeFormButtons.bind(this, "disable"))
            .afterEvent(this.changeFormButtons.bind(this, "enable"))
            .afterSubmit(this.refreshItemList.bind(this))
            .add()
    }

    offerDefinedAmountRadio(type)
    {
        radio := this.radio(type "OfferDefinedAmount", txt("Criar oferta com no máximo", "Create offer with at most"))
            .tt("Definir uma quantidade máxima de itens da oferta a ser criada pelo bot.", "Set a maximum amount of items of the offer to be created by the bot.")

        this.amount(type "OfferAmount").add()
        this.text("item(s)")

        return radio
    }

    offerExclusiveAmountRadio(type)
    {
        radio := this.radio(type "OfferExclusiveAmount", txt("Criar oferta com somente", "Create offer only"))
            .tt("Definir uma quantidade exata de itens da oferta a ser criada pelo bot.", "Set an exact amount of items of the offer to be created by the bot.")
            .tt("Exemplo: caso você queira criar ofertas de ""Tibia Coin"" com 25 unidades sempre, marque essa opção e preencha 25 na quantidade de itens", "Example: if you want to create offers of ""Tibia Coin"" with 25 units always, check this option and fill in 25 in the amount of items.")

        this.amount(type "OfferAmountExclusive").add()
        this.text("item(s)")

        return radio
    }

    balanceCondition(type)
    {
        this.titleText("Balance:", 20)

        this.checkbox(type "BalanceCondition", txt("Ignorar se o balance for menor que", "Ignore if balance is less than"))
            .xp().yadd(10)
            .tt("Com essa opção ativa, o bot não irá realizar novas compras do item se o balance for menor do que o valor especificado.", "With this option active, the bot will not make new purchases of the item if the balance is less than the specified value.")
            .add()

        this.price(type "BalanceAmount", "10000", 1) 

        this.text("gp.")

        this[type "BalanceError"] := this.errorText()
    }
    ;#Endregion
}