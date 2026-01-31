LAddWaypointGUI:
    CavebotGUI.addWaypointGUI()
return
AddWaypointGUIGuiEscape:
AddWaypointGUIGuiClose:
    Gui, AddWaypointGUI:Destroy
return

AddWaypoint_Walk:
    type := "Walk"
    GUIControl := "AddWaypoint_Walk"
    goto, AddWaypoint

AddWaypoint_Stand:
    type := "Stand"
    GUIControl := "AddWaypoint_Stand"
    goto, AddWaypoint

AddWaypoint_Ladder:
    if (OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection = true && CavebotScript.isCoordinate()) {
        type := "Ladder"
        GUIControl := "AddWaypoint_Ladder"
        goto, AddWaypoint
    }
    CavebotGUI.ladderWaypointGUI()
    waitingLadderWaypoint := true
    canceledLadderWaypoint := false
    timeout := true
    Loop, 100 {
        Sleep, 250
        if (waitingLadderWaypoint = false) {
            timeout := false
            break
        }
        if (canceledLadderWaypoint = true)
            return
    }
    if (timeout = true) {
        waitingLadderWaypoint := false
        Goto, ladderWaypointGUIGuiEscape
    }
    GUIControl := "AddWaypoint_Ladder"
    goto, AddWaypoint

ladderWaypointGUIGuiEscape:
ladderWaypointGUIGuiClose:
    canceledLadderWaypoint := true
    Gui, ladderWaypointGUI:Destroy
return

SubmitLadderWaypointType:
    Gui, ladderWaypointGUI:Submit, NoHide
    Gui, ladderWaypointGUI:Destroy
    waitingLadderWaypoint := false
    type := "Ladder " ladderWaypointType
return

AddWaypoint_Stair:
    CavebotGUI.stairWaypointGUI()
    waitingStairWaypoint := true
    canceledStairWaypoint := false
    timeout := true
    Loop, 100 {
        Sleep, 250
        if (waitingStairWaypoint = false) {
            timeout := false
            break
        }
        if (canceledStairWaypoint = true)
            return
    }
    if (timeout = true) {
        waitingStairWaypoint := false
        Goto, stairWaypointGUIGuiEscape
    }
    GUIControl := "AddWaypoint_Stair"
    goto, AddWaypoint

stairWaypointGUIGuiEscape:
stairWaypointGUIGuiClose:
    canceledStairWaypoint := true
    Gui, stairWaypointGUI:Destroy
return

SubmitStairWaypointType:
    Gui, stairWaypointGUI:Submit, NoHide
    Gui, stairWaypointGUI:Destroy
    waitingStairWaypoint := false
    type := "Stair " stairWaypointType
return

AddWaypoint_UseTool:
        new _ToolWaypointGUI().open()
return

AddWaypointLabel:
    ;  AddWaypoint_
    fromHotkey := false
    GUIControl := A_GuiControl
    StringTrimLeft, type, GUIControl, 12
    if (type = "") {
        Msgbox, 16,, No waypoint type selected
        return
    }

    goto, AddWaypoint

AddWaypoint:
    if (tab = "") {
        Msgbox, 48, Add waypoint, No tab selected.
        return
    }

    try TibiaClient.checkClientSelected()
    catch e {
        Msgbox, 48, Add waypoint, % e.Message, 10
        return
    }

    switch scriptSettingsObj.cavebotFunctioningMode {

        case "markers":
            actionAddWaypointMarker := type
            if (type = "action") {
                markerNumber := ""
                Goto, AddWaypointMarkerLabel
            }
            CavebotGUI.selectMarkerGUI()
            return

        default:
            Gui, CavebotGUI:Default
            if (GUIControl != "AddWaypoint_UseTool") {
                CavebotGUI.beforeAddWaypointGuiControls(GUIControl)
                GuiControl, AddWaypointGUI:Disable, %GUIControl%
                GuiControl, AddWaypointGUI:Disable, AutoShowWaypoints
                buttonName := ""
                GuiControlGet, buttonName,, %GUIControl%
                if (buttonName != "")
                    GuiControl, AddWaypointGUI:, %GUIControl%, % (type = "Action") ? "Adding..." : "Adding, please wait..."
                ; msgbox, % GUIControl " / " type " / " buttonName
            }

            showTimerOnBeforeAdd := false
            if (showWaypointsTimer = true) {
                showTimerOnBeforeAdd := true
                CavebotHandler.stopShowWaypointTimer(destroyGUI := true, true)
            }
            CavebotGUI.selectedSqm := GetSelectedSQM()

            OldBotSettings.disableGuisLoading()
            try {
                WaypointHandler.addWaypoint(type, CavebotGUI.selectedSqm, RangeWaypointWidth, RangeWaypointHeight, tab, fromHotkey, debug := false)
            } catch, e {
                CavebotGUI.addWaypointException(e)
                CavebotGUI.afterAddWaypointGuiControls(GUIControl)
                OldBotSettings.enableGuisLoading()
                return
            }
    }

    CavebotGUI.afterAddWaypointGuiControls(GUIControl)
    OldBotSettings.enableGuisLoading()
