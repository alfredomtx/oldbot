selectTibiaClientLabel:
    GetKeyState, AltPressed, Alt, D
    if (AltPressed = "D") {
        if (OldbotSettings.settingsJsonObj.tibiaClient.selectClientButtonOpenFolderInsteadOfClient = true) {
            Goto, openClientPath
        } else {
            Goto, openSelectedTibiaClient
        }
    }

    TibiaClient.showOtherClients := false
    TibiaClient.listTibiaClientsGUI()
return

openSelectedTibiaClient:
    if (OldbotSettings.settingsJsonObj.tibiaClient.selectClientButtonOpenFolderInsteadOfClient)
        Goto, openClientPath

    TibiaClient.openTibiaClient()

    fn := TibiaClient.autoSelectFirstClient.bind(TibiaClient)
    SetTimer, % fn, Delete
    SetTimer, % fn, -2000
    SetTimer, % fn, -3000
    ; SetTimer, selectTibiaClientLabel, Delete
    ; SetTimer, selectTibiaClientLabel, -2000
return

copySelectedTibiaClientID:
    Gui, SelectClientGUI:Submit, NoHide
    if (TibiaClientList = "") {
        msgbox, 64,, % "Select a client on the list.", 1
        return
    }

    copyToClipboard(TibiaClient.clientsList[TibiaClientList].id)

    TrayTipMessage("Success", "Client ID copied to clipboard(Ctrl+V)", 2)
return


selectClientExePath:
    try TibiaClient.selectTibiaExePath()
    catch e {
        Msgbox, 48,, % e.Message
        return
    }
    gosub, selectTibiaClientLabel
return

openClientPath:
    dir := TibiaClient.clientDir
    if (dir = "") {
        Msgbox, 64,, % "Tibia Client directory not set", 2
        return
    }
    try Run, % dir
    catch e {
        Msgbox, 48, % A_ThisLabel, % "Failed to open folder directory:`n" dir, 4
    }
return

openMinimapPath:
    dir := TibiaClient.clientMinimapPath
    if (dir = "") {
        Msgbox, 64,, % "Minimap folder directory not set", 2
        return
    }
    try Run, % dir
    catch e {
        Msgbox, 48, % A_ThisLabel, % "Failed to open folder directory:`n" dir, 4
    }
return

SelectClientGUIGuiClose:
SelectClientGUIGuiEscape:
    Gui, SelectClientGUI:Destroy
return

selectTibiaClientFromList:
    Gui, SelectClientGUI:Submit, NoHide
    Gui, SelectClientGUI:Destroy
    if (TibiaClientList = "") {
        Msgbox, 48,, % LANGUAGE = "PT-BR" ? "Selecione um cliente do Tibia para continuar.`n`nCaso o cliente não esteja aparecendo na lista, certifique-se de que ele está aberto." : "Select a Tibia client to continue.`n`nIn case the client is not appearing in the list, make sure it is opened.", 5
        Goto, selectTibiaClientLabel
    }

    try {
        TibiaClient.selectTibiaClient(TibiaClient.clientsList[TibiaClientList]["id"])
        _Reconnect.autoLogin()
    } catch e {
        _Logger.msgboxException(48, e)
    }

return

RestoreTibiaClientTitle:
    TibiaClient.restoreTibiaWindowTitle()
return

updateMenuTibiaClient:
    TibiaClient.updateMenuClient()
return

showOtherClients:
    TibiaClient.showOtherClients := true
    TibiaClient.listTibiaClientsGUI()
return

TibiaClientSettingsJson:
    GuiControlGet, TibiaClientSettingsJson
    TibiaClient.clientSettingsJson(TibiaClientSettingsJson)
    Reload()
return


LV_ClientsList:
    GuiControl, CavebotGUI:-g, LV_ClientsList
    switch A_GuiEvent {
        case "C":
            selectedRow := _ListviewHandler.getCheckedRow("LV_ClientsList", column := 1, defaultGUI := "SelectClientGUI", true)
            /*
            if unchecked the same row that is already selected, will warn that the client is already selected
            otherwise will set the selected row as the new client
            */
            if (selectedRow = TibiaClient.currentClientRow)
                _ListviewHandler.uncheckRow("LV_ClientsList", TibiaClient.currentClientRow, defaultGUI := "SelectClientGUI")
            selectedRow := _ListviewHandler.getCheckedRow("LV_ClientsList", column := 1, defaultGUI := "SelectClientGUI", true)

            /*
            if is zero means that there is no client checked, to the user unchecked the current client
            */
            selectedClient := _ListviewHandler.getCheckedRow("LV_ClientsList", column := 1, defaultGUI := "SelectClientGUI")

            /*
            when double click a row
            */
            if (selectedClient = "Name") {
                _ListviewHandler.checkRow("LV_ClientsList", TibiaClient.currentClientRow, defaultGUI := "SelectClientGUI", focus := false)
                return
            }
            if (selectedRow = 0) {
                _ListviewHandler.checkRow("LV_ClientsList", TibiaClient.currentClientRow, defaultGUI := "SelectClientGUI")
                Gui, SelectClientGUI:Hide
                msgbox, 64,, % LANGUAGE = "PT-BR" ? "O cliente """ selectedClient """  já está selecionado, escolha outro caso queira mudar." : "The client """ selectedClient """ is already selected, choose another in case you want to change.", 8
                Gui, SelectClientGUI:Show
                return
            }
            ; msgbox, % selectedClient
            if (selectedClient = "" OR selectedClient = "#")
                return
            ; msgbox, % selectedClient
            TibiaClient.clientSettingsJson(selectedClient)
            Reload()
    }
    GuiControl, CavebotGUI:+gLV_ClientsList, LV_ClientsList
return


clientListFiter:
    Gui, SelectClientGUI:Submit, NoHide
    IniWrite, % %A_GuiControl%, %DefaultProfile%, selectclient_filters, %A_GuiControl%
    SetTimer, applyClientListFiter, Delete
    SetTimer, applyClientListFiter, -300
return


applyClientListFiter:
        new _SelectClientGUI(true).loadClientsListLV()
return

fixPagoderaGraphicClient:
    Gui, SelectClientGUI:Hide
    try TibiaClient.clientFolderExists()
    catch e {
        Msgbox, 48,, % e.Message, 6
        Gui, SelectClientGUI:Show
        return
    }
    TibiaClient.replaceGraphicResourcesFilePagodera()
    Gui, SelectClientGUI:Show
return

addNewClientMemory:
    Gui, SelectClientGUI:Destroy
    MemoryManager.memoryFindClientGUI()
return