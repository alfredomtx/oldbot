

LV_HotkeysList:
    GuiControl, CavebotGUI:-g, LV_HotkeysList
    switch A_GuiEvent {
        Case "Normal", case "DoubleClick", case "RightClick":
            HotkeysGUI.LV_HotkeysList()   
    }
    GuiControl, CavebotGUI:+gLV_HotkeysList, LV_HotkeysList
return

hotkeySubmit:
    GuiControl, CavebotGUI:Enable, hotkeySaveChangesButton
return

hotkeyAction:
    GuiControlGet, hotkeyAction
    GuiControlGet, hotkeyID
    HotkeysHandler.setDefaultHotkeyActionValues(hotkeyID, hotkeyAction)
    if (InStr(hotkeysObj[hotkeyID].action, "Action "))
        GuiControl, CavebotGUI:Enable, hotkeyEditActionButton
    else
        GuiControl, CavebotGUI:Disable, hotkeyEditActionButton
    goto, hotkeySubmit
return


SaveHotkeyChanges:
    GuiControl, CavebotGUI:Disable, hotkeySaveChangesButton
    GuiControl, CavebotGUI:, hotkeySaveChangesButton, % LANGUAGE = "PT-BR" ? "Salvando..." : "Saving..."
    try HotkeysHandler.saveHotkeysOptions()
    catch e {
        Gosub, EnableSaveHotkeysButton
        Msgbox, 48,% "Hotkeys options", % e.Message, 5
    return
}
SetTimer, EnableSaveHotkeysButton, -150
return

HotkeysToggleAll:
    if (toggleAllHotkeysStatus = "")
        toggleAllHotkeysStatus := 0
    GuiControl, CavebotGUI:, toggleAllHotkeys, % !toggleAllHotkeysStatus
    goto, toggleAllHotkeys
return


toggleAllHotkeysEnabled:
    if (hotkeysObj.Count() < 1)
        return
    OldBotSettings.disableGuisLoading()
    try HotkeysHandler.checkBeforeEnablingHotkeys(hotkeyID)
    catch e {
        checkbox_setvalue("HotkeysToggleAll", toggleAllHotkeysStatus := 0)
        OldBotSettings.enableGuisLoading()
        MsgBox, 64,, % e.Message, % e.What
    return
}

changeButton("CavebotGUI", "toggleAllHotkeysEnabled", "Disable", LANGUAGE = "PT-BR" ? "Ativando..." : "Enabling...")
enableButtonTimer := Func("changeButton").bind("CavebotGUI", "toggleAllHotkeysEnabled", "Enable", (LANGUAGE = "PT-BR" ? "Ativar todas" : "Enable all"))
SetTimer, % enableButtonTimer, Delete
SetTimer, % enableButtonTimer, -1500


for key, hotkey in hotkeysObj
    hotkeysObj[key].enabled := 1

HotkeysHandler.enableHotkey()
checkbox_setvalue("HotkeysToggleAll", toggleAllHotkeysStatus := 1)
HotkeysGUI.loadHotkeysListLV()
HotkeysHandler.saveHotkeys()
HotkeysHandler.runHotkeysExe()
OldBotSettings.enableGuisLoading()

return

toggleAllHotkeysDisabled:
    OldBotSettings.disableGuisLoading()
    changeButton("CavebotGUI", "toggleAllHotkeysDisabled", "Disable", LANGUAGE = "PT-BR" ? "Desativando..." : "Disabling...")
    enableButtonTimer := Func("changeButton").bind("CavebotGUI", "toggleAllHotkeysDisabled", "Enable", (LANGUAGE = "PT-BR" ? "Desativar todas" : "Disable all") )

    SetTimer, % enableButtonTimer, Delete
    SetTimer, % enableButtonTimer, -500

    for key, hotkey in hotkeysObj
        hotkeysObj[key].enabled := 0

    HotkeysHandler.disableHotkey()
    checkbox_setvalue("HotkeysToggleAll", toggleAllHotkeysStatus := 0)
    HotkeysGUI.loadHotkeysListLV()
    HotkeysHandler.saveHotkeys()
    ProcessExistClose(hotkeysExeName, "hotkeysExeName")
    OldBotSettings.enableGuisLoading()
return

toggleAllHotkeys:
    OldBotSettings.disableGuisLoading()
    if (toggleAllHotkeysStatus = "")
        toggleAllHotkeysStatus := 0
    global toggleAllHotkeysStatus := !toggleAllHotkeysStatus

    if (toggleAllHotkeysStatus = 1) {

        try HotkeysHandler.checkBeforeEnablingHotkeys(hotkeyID)
        catch e {
            checkbox_setvalue("HotkeysToggleAll", toggleAllHotkeysStatus := 0)
            OldBotSettings.enableGuisLoading()
            MsgBox, 64,, % e.Message, % e.What
        return
    }

    try TibiaClient.checkClientSelected()
    catch e {
        OldBotSettings.enableGuisLoading()
        Msgbox, 64,, % e.Message, 2
        return
    }
}

for key, hotkey in hotkeysObj
    hotkeysObj[key].enabled := toggleAllHotkeysStatus

