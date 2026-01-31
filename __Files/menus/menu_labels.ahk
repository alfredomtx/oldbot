
OpenWaypointTibiaMapsIoStart:
    waypointCoords := WaypointHandler.getAtribute("coordinates", selectedWaypointEdit)
    URL := "https://tibiamaps.io/map#" waypointCoords.x "," waypointCoords.y "," waypointCoords.z ":2"
    Goto, OpenWaypointTibiaMapsIo

OpenWaypointTibiaMapsIoEnd:
    waypointCoords := WaypointHandler.getAtribute("coordinates", selectedWaypointEdit)
    URL := "https://tibiamaps.io/map#" waypointCoords.x + WaypointHandler.getAtribute("rangeX", selectedWaypointEdit) "," waypointCoords.y + WaypointHandler.getAtribute("rangeY", selectedWaypointEdit) "," waypointCoords.z ":2"
    Goto, OpenWaypointTibiaMapsIo

OpenWaypointMapViewerStart:
    waypointCoords := WaypointHandler.getAtribute("coordinates", selectedWaypointEdit)
    MinimapGUI.changeCoordinatesControl(waypointCoords.x, waypointCoords.y, waypointCoords.z)
    Goto, minimapViewer

OpenWaypointMapViewerEnd:
    waypointCoords := WaypointHandler.getAtribute("coordinates", selectedWaypointEdit)
    MinimapGUI.changeCoordinatesControl(waypointCoords.x + WaypointHandler.getAtribute("rangeX", selectedWaypointEdit), waypointCoords.y + WaypointHandler.getAtribute("rangeY", selectedWaypointEdit), waypointCoords.z)
    Goto, minimapViewer

OpenWaypointTibiaMapsIo:
    if (selectedWaypointEdit = "")
        return
    CarregandoGUI("Opening...")
    try
        Run, %URL%
    catch {
        Gui, Carregando:Destroy
        Msgbox, 48,, Error opening URL: %URL%
    }
    Gui, Carregando:Destroy
return


;MenuHandler:
MenuHandler:
    ; MsgBox, %A_ThisMenuItem%
    ; Clipboard := A_ThisMenuItem
    if (A_ThisMenuItem = "&Transparência`tShift+F12" OR A_ThisMenuItem = "&Transparency`tShift+F12") {
        Goto, toggleTransparentOldBot     
    }
    if (A_ThisMenuItem = "&Ativar Always On Top`tShift+F9" OR A_ThisMenuItem = "&Activate Always On Top`tShift+F9") {
        gosub, SetAlwaysOnTop
    return
}
if (A_ThisMenuItem = "Esconder interface`tShift+F10" OR A_ThisMenuItem = "Hide interface`tShift+F10") {
    BotHidden = 1
    ; IniWrite, 1, %DefaultProfile%, settings, BotHidden
    ; Goto, TransparentOldBot
    WinHide, ahk_id %OldBotHWND%
    return      
}
if (A_ThisMenuItem = "Mostrar janela de &funções`tShift+F11" OR A_ThisMenuItem = "Show &functions window`tShift+F11") {
    MostrarShortcutGUI := !MostrarShortcutGUI
    GetShortcutWindowPos(minimized := false)
    IniWrite, %MostrarShortcutGUI%, %DefaultProfile%, settings, MostrarShortcutGUI
    if (MostrarShortcutGUI = 0) {
        Menu, WindowsMenu, Uncheck, % LANGUAGE = "PT-BR" ? "Mostrar janela de &funções`tShift+F11" : "Show &functions window`tShift+F11"
        Gui, ShortcutScripts:Hide
    } else {
        Menu, WindowsMenu, Check, % LANGUAGE = "PT-BR" ? "Mostrar janela de &funções`tShift+F11" : "Show &functions window`tShift+F11"
        Goto, CreateShortcutGUI_Forced
    }
    return
}
if (A_ThisMenuItem = "Auto login bot ON") {
    ; msgbox %LANGUAGE%
    Menu, EditMenu, Check, Auto login bot ON
    Menu, EditMenu, Uncheck, Auto login bot OFF
    IniWrite, 1, %DefaultProfile%, accountsettings, AutoLogin
    return
}
if (A_ThisMenuItem = "Auto login bot OFF") {
    ; msgbox %LANGUAGE%
    Menu, EditMenu, Check, Auto login bot OFF
    Menu, EditMenu, Uncheck, Auto login bot ON
    IniWrite, 0, %DefaultProfile%, accountsettings, AutoLogin
    return
}



