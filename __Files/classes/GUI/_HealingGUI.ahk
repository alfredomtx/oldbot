
Class _HealingGUI  {

    static ITEM_ICON_OPTIONS := "a0 l5 b0 t0 s30"

    __New()
    {
    }

    PostCreate_HealingGUI() {
        if (OldbotSettings.uncompatibleModule("healing") = true)
            return
    }

    createHealingGUI()
    {
        global

        main_tab := "Healing"
        child_tabs_%main_tab% := "Settings"

        Gui, CavebotGUI:Add, Tab2, x6 vTab_%main_tab% y%y_tab% w%tabsWidth% h%tabsHeight% hWndhTab_%main_tab% %TabStyle% +Theme, % child_tabs_%main_tab%
        if (load_order[1] != main_tab)
            GuiControl, Hide, Tab_%main_tab% ; esconder a tab antes de adicionar os elementos a ela

        if (OldbotSettings.uncompatibleModule("healing") = true) {
            _GuiHandler.uncompatibleModuleWarning()
            return
        }

        Loop, parse, child_tabs_%main_tab%, |
        {
            current_child_tab := A_LoopField
            ; msgbox, % child_tabs_%main_tab%
            Gui, CavebotGUI:Tab, %current_child_tab%
            switch current_child_tab
            {
                case "Settings":
                    this.ChildTab_Settings()
            }
        }

    }

    ChildTab_Settings() {
        global

        w := tabsWidth - 20
        w_group := 194
        w_text := 83
        w_control := w_group - w_text - 27
        xs := "8"

        this.w_control := w_control

        lifeGroupboxHeight := 200

        groupH := 180

        groupGap := 7

        y_group := 80
        x_group1 := 25

        ruleCommentHwndText := (LANGUAGE = "PT-BR" ? "Um comentário ou descrição dessa regra, com propósito informativo somente" : "A comment or description of this rule, for information purpose only")
        hotkeyHighHwndText := (LANGUAGE = "PT-BR" ? "Hotkey da magia de healing" : "Hotkey of the healing spell")
        hotkeyHwndText := (LANGUAGE = "PT-BR" ? "Hotkey da magia de healing.`nNão preencha a hotkey de uma potion nessa opção." : "Hotkey of the healing spell.`nDo not fill the hotkey potion of a potion in this option.")
        lifeHwndText := (LANGUAGE = "PT-BR" ? "Porcentagem de vida para começar a healar com essa regra" : "Percentage of life to start healing with this rule")
        manaHwndText := txt("Porcentagem mínima de mana que o seu personagem deve possuir para continuar healando com essa magia, se a mana for abaixo a magia não será usada.`n`nOBS: A potion/runa será usada independente da condição de mana.", "Mininum percentage of mana your char must have to keep healing with this spell, if mana is below the spell won't be casted.`n`nPS: The potion/rune will be used despite of the mana condition.")
        potionHotkeyhwndText := (LANGUAGE = "PT-BR" ? "Hotkey de alguma Health Potion ou Runa para healer junto com a Spell(combo).`nA potion não irá considerar a regra de ""Mana above"" para ser usada, somente a Spell irá." : "Hotkey of some Health Potion or Rune to heal together with the Spell(combo).`nThe Potion won't consider the ""Mana above"" rule to be used, only the Spell will.")

        Gui CavebotGUI:Add, GroupBox, x15 y+10 w%w% h%lifeGroupboxHeight% Section,

        Disabled := uncompatibleFunction("healing", "lifeHealing") = true ? "Disabled" : ""
        DisabledMana := uncompatibleFunction("healing", "manaHealing") = true ? "Disabled" : ""

        Gui CavebotGUI:Add, Checkbox, x25 ys vlifeHealingEnabled glifeHealingEnabled hwndhlifeHealingEnabled Checked%lifeHealingEnabled% %Disabled% Section, % "Life Healing " lang("enabled")
        TT.Add(hlifeHealingEnabled, txt("Ativa e inicia o Life Healing", "Enable and starts the Life Healing"))

        this.baseLoadHotkeysButton()
            .tt("Carrega a hotkey da health potion mais forte encontrada na Action Bar e também as magias de cura, da mais fraca até a mais forte, de acordo com cada vocação(hotkey preset).`n`nSe o hotkey preset for ""Paladin"", carrega a spirit potion.`n`nATENÇÃO: é necessário relogar no char após você mudar alguma hotkey ou item na Action Bar para carregar novamente.`n`nDICA: segure a tecla ""Ctrl"" ao clicar para confirmar cada mudança.", "Load the hotkey of the strongest health potion found in the Action Bar and also the healing spells, from the weakest to the strongest, according to each vocation(hotkey preset).`n`nIf the hotkey preset is ""Paladin"", loads the spirit potion.`n`nATTENTION: It's necessary to relogin on the character after you change a hotkey or item in the Action Bar to load again.`n`nTIP: Hold the ""Ctrl"" key when clicking to confirm each change.")
            .event(this.loadLifeHealingHotkeys.bind(this))
            .add()

            new _Button().title("Resetar", "Reset")
            .x("+5").y("p-0").h(20).w(70)
            .tt("Deleta todas as hotkeys do Life Healing.", "Delete all of the Life Healing hotkeys.")
            .event(this.deleteLifeHealingHotkeys.bind(this))
            .icon(_Icon.get(_Icon.RELOAD), "a0 l2 s13 t1")
            .add()

        disabledHotkey := clientHasFeature("useItemWithHotkey") ? "" : "Disabled"

        this.lifeHealing()


        this.manaHealing()
        this.manaTrain()

        this.healingSetup()

        _GuiHandler.tutorialButtonModule("Healing")
    }

    healingSetup()
    {
        global

        if (clientHasFeature("useItemWithHotkey")) {
            return
        }

        y := manaGroupY + manaGroupHeight + 10

        Gui, CavebotGUI:Add, Groupbox, x15 y%y% w160 h90 Section, Healing Setup
        Gui, CavebotGUI:Add, Button, xs+10 ys+20 w140 gShowGameWindowArea, % "Show Game Window area"
        Gui, CavebotGUI:Add, Button, xs+10 y+10 w140 gSetGameWindowArea, % "Set Game Window area"
    }

    baseLoadHotkeysButton(title := "")
    {
        return new _Button().title(title ? title : txt("Carregar hotkeys", "Load hotkeys"))
            .x("+10").y("p-3").h(20).w(110)
            .disabled(new _LoadHotkeysPolicy().run())
            .icon(_Icon.get(_Icon.TIBIA), "a0 l1 b1 s17")
    }

    lifeEdit()
    {
        return new _Edit()
            .x("+8").y("p-2").h(18).w(this.w_control)
            .numeric()
            .center()
            .limit(2)
            .state(_HealingSettings)
            .rule(_ControlRule.fromDefaultValue(_HealingSettings.getDefaultPercentageValue()))
            .setDebounceInterval(1000)
            .nested("life")
    }

    manaEdit()
    {
        return new _Edit()
            .x("+8").y("p-2").h(18).w(this.w_control)
            .numeric()
            .center()
            .limit(2)
            .state(_HealingSettings)
            .rule(_ControlRule.fromDefaultValue(_HealingSettings.getDefaultPercentageValue()))
            .setDebounceInterval(1000)
            .nested("mana")
    }

    lifeHealing()
    {
        global

        h := 170

        ; msgbox, % "healing " serialize(healingObj.life)
        Gui, CavebotGUI:Add, Groupbox, x%x_group1% y%y_group% w%w_group% h%h% Section, Highest HP # 4

        this.commentAndHotkey("highest")
        this.lifeAndManaPercentages("highest")

        x_group2 := x_group1 + w_group + groupGap
        Gui, CavebotGUI:Add, Groupbox, x%x_group2% y%y_group% w%w_group% h%h% Section, High HP # 3

        this.commentAndHotkey("high")
        this.lifeAndManaPercentages("high")

        x_group3 := x_group2 + w_group + groupGap
        Gui, CavebotGUI:Add, Groupbox, x%x_group3% y%y_group% w%w_group% h%h% Section, Mid HP # 2


        if (!clientHasFeature("useItemWithHotkey")) {
            this.addLifeItem("midItemName")
        } else {
            this.potionHotkey("mid")
        }

        this.commentAndHotkey("mid", "+10")

        this.lifeAndManaPercentages("mid")

        x_group4 := x_group3 + w_group + groupGap
        Gui, CavebotGUI:Add, Groupbox, x%x_group4% y%y_group% w%w_group% h%h% Section, Low HP # 1

        if (!clientHasFeature("useItemWithHotkey")) {
            this.addLifeItem("lowItemName")
        } else {
            this.potionHotkey("low")
        }

        this.commentAndHotkey("low", "+10")

        this.lifeAndManaPercentages("low")
    }

    addLifeItem(name)
    {
        itemsList := ItemsHandler.getItemListArray("health|life|spirit|intense|ultimate", {1: "Liquids", 2: "Attack Runes"}, "mana potion", "")

        this.addMenuItem(name, "life", itemsList)
    }

    addMenuItem(name, type, itemsList, firstOption := "")
    {
        global w_group, xs

        this[name] := {}

        this[name].menu := new _ItemsMenu(itemsList, this.menuCallback.bind(this, name), name)
            .text(firstOption ? firstOption : txt("Selecione uma potion/runa`n(opcional)", "Select a potion/rune`n(optional)"))
            .create()

        itemName := healingObj[type][name]

        this[name].button := new _Button().title(itemName ? itemName : this[name].menu.getFirst().getTitle())
            .xs(xs).yp(20).w(buttonWidth := w_group - 20).h(buttonHeight := 38)
            .event(this.showMenu.bind(this, name))

        if (itemName) {
            icon := _BitmapIcon.FROM_ITEM(itemName)
            if (icon) {
                this[name].button.icon(icon, this.ITEM_ICON_OPTIONS)
            }
        }

        this[name].button.add()

        this[name].edit := new _Edit().name(name)
            .xp(0).yp(0).w(buttonWidth).h(buttonHeight)
        ; .xp(0).yadd(1).w(buttonWidth).h(buttonHeight)
            .nested(type)
            .state(_HealingSettings)
            .hidden(true)
            .add()

        this[name].changeImageButton := new _Button().title(txt("Alterar imagem do item", "Change item image"))
            .xp(0).yadd(3).w(buttonWidth).h(18)
            .tt(txt("Caso a sprite(imagem) do item esteja diferente da sprite do item no OT server que você está jogando, é necessário alterar a imagem do item no bot na aba Looting -> ItemList para que o bot consiga localizar o item na tela.", "If the item sprite(image) is different from the item sprite in the OT server you are playing, it's necessary to change the item image in the bot in the Looting -> ItemList tab so the bot can find the item on the screen."))
            .event(this.changeItemImage.bind(this, name))
            .disabled(empty(itemName))
            .add()

        this.createItemMenu(name)
    }

    changeItemImage(controlName)
    {
        GuiControl, CavebotGUI:Choose, MainTab, Looting
        try {
            Gosub, MainTab
        } catch e {
        }

        GuiControl, CavebotGUI:Choose, Tab_Looting, ItemList

        itemName := this[controlName].edit.get()
        GuiControl, CavebotGUI:, searchFilter_Name, % itemName

        Msgbox, 64, % txt("Alterar imagem do item", "Change item image"), % txt("Coloque o item " _Str.quoted(itemName) " no primeiro slot da bag/backpack selecionada e clique no botão ""Add from backpack"" para alterar a sua imagem.", "Put the item " _Str.quoted(itemName) " in the first slot of the selected bag/backpack and click on the button ""Add from backpack"" to change its image."), 10
    }

    menuCallback(controlName)
    {
        isFirst := A_ThisMenuItem == this[controlName].menu.getFirst().getTitle()

        value := isFirst ? "" : A_ThisMenuItem
        this[controlName].edit.set(value)
        this[controlName].edit.stateHandlerSet(value) ; for some reason the gui event(onEvent) is not being triggered for the Edit control

        this[controlName].button.set(A_ThisMenuItem)
        this[controlName].changeImageButton.enable()

        if (isFirst) {
            this[controlName].button.destroyIcon()
            this[controlName].changeImageButton.disable()

            return
        }

        icon := _BitmapIcon.FROM_ITEM(A_ThisMenuItem)
        if (!icon) {
            return
        }

        this[controlName].button.icon(icon, this.ITEM_ICON_OPTIONS)
    }

    showMenu(name)
    {
        this[name].menu.show()
    }

    commentAndHotkey(rule, y := "p+25")
    {
        global

        ;     new _Text().title("Comentário:", "Comment:")
        ;     .xs(xs).y(y).w(w_text)
        ;     .tt(ruleCommentHwndText)
        ;     .option("Right")
        ;     .add()

        ; this.lifeSpellComment(rule)

            new _Text().title("Hotkey da magia:", "Spell hotkey:")
            .xs(xs).y(y).w(w_text)
        ; .xs(xs).yadd(10).w(w_text)
            .tt(hotkeyHwndText)
            .option("Right")
            .add()

        this.lifeSpellHotkey(rule)
    }

    lifeAndManaPercentages(rule)
    {
        global

            new _Text().title("Vida abaixo", "Life below", " `%:")
            .xs(xs).yadd(10).w(w_text)
            .tt(lifeHwndText)
            .option("Right")
            .add()

        this.lifeEdit()
            .name(rule "Life")
            .tt(lifeHwndText)
            .afterSubmit(HealingHandler.validateLifeHealingPercentages.bind(validateLifeHealingPercentages))
            .add()


            new _Text().title("Mana acima", "Mana above", " `%:")
            .xs(xs).yadd(10).w(w_text)
            .tt(manaHwndText)
            .option("Right")
            .disabled(uncompatibleFunction("healing", "manaHealing"))
            .add()

        this.lifeEdit()
            .name(rule "mana")
            .tt(manaHwndText)
            .disabled(uncompatibleFunction("healing", "manaHealing"))
            .add()
    }

    potionHotkey(rule)
    {
        global

        Gui, CavebotGUI:Add, Text, xs+%xs% yp+25 w%w_text% Right, % txt("Hotkey Potion:", "Potion Hotkey:")

        this[rule "PotionHotkey"] := new _Hotkey().name(rule "PotionHotkey")
            .x("+8").y("p-2").w(w_control).h(18)
            .tt(potionHotkeyhwndText)
            .nested("life")
            .state(_HealingSettings)
            .rule(new _HotkeyRule())
            .event(this.validatePotionHotkey.bind(this))
            .add()
    }

    validateSpellHotkey(control, value)
    {
        if (empty(value)) {
            return
        }

        rule := StrReplace(control.getControlID(), "PotionHotkey", "")
        value := strtoupper(value)

        try {
            if (value = this.lowPotionHotkey.get()) {
                this.spellHotkeyException(value, rule, ucfirst("low"))
            }
            if (value = this.midPotionHotkey.get()) {
                this.spellHotkeyException(value, rule, ucfirst("mid"))
            }
            if (value = this.highPotionHotkey.get()) {
                this.spellHotkeyException(value, rule, ucfirst("high"))
            }
            if (value = this.highestPotionHotkey.get()) {
                this.spellHotkeyException(value, rule, ucfirst("highest"))
            }
        } catch e {
            control.setWithoutEvent("")
            Msgbox, 48,, % e.Message, 10
        }
    }

    validatePotionHotkey(control, value)
    {
        if (empty(value)) {
            return
        }

        rule := StrReplace(control.getControlID(), "PotionHotkey", "")
        value := strtoupper(value)

        try {
            if (value = this.lowHotkey.get()) {
                this.potionHotkeyException(value, rule, ucfirst("low"))
            }
            if (value = this.midHotkey.get()) {
                this.potionHotkeyException(value, rule, ucfirst("mid"))
            }
            if (value = this.highHotkey.get()) {
                this.potionHotkeyException(value, rule, ucfirst("high"))
            }
            if (value = this.highestHotkey.get()) {
                this.potionHotkeyException(value, rule, ucfirst("highest"))
            }
        } catch e {
            control.setWithoutEvent("")
            Msgbox, 48,, % e.Message, 10
        }
    }

    potionHotkeyException(htk, rule, conflictingRule)
    {
        throw Exception(txt("A ""Hotkey Potion"" (" htk ") do """ ucfirst(rule) " HP"" não pode ser igual a ""Hotkey Magia"" do ", "The ""Potion Hotkey"" (" htk ") of """ ucfirst(rule) " HP"" cannot be the same as the ""Spell Hotkey"" of the ") """" conflictingRule " HP"".")
    }

    spellHotkeyException(htk, rule, conflictingRule)
    {
        throw Exception(txt("A ""Hotkey Magia"" (" htk ") do """ ucfirst(rule) " HP"" não pode ser igual a ""Hotkey Potion"" do ", "The ""Spell Hotkey"" (" htk ") of """ ucfirst(rule) " HP"" cannot be the same as the ""Potion Hotkey"" of the ") """" conflictingRule " HP"".")
    }

    lifeSpellHotkey(rule)
    {
        global

        this[rule "Hotkey"] := new _Hotkey().name(rule "Hotkey")
            .x("+8").y("p-2").w(w_control).h(18)
            .tt(hotkeyHwndText)
            .nested("life")
            .state(_HealingSettings)
            .rule(new _HotkeyRule())
            .event(this.validateSpellHotkey.bind(this))
            .add()
    }

    lifeSpellComment(rule)
    {
        global

        this[rule "Comment"] := new _Edit()
            .x("+8").y("p-2").h(18).w(w_control)
            .name(rule "Comment")
            .nested("life")
            .tt(ruleCommentHwndText)
            .state(_HealingSettings)
            .add()
    }

    manaHealing()
    {
        global
        w_group += 20
        w_text := 80
        xs := "8"
        w_control := w_group - w_text - 31

        manaGroupHeight := 170
        manaGroupWidth := 270

        manaGroupY := lifeGroupboxHeight + y_group - 15

        Gui CavebotGUI:Add, GroupBox, x15 y%manaGroupY% w%manaGroupWidth% h%manaGroupHeight% Section,

        Disabled := uncompatibleFunction("healing", "manaHealing") = true ? "Disabled" : ""

        Gui CavebotGUI:Add, Checkbox, x25 ys vmanaHealingEnabled gmanaHealingEnabled Checked%manaHealingEnabled% %Disabled%, % "Mana Healing " lang("enabled")

        this.baseLoadHotkeysButton(txt("Carregar hotkey", "Load hotkey"))
            .tt("Carrega a hotkey da mana potion mais forte encontrada na Action Bar.`n`nATENÇÃO: é necessário relogar no char após você mudar alguma hotkey ou item na Action Bar para carregar novamente.", "Load the hotkey of the strongest mana potion found in the Action Bar.`n`nATTENTION: It's necessary to relogin on the character after you change a hotkey or item in the Action Bar to load again.")
            .event(this.loadManaHealingHotkey.bind(this))
            .add()

        Gui, CavebotGUI:Add, Groupbox, x%x_group1% ys+23 w%w_group% h138 Section, Mana rule

        if (!clientHasFeature("useItemWithHotkey")) {
            itemsList := ItemsHandler.getItemListArray("mana|spirit", {1: "Liquids"}, "", "")
            this.addMenuItem("manaItemName", "mana", itemsList, txt("Selecione a mana potion", "Select the mana potion"))
        } else {
            Gui, CavebotGUI:Add, Text, xs+%xs% yp+25 w%w_text% Right, % txt("Hotkey Potion:", "Potion Hotkey:")
            this.manaHotkey := new _Hotkey().name("manaHotkey")
                .x("+8").y("p-2").w(w_control).h(18)
                .tt("Hotkey de uma Mana Potion", "Hotkey of a Mana Potion")
                .nested("mana")
                .rule(new _HotkeyRule())
                .state(_HealingSettings)
                .add()
        }


        manaHwndText := txt("Porcentagem de mana para começar a usar mana potions", "Percentage of mana where it will start using mana potions")
            new _Text().title("Mana abaixo", "Mana below", " `%:")
            .xs(xs).yadd(10).w(w_text)
            .tt(manaHwndText)
            .option("Right")
            .add()

        this.manaEdit()
            .name("manaMin")
            .tt(manaHwndText)
            .afterSubmit(HealingHandler.validateManaHealingPercentages.bind(validateManaHealingPercentages))
            .add()

        manaHwndText := txt("Porcentagem de mana para parar de usar mana potions", "Percentage of mana where it will stop using mana potions")
            new _Text().title("Mana acima", "Mana above", " `%:")
            .xs(xs).yadd(10).w(w_text)
            .tt(manaHwndText)
            .option("Right")
            .add()

        this.manaEdit()
            .name("manaMax")
            .tt(manaHwndText)
            .afterSubmit(HealingHandler.validateManaHealingPercentages.bind(validateManaHealingPercentages))
            .add()


        ; Gui, CavebotGUI:Add, Text, xs+%xs% y+10 w%w_text% Right, % txt("Mana abaixo", "Mana below") " `%:"
        ; Gui, CavebotGUI:Add, Edit, x+8 yp-2 w%w_control% h18 vmanaMin hwndhmanaMin gsubmitHealingOptionHandler 0x2000 Limit2 Center, % healingObj.mana.manaMin
        ; TT.Add(hmanaMin, (LANGUAGE = "PT-BR" ? ))

        ; Gui, CavebotGUI:Add, Text, xs+%xs% y+10 w%w_text% Right, % txt("Mana acima", "Mana above") " `%:"
        ; Gui, CavebotGUI:Add, Edit, x+8 yp-2 w%w_control% h18 vmanaMax hwndhmanaMax gsubmitHealingOptionHandler 0x2000 Limit2 Center, % healingObj.mana.manaMax
        ; TT.Add(hmanaMax, (LANGUAGE = "PT-BR" ? "Porcentagem de mana para parar de usar mana potions" : "Percentage of mana where it will stop using mana potions"))

    }

    manaTrain()
    {
        global

        w_text := 75
        w_control := w_group - w_text - 29
        xs := "10"


        x := manaGroupWidth + 30
        Gui CavebotGUI:Add, GroupBox, x%x% ys-23 w%manaGroupWidth% h%manaGroupHeight% Section,

        Disabled := uncompatibleFunction("healing", "manaTrain") = true ? "Disabled" : ""
        Gui CavebotGUI:Add, Checkbox, xs+10 ys vmanaTrainEnabled gmanaTrainEnabled Checked%manaTrainEnabled% %Disabled%, % "Mana Train " lang("enabled")

        Gui, CavebotGUI:Add, Groupbox, xs+10 ys+23 w%w_group% h138 Section, Mana rule
        Gui, CavebotGUI:Add, Text, xs+%xs% yp+25 w%w_text% Right, % txt("Hotkey magia:", "Spell hotkey:")

        this.manaTrainHotkey := new _Hotkey().name("manaTrainHotkey")
            .x("+8").y("p-2").w(w_control).h(18)
            .tt("Hotkey de uma magia para gastar sua mana", "Hotkey of a spell to waste your mana")
            .nested("mana")
            .rule(new _HotkeyRule())
            .state(_HealingSettings)
            .add()

        ; Gui, CavebotGUI:Add, Hotkey, x+8 yp-2 w%w_control% h18 vmanaTrainHotkey hwndhmanaTrainHotkey gsubmitHealingOptionHandler, % healingObj.mana.manaTrainHotkey
        ; TT.Add(hmanaTrainHotkey, (LANGUAGE = "PT-BR" ? "Hotkey de uma magia para gastar sua mana" : "Hotkey of a spell to waste your mana"))


        Gui, CavebotGUI:Add, Text, xs+%xs% y+10 w%w_text% Right, % LANGUAGE = "PT-BR" ? "Mana acima `%:" : "Mana above `%:"
        Gui, CavebotGUI:Add, Edit, x+8 yp-2 h18 vmanaTrain gsubmitHealingOptionHandler hwndhmanaTrain w%w_control% 0x2000 Limit2 Center, % healingObj.mana.manaTrain
        TT.Add(hmanaTrain, (LANGUAGE = "PT-BR" ? "Porcentagem de mana para parar de usar a magia de mana train, irá usar somente quando a mana estiver acima dessa porcentagem" : "Percentage of mana to stop casting mana train spell, it only casts while the mana is above this percentage"))


        DisabledChatCondition := OldBotSettings.settingsJsonObj.clientFeatures.chatOnOff = false ? "Disabled" : ""
        manaTrainChatOn := healingObj.mana.manaTrainChatOn
        Gui, CavebotGUI:Add, Checkbox, xs+10 y+15 vmanaTrainChatOn hwndhmanaTrainChatOn gsubmitHealingOptionHandler Checked%manaTrainChatOn% %DisabledChatCondition%, % LANGUAGE = "PT-BR" ? "Não usar com ""chat on""" : "Don't use with ""chat on"""

        manaTrainPZ := healingObj.mana.manaTrainPZ

        Gui, CavebotGUI:Add, Checkbox, xs+10 y+11 vmanaTrainPZ Checked%manaTrainPZ% gsubmitHealingOptionHandler %Disabled% %DisabledProtectionZoneCondition%, % LANGUAGE = "PT-BR" ? "Não usar em área PZ" : "Don't cast in PZ zone"
    }

    /**
    * @return void
    * @msgbox
    */
    loadManaHealingHotkey()
    {
        this.showConfirmationMessage := !GetKeyState("Ctrl")
        try {
            clientOptions := new _ClientOptions()
            this.preset := clientOptions.getPreset()
            action := clientOptions.getManaPotionHotkey()
            if (!action) {
                return this.noActionBarMessage("mana")
            }

            if (!this.loadHotkeyConfimationMessage(action, this.manaHotkey.get(), "", true)) {
                return
            }

            this.manaHotkey.set(action.hotkey)
        } catch e {
            msgbox, 48,, % e.Message, 10
            return
        }

        TrayTipMessage(txt("Hotkeys carregadas com sucesso.", "Hotkeys loaded successfully."), txt("Confirme se as hotkeys estão corretas.", "Confirm if the hotkeys are correct"), 8)
    }

    /**
    * @return void
    * @msgbox
    */
    loadLifeHealingHotkeys()
    {
        this.showConfirmationMessage := !GetKeyState("Ctrl")
        noHotkeyLoaded := true
        try {
            clientOptions := new _ClientOptions()
            this.preset := clientOptions.getPreset()
            action := clientOptions.getHealthPotionHotkey()

            if (!action && (this.preset = _ClientOptions.PRESET_KNIGHT || this.preset = _ClientOptions.PRESET_PALADIN)) {
                this.noActionBarMessage("life")
                return
            }

            lowPotion := ""
            if (this.loadHotkeyConfimationMessage(action, this.lowPotionHotkey.get(), "LowHP Potion", true)) {
                lowPotion := action.value
                this.lowPotionHotkey.set(action.hotkey)
                noHotkeyLoaded := false
            }

            midPotion := ""
            if (this.loadHotkeyConfimationMessage(action, this.midPotionHotkey.get(), "MidHP Potion", true)) {
                midPotion := action.value
                this.midPotionHotkey.set(action.hotkey)
                noHotkeyLoaded := false
            }

            action := new _ClientOptions().getHealthSpellHotkey("highest")
            if (this.loadHotkeyConfimationMessage(action, this.highestHotkey.get(), "highestHP", true)) {
                this.highestHotkey.set(action.hotkey)
                ; this.highestComment.set(action.value)
                noHotkeyLoaded := false
            }

            action := new _ClientOptions().getHealthSpellHotkey("high")
            if (this.loadHotkeyConfimationMessage(action, this.highHotkey.get(), "highHP", true)) {
                this.highHotkey.set(action.hotkey)
                ; this.highComment.set(action.value)
                noHotkeyLoaded := false
            }

            action := new _ClientOptions().getHealthSpellHotkey("mid")
            if (this.loadHotkeyConfimationMessage(action, this.midHotkey.get(), "midHP", true)) {
                this.midHotkey.set(action.hotkey)
                value := midPotion ? action.value " & " midPotion : action.value
                ; this.midComment.set(value)
                noHotkeyLoaded := false
            }

            action := new _ClientOptions().getHealthSpellHotkey("low")
            if (this.loadHotkeyConfimationMessage(action, this.lowHotkey.get(), "lowHP", true)) {
                this.lowHotkey.set(action.hotkey)
                value := lowPotion ? action.value " & " lowPotion : action.value
                ; this.lowComment.set(value)
                noHotkeyLoaded := false
            }

        } catch e {
            msgbox, 48, % this.loadHotkeysTitle(), % e.Message, 20
            return
        }

        if (noHotkeyLoaded) {
            TrayTipMessage("Preset: " this.preset, txt("Nenhuma hotkey foi carregada.", "No hotkey was loaded."), 8)
            return
        }

        TrayTipMessage(txt("Hotkeys carregadas com sucesso.", "Hotkeys loaded successfully."), txt("Confirme se as hotkeys estão corretas.", "Confirm if the hotkeys are correct"), 8)
    }

    /**
    * @return string
    */
    loadHotkeysTitle()
    {
        return txt("Carregar hotkeys do cliente", "Load hotkeys from client") " (preset: " this.preset ")"
    }

    /**
    * @param _ActionBarButton action
    * @param ?string currentHotkey
    * @param ?string rule
    * @param ?bool ignoreMsg
    * @return bool
    */
    loadHotkeyConfimationMessage(action, currentHotkey := "", rule := "", ignoreMsg := false)
    {
        if (!action) {
            return false
        }

        string := "- Item: " action.value "`n- Hotkey: " action.hotkey
        if (currentHotkey && currentHotkey = action.hotkey) {
            if (ignoreMsg) {
                return true
            }

            msgbox, 64, % this.loadHotkeysTitle(), % txt("A hotkey carregada é a mesma hotkey já setada atualmente", "The loaded hotkey is the same hotkey as the currently that is set") ":`n`n" string
            return false
        }

        if (GetKeyState("Ctrl")) {
            Msgbox, 68, % this.loadHotkeysTitle(), % txt("Hotkey encontrada no cliente" (rule ? " para """ rule """" : ""), "Client hotkey found" (rule ? " for """ rule """" : "")) ":`n`n" string "`n`n" txt("Deseja carregar essa hotkey?", "Do you wish to load this hotkey?")
            IfMsgBox, No
                return false
        }

        return true
    }

    /**
    * @param string type
    * @return void
    * @msgbox
    */
    noActionBarMessage(type)
    {
        msgbox, 48, % this.loadHotkeysTitle(), % txt("Não há nenhuma " type " potion na Action Bar.`n`nAdicione algum tipo de " type " potion COM hotkey na Action Bar, RELOGUE o char e tente novamente.", "There is not any " type " potion in the Action Bar.`n`nAdd some type of " type " potion WITH hotkey in the Action Bar, RELOGIN the character, and try again."), 10
    }

    /**
    * @return void
    */
    deleteLifeHealingHotkeys()
    {
        this.highestHotkey.set("")
        this.highHotkey.set("")
        this.midPotionHotkey.set("")
        this.midHotkey.set("")
        this.lowPotionHotkey.set("")
        this.lowHotkey.set("")

        ; this.highestComment.set("")
        ; this.highComment.set("")
        ; this.midComment.set("")
        ; this.lowComment.set("")
    }
}
