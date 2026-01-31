
#If (WinActive(MAIN_GUI_TITLE))

+F9::
    WinSet, AlwaysOnTop, Toggle, ahk_id %OldBotHWND%
return

+F8:: Goto, toggleTransparentOldBot

; hotkeys do bot (Menu superior arquivo)
^#i:: Goto, AboutGUI

^!l::
    IniWrite, settings.ini, oldbot_profile.ini, profile, DefaultProfile
    Goto, Reload
return

^+l::
    selectedScript := "Default"
    goto, LoadSelectedScriptFromHotkey

    ; ^+s::Goto, selectTibiaClientLabel
    ; !s:: Goto, SioGUI
    ; !o:: Goto, CavebotGUI
    ; !g:: Goto, CavebotGUI
^l:: Goto, ScriptListGUI
^e:: new _ProfileGUI()


#If
