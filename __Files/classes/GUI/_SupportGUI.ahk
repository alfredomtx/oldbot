


global supportControlsTotal := 3
global supportControlsHidden1
global supportControlsHidden2
global supportControlsHidden3
global supportControlsHidden4


Class _SupportGUI
{
    __New()
    {
        this.supportHiddenControls := {}
        loop, % supportControlsTotal
            this.supportHiddenControls[A_Index] := {}

        this.supportHiddenControls[1].Push("autoHastePZ")
        this.supportHiddenControls[1].Push("autoHasteChatOn")
        this.supportHiddenControls[1].Push("autoHasteTargetingRunning")
        this.supportHiddenControls[1].Push("autoHasteOnlyWithTargetingRunning")

        this.supportHiddenControls[2].Push("autoUtamoVitaPZ")
        this.supportHiddenControls[2].Push("autoUtamoVitaChatOn")
        this.supportHiddenControls[2].Push("autoUtamoVitaTargetingRunning")
        this.supportHiddenControls[2].Push("autoUtamoVitaOnlyWithTargetingRunning")

        this.supportHiddenControls[3].Push("autoBuffSpellPZ")
        this.supportHiddenControls[3].Push("autoBuffSpellChatOn")
        this.supportHiddenControls[3].Push("autoBuffSpellTargetingRunning")
        this.supportHiddenControls[3].Push("autoBuffSpellOnlyWithTargetingRunning")

        this.readIniSupportGUISettings()

    }

    isUncompatibleSupportGui() {
        ; if (OldbotSettings.uncompatibleModule("support") = true) && (OldbotSettings.uncompatibleModule("fullLight") = true)
        ; return true

        return false
    }

    PostCreate_SupportGUI() {
        if (this.isUncompatibleSupportGui() = true)
            return
    }

    createSupportGUI() {
        global

        main_tab := "Support"
        child_tabs_%main_tab% := "Settings"

        Gui, CavebotGUI:Add, Tab2, x6 vTab_%main_tab% y%y_tab% w%tabsWidth% h%tabsHeight% hWndhTab_%main_tab% %TabStyle% +Theme, % child_tabs_%main_tab%
        if (load_order[1] != main_tab)
            GuiControl, Hide, Tab_%main_tab% ; esconder a tab antes de adicionar os elementos a ela

        if (this.isUncompatibleSupportGui() = true) {
            _GuiHandler.uncompatibleModuleWarning()
            return
        }

        Loop, parse, child_tabs_%main_tab%, |
        {
            current_child_tab := A_LoopField
            ; msgbox, % child_tabs_%main_tab%
            Gui, CavebotGUI:Tab, %current_child_tab%
            switch current_child_tab
            {
                case "Settings":
                    this.ChildTab_Settings()
            }
        }

        return


    }

    ChildTab_Settings() {
        global

        w := tabsWidth - 20
        w_group := 380
        w_text := 72
        w_control := w_group - w_text - 31
        y_group := 75
        x_group1 := 25

        w_column1 := w_group - 20

        h_group := 225

        w_column2 := w - w_column1 - 10
        x_column2 := w_column1 + 15 + 10

        this.misc()

        this.others()

    }

    misc()
    {
        global

        y_nextgroups := 300
        Gui CavebotGUI:Add, GroupBox, x15 y+6 w%w_column1% h130 Section, Misc.

        this.autoEatFood()

        this.autoShoot()
    }

    autoEatFood()
    {
        uncompatible := uncompatibleFunction("support", "autoEatFood")

        function := "autoEatFood"
        %function% := supportObj[function]

            new _Checkbox().title("Auto Eat Food")
            .name("autoEatFood")
            .xs(10).yp(23).w(130)
            .state(_SupportSettings)
            .disabled(uncompatible)
            .event(this.toggleEatFood.bind(this))
            .add()



        this.eatFoodHotkey := new _Hotkey().name("hotkey")
            .nested("eatFood")
            .x().yp(-2).w(83).h(18)
            .tt("Hotkey configurada no Tibia com o food para comer food.", "Hotkey set in Tibia with the food to eat.")
            .state(_SupportSettings)
            .rule(new _HotkeyRule())
            .disabled(uncompatible)
            .add()

            new _Button().title("Carregar hotkey", "Load hotkey")
            .tt("Carrega a hotkey do ""brown mushroom"" encontrado na Action Bar.`n`nATENÇÃO: é necessário relogar no char após você mudar alguma hotkey ou item na Action Bar para carregar novamente.", "Load the hotkey of the ""brown mushroom"" found in the Action Bar.`n`nATTENTION: It's necessary to relogin on the character after you change a hotkey or item in the Action Bar to load again.")
            .xadd(10).yp(-1).h(20).w(110)
            .disabled(new _LoadHotkeysPolicy().run())
            .disabled(!isTibia13())
            .icon(_Icon.get(_Icon.TIBIA), "a0 l1 b1 s17")
            .event(this.loadFoodHotkey.bind(this))
            .add()

        if (!uncompatible) {
            this.targetingRunningOption(function, "Auto Eat Food")
        } else {
            Gui, CavebotGUI:Font, cRed
            Gui, CavebotGUI:Add, Text, xs+10 y+3, % LANGUAGE = "PT-BR" ? "Use a Persistent de ""Use item"" para comer." : "Use the ""Use item"" Persistent to eat food."
            Gui, CavebotGUI:Font,
        }

    }

    /**
    * @param _Checkbox checkbox
    * @param bool value
    * @return void
    */
    toggleEatFood(checkbox, value)
    {
        if (value) {
            OldBotSettings.startFunction("support", control, startProcess := true, throwE := false, saveJson := true)
        } else {
            OldBotSettings.stopFunction("support", control, closeProcess := true, saveJson := true)
        }

        checkbox.syncShortcut()
    }

    /**
    * @return void
    * @msgbox
    */
    loadFoodHotkey()
    {
        this.showConfirmationMessage := !GetKeyState("Ctrl")
        try {
            clientOptions := new _ClientOptions()
            action := clientOptions.getFoodHotkey()
            if (!action) {
                return this.noActionBarMessage("brown mushroom")
            }

            ; if (!this.loadHotkeyConfimationMessage(action, this.eatFoodHotkey.get(), "", true)) {
            ;     return
            ; }

            this.eatFoodHotkey.set(action.hotkey)
        } catch e {
            msgbox, 48,, % e.Message, 10
            return
        }

        TrayTipMessage(txt("Hotkey carregada com sucesso.", "Hotkey loaded successfully."), txt("Confirme se as hotkey do ""brown mushroom"" está correta.", "Confirm if the ""brown mushroom"" hotkey is correct."), 8)
    }

    /**
    * @param string type
    * @return void
    * @msgbox
    */
    noActionBarMessage(type)
    {
        msgbox, 48, % this.loadHotkeysTitle(), % txt("Não há nenhum " type " na Action Bar.`n`nAdicione algum tipo de " type " COM hotkey na Action Bar, RELOGUE o char e tente novamente.", "There is not any " type " in the Action Bar.`n`nAdd some type of " type " WITH hotkey in the Action Bar, RELOGIN the character, and try again."), 10
    }

    others()
    {
        global
        Gui CavebotGUI:Add, GroupBox, x15 y190 w%w_column1% h200 Section, Misc

        this.fullLight()

        _FloorSpy.CHECKBOX := new _Checkbox().name("floorSpyEnabled")
            .xs(10).yadd(15)
            .title("Floor Spy (X-Ray)")
            .event(FloorSpy.toggle.bind(FloorSpy))
            .tt(txt("Com o Floor Spy você pode ver outros andares e SQMs perto da posição atual do seu char.`n`nATENÇÃO: Ao ativar o floor spy, NÃO ANDE com o seu personagem, desative antes de andar para outro SQM, caso contrário o cliente buga e você precisará relogar o char para voltar ao normal.", "With the Floor Spy you can see other floors and SQMs near the current position of your character.`n`nATTENTION: When enabling the floor spy, DO NOT WALK with your character, disable it before walking to another SQM, otherwise the client bugs and you will need to relogin your char to go back to normal. "))
            .disabled(OldBotSettings.uncompatibleModule("floorSpy"))
            .add()

            new _ControlFactory(_ControlFactory.SETTINGS_BUTTON)
            .event(new _FloorSpySettingsGUI().open.bind(new _FloorSpySettingsGUI()))
            .tt("Configurações do Floor Spy", "Floor Spy settings")
            .add()


        _Magnifier.CHECKBOX := new _Checkbox().name(_Magnifier.CHECKBOX_NAME)
            .title("Magnifier")
            .xs(10).yadd(10)
            .tt("Hotkeys (com o Magnifier ativo):`n`n[Alt + Space]: setar a área do magnifier.`n[Shift + Alt + Space]: setar a posição da janela do magnifier.", "Hotkeys (with the Magnifier enabled):`n`n[Alt + Space]: set the magnifier's area`n[Shift + Alt + Space]: set the magnifier's window position.")
            .event(_Magnifier.toggle.bind(_Magnifier))
            .add()

            new _ControlFactory(_ControlFactory.SETTINGS_BUTTON)
            .event(new _MagnifierSettingsGUI().open.bind(new _MagnifierSettingsGUI()))
            .tt("Configurações do Magnifier", "Magnifier settings")
            .add()


    }

    /**
    * @return array<_ListOption>
    */
    getZoomList()
    {
        static list
        if (list) {
            return list
        }

        list := {}
        list.Push(new _ListOption(0.5))
        list.Push(new _ListOption(0.6))
        list.Push(new _ListOption(0.7))
        list.Push(new _ListOption(0.8))
        list.Push(new _ListOption(0.9))
        list.Push(new _ListOption(1, true))

        return list
    }

    fullLight()
    {
        global
        Disabled := (uncompatibleModule("fullLight")) ? "Disabled" : ""
        Hidden := (uncompatibleModule("fullLight")) ? "Hidden" : ""

        switch (TibiaClient.getClientIdentifier()) {
            case "nostalrius", case "dura":
                DisabledFullLightOptions := ""
            default:
                DisabledFullLightOptions := "Disabled"

        }


        fullLightEnabled := fullLightObj.fullLightEnabled
        Gui, CavebotGUI:Add, Checkbox, xs+10 yp+25 gfullLightEnabled vfullLightEnabled Checked%fullLightEnabled% %Disabled%, Light Hack
        ; Gui, CavebotGUI:Add, Text, xs+20 y+7 w120 %Hidden%, % "SQMs:"
        ; Gui, CavebotGUI:Add, Dropdown, x+5 yp-2 w83 vfullLightSqms gsubmitFullLightOption hwndhfullLightSqms %DisabledFullLightOptions% %Hidden%, % "1|2|3|4|5|6|7|8|9|10|11"
        ; TT.Add(hfullLightSqms, "How many SQMs to illuminate on screen, for example a ""Torch"" lights 5 sqms")
        ; GuiControl, CavebotGUI:ChooseString, fullLightSqms, % fullLightObj.fullLightSqms


        ; Gui, CavebotGUI:Add, Text, xs+20 y+7 w120 %Hidden%, % "Light effect:"
        ; Gui, CavebotGUI:Add, DropdownList, x+5 yp-2 w83 vfullLightEffect gsubmitFullLightOption %DisabledFullLightOptions% %Hidden%, % "Spell|Torch"
        ; GuiControl, CavebotGUI:ChooseString, fullLightEffect, % fullLightObj.fullLightEffect

        ; Gui, CavebotGUI:Add, Text, xs+20 y+7 w120 %Hidden%, % "Delay (ms):"
        ; Gui, CavebotGUI:Add, DropdownList, x+5 yp-2 w83 vfullLightDelay gsubmitFullLightOption %Hidden%, % "1|50|100|150"
        ; GuiControl, CavebotGUI:ChooseString, fullLightDelay, % fullLightObj.fullLightDelay
    }

    targetingRunningOption(function, functionName, x := "s+20", y := "+5", w := 200, hiddenControls := "") {
        global
        %function%TargetingRunning := bool(supportObj[function "TargetingRunning"])
        checkedTargetingRunning := "Checked" %function%TargetingRunning
        ; msgbox, % function " , "  functionName " ,  " %function% " ,  " %function%TargetingRunning " ,  " checkedTargetingRunning
        Gui, CavebotGUI:Add, Checkbox, x%x% y%y% w%w% v%function%TargetingRunning hwndh%function%TargetingRunning %checkedTargetingRunning% gsubmitSupportOptionHandler %hiddenControls%, % txt("Não usar com Targeting em ação", "Don't use with Targeting in action")
        this.tooltipDontRunWithTargeting(function "TargetingRunning", functionName)
    }

    onlyWithTargetingRunningOption(function, functionName, x := "s+20", y := "+5", w := 200, hiddenControls := "") {
        global
        %function%OnlyWithTargetingRunning := bool(supportObj[function "OnlyWithTargetingRunning"])
        checkedOnlyWithTargetingRunning := "Checked" %function%OnlyWithTargetingRunning
        ; msgbox, % function " , "  functionName " ,  " %function% " ,  " %function%OnlyWithTargetingRunning " ,  " checkedOnlyWithTargetingRunning
        Gui, CavebotGUI:Add, Checkbox, x%x% y%y% w%w% v%function%OnlyWithTargetingRunning hwndh%function%OnlyWithTargetingRunning %checkedOnlyWithTargetingRunning% gsubmitSupportOptionHandler %hiddenControls%, % txt("Usar somente com Targeting em ação", "Use only with Targeting in action")
        this.tooltipRunWithOnlyTargeting(function "OnlyWithTargetingRunning", functionName)
    }

    tooltipDontRunWithTargeting(control, functionName) {
        global
        TT.add(h%control%, txt("Não usar o " functionName " enquanto o Targeting estiver atacando criaturas." , "Not use the " functionName " while the Targeting is attacking creatures."))
    }


    tooltipRunWithOnlyTargeting(control, functionName) {
        global
        TT.add(h%control%, txt("Usar o " functionName " somente enquanto o Targeting estiver atacando criaturas." , "Use the " functionName " only while the Targeting is attacking creatures."))
    }

    readIniSupportGUISettings() {
        global

        loop, % supportControlsTotal
            IniRead, supportControlsHidden%A_Index%, %DefaultProfile%, gui_support, supportControlsHidden%A_Index%, 1
    }

    supportToggleOptionsButton(number) {
        global
        Gui, CavebotGUI:Add, Button, % "xs+38 y+3 w90 h19 vsupportControlsHidden" number " gsupportControlsHidden", % this.getSupportControlHiddenButtonText(number)
    }

    getSupportControlHiddenButtonText(number) {
        return (supportControlsHidden%number% = 0) ? txt("Ocultar opções", "Hide options") : txt("Mostrar opções", "Show options")
    }

    toggleSupportControlsHidden() {
        Gui, CavebotGUI:Submit, NoHide
        number := StrReplace(A_GuiControl, "supportControlsHidden", "")
        value := !supportControlsHidden%number%
        supportControlsHidden%number% := value
        IniWrite, % value, %DefaultProfile%, gui_support, supportControlsHidden%number%

        GuiControl, CavebotGUI:, supportControlsHidden%number%, % this.getSupportControlHiddenButtonText(number)

        for key, control in this.supportHiddenControls[number]
        {

            GuiControl, % "CavebotGUI: " (value = 1 ? "Hide" : "Show"), % control
        }
    }



}
