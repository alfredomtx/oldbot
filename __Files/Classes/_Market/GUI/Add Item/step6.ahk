step6()
{
    this.sellOfferPrice()
    this.sellOfferAmount()
    this.sellOfferLimit()

    this.nextButton()
    this.backButton()
    this.closeButton()
}

validateStep6()
{
    static count := 0
    if (count > 1) {
        count := 0
    }

    this.sellOfferPriceError.hide()
    this.noSellOfferPriceError.hide()

    if (this.itemSetting("offerProfitByPrice") && !this.itemSetting("sellOfferPrice")) {
        this.sellOfferPriceError.set(txt("Preencha o preço ""maior que"".", "Fill the ""greater than"" price.")).show()
        if (!A_IsCompiled) {
            count++
        }

        return count > 1 ? true : false
    }

    if (!this.itemSetting("noSellOfferPrice") > 0) {
        if (!A_IsCompiled) {
            count++
        }

        this.noSellOfferPriceError.set(txt("Preencha o preço da opção ""Se não houver nenhuma oferta"".", "Fill the price of the option ""If there is no offer"".")).show()

        return count > 1 ? true : false
    }

    return true
}

sellOfferPrice()
{
    this.titleTextCentered(txt("Criar ofertas de venda e cobrir existentes.", "Create sell offers and cover existing ones."))
    this.titleText(txt("Oferta de venda - preço:", "Sell offer - price:"), 20)

        new _Text().title("Decrementar 1 gp enquanto:", "Decrement 1 gp while:")
        .xp().yadd(5)
        .add()

    radio1 := new _Radio().name("offerProfitByPrice")
        .title("For maior que", "Is greater than")
        .xs().yadd(10)
        .placeholder("31000")
        .nested(this.itemName)
        .beforeEvent(this.changeFormButtons.bind(this, "disable"))
        .afterEvent(this.changeFormButtons.bind(this, "enable"))
        .afterSubmit(this.toggleOfferProfitTextElements.bind(this, "disable"))
        .afterSubmit(this.loadItemList.bind(this))
        .add()

    this.price("sellOfferPrice", 31000)

    this.text("gp")

    this.sellOfferPriceError := this.errorText()

    radio2 := new _Radio().name("offerProfitByPercentage")
        .title("O lucro for", "The profit is")
        .nested(this.itemName)
        .xs().yadd(5)
        .parent(radio1)
        .beforeEvent(this.changeFormButtons.bind(this, "disable"))
        .afterEvent(this.changeFormButtons.bind(this, "enable"))
        .afterSubmit(this.toggleOfferProfitTextElements.bind(this, "enable"))
        .afterSubmit(this.loadItemList.bind(this))
        .add()

        new _Edit().name("sellOfferPercentage")
        .nested(this.itemName)
        .xadd(1).yp(-2).w(30).h(18)
        .placeholder("20")
        .numeric()
        .rule(new _ControlRule().default(new _MarketItemSettings().getAttribute("sellOfferPercentage")))
        .afterSubmit(this.updateOfferProfitElements.bind(this))
        .beforeEvent(this.changeFormButtons.bind(this, "disable"))
        .afterEvent(this.changeFormButtons.bind(this, "enable"))
        .add()

    this.text(txt("% sob o valor da oferta de compra", "% over the buy offer price"), x := 3)

    radio1.related(radio2)
    radio2.related(radio1)

    this.calculatedOfferElements()

    this.sellOfferPriceError := new _Text()
        .xs().yadd(7).w(this.guiW - this.paddingRight)
        .color("Red")
        .add()
        .hide()

        new _Text().title("Se não houver nenhuma oferta*, criar a", "If there is no offer*, create at")
        .xp().yadd(5)
        .tt("Valor para criar a oferta quando não houver nenhuma oferta disponível para cobrir.`nEsse valor também é usado como um valor limite para criação de oferta, se o valor da oferta de venda for maior do que esse valor, o bot criará a oferta com esse valor.", "Value to create the offer when there is no offer available to cover.`nThis value is also used as a limit value for offer creation, if the sell offer price is higher than this value, the bot will create the offer with this value.")
        .add()

    this.noSellOfferPrice := this.price("noSellOfferPrice", "45000")

    this.text("gp.")

    this.noSellOfferPriceError := this.errorText()
}

