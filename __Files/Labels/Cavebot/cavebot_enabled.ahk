CavebotEnabled:
    Gui, CavebotGUI:Default
    Gui, Submit, NoHide
    try {
        GuiControl, CavebotGUI:Disable, CavebotEnabled
        GuiControl, CavebotGUI:Disable, TargetingEnabled
    } catch {
    }
    try {
        if (CavebotEnabled = 1)
            CarregandoGUI(LANGUAGE = "PT-BR" ? "Carregando Cavebot..." : "Loading Cavebot...", 180, 180)
    } catch e {
        _Logger.msgboxException(e, A_ThisLabel, "CarregandoGUI")
    }
    IniWrite, %TargetingEnabled%, %DefaultProfile%, cavebot_settings, TargetingEnabled
    IniWrite, %CavebotEnabled%, %DefaultProfile%, cavebot_settings, CavebotEnabled
    IniWrite, 0, %DefaultProfile%, targeting_system, TargetingRunning
    IniDelete, %DefaultProfile%, cavebot, CurrentWaypointTab

    try {
        if (CavebotEnabled = 0 OR TargetingEnabled = 0) && (CavebotTargeting = 1)
            checkbox_setvalue("CavebotTargeting", 0)
        else if (CavebotEnabled = 1 && TargetingEnabled = 1)
            checkbox_setvalue("CavebotTargeting", 1)
    } catch e {
        _Logger.msgboxException(e, A_ThisLabel, "checkbox_setvalue")
    }

    Error := 0
    if (TargetingEnabled = 1 OR CavebotEnabled = 1) {
        ClientSettings.checkSettingsRoutine()

        if (CheckClientMC() = false)
            Error++

        if (Error > 0) {
            Gui, Carregando:Destroy
            try {
                GuiControl, CavebotGUI:Enable, CavebotEnabled
                GuiControl, CavebotGUI:Enable, TargetingEnabled
            } catch{
            }
            Gosub, DisableCavebotTargeting
            return
        }

    }
    IniDelete, %DefaultProfile%, cavebot, CurrentWaypointTab
    IniDelete, %DefaultProfile%, cavebot, CurrentWaypoint
    if (CavebotEnabled = 1) {
        if (OldBotSettings.settingsJsonObj.configFile == "settings.json") {
            Error++
            Gui, Carregando:Destroy
                new _SelectClientGUI().show()
            msgbox, 48,, % txt("Selecione o OT Server em que você irá usar o bot na lista em ""Selecionar Client"".", "Select the OT Server you will use the bot on the list in ""Select Client""."), 10
            goto, CavebotEnabledError
        }

        if (!scriptSettingsObj.charCoordsFromMemory && CavebotScript.isCoordinate()) {
            Error++
            Gui, Carregando:Destroy
            msgbox, 48,, % txt("A opcão de ""Coordenadas do char da memoria do cliente"" esta desmarcada. Selecione o cliente do OT Server que voce esta usando no botao ""Selecionar Client"".`n`nCaso voce nao encontre na lista, clique no botao ""Adicionar novo cliente"" em baixo da lista.", "The option ""Character coordinates from client memory"" is unchecked. Select the client of the OT server you are using in the ""Select Client"" button.`n`nIn case you don't find the client on the list, click on the ""Add new client"" button below the list."), 30
        }
    } ; if CavebotEnabled = 1

    if (CavebotEnabled = 1 OR TargetingEnabled = 1) {
        if (TibiaClient.isClientOpened() = false) {
            Error++
            TrayTip, % LANGUAGE = "PT-BR" ? "Cliente fechado" : "Client closed", % LANGUAGE = "PT-BR" ? "Abra o cliente do Tibia para iniciar o Cavebot/Targeting." : "Open the Tibia client to start the Cavebot/Targeting.", 2, 2
            SetTimer, HideTrayTip, Delete
            SetTimer, HideTrayTip, -3000
        }


        try {
                new _CharPosition()
        } catch e {
            gosub, setGameAreas
            msgbox, 48,, % e.Message
            Error++
        }
    }

    if (Error > 0) {
        goto, CavebotEnabledError
    }

    switch CavebotEnabled {
        case 1:
            try {
                checkbox_setvalue("CavebotEnabled_2", 1)
            } catch e {
                _Logger.msgboxException(e, A_ThisLabel, "checkbox_setvalue")
            }
            IniWrite, 1, %DefaultProfile%, cavebot_settings, CavebotEnabled_2
        case 0:
            Gosub, DisableCavebot
    }
    switch TargetingEnabled {
        case 1:
            checkbox_setvalue("TargetingEnabled_2", 1)
            IniWrite, 1, %DefaultProfile%, cavebot_settings, TargetingEnabled_2
        case 0:
            Gosub, DisableTargeting
    }

    if (TargetingEnabled = 0) && (CavebotEnabled = 0) {
        HideTrayTip()
        Gui, Carregando:Destroy

        _CavebotExe.stop()
        ; _TargetingExe.stop()
        Process, Close, Alarm.exe
        try {
            GuiControl, CavebotGUI:Enable, CavebotEnabled
            GuiControl, CavebotGUI:Enable, TargetingEnabled
        } catch{
        }

        return
    }

    if (CavebotEnabled || TargetingEnabled)
        CarregandoGUI2(LANGUAGE = "PT-BR" ? "Abrindo executavel do Cavebot..." : "Opening Cavebot executable...", 165)
    ; InfoCarregando(LANGUAGE = "PT-BR" ? "Abrindo executavel do Cavebot..." : "Opening Cavebot executable...")

    if (CavebotEnabled) {
            new _VideoRecorder().open()
    }

    if (A_IsCompiled)
        _CavebotExe.start()
    else {
        ; _CavebotExe.start()
        ; if (CavebotEnabled) {
        Run, Cavebot.ahk
        ; }
        ; if (TargetingEnabled) {
        ;     Run, Targeting.ahk
        ; }
    }
    if (CavebotEnabled = 1 && scriptSettingsObj.startWaypoint > 1) {
        if (scriptSettingsObj.startWaypoint != 1) {
            TrayTip, % LANGUAGE = "PT-BR" ? "Waypoint inicial diferente" : "Different start waypoint", % LANGUAGE = "PT-BR" ? "A waypoint inicial é: " scriptSettingsObj.startWaypoint : "The start waypoint is: " scriptSettingsObj.startWaypoint, 2, 1
            ; Sleep, 2000
            ; HideTrayTip()
            SetTimer, HideTrayTip, -2000
        }
    }

    SetTimer, VerificarExecucaoCavebot, Delete
    if (CavebotEnabled || TargetingEnabled) {
        global timeCheckingCavebot := new _Timer()
        SetTimer, VerificarExecucaoCavebot, 500
    }
    ; Gui, Carregando:Destroy
    try {
        GuiControl, CavebotGUI:Enable, CavebotEnabled
        GuiControl, CavebotGUI:Enable, TargetingEnabled
        Gui, Carregando:Destroy
    } catch{
    }
        new _ReleaseModifierKeys()
return

CavebotEnabledError:
    Gosub, DisableCavebotTargeting
    Gui, Carregando:Destroy
    GuiControl, CavebotGUI:Enable, CavebotEnabled
    GuiControl, CavebotGUI:Enable, TargetingEnabled
return