checkbox_setvalue("HotkeysToggleAll", toggleAllHotkeysStatus)
HotkeysGUI.loadHotkeysListLV()
HotkeysHandler.saveHotkeys()
if (toggleAllHotkeysStatus = 1) {
    HotkeysHandler.runHotkeysExe()
} else {
    ProcessExistClose(hotkeysExeName, "hotkeysExeName")
}
OldBotSettings.enableGuisLoading()
return

hotkeyEnabled:
    GuiControlGet, hotkeyID
    if (hotkeyID = "") {
        HotkeysHandler.disableHotkey()
        msgbox, 64,,% "No hotkey selected.", 2
    return
}
hotkeysObj[hotkeyID].enabled := !hotkeysObj[hotkeyID].enabled
try HotkeysHandler.checkBeforeEnablingHotkeys(hotkeyID)
catch e {
    HotkeysHandler.disableHotkey()
    hotkeysObj[hotkeyID].enabled := 0
    MsgBox, 64, % A_ThisFunc, % e.Message, % e.What
    return
}
HotkeysHandler.changeHotkeyEnabled(hotkeyID, save := true)
return

EnableSaveHotkeysButton:
    ; GuiControl, CavebotGUI:Enable, hotkeySaveChangesButton
    GuiControl, CavebotGUI:, hotkeySaveChangesButton, % LANGUAGE = "PT-BR" ? "Salvar alterações" : "Save changes"
    GuiControl, CavebotGUI:Disable, hotkeySaveChangesButton
return

deleteHotkey:
    HotkeysHandler.deleteHotkey()
return

addHotkey:
    HotkeysHandler.addNewHotkey()
return

editHotkeyAction:
    HotkeysHandler.editHotkeyActionScript()
return

editHotkeyUserValue:
    Gui, CavebotGUI:Default
    GuiControlGet, hotkeyID
    if (hotkeyID = "") {
        Msgbox, 62,, % "No hotkey selected", 2
    return
}
Gui, EditHotkeysUserValueGUI:Destroy
Gui, EditHotkeysUserValueGUI:+AlwaysOnTop -MinimizeBox



; for key, value in hotkeysObj[hotkeyID]["userValue"]
; {
;     if (A_Index > 10)   
;         Break
;     Gui, EditHotkeysUserValueGUI:Add, Text, x10 y+5, % "key:"
;     Gui, EditHotkeysUserValueGUI:Add, edit, x+3 yp-2 h18 w100 vuserKey%A_Index%, % key
;     Gui, EditHotkeysUserValueGUI:Add, Text, x+10 yp+2, % "value:"
;     Gui, EditHotkeysUserValueGUI:Add, edit, x+3 yp-2 h18 w150 vuserValue%A_Index%, % value
; }
; msgbox, % serialize(hotkeysObj[hotkeyID])

Loop, 10 {
    keyValue := "", valueValue := ""
    for key, value in hotkeysObj[hotkeyID]["userValue"][A_Index]
    {
        keyValue := key, valueValue := value
        break
    }
    Gui, EditHotkeysUserValueGUI:Add, Text, x10 y+5, % LANGUAGE = "PT-BR" ? "chave:" : "key:"
    Gui, EditHotkeysUserValueGUI:Add, edit, x+3 yp-2 h18 w150 vhotkeyUserKey%A_Index%, % keyValue
    Gui, EditHotkeysUserValueGUI:Add, Text, x+10 yp+2, % LANGUAGE = "PT-BR" ? "valor:" : "value:"
    Gui, EditHotkeysUserValueGUI:Add, edit, x+3 yp-2 h18 w150 vhotkeyUserValue%A_Index%, % valueValue
}


; Gui, EditHotkeysUserValueGUI:Add, Button, x10 y+5 w150 h23 gsaveUserValue %Disabled%,% "Add new"

Gui, EditHotkeysUserValueGUI:Add, Button, x10 y+15 w150 h23 gsubmitHotkeysUserValues 0x1, % LANGUAGE = "PT-BR" ? "Salvar User Values" : "Save User Values"
; Gui, EditHotkeysUserValueGUI:Font, cGray
; Gui, EditHotkeysUserValueGUI:Add, Text, x10 y+10 w310, % "The ""clientID"" param is optional and can be used to send key press OR click to other clients, allowing to control multi clients(MC).`nClient ID is the string that starts with ""0x..."" in the Select Client list."
Gui, EditHotkeysUserValueGUI:Show,, % "Edit User Value (" hotkeyID ")"
return
EditHotkeysUserValueGUIGuiEscape:
EditHotkeysUserValueGUIGuiClose:
    Gui, EditHotkeysUserValueGUI:Destroy
return

submitHotkeysUserValues:
    ; Gui, CavebotGUI:Default
    ; Gui, CavebotGUI:Submit, NoHide

    ; GuiControlGet, hotkeyID
    if (hotkeyID = "") {
        Msgbox, 62,, % "No hotkey selected", 2
    return
}

try HotkeysHandler.saveHotkeysUserValue()
catch e {
    Msgbox, 48, % e.What, % e.Message, 4
    Goto, editHotkeyUserValue
    return
}

return

openHotkeysScreenshotsFolder:
    dir := HotkeysHandler.hotkeyScreenshotFolder
    try Run, % dir
    catch e {
        Msgbox, 48, % A_ThisLabel, % "Failed to open folder directory:`n" dir, 4
    }
return

tutorialButtonHotkeys:
    openURL(LinksHandler.Hotkeys.tutorial)
return