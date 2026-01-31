#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_GUI.ahk

Class _ToolWaypointGUI extends _GUI
{
    static ITEM_ICON_OPTIONS := "a0 l5 b0 t0 s30"
    static BUTTON_WIDTH := 180

    /**
    * @param ?string title
    */
    __New()
    {
        base.__New("toolWaypoint", "Tool Waypoint")

        this.guiW := this.BUTTON_WIDTH + 20
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

        this.createControls()

        _AbstractControl.RESET_DEFAULT_GUI()
    }

    /**
    * @return void
    */
    createControls()
    {
        itemsList := ["rope", "shovel", "machete"]
        this.addMenuItem(controlName := "tool", itemsList, txt("Selecione o item", "Select the item"), y := 5, _A.first(itemList))

            new _Button().title("Add Waypoint")
            .xs().yadd(10).w(this.BUTTON_WIDTH).h(25)
            .event(this.addWaypoint.bind(this, controlName))
            .add()
    }

    addWaypoint(controlName)
    {
        itemName := this[controlName].edit.get()
        if (!itemName) {
            return
        }

        this.close()

        global GUIControl := "AddWaypoint_UseTool"
        global type := ucfirst(itemName)

        gosub, AddWaypoint
    }

    addMenuItem(name, itemsList, firstOption, y := 10, itemName := "")
    {
        global w_group, xs

        this[name] := {}

        this[name].menu := new _ItemsMenu(itemsList, this.menuCallback.bind(this, name), name)
            .text(firstOption)
            .create()

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
