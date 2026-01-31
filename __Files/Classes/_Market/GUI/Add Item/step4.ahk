step4()
{
    this.sellPrice()
    this.sellAmount()

    this.nextButton()
    this.backButton()
    this.closeButton()
}

validateStep4()
{
    static count := 0
    this.sellPriceError.hide()

    if (this.itemSetting("profitByPrice")) {
        price := this.itemSetting("sellPrice")
        if (!price) {
            this.sellPriceError.set(txt("Preencha o preço de venda.", "Fill the sell price.")).show()
            if (!A_IsCompiled) {
                count++
            }

            return count > 1 ? true : false
        }

        buyPrice := this.itemSetting("buyPrice")
        if (this.itemSetting("buyItem") && buyPrice >= price) {
            this.sellPriceError.set(txt("O preço deve ser maior que o preço de compra", "The price must be higher than the buy price") " (" buyPrice " gp)").show()
            if (!A_IsCompiled) {
                count++
            }

            return count > 1 ? true : false
        }

    }

    return true
}

sellPrice()
{
    this.titleTextCentered(txt("Vender para ofertas existentes.", "Sell to existing offers."))

    this.titleText(txt("Vender - preço:", "Sell - price:"), 20)

    radio1 := new _Radio().name("profitByPrice")
        .title("Se maior ou igual a", "If greater than or equal to")
        .xs().yadd(10)
        .placeholder("31000")
        .nested(this.itemName)
        .beforeEvent(this.changeFormButtons.bind(this, "disable"))
        .afterEvent(this.changeFormButtons.bind(this, "enable"))
        .afterSubmit(this.toggleProfitTextElements.bind(this, "disable"))
        .afterSubmit(this.loadItemList.bind(this))
        .add()

    this.price("sellPrice", 31000)

    this.text("gp")

    radio2 := new _Radio().name("profitByPercentage")
        .title("Se o lucro for", "If profit is")
        .nested(this.itemName)
        .xs().yadd(10)
        .parent(radio1)
        .beforeEvent(this.changeFormButtons.bind(this, "disable"))
        .afterEvent(this.changeFormButtons.bind(this, "enable"))
        .afterSubmit(this.toggleProfitTextElements.bind(this, "enable"))
        .afterSubmit(this.loadItemList.bind(this))
        .add()

        new _Edit().name("sellPercentage")
        .nested(this.itemName)
        .xadd(1).yp(-2).w(30).h(18)
        .placeholder("20")
        .numeric()
        .rule(new _ControlRule().default(new _MarketItemSettings().getAttribute("sellPercentage")))
        .afterSubmit(this.updateProfitElements.bind(this))
        .beforeEvent(this.changeFormButtons.bind(this, "disable"))
        .afterEvent(this.changeFormButtons.bind(this, "enable"))
        .add()

    this.text(txt("% sob o valor de compra", "% over the buy price"), x := 3)

    radio1.related(radio2)
    radio2.related(radio1)

    this.calculatedElements()

    this.sellPriceError := new _Text()
        .xs().yadd(7).w(this.guiW - this.paddingRight)
        .color("Red")
        .add()
        .hide()
}

sellAmount()
{
    this.titleText(txt("Vender - quantidade:", "Sell - amount:"), 10)

    radio1 := new _Radio().name("sellAll")
        .title("Vender todos", "Sell all")
        .nested(this.itemName)
        .xp().yadd(10)
        .beforeEvent(this.changeFormButtons.bind(this, "disable"))
        .afterEvent(this.changeFormButtons.bind(this, "enable"))
        .afterSubmit(this.loadItemList.bind(this))
        .add()

    radio2 := new _Radio().name("sellAmountAndStop")
        .title("Vender")
        .xp().yadd(10)
        .nested(this.itemName)
        .parent(radio1)
        .beforeEvent(this.changeFormButtons.bind(this, "disable"))
        .afterEvent(this.changeFormButtons.bind(this, "enable"))
        .afterSubmit(this.loadItemList.bind(this))
        .add()

    this.amount("sellAmount").add()

    this.text(txt("item(s) e parar", "item(s) and stop"))

    radio1.related(radio2)
    radio2.related(radio1)
}

calculatedElements()
{
    color := "2335da"

    this.buyPriceText := new _Text().title(txt("Valor de compra: ", "Buy price: "))
        .xs().yadd(10)
        .color(color)
        .add()

    this.buyOfferPriceText := new _Text().title(this.itemSetting("buyPrice") " gp")
        .xadd(1).yp()
        .color(color)
        .add()

    this.profitText := new _Text().title(txt("Lucro de xxx%: ", "Profit of xxx%: "))
        .xs().yadd(5)
        .color(color)
        .add()

    this.calculatedProfitText := new _Text()
        .xadd(1).yp().w(this.guiW - this.paddingRight)
        .color(color)
        .add()

    this.offerPriceText := new _Text().title(txt("Valor da oferta: ", "Offer price: "))
        .xs().yadd(5)
        .color(color)
        .add()

    this.calculatedOfferPriceText := new _Text()
        .xadd(1).yp().w(this.guiW - this.paddingRight)
        .color(color)
        .add()


    this.toggleProfitTextElements(this.itemSetting("profitByPrice") ? "disable" : "enable")
    this.updateProfitElements()
}

toggleProfitTextElements(action)
{
    (action = "disable") ? this.buyPriceText.disable() : this.buyPriceText.enable()
    (action = "disable") ? this.buyOfferPriceText.disable() : this.buyOfferPriceText.enable()
    (action = "disable") ? this.profitText.disable() : this.profitText.enable()
    (action = "disable") ? this.calculatedProfitText.disable() : this.calculatedProfitText.enable()
    (action = "disable") ? this.offerPriceText.disable() : this.offerPriceText.enable()
    (action = "disable") ? this.calculatedOfferPriceText.disable() : this.calculatedOfferPriceText.enable()
}

updateProfitElements()
{
    price := this.itemSetting("buyPrice")
    percentage := this.itemSetting("sellPercentage")
    profit := this.percentageProfit(price, percentage)
    this.profitText.set(txt("Lucro de " percentage "%: ", "Profit of " percentage "%: "))

    this.calculatedProfitText.set(profit " gp")
    this.calculatedOfferPriceText.set((profit + price) " gp")
}