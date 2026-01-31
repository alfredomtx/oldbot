
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_GUI.ahk

Class _PremiumGUI extends _GUI
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?string title
    */
    __New()
    {
        base.__New("premium", "Marketbot PREMIUM")

        this.guiW := 400
        this.textW := 80
        this.editW := 105


        this.paddingLeft := 10
        this.paddingRight := 20

        this.onCreate(this.create.bind(this))
            .y(100).w(this.guiW)
            .withoutMinimizeButton()
        ; .alwaysOnTop()
        ; .withoutWindowButtons()

        this.license := new _MarketbotLicense()  
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
        this.iniSettings()
    }

    iniSettings()
    {
        if (this.license.isPremium()) {
                new _Text().title(txt("Sua premium expira em: ", "Your premium expires in: ") this.license.date() ".")
                .xs().yadd(5).w(this.guiW - (this.paddingRight + 5))
                .font("s10")
                .color("green")
                .center()
                .add()
        }

            new _Text().title(txt("O Marketbot possui uma versão FREE(grátis) e a versão PREMIUM(paga), a versão free possui mais limitações do que a premium.`n`nConfira abaixo as diferenças entre as duas versões:", "The Marketbot has a FREE(free) version and the PREMIUM(paid) version, the free version has more limitations than the premium.`nCheck below the differences between the two versions:"))
            .xs().yadd(5).w(this.guiW - this.paddingRight)
            .font("s10")
            .add()


        this.textW := 210

        this.freeX := this.paddingLeft + this.textW
        this.freeW := 50
        this.premiumX := this.freeX + this.freeW + 15
        this.premiumW := 50

        freeNumberW := this.freeW + 5
        premiumNumberW := this.premiumW + 30

            new _Text().title("FREE")
            .x(this.freeX).yadd(15).w(this.freW)
            .font("s14")
            .section()
            .center()
            .add()

            new _Text().title("PREMIUM")
            .x(this.premiumX).yp().w(this.premiumW)
            .font("s14")
            .section()
            .center()
            .add()

        this.textFont := "s10"

        this.text("1) " txt("Limite de itens ativos", "Active items limit"))
        this.number(_MarketbotLicense.FREE_ITEMS, "red", this.freeX, freeNumberW)
        this.numberText(txt("itens", "items"))
        this.number(_MarketbotLicense.PREMIUM_ITEMS, "green", this.premiumX, premiumNumberW)
        this.numberText(txt("itens", "items"))


        this.text("2) " txt("Tempo de cooldown por item", "Cooldown time per item"))
        this.number(_MarketbotLicense.FREE_ITEM_COOLDOWN_HOURS, "red", this.freeX, freeNumberW)

        this.numberText(txt("hora(s)", "hour(s)"))

        this.number(_MarketbotLicense.PREMIUM_ITEM_COOLDOWN, "green", this.premiumX, premiumNumberW)

        this.numberText(txt("minuto(s)", "minute(s)"))



            new _Button().title((this.license.isPremium() ? txt("Renovar ", "Renew ") : txt("Comprar ", "Buy ")) "PREMIUM")
            .x(95).yadd(10).w(200).h(35)
            ; .event(func("openUrl").bind("")) ; Premium always unlocked
            .icon(_Icon.get(_Icon.STAR), "a0 l5 s18 b0")
            .focused()
            .add()


            new _Text().title("1) Limite de itens ativo é a quantidade de itens que o Marketbot poderá ter ativo para realizar as checagens. Você pode adicionar quantos itens quiser na lista de itens, mas apenas a quantidade de itens ativos permitidos pela sua licença serão checados.`nSerá necessário desativar itens excedentes para usar o Marketbot, exemplo: na versão FREE, se você possuir 5 itens ativos na lista de itens, será necessário desativar 3 itens para iniciar o Marketbot.", "1) Active item limit is the number of items that Marketbot can have active to perform checks. You can add as many items as you want to the item list, but only the number of active items allowed by your license will be checked.`nIt will be necessary to deactivate excess items to use Marketbot, example: in the FREE version, if you have 5 active items in the item list, it will be necessary to deactivate 3 items to start Marketbot.")
            .x(10).yadd(10).w(this.guiW - this.paddingRight)
            .font("s8")
            .color("gray")
            .add()  

            new _Text().title("2) Tempo de cooldown por item é o intevalo em que o Marketbot irá esperar para checar o mesmo item novamente. O tempo de cooldown é individual para cada item.`nO tempo de cooldown serve para que o uso do bot não seja tão destrutivo ao market do jogo e evitar ""spam"" de criação de ofertas.", "2) Cooldown time per item is the interval in which Marketbot will wait to check the same item again. The cooldown time is individual for each item.`nThe cooldown time is used so that the use of the bot is not so destructive to the game market and avoid ""spam"" of creating offers.")
            .x(10).yadd(10).w(this.guiW - this.paddingRight)
            .font("s8")
            .color("gray")
            .add()
    } 

    numberText(title)
    {
            new _Text().title(title)
            .xadd(5).yp()
            .font(this.textFont)
            .add()
    }

    number(number, color, x, w)
    {
            new _Text().title(number)
            .x(x).yp()
            .bold()
            .color(color)
            .font(this.textFont)
            .add()


    }

    text(title)
    {
        return new _Text().title(title)
            .x(10).yadd(5).w(this.textW)
            .font(this.textFont)
            .add()
    }
}