if (A_ThisMenuItem = "Validar conta por IP") OR (A_ThisMenuItem = "Validate account by IP") {
    Gui, Carregando:Destroy
    Gui, Carregando:-Caption +Border +Toolwindow +AlwaysOnTop
    Gui, Carregando:Add, Text,,% LANGUAGE = "PT-BR" ? "Carregando..." : "Loading..."
    Gui, Carregando:Show, NoActivate,
    params := {"UPDATE_VALIDATION": 1, "acc_id": acc_id, "type": "IP"}
    try API.call("up", params)
    catch e {
        Gui, Carregando:Destroy
        Msgbox,16,,% "Error updating the account validation, please try again."
        return
    }
    IniWrite, 1, %DefaultProfile%, accountsettings, AutoLogin
    Goto, Reload
    return
}
if (A_ThisMenuItem = "Validar conta por PC_ID") OR (A_ThisMenuItem = "Validate account by PC_ID") {
    Gui, Carregando:Destroy
    Gui, Carregando:-Caption +Border +Toolwindow +AlwaysOnTop
    Gui, Carregando:Add, Text,,% LANGUAGE = "PT-BR" ? "Carregando..." : "Loading..."
    Gui, Carregando:Show, NoActivate,
    params := {"UPDATE_VALIDATION": 1, "acc_id": acc_id, "type": "PC_ID"}
    try API.call("up", params)
    catch e {
        Gui, Carregando:Destroy
        Msgbox,16,,% "Error updating the account validation, please try again."
        return
    }
    IniWrite, 1, %DefaultProfile%, accountsettings, AutoLogin
    Goto, Reload
    return
}
; if (A_ThisMenuItem = "Use HTTP connection") {
; Menu, EditMenu, Check, Use HTTP connection
; Menu, EditMenu, Uncheck, Use HTTPS connection
; IniWrite, 0, %DefaultProfile%, advanced, HTTPS
; Goto, Reload
; return
; }
; if (A_ThisMenuItem = "Use HTTPS connection") {
; Menu, EditMenu, Check, Use HTTPS connection
; Menu, EditMenu, Uncheck, Use HTTP connection
; IniWrite, 1, %DefaultProfile%, advanced, HTTPS
; Goto, Reload
; return
; }


if (A_ThisMenuItem = "Português") {
    LANGUAGE_new = PT-BR
    if (LANGUAGE = LANGUAGE_new) {
        return
    }
    global LANGUAGE := LANGUAGE_new
    ; msgbox %LANGUAGE%
    IniWrite, %LANGUAGE%, %DefaultProfile%, settings, LANGUAGE
    IniWrite, 1, %DefaultProfile%, accountsettings, AutoLogin
    Goto, Reload
    return
}
if (A_ThisMenuItem = "English") {
    ; msgbox, a
    LANGUAGE_new = EN-US
    if (LANGUAGE = LANGUAGE_new) {
        return
    }
    global LANGUAGE := LANGUAGE_new
    IniWrite, %LANGUAGE%, %DefaultProfile%, settings, LANGUAGE
    IniWrite, 1, %DefaultProfile%, accountsettings, AutoLogin
    Goto, Reload
    return
}
if (RegExMatch(A_ThisMenuItem,"Sair|Exit|Ctrl+W")) {
    Goto, ElfGUIGuiClose
}
if (RegExMatch(A_ThisMenuItem,"Reload Bot|Ctrl+R")) {
    WinGetPos, x, y,,, OldBot - %DefaultProfile_SemIni%
    if (x = "" OR y = "")
        WinGetPos, x, y,,, OldBot *BETA
    IniWrite, %x%, %DefaultProfile%, settings, MainGUI_X
    IniWrite, %y%, %DefaultProfile%, settings, MainGUI_Y
    WinGetPos, x, y,,, Scripts shortcut
    if (x != "" && y != "") {
        ScriptsShortcutGUI_X := x
        ScriptsShortcutGUI_Y := y
        IniWrite, %ScriptsShortcutGUI_X%, %DefaultProfile%, settings, ScriptsShortcutGUI_X
        IniWrite, %ScriptsShortcutGUI_Y%, %DefaultProfile%, settings, ScriptsShortcutGUI_Y
    }
    IniWrite, 1, %DefaultProfile%, accountsettings, AutoLogin
    Goto, Reload
    return
}
if (A_ThisMenuItem = "Sobre" OR A_ThisMenuItem = "About") {
    Goto, AboutGUI
}
if (A_ThisMenuItem = "Licença" OR A_ThisMenuItem = "License") {
    Goto, LicenseGUI
}








