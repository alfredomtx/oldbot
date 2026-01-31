#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_GUI.ahk

class _MarketbotGUI extends _GUI
{
    static INSTANCE

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?string title
    */
    __New()
    {
        if (_MarketbotGUI.INSTANCE) {
            return _MarketbotGUI.INSTANCE
        }

        base.__New("marketbot", "Marketbot - OldBot")

        this.guiW := 395
        this.guih := 200

        this.paddingLeft := 10
        this.paddingRight := 20

        this.onCreate(this.create.bind(this))
            .y(10).w(this.guiW)
        ; .withoutMinimizeButton()
            .alwaysOnTop()
            .noActivate()
            .afterCreate(this.afterCreateGui.bind(this))
        ; .withoutWindowButtons()

        _MarketbotGUI.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    */
    create()
    {
        _AbstractControl.SET_DEFAULT_GUI(this)

        try {
            this.loadLicense()
        } catch e {
            _Logger.msgboxException(16, e, "Marketbot License")
        }

        this.createControls()

        _AbstractControl.RESET_DEFAULT_GUI()
    }

    loadLicense()
    {
        this.license := new _MarketbotLicense()
        this.premium := this.license.isPremium()

        if (this.premium) {
            this.title("Marketbot Premium - " this.license.days() " " txt("dia(s)", "day(s)")" (" this.license.date() ") ")
        } else {
            this.title("Marketbot FREE - " txt("Limite de", "Limit of") " " this.license.items() " item(s)" )
        }
    }

    checkEnabledItems()
    {
        _Market.itemLimitExceeded() ? this.enabledItemsWarning.show() : this.enabledItemsWarning.hide()
    }

    afterCreateGui()
    {
        this.loadItemList()
        _Market.ensureFolderExists()
    }

    ;#region Elements
    /**
    * @return void
    */
    createControls()
    {
        disabled := !isTibia13() || isRubinot()
            new _Checkbox().title("&Marketbot " txt("Ativado","Enabled"))
            .prefix(_Market.IDENTIFIER)
            .name(_AbstractSettings.ENABLED_KEY)
            .xs().yadd(5)
            .state(_MarketSettings)
            .event(this.toggleMarketbot.bind(this))
            .afterSubmit(_Market.toggleEvent.bind(_Market))
            .disabled(disabled)
            .tt("Iniciar o módulo do Marketbot.", "Start the Marketbot module.")
            .add()

        if (disabled) {
                new _Text().title("Compatível somente com clientes Tibia 13/14.", "Compatible only with Tibia 13/14 clients.")
                .x().yp()
                .color("red")
                .add()
        } else {
            this.enabledItemsWarning := new _Text().title(txt("Limite de", "Limit of") " " this.license.items() " " txt("itens ativos, desative algum item", "active items, disable some item.") ".")
                .x().yp()
                .color("red")
                .hidden(!_Market.itemLimitExceeded())
                .add()
        }

        ; new _Text().title("Items:")
        ; .x(this.paddingLeft).yadd(10).w(this.guiW - this.paddingRight)
        ; .font("s12")
        ; .add()

        this.columns := this.getColumns()

            new _Checkbox().name("toggleItems")
            .title("Ativar/desativar itens", "Enable/disable items")
            .xs().yadd(10)
            .state(_MemorySettings)
            .event(this.toggleItems.bind(this))
            .add()

        this.profiles()

        ; rows := this.license.items() > 10 ? 10 :  + 1
        rows := 11
        this.itemList := new _Listview().name("itemList")
            .xs().yadd(3).w(this.guiW - this.paddingRight).r(rows) .title(this.columns)
            .options("-HScroll", "Grid", "-Multi")
            .checked()
            .event(this.selectItem.bind(this))
            .add()


        this.buttons()
    }

    profiles()
    {
            new _Text().title("Perfil:", "Profile:")
            .x(200).yp().w(50)
            .alignRight()
            .tt("Selecione o perfil de itens do Marketbot.`nVocê pode criar novos perfis com diferentes itens configurados.", "Select the Marketbot items profile.`nYou can create new profiles with different items configured.")
            .add()

        this.profilesList := new _Dropdown().name("profile")
            .state(_MarketSettings)
            .xadd(5).yp(-5).w(100)
            .event(this.selectProfile.bind(this))
            .parent()
            .add()

            new _Button()
            .xadd(3).yp(-1).w(24).h(24)
            .event(this.addProfile.bind(this))
            .tt("Adicionar novo perfil de itens do Marketbot.", "Add new Marketbot items profile.")
            .icon(_Icon.get(_Icon.PLUS), "a0 l2 s14 b0")
            .add()

        this.loadProfiles()
    }

    loadProfiles(cached := true)
    {
        list := {}

        selectedProfile := new _MarketSettings().get("profile")

        for _, profile in _A.keys(new _MarketSettings().profiles(cached)) {
            list.push(new _ListOption(profile, profile == selectedProfile))
        }

        this.profilesList.list(list)
    }

    selectProfile(control, value)
    {
        if (value == new _MarketSettings().profile()) {
            return
        }

        this.setNewProfile(value)
    }

    setNewProfile(profile)
    {
            new _MarketSettings().submit("profile", profile)
            new _MarketItemSettings().loadSettings()
        this.loadProfiles(cached := false)
        this.refreshItemList()
    }

    addProfile()
    {
        InputBox, profile, % LANGUAGE = "PT-BR" ? "Criar novo perfil" : "Create new profile", % LANGUAGE = "PT-BR" ? "O novo perfil estará com a lista de itens vazia.`n`nNome do perfil:" : "The new profile will be with the items list empty.`n`nProfile name:",,300,155
        if (ErrorLevel = 1) {
            return
        }

        if (empty(profile)) {
            Msgbox, 64,, % LANGUAGE = "PT-BR" ? "Escreva o nome para o perfil." : "Write a nome for the profile."
            return
        }

        path := _MarketSettings.PROFILE_PATH "\" profile ".ini"

        if (FileExist(path)) {
            Msgbox,48,, % LANGUAGE = "PT-BR" ? "Já existe um perfil com este nome." : "There is already a profile with this name."
            return
        }

        StringReplace, profile, profile, %A_Space%,_, All
        profile := RegExReplace(profile,"[^\w]","")
        FileAppend, % "", % path

        this.setNewProfile(profile)
        this.loadProfiles(cached := false)
    }

    getColumns()
    {
        buyOfferColumns := Array("Buy Offer")
        sellOfferColumns := Array("Sell Offer")
        offerColumns := _A.concat(buyOfferColumns, sellOfferColumns)

        buySellColumns := Array(txt("Comprar", "Buy"), txt("Vender", "Sell"))
        itemColumns := Array(txt("Ativo", "Enabled"), "Item")

        return _A.concat(_A.concat(itemColumns, buySellColumns), offerColumns)


        amountColumn := txt("Qtd.", "Amount")

        buySellColumns := Array(txt("Comprar", "Buy"), amountColumn, txt("Vender", "Sell"), amountColumn, txt("Lucro", "Profit"))

        buyOfferColumns := Array("Buy Offer", amountColumn, txt("Limite", "Limit"))
        sellOfferColumns := Array("Sell Offer", amountColumn, txt("Limite", "Limit"))
        offerColumns := _A.concat(buyOfferColumns, sellOfferColumns)

        columns := _A.concat(buySellColumns, _A.concat(offerColumns, txt("Lucro", "Profit")))

        this.columns := _A.concat(Array(txt("Ativo", "Enabled"), "Item"), columns)
    }

    buttons()
    {
        this.buttonsW := 80
        this.buttonsPaddingLeft := 2

            new _Button()
            .title("                &A")
            .xp().yadd(5).w(28).h(30)
            .event(this.addItem.bind(this))
            .tt(txt("Adicionar novo item", "Add new item"))
            .tt("[Alt + A]")
            .icon(_Icon.get(_Icon.PLUS), "a0 l3 s16 b0")
            .add()

            new _Button()
            .title("                &D")
            .xadd(this.buttonsPaddingLeft).yp().w(30).h(30)
            .icon(_Icon.get(_Icon.DELETE), "a0 l4 s16 b0")
            .tt(txt("Deletar item selecionado", "Delete selected item"))
            .tt("[Alt + D]")
            .event(this.deleteItem.bind(this))
            .add()

            new _Button()
            .title("                &I")
            .xadd(this.buttonsPaddingLeft).yp().w(30).h(30)
            .icon(_Icon.get(_Icon.EXCLAMATION), "a0 l4 s16 b0")
            .tt("Abrir resumo do item selecionado.", "Open summary of the selected item.")
            .tt("")
            .tt("Dica: selecione o item na lista segurando ""Ctrl"" para ir para a tela do resumo.", "Tip: select the item in the list holding ""Ctrl"" to go to the summary screen.")
            .title("                &I")
            .event(this.openAddItemOnSummaryStep.bind(this))
            .add()

            new _Button()
            .xadd(this.buttonsPaddingLeft).yp().w(30).h(30)
            .icon(_Icon.get(_Icon.RELOAD), "a0 l4 s16 b0")
            .event(this.refreshItemList.bind(this))
            .tt(txt("Atualizar lista dos itens", "Update the items list"))
            .add()

            new _Button().title(lang("settings"))
            .xadd(this.buttonsPaddingLeft).yp().w(100).h(30)
            .event(new _MarketbotSettingsGUI().open.bind(new _MarketbotSettingsGUI()))
            .icon(_Icon.get(_Icon.SETTINGS), "a0 l3 s16 b0")
            .add()

        w := 100
        x := this.getWidth() - (w + this.paddingRight) + 10
            new _Button().title(this.license.isPremium() ? txt("Ver", "See") " Premium" : "Get Premium!")
            .x(x).yp().w(w).h(30)
            .event(new _PremiumGUI().open.bind(new _PremiumGUI()))
            .icon(_Icon.get(_Icon.STAR), "a0 l3 s16 b0")
            .add()
    }
    ;#endregion

    ;#region Events
    toggleItems(_, value)
    {
        for _, item in new _MarketItemCollection().items() {
                new _MarketItemSettings().submit("enabled", value, _A.snakeCase(item))
        }

        this.checkEnabledItems()
        this.loadItemList()
    }

    toggleMarketbot(control, value)
    {
        if (!value) {
            return
        }

        try {
            _Market.guardAgainstItemLimitExceeded()
        } catch e {
            control.uncheckWithoutEvent()
            msgbox, 48, % txt("Limite de itens", "Items limit"), % e.Message
            return false
        }

            new _GraphicEngineSetting().handledAutomaticCheck()
    }

    closeMarketbotInstances(control, value)
    {
        Loop, 10 {
            Process, Exist, % _MarketExe.getName()
            if (!ErrorLevel) {
                break
            }

            if (ErrorLevel = _MarketExe.getPID()) {
                continue
            }

            Process, Close, % _MarketExe.getName()
            sleep(100)
        }
    }

    addItem()
    {
            new _AddItemGUI().open()
    }

    openAddItemOnSummaryStep()
    {
        selectedItem := this.getSelectedItem()
        if (!selectedItem) {
            this.itemList.selectRow(1, removeCallback := false)
            if (!selectedItem) {
                Msgbox, 64,, % txt("Selecione um item na lista.", "Select an item in the list."), 4
                return
            }
        }

            new _AddItemGUI(selectedItem, _AddItemGUI.STEP_SUMMARY).open()
    }

    selectItem(control, value, CtrlHwnd, GuiEvent, EventInfo, ErrLevel)
    {
        row := EventInfo
        event := ErrLevel

        selectedItem := this.getSelectedItem()
        switch (GuiEvent) {
            case "A":
                    new _AddItemGUI(selectedItem).open()
                return

            case "Normal":
                if (GetKeyState("Ctrl")) {
                    this.openAddItemOnSummaryStep()
                    return
                }
        }

        if (!row || !event) {
            return
        }

        item := this.itemList.getText(row, 2)
        if (!item) {
            return
        }

        this.toggleItem(item, event)
    }

    toggleItem(item, event)
    {
            new _MarketItemSettings().submit("enabled", event == "C" ? true : false, _A.snakeCase(item))
        this.checkEnabledItems()
    }

    deleteItem()
    {
        selectedItem := this.getSelectedItem()
        if (!selectedItem) {
            Msgbox, 64,, % txt("Selecione um item na lista", "Select an item in the list")
            return
        }

        Msgbox, 52, % txt("Deletar item", "Delete item"), % txt("Tem certeza que deseja deletar o item " , "Are you sure you want to delete the item " ) _Str.quoted(selectedItem) "?"
        IfMsgBox, No
            return

            new _AddItemGUI().close()
            new _MarketItemSettings().deleteSection(_A.snakeCase(selectedItem))
            new _MarketItemCollection().refresh()

        this.loadItemList()
    }

    refreshItemList()
    {
            new _MarketItemCollection().refresh()
        this.loadItemList()
    }

    loadItemList()
    {
        this.itemList.deleteRows()

        for, _, item in new _MarketItemCollection().items() {
            offer := new _UserOffer(item)

            row := new _Row()
                .add(A_Index " ")
                .add(offer.itemName)
                .add(offer.buy.isEnabled() ? "✔️" : "❌")
                .add(offer.sell.isEnabled() ? "✔️" : "❌")
                .add(offer.buyOffer.isEnabled() ? "✔️" : "❌")
                .add(offer.sellOffer.isEnabled() ? "✔️" : "❌")

            row.setChecked(offer.isEnabled())

            this.itemList.addRow(row, A_Index)
        }

        this.itemList.resize()
    }
    ;#endregion

    ;#region Getters
    getSelectedItem()
    {
        item := this.itemList.getSelectedText(2)
        if (item == this.columns[2]) {
            return
        }

        return item
    }

    ;#endregion

    ;#region Predicates
    ;#endregion
}