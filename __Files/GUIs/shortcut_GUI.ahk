
CreateShortcutGUI:
    global SelectedFunctions
    if (ShortcutScriptsHWND != "")
    {
        WinMove, ahk_id %ShortcutScriptsHWND%,, ScriptsShortcutGUI_X, ScriptsShortcutGUI_Y
        WinShow, ahk_id %ShortcutScriptsHWND%
    return
}
Gui, ShortcutScripts:Destroy
CreateShortcutGUI_Forced:

        new _ShortcutGUI().createShortcutGUI()
return



MaximizeShortcutGUI:
    GetShortcutWindowPos(true)

    global ScriptsShortcut_minimized = 0
    IniWrite, %ScriptsShortcut_minimized%, %DefaultProfile%, settings, ScriptsShortcut_minimized


    WinHide, ahk_id %ShortcutScripts_MinimizedHWND%

    Goto, CreateShortcutGUI
return




GuiShortcutScriptsGuiEscape:
GuiShortcutScriptsGuiClose:
    Gui, ShortcutScripts:Destroy
return