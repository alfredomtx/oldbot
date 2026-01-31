
selectedFunctionsOption:
    try {
        Gui, %ID_VariaveisGUI%:Default
        Gui, %ID_VariaveisGUI%:Submit, NoHide
    } catch {
    }

    control := StrReplace(A_GuiControl, "selectedFunctions_", "")
    controlValue := ""
    try controlValue := %A_GuiControl%
    catch e {
        if (!A_IsCompiled)
            msgbox, 48,, % e.Message "`n" e.What
        controlValue := ""
    }

    _GuiHandler.submitCheckbox("selectedFunctions", control, controlValue)

return

CavebotTargeting:
    if (CavebotTargeting = 0)
        value = 0
    else if (CavebotTargeting = 1)
        value = 1
    IniWrite, %value%, %DefaultProfile%, cavebot_settings, CavebotEnabled
    IniWrite, %value%, %DefaultProfile%, cavebot_settings, CavebotEnabled_2
    IniWrite, %value%, %DefaultProfile%, cavebot_settings, TargetingEnabled
    IniWrite, %value%, %DefaultProfile%, cavebot_settings, TargetingEnabled_2
    GuiControl, CavebotGUI:, CavebotEnabled, %value%
    GuiControl, CavebotGUI:, TargetingEnabled, %value%
    checkbox_setvalue("CavebotEnabled_2", value)
    checkbox_setvalue("TargetingEnabled_2", value)
    CavebotEnabled := value
    TargetingEnabled := value
    Gosub, CavebotEnabled
    OldBotSettings.enableGuisLoading()
    Gui, CavebotGUI:-Disabled ; force enable
return


forceStartWaypoint:
    Gui, %ID_VariaveisGUI%:Default
    GuiControlGet, forceStartWaypoint
    if (forceStartWaypoint = 1) {
        GuiControl, Enable, startTabSet
        GuiControl, Enable, startWaypointSet
    } else {
        GuiControl, Disable, startTabSet
        GuiControl, Disable, startWaypointSet

    }
    CavebotScript.setForceStartWaypoint(forceStartWaypoint)

return

startWaypointSet:
    Gui, %ID_VariaveisGUI%:Default
    GuiControlGet, startWaypointSet

    CavebotScript.setStartWaypointSet(startWaypointSet)
return
startTabSet:
    Gui, %ID_VariaveisGUI%:Default
    GuiControlGet, startTabSet
    GuiControlGet, startWaypointSet
    try CavebotScript.validateStartWaypointSet(startWaypointSet, startTabSet)
    catch e {
        GuiControl,, startWaypointSet, % ""
        msgbox, 48,, % e.Message, 4
    }
    CavebotScript.setStartTabSet(startTabSet)
return

DeleteTooltip:
    Tooltip
return



RemoveStartWaypoint:
    ; msgbox, % startTab
    CavebotScript.removeStartWaypoint()
return

