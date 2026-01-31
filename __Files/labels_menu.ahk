
AbrirAnydesk:
    CarregandoGUI(LANGUAGE = "PT-BR" ? "Abrindo..." : "Opening...")
    dir = %A_WorkingDir%\Data\Files\Third Part Programs\AnyDesk.exe
    try
        Run, %dir%
    catch {
        Gui, Carregando:Destroy
        Msgbox, 48,, % "It was not possible to open the executable in: " dir
        return
    }
    Gui, Carregando:Destroy
return

AbrirShareX:
    CarregandoGUI(LANGUAGE = "PT-BR" ? "Abrindo..." : "Opening...")
    dir = %A_WorkingDir%\Data\Files\Third Part Programs\ShareX-portable\ShareX.exe
    try
        Run, %dir%
    catch {
        Gui, Carregando:Destroy
        Msgbox, 48,, % "It was not possible to open the executable in: " dir
        return
    }
    Gui, Carregando:Destroy
return

OpenDebugView:
    CarregandoGUI(LANGUAGE = "PT-BR" ? "Abrindo..." : "Opening...")
    dir = %A_WorkingDir%\Data\Files\Third Part Programs\DebugView\Dbgview.exe
    try
        Run, %dir%
    catch {
        Gui, Carregando:Destroy
        Msgbox, 48,, % "It was not possible to open the executable in: " dir
        return
    }
    Gui, Carregando:Destroy
return

OpenRamMemoryMonitor:
    CarregandoGUI(LANGUAGE = "PT-BR" ? "Abrindo..." : "Opening...")
    dir = %A_WorkingDir%\Data\Files\Third Part Programs\memory_usage.ahk
    try
        Run, %dir%
    catch {
        Gui, Carregando:Destroy
        Msgbox, 48,, % "It was not possible to open the executable in: " dir
        return
    }
    Gui, Carregando:Destroy
return

AbrirCoreTemp:
    CarregandoGUI(LANGUAGE = "PT-BR" ? "Abrindo..." : "Opening...")
    dir = %A_WorkingDir%\Data\Files\Third Part Programs\Core Temp.exe
    try
        Run, %dir%
    catch {
        Gui, Carregando:Destroy
        Msgbox, 48,, % "It was not possible to open the executable in: " dir
        return
    }
    Gui, Carregando:Destroy
return

OpenHardwareMonitor:
    CarregandoGUI(LANGUAGE = "PT-BR" ? "Abrindo..." : "Opening...")
    dir = %A_WorkingDir%\Data\Files\Third Part Programs\OpenHardwareMonitor\OpenHardwareMonitor.exe
    try
        Run, %dir%
    catch {
        Gui, Carregando:Destroy
        Msgbox, 48,, % "It was not possible to open the executable in: " dir
        return
    }
    Gui, Carregando:Destroy
return

OpenWindowSpy:
    CarregandoGUI(LANGUAGE = "PT-BR" ? "Abrindo..." : "Opening...")

    dir = %A_WorkingDir%\Data\Files\Third Part Programs\WindowSpy.ahk
    try
        Run, %dir%
    catch {
        Gui, Carregando:Destroy
        Msgbox, 48,, % "It was not possible to open the executable in: " dir
        return
    }
    Gui, Carregando:Destroy
return

OpenExecutablesFolder:
    dir := "Data\Executables"
    try Run, % dir
    catch e {
        Msgbox, 48, % "", % "Failed to open folder directory:`n" dir, 4
    }
return

AbrirPastaOldBot:
    Run, %A_WorkingDir%
return
AbrirPastaCavebot:
    Run, %A_WorkingDir%\Cavebot\
return

AbrirPastaShareX:
    dir := A_WorkingDir "\Data\Files\Third Part Programs\ShareX-portable\ShareX\Screenshots\"
    try
        Run, %dir%
    catch
        Msgbox, 16,, % "Failed to open folder: " dir
return

AbrirPastaScreenshots:
    IfNotExist, Data\Screenshots
        FileCreateDir, Data\Screenshots
    Run, Data\Screenshots
