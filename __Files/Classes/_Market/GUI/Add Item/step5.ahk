step5()
{
    this.buyOfferPrice()
    this.buyOfferAmount()
    this.buyOfferLimit()
    this.balanceCondition("buyOffer")

    this.nextButton(,,5)
    this.backButton()
    this.closeButton()
}

validateStep5()
{
    static count := 0
    if (count > 1) {
        count := 0
    }

    this.buyOfferPriceError.hide()
    this.noBuyOfferPriceError.hide()

    if (!this.balanceValidation("buyOffer")) {
        return false
    }

    if (!this.itemSetting("buyOfferPrice")) {
        this.buyOfferPriceError.set(txt("Preencha o preço.", "Fill the price.")).show()
        if (!A_IsCompiled) {
            count++
        }

        return count > 1 ? true : false
    }

    if (!this.itemSetting("noBuyOfferPrice") > 0) {
        if (!A_IsCompiled) {
            count++
        }

        this.noBuyOfferPriceError.set(txt("Preencha o preço da opção ""Se não houver nenhuma oferta"".", "Fill the price of the option ""If there is no offer"".")).show()

        return count > 1 ? true : false
    }

    return true
}

buyOfferPrice()
{
    this.titleTextCentered(txt("Criar ofertas de compra e cobrir existentes.", "Create buy offers and cover existing ones."))
    this.titleText(txt("Oferta de compra - preço:", "Buy offer - price:"), 20)

        new _Text().title("Incrementar 1 gp enquanto for menor que", "Increment 1 gp while is less than")
        .xp().yadd(1)
        .add()

    this.price("buyOfferPrice", 29000)

    this.text("gp.")

    this.buyOfferPriceError := new _Text()
        .xs().yadd(7).w(this.guiW - this.paddingRight)
        .color("Red")
        .add()
        .hide()

        new _Text().title("Se não houver nenhuma oferta*, criar a", "If there is no offer*, create at")
        .xp().yadd(5)
        .tt("Valor para criar a oferta quando não houver nenhuma oferta disponível para cobrir.`nEsse valor também é usado como um valor limite para criação de oferta, se o valor da oferta de compra for menor do que esse valor, o bot criará a oferta com esse valor.", "Value to create the offer when there is no offer available to cover.`nThis value is also used as a limit value for offer creation, if the buy offer price is lower than this value, the bot will create the offer with this value.")
        .add()

    this.price("noBuyOfferPrice", "20000")

    this.text("gp.")

    this.noBuyOfferPriceError := this.errorText()

        new _Text().title("Exemplo: para uma ""boots of haste"", incrementar 1 gp enquanto o preço para cobrir a primeira oferta for menor que 29000 gp.`nSe não houver nenhuma oferta, criar a 20000 gp.", "Example: for a ""boots of haste"", increment 1 gp while the price to cover the first offer is less than 29000 gp.`nIf there is no offer, create at 20000 gp.")
        .color("Gray")
        .xs().yadd(5).w(this.guiW - this.paddingRight)
        .add()
}

buyOfferAmount()
{
    this.titleText(txt("Oferta de compra - quantidade:", "Buy offer - amount:"), 20)

    radio1 := this.radio("buyOfferMaximumAmount", txt("Criar oferta com a quantidade máxima possível", "Create offer with the maximum possible amount") "(balance)")
        .tt("A quantidade máxima possível em uma oferta de compra será o quanto de dinheiro você possui no balance.", "The maximum possible amount in a buy offer will be how much money you have in the balance.")

    radio2 := this.offerDefinedAmountRadio("buy")
    radio3 := this.offerExclusiveAmountRadio("buy")

    radio1.related(radio2, radio3)
    radio2.related(radio1, radio3)
    radio3.related(radio1, radio2)
}

buyOfferLimit()
{
    this.titleText(txt("Limitar a quantidade de ofertas criadas:", "Limit the amount of offers created:"), 20)

    this.checkbox("buyOfferCreationLimit", txt("Parar de criar novas ofertas após criar", "Stop creating new offers after creating"))
        .xp().yadd(10)
        .tt("Utilize essa opção para limitar a quantidade de ofertas que você quer que o bot crie e depois pare.`nCom essa opção desmarcada, o bot irá criar ofertas(para cobrir outras) indefinidamente, o que pode causar altos gastos com taxa.", "Use this option to limit the amount of offers you want the bot to create and then stop.`nWith this option unchecked, the bot will create offers(to cover others) indefinitely, which can cause high fee expenses.")
        .add()

    this.amount("buyOfferCreationLimitAmount").add()

    this.text(txt("oferta(s)", "offer(s)") ".")
}
