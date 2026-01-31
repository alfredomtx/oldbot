step8()
{
    this.summary()

        new _Button().title("Copiar para o clipboard", "Copy to clipboard")
        .xs().yadd(15).w(w ? w : (this.guiW - this.paddingRight)).h(20)
        .event(this.copySummary.bind(this))
        .icon(_Icon.get(_Icon.CHECK_ROUND_WHITE), "a0 l5 b0 s14")
        .add()


    this.backButton()
    this.closeButton()
}

summary()
{
    this.summaryFontSize := "s11"

    ; new _Text().title(txt("Resumo", "Summary"))
    ; .xs().yadd(15).w(this.guiW - this.paddingRight)
    ; .font("s16")
    ; .center()
    ; .add()

        new _Text().title(string := ("Resumo: " _A.lowerCase(this.itemName)))
        .xs().yadd(15).w(this.guiW - this.paddingRight)
        .font(this.summaryFontSize)
        .center()
        .add()

    this.summaryContent .= string "`n`n`"

    this.buySummary()  
    this.sellSummary()

    this.buyOfferSummary()  
    this.sellOfferSummary()
}

buySummary()
{
    this.summaryTitle(txt("Compra - ofertas existentes:", "Buy - existing offers:"), 5)

    if (!this.itemSetting("buyItem")) {
        this.summaryText("❌ " txt("Você não habilitou a opção de compra do item.", "You have not enabled the item buy option."))

        return
    }

    buyAll := this.itemSetting("buyAll")
    amount := this.itemSetting("buyAmount")
    price := this.itemSetting("buyPrice")

    pt := "Comprar " (buyAll ? "todos(enquanto houver balance)" : "somente " amount " item(s) e parar") ", com valor menor que " price " gp."
    en := "Buy " (buyAll ? "all(while there is balance)" : "only " amount " item(s) and stop") ", with value less than " price " gp."

    type := "buy"
    if (this.itemSetting(type "BalanceCondition")) {
        pt .= this.balanceTextPt(type)
        en .= this.balanceTextEn(type)
    }

    this.summaryText(txt(pt, en))
}

sellSummary()
{
    this.summaryTitle(txt("Venda - ofertas existentes:", "Sell - existing offers:"))

    if (!this.itemSetting("sellItem")) {
        this.summaryText("❌ " txt("Você não habilitou a opção de venda do item.", "You have not enabled the item sell option."))

        return
    }

    buyPrice := this.itemSetting("buyPrice")

    sellAll := this.itemSetting("sellAll")
    sellAmount := this.itemSetting("sellAmount")
    profitByPrice := this.itemSetting("profitByPrice")
    sellPrice := this.itemSetting("sellPrice")
    sellPercentage := this.itemSetting("sellPercentage")

    percentageProfit := this.percentageProfit(buyPrice, sellPercentage)

    pt := "Vender " (sellAll ? "todos os itens" : "somente " sellAmount " item(s) e parar")
    en := "Sell " (sellAll ? "all items" : "only " sellAmount " item(s) and stop")
    if (profitByPrice) {
        pt .= ", com preço maior ou igual a " sellPrice " gp."
        en .= ", with price greater than or equal to " sellPrice " gp."

        profit := (sellPrice - buyPrice)
        profitPercent := (profit / buyPrice) * 100
        pt .= "`nO lucro é de " profit " gp (" profitPercent "%) sob o valor de compra (" buyPrice " gp)."
        en .= "`nThe profit is" profit " gp (" profitPercent "%) over the buy price (" buyPrice " gp)."

    } else {
        pt .= ", com lucro de " sellPercentage "% sob o valor de compra"
        en .= ", with profit of " sellPercentage "% over the buy price"

        pt .= " (" buyPrice " gp)."
        en .= " (" buyPrice " gp)."

        pt .= "`n" sellPercentage "% de " buyPrice " gp são " percentageProfit " gp, a oferta de compra precisará ser de pelo menos " (buyPrice + percentageProfit) " gp para o bot aceitá-la."

        en .= "`n" sellPercentage "% of " buyPrice " gp are " percentageProfit " gp, the buy offer will need to be at least " (buyPrice + percentageProfit) " gp for the bot to accept it."
    }

    this.summaryText(txt(pt, en))
}