return

AbrirPastaScreenshotsTibia:

    try TibiaClient.clientFolderExists()
    catch e {
        Msgbox, 48,, % e.Message
        return
    }
    folder := TibiaClient.clientFolderPath "\screenshots"

    try Run, % folder
    catch {
        Msgbox, 48,, % "Failed to open screenshots folder:`n" folder
    }
return

ExportarClientOptions:
    TibiaClient.exportClientOptions()
return

ImportarClientOptions:
    try TibiaClient.importClientOptions()
    catch e {
        Gui, Carregando:Destroy
        Msgbox,48,, % e.Message
    }
return

OpenFolderHandler:
    dir := ImagesConfig.folder "\" A_ThisMenuItem
    switch A_ThisMenuItem {
        case "Alerts":
            dir := ImagesConfig.alertsFolder
        case "Executables":
            dir := "Data\Executables"
        case "Healing":
            dir := ImagesConfig.healingFolder
        case "Looting":
            dir := ImagesConfig.lootingFolder
        case "Images":
            dir := ImagesConfig.folder
        case "Item Refill":
            dir := ImagesConfig.itemRefillFolder
        case "JSON files",case "JSON files`tAlt+J":
            dir := OldBotSettings.JsonFolder
        case "JSON (Memory)":
            dir := OldBotSettings.JsonFolder "/Memory"
        case "NPCs":
            dir := ImagesConfig.npcsFolder
        case "Reconnect":
            dir := ImagesConfig.reconnectFolder
        case "Sio":
            dir := ImagesConfig.sioFolder
        case "Support":
            dir := ImagesConfig.supportFolder
        case "Targeting":
            dir := ImagesConfig.targetingFolder

        default:
            Msgbox, 64, % "", % "Folder directory not set: " A_ThisMenuItem, 4
            return
    }
    try Run, % dir
    catch e {
        Msgbox, 48, % "", % "Failed to open folder directory:`n" dir, 4
    }
return

TutorialsMenuHandler:
    ; msgbox, % A_ThisMenu "`n" A_ThisMenuItem
    ; msgbox, % A_ThisMenu "`n" A_ThisMenuItem "`n`n" serialize(MenuHandler.menus["Tutorials"][A_ThisMenu])

    url := MenuHandler.menus["Tutorials"][A_ThisMenu][A_ThisMenuItem]

    if (url = "") {
        Msgbox, 64,, % "Empty URL.`nMenu: " A_ThisMenu "`nItem: " A_ThisMenuItem
        return
    }
    ; msgbox, % url

    openURL(url)
return

LogoutMenu:
    IniWrite, % AutoLogin := 0, %DefaultProfile%, accountsettings, AutoLogin
    Reload(false)
return

SaveScriptAsMenu:
    InputBox, newScriptName, % txt("Save script as... (", "Salvar script como... (" currentScript ")"), % txt("Nome do novo script","Name of the new script:"),, 300, 123,,,,, %currentScript%
    if (newScriptName = "")
        return
    if (ErrorLevel = 1)
        return

    try CavebotScript.saveScriptAs(currentScript, newScriptName, throwException := true)
    catch e {
        Msgbox, 48, % "Save script as", % e.Message
        Goto, SaveScriptAsMenu
    }

    Gosub, ScriptListGUI

    row := _ListviewHandler.findRowByContent(newScriptName, 1, "LV_Scripts", "ScriptListGUI")
    _ListviewHandler.selectRow("LV_Scripts", row, "ScriptListGUI")
return



