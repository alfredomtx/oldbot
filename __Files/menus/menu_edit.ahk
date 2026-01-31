Menu, EditMenu, Add, % "&" txt("Checar configurações do cliente", "Check client settings") "`tCtrl+Shift+P", ChecarConfiguracoesCliente
icon := _Icon.get(_Icon.CHECK_SETTINGS)
try Menu, EditMenu, Icon, % "&" txt("Checar configurações do cliente", "Check client settings") "`tCtrl+Shift+P", % icon.dllName, % icon.number,18
catch {
}

Menu, EditMenu, Add

Menu, EditMenu, Add, % "&" txt("Gerenciar script(restrição)", "Manage script Restriction"), manageScriptRestrictionGUI 
try Menu, EditMenu, Icon, % "&" txt("Gerenciar script(restrição)", "Manage script(restriction)"), imageres.dll,74,16
catch {
}

Menu, EditMenu, Add

try {
    fn := HotkeysFunctionsGUI.createHotkeysFunctionsGUI.bind(HotkeysFunctionsGUI)
    icon := _Icon.get(_Icon.KEYBOARD)
    Menu, EditMenu, Add, % "&" txt("Hotkeys de atalho (janela de funções)", "Shortcut hotkeys (functions window)"), % fn 
    Menu, EditMenu, Icon, % "&" txt("Hotkeys de atalho (janela de funções)", "Shortcut hotkeys (functions window)"), % icon.dllName, % icon.number,16
} catch e {
    _Logger.msgboxException(48, e)
}

Menu, EditMenu, Add


Menu, EditMenu, Add, Auto login bot ON, MenuHandler
Menu, EditMenu, Add, Auto login bot OFF, MenuHandler

IniRead, AutoLogin, %DefaultProfile%, accountsettings, AutoLogin, 0

if (AutoLogin = 1) {
    Menu, EditMenu, Check, Auto login bot ON
    Menu, EditMenu, Uncheck, Auto login bot OFF
} else {
    Menu, EditMenu, Check, Auto login bot OFF
    Menu, EditMenu, Uncheck, Auto login bot ON
}

