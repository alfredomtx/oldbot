
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_GUI.ahk

Class _MarketbotSettingsGUI extends _GUI
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?string title
    */
    __New()
    {
        base.__New("marketbotSettings", "Marketbot - " lang("settings"))

        this.guiW := 285
        this.textW := 80
        this.editW := 105

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
        _AbstractStatefulControl.SET_DEFAULT_STATE(_MarketIniSettings)

        this.createControls()

        _AbstractControl.RESET_DEFAULT_GUI()
        _AbstractStatefulControl.RESET_DEFAULT_STATE()
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
        pt := 20

            new _ControlFactory(_ControlFactory.PROFILE_SETTINGS_EDIT)
            .w(this.guiW - 20)
            .add()

            new _Checkbox().name("simulation")
            .title(txt("Modo de simulação", "Simulation mode"))
            .xs().yadd(10)
            .tt("No modo de simulação, o bot não irá aceitar ou criar ofertas, apenas irá simular como se a ação tivesse sido feita, exibindo logs e progresso.`n`nEssa opção é útil para testar as configurações do bot sem realizar ações reais.", "In simulation mode, the bot will not accept or create offers, it will only simulate as if the action had been done, displaying logs and progress.`n`nThis option is useful for testing the bot settings without performing real actions.")
            .state(_MarketIniSettings)
            .add()

            new _Checkbox().name("autoStart")
            .title(txt("Iniciar automaticamente ao ativar", "Start automatically when enabling"))
            .xs().yadd(10)
            .state(_MarketIniSettings)
            .tt(txt("Por padrão o Marketbot não inicia as ações automaticamente quando é aberto, é necessário clicar no botão ""Iniciar"" para começar. Ao ativar essa opção, não será necessário clicar no botão para iniciar.", "By default the Marketbot does not start the actions automatically when it is opened, it is necessary to click on the ""Start"" button to begin. By enabling this option, it will not be necessary to click on the button to start."))
            .add()

            new _Checkbox().name("pauseOnError")
            .title("Pausar em caso de erro", "Pause on error")
            .xs().yadd(10)
            .state(_MarketIniSettings)
            .tt(txt("Pausar o bot em quando ocorrer algum erro, será necessário despausar manualmente para prosseguir com as ações.", "Pause the bot when an error occurs, it will be necessary to unpause manually to continue with the actions."))
            .add()

            new _Text().title("Mensagens de confirmação", "Confirmation messages")
            .x(this.paddingLeft).yadd(15)
            .font("s12")
            .add()

            new _Checkbox().name("acceptOfferConfirmation")
            .title(txt("Exibir confirmação para aceitar oferta", "Show confirmation to accept offer"))
            .xs().yadd(5)
            .tt("Exibir uma mensagem de confirmação ao aceitar uma oferta de compra ou venda, o bot esperará a mensagem ser aceita ou rejeitada para realizar novas ações.`nEssa opção é útil para testar as configurações das ofertas antes de deixar o bot rodando por conta prória.", "Display a confirmation message when accepting a buy or sell offer, the bot will wait for the message to be accepted or rejected to perform new actions.`nThis option is useful for testing the offer settings before letting the bot run on its own.")
            .state(_MarketIniSettings)
            .add()

            new _Checkbox().name("createOfferConfirmation")
            .title(txt("Exibir confirmação para criar oferta", "Show confirmation to create offer"))
            .xs().yadd(10)
            .tt("Exibir uma mensagem de confirmação ao criar uma oferta de compra ou venda, o bot esperará a mensagem ser aceita ou rejeitada para realizar novas ações.`nEssa opção é útil para testar as configurações das ofertas antes de deixar o bot rodando por conta prória.", "Display a confirmation message when creating a buy or sell offer, the bot will wait for the message to be accepted or rejected to perform new actions.`nThis option is useful for testing the offer settings before letting the bot run on its own.")
            .state(_MarketIniSettings)
            .add()

            new _Checkbox().name("cancelOfferConfirmation")
            .title(txt("Exibir confirmação para cancelar oferta", "Show confirmation to cancel offer"))
            .xs().yadd(10)
            .tt("Exibir uma mensagem de confirmação ao cancelar uma oferta de compra ou venda, o bot esperará a mensagem ser aceita ou rejeitada para realizar novas ações.`nEssa opção é útil para testar as configurações das ofertas antes de deixar o bot rodando por conta prória.", "Display a confirmation message when cancelling a buy or sell offer, the bot will wait for the message to be accepted or rejected to perform new actions.`nThis option is useful for testing the offer settings before letting the bot run on its own.")
            .state(_MarketIniSettings)
            .add()

            new _Checkbox().name("runActionConfirmation")
            .title(txt("Exibir mensagem antes de iniciar cada tipo de oferta", "Show message before starting each type of offer"))
            .xs().yadd(10)
            .tt("Exibir uma mensagem antes de iniciar a checagem de cada tipo de ação para o item(compra, venda, oferta de compra e oferta de venda)", "Display a message before starting the check of each type of action for the item(buy, sell, buy offer and sell offer)")
            .state(_MarketIniSettings)
            .add()

            new _Checkbox().name("finishedItemConfirmation")
            .title(txt("Exibir mensagem ao finalizar ações do item", "Show message when finishing item actions"))
            .xs().yadd(10)
            .tt("Exibir uma mensagem ao finalizar todas as ações de um item, como criar, aceitar ou cancelar ofertas.`nEssa opção é útil para saber quando o bot terminou de realizar todas as ações de um item.", "Display a message when finishing all actions of an item, such as creating, accepting or canceling offers.`nThis option is useful to know when the bot has finished performing all actions of an item.")
            .state(_MarketIniSettings)
            .add()

            new _Checkbox().name("finishedAllItemsConfirmation")
            .title(txt("Exibir mensagem ao finalizar todos os itens", "Show message when finishing all items"))
            .xs().yadd(10)
            .tt("Exibir uma mensagem ao finalizar todas as ações de todos os itens, como criar, aceitar ou cancelar ofertas.`nEssa opção é útil para saber quando o bot terminou de realizar todas as ações de todos os itens.", "Display a message when finishing all actions of all items, such as creating, accepting or canceling offers.`nThis option is useful to know when the bot has finished performing all actions of all items.")
            .state(_MarketIniSettings)
            .add()

            new _Button().title("Atualizar licença", "Update license")
            .xp().yadd(10).w(130)
            .icon(_Icon.get(_Icon.RELOAD), "a0 l4 s16 b0")
            .event(this.updateLicense.bind(this))
            .tt(txt("Atualizar dados da licença atual do Marketbot da sua conta.", "Update data of the current Marketbot license from your account."))
            .add()
    } 

    updateLicense()
    {
            new _MarketbotLicense().get(false)
            new _MarketbotGUI().open()
    }
}
