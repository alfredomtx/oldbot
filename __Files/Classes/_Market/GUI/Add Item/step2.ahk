step2()
{
    this.titleText(txt("Quero que o bot:", "I want the bot to:"))

    this.buyItem := this.checkbox("buyItem", txt("Compre o item de ofertas existentes", "Buy the item from existing offers"))
        .tt("Comprar o item aceitando as ofertas de venda(Sell Offers) existentes.", "Buy the item accepting the existing Sell Offers.")
        .add()

    this.sellItem := this.checkbox("sellItem", txt("Venda o item a ofertas existentes", "Sell the item to existing offers"))
        .tt("Vender o item aceitando as ofertas de compra(Buy Offers) existentes.", "Sell the item accepting the existing Buy Offers.")
        .add()

    this.createBuyOffer := this.checkbox("createBuyOffer", txt("Crie ofertas de compra", "Create buy offers"))
        .tt("Criar ofertas de compra e cobrir ofertas existentes com o preço sempre 1 gp menor.", "Create buy offers and cover existing offers with the price always 1 gp lower.")
        .add()

    this.createSellOffer := this.checkbox("createSellOffer", txt("Crie ofertas de venda", "Create sell offers"))
        .tt("Criar ofertas de venda e cobrir ofertas existentes com o preço sempre 1 gp maior.", "Create sell offers and cover existing offers with the price always 1 gp higher.")
        .add()

    this.nextButton()
    this.backButton()
    this.closeButton()
}