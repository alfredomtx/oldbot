
Class _FishingModuleGUI extends _GUI
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?string title
    */
    __New()
    {
        base.__New("fishing", "Fishing")

        this.guiW := 300
        this.editW := 90

        this.onCreate(this.create.bind(this))
            .y(100).w(this.guiW)
            .alwaysOnTop()
        ; .withoutWindowButtons()
    }

    /**
    * @abstract
    * @return void
    */
    create()
    {
        _AbstractControl.SET_DEFAULT_GUI(this)
        _AbstractStatefulControl.SET_DEFAULT_STATE(_FishingSettings)

        this.createControls()

        _AbstractControl.RESET_DEFAULT_GUI()
        _AbstractStatefulControl.RESET_DEFAULT_STATE()
    }

    /**
    * @return void
    */
    createControls()
    {
            new _Checkbox().title("Fishing Enabled")
            .name("enabled")
            .xp().y()
            .tt("Enable and start the Auto Fishing.`n`nPS: The Fishing Rod must be visible on screen to be used(inside a bag/BP).`n`nCAUTION! Be careful when clicking on items with the Fishing running, it can throw what's under the mouse on the sea!")
            .section()
            .add()

        this.createOptions()
        this.createConditions()
        this.createSetup()
    }

    createOptions()
    {
            new _Groupbox().title(lang("options"))
            .xs().y().w(this.guiW - 20).h(130) 
            .section()
            .add()

            new _Text().title("Fishing delay:")
            .xs(10).yp(25).w(this.editW)
            .tt("Delay após cada ação de fishing(usando a fishing rod na água)", "Delay after each fishing(using fishing rod on the water)")
            .option("Right")
            .add()

            new _Edit().name("delay")
            .x().yp(-1).w(this.editW).h(18)
            .numeric()
            .parent()
            .add()

            new _Text().title("Fishing Rod hotkey:")
            .xs(10).yadd(10).w(this.editW)
            .tt("Hotkey da Fishing Rod, se o OT não possui hotkeys, deixe em branco(""Nenhum"") para que o bot clique na rod(usar item sem hotkey).", "Fishing Rod hotkey, if the OT do not have hotkeys, leave it blank(""None"") so the bot click on the rod(use item without hotkey).")
            .option("Right")
            .add()

            new _Hotkey().name("rodHotkey")
            .x().yp(-1).w(this.editW).h(18)
            .parent()
            .add()

            new _Text().title("Pause hotkey:")
            .xs(10).yadd(10).w(this.editW)
            .option("Right")
            .add()

            new _Hotkey().name("pauseHotkey")
            .x().yp(-1).w(this.editW).h(18)
            .parent()
            .add()

            new _Checkbox().title("Pressionar ""Esc"" antes de usar fishing rod", "Press ""Esc"" before using fishing rod")
            .name("pressEsc")
            .xs(10).yadd(10)
            .add()
    }

    createConditions()
    {
            new _Groupbox().title(lang("conditions"))
            .xs().yadd(20).w(this.guiW - 20).h(130) 
            .section()
            .add()

            new _Checkbox().title("Somente se slot vazio encontrado", "Only if free slot found")
            .name("withFreeSlot")
            .xs(10).yp(25)
            .tt("Pescar somente se qualquer slot vazio de backpack for encontrado na tela.", "Fish only if any empty backpack slot is found on screen.")
            .add()

            new _Checkbox().title("Somente se não houver fish na BP", "Only if no fish on BP")
            .name("ifNoFish")
            .tt("Pescar somente se não houver nenhum peixe encontrado em nenhum slot de backpack na tela.", "Fish only if there is no fish found in any backpack slot on screen.")
            .xp().yadd(10)
            .add()

            new _Checkbox().title("Se cap maior que:", "If cap higher than:")
            .name("capCondition")
            .tt("Pescar somente se o cap do char for maior do que o valor setado.", "Fish only if character's Capacity is higher than the value set.")
            .xp().yadd(10)
            .add()

            new _Edit().name("capAmount")
            .x().yp(-1).w(this.editW).h(18)
            .tt("Quantidade de cap para continuar pescando.", "Amount of cap to keep fishing.")
            .numeric()
            .add() 

            new _Checkbox().title("Ignorar na aba de Waypoint:" , "Ignore in Waypoint tab:")
            .name("ignoreIfWaypointTab")
            .tt("Se marcado e o Cavebot estiver rodando, irá checar qual a aba atual do Waypoint que o Cavebot está, se for uma das abas setadas no parametro, não irá pescar.", "If checked and the Cavebot is running, it will check which is the current Waypoint Tab the cavebot is at, if is one of the tabs set in the param, it won't fish.")
            .xs(10).yadd(5)
            .add()

            new _Edit().name("waypointTab")
            .x().yp(-1).w(this.editW).h(18)
            .tt("Um ou mais nomes de Abas de Waypoint, separados por ""|"", exemplo: ", "One or more Waypoint Tab names, separated by ""|"", example: " "Depositer|Hunt|BuySupply")
            .numeric()
            .add() 
    }

    createSetup()
    {
            new _Groupbox().title("Fishing Setup")
            .xs().yadd(20).w(this.guiW - 20).h(100) 
            .section()
            .add()

            new _Button().title("Definir", "Set", " Fishing SQMs")
            .xs(10).yp(25).w(150).h(25)
            .event("SetFishingSqms")
            .icon(_Icon.get(_Icon.SQUARE), "a0 l5 b1 s18")
            .add()

            new _Button().title("Resetar", "Reset", " Fishing SQMs")
            .xp().y().w(150).h(25)
            .event("ResetFishingSQMs")
            .icon(_Icon.get(_Icon.UNDO), "a0 l5 b1 s18")
            .add()
    }
}
