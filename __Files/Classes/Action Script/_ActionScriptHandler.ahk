

class _ActionScriptHandler
{
    __New()
    {

    }

    saveActionScript(fromHotkey := false) {
        setSystemCursor("IDC_WAIT")
        ; SetListView()
        Gui, ActionScriptGUI:Default
        GuiControlGet, actionScriptCode

        if (actionScriptTypeID != "") {
            switch actionScriptWaypoint {
                case "hotkey":
                    this.saveActionScriptHotkey(actionScriptTypeID)
                case "persistent":
                    this.saveActionScriptPersistent(actionScriptTypeID)
                default:
                    if (!A_IsCompiled)
                        msgbox, 16, % A_ThisFunc, % "Default actionScriptWaypoint: " actionScriptWaypoint
            }
        } else {
            if (actionScriptWaypoint = "") {
                restoreCursor()
                Msgbox, 48,, No Action Script waypoint selected.
                return
            }

            this.saveActionScriptWaypoint()
        }

        GuiControl, ActionScriptGUI:Disable, SaveActionScript
        if (fromHotkey = true)
            Send, {Tab}

        Sleep, 100

        GuiControl, ActionScriptGUI:Enable, SaveActionScript
        if (actionScriptTypeID = "")
            _ListviewHandler.selectRow(LV_Waypoints_%tab%, actionScriptWaypoint)
        restoreCursor() 
    }

    saveActionScriptWaypoint() {
        ; msgbox, %  actionScriptCode "," actionScriptWaypoint "," actionScriptTab

        try
            WaypointHandler.editAtribute("action", actionScriptCode, actionScriptWaypoint, actionScriptTab)
        catch e {
            ; Msgbox, 52,, % e.Message (LANGUAGE = "PT-BR" ? "`n`nContinuar edição?" : "`n`nContinue editing?")
            Msgbox, 48,, % e.Message
        }

        CavebotGUI.loadLV()
    }

    saveActionScriptHotkey(ID) {
        hotkeysObj[ID].actionScript := WaypointValidation.formatActionToSave(actionScriptCode, "Hotkey")
        HotkeysHandler.saveHotkeys()
        ; gosub, SaveHotkeyChanges
    }

    saveActionScriptPersistent(ID) {
        persistentObj[ID].actionScript := WaypointValidation.formatActionToSave(actionScriptCode, "Persistent")
        PersistentHandler.savePersistent()
    }

    setActionScriptsVariablesObjValues(ArrayVars, tabName := "", waypointNumber := "", type := "") {
        classLoaded("_ActionScriptValidation", _ActionScriptValidation)

        if (!IsObject(actionScriptsVariablesObj))
            actionScriptsVariablesObj := {}


        for line, lineContent in ArrayVars
        {
            ; 
            if (_ActionScriptValidation.isVariableString(lineContent) = false)
                continue

            variableName := _ActionScriptValidation.getVariableName(lineContent)
            variableValue := _ActionScriptValidation.getVariableFunctionName(lineContent)
            /**
            if it's a itemcount function, the variable will receive the entire function as value, and not its params like getsetting() and getuseroption()
            */
            switch type {
                case "hotkey", case "persistent":
                    if (!IsObject(actionScriptsVariablesObj[type]))
                        actionScriptsVariablesObj[type] := {}

                    if (!IsObject(actionScriptsVariablesObj[type][waypointNumber]))
                        actionScriptsVariablesObj[type][waypointNumber] := {}

                    if (InStr(lineContent, "getsetting") OR InStr(lineContent, "getuseroption")) {
                        variableUserOption := _ActionScriptValidation.getVariableFunctionParam(variableValue)
                        actionScriptsVariablesObj[type][waypointNumber][variableName] := variableUserOption
                    } else {
                        actionScriptsVariablesObj[type][waypointNumber][variableName] := variableValue
                    }
                default:
                    if (InStr(lineContent, "getsetting") OR InStr(lineContent, "getuseroption")) {
                        variableUserOption := _ActionScriptValidation.getVariableFunctionParam(variableValue)
                        actionScriptsVariablesObj[tabName][waypointNumber][variableName] := variableUserOption
                    } else {
                        actionScriptsVariablesObj[tabName][waypointNumber][variableName] := variableValue
                    }
            }

            ; msgbox, % variableName "`n" variableValue "`n" variableUserOption

            ; msgbox,% serialize(actionScriptsVariablesObj[tabName][waypointNumber])
        } ; for line, lineContent in ArrayVars

        ; m(actionScriptsVariablesObj)
        ; msgbox,% serialize(actionScriptsVariablesObj)
    }






}