ChangeMenus:

    Menu, WindowsMenu, Disable, % LANGUAGE = "PT-BR" ? "Mostrar janela de &funções`tShift+F11" : "Show &functions window`tShift+F11"
    Menu, WindowsMenu, Disable, % "&" txt("Transparência`tShift+F12", "Transparency`tShift+F12")
    if (MostrarShortcutGUI = 1)
        Menu, WindowsMenu, Check, % LANGUAGE = "PT-BR" ? "Mostrar janela de &funções`tShift+F11" : "Show &functions window`tShift+F11"
    else
        Menu, WindowsMenu, Uncheck, % LANGUAGE = "PT-BR" ? "Mostrar janela de &funções`tShift+F11" : "Show &functions window`tShift+F11"

    if (TransparentOldBot = 1) {
        try Menu, WindowsMenu, Check, % "&" txt("Transparência`tShift+F12", "Transparency`tShift+F12")
        catch {
        }
    } else {
        try Menu, WindowsMenu, Uncheck, % "&" txt("Transparência`tShift+F12", "Transparency`tShift+F12")
        catch {
        }
    }

    Menu, WindowsMenu, Enable, % LANGUAGE = "PT-BR" ? "Mostrar janela de &funções`tShift+F11" : "Show &functions window`tShift+F11"
    Menu, WindowsMenu, Enable, % "&" txt("Transparência`tShift+F12", "Transparency`tShift+F12")


    Menu, EditMenu, Add ; with no more options, this is a seperator

    Menu, EditMenu, Add, % LANGUAGE = "PT-BR" ? "Validar conta por IP" : "Validate account by IP", MenuHandler

    Menu, EditMenu, Add, % LANGUAGE = "PT-BR" ? "Validar conta por PC_ID" : "Validate account by PC_ID", MenuHandler
    Menu, EditMenu, Add, % LANGUAGE = "PT-BR" ? "Sobre validação de conta " : "About account validation", InfoValidacaConta
    try Menu, EditMenu, Icon, % LANGUAGE = "PT-BR" ? "Sobre validação de conta " : "About account validation", imageres.dll,77,16
    catch {
    }
    Menu, EditMenu, Disable, % LANGUAGE = "PT-BR" ? "Validar conta por IP" : "Validate account by IP"
    Menu, EditMenu, Disable, % LANGUAGE = "PT-BR" ? "Validar conta por PC_ID" : "Validate account by PC_ID"

    Menu, EditMenu, Enable, % LANGUAGE = "PT-BR" ? "Validar conta por IP" : "Validate account by IP"
    Menu, EditMenu, Enable, % LANGUAGE = "PT-BR" ? "Validar conta por PC_ID" : "Validate account by PC_ID"


    ; Menu, FileMenu, Enable, % LANGUAGE = "PT-BR" ? "Carregar script`tCtrl+L" : "Load script`tCtrl+L"


    ; Menu, EditMenu, Enable, Auto login


    if (validation_type = "PC_ID")
        Menu, EditMenu, Check, % LANGUAGE = "PT-BR" ? "Validar conta por PC_ID" : "Validate account by PC_ID"
    else
        Menu, EditMenu, Check, % LANGUAGE = "PT-BR" ? "Validar conta por IP" : "Validate account by IP"
    ; Menu, HelpMenu, Enable, WhatsApp Help




return






API_downloadCreatures:
    API.downloadCreatures()
return
API_uploadCreatures:
    API.uploadCreatures()
return