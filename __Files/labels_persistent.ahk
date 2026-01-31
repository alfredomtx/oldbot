


LV_PersistentList:
    GuiControl, CavebotGUI:-g, LV_PersistentList
    switch A_GuiEvent {
        Case "Normal", case "DoubleClick", case "RightClick":
            PersistentGUI.LV_PersistentList()   
    }
    GuiControl, CavebotGUI:+gLV_PersistentList, LV_PersistentList
return

persistentSubmit:
    GuiControl, CavebotGUI:Enable, persistentSaveChangesButton
return

persistentAction:
    GuiControlGet, persistentID
    GuiControlGet, persistentAction
    PersistentHandler.setDefaultActionValues(persistentID, persistentAction)
    if (InStr(persistentObj[persistentID].action, "Action Script"))
        GuiControl, CavebotGUI:Enable, persistentEditActionButton
    else
        GuiControl, CavebotGUI:Disable, persistentEditActionButton

    goto, persistentSubmit


SavePersistentChanges:
    OldBotSettings.disableGuisLoading()
    GuiControl, CavebotGUI:Disable, persistentSaveChangesButton
    GuiControl, CavebotGUI:, persistentSaveChangesButton, % LANGUAGE = "PT-BR" ? "Salvando..." : "Saving..."
    try PersistentHandler.savePersistentOptions()
    catch e {
        Gosub, EnableSavePersistentButton
        OldBotSettings.enableGuisLoading()
        Msgbox, 48,% "Persistent options", % e.Message, 5
    return
}
SetTimer, EnableSavePersistentButton, -150
OldBotSettings.enableGuisLoading()
return


persistentEnabled:
    GuiControlGet, persistentID
    if (persistentID = "") {
        PersistentHandler.disablePersistent()
        msgbox, 64,,% "No persistent selected.", 2
    return
}
persistentObj[persistentID].enabled := !persistentObj[persistentID].enabled
try PersistentHandler.checkBeforeEnabling(persistentID)
catch e {
    PersistentHandler.disablePersistent()
    persistentObj[persistentID].enabled := 0
    MsgBox, 64, % A_ThisFunc, % e.Message, % e.What
    return
}
PersistentHandler.changePersistentEnabled(persistentID, save := true)
return

EnableSavePersistentButton:
    ; GuiControl, CavebotGUI:Enable, persistentSaveChangesButton
    GuiControl, CavebotGUI:, persistentSaveChangesButton, % txt("Salvar alterações", "Save changes")
    GuiControl, CavebotGUI:Disable, persistentSaveChangesButton
return

deletePersistent:
    PersistentHandler.deletePersistent()
return

addPersistent:
    ; try 
    PersistentHandler.addNewPersistent()
    ; catch e {
    ; Msgbox, 48,, % e.Message, 5
    ; }
return

editPersistentAction:
    PersistentHandler.editPersistentActionScript()
return

editPersistentUserValue:

    Gui, CavebotGUI:Default
    GuiControlGet, persistentID
    if (persistentID = "") {
        Msgbox, 62,, % "No persistent selected", 2
    return
}
Gui, EditPersistentUserValueGUI:Destroy
Gui, EditPersistentUserValueGUI:+AlwaysOnTop -MinimizeBox



; for key, value in persistentObj[persistentID]["userValue"]
; {
;     if (A_Index > 10)   
;         Break
;     Gui, EditPersistentUserValueGUI:Add, Text, x10 y+5, % "key:"
;     Gui, EditPersistentUserValueGUI:Add, edit, x+3 yp-2 h18 w100 vuserKey%A_Index%, % key
;     Gui, EditPersistentUserValueGUI:Add, Text, x+10 yp+2, % "value:"
;     Gui, EditPersistentUserValueGUI:Add, edit, x+3 yp-2 h18 w150 vuserValue%A_Index%, % value
; }
; msgbox, % serialize(persistentObj[persistentID])

Loop, 10 {
    keyValue := "", valueValue := ""
    for key, value in persistentObj[persistentID]["userValue"][A_Index]
    {
        keyValue := key, valueValue := value
        break
    }
    Gui, EditPersistentUserValueGUI:Add, Text, x10 y+5 w40 right, % LANGUAGE = "PT-BR" ? "chave " A_Index: "key " A_Index ":"
    Gui, EditPersistentUserValueGUI:Add, edit, x+3 yp-2 h18 w100 vpersistentUserKey%A_Index%, % keyValue
    Gui, EditPersistentUserValueGUI:Add, Text, x+10 yp+2, % LANGUAGE = "PT-BR" ? "valor:" : "value:"
    Gui, EditPersistentUserValueGUI:Add, edit, x+3 yp-2 h18 w150 vpersistentUserValue%A_Index%, % valueValue
}


