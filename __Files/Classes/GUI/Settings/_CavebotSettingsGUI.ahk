
Class _CavebotSettingsGUI extends _GUI
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?string title
    */
    __New()
    {
        base.__New("Cavebot", "Cavebot - " lang("settings"))

        this.guiW := 350
        this.editW := 140

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
        _AbstractStatefulControl.SET_DEFAULT_STATE(_CavebotSettings)

        this.createControls()

        _AbstractControl.RESET_DEFAULT_GUI()
        _AbstractStatefulControl.RESET_DEFAULT_STATE()
    }

    /**
    * @return void
    */
    createControls()
    {
        this.settings()
        this.iniSettings()
    }

    /**
    * @return void
    */
    settings()
    {
        #Include, C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\GUIs\Components\settings_script_title.ahk
            new _Text().title("Delay caminhar pelas setas", "Walk by arrow delay", ":")
            .xs().y()
            .tt("Delay que o bot esperará após pressionar a seta para andar.", "Delay that the bot will wait after pressing the arrow to walk.")
            .tt("")
            .tt("O Ping(latência) impacta diretamente a velocidade que o seu char caminha ao andar usando as setas.`nSe você mora no Brasil e joga num servidor SA por exemplo, o char irá andar rápido na maior parte das vezes independente do delay setado aqui.", "The Ping(latency) impacts directly the speed your char will walk when using arrow keys.`nIf you live in Brazil and play in SA Server for example, the character will most of the time walk fast despite the delay set here.")
            .add()

            new _Edit().name("walkArrowDelay")
            .x().w(this.editW)
            .rule(new _ControlRule().default(new _CavebotSettings().getAttribute("walkArrowDelay")))
            .numeric()
            .center()
            .parent()
            .add()

        #Include, C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\GUIs\Components\Cavebot\cavebot_settings.ahk
    }


    iniSettings()
    {
        _AbstractStatefulControl.SET_DEFAULT_STATE(_CavebotIniSettings)

        #Include, C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\GUIs\Components\settings_profile_title.ahk


            new _Checkbox().title("Manter chat off após enviar mensagem", "Turn chat off after sending message")
            .name("turnChatOffAfterMessages")
            .xs().yadd(10)
            .tt("Mantém o  ""Chat Off"" após enviar uma mensagem.", "Keep the ""Chat Off"" after sending a message.")
            .disabled(!OldBotSettings.settingsJsonObj.clientFeatures.chatOnOff)
            .add()

            new _Checkbox().title("Ajustar zoom do minimap ao adicionar waypoint", "Adjust minimap zoom add waypoint")
            .name("adjustMinimapAddWaypoint")
            .xs().yadd(10)
            .disabled(isMemoryCoordinates())
            .add()

        #Include, C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\GUIs\Components\Cavebot\cavebot_ini_settings.ahk
        #Include, C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\GUIs\Components\Cavebot\pause_hotkeys.ahk

        #Include, C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\GUIs\Components\Cavebot\special_areas_settings.ahk
    }
}