return

SelectMarkerAddWaypoint:
    markerNumber := StrReplace(A_GuiControl, "minimapMarker", "")
    goto, AddWaypointMarkerLabel

AddWaypointMarkerLabel:
    OldBotSettings.disableGuisLoading()

    SQM := GetSelectedSQM()
    try {
        ; msgbox, % actionAddWaypointMarker "," SQM "," markerNumber
        WaypointHandler.addWaypointMarker(actionAddWaypointMarker, SQM, markerNumber)
    } catch, e {
        OldBotSettings.enableGuisLoading()
        CavebotGUI.addWaypointException(e)
        CavebotGUI.afterAddWaypointGuiControls(GUIControl)
        return
    }

    CavebotGUI.afterAddWaypointGuiControls(GUIControl)
    OldBotSettings.enableGuisLoading()
return

AddWaypointImageLabel:
    OldBotSettings.disableGuisLoading()
    SQM := GetSelectedSQM()

    ; msgbox, % actionAddWaypointMarker "," SQM "," imageAddWaypointMarker
    try {
        WaypointHandler.AddImageWaypointMinimapMarker(actionAddWaypointMarker, SQM, imageAddWaypointMarker)
    } catch, e {

        Gui, selectMarkerGUI:Hide
        CavebotGUI.addWaypointException(e)
        Gui, selectMarkerGUI:Show
        CavebotGUI.afterAddWaypointGuiControls(GUIControl)
        OldBotSettings.enableGuisLoading()
        return
    }
    Gui, selectMarkerGUI:Destroy
    CavebotGUI.afterAddWaypointGuiControls(GUIControl)
    OldBotSettings.enableGuisLoading()
return


MoveToTabGUI:
    CavebotScript.createScriptTabsList()
    if (ScriptTabsList.MaxIndex() <= 1) {
        msgbox, 64,, % LANGUAGE = "PT-BR" ? "Não há abas adicionais no script." : "There are no additional tabs in the script.", 3
        return
    }
    try selectedWaypoints := _ListviewHandler.getSelectedRowsLV(A_DefaultListview, 1)
    catch e {
        msgbox, 64,, % "Select at least one waypoint."
        return
    }

    options := ""
    rows := 1
    for key, value in ScriptTabsList
    {
        if (value = tab)
            continue
        options .= value "|"
        rows++
    }
    if (rows > 15)
        rows := 15

    Gui, MoveToTabGUI:Destroy
    Gui, MoveToTabGUI:+AlwaysOnTop -MinimizeBox
    Gui, MoveToTabGUI:Add, Text, x10 y+5, % LANGUAGE = "PT-BR" ? "Selecione a aba:" : "Select the tab:"
    Gui, MoveToTabGUI:Add, Listbox, vMoveToTabName x10 y+3 w200 r%rows%, %options%
    Gui, MoveToTabGUI:Add, Button, x10 y+5 w200 0x1 gMoveToTab, % "Move to tab"

    Gui, MoveToTabGUI:Show,, % LANGUAGE = "PT-BR" ? "Move para a aba" : "Move to the tab"
return
MoveToTabGUIGuiEscape:
MoveToTabGUIGuiClose:
    Gui, MoveToTabGUI:Destroy
return

MoveToTab:
    Gui, MoveToTabGUI:Submit, NoHide
    Gui, MoveToTabGUI:Destroy
    if (MoveToTabName = "") {
        msgbox, 48,, % "Select the tab to move the waypoints to."
        Goto, MoveToTabGUI
        return
    }

    WaypointHandler.moveWaypointsToTab(tab, MoveToTabName)
return



editWaypointAtributeGUIGuiClose:
editWaypointAtributeGUIGuiEscape:
    Gui, editWaypointAtributeGUI:Destroy
return

editWaypointAtributeMarkerLabel:
    waypointAtributeName := "marker"
    goto, editWaypointAtributeLabel

editWaypointAtributeImageLabel:
    waypointAtributeName := "image"
    goto, editWaypointAtributeLabel