SalvarPerfil:
    InputBox, NovoProfileNome, % LANGUAGE = "PT-BR" ? "Salvar perfil atual como:" : "Save current profile as:", % LANGUAGE = "PT-BR" ? "Nome do perfil:" : "Profile name:",,220,127
    if ErrorLevel = 1
        return
    if (NovoProfileNome = "") {
        Msgbox, 64,, % LANGUAGE = "PT-BR" ? "Escreva o nome para o perfil." : "Write a nome for the profile."
        return
    }
    if (FileExist("settings_" NovoProfileNome ".ini")) {
        Msgbox,48,, % LANGUAGE = "PT-BR" ? "Já existe um perfil com este nome." : "There is already a profile with this name."
        return
    }
    StringReplace, NovoProfileNome, NovoProfileNome, %A_Space%,_, All
    NovoProfileNome := RegExReplace(NovoProfileNome,"[^\w]","")
    ; msgbox, %NovoProfileNome%
    FileCopy, %DefaultProfile%, settings_%NovoProfileNome%.ini, 1
    IniWrite, settings_%NovoProfileNome%.ini, oldbot_profile.ini, profile, DefaultProfile
    msgbox,64,,% LANGUAGE = "PT-BR" ? "Sucesso." : "Success."
return

CarregarPerfil:

    FileSelectFile, SelectedFile,1,settings_xxxxx.ini, % LANGUAGE = "PT-BR" ? "Selecione o arquivo .ini de settings" : "Select the .ini file of settings", (*.ini)
    if (ErrorLevel = 1)
        return
    IfNotInString, SelectedFile, settings
    {
        Msgbox,16,, % LANGUAGE = "PT-BR" ? "Arquivo inválido, selecione um arquivo com a palavra 'settings' no nome." : "Invalid file, select a file with the word 'settings' in the name."
        return
    }
    Gui, Carregando:-Caption +Border +Toolwindow +AlwaysOnTop
    Gui, Carregando:Add, Text,,% LANGUAGE = "PT-BR" ? "Carregando..." : "Loading..."
    Gui, Carregando:Show, NoActivate,
    NovoSettingsIni := SelectedFile
    StringReplace, NovoSettingsIni, NovoSettingsIni, %A_Space%, _, All
    IniWrite, %NovoSettingsIni%, oldbot_profile.ini, profile, DefaultProfile
    IniWrite, 1, %NovoSettingsIni%, accountsettings, AutoLogin
    ; FileSelectFile, OutputVar [, Options, RootDir[\DefaultFilename], Prompt, Filter]
    ; MsgBox, NovoSettingsIni = %NovoSettingsIni%
    Goto, Reload
return

CheckAlwaysOnTop:
    ; if (OldBotAlwaysOnTop = 0)
    ;     return
    WinSet, AlwaysOnTop, On, ahk_id %OldBotHWND%
    Menu, WindowsMenu, Check, % LANGUAGE = "PT-BR" ? "&Ativar Always On Top`tShift+F9" : "&Activate Always On Top`tShift+F9"
return

SetAlwaysOnTop:
    if (OldBotAlwaysOnTop = 1) {
        OldBotAlwaysOnTop := 0
        WinSet, AlwaysOnTop, Off, ahk_id %OldBotHWND%
        Menu, WindowsMenu, Uncheck, % LANGUAGE = "PT-BR" ? "&Ativar Always On Top`tShift+F9" : "&Activate Always On Top`tShift+F9"
    } else {
        OldBotAlwaysOnTop := 1
        WinSet, AlwaysOnTop, On, ahk_id %OldBotHWND%
        Menu, WindowsMenu, Check, % LANGUAGE = "PT-BR" ? "&Ativar Always On Top`tShift+F9" : "&Activate Always On Top`tShift+F9"
    }
    ; IniWrite, %OldBotAlwaysOnTop%, %DefaultProfile%, settings, OldBotAlwaysOnTop
return

toggleTransparentOldBot:
    TransparentOldBot := !TransparentOldBot
    if (TransparentOldBot = 0)
        Menu, WindowsMenu, Uncheck, % "&" txt("Transparência`tShift+F12", "Transparency`tShift+F12")
    else {
        Menu, WindowsMenu, Check, % "&" txt("Transparência`tShift+F12", "Transparency`tShift+F12")
    }
    IniWrite, %TransparentOldBot%, %DefaultProfile%, settings, TransparentOldBot
    Gosub, TransparentOldBot
return