sellOfferAmount()
{
    this.titleText(txt("Oferta de venda - quantidade:", "Sell offer - amount:"), 5)

    radio1 := new _Radio().name("sellOfferMaximumAmount")
        .title(txt("Criar oferta com a quantidade máxima possível(itens)", "Create offer with the maximum possible amount(items)"))
        .tt("A quantidade máxima possível em uma oferta de venda será a quantidade de itens que o você possui no depot.", "The maximum possible amount in a sell offer will be the amount of items you have in the depot.")
        .nested(this.itemName)
        .xs().yadd(10)
        .beforeEvent(this.changeFormButtons.bind(this, "disable"))
        .afterEvent(this.changeFormButtons.bind(this, "enable"))
        .afterSubmit(this.loadItemList.bind(this))
        .add()

    radio2 := this.offerDefinedAmountRadio("sell")
    radio3 := this.offerExclusiveAmountRadio("sell")

    radio1.related(radio2, radio3)
    radio2.related(radio1, radio3)
    radio3.related(radio1, radio2)
}

sellOfferLimit()
{
    this.titleText(txt("Limitar a quantidade de ofertas criadas:", "Limit the amount of offers created:"), 20)

        new _Checkbox().name("sellOfferCreationLimit")
        .title("Parar de criar novas ofertas após criar", "Stop creating new offers after creating")
        .nested(this.itemName)
        .xp().yadd(10)
        .tt("Com essa opção desmarcada, o bot irá criar ofertas(para cobrir outras) indefinidamente, o que pode causar altos gastos com taxa.`nUtilize essa opção para limitar a quantidade de ofertas que você quer que o bot crie e depois pare.", "With this option unchecked, the bot will create offers(to cover others) indefinitely, which can cause high fee expenses.`nUse this option to limit the amount of offers you want the bot to create and then stop.")
        .beforeEvent(this.changeFormButtons.bind(this, "disable"))
        .afterEvent(this.changeFormButtons.bind(this, "enable"))
        .afterSubmit(this.loadItemList.bind(this))
        .add()

    this.amount("sellOfferCreationLimitAmount").add()

    this.text(txt("oferta(s)", "offer(s)") ".")
}

calculatedOfferElements()
{
    color := "2335da"
    this.buyPriceOfferText := new _Text().title(txt("Valor oferta de compra: ", "Buy offer price: "))
        .xs().yadd(10)
        .color(color)
        .add()

    this.buyOfferPriceOfferText := new _Text().title(this.itemSetting("buyOfferPrice") " gp")
        .xadd(1).yp()
        .color(color)
        .add()

    this.profitOfferText := new _Text().title(txt("Lucro de xxx%: ", "Profit of xxx%: "))
        .xs().yadd(5)
        .color(color)
        .add()

    this.calculatedProfitOfferText := new _Text()
        .xadd(1).yp().w(this.guiW - this.paddingRight)
        .color(color)
        .add()

    this.offerPriceOfferText := new _Text().title(txt("Valor da oferta: ", "Offer price: "))
        .xs().yadd(5)
        .color(color)
        .add()

    this.calculatedOfferPriceOfferText := new _Text()
        .xadd(1).yp().w(this.guiW - this.paddingRight)
        .color(color)
        .add()


    this.toggleOfferProfitTextElements(this.itemSetting("offerProfitByPrice") ? "disable" : "enable")
    this.updateOfferProfitElements()
}

toggleOfferProfitTextElements(action)
{
    (action = "disable") ? this.buyPriceOfferText.disable() : this.buyPriceOfferText.enable()
    (action = "disable") ? this.buyOfferPriceOfferText.disable() : this.buyOfferPriceOfferText.enable()
    (action = "disable") ? this.profitOfferText.disable() : this.profitOfferText.enable()
    (action = "disable") ? this.calculatedProfitOfferText.disable() : this.calculatedProfitOfferText.enable()
    (action = "disable") ? this.offerPriceOfferText.disable() : this.offerPriceOfferText.enable()
    (action = "disable") ? this.calculatedOfferPriceOfferText.disable() : this.calculatedOfferPriceOfferText.enable()
}

updateOfferProfitElements()
{
    price := this.itemSetting("buyOfferPrice")
    percentage := this.itemSetting("sellOfferPercentage")
    profit := this.percentageProfit(price, percentage)

    this.profitOfferText.set(txt("Lucro de " percentage "%: ", "Profit of " percentage "%: "))
    this.calculatedProfitOfferText.set(profit " gp")
    this.calculatedOfferPriceOfferText.set((profit + price) " gp")
}
