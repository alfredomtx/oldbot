
step1()
{
    this.titleText(txt("Nome do item:", "Item name:"))

    this.item := new _Edit().name("item")
        .xp().yadd(3).w(this.guiW - this.paddingRight).h(20)
        .placeholder("boots of haste")
        .afterSubmit(this.validateItemName.bind(this))
        .state(_MemorySettings)
        .beforeEvent(this.changeFormButtons.bind(this, "disable"))
        .disabled(_Market.itemLimitExceeded())
        .add()

    this.itemError := new _Text()
        .xp().yadd(3).w(this.guiW - this.paddingRight).h(28)
        .color("Red")
        .add()

    this.nextButton()
    this.closeButton()
}

afterOpenStep1()
{
    if (!empty(this.item.get())) {
        this.nextBtn.enable()
    }
}

validateStep1()
{
    itemName := this.item.get()
    if (!this.validateItem(itemName)) {
        return false
    }

    ; if (itemsObj && !itemsObj.hasKey(itemName)) {
    ;     this.itemError.set(txt("Item não existe no ItemList (aba Looting).", "Item not found in the ItemList (Looting tab).")).show()
    ;     return false
    ; }

    return true
}

validateItem(item)
{
    if (empty(item)) {
        this.itemError.set(txt("Preencha o nome do item.", "Fill the item name.")).show()
        return
    }

    return true
}

validateItemName(control, item)
{
    this.itemError.hide()

    if (!this.validateItem(item)) {
        try {
            this.next.disable()
        } catch e {
            ; _Logger.msgboxException(e 4)
        }

        return
    }

    this.enableButtons()
}

enableButtons()
{
    this.nextBtn.disable()
    this.closeBtn.disable()


    this.nextFn := this.nextBtn.enable.bind(this.nextBtn)
    this.closeFn := this.closeBtn.enable.bind(this.closeBtn)

    fn := this.nextFn
    SetTimer, % fn, Delete
    SetTimer, % fn, -1500

    fn := this.closeFn
    SetTimer, % fn, Delete
    SetTimer, % fn, -1500
}