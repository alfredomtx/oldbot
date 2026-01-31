
Class _ProfileSettingsGUI extends _AbstractSettingsGUI
{
    static INSTANCE

    __Call(method, args*)
    {
        if (this[method]) {
            methodParams(this[method], method, args)
            return this[method].Call(this, args*)
        }

        methodParams(this.instance[method], method, args)
        return this.instance[method].Call(this.instance, args*)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_ProfileSettingsGUI.INSTANCE) {
            return _ProfileSettingsGUI.INSTANCE
        }

        base.__New(DefaultProfile)

        this.instance := new _GUI("profileSettings", txt("Configurações do Perfil", "Profile Settings") ": " DefaultProfile)

        this.instance.onCreate(this.create.bind(this, this.instance))
            .scrollable()
            .withoutMinimizeButton()
        ; .withoutWindowButtons()

        this.guiHeight := 260

        _ProfileSettingsGUI.INSTANCE := this
    }

    open()
    {
        this.instance
            .w(this.guiWidth).h(this.guiHeight)
            .open()
    }

    createControls()
    {
        this.clientInput()
        this.healing()
        this.interface()

        _AbstractStatefulControl.RESET_DEFAULT_STATE()
    }

    clientInput()
    {
        _AbstractStatefulControl.SET_DEFAULT_STATE(_ClientInputIniSettings)

        this.title("Client Input")

            new _Checkbox().title("""Classic Control"" desativado", """Classic Control"" disabled")
            .name("classicControlDisabled")
            .xs().y()
            .tt("Tenha certeza de que a configuração de ""Classic Control"" no cliente do Tibia é a MESMA configurada aqui para o bot funcionar corretamente.`n`nO Classic Control pode estar desabilitado por padrão em alguns clientes principalmente para evitar interferência no teclado ao pressionar ""Ctrl"" ao lootear ou usar itens.`nMas para jogar manualmente e usar o bot como um Suporte é melhor deixar habilitado já que é mais fácil de jogar.`n`nTenha em mente que em clientes em que esta desativado por padrão, o Cavebot e o Looting irão funcionar melhor com o Classic Control desabilitado", "Make sure the ""Classic Control"" setting in the Tibia Client is the SAME as configured here for the bot to work properly.`n`nClassic Control may be disabled by default for some clients mainly to avoid keyboard interference when pressing ""Ctrl"" key when looting or using items.`nBut for playing manually and using the bot as Support is better to keep it enabled since it's easier to play.`n`nKeep in mind that in clients where it's disabled by default, the Cavebot and Looting will work better with Classic Control disabled.")
            .add()

            new _Checkbox().title("Modo de clique padrão em Menus", "Default Menu click method")
            .name("defaultMenuClickMethod")
            .xs().y()
            .tt("Alguns clientes não reconhecem o input do click em opções de Menu, tal como ""Follow"" no Battle List, ao desabilitar o método padrão(Default method), um método alternativo é usado para clicar nos menus.", "Some clients does not recognize the click input on Menu options, such as ""Follow"" on Battle List, by disabling the Default method, an alternative method is used to click on the menus.")
            .add()

            new _Checkbox().title("Escrever mensagens com a ação de ""colar""", "Send messages with ""paste"" action")
            .name("writeMessagesWithPasteAction")
            .xs().y()
            .tt("Por padrão ao escrever mensagens o bot digita as letras da mensagem no chat do Tibia, caso esteja falhando a digitação de algumas das letras, marcando essa opção o bot irá usar o clipbpard e colar o conteudo da mensagem diretamente, pressionando ""Ctrl + V"".`n`nOBS: com essa opção ativa poderá ocorrer uma pequena interferência no teclado quando o bot pressionar o ""Ctrl"".", "By default when writing messages the bot types the letters of the message in the Tibia chat, if it is failing to type some of the letters, marking this option the bot will use the clipboard and paste the content of the message directly, pressing ""Ctrl + V"".`n`nNOTE: with this option active there may be a small interference in the keyboard when the bot presses ""Ctrl"".")
            .add()
    }

    healing()
    {
        _AbstractStatefulControl.SET_DEFAULT_STATE(_HealingIniSettings)

        this.title("Healing")

            new _Text().title("Delay após usar item", "Delay after use item", ":")
            .xs().y()
            .tt("Delay em milisegundos após usar um item de cura(potion, runa)", "Delay in milliseconds after using a healing item(potion, rune)")
            .add()

            new _Edit().name("delayAfterUseItem")
            .x()
            .rule(new _ControlRule().default(new _HealingIniSettings().getAttribute("delayAfterUseItem")))
            .numeric()
            .center()
            .parent()
            .add()
    }

    interface()
    {
        _AbstractStatefulControl.SET_DEFAULT_STATE(_InterfaceIniSettings)

        this.title("Interface")

            new _Checkbox().title("Checar automaticamente as configurações do cliente", "Automatically check client settings")
            .name("autoCheckClientSettings")
            .xs().y()
            .tt("Na primeira vez que o bot é iniciado(Cavebot, Targeting...), ele irá checar se as configurações do cliente do Tibia estão corretas, se não estiverem, irá alterar para as configurações corretas.`nCom essa opção desmarcada, não irá checar as configurações do cliente.", "The first time the bot is started(Cavebot, Targeting...), it will check if the Tibia client settings are correct, if they are not, it will change to the correct settings.`nWith this option unchecked, it will not check the client settings.")
            .disabled(!isTibia13Or14() && !isRubinot())
            .add()
    }
}
