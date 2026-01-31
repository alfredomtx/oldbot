global supportControlsTotal := 3
global supportControlsHidden1
global supportControlsHidden2
global supportControlsHidden3
global supportControlsHidden4


Class _AutoSpellsGUI
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

    isUncompatibleSupportGui()
    {
        if (OldbotSettings.uncompatibleModule("support") = true) && (OldbotSettings.uncompatibleModule("fullLight") = true)
            return true

        return false
    }

    PostCreate_AutoSpellsGUI() {
        if (this.isUncompatibleSupportGui() = true)
            return
    }

    createAutoSpellsGUI() {
        global

        main_tab := "AutoSpells"
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
        w_group := 191
        w_text := 72
        w_control := w_group - w_text - 31
        y_group := 75
        x_group1 := 25

        w_column1 := 260

        h_group := 230


        Gui CavebotGUI:Add, GroupBox, x15 y+6 w%w_column1% h%h_group% Section vSupportSpecialCondsTab, Special Conditions

        functions := {}
        functions.Push({1: "cureParalyze", 2: txt("Curar Paralyze", "Cure Paralyze"), 3: txt("Hotkey da magia para curar paralyze.", "Hotkey of the spell to cure paralyze.") })
        functions.Push({1: "curePoison", 2: txt("Curar Poison", "Cure Poison"), 3: txt("Hotkey da magia para curar poison(exana pox).", "Hotkey of the spell to cure poison(exana pox).") })
        functions.Push({1: "cureFire", 2: txt("Curar Fire", "Cure Fire"), 3: txt("Hotkey da magia para curar fire(exana flam).", "Hotkey of the spell to cure fire(exana flam).") })
        functions.Push({1: "cureCurse", 2: txt("Curar Curse", "Cure Curse"), 3: txt("Hotkey da magia para curar mort(exana mort).", "Hotkey of the spell to cure mort(exana mort).")})

        for key, value in functions
        {
            y := (A_Index = 1) ? "p+25" : "+17"
            function := value.1
            functionName := value.2
            %function% := supportObj[function]

            enabled := bool(%function%)
            checked := "Checked" enabled

            Disabled := uncompatibleFunction("support", function) = true ? "Disabled" : ""

            ; msgbox, % function " , " functionName " , " enabled "`n" value.3
            Gui, CavebotGUI:Add, Checkbox, xs+10 y%y% w90 g%function% v%function% %checked% %Disabled%, % functionName
            Gui, CavebotGUI:Add, Hotkey, x+8 yp-2 w120 h18 v%function%Hotkey hwndh%function%Hotkey gsubmitSupportOptionHandler %Disabled%, % supportObj[function "Hotkey"]
            this.targetingRunningOption(function, functionName)
            TT.Add(hcurePoisonHotkey, value.3)
        }



        w_column2 := w - w_column1 - 10
        x_column2 := w_column1 + 15 + 10

        DisabledChatCondition := OldBotSettings.settingsJsonObj.clientFeatures.chatOnOff = false ? "Disabled" : ""
        DisabledProtectionZoneCondition := OldBotSettings.settingsJsonObj.clientFeatures.protectionZoneIndicator = false ? "Disabled" : ""


        h_group_spells := 325
        Gui CavebotGUI:Add, GroupBox, x%x_column2% ys+0 w%w_column2% h%h_group_spells% Section, Spells

        w_groupspell := 168
        h_groupspell := h_group_spells - 33
        w_text := 70
        w_hotkey := w_groupspell - w_text - 30

        x_group1 := x_column2 + 10

        hiddenControls := supportControlsHidden1 = 1 ? "Hidden" : ""
        Gui, CavebotGUI:Add, Groupbox, x%x_group1% ys+23 w%w_groupspell% h%h_groupspell% Section,
        Disabled := uncompatibleFunction("support", "autoHaste") = true ? "Disabled" : ""
        autoHaste := supportObj.autoHaste
        Gui, CavebotGUI:Add, Checkbox, xs+10 yp+0 gautoHaste vautoHaste Checked%autoHaste% %Disabled%, Auto Haste


        Gui, CavebotGUI:Add, Text, xs+10 yp+23 w%w_text% Right %Disabled%, Hotkey:
        Gui, CavebotGUI:Add, Hotkey, x+8 yp-2 w%w_hotkey% h18 vhasteSpellHotkey hwndhhasteSpellHotkey gsubmitSupportOptionHandler %Disabled%, % supportObj.hasteSpellHotkey
        TT.Add(hhasteSpellHotkey, LANGUAGE = "PT-BR" ? "Hotkey da magia de Haste." : "Hotkey of the Haste spell.")

        Gui, CavebotGUI:Add, Text, xs+10 y+8 w%w_text% Right %Disabled%, % LANGUAGE = "PT-BR" ? "Mana acima %" : "Mana above %:"
        Gui, CavebotGUI:Add, Edit, x+8 yp-2 w%w_hotkey% h18 vhasteMinMana hwndhhasteMinMana gsubmitSupportOptionHandler %Disabled% 0x2000 Limit2 Center, % supportObj.hasteMinMana
        TT.Add(hhasteMinMana, LANGUAGE = "PT-BR" ? "Porcentagem mínima de mana para usar o Auto Haste, não será usado se a mana estiver abaixo dessa porcentagem.": "Mininum mana percentage to use the Auto Haste, it won't be used if the mana is below this percentage.")


        this.supportToggleOptionsButton(1)


        autoHastePZ := supportObj.autoHastePZ
        autoHasteChatOn := supportObj.autoHasteChatOn

        function := "autoHaste"
        functionName := "Auto Haste"
        %function% := supportObj[function]

        Gui, CavebotGUI:Add, Checkbox, xs+10 y+11 vautoHastePZ Checked%autoHastePZ% gsubmitSupportOptionHandler %hiddenControls% %Disabled% %DisabledProtectionZoneCondition%, % LANGUAGE = "PT-BR" ? "Não usar em área PZ" : "Don't cast in PZ zone"
        Gui, CavebotGUI:Add, Checkbox, xs+10 y+8 vautoHasteChatOn Checked%autoHasteChatOn% gsubmitSupportOptionHandler %hiddenControls% %Disabled% %DisabledChatCondition%, % LANGUAGE = "PT-BR" ? "Não usar com ""chat on""" : "Don't cast with ""chat on"""
        this.targetingRunningOption(function, functionName, x := "s+10", y := "+5", w := w_groupspell - 30, hiddenControls)
        this.onlyWithTargetingRunningOption(function, functionName, x := "s+10", y := "+5", w := w_groupspell - 30, hiddenControls)

        x_group2 := x_group1 + w_groupspell + 10
        hiddenControls := supportControlsHidden2 = 1 ? "Hidden" : ""
        Gui, CavebotGUI:Add, Groupbox, x%x_group2% ys+0 w%w_groupspell% h%h_groupspell% Section,
        Disabled := uncompatibleFunction("support", "autoUtamoVita") = true ? "Disabled" : ""

        autoUtamoVita := supportObj.autoUtamoVita
        function := "autoUtamoVita"
        functionName := "Auto Utamo Vita"
        %function% := supportObj[function]

        Gui, CavebotGUI:Add, Checkbox, xs+10 yp+0 gautoUtamoVita vautoUtamoVita Checked%autoUtamoVita% %Disabled%, Auto Utamo Vita

        Gui, CavebotGUI:Add, Text, xs+10 yp+23 w%w_text% Right %Disabled%, Hotkey:
        Gui, CavebotGUI:Add, Hotkey, x+8 yp-2 w%w_hotkey% h18 vutamoVitaHotkey hwndhutamoVitaHotkey gsubmitSupportOptionHandler %Disabled%, % supportObj.utamoVitaHotkey
        TT.Add(hutamoVitaHotkey, LANGUAGE = "PT-BR" ? "Hotkey da magia Utamo Vita." : "Hotkey of the Utamo Vita spell.")

        Gui, CavebotGUI:Add, Text, xs+10 y+7 w%w_text% Right %Disabled%, % LANGUAGE = "PT-BR" ? "Mana acima %" : "Mana above %:"
        Gui, CavebotGUI:Add, Edit, x+8 yp-2 w%w_hotkey% h18 vutamoVitaMinMana hwndhutamoVitaMinMana gsubmitSupportOptionHandler %Disabled% 0x2000 Limit2 Center, % supportObj.utamoVitaMinMana
        TT.Add(hutamoVitaMinMana, LANGUAGE = "PT-BR" ? "Porcentagem mínima de mana para usar o Utamo Vita, não será usado se a mana estiver abaixo dessa porcentagem.": "Mininum mana percentage to use the Utamo Vita, it won't be used if the mana is below this percentage.")

        Gui, CavebotGUI:Add, Text, xs+10 y+7 w%w_text% vutamoVitaLifeText Right %Disabled% %DisabledExanaVitaNotEnabled% Center, % txt("Vida abaixo %", "Life below %")
        Gui, CavebotGUI:Add, Edit, x+8 yp-2 w%w_hotkey% h18 vutamoVitaLife gutamoVitaLife hwndhutamoVitaLife 0x2000 Limit3 %Disabled% Center, % supportObj.utamoVitaLife
        TT.Add(hutamoVitaLife, LANGUAGE = "PT-BR" ? "O Utamo Vita será usado somente quando a vida estiver abaixo da porcentagem setada nessa opção.`nPara usar sempre, coloque em 100%.": "The Utamo Vita will be used only when the life is below the percentage set in this option.`nTo always use, set to 100%.")

        exanaVitaEnabled := supportObj.exanaVitaEnabled
        DisabledExanaVitaNotEnabled := exanaVitaEnabled = 1 ? "" : "Hidden"
        DisabledNotTibia13 := !IsTibia13Or14() ? "Hidden" : ""
        Gui, CavebotGUI:Add, Checkbox, xs+10 y+10 vexanaVitaEnabled gexanaVitaEnabled hwndhexanaVitaEnabled Checked%exanaVitaEnabled% %Disabled% %DisabledNotTibia13%, % LANGUAGE = "PT-BR" ? "Usar Exana Vita" : "Use Exana Vita"
        TT.Add(hexanaVitaEnabled, LANGUAGE = "PT-BR" ? "Usar Exana Vita se a vida estiver acima da  porcentagem definida, quando o Exana Vita for usado, o Utamo Vita não será.": "Use Exana Vita if the life is above the percentage set, when the Exana Vita is used, Utamo Vita won't be.")

        Gui, CavebotGUI:Add, Text, xs+10 y+7 w%w_text% vexanaVitaHotkeyText Right %Disabled%  %DisabledExanaVitaNotEnabled%, Hotkey:
        Gui, CavebotGUI:Add, Hotkey, x+8 yp-2 w%w_hotkey% h18 vexanaVitaHotkey hwndhexanaVitaHotkey gsubmitSupportOptionHandler %Disabled% %DisabledExanaVitaNotEnabled%, % supportObj.exanaVitaHotkey
        TT.Add(hexanaVitaHotkey, LANGUAGE = "PT-BR" ? "Hotkey da magia Exana Vita no Tibia.": "Exana Vita spell hotkey in Tibia.")

        Gui, CavebotGUI:Add, Text, xs+10 y+7 w%w_text% Right vexanaVitaLifeText %Disabled% %DisabledExanaVitaNotEnabled%, % LANGUAGE = "PT-BR" ? "Vida acima %" : "Life above %"
        Gui, CavebotGUI:Add, Edit, x+8 yp-2 w%w_hotkey% h18 vexanaVitaLife gexanaVitaLife hwndhexanaVitaLife 0x2000 Limit2 %DisabledExanaVitaNotEnabled% %Disabled% Center, % supportObj.exanaVitaLife
        TT.Add(hexanaVitaLife, LANGUAGE = "PT-BR" ? "O Exana Vita será usado somente quando a vida estiver acima da porcentagem setada nessa opção.": "The Exana Vita will be used only when the life is above the percentage set in this option.")

        this.supportToggleOptionsButton(2)

        autoUtamoVitaPZ := supportObj.autoUtamoVitaPZ
        autoUtamoVitaChatOn := supportObj.autoUtamoVitaChatOn
        Gui, CavebotGUI:Add, Checkbox, xs+10 y+9 vautoUtamoVitaPZ Checked%autoUtamoVitaPZ% gsubmitSupportOptionHandler %hiddenControls% %Disabled% %DisabledProtectionZoneCondition%, % LANGUAGE = "PT-BR" ? "Não usar em área PZ" : "Don't cast in PZ zone"
        Gui, CavebotGUI:Add, Checkbox, xs+10 y+7 vautoUtamoVitaChatOn Checked%autoUtamoVitaChatOn% gsubmitSupportOptionHandler %hiddenControls% %Disabled% %DisabledChatCondition%, % LANGUAGE = "PT-BR" ? "Não usar com ""chat on""" : "Don't cast with ""chat on"""

        this.targetingRunningOption(function, functionName, x := "s+10", y := "+5", w := w_groupspell - 30, hiddenControls)
        this.onlyWithTargetingRunningOption(function, functionName, x := "s+10", y := "+5", w := w_groupspell - 30, hiddenControls)


        x_group3 := x_group2 + w_groupspell + 10
        hiddenControls := supportControlsHidden3 = 1 ? "Hidden" : ""
        Gui, CavebotGUI:Add, Groupbox, x%x_group3% ys+0 w%w_groupspell% h%h_groupspell% Section,

        Disabled := uncompatibleFunction("support", "autoBuffSpell") = true ? "Disabled" : ""

        autoBuffSpell := supportObj.autoBuffSpell
        function := "autoBuffSpell"
        functionName := "Auto Buff"
        %function% := supportObj[function]
        checked := %function%
        Gui, CavebotGUI:Add, Checkbox, xs+10 yp+0 g%function% v%function% Checked%checked% %Disabled%, % functionName
        Gui, CavebotGUI:Add, Text, xs+10 yp+23 w%w_text% Right %Disabled%, Hotkey:
        Gui, CavebotGUI:Add, Hotkey, x+8 yp-2 w%w_hotkey% h18 v%function%Hotkey hwndh%function%Hotkey gsubmitSupportOptionHandler %Disabled%, % supportObj[function "Hotkey"]

        TT.Add(h%function%Hotkey, LANGUAGE = "PT-BR" ? "Hotkey da magia de Buff(utito tempo, utura, utamo tempo, etc...)." : "Hotkey of the Buff spell(utito tempo, utura, utamo tempo, etc...).")


        Gui, CavebotGUI:Add, Text, xs+10 y+8 w%w_text% Right %Disabled%, % LANGUAGE = "PT-BR" ? "Mana acima %" : "Mana above %:"
        Gui, CavebotGUI:Add, Edit, x+8 yp-2 w%w_hotkey% h18 v%function%MinMana hwndh%function%MinMana gsubmitSupportOptionHandler %Disabled% 0x2000 Limit2 Center, % supportObj[function "MinMana"]
        TT.Add(h%function%MinMana, LANGUAGE = "PT-BR" ? "Porcentagem mínima de mana para usar o Buff Spell, não será usado se a mana estiver abaixo dessa porcentagem.": "Mininum mana percentage to use the Buff Spell, it won't be used if the mana is below this percentage.")

        this.supportToggleOptionsButton(3)

        %function%PZ := supportObj[function "PZ"]
        %function%ChatOn := supportObj[function "ChatOn"]
        checked := %function%PZ
        Gui, CavebotGUI:Add, Checkbox, xs+10 y+11 v%function%PZ Checked%checked% gsubmitSupportOptionHandler %hiddenControls% %Disabled% %DisabledProtectionZoneCondition%, % LANGUAGE = "PT-BR" ? "Não usar em área PZ" : "Don't cast in PZ zone"
        checked := %function%ChatOn
        Gui, CavebotGUI:Add, Checkbox, xs+10 y+8 v%function%ChatOn Checked%checked% gsubmitSupportOptionHandler %hiddenControls% %Disabled% %DisabledChatCondition%, % LANGUAGE = "PT-BR" ? "Não usar com ""chat on""" : "Don't cast with ""chat on"""

        this.targetingRunningOption(function, functionName, x := "s+10", y := "+5", w := w_groupspell - 30, hiddenControls)
        this.onlyWithTargetingRunningOption(function, functionName, x := "s+10", y := "+5", w := w_groupspell - 30, hiddenControls)

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
