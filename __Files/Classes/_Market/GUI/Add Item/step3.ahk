step3()
{
    this.buyPrice()
    this.buyAmount()
    this.balanceCondition("buy")

    this.nextButton(,,5)
    this.backButton()
    this.closeButton()
}

validateStep3()
{
    this.buyPriceError.hide()

    if (!this.itemSetting("buyPrice") > 0) {
        this.buyPriceError.set(txt("Preencha o preço de compra.", "Fill the buy price.")).show()
        return false
    }

    if (!this.balanceValidation("buy")) {
        return false
    }

    return true
}

buyPrice()
{
    this.titleTextCentered(txt("Comprar de ofertas existentes.", "Buy from existing offers."))
    this.titleText(txt("Comprar - preço:", "Buy - price:"), 20)

        new _Text().title("Se menor que", "If less than")
        .xp().yadd(10)
        .tt(txt("Preço para comprar o item(aceitar oferta de compra)", "Price to buy the item(accept buy offer)"))
        .add()

    this.price("buyPrice", 29000)

    this.text("gp")

    this.buyPriceError := this.errorText()
}

buyAmount()
{
    this.titleText(txt("Comprar - quantidade:", "Buy - amount:"), 10)

    radio1 := new _Radio().name("buyAll")
        .title("Comprar todos, enquanto houver balance", "Buy all, while there is balance")
        .nested(this.itemName)
        .xp().yadd(10)
        .tt(txt("Continuar comprando o item até que o balance seja menor do que o preço da oferta(insuficiente)", "Continue buying the item until the balance is less than the offer price(insufficient)"))
        .beforeEvent(this.changeFormButtons.bind(this, "disable"))
        .afterEvent(this.changeFormButtons.bind(this, "enable"))
        .afterSubmit(this.loadItemList.bind(this))
        .add()


    radioTt := txt("Comprar a quantidade especificada do item e não realizar nenhuma nova compra", "Buy the specified amount of the item and do not make any new purchases")
    radio2 := new _Radio().name("buyAmountAndStop")
        .title("Comprar")
        .xp().yadd(10)
        .nested(this.itemName)
        .tt(radioTt)
        .parent(radio1)
        .beforeEvent(this.changeFormButtons.bind(this, "disable"))
        .afterEvent(this.changeFormButtons.bind(this, "enable"))
        .afterSubmit(this.loadItemList.bind(this))
        .add()

    this.amount("buyAmount").add()

    this.text(txt("item(s) e parar", "item(s) and stop"))

    radio1.related(radio2)
    radio2.related(radio1)
}