buyOfferSummary()
{
    this.summaryTitle(txt("Criar ofertas de compra:", "Create buy offers:"))

    if (!this.itemSetting("createBuyOffer")) {
        this.summaryText("❌ " txt("Você não habilitou a opção de criar ofertas de compra do item.", "You have not enabled the item create buy offers option."))

        return
    }

    maximumAmount := this.itemSetting("buyOfferMaximumAmount")
    amount := this.itemSetting("buyOfferAmount")
    price := this.itemSetting("buyOfferPrice")
    noOfferPrice := this.itemSetting("noBuyOfferPrice")
    limit := this.itemSetting("buyOfferCreationLimit")
    limitAmount := this.itemSetting("buyOfferCreationLimitAmount")

    pt := "Criar cada oferta com " (maximumAmount ? "a quantidade máxima possível(enquanto houver balance)" : "no máximo " amount " item(s)") ".`nIncrementando 1 gp enquanto o preço para cobrir a oferta for menor que " price " gp."
    en := "Create each offer with " (maximumAmount ? "the maximum possible amount(while there is balance)" : "at most " amount " item(s)") ".`nIncreasing 1 gp while the price to cover the offer is less than " price " gp."

    pt .= "`nSe não houver nenhuma oferta de compra, o bot irá criar uma com o valor de " noOfferPrice " gp."
    en .= "`nIf there is no buy offer, the bot will create one with the value of " noOfferPrice " gp."

    pt .= limit ? "`nO bot irá criar " limitAmount " ofertas de compra e parar." : "`nO bot irá criar ofertas de compra indefinidamente(sem limite de vezes)."
    en .= limit ? "`nThe bot will create " limitAmount " buy offers and stop." : "`nThe bot will create buy offers indefinitely(no limit of times)."


    type := "buyOffer"
    if (this.itemSetting(type "BalanceCondition")) {
        pt .= this.balanceTextPt(type)
        en .= this.balanceTextEn(type)
    }

    this.summaryText(txt(pt, en))
}

sellOfferSummary()
{
    this.summaryTitle(txt("Criar ofertas de venda:", "Create sell offers:"))

    if (!this.itemSetting("createSellOffer")) {
        this.summaryText("❌ " txt("Você não habilitou a opção de criar ofertas de venda do item.", "You have not enabled the item create sell offers option."))

        return
    }

    buyPrice := this.itemSetting("buyOfferPrice")

    sellAll := this.itemSetting("sellOfferMaximumAmount")
    sellAmount := this.itemSetting("sellOfferAmount")
    profitByPrice := this.itemSetting("offerProfitByPrice")
    sellPrice := this.itemSetting("sellOfferPrice")
    sellPercentage := this.itemSetting("sellOfferPercentage")

    percentageProfit := this.percentageProfit(buyPrice, sellPercentage)

    pt := "Criar oferta com " (sellAll ? "a quantidade máxima possível(enquanto houver itens)" : "no máximo " sellAmount " item(s)") "."
    pt .= "`nDecrementando 1 gp "
    en := "Create offer with " (sellAll ? "the maximum possible amount(while there are items)" : "at most " sellAmount " item(s)") "."
    en .= "`nDecreasing 1 gp "

    if (profitByPrice) {
        pt .= "enquanto o preço maior ou igual a " sellPrice " gp."
        en .= "while price greater than or equal to " sellPrice " gp."

        profit := (sellPrice - buyPrice)
        profitPercent := (profit / buyPrice) * 100
        pt .= "`nO lucro é de " profit " gp (" profitPercent "%) sob o valor da oferta de compra (" buyPrice " gp)."
        en .= "`nThe profit is" profit " gp (" profitPercent "%) over the buy offer price (" buyPrice " gp)."

    } else {
        pt .= "enquanto o lucro for de " sellPercentage "% sob o valor da oferta de compra"
        en .= "while profit is " sellPercentage "% over the buy offer price"

        pt .= " (" buyPrice " gp)."
        en .= " (" buyPrice " gp)."

        pt .= "`n" sellPercentage "% de " buyPrice " gp são " percentageProfit " gp, o bot irá cobrir ofertas de venda de até " (buyPrice + percentageProfit) " gp."

        en .= "`n" sellPercentage "% of " buyPrice " gp are " percentageProfit " gp, the bot will cover sell offers up to " (buyPrice + percentageProfit) " gp."
    }

    this.summaryText(txt(pt, en))
}

balanceTextPt(type)
{
    return "`n- Balance: irá ignorar a oferta se o balance for menor que " this.itemSetting(type "BalanceAmount") " gp."
}

balanceTextEn(type)
{
    return "`n- Balance: will ignore the offer if the balance is less than " this.itemSetting(type "BalanceAmount") " gp."
}

summaryTitle(text, y := 20)
{
        new _Text().title(text)
        .xs().yadd(y).w(this.guiW - this.paddingRight)
        .font("s14")
        .add()

    this.summaryContent .= text "`n"
}

summaryText(text)
{
        new _Text().title(text)
        .xs().yadd(3).w(this.guiW - this.paddingRight)
        .font(this.summaryFontSize)
        .add()

    this.summaryContent .= text "`n`n"
}

percentageProfit(buyPrice, sellPercentage)
{
    return (buyPrice * sellPercentage) / 100
}

copySummary()
{
    copyToClipboard(this.summaryContent)

        new _Notification().title(txt("Resumo", "Summary") " " _Str.withSpaces(this.itemName))
        .message(txt("Copiado para o clipboard (Ctrl+V para colar)", "Copied to clipboard (Ctrl+V to paste)"))
        .show()
}
