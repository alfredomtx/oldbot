
Class _AlertsGUI  {
    __New()
    {

        this.LVColumnsCount := 10


        this.enabledText := LANGUAGE = "PT-BR" ? "Ativar Alert" : "Enable Alert"
        this.disabledText := LANGUAGE = "PT-BR" ? "Desativar Alert" : "Disable Alert"
    }

    PostCreate_AlertsGUI() {
        if (OldbotSettings.uncompatibleModule("alerts") = true)
            return
        this.loadAlertsListLV()
    }

    createAlertsGUI() {
        global

        main_tab := "Alerts"
        child_tabs_%main_tab% := "Settings"

        Gui, CavebotGUI:Add, Tab2, x6 vTab_%main_tab% y%y_tab% w%tabsWidth% h%tabsHeight% hWndhTab_%main_tab% %TabStyle% +Theme, % child_tabs_%main_tab%
        if (load_order[1] != main_tab)
            GuiControl, Hide, Tab_%main_tab% ; esconder a tab antes de adicionar os elementos a ela

        if (OldbotSettings.uncompatibleModule("alerts") = true) {
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
                    this.ChildTab_Alerts()
            }
        }

        return
    }

    ChildTab_Alerts() {
        global

        mod := 50
        w_lv := w_LVWaypoints - mod
        w_group := 150 + 10

        Gui, CavebotGUI:Add, ListView, x15 y+6 h%LV_Waypoints_height% w%w_lv% AltSubmit -Multi vLV_AlertsList gLV_AlertsList hwndhLV_AlertsList LV0x1 LV0x10, Alert name|Enabled|Sound|Logout|Pause|Exit|Teleg.|Screensh.|Label|User value

        x_group1 := x_groupbox_listview - mod

        w_group := 150 + mod
        w_controls := w_group - 20

        Disabled := ""


        Gui, CavebotGUI:Add, Groupbox, x%x_group1% y50 w%w_group% h55 Section, % txt("Add Alert (""Image"" alerts somente)", "Add Alert (""Image"" alert only)")
        w := w_controls / 2 - 2
        w1 := w + 15
        w2 := w - 15

            new _ControlFactory(_ControlFactory.ADD_NEW_BUTTON)
            .name("addAlertButton")
            .w(w1)
            .disabled()
            .event("addImageAlert")
            .add()

            new _Button().title(lang("delete"))
            .name("deleteAlertButton")
            .xadd(3).yp().w(w2)
            .icon(_Icon.get(_Icon.DELETE), "a0 l3 s14 b0")
            .tt("Segure ""Ctrl"" para pular o diálogo de confirmação", "Hold ""Ctrl"" to skip the confirmation dialog")
            .event("deleteAlert")
            .disabled()
            .add()

        Gui, CavebotGUI:Add, Groupbox, x%x_group1% y+18 w%w_group% h312 Section, Edit Alert
        Gui, CavebotGUI:Add, Checkbox, xs+10 yp+20 w%w_controls% h23 valertEnabled gsubmitAlertOptionHandler hwndhalertEnabled Disabled 0x1000, % this.enabledText
        icon := _Icon.get(_Icon.CHECK_ROUND_WHITE)
        CavebotGUI.cavebotGUIButtonIcon(halertEnabled, icon.dllName, icon.number, "a0 l5 s16 b0")

        TT.Add(halertEnabled, (LANGUAGE = "PT-BR" ? "Você também pode ativar o Alert clicando com o botão direito do mouse no na lista." : "You can also enable the Alert by right clicking on the list." ))


            new _ControlFactory(_ControlFactory.EDIT_USER_VALUES_BUTTON)
            .name("editUserValueButton")
            .xs(10).yadd(5).w(w_controls).h(23)
            .disabled()
            .event("editUserValue")
            .add()

        Gui, CavebotGUI:Add, Text, xs+10 y+10 %Disabled%, Alert name:
        Gui, CavebotGUI:Add, Edit, xs+10 y+3 w%w_controls% h18 valertName Disabled,

        Gui, CavebotGUI:Add, Checkbox, xs+10 y+10 w%w_controls% h18 valertPlaySound hwndhalertPlaySound gsubmitAlertOptionHandler %Disabled%, % "Play sound"
        Gui, CavebotGUI:Add, Checkbox, xs+10 y+5 w%w_controls% h18 valertPauseCavebot hwndhalertPauseCavebot gsubmitAlertOptionHandler %Disabled%, % "Pause bot"
        Gui, CavebotGUI:Add, Checkbox, xs+10 y+5 w%w_controls% h18 valertLogout hwndhalertLogout gsubmitAlertOptionHandler %Disabled%, % "Logout"
        Gui, CavebotGUI:Add, Checkbox, xs+10 y+5 w%w_controls% h18 valertExitGame hwndhalertExitGame gsubmitAlertOptionHandler %Disabled%, % "Exit game"
        Gui, CavebotGUI:Add, Checkbox, xs+10 y+5 w%w_controls% h18 valertTelegram hwndhalertTelegram gsubmitAlertOptionHandler %Disabled%, % "Telegram"
        Gui, CavebotGUI:Add, Checkbox, xs+10 y+5 w%w_controls% h18 valertScreenshot hwndhalertScreenshot gsubmitAlertOptionHandler %Disabled%, % "Screenshot"

        Gui, CavebotGUI:Add, Checkbox, xs+10 y+5 w%w_controls% h18 valertGoToLabel hwndhalertGoToLabel gsubmitAlertOptionHandler %Disabled%, % "Go to label:"
        Gui, CavebotGUI:Add, Edit, xs+10 y+1 w%w_controls% h18 valertLabelName hwndhalertLabelName gsubmitAlertOptionHandler Disabled,
        SetEditCueBanner(halertLabelName, "label name...")


        ; Gui, CavebotGUI:Add, Button, xs+10 yp+20 w85 h35 gScriptImagesGUI, % LANGUAGE = "PT-BR" ? "Abrir Script Images" : "Open Script Images"
        TT.Add(halertPlaySound, LANGUAGE = "PT-BR" ? "Toca o som de alarme" : "Play the alarm sound")
        TT.Add(halertPauseCavebot, LANGUAGE = "PT-BR" ? "Pausar o Cavebot/Targeting`n`nO user value ""unpauseBotAfter"" irá despausar após determinado tempo em segundos." : "Pause Cavebot/Targeting`n`nThe user value ""unpauseBotAfter"" will unpause after a certain time in seconds.")
        TT.Add(halertLogout, LANGUAGE = "PT-BR" ? "Pressiona Ctrl+Q para logar, tenta logar 3 vezes" : "Press Ctrl+Q to logout, tries to logout 3 times")
        TT.Add(halertExitGame, LANGUAGE = "PT-BR" ? "Força exitar o jogo(fechando a janela do Tibia)" : "Force exit the game(closing Tibia window)")
        TT.Add(halertTelegram, LANGUAGE = "PT-BR" ? "Envia uma mensagem no Telegram quando o alarme for disparado`n`nSe a opção ""Screenshot"" estiver marcada, irá enviar também a screenshot" : "Send a Telegram message when the alarm triggers`n`nIf the ""Screenshot"" option is checked, it will also send a screenshot")
        TT.Add(halertScreenshot, LANGUAGE = "PT-BR" ? "Salva a screenshot na pasta Alerts`n`nSe a opção ""Telegram"" estiver marcada, irá também enviar a screenshot " : "Save a screenshot in the Alerts folder`n`nIf the ""Telegram"" option is checked, it will also send the screenshot")

        labelTriggerString := LANGUAGE = "PT-BR" ? "`n`nImportante: o label será disparado somente uma vez quando o alerta é disparado, para ir para o label quando o alerta disparar novamente, é necessário desabilitar e habilitar o Alert.`nVocê pode fazer isto usando a action ""setsetting""(veja exemplos na documentação) no Cavebot ou manualmente na aba Alerts" : "`n`nImportant: the label will be triggered only once when the alert is triggered, to make it go to the label when the alert triggers again, it's needed to disable and enable the Alert.`nYou can do it using the Action ""setsetting""(see examples in documentation) in the Cavebot or manually in the Alerts tab."

        TT.Add(halertGoToLabel, LANGUAGE = "PT-BR" ? "Se o Cavebot estiver rodando, faz ele executar a action gotolabel()" labelTriggerString : "If Cavebot is running, make it run the gotolabel() action" labelTriggerString)
        TT.Add(halertLabelName, LANGUAGE = "PT-BR" ? "Label do waypoint para ir quando o Alert for disparado." labelTriggerString : "Label of the waypoint to go to when the Alert is triggered." labelTriggerString)

        Gui, CavebotGUI:Add, Groupbox, x%x_group1% y+18 w%w_group% h65 Section, Options

            new _ControlFactory(_ControlFactory.SCRIPT_IMAGES_BUTTON)
            .xs(10).yp(20).w(85).h(35)
            .add()

        Gui, CavebotGUI:Add, Text, x+5 yp+12, Delay (ms):
        Gui, CavebotGUI:Add, Edit, x+3 yp-2 w35 h18 valertsDelay galertsDelay hwndhalertsDelay 0x2000, % alertsObj.settings.delay
        TT.Add(halertsDelay, txt("Delay após checar cada Alert, quanto menor o delay, mais rápido os alertas serão checados, porém maior será o uso de CPU, então aumentar o delay é uma forma de diminuir o uso de CPU do ""Alerts.exe"".`nO padrão é ", "Delay after checking each Alert, the lower the delay, the faster the alerts will be checked, but the CPU usage will be higher, so increasing the delay is a way to decrease the CPU usage of the ""Alerts.exe"".`nThe default is ") AlertsHandler.minAlertDelay "ms.")

        Gui, CavebotGUI:Add, Groupbox, x%x_group1% y+30 w%w_group% h55 Section, Telegram
        Gui, CavebotGUI:Add, Button, xs+10 yp+20 w%w_controls% gsetupTelegramGUI, % LANGUAGE = "PT-BR" ? "Configurar Telegram" : "Setup Telegram"


        _GuiHandler.tutorialButtonModule("Alerts")
    }

    getSelectedAlert() {
        GuiControlGet, alertName   
        if (alertName != "")
            return alertName

        alertName := _ListviewHandler.getSelectedItemOnLV("LV_AlertsList", column := 1, defaultGUI := "CavebotGUI", returnRow := false)
        if (alertName = "" OR alertName = "Alert Name")
            return
        return alertName
    }

    LV_AlertsList() {

        Gui, CavebotGUI:Default
        Gui, ListView, LV_AlertsList

        alertName := _ListviewHandler.getSelectedItemOnLV("LV_AlertsList", column := 1, defaultGUI := "CavebotGUI", returnRow := false)
        if (alertName = "" OR alertName = "Alert Name")
            return


        GuiControl, CavebotGUI:, alertName, % alertName
        GuiControl, CavebotGUI:, alertEnabled, % alertsObj[alertName].enabled = true ? 1 : 0
        GuiControl, CavebotGUI:, alertExitGame, % alertsObj[alertName].exitGame = true ? 1 : 0
        GuiControl, CavebotGUI:, alertGoToLabel, % alertsObj[alertName].goToLabel = true ? 1 : 0
        GuiControlEdit("CavebotGUI", "alertLabelName", alertsObj[alertName].labelName, "submitAlertOptionHandler")
        GuiControl, % "CavebotGUI:" (alertsObj[alertName].goToLabel = true ? "Enable" : "Disable"), alertLabelName

        GuiControl, CavebotGUI:, alertLogout, % alertsObj[alertName].logout = true ? 1 : 0
        GuiControl, CavebotGUI:, alertPlaySound, % alertsObj[alertName].playSound = true ? 1 : 0
        GuiControl, CavebotGUI:, alertPauseCavebot, % alertsObj[alertName].pauseCavebot = true ? 1 : 0
        GuiControl, CavebotGUI:, alertScreenshot, % alertsObj[alertName].screenshot = true ? 1 : 0
        GuiControl, CavebotGUI:, alertTelegram, % alertsObj[alertName].telegram = true ? 1 : 0

        switch alertName {
            case "disconnected":
                GuiControl, CavebotGUI:Disable, alertLogout
                GuiControl, CavebotGUI:Disable, alertExitGame
            default:
                GuiControl, CavebotGUI:Enable, alertLogout
                GuiControl, CavebotGUI:Enable, alertExitGame

        }
        GuiControl, CavebotGUI:Enable, alertEnabled
        GuiControl, CavebotGUI:Enable, editUserValueButton

        GuiControl, CavebotGUI:, alertEnabled, % alertsObj[alertName].enabled = true ? this.disabledText : this.enabledText
        this.changeImageAlertButtons(alertName)


        If (A_GuiEvent = "DoubleClick" OR A_GuiEvent = "RightClick") {

            alertsObj[alertName].enabled := !alertsObj[alertName].enabled
            if (alertsObj[alertName].enabled = 1) {

                try {
                    _AlertsHandler.checkBeforeEnabling(alertName)
                } catch e {
                    alertsObj[alertName].enabled := 0
                    _AlertsHandler.disableAlert(alertNanme)
                    MsgBox, 64, % A_ThisFunc, % e.Message, % e.What
                    return
                }
            }
            GuiControl, CavebotGUI:, alertEnabled, % alertsObj[alertName].enabled = true ? 1 : 0
            AlertsHandler.changeAlertEnabled(alertName, save := true)
            if (alertsObj[alertName].enabled = 1)
                AlertsHandler.runAlertsExe()
        }


        ; LV_GetText(UseItemText,selectedLine,4)
        ; UseTrashItemEdit := UseItemText = "true" ? 1 : 0

        ; GuiControl, CavebotGUI:, UseTrashItemEdit, % UseTrashItemEdit

    }


    loadAlertsListLV() {
        try {
            _ListviewHandler.loadingLV("LV_AlertsList")
        } catch {
            return
        }

        /**
        */
        IL_Destroy(ImageListID_LV_AlertsList)  ; Required for image lists used by tab_name controls.

        IconWidth    := 1
        IconHeight   := 41
        IconBitDepth := 24 ;
        InitialCount :=  1 ; The starting Number of Icons available in ImageList
        GrowCount    :=  1

        ImageListID_LV_AlertsList  := DllCall( "ImageList_Create", Int,IconWidth,    Int,IconHeight
            , Int,IconBitDepth, Int,InitialCount
            , Int,GrowCount )

        Gui, ListView, LV_AlertsList
        LV_SetImageList( ImageListID_LV_AlertsList, 1 ) ; 0 for large icons, 1 for small icons


        ; msgbox, % serialize(alertsObj)
        for alertName, alertAtributes in alertsObj
        {
            if (alertName = AlertsSystem.settingsKey) {
                continue
            }

            if (uncompatibleFunction("alerts", alertName)) {
                continue
            }

            switch alertName {
                case "Player on Battle List":
                    /**
                    hide on non Tibia 12/13
                    */
                    if (isNotTibia13())
                        continue
                case "Disconnected":
                    if (OldBotSettings.settingsJsonObj.disconnectedCheck.enabled = false)
                        continue
            }
            Gui, ListView, LV_AlertsList
            ; msgbox, % alertName
            LV_Add("", this.rowAlertName(alertName), this.rowEnabled(alertName), this.rowPlaySound(alertName), this.rowLogout(alertName), this.rowPauseCavebot(alertName), this.rowExitGame(alertName), this.rowTelegram(alertName), this.rowScreenshot(alertName), this.rowLabel(alertName), this.rowUserValue(alertName))
            ; msgbox, % alertName " / " serialize(alertAtributes) "`n`n" serialize(alertsObj[alertName])
        }

        Loop, % this.LVColumnsCount {
            Gui, ListView, LV_AlertsList
            LV_ModifyCol(A_Index, "autohdr")
        }

        LV_ModifyCol(1, "Left")
        LV_ModifyCol(10, 550) ; user value
        return
    }

    rowAlertName(alertName) {
        return (alertName = "disconnected") ? "Disconnected" : alertName
    }

    rowEnabled(alertName) {
        return alertsObj[alertName].enabled = true ? "true" : "false"
    }

    rowPlaySound(alertName) {
        return alertsObj[alertName].playSound = true ? "yes" : "no"
    }

    rowPauseCavebot(alertName) {
        return alertsObj[alertName].pauseCavebot = true ? "yes" : "no"
    }

    rowLogout(alertName) {
        return alertsObj[alertName].logout = true ? "yes" : "no"
    }

    rowExitGame(alertName) {
        return alertsObj[alertName].exitGame = true ? "yes" : "no"
    }

    rowTelegram(alertName) {
        return alertsObj[alertName].telegram = true ? "yes" : "no"
    }

    rowScreenshot(alertName) {
        return alertsObj[alertName].screenshot = true ? "yes" : "no"
    }

    rowLabel(alertName) {
        return alertsObj[alertName].gotolabel = true ? (alertsObj[alertName].labelName = "" ? "<no label>" : alertsObj[alertName].labelName) : "false"
    }

    rowUserValue(alertName) {
        string := "{"
        ; msgbox, % alertName "`n" serialize(alertsObj[alertName]["userValue"])
        for a, values in alertsObj[alertName]["userValue"]
        {
            ; msgbox, % a " = " values
            for key, value in values
                string .= """" key """" ": " value ", "
            ; string .= """" key """" ": " """" value """" ", "
        }
        StringTrimRight, string, string, 2
        if (StrLen(string) > 2)
            string .= "}"
        return string

    }

    updateAlertRow(alertName) {
        rowNumber := _ListviewHandler.findRowByContent(alertName, 1, "LV_AlertsList", defaultGUI := "CavebotGUI")
        if (rowNumber < 1) {
            if (!A_IsCompiled) {
                ; Msgbox, 48, % A_ThisFunc, % "alertName = " alertName ", rowNumber = "  rowNumber
            }
            return
        }

        LV_Modify(rowNumber, "", this.rowAlertName(alertName), this.rowEnabled(alertName), this.rowPlaySound(alertName),this.rowLogout(alertName), this.rowPauseCavebot(alertName), this.rowExitGame(alertName), this.rowTelegram(alertName), this.rowScreenshot(alertName), this.rowLabel(alertName), this.rowUserValue(alertName))
    }


    changeImageAlertButtons(alertName) {
        GuiControl, % "CavebotGUI:" (InStr(alertName, "Image is ") ? "Enable" : "Disable"), addAlertButton
        GuiControl, % "CavebotGUI:" (InStr(alertName, "Image is ") ? "Enable" : "Disable"), deleteAlertButton
    }




}