SetStartWaypoint:
    selectedWaypoint := _ListviewHandler.getSelectedItemOnLV("LV_Waypoints_" tab, 1)
    if (selectedWaypoint = "" OR selectedWaypoint = "WP") {
        ; Msgbox, 64,, % "Select a waypoint on the list."
        return
    }
    CavebotGUI.selectStartWaypoint(selectedWaypoint, tab)
    if (forceStartWaypoint = 1) {

        TrayTipMessage("Force start waypoint", (LANGUAGE = "PT-BR" ? """Force start waypoint"" está selecionado na aba Script Settings." : """Force start waypoint"" is checked in Script Settings tab."), timeout := 4)
        ; TrayTipHotkey(message) {

    }

    if (new _CavebotIniSettings().get("setWaypointChangesOnCavebot")) {
        _CavebotExeMessage.goToLabel(tab "/" selectedWaypoint)
    }

return

saveScriptJSON:
    GuiControlGet, ScriptVariablesJSON

    try
        newScriptVariablesObj := JsonLib.Load(ScriptVariablesJSON)
    catch, e {
        Run, https://jsonlint.com/
        Sleep, 1000
        try {
            ClipBoard := ScriptVariablesJSON
            Send, ^v
        }
        catch {
        }
        msgbox,48,, % "Syntax error on JSON.`nCopy its contents into JSONLint to check.`n`nError details:`n" e.Message "`n`n" e.What "`n`n" e.Extra
        return
    }

    ; msgbox, % serialize(newScriptVariablesObj)
    try
        ScriptJsonValidation.validateUserOptions(newScriptVariablesObj, tempJsonFileDir)
    catch e {
        Msgbox, 48, Error saving JSON, % e.Message
        ; Msgbox, 48, Error saving JSON, % e.Message "`n" e.What "`n" e.Extra
        return
    }
    ; msgbox, % serialize(newScriptVariablesObj)
    _ScriptJson.saveScriptVariables(newScriptVariablesObj)

    Gosub, ScriptSettingsGUI
    Goto, ScriptVariablesJsonGUI
return

RangeWaypointWidth:
    GuiControlGet, RangeWaypointWidth
    GetKeyState, CtrlPressed, Ctrl, D
    if (CtrlPressed = "D")
        GuiControl, AddWaypointGUI:, RangeWaypointHeight, % RangeWaypointWidth
return

RangeWaypointHeight:
    GuiControlGet, RangeWaypointHeight
    GetKeyState, CtrlPressed, Ctrl, D
    if (CtrlPressed = "D")
        GuiControl, AddWaypointGUI:, RangeWaypointWidth, % RangeWaypointHeight
return

currentFloorLevel:
    GuiControlGet, currentFloorLevel
    IniWrite, % currentFloorLevel, %DefaultProfile%, cavebot_settings, currentFloorLevel
return

ScriptSettingsGUI:
    CavebotGUI.createScriptSettingsGUI()
return

ScriptVariablesJsonGUI:
    try ScriptRestriction.checkScriptRestriction()
    catch
    return
Gui, ScriptVariablesJsonGUI:Destroy
; Gui, ScriptVariablesJsonGUI:-MinimizeBox
tempJsonFileDir := A_Temp "\" currentScript ".json"
FileDelete, %tempJsonFileDir%
scriptVariablesTempFile := new JSONFile(tempJsonFileDir)
scriptVariablesTempFile.Fill(scriptVariablesObj)
scriptVariablesTempFile.Save()

ScriptVariablesJSON := scriptVariablesTempFile.JSON(true)
scriptVariablesTempFile := ""
ScriptVariablesJSONOld := ScriptVariablesJSON

Gui, ScriptVariablesJsonGUI:Add, Edit, x25 y5 h485 w750 vScriptVariablesJSON -HScroll

Gui, ScriptVariablesJsonGUI:Add, Button, x24 +5 w120 h25 gsaveScriptJSON hwndsaveScriptJSON_Button, % LANGUAGE = "PT-BR" ? "Salvar JSON" : "Save JSON"
Gui, ScriptVariablesJsonGUI:Add, Button, x+8 yp+0 h25 gOpenJsonLint, % "Open on JSONLint"


; new _Button().title("Tutorial criar script 100% AFK", "Tutorial create 100% AFK script")
; .x("+8").y("p+0").w(170).h(25)
; .event(Func("openUrl").bind("https://youtu.be/XboGV6gUFJo"))
; .gui("ScriptVariablesJsonGUI")
; .icon(_Icon.get(_Icon.YOUTUBE), "a0 l2 b0 s14")
; .add()


Gui, ScriptVariablesJsonGUI:Font, s16
Gui, ScriptVariablesJsonGUI:Add, Button, xm+565 yp+0 w200 h25 gOldBotDocs_ScriptSetup hwndhOldBotDocs, % "Script Setup Docs"
Gui, ScriptVariablesJsonGUI:Font, s8
Gui, ScriptVariablesJsonGUI:Show,,% "Script setup JSON - " currentScript
if (ScriptVariablesJSON = "{}") {

    ScriptVariablesJSON =
(
[
    {
        "children": [
            {
                "text": "Empty script setup.",
                "type": "text"
            }
        ],
        "name": "noSetup",
        "text": "No setup"
    }
]
)

}
GuiControl, ScriptVariablesJsonGUI:, ScriptVariablesJSON, % ScriptVariablesJSON
return
ScriptVariablesJsonGUIGuiClose:
    Gui, ScriptVariablesJsonGUI:Destroy
return

SubmitScriptVariableControl:
    if (creatingGUI = true)
        return

    if (WinExist("ahk_id " ID_VariaveisGUI)) {
        Gui, %ID_VariaveisGUI%:Default
        Gui, Submit, NoHide
    }
    if (A_GuiControl = "") {
        Msgbox, 48,, % "No control selected."
        return
    }

    OldBotSettings.disableGuisLoading()
    ; Gui, %ID_VariaveisGUI%:+Disabled

    try
        _ScriptJson.submitControl(A_GuiControl, %A_GuiControl%)
    catch e {
        OldBotSettings.enableGuisLoading()
        Gui, %ID_VariaveisGUI%:-Disabled
        Msgbox, 48,, % e.Message
        return
    }
    Gui, %ID_VariaveisGUI%:-Disabled
    OldBotSettings.enableGuisLoading()

return

OpenJsonFormatter:
    CarregandoGUI("Opening and pasting content...")
    Clipboard := ScriptVariablesJSON
    try {
        Run, https://jsonformatter.curiousconcept.com/#
        Sleep, 2500
        Send, ^v
        Gui, Carregando:Destroy
    }
    catch {
        Gui, Carregando:Destroy
        Msgbox, 48,, Error opening https://jsonformatter.curiousconcept.com/#
    }
return

OpenJsonLint:
    CarregandoGUI("Opening and pasting content...")
    Clipboard := ScriptVariablesJSON
    try {
        Run, https://jsonlint.com/
        Sleep, 2500
        Send, ^v
        Gui, Carregando:Destroy
    }
    catch {
        Gui, Carregando:Destroy
        Msgbox, 48,, Error opening https://jsonlint.com/
    }
return

HotkeysWaypoints:
    Gui, HotkeysWaypoints:Destroy
    Gui, HotkeysWaypoints:+AlwaysOnTop +Owner -MinimizeBox
    Gui, HotkeysWaypoints:Font, s10

    hotkeys := {}
    hotkeys.Push({hotkey: "Ctrl + Shift + Home", desc: "Add ""Walk"" waypoint"})
    hotkeys.Push({hotkey: "Ctrl + Shift + End", desc: "Add ""Stand"" waypoint"})
    hotkeys.Push({hotkey: "Ctrl + Shift + S", desc: "Show selected waypoint(s)"})
    hotkeys.Push("<br>")
    hotkeys.Push({hotkey: "Alt + D", desc: "Duplicate selected waypoint"})
    hotkeys.Push({hotkey: "Alt + Del", desc: "Delete selected waypoint(s)"})
    hotkeys.Push({hotkey: "Shift + Alt + Del", desc: "Delete last waypoint"})
    hotkeys.Push("<br>")
    hotkeys.Push({hotkey: "Alt + Arrow Up", desc: "Move waypoint Up"})
    hotkeys.Push({hotkey: "Alt + Arrow Down", desc: "Move waypoint Down"})
    hotkeys.Push({hotkey: "Alt + Scroll Up", desc: "Move waypoint Up"})
    hotkeys.Push({hotkey: "Alt + Scroll Down", desc: "Move waypoint Down"})
    hotkeys.Push({hotkey: "Alt + Home", desc: "Move waypoint to first position"})
    hotkeys.Push({hotkey: "Alt + End", desc: "Move waypoint to last position"})
    hotkeys.Push("<br>")
    hotkeys.Push({hotkey: "Alt + 1", desc: "Set direction SW"})
    hotkeys.Push({hotkey: "Alt + 2", desc: "Set direction S"})
    hotkeys.Push({hotkey: "Alt + 3", desc: "Set direction SE"})
    hotkeys.Push({hotkey: "Alt + 4", desc: "Set direction W"})
    hotkeys.Push({hotkey: "Alt + 5", desc: "Set direction C"})
    hotkeys.Push({hotkey: "Alt + 6", desc: "Set direction E"})
    hotkeys.Push({hotkey: "Alt + 7", desc: "Set direction NW"})
    hotkeys.Push({hotkey: "Alt + 8", desc: "Set direction N"})
    hotkeys.Push({hotkey: "Alt + 9", desc: "Set direction NE"})

    for key, value in hotkeys
    {
        if (value = "<br>") {
            Gui, HotkeysWaypoints:Add, Text, x10 y+1 w200 Section, % ""
            continue

        }
        Gui, HotkeysWaypoints:Add, Text, x10 y+5 w200 Section, % "[ " value.hotkey " ]"
        Gui, HotkeysWaypoints:Add, Text, x+5 yp+0, % value.desc

    }

    Gui, HotkeysWaypoints:Font, italic cGray

    Gui, HotkeysWaypoints:Add, Text, x10 y+10 w340 center, % LANGUAGE = "PT-BR" ? "As hotkeys só tem efeito se a janela do OldBot ou Ravendawn estiver em foco." : "The hotkeys have effect only if the OldBot or Ravendawn window is focused."

    Gui, HotkeysWaypoints:Font, norm

    Gui, HotkeysWaypoints:Font,

    Gui, HotkeysWaypoints:Show,, Cavebot/Waypoint Hotkeys
return
HotkeysWaypointsGuiEscape:
HotkeysWaypointsGuiClose:
    Gui, HotkeysWaypoints:Destroy
return

LoadScriptInfoGUI:
    GuiControlGet, LoadScriptInfoGUI
    IniWrite, %LoadScriptInfoGUI%, %DefaultProfile%, settings, LoadScriptInfoGUI
return

InformacoesScript:
    try ScriptRestriction.checkScriptRestriction()
    catch
    return
GuiControlGet, InformacoesScript
scriptFile.scriptInfo := InformacoesScript
CavebotScript.saveSettings(A_ThisFunc)
Msgbox, 64,, % LANGUAGE = "PT-BR" ? "Sucesso." : "Success."
return

ScriptInfoGUI:
    Gui, ScriptInfoGUI:Destroy
    Gui, ScriptInfoGUI:-MinimizeBox

    Disabled := (protected = true) ? "Disabled" : ""
    ReadOnly := (protected = true) ? "ReadOnly" : ""

    DisabledBlockEdit := (DisableEditScript = 1) ? "Disabled" : ""

    Gui, ScriptInfoGUI:Add, Edit, x10 y+5 h430 w600 vInformacoesScript -HScroll %ReadOnly%, %InformacoesScript%
    Gui, ScriptInfoGUI:Add, Button, xp-1 y+3 w125 h25 gInformacoesScript hwndSalvarInfos_Button %Disabled% %DisabledBlockEdit%, % LANGUAGE = "PT-BR" ? "Salvar informações" : "Save information"
    ; GuiButtonIcon(SalvarInfos_Button, "shell32.dll", 297, "a0 l2 s18")
    Gui, ScriptInfoGUI:Show,,% LANGUAGE = "PT-BR" ? "Informações do script - " currentScript : "Script information - " currentScript
    GuiControl, ScriptInfoGUI:, InformacoesScript, % scriptFile.scriptInfo
return
ScriptInfoGUIGuiEscape:
ScriptInfoGUIGuiClose:
    Gui, ScriptInfoGUI:Destroy
return

WhereToStartGUI:
    CavebotGUI.WhereToStartGUI()
return
WhereToStartGUIGuiEscape:
WhereToStartGUIGuiClose:
    Gui, WhereToStartGUI:Destroy
return

selectWhereToStartImage:
    FileSelectFile, image, 3,, Select a ".png" picture file(800 x 600px max size), (*.png)
    if (image = "")
        return
    if (!InStr(image, ".png")) {
        Msgbox, 48,, % "Select a .png file."
        return
    }

    string := InStr(image, "\", 0, -1)
    newImage := SubStr(image, string - StrLen(image) + 1)
    imageName := _ScriptImages.getNextWhereToStartImageName()
    ; msgbox, % string " / " newImage

    ; InputBox, imageName, Image name, Write a unique  name for the selected image:,, 300, 150, X := "", Y := "", Font := "", Timeout := "", %image%
    ; if (imageName = "")
    ;     return
    ; InputBox, imageName, Image name, Write a name for the image, HIDE, Width, Height, X, Y, Font, Timeout, Default]

    ; msgbox, % imageName "`n" image
    try
        _ScriptImages.addImageFromPath(image, imageName)
    catch e {
        Msgbox, 48,, % e.Message
        return
    }

    Goto, WhereToStartGUI
return

changeWhereToStartScriptImage:
    imageNumber := StrReplace(A_GuiControl, "WhereToStartImage", "")

    imageName := "WhereToStart" imageNumber

    GetKeyState, CtrlPressed, Ctrl, D
    if (CtrlPressed = "D") {
        Msgbox, 52,, % "Do you want to DELETE the script image """ imageName """?"
        IfMsgBox, no
            return
        _ScriptImages.deleteImage(imageName)
        Goto, WhereToStartGUI
        return
    }
    GetKeyState, ShiftPressed, Shift, D
    if (ShiftPressed = "D") {
        try {
            image := new _ScriptImage(imageName).toClipboard()
        } catch e {
            Msgbox, 48, % imageName, % e.Message, 10
        }
        return
    }

    Msgbox, 68,, % "Do you want to overwrite the script image """ imageName """?"
    IfMsgBox, no
        return

    try
        _ScriptImages.addImageFromClipboard(imageName)
    catch e {
        Msgbox, 48,, % e.Message, 2
        return
    }
    Goto, WhereToStartGUI

return

addClipboardWhereToStartImage:
    if (_ScriptImages.getLastWhereToStartImageNumber() >= 6) {
        msgbox, 48,, % "You can only add up to 6 ""where to start"" images.", 2
        return
    }
    try
        _ScriptImages.addImageFromClipboard(_ScriptImages.getNextWhereToStartImageName())
    catch e {
        Msgbox, 48,, % e.Message, 2
        return
    }
    Goto, WhereToStartGUI
return

deleteWhereToStartImage:
    imageName := _ScriptImages.getLastWhereToStartImageName()
    if (imageName = 0)
        return
    Msgbox, 52,, % "This will delete the """ imageName """ Script Image.`n`nAre you sure?"
    IfMsgBox, No
        return
    _ScriptImages.deleteImage(imageName)
    Goto, WhereToStartGUI
return

CavebotGUI_TabScript1:
    ChooseTabScript := 1
    tab := LANGUAGE = "PT-BR" ? "Configurações Script" : "Script Settings"
    GuiControl, CavebotGUI:Choose, Tab_Script_Cavebot, 1
    Gosub, CavebotGUI
return

;CavebotGUI:
CavebotGUI:
    CavebotGUI.destroyButtonIconsCavebotGUI()
    CavebotGUI.createWaypointListviewIcons()
    InfoCarregando("Loading GUIs...")
    ; gosub, CarregandoCavebotGUI
    if (tab = "")
        tab := "Waypoints"
    selected_GUI := "Cavebot"
    Gosub, MainGUI
    if (TransparentOldBot = 1)
        Gosub, TransparentOldBot
    Gui, Carregando:Destroy
return

LV_Waypoints_lines:
    GuiControlGet, LV_Waypoints_lines
    if (LV_Waypoints_lines_old = LV_Waypoints_lines)
        return
    LV_Waypoints_lines_old := LV_Waypoints_lines

    IniWrite, %LV_Waypoints_lines%, %DefaultProfile%, cavebot_settings, LV_Waypoints_lines
    goto, CavebotGUI
return

DisableButtonsCavebot:
    GuiControl, CavebotGUI:Disable, LV_Waypoints
    GuiControl, CavebotGUI:Disable, LV_Waypoints2
    GuiControl, CavebotGUI:Disable, PosicaoDesejada_Button
    GuiControl, CavebotGUI:Disable, PosicaoDesejada
    GuiControl, CavebotGUI:Disable, DeletarWP_Button
    GuiControl, CavebotGUI:Disable, DeletarTodosWP_Button
    GuiControl, CavebotGUI:Disable, AddWaypoint_Andar_Button
    GuiControl, CavebotGUI:Disable, AddWaypoint_AndarComMark_Button
    GuiControl, CavebotGUI:Disable, AddWaypoint_Ladder_Button
    GuiControl, CavebotGUI:Disable, AddWaypoint_UsarItem_Button
    GuiControl, CavebotGUI:Disable, EditarWaypoint_Button
    GuiControl, CavebotGUI:Disable, SpecialAction_Button
    GuiControl, CavebotGUI:Disable, AHKScriptCavebot_Button
    GuiControl, CavebotGUI:Disable, Label_Button
    GuiControl, CavebotGUI:Disable, TestarWP_Button
    GuiControl, CavebotGUI:Disable, DuplicarWP_Button
    GuiControl, CavebotGUI:Disable, ActionScript_Button
    GuiControl, CavebotGUI:Disable, ImportarWP_Button
    GuiControl, CavebotGUI:Disable, AddWaypoint_ClicarSQM_Button
    GuiControl, CavebotGUI:Disable, MoveToTabWP_Button
return
EnableButtonsCavebot:
    GuiControl, CavebotGUI:Enable, LV_Waypoints
    GuiControl, CavebotGUI:Enable, LV_Waypoints2
    GuiControl, CavebotGUI:Enable, PosicaoDesejada_Button
    GuiControl, CavebotGUI:Enable, PosicaoDesejada
    GuiControl, CavebotGUI:Enable, DeletarWP_Button
    GuiControl, CavebotGUI:Enable, DeletarTodosWP_Button
    GuiControl, CavebotGUI:Enable, AddWaypoint_Andar_Button
    GuiControl, CavebotGUI:Enable, AddWaypoint_AndarComMark_Button
    GuiControl, CavebotGUI:Enable, AddWaypoint_Ladder_Button
    GuiControl, CavebotGUI:Enable, AddWaypoint_UsarItem_Button
    GuiControl, CavebotGUI:Enable, EditarWaypoint_Button
    GuiControl, CavebotGUI:Enable, SpecialAction_Button
    GuiControl, CavebotGUI:Enable, AHKScriptCavebot_Button
    GuiControl, CavebotGUI:Enable, Label_Button
    GuiControl, CavebotGUI:Enable, TestarWP_Button
    GuiControl, CavebotGUI:Enable, DuplicarWP_Button
    GuiControl, CavebotGUI:Enable, ActionScript_Button
    GuiControl, CavebotGUI:Enable, ImportarWP_Button
    GuiControl, CavebotGUI:Enable, AddWaypoint_ClicarSQM_Button
    GuiControl, CavebotGUI:Enable, MoveToTabWP_Button
return

manageScriptRestrictionGUI:
    ScriptRestriction.createRestrictionGUI()
return

manageScriptRestrictionGUIGuiEscape:
manageScriptRestrictionGUIGuiClose:
    Gui, manageScriptRestrictionGUI:Destroy
return

_restrictScript:
    try ScriptRestriction.restrictScript()
    catch e {
        Msgbox, 48,, % e.Message "`n" e.What
        return
    }
    Gosub, manageScriptRestrictionGUI
return

Create_CavebotGUI:

    CavebotGUI.createCavebotGUI()

return

ChangeTabOrderGUI:
    CavebotScript.createScriptTabsList()
    if (ScriptTabsList.MaxIndex() <= 1) {
        msgbox, 64,, % LANGUAGE = "PT-BR" ? "Não há abas adicionais no script." : "There are no additional tabs in the script.", 3
        return
    }
    options := ""
    rows := 0
    tab_order_array := []
    for key, value in ScriptTabsList
    {
        if (value = "Waypoints")
            continue
        tab_order_array.Push(value)
        options .= value "|"
        rows++
    }
    Gui, ChangeTabOrderGUI:Destroy
    Gui, ChangeTabOrderGUI:+AlwaysOnTop -MinimizeBox
    Gui, ChangeTabOrderGUI:Add, Listbox, vSelectedTab x10 y5 w150 r%rows%, %options%
    Gui, ChangeTabOrderGUI:Add, Button, xp+0 y+5 w150 gSaveTabOrder, % LANGUAGE = "PT-BR" ? "Salvar ordenação" : "Save order"
    ; Gui, ChangeTabOrderGUI:Add, Edit, xp+0 y+5 w120 r6 vTeste1, % serialize(tab_order_array)
    ; Gui, ChangeTabOrderGUI:Add, Edit, xp+0 y+5 w120 r6 vTeste2,
    Gui, ChangeTabOrderGUI:Add, Button, x165 y5 w50 vUp gChangeTabOrder, Up
    Gui, ChangeTabOrderGUI:Add, Button, xp+0 y+5 w50 vDown gChangeTabOrder, Down
    Gui, ChangeTabOrderGUI:Show,, % LANGUAGE = "PT-BR" ? "Alterar ordem das abas" : "Change tabs order"
return
ChangeTabOrderGUIGuiEscape:
ChangeTabOrderGUIGuiClose:
    Gui, ChangeTabOrderGUI:Destroy
return

; Context Menu.
CavebotGUIGuiContextMenu:
    If (A_GuiControl = "Tab_Script_Cavebot") && (tab != "Configurações Script" && tab != "Script Settings")
        Menu, TabMenuCavebot, Show
return

ChangeTabOrder:
    Gui, ChangeTabOrderGUI:Submit, NoHide

    old_pos := InArray(tab_order_array, SelectedTab)
    new_order_array := []
    for key, value in tab_order_array
        new_order_array.Push(value)

    ; msgbox, % serialize(new_order_array) "`n`n" serialize(tab_order_array)
    if (A_GuiControl = "Up") {
        new_pos := old_pos - 1
        if (new_pos < 1)
            new_pos := 1
        new_order_array[new_pos] := SelectedTab
        new_order_array[old_pos] := tab_order_array[new_pos]
    }
    if (A_GuiControl = "Down") {
        new_pos := old_pos + 1
        if (new_pos > tab_order_array.MaxIndex())
            new_pos := tab_order_array.MaxIndex()
        new_order_array[new_pos] := SelectedTab
        new_order_array[old_pos] := tab_order_array[new_pos]
    }
    tab_order_array := new_order_array
    ; msgbox, % serialize(new_order_array) "`n`n" serialize(tab_order_array)
    options := ""
    for key, value in new_order_array
        options .= value "|"
    GuiControl,, SelectedTab, % "|"
    GuiControl,, SelectedTab, %options%
    ; GuiControl,, teste1, % serialize(tab_order_array)
    ; GuiControl,, teste2, % serialize(new_order_array)
    GuiControl, ChooseString, SelectedTab, %SelectedTab%

return

SaveTabOrder:
    if (new_order_array.MaxIndex() < 1)
        return
    Gui, ChangeTabOrderGUI:Destroy
    ScriptTabsListDropdown := "Main|"
    for key, value in new_order_array
        ScriptTabsListDropdown .= value "|"
    IniWrite, %ScriptTabs%, Cavebot\%currentScript%\waypoints.ini, tabs, ScriptTabs
    CavebotScript.createScriptTabsList()
    Goto, CavebotGUI
return

SelectTabRename:
    GuiControlGet, RenameTabSelected
    GuiControl, RenameTabGUI:, RenameTabName, %RenameTabSelected%
return


DisableEditScript:
    GuiControlGet, DisableEditScript
    IniWrite, %DisableEditScript%, Cavebot\%currentScript%\waypoints.ini, settings, DisableEditScript
    Goto, CavebotGUI
return
PainelSpecialActionX:
    Gui, CavebotGUI:Submit, NoHide
    if (PainelSpecialActionX < 0) {
        PainelSpecialActionX = 0
        GuiControl, CavebotGUI:, PainelSpecialActionX, %PainelSpecialActionX%
    }
    if (PainelSpecialActionX > A_ScreenWidth) {
        PainelSpecialActionX = %A_ScreenWidth%
        GuiControl, CavebotGUI:, PainelSpecialActionX, %PainelSpecialActionX%
    }
    IniWrite, %PainelSpecialActionX%, %DefaultProfile%, cavebot_settings, PainelSpecialActionX
return
PainelSpecialActionY:
    Gui, CavebotGUI:Submit, NoHide
    if (PainelSpecialActionY < 0) {
        PainelSpecialActionY = 0
        GuiControl, CavebotGUI:, PainelSpecialActionY, %PainelSpecialActionY%
    }
    if (PainelSpecialActionY > A_ScreenHeight) {
        PainelSpecialActionY = %A_ScreenHeight%
        GuiControl, CavebotGUI:, PainelSpecialActionY, %PainelSpecialActionY%
    }
    IniWrite, %PainelSpecialActionY%, %DefaultProfile%, cavebot_settings, PainelSpecialActionY
return
PainelCavebotX:
    Gui, CavebotGUI:Submit, NoHide
    if (PainelCavebotX < 0) {
        PainelCavebotX = 0
        GuiControl, CavebotGUI:, PainelCavebotX, %PainelCavebotX%
    }
    if (PainelCavebotX > A_ScreenWidth) {
        PainelCavebotX = %A_ScreenWidth%
        GuiControl, CavebotGUI:, PainelCavebotX, %PainelCavebotX%
    }
    IniWrite, %PainelCavebotX%, %DefaultProfile%, cavebot_settings, PainelCavebotX
return
PainelCavebotY:
    Gui, CavebotGUI:Submit, NoHide
    if (PainelCavebotY < 0) {
        PainelCavebotY = 0
        GuiControl, CavebotGUI:, PainelCavebotX, %PainelCavebotX%
    }
    if (PainelCavebotY > A_ScreenHeight) {
        PainelCavebotY = %A_ScreenHeight%
        GuiControl, CavebotGUI:, PainelCavebotY, %PainelCavebotY%
    }
    IniWrite, %PainelCavebotY%, %DefaultProfile%, cavebot_settings, PainelCavebotY
return
NaoMostrarMensagem_DeletarWaypoint:
    Gui, CavebotGUI:Submit, NoHide
    IniWrite, %NaoMostrarMensagem_DeletarWaypoint%, %DefaultProfile%, cavebot_settings, NaoMostrarMensagem_DeletarWaypoint
return
NaoMostrarMensagem_DistanceAttackMode:
    Gui, WhatIsTargetingMode:Submit, NoHide
    IniWrite, %NaoMostrarMensagem_DistanceAttackMode%, %DefaultProfile%, settings, NaoMostrarMensagem_DistanceAttackMode
return

cavebotLogsAlwaysOnTop:
    GuiControlGet, cavebotLogsAlwaysOnTop
    IniWrite, %cavebotLogsAlwaysOnTop%, %DefaultProfile%, cavebot_settings, cavebotLogsAlwaysOnTop
return

RopeHotkey:
    CavebotScript.setItemHotkey("rope")
return
ShovelHotkey:
    CavebotScript.setItemHotkey("shovel")
return
MacheteHotkey:
    CavebotScript.setItemHotkey("machete")
return

; screenshotOnDeath:
; return
pauseOnDeath:
    CavebotScript.setPauseOnDeath()
return
nodeRange:
    CavebotScript.setNodeRange()
return

MoverWaypointHotkey:
    WaypointHandler.moveWaypoint(LV_GetNext(), waypointDest)
    CavebotGUI.loadLV()
return

DisableTargeting:
    TargetingEnabled := 0
    checkbox_setvalue("TargetingEnabled_2", 0)
    try GuiControl, CavebotGUI:, TargetingEnabled, 0
    catch {
    }
    IniWrite, 0, %DefaultProfile%, cavebot_settings, TargetingEnabled
    IniWrite, 0, %DefaultProfile%, cavebot_settings, TargetingEnabled_2
return
DisableCavebot:
    CavebotEnabled := 0
    checkbox_setvalue("CavebotEnabled_2", 0)
    try GuiControl, CavebotGUI:, CavebotEnabled, 0
    catch {
    }
    IniWrite, 0, %DefaultProfile%, cavebot_settings, CavebotEnabled
    IniWrite, 0, %DefaultProfile%, cavebot_settings, CavebotEnabled_2
return
DisableCavebotTargeting:
    TargetingEnabled := 0, CavebotEnabled := 0, CavebotTargeting := 0
    checkbox_setvalue("CavebotTargeting", 0)
    checkbox_setvalue("TargetingEnabled_2", 0)
    checkbox_setvalue("CavebotEnabled_2", 0)
    try {
        GuiControl, CavebotGUI:, TargetingEnabled, 0
        GuiControl, CavebotGUI:, CavebotEnabled, 0
    } catch {
    }
    IniWrite, 0, %DefaultProfile%, cavebot_settings, TargetingEnabled
    IniWrite, 0, %DefaultProfile%, cavebot_settings, TargetingEnabled_2
    IniWrite, 0, %DefaultProfile%, cavebot_settings, CavebotEnabled
    IniWrite, 0, %DefaultProfile%, cavebot_settings, CavebotEnabled_2
return

TargetingEnabled:
    Gui, CavebotGUI:Default
    Gui, Submit, NoHide
    if (TargetingEnabled = 1) {
        functionName := "TargetingEnabled"
        try TibiaClient.checkClientSelected()
        catch e {
            value := 0
            %functionName% := value, %moduleName%[functionName] := value, checkbox_setvalue(functionName "_2", value)
            IniWrite, %value%, %DefaultProfile%, cavebot_settings, %functionName%
            try {
                GuiControl, CavebotGUI:, % functionName, % value
            } catch {
            }
            Gui, Carregando:Destroy
            MsgBox, 64,, % e.Message, 2
            return
        }
    }
    checkbox_setvalue("TargetingEnabled_2", TargetingEnabled)
    IniWrite, %TargetingEnabled%, %DefaultProfile%, cavebot_settings, TargetingEnabled

    #Include __Files\Labels\Cavebot\cavebot_enabled.ahk

VerificarExecucaoCavebot:

    if (timeCheckingCavebot.elapsed() > 30000) || (!CavebotEnabled && !TargetingEnabled) {
        SetTimer, VerificarExecucaoCavebot, Delete
        Gui, Carregando2:Destroy
        Gui, Carregando:Destroy
        OldBotSettings.enableGuisLoading()
        return
    }

    if (_CavebotExe.isRunning()) {
        Gui, Carregando2:Destroy
        Gui, Carregando:Destroy
        SetTimer, VerificarExecucaoCavebot, Delete
        OldBotSettings.enableGuisLoading()
    }
return

ScriptTabsNavigation:
    Gui, CavebotGUI:Submit, NoHide
    switch Tab_Script_Cavebot
    {
        case "+":
            GuiControl, CavebotGUI:Choose, Tab_Script_Cavebot, 2 ; selecionar a tab Waypoints como padrão
            if (DisableEditScript = 1)
                Msgbox, 64,, % LANGUAGE = "PT-BR" ? "O script está marcado para bloquear a edição de waypoints." : "The script is checked to block the editing of waypoint."
            else
                Gosub, NewTabGUI
            return
        case "Configurações Script", case "Script settings":
            GuiControl, CavebotGUI:Choose, Tab_Script_Cavebot, 2 ; selecionar a tab Waypoints como padrão
            goto, ScriptSettingsGUI
            return
        default:
    }

    /**
    Tirar seleção dos waypoints da aba passada
    */
    Loop,% LV_GetCount()
        LV_Modify(A_Index, "-Focus -Select")
    tab := Tab_Script_Cavebot
    tab_prefix := Tab_Script_Cavebot "_"
    ; msgbox, % CavebotGUIHwnd
    if (IsSettingScriptTab(Tab_Script_Cavebot)) {
        for key, value in GUI_elements
            GuiControl, Hide, %value%
        right_buttons_hidden := true ; variavel de controle pra não da Show nos elementos se eles ja foram mostrados anteriormente
    } else {
        Gui, ListView, LV_Waypoints_%Tab_Script_Cavebot% ; definir o LV da aba como padrão]
    }
    if (selectedTabs.MaxIndex() > 100) {
        lastOldTab := selectedTabs.MaxIndex() - 1
        selectedTabs := {}
        selectedTabs.Push(lastOldTab)
    }
    selectedTabs.Push(tab)
return

; CavebotGUIGuiEscape:
CavebotGUIGuiClose:
    ; Msgbox, 68, % "Close OldBot", % (LANGUAGE = "PT-BR" ? "Você tem certeza que quer fechar o OldBot?" : "Are you sure you want to close OldBot?")
    ; IfMsgBox, No
    ;     return
    CavebotScript.deleteAllTempScriptFiles()
    CavebotGUI.destroyButtonIcons()
    Goto, ElfGuiGUIClose
return

selectRowLV(rowNumber) {
    LV_Modify(selectedWaypointEdit, "-Focus -Select")
    LV_Modify(rowNumber, "Focus Select")
    LV_Modify(rowNumber, "Vis")
    return

}

copyCoords:
    Gui, editWaypointAtributeGUI:Submit, NoHide
    try
        Clipboard := editWaypointX "," editWaypointY "," editWaypointZ
    catch {
        Msgbox, 48,, Failed to copy to clipboard.
        return
    }
    TrayTip, % "OldBot notification", % "Coordinates copied.", 2, 1
    SetTimer, HideTrayTip, Delete
    SetTimer, HideTrayTip, -2000
return

openCoordsTibiaMaps:
    Gui, editWaypointAtributeGUI:Submit, NoHide
    Run, % "https://tibiamaps.io/map#" editWaypointX "," editWaypointY "," editWaypointZ ":2"
return

openCoordsTibiaMapViewer:
    Gui, editWaypointAtributeGUI:Submit, NoHide
    MinimapGUI.changeCoordinatesControl(editWaypointX, editWaypointY, editWaypointZ)
    Goto, minimapViewer

return

LV_Waypoints_tab2:
return
LV_Waypoints_tab:
    if (DisableEditScript = 1)
        return
LVLabel:
    Gui, CavebotGUI:Default
    Gui, ListView, LV_Waypoints_%tab%

    switch A_GuiEvent {
        case "Normal":
            GetKeyState, AltPressed, Alt, D
            if (AltPressed = "D") {
                goto, SetStartWaypoint
            }

            _WaypointViewer.setWaypointsToShow()

        case "K":
            ; if (Chr(A_EventInfo) = "e") {
            ;     ; Gui, ListView, %A_GuiControl%
            ;     If (Row := LV_GetNext(0, "Focused")) {
            ;         selectedWaypointColEdit := "", selectedWaypointCell := ""
            ;         ICELV_%tab%.EditCell(Row)
            ;         return
            ;     }
            ; }
            selectedWaypointEdit := _ListviewHandler.getSelectedItemOnLV("LV_Waypoints_" tab, 1)
            if (selectedWaypointEdit = "" OR selectedWaypointEdit = "WP")
                return
            switch Chr(A_EventInfo) {
                case "l": Goto, EditWaypointLabel
                case "c": Goto, EditWaypointCoordinates
                case "r": Goto, EditWaypointRange
                case "t": Goto, EditWaypointType
                case "a": Goto, EditWaypointAction
            }
        Case "DoubleClick":
            selectedWaypointEdit := _ListviewHandler.getSelectedItemOnLV("LV_Waypoints_" tab, 1)
            if (selectedWaypointEdit = "" OR selectedWaypointEdit = "WP")
                return
            switch WaypointHandler.getAtribute("type", selectedWaypointEdit) {
                case "Action": Goto, ActionScriptGUI
                default: Goto, EditWaypointCoordinates
            }

        Case "D":
            ; Detect Drag event.
            selectedWaypointDrag := _ListviewHandler.getSelectedItemOnLV("LV_Waypoints_" tab, 1)
            waypointDest := LvHandle_%tab%.Drag()
            if (waypointDest = "")
                return
            WaypointHandler.moveWaypoint(waypointDest)
            CavebotGUI.loadLV()
            _ListviewHandler.selectRow(LV_Waypoints_%tab%, waypointDest > selectedWaypointDrag ? waypointDest - 1 : waypointDest)
            return
        Case "RightClick":
            selectedWaypointEdit := _ListviewHandler.getSelectedItemOnLV("LV_Waypoints_" tab, 1)
            if (selectedWaypointEdit = "" OR selectedWaypointEdit = "WP")
                return
            GetKeyState, AltPressed, Alt, D
            if (AltPressed = "D") {
                Goto, OpenWaypointMapViewerStart
                return
            }
            Menu, CavebotMenu, Show
    }
return

SetListView() {
    Gui, CavebotGUI:Default
    GuiControlGet, Tab_Script_Cavebot
    if (IsSettingScriptTab(Tab_Script_Cavebot) = false) && (Tab_Script_Cavebot != "") {
        tab := Tab_Script_Cavebot
        tab_prefix := Tab_Script_Cavebot "_"
    }
    Gui, ListView, LV_Waypoints_%Tab_Script_Cavebot%
    return

}

GetSelectedSQM() {
    Gui, AddWaypointGUI:Default
    Gui, AddWaypointGUI:Submit, NoHide
    Loop, 9 {
        GuiControlGet, WaypointSQM_%A_Index%
        if (WaypointSQM_%A_Index% = 1) {
            return A_Index
        }
    }
    return 5
}

RenameTabLabel:
    try
        CavebotScript.renameScriptTab()
    catch e {
        Msgbox, 48,, % e.Message "`n" e.What "`n" e.File "`n" e.Line
        Goto, RenameTabGUI
    }
    Goto, CavebotGUI
return

RenameTabGUI:
    CavebotGUI.createRenameTabGUI()
return
RenameTabGUIGuiEscape:
RenameTabGUIGuiClose:
    Gui, RenameTabGUI:Destroy
return

AddNewTabLabel:
    try
        CavebotScript.addScriptTabFromGui()
    catch e {
        Msgbox, 48,, % e.Message
        Goto, NewTabGUI
    }
    Goto, CavebotGUI
return

RenameTabName:
    GuiControlGet, RenameTabName
    if (RegExMatch(RenameTabName," ") OR RegExMatch(RenameTabName,"[^\w]")) {
        RenameTabName := CavebotScript.getFixedTabName(RenameTabName)
        GuiControlEdit("RenameTabGUI", "RenameTabName", RenameTabName)
        Send, {End}
    }
return

NewTabName:
    GuiControlGet, NewTabName
    if (RegExMatch(NewTabName," ") OR RegExMatch(NewTabName,"[^\w]")) {
        NewTabName := CavebotScript.getFixedTabName(NewTabName)
        GuiControlEdit("NewTabGUI", "NewTabName", NewTabName)
        Send, {End}
    }
return

NewTabGUI:
    CavebotGUI.createNewTabGUI()
return
NewTabGUIGuiEscape:
NewTabGUIGuiClose:
    Gui, NewTabGUI:Destroy
return

DeleteTabLabel:
    try
        CavebotScript.deleteScriptTab()
    catch e {
        Msgbox, 48,, % e.Message
        Goto, DeleteTabGUI
    }
    ; Gosub, ScriptTabsNavigation
    Goto, CavebotGUI
return

DeleteTabGUI:
    CavebotGUI.createDeleteTabGUI()
return
DeleteTabGUIGuiEscape:
DeleteTabGUIGuiClose:
    Gui, DeleteTabGUI:Destroy
return

DuplicarWaypoint:
    Gui, CavebotGUI:Submit, NoHide
    SetListView()
    WaypointHandler.duplicateWaypoints()

return

DeleteWaypoints:
; if (NaoMostrarMensagem_DeletarWaypoint = 0) {

;     Gui, DeletarWaypointGUI:Destroy
;     Gui, DeletarWaypointGUI:+AlwaysOnTop +Owner -MinimizeBox
;     Gui, DeletarWaypointGUI:Add, Text, x10 y5+5, % LANGUAGE = "PT-BR" ? "Deletar waypoint(s)?" : "Delete waypoint(s)?"
;     Gui, DeletarWaypointGUI:Add, Button, x10 y+7 w40 gContinuarDelecao 0x1, % LANGUAGE = "PT-BR" ? "Sim" : "Yes"
;     Gui, DeletarWaypointGUI:Add, Button, x+3 yp+0 w40 gDeletarWaypoint_No, % LANGUAGE = "PT-BR" ? "Não" : "No"
;     Gui, DeletarWaypointGUI:Add, Checkbox, x10 y+5 vNaoMostrarMensagem_DeletarWaypoint, % LANGUAGE = "PT-BR" ? "Não mostrar mensagem`nde confirmação" : "Don't show confirmation`nmessage"
;     Gui, DeletarWaypointGUI:Show,, % LANGUAGE = "PT-BR" ? "Deletar waypoints" : "Delete waypoints"
;     return
; }
ContinuarDelecao:
    Gui, DeletarWaypointGUI:Submit, NoHide
    if (NaoMostrarMensagem_DeletarWaypoint = 1)
        IniWrite, %NaoMostrarMensagem_DeletarWaypoint%, %DefaultProfile%, cavebot_settings, NaoMostrarMensagem_DeletarWaypoint

    WaypointHandler.deleteWaypoints()
return

DeletarWaypointGUIGuiEscape:
DeletarWaypointGUIGuiClose:
    Gui, DeletarWaypointGUI:Destroy
return

DeletarWaypoint_No:
    Gui, DeletarWaypointGUI:Destroy
return

GetSelectedWaypoints:
    SetListView()
    QtdWaypoints = 1
    RowNumber = 0 ; This causes the first loop iteration to start the search at the top of the list.
    Loop {
        RowNumber := LV_GetNext(RowNumber) ; Resume the search at the row after that found by the previous iteration.
        if not RowNumber ; The above returned zero, so there are no more selected rows.
            break
        LV_GetText(Text, RowNumber)
        StringReplace, Text, Text, %A_Space%,, All
        WPDeletar_%QtdWaypoints% := Text
        ; MsgBox The next selected row is #%RowNumber%, whose first field is "%Text%".
        QtdWaypoints++
    }
    QtdWaypoints--
return

ChooseScriptTab(tabName) {
    for key, value in ScriptTabsList
    {
        if (value = tabName)
            ChooseTabScript := key
    }
    ChooseTabScript++ ; a primeira tab é sempre configurações
    Gui, ListView, LV_Waypoints_%tabName%
    Tab_Script_Cavebot := tabName
    GuiControl, CavebotGUI:Choose, Tab_Script_Cavebot, %ChooseTabScript% ; selecionar a tab Waypoints como padrão
    Gosub, ScriptTabsNavigation
    return
}

ConvertFloor(selected_level, to_slider := false) {
    if (to_slider = true) {
        switch selected_level
        {
            case "7": level = 15
            case "6": level = 14
            case "5": level = 13
            case "4": level = 12
            case "3": level = 11
            case "2": level = 10
            case "1": level = 9
            case "0": level = 8
            case "-1": level = 7
            case "-2": level = 6
            case "-3": level = 5
            case "-4": level = 4
            case "-5": level = 3
            case "-6": level = 2
            case "-7": level = 1
            case "-8": level = 0
        }
        return level

    }
    switch selected_level
    {
        case "15": level := "7"
        case "14": level := "6"
        case "13": level := "5"
        case "12": level := "4"
        case "11": level := "3"
        case "10": level := "2"
        case "9": level := "1"
        case "8": level := "0"
        case "7": level := "-1"
        case "6": level := "-2"
        case "5": level := "-3"
        case "4": level := "-4"
        case "3": level := "-5"
        case "2": level := "-6"
        case "1": level := "-7"
        case "0": level := "-8"
    }

    return level
}

loadScriptWindbot:
    Msgbox, 64, % "How to load Windbot Waypoints (EXPERIMENTAL)", % "ATTENTION! WindBot script is a "".xml"" file. To load in OldBot, need to first convert manually the .xml to .json file.`n`nYou can convert it using some online tool such as ""www.codebeautify.org/xmltojson"" or others."
    IfMsgBox, No
        return
    Msgbox, 68,, % "Open https://codebeautify.org/xmltojson on browser?"
    IfMsgBox, Yes
    {
        Run, https://codebeautify.org/xmltojson
    }
    CavebotScript.convertScriptWindbot()
return

selectMarkerGUIGuiEscape:
selectMarkerGUIGuiClose:
    Gui, selectMarkerGUI:Destroy
return

setGameAreas:
    CavebotGUI.setGameAreasGUI()
return

setGameAreasGUIGuiClose:
setGameAreasGUIGuiEscape:
    Gui, setGameAreasGUI:Destroy
return

ShowLootSearchArea:
    ClientAreas.showLootSearchArea()
return
SetLootSearchArea:
    Gui, setGameAreasGUI:Hide
    ClientAreas.setLootSearchArea()
    Gui, setGameAreasGUI:Show
return
ShowLootBackpackPosition:
    ClientAreas.showLootBackpackPosition()
return
SetLootBackpackPosition:
    Gui, setGameAreasGUI:Hide
    ClientAreas.setLootBackpackPosition()
    Gui, setGameAreasGUI:Show
return

ShowGameWindowArea:
    ClientAreas.showGameWindowArea()
return
SetGameWindowArea:
    ClientAreas.setGameWindowArea()
return

cavebotFunctioningMode:
    Gui, minimapViewerGUI:Destroy
    GuiControlGet, cavebotFunctioningMode
    _GuiHandler.submitSetting("scriptSettings", "cavebotFunctioningMode", cavebotFunctioningMode)

    SetTimer, Reload, -750
    ;Goto, CavebotGUI
return

AddImageWaypointMinimap:
    CavebotGUI.changeWaypointImageMinimap()
return

waypointImageType:
    GuiControlGet, waypointImageType
    IniWrite, %waypointImageType%, %DefaultProfile%, settings, waypointImageType
    CavebotGUI.selectMarkerGUI()
return

waypointImageTypeEdit:
    GuiControlGet, waypointImageType
    CavebotGUI.selectMarkerGUI(waypointAtributeNumber, waypointImageType)
return

minimapWaypointWidth:
    GuiControlGet, minimapWaypointWidth
    GuiControlGet, minimapWaypointHeight

    GetKeyState, CtrlPressed, Ctrl, D
    if (CtrlPressed != "D")
        GuiControl, selectMarkerGUI:, minimapWaypointHeight, % minimapWaypointHeight := minimapWaypointWidth

    IniWrite, %minimapWaypointWidth%, %DefaultProfile%, settings, minimapWaypointWidth
    IniWrite, %minimapWaypointHeight%, %DefaultProfile%, settings, minimapWaypointHeight

    SetTimer, scaleMinimapDummyImage, Delete
    SetTimer, scaleMinimapDummyImage, -50
return

minimapWaypointHeight:
    GuiControlGet, minimapWaypointWidth
    GuiControlGet, minimapWaypointHeight

    GetKeyState, CtrlPressed, Ctrl, D
    if (CtrlPressed != "D") {
        GuiControl, selectMarkerGUI:, minimapWaypointWidth, % minimapWaypointWidth := minimapWaypointHeight
    }

    SetTimer, scaleMinimapDummyImage, Delete
    SetTimer, scaleMinimapDummyImage, -50
return

scaleMinimapDummyImage:
    CavebotGUI.setDummyWaypointImage(minimapWaypointWidth, minimapWaypointHeight)
return

TestImageWaypointMinimap:
    if (TibiaClient.getClientArea() = false) {
        return
    }

    if (imageAddWaypointMarker) {
        base64 := imageAddWaypointMarker
    } else {
        if (!waypointsObj[tab][selectedWaypointEdit].image) {
            Gui, selectMarkerGUI:Hide
            Msgbox, 64, % "", % "There is no image for this waypoint, add the image first to test.", 4
            Gui, selectMarkerGUI:Show
            return
        }
        base64 := waypointsObj[tab][selectedWaypointEdit].image
    }

    Gui, selectMarkerGUI:Hide
    WinActivate()

    try {
        waypointImage := new _Base64Image(tab "." selectedWaypointEdit, base64)

        _search := new _Base64ImageSearch()
            .setImage(waypointImage)
            .setVariation(_CavebotByImage.MARKER_VARIATION)
            .search()
    } catch e {
        Msgbox, 48, % "Image Search", % e.Message, 6
        return
    } finally {
        waypointImage.dispose()
    }

    if (_search.notFound()) {
        msgbox,48,, % "Waypoint image not found.", 2
        Gui, selectMarkerGUI:Show
        return
    }

    coord := new _Coordinate(_search.getX() + (waypointW / 2), _search.getY() + (waypointH / 2))
        .click()

    MouseMove, WindowX + x, WindowY + y
    msgbox, 64,, % "Found!", 2
    Gui, selectMarkerGUI:Show

return

backupCurrentScript:
    CavebotScript.backupScript()
    CavebotScript.checkScriptBackups()
return