; Gui, EditPersistentUserValueGUI:Add, Button, x10 y+5 w150 h23 gsaveUserValue %Disabled%,% "Add new"
; Gui, EditPersistentUserValueGUI:Add, Text, x10 y+5, % "Action Script"
; Gui, EditPersistentUserValueGUI:Add, edit, x+3 yp-2 h18 w100 vpersistentActionScript,


Gui, EditPersistentUserValueGUI:Add, Button, x10 y+15 w150 h23 gsubmitPersistentUserValues 0x1, % LANGUAGE = "PT-BR" ? "Salvar User Values" : "Save User Values"
Gui, EditPersistentUserValueGUI:Font, cGray
; Gui, EditPersistentUserValueGUI:Add, Text, x10 y+10 w310, % (LANGUAGE = "PT-BR" ? "O parâmetro ""clientID"" é opcional e pode ser usado para enviar key press OU clique para outros clientes, permitindo controlar multi clients(MC) sem abrir outra instância do bot.`nClient ID é a palavra que inicia com ""0x..."" na lista em Select Client. " : "The ""clientID"" param is optional and can be used to send key press OR click to other clients, allowing to control multi clients(MC) without opening another instance of the bot.`nClient ID is the string that starts with ""0x..."" in the Select Client list.")
Gui, EditPersistentUserValueGUI:Add, Text, x10 y+10 w310, % (LANGUAGE = "PT-BR" ? "Para usar a Persistent ""Go to label if itemcount"", veja a documentação da action ""setsetting""." : "To use the Persistent ""Go to label if itemcount"", check the documentation of the ""setsetting"" action.")
Gui, EditPersistentUserValueGUI:Show,, % "Edit User Value (" persistentID ")"

; GuiControl, EditPersistentUserValueGUI:, persistentActionScript, % persistentObj[persistentID]["userValue"].actionScript
return
EditPersistentUserValueGUIGuiEscape:
EditPersistentUserValueGUIGuiClose:
    Gui, EditPersistentUserValueGUI:Destroy
return

submitPersistentUserValues:
    if (persistentID = "") {
        Msgbox, 62,, % "No persistent selected", 2
    return
}

OldBotSettings.disableGuisLoading()

try PersistentHandler.savePersistentUserValue()
catch e {
    OldBotSettings.enableGuisLoading()
    Msgbox, 48, % e.What, % e.Message, 4
    Gui, EditPersistentUserValueGUI:Show
    ; Goto, editPersistentUserValue
    return
}
Gui, EditPersistentUserValueGUI:Destroy
OldBotSettings.enableGuisLoading()


return

openPersistentScreenshotsFolder:
    dir := PersistentHandler.persistentScreenshotFolder
    try Run, % dir
    catch e {
        Msgbox, 48, % A_ThisLabel, % "Failed to open folder directory:`n" dir, 4
    }
return



persistentsToggleAll:
    if (toggleAllPersistentsStatus = "")
        toggleAllPersistentsStatus := 0
    GuiControl, CavebotGUI:, toggleAllPersistents, % !toggleAllPersistentsStatus
    goto, toggleAllPersistents
return

toggleAllPersistents:
    if (loadingGuisSelectedFunctions != true)
        OldBotSettings.disableGuisLoading()

    if (toggleAllPersistentStatus = "")
        toggleAllPersistentStatus := 0
    global toggleAllPersistentStatus := !toggleAllPersistentStatus

    if (toggleAllPersistentStatus = 1) {
        try TibiaClient.checkClientSelected()
        catch e {
            OldBotSettings.enableGuisLoading()
            Msgbox, 64,, % e.Message, 2
        return
    }
}

for key, hotkey in persistentObj
    persistentObj[key].enabled := toggleAllPersistentStatus

checkbox_setvalue("persistentsToggleAll", toggleAllPersistentStatus)
PersistentGUI.loadPersistentListLV()
PersistentHandler.savePersistent()
if (toggleAllPersistentStatus = 1) {
    PersistentHandler.runPersistentExe()
} else {
    ProcessExistClose(persistentExeName, "persistentExeName")
}

if (loadingGuisSelectedFunctions != true)
    OldBotSettings.enableGuisLoading()
return


tutorialButtonPersistent:
    openURL(LinksHandler.Persistent.tutorial)
return