#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_GUI.ahk

Class _RunemakerGUI extends _GUI
{
    static ITEM_ICON_OPTIONS := "a0 l5 b0 t0 s30"
    static BUTTON_WIDTH := 200
    static CHECKBOX_MT := 5
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @param ?string title
    */
    __New()
    {
        base.__New("runemaker", "Runemaker")

        this.guiW := 410
        this.textW := 100
        this.editW := 70

        this.onCreate(this.create.bind(this))
            .y(100).w(this.guiW)
            .withoutMinimizeButton()
        ; .alwaysOnTop()
        ; .withoutWindowButtons()
    }

    /**
    * @abstract
    * @return void
    */
    create()
    {
        _AbstractControl.SET_DEFAULT_GUI(this)
        _AbstractStatefulControl.SET_DEFAULT_STATE(_RunemakerSettings)

        this.createControls()

        _AbstractControl.RESET_DEFAULT_GUI()
        _AbstractStatefulControl.RESET_DEFAULT_STATE()
    }

    /**
    * @return void
    */
    createControls()
    {
        disabled := !isTibia74()
            new _Checkbox().title("&Runemaker " txt("Ativado","Enabled") " (BETA)")
            .prefix(_Runemaker.IDENTIFIER)
            .name(_AbstractSettings.ENABLED_KEY)
            .xs().yadd(5)
            .afterSubmit(_Runemaker.toggleEvent.bind(_Runemaker))
            .disabled(disabled)
            .tt("Iniciar o módulo do Runemaker.", "Start the Runemaker module.")
            .add()

        if (disabled) {
                new _Text().title("Compatível somente com clientes Tibia 7.4-8.0.", "Compatible only with Tibia clients 7.4-8.0.")
                .x().yp()
                .color("red")
                .add()
        }

        this.setup()
        this.actions()
        this.extras()

            new _Picture()
            .image(_Folders.IMAGES_GUI_RUNEMAKER "\backpack.png" )
            .x(this.BUTTON_WIDTH + 20).y(20)
            .add()
    }

    setup()
    {
            new _Text().title("Setup")
            .xs().yadd(10)
            .bold()
            .add()

            new _Text().title("Hotkey da magia", "Spell hotkey")
            .xs().yadd(10)
            .tt("Hotkey da magia para fazer a runa", "Spell hotkey to make the rune")
            .add()


            new _Hotkey()
            .name("spellHotkey")
            .x().yp(-2).w(this.editW).h(18)
            .center()
            .parent()
            .add()

            new _Text().title(txt("A magia será usada quando a mana estiver acima de 95%.", "The spell will be used when the mana is above 95%."))
            .xs().yadd(5).w(this.BUTTON_WIDTH)
            .color("gray")
            .add()

        ; itemsList := ItemsHandler.getItemListArray("", {1: "Attack Runes"}, "light|field|soulfire|stalagmite")
        ; this.addMenuItem("rune", itemsList, txt("Selecione a runa que será feita", "Select the rune that will be made"))
    }

    actions()
    {
            new _Text().title(txt("Ações", "Actions"))
            .xs().yadd(10)
            .bold()
            .add()

            new _Checkbox().title("Mover blank rune para a mão", "Move blank rune to hand")
            .name("moveBlankToHand")
            .xs().yadd(10)
            .tt("Mover a blank rune para a mão antes de usar a magia para fazer a runa.", "Move the blank rune to the hand before using the spell to make the rune.")
            .add()

            new _Checkbox().title("Abrir próxima backpack", "Open next backpack")
            .name("openNextBackpack")
            .xs().yadd(this.CHECKBOX_MT)
            .tt("Abrir a próxima backpack quando a atual estiver cheia e sem nenhuma blank rune dentro.", "Open the next backpack when the current one is full and without any blank rune inside.")
            .add()

            new _Checkbox().title("Logout sem blank rune", "Logout without blank rune")
            .name("logoutWithoutBlankRune")
            .xs().yadd(this.CHECKBOX_MT)
            .tt("Logout quando não houver nenhuma blank rune visível na tela(em alguma backpack).", "Logout when there is no blank rune visible on the screen(in any backpack).")
            .add()
    }

    extras()
    {
            new _Text().title("Extras")
            .xs().yadd(10)
            .bold()
            .add()

            new _Checkbox().title("Anti AFK")
            .nested("antiIdle")
            .name("enabled")
            .xs().yadd(10)
            .tt("Girar o personagem a cada " _Runemaker.ANTI_IDLE_MINUTES " minutos para evitar o kick por inatividade.", "Rotate the character every " _Runemaker.ANTI_IDLE_MINUTES " minutes to avoid being kicked for inactivity.")
            .add()

            new _Checkbox().title(txt("Pausar Fishing", "Pause Fishing") " - " txt("Em breve!","Soon!"))
            .nested("pauseFishing")
            .name("enabled")
            .disabled()
            .xs().yadd(this.CHECKBOX_MT)
            .add()

            new _Checkbox().title("Eat food")
            .nested("eatFood")
            .name("enabled")
            .xs().yadd(this.CHECKBOX_MT)
            .tt("Comer a comida selecionada a cada " _Runemaker.FOOD_INTERVAL_MINUTES " minuto(s).", "Eat the selected food every " _Runemaker.FOOD_INTERVAL_MINUTES " minute(s).")
            .add()

        itemsList := ItemsHandler.getItemListArray("white mushroom|brown mushroom|meat|fish|ham|cheese|bread|orange", {1: "Food"}, "_|burguer|sand|soft|stock|rat|ginger|roast|bug|north|cookie")
        this.addMenuItem("food", itemsList, txt("Selecione a comida", "Select the food"), y := 5, "eatFood")
    }

    addMenuItem(name, itemsList, firstOption, y := 10, nested := "")
    {
        global w_group, xs

        this[name] := {}

        this[name].menu := new _ItemsMenu(itemsList, this.menuCallback.bind(this, name), name)
            .text(firstOption)
            .create()

        itemName := new _RunemakerSettings().get(name, nested)

        this[name].button := new _Button().title(itemName ? itemName : this[name].menu.getFirst().getTitle())
            .x(10).yadd(y).w(this.BUTTON_WIDTH).h(buttonHeight := 38)
            .event(this.showMenu.bind(this, name))

        if (itemName) {
            icon := _BitmapIcon.FROM_ITEM(itemName)
            if (icon) {
                this[name].button.icon(icon, this.ITEM_ICON_OPTIONS)
            }
        }

        this[name].button.add()

        this[name].edit := new _Edit().name(name)
            .xp(0).yp(0).w(this.BUTTON_WIDTH).h(buttonHeight)
        ; .xp(0).yadd(1).w(buttonWidth).h(buttonHeight)
            .hidden(true)
        if (nested) {
            this[name].edit.nested(nested)
        }

        this[name].edit.add()

        this[name].changeImageButton := new _Button().title(txt("Alterar imagem do item", "Change item image"))
            .xp(0).yadd(3).w(this.BUTTON_WIDTH).h(18)
            .tt(txt("Caso a sprite(imagem) do item esteja diferente da sprite do item no OT server que você está jogando, é necessário alterar a imagem do item no bot na aba Looting -> ItemList para que o bot consiga localizar o item na tela.", "If the item sprite(image) is different from the item sprite in the OT server you are playing, it's necessary to change the item image in the bot in the Looting -> ItemList tab so the bot can find the item on the screen."))
            .event(this.changeItemImage.bind(this, name))
            .disabled(empty(itemName))
            .add()
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

}
