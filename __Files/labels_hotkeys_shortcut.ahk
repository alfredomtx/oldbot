




readVisibleShortcuts:
    for key, function in HotkeysFunctionsGUI.functionsList
    {   
        IniRead, %function%ShortcutCheckbox, %DefaultProfile%, hotkeys, %function%ShortcutCheckbox, 1
        ; msgbox, % function " = " %function%Hotkey
    }
return

readHotkeys:
    functionHotkeys := {}
    for key, function in HotkeysFunctionsGUI.functionsList
    {   
        IniRead, %function%Hotkey, %DefaultProfile%, hotkeys, %function%Hotkey, %A_Space%
        hotkey := %function%Hotkey
        functionHotkeys.Push({"function": function, "hotkey": hotkey})
        ; msgbox, % function " = " %function%Hotkey
    }
    ; msgbox, % serialize(functionHotkeys)
    ; gosub, disableAllHotkeys
return

enableAllHotkeys:   
    Gosub, readHotkeys
    for key, value in functionHotkeys
    {
        toggleHotkey(value.function, value.hotkey, "On")
    }

return

disableAllHotkeys:
    for key, value in functionHotkeys
    {
        toggleHotkey(value.function, value.hotkey, "Off")
    }
    ProcessExistClose(hotkeysExeName, "hotkeysExeName")
return

HotkeysFunctionsGUI:
    buttonPress("ShortcutScripts", A_GuiControl, "settings_button", press := true)
    HotkeysFunctionsGUI.createHotkeysFunctionsGUI()
    buttonPress("ShortcutScripts", A_GuiControl, "settings_button", press := false)
return
HotkeysFunctionsGUIGuiClose:
HotkeysFunctionsGUIGuiEscape:
    buttonPress("HotkeysFunctionsGUI", A_GuiControl, "close_button", press := true, sleep := 100)
    Gui, HotkeysFunctionsGUI:Destroy
return


functionCheckboxControl:
    Gui, HotkeysFunctionsGUI:Submit, NoHide
    function := A_GuiControl
    show := %A_GuiControl%
    IniWrite, % show, %DefaultProfile%, hotkeys, % function

    ShortcutGUI.createShortcutGUI()
return

functionHotkeyControl:
    function := A_GuiControl
    hotkey := %A_GuiControl%
    if (hotkey = "^")
        return
    if (hotkey = "!")
        return
    if (hotkey = "+")
        return
    if (StrLen(hotkey) < 2) && (hotkey != "") {
        Gui, HotkeysFunctionsGUI:Hide
        GuiControl, HotkeysFunctionsGUI:, % A_GuiControl, % ""
        Msgbox, 48,, % "The hotkey(" hotkey ") can't be a single letter or number.", 4
        Gui, HotkeysFunctionsGUI:Show
        return
    }
    ; msgbox, % function " = " hotkey
    IniWrite, % hotkey, %DefaultProfile%, hotkeys, % function

    function := StrReplace(function, "Hotkey", "")
    for key, value in functionHotkeys
    {
        ; msgbox, % value.function  "/ " function
        if (value.function = function) {
            ; disabling old hotkey
            toggleHotkey(value.function, value.hotkey, "Off")
            functionHotkeys[key].hotkey := hotkey
            ; creating new hotkey
            toggleHotkey(value.function, hotkey, "On")

        }
    }
return


toggleHotkey(function, htk, state)
{
    if (empty(htk)) {
        return
    }

    event := function "Hotkey"
    navigationHotkey := false
    switch (function) {
        case "navigationLeader":
            navigationHotkey := true
            event := _Navigation.CHECKBOX.toggle.bind(_Navigation.CHECKBOX)
        case "navigationFollower":
            navigationHotkey := true
            event := _Follower.CHECKBOX.toggle.bind(_Follower.CHECKBOX)
    }

    if (navigationHotkey) {
        if (state = "On") {
            _HotkeyRegister.register(htk, event, function)
            return
        } else {
            _HotkeyRegister.unregister(htk)
            return
        }
    }

    try {
        fn := _HotkeyRegister.clientOrWindowCondition.bind(_HotkeyRegister)
        Hotkey If, % fn
        Hotkey, % htk, % event, % state
    } catch e {
        _Logger.msgboxExceptionOnLocal(e, function, htk)
        ; msgbox, 16,, % "Function: " function "`nState: " state  "`nHotkey: " htk "`n" e.Message "`n" e.What
    }

    return
}


functionHotkey(functionName) {
    global
    value := !%functionName%
    %functionName% := value
    GuiControl, CavebotGUI:, %functionName%, %value%
    checkbox_setvalue(functionName "_2", value)
    Gosub, %functionName%
    return
}




#If (WinActive("ahk_id " TibiaClientID) OR WinActive("ahk_id " ShortcutScriptsHWND) OR WinActive(MAIN_GUI_TITLE))
; #If (WinActive("ahk_id " TibiaClientID))
/*
cavebot 
*/
selectedFunctionsHotkey:
cavebotTargetingHotkey:
cavebotEnabledHotkey:
targetingEnabledHotkey:
/*
healing
*/
lifeHealingEnabledHotkey:
manaHealingEnabledHotkey:
manaTrainEnabledHotkey:

/*
support
*/
autoEatFoodHotkey:
autoShootHotkey:
autoHasteHotkey:
autoUtamoVitaHotkey:
autoBuffSpellHotkey:
cureParalyzeHotkey:
curePoisonHotkey:
cureFireHotkey:
cureCurseHotkey:

/*
itemRefill
*/
quiverRefillEnabledHotkey:
distanceWeaponRefillEnabledHotkey:
ringRefillEnabledHotkey:
amuletRefillEnabledHotkey:
bootsRefillEnabledHotkey:
/*
reconnect
*/
autoReconnectHotkey:
/*
others
*/
fishingEnabledHotkey:
fullLightEnabledHotkey:
floorSpyEnabledHotkey:
magnifierEnabledHotkey:

    functionHotkey(StrReplace(A_ThisLabel, "Hotkey", ""))
    if (A_ThisLabel = "selectedFunctionsHotkey")
        checkbox_setvalue("SelectedFunctions", SelectedFunctions)
return
