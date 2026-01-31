CAVEBOT_SCRIPT :=  txt("Script do Cavebot", "Cavebot Script")
PROFILE_SETTINGS := txt("Configurações de Perfil", "Profile Settings")



/*
Sub_NewMenu
*/

Menu, Sub_NewMenu, Add, % CAVEBOT_SCRIPT "`tCtrl+N", CreateNewScriptFromMenu


try {
    fn := _ProfileGUI.__New.bind(_ProfileGUI)
    icon := _Icon.get(_Icon.SETTINGS)
    Menu, Sub_NewMenu, Add, % PROFILE_SETTINGS, % fn
    Menu, Sub_NewMenu, Icon, % PROFILE_SETTINGS, % icon.dllName, % icon.number,16
} catch e {
    _Logger.msgboxException(48, e)
}


/*
Sub_LoadMenu
*/
Menu, Sub_LoadMenu, Add, % CAVEBOT_SCRIPT "`tCtrl+L", ScriptListGUI

Menu, Sub_LoadMenu, Add, % (LANGUAGE = "PT-BR" ? "Importar" : "Import") " Script...`tCtrl+I", ImportCavebotScript
try {
    icon := _Icon.get(_Icon.SETTINGS)
    Menu, Sub_LoadMenu, Add, % PROFILE_SETTINGS "`tCtrl+E", ProfileGUI
    Menu, Sub_LoadMenu, Icon, % PROFILE_SETTINGS "`tCtrl+E", % icon.dllName, % icon.number,16
} catch e {
    _Logger.msgboxException(48, e)
}

/*
Sub_SaveMenu
*/
MenuHandler.subSaveMenuOptions()



/*
FoldersSubMenu
*/
MenuHandler.createSubOpenFolderMenu()


/*
FileMenu
*/
try {
    icon := _Icon.get(_Icon.SETTINGS)
    Menu, FileMenu, Add, % txt("Confi&gurações", "Settin&gs"), openSettingsGuis
    Menu, FileMenu, Icon, % txt("Confi&gurações", "Settin&gs"), % icon.dllName, % icon.number,18
} catch e {
    _Logger.msgboxException(48, e)
}

Menu, FileMenu, Add

Menu, FileMenu, Add, % "&" txt("Novo", "New"), :Sub_NewMenu
Menu, FileMenu, Add, % "&" txt("Carregar", "Load"), :Sub_LoadMenu
Menu, FileMenu, Add, % "&" txt("Salvar", "Save"), :Sub_SaveMenu

Menu, FileMenu, Add,


Menu, FileMenu, Add, % txt("L&ista de Scripts", "Scripts L&ist") "`tCtrl+L", ScriptListGUI

iconNumber := (isWin11() = true) ? 233 : 232
try Menu, FileMenu, Icon, % txt("L&ista de Scripts", "Scripts L&ist") "`tCtrl+L", imageres.dll,%iconNumber%,16
catch {
}

; Menu, FileMenu, Add, % "Script Cloud" "`tCtrl+L", ScriptListGUIToScriptCloud
; iconNumber := (isWin11() = true) ? 233 : 232
; try Menu, FileMenu, Icon, % "Script Cloud" "`tCtrl+L", imageres.dll,%iconNumber%,16
; catch {
; }

Menu, FileMenu, Add


try {
    instance := new _ClientOptions()
    fn := instance.open.bind(instance)
    Menu, Sub_TibiaClient, Add, % LANGUAGE = "PT-BR" ? "Abrir clientoptions.json" : "Open clientoptions.json", % fn
} catch {
}
Menu, Sub_TibiaClient, Add, % LANGUAGE = "PT-BR" ? "Exportar clientoptions.json" : "Export clientoptions.json", ExportarClientOptions
Menu, Sub_TibiaClient, Add, % LANGUAGE = "PT-BR" ? "Importar clientoptions.json" : "Import clientoptions.json", ImportarClientOptions



openString := (LANGUAGE = "PT-BR" ? "Abrir" : "Open")


Menu, FileMenu, Add, % (LANGUAGE = "PT-BR" ? "Abrir pastas" : "Open folders"), :Sub_FoldersMenu
try Menu, FileMenu, Icon, % (LANGUAGE = "PT-BR" ? "Abrir pastas" : "Open folders"), shell32.dll,4,14
catch {
}

Menu, OpenProgramsMenu, Add, % txt("Abrir &Anydesk`tCtrl+U", "Open &Anydesk`tCtrl+U"), AbrirAnydesk
try Menu, OpenProgramsMenu, Icon, % txt("Abrir &Anydesk`tCtrl+U", "Open &Anydesk`tCtrl+U"), Data\Files\Images\GUI\Icons\third_part\anydesk.ico,0,16
catch {
}

Menu, OpenProgramsMenu, Add, % txt("Abrir Share&X (gravar tela)", "Open Share&X (record screen)"), AbrirShareX
try Menu, OpenProgramsMenu, Icon, % txt("Abrir Share&X (gravar tela)", "Open Share&X (record screen)"), Data\Files\Images\GUI\Icons\third_part\sharex.ico,0,16
catch {
}

Menu, OpenProgramsMenu, Add, % openString (LANGUAGE = "PT-BR" ? " pasta do ShareX(videos gravados)" : " ShareX folder(videos)"), AbrirPastaShareX
try Menu, OpenProgramsMenu, Icon, % openString (LANGUAGE = "PT-BR" ? " pasta do ShareX(videos gravados)" : " ShareX folder(recorded videos)"), shell32.dll,4,14
catch {
}

Menu, OpenProgramsMenu, Add, % openString " &Window Spy", OpenWindowSpy
Menu, OpenProgramsMenu, Add, % openString " Hardware Monitor", OpenHardwareMonitor

Menu, OpenProgramsMenu, Add, % LANGUAGE = "PT-BR" ? "Abrir Core Temp" : "Open Core Temp", AbrirCoreTemp
; try Menu, OpenProgramsMenu, Icon, % LANGUAGE = "PT-BR" ? "Abrir Core Temp" : "Open Core Temp", Data\Files\Images\GUI\Icons\third_part\cpu_temperature.ico,0,18
Menu, OpenProgramsMenu, Add, % openString " &DebugView", OpenDebugView
Menu, OpenProgramsMenu, Add, % openString " RAM Memory Monitor", OpenRamMemoryMonitor

Menu, FileMenu, Add, % txt("Abrir &programas", "Open &programs"), :OpenProgramsMenu
switch A_OSVersion {
    case "10.0.22000", case "10.0.22621": ; windows 11
        try Menu, FileMenu, Icon, % txt("Abrir &programas", "Open &programs"), shell32.dll,25,16
        catch {
        }
    default:
}

Menu, FileMenu, Add




if (isTibia13()) {
    Menu, FileMenu, Add, Tibia Client, :Sub_TibiaClient
    try Menu, FileMenu, Icon, Tibia Client, Data\Files\Images\GUI\icons\icon_tibia.ico,0,16
    catch {
    }
}

Menu, FileMenu, Add

MenuHandler.fileMenuCloseOptions()