editWaypointAtributeLabel:
    Gui, editWaypointAtributeGUI:Submit, NoHide

    continueEditingMsg := txt("Continuar editando waypoint?", "continue editing waypoint?")


    switch waypointAtributeName {
        case "Label":
            try WaypointHandler.editAtribute(waypointAtributeName, editWaypointLabel, waypointAtributeNumber, waypointAtributeTab)
            catch e {
                Gui, editWaypointAtributeGUI:Hide
                Msgbox, 52,, % e.Message "`n`n" continueEditingMsg
                IfMsgBox, No
                    Gui, editWaypointAtributeGUI:Destroy
                else
                    Gui, editWaypointAtributeGUI:Show
                return
            }
        case "Range":
            try WaypointHandler.editAtribute(waypointAtributeName, editWaypointRange, waypointAtributeNumber, waypointAtributeTab)
            catch e {
                Gui, editWaypointAtributeGUI:Hide
                Msgbox, 52,, % e.Message "`n`n" continueEditingMsg
                IfMsgBox, No
                    Gui, editWaypointAtributeGUI:Destroy
                else
                    Gui, editWaypointAtributeGUI:Show
                return
            }
        case "Coordinates":
            coordinates := "x:" editWaypointX ", y:" editWaypointY ", z:" editWaypointZ
            try WaypointHandler.editAtribute(waypointAtributeName, coordinates, waypointAtributeNumber, waypointAtributeTab)
            catch e {
                Gui, editWaypointAtributeGUI:Hide
                Msgbox, 52,, % e.Message "`n`n" continueEditingMsg
                IfMsgBox, No
                    Gui, editWaypointAtributeGUI:Destroy
                else
                    Gui, editWaypointAtributeGUI:Show
                return
            }
        case "Type":
            try WaypointHandler.editAtribute(waypointAtributeName, editWaypointType, waypointAtributeNumber, waypointAtributeTab)
            catch e {
                Gui, editWaypointAtributeGUI:Hide
                Msgbox, 52,, % e.Message "`n`n" continueEditingMsg
                IfMsgBox, No
                    Gui, editWaypointAtributeGUI:Destroy
                else
                    Gui, editWaypointAtributeGUI:Show
                return
            }
        case "Marker":
            markerNumber := StrReplace(A_GuiControl, "minimapMarker", "")
            try WaypointHandler.editAtribute(waypointAtributeName, markerNumber, waypointAtributeNumber, waypointAtributeTab)
            catch e {
                Gui, editWaypointAtributeGUI:Hide
                Msgbox, 52,, % e.Message "`n`n" continueEditingMsg
                IfMsgBox, No
                    Gui, editWaypointAtributeGUI:Destroy
                else
                    Gui, editWaypointAtributeGUI:Show
                return
            }
            Gui, selectMarkerGUI:Destroy
        case "Image":
            try WaypointHandler.editAtribute(waypointAtributeName, imageAddWaypointMarker, waypointAtributeNumber, waypointAtributeTab)
            catch e {
                Gui, editWaypointAtributeGUI:Hide
                Msgbox, 52,, % e.Message "`n`n" continueEditingMsg
                IfMsgBox, No
                    Gui, editWaypointAtributeGUI:Destroy
                else
                    Gui, editWaypointAtributeGUI:Show
                return
            }
            Gui, selectMarkerGUI:Destroy
            ; CavebotGUI.selectMarkerGUI(waypointAtributeNumber)

    }
    Gui, editWaypointAtributeGUI:Destroy
    CavebotGUI.loadLV()
    selectRowLV(waypointAtributeNumber)
    ; msgbox, % waypointAtributeNumber " = " startWaypoint " / " tab " = " startTab
    ; if (waypointAtributeNumber = startWaypoint && tab = startTab)
    ;     CavebotGUI.selectStartWaypoint(waypointAtributeNumber)
    ; else
    CavebotGUI.selectStartWaypoint(startWaypoint, startTab)
return







EditWaypointType:
    CavebotHandler.editWaypointAtributeGUI(selectedWaypointEdit, "Type")
return
EditWaypointLabel:
    CavebotHandler.editWaypointAtributeGUI(selectedWaypointEdit, "Label")
return
EditWaypointCoordinates:
    CavebotHandler.editWaypointAtributeGUI(selectedWaypointEdit, "Coordinates")
return
EditWaypointRange:
    switch WaypointHandler.getAtribute("type", selectedWaypointEdit) {
        case "Walk", case "Action": CavebotHandler.editWaypointAtributeGUI(selectedWaypointEdit, "Range")
        default:
            Msgbox, 64,, % txt("Apenas waypoints do tipo ""Walk"" e ""Action"" podem ter ranges diferentes de 1.", "Only ""Walk"" and ""Action"" waypoints can have ranges different than 1.")
    }
return
EditWaypointAction:
    if (WaypointHandler.getAtribute("type", selectedWaypointEdit) = "Action")
        Goto, ActionScriptGUI
return
