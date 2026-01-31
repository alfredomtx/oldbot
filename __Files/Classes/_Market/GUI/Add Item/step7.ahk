step7()
{
    this.offerCreationOptions()
    this.searchOptions()

    this.nextButton()
    this.backButton()
    this.closeButton()
}

offerCreationOptions()
{
    this.titleTextCentered(txt("Configurações avançadas*", "Advanced settings*"))

        new _Text().title("*Atenção: não é recomendado alterar as configurações abaixo, na dúvida, deixe as opções no seu valor padrão e continue para o próximo passo.", "*Attention: it is not recommended to change the settings below, in doubt, leave the options at their default value and continue to the next step.")
        .color("Red")
        .xs().yadd(10).w(this.guiW - this.paddingRight)
        .add()

    this.titleText(txt("Criação de ofertas:", "Offer creation:"), 10)

    this.anonymousCheckbox()
    this.coverAmount()
    this.selectModifierAmount()

}

searchOptions()
{
    this.itemSearchName()
    this.itemPositionOnList()
}

coverAmount()
{
        new _Text().title("Incrementar ou decrementar ofertas com", "Increment or decrement offers by")
        .xp().yadd(10)
        .tt("Por padrão o bot incrementa/decrementa ofertas com 1 gp de diferença, utilize essa opção caso você queira alterar este valor.", "By default the bot increments/decrements offers by 1 gp difference, use this option if you want to change this value.")
        .add()

    this.price("coverOfferAmount", 1)

    this.text("gp(s).")
}

selectModifierAmount()
{
        new _Text().title("Quantidade unitária do item ao selecionar: ", "Unit quantity of the item when selecting: ")
        .xs().yadd(15)
        .tt("A maioria dos itens possuem quantidade unitária para selecionar ao criar uma oferta no Market. Porém outros itens como ""Tibia Coins"", só é possível selecionar de 5 em 5 itens na maioria dos OTs.`n`nNesse caso, é necessário utilizr essa opção para alterar o valor padrão de 1 para 5 para que o bot consiga selecionar corretamente a quantidade de itens para itens como ""Tibia Coins"".", "Most items have a unit quantity to select when creating an offer on the Market. However, other items like ""Tibia Coins"", it is only possible to select 5 items at a time on most OTs.`n`nIn this case, it is necessary to use this option to change the default value from 1 to 5 so that the bot can correctly select the quantity of items for items like ""Tibia Coins"".")
        .add()

    this.amount("itemUnitAmount")
        .placeholder("1")
        .add()

    this.text("item(s).")
}

anonymousCheckbox()
{
    this.checkbox("createAnonymousOffers", txt("Criar ofertas como ""Anonymous""", "Create offers as ""Anonymous"""))
        .xs().yadd(10)
        .tt("Por padrão o bot sempre cria ofertas como ""Anonymous"", caso você queira criar ofertas com o nome do seu personagem, desmarque essa opção.", "By default the bot always creates offers as ""Anonymous"", if you want to create offers with your character's name, uncheck this option.")
        .add()
}

itemSearchName()
{
    this.titleText(txt("Pesquisa do item:", "Item search:"), 20)

    this.checkbox("searchUsingAnotherName", txt("Pesquisar item usando outro nome:", "Search item by using another name:"))
        .xs().yadd(10)
        .tt("Por padrão o bot pesquisa pelo item utilizando o nome do item definido no Passo 1. Porém para alguns itens pode ser necessário pesquisar por outro nome.`n`nPor exemplo: para pesquisar pelo ""ferumbras' hat"", será necessário ativar e usar essa opção para que o bot pesquise sem remover os caractéres especiais do nome(nesse exemplo, o apóstrofe).", "By default the bot searches for the item using the item name defined in Step 1. However, for some items it may be necessary to search by another name.`n`nFor example: to search for ""ferumbras' hat"", it will be necessary to activate and use this option so that the bot searches without removing the special characters from the name(in this example, the apostrophe).")	
        .add()

    this.edit("itemSearchName", _Str.withSpaces(this.itemName))
        .xs().yadd(3).w(this.guiW - this.paddingRight)
        .add()
}

itemPositionOnList()
{
        new _Text().title("Posição do item na lista ao pesquisar: ", "Item position on the list when searching: ")
        .xs().yadd(10)
        .tt("Quando o bot pesquisa pelo nome do item na lista, na maioria dos casos, o primeiro item da lista é o correto e é selecionado.`nPorém, há casos de itens onde ao pesquisar o nome exato do item, o primeiro item na lista é outro item com o nome similar, nesse caso é necessário selecionar o item em outra posição na lista que não é a primeira.`n`nPara entender melhor com um exemplo, procure pelo ""winged helmet"" no Market, o primeiro item na lista será o ""rusty winged helmet"", nesse caso, é necessário alterar o valor dessa opção para ""2"" para que o bot selecione o segundo item na lista ao pesquisar pelo ""winged helmet"".", "When the bot searches for the item name on the list, in most cases, the first item on the list is the correct one and is selected.`nHowever, there are cases of items where when searching for the exact item name, the first item on the list is another item with a similar name, in this case it is necessary to select the item in another position on the list that is not the first.`n`nTo better understand with an example, search for ""winged helmet"" on the Market, the first item on the list will be the ""rusty winged helmet"", in this case, it is necessary to change the value of this option to ""2"" so that the bot selects the second item on the list when searching for ""winged helmet"".")
        .add()

    this.amount("itemPositionOnList")
        .placeholder("1")
        .add()
}