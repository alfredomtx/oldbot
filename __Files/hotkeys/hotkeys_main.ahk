#if !WinActive("ahk_class " _App.GUI_CLASS)
!+r::
    Goto, Reload
return
#if

#If
+F10::
    if (BotHidden = 1) {
        BotHidden = 0
        WinShow, ahk_id %OldBotHWND%
    } else {
        BotHidden = 1
        WinHide, ahk_id %OldBotHWND%
    }
    ; IniWrite, 1, %DefaultProfile%, settings, BotHidden
return

+F11::
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


#If
