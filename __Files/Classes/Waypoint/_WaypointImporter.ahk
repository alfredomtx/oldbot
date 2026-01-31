

global scriptsTab
global toggleCheckAllWaypoints := 0
class _WaypointImporter
{
    __New()
    {

        this.listviewColumns := "WP|Type|Label|Coordinates|Action"

    }

    importWaypointsStart() {
        ; if (A_IsCompiled) {
        try this.selectedScript := ScriptListGUI.getSelectedScript()
        catch 
            return
        ; } else {
        ;     this.selectedScript := "Default"
        ; }

        if (this.loadSelectedScriptWaypoints() = false)
            return

        this.createScriptWaypointsGUI()
    }

    loadSelectedScriptWaypoints() {

        fileDir := "Cavebot\" this.selectedScript ".json"

        if (!FileExist(fileDir)) {
            msgbox, 48, % A_ScriptName "." A_ThisFunc, % "Script JSON file doesn't exist: " fileDir ".`n`nLoading ""Default"" script instead."
            return false
        }

        this.script := "", this.scriptObj := ""
        try {
            this.script := new JSONFile(fileDir)
        } catch e {
            Msgbox, 48,, % txt("O script selecionado não é válido OU está restringido(encriptado), não é possivel importar waypoints desse script.", "The selected script is not valid OR is restricted(encrypted), it is not possible to import waypoints from this script.") "`n`n`n" e.Message "" e.What, 10
            return false
        }

        ; if (this.isSelectedEncryptedScript() = true) {
        ;     return false
        ; }

        if (this.isCoordinateModeScript() = true) {
            Msgbox, 48,, % txt("O script selecionado está no modo de ""Markers"", é possivel importar waypoints somente de scripts no modo de ""Coordinates"".", "The selected script is on ""Markers"" mode, it is possible to import waypoints only from scripts on ""Coordinates"" mode."), 10
            return false
        }


        this.scriptObj := this.script.Object()

        ; msgbox, % serialize(this.scriptObj)
    }


    createScriptWaypointsGUI() {
        global

        Gui, importWaypointGUI:Destroy
        ; Gui, importWaypointGUI:+AlwaysOnTop -MinimizeBox +Owner

        tabName := this.scriptObj.waypoints[1]

        Gui, importWaypointGUI:Add, Text, x10 y+3, % txt("Abas do Script:", "Script Tabs:")
        Gui, importWaypointGUI:Add, ListBox, x10 y+3 vscriptsTab gselectWaypointImportTabLabel w150 r20,
        Gui, importWaypointGUI:Add, Button, x10 y+5 0x1 h35 w150 gimportSelectedTabLabel hwndhimportSelectedTabLabel, % txt("Importar Aba`nselecionada", "Import`nselected Tab")
        TT.Add(himportSelectedTabLabel, txt("Importar todos os waypoints da aba, se a aba não existe no script atual, irá cria-lá.", "Import all the waypoints of the tab, if the tab does not exist in the current script, it will create."))

        Gui, importWaypointGUI:Add, Button, x10 y+5 0x1 h35 w150 gimportSelectedWaypointsLabel hwndhimportSelectedWaypointsLabel, % txt("Importar Waypoints selecionados", "Import selected Waypoints")
        Gui, importWaypointGUI:Add, Button, x10 y+5 0x1 h20 w150 gselectAllWaypointsImportLabel, % txt("Selecionar todos os waypoints", "Select all waypoints")
        TT.Add(himportSelectedWaypointsLabel, txt("Importar os waypoints selecionados(checked) para a aba atual selecionada na tela do Cavebot.", "Import the selected(checked) waypoints for the current tab selected on the Cavebot screen."))


        Gui, importWaypointGUI:Add, ListView, x+5 y5 h%LV_Waypoints_height% w%w_LVWaypoints% AltSubmit -ReadOnly Checked Grid NoSort NoSortHdr vLV_Waypoints_Import hwndhLV_Waypoints_Import LV0x1 LV0x10, % this.listviewColumns

        Gui, importWaypointGUI:Show,, % txt("Importar Waypoints", "Import Waypoints") " - " this.selectedScript


        tabs := ""
        for tabName, atributes in this.scriptObj.waypoints
        {
            tabs .= tabName "|"
        }
        GuiControl, importWaypointGUI:, scriptsTab, % tabs
        GuiControl, importWaypointGUI:Choose, scriptsTab, % tabName

        this.loadTabWaypoints(tabName)
    }

    isSelectedEncryptedScript() {
        return false
    }

    isCoordinateModeScript() {
        return false
    }

    loadTabWaypoints(tabName) {
        Gui, importWaypointGUI:Default

        try {
            _ListviewHandler.loadingLV("LV_Waypoints_Import", "importWaypointGUI")
        } catch {
            return
        }

        ; LV_SetImageList( IMAGE_LIST_LV_Waypoints, 1 ) ; 0 for large icons, 1 for small icons

        Loop, % this.scriptObj.waypoints[tabName].Count()
        {
            ; msgbox, % "A_Index = " A_Index "`nActionWP = " action "`ntab_name = " tabName
            waypointObj := this.scriptObj.waypoints[tabName][A_Index]
            type := waypointObj.type
                , label := waypointObj.label
                , coordinates := "x:" waypointObj.coordinates.x ", y:" waypointObj.coordinates.y ", z:" waypointObj.coordinates.z
                , action := StrReplace(waypointObj.action, "<br>", "  ")

            if (StrLen(action) > 100)
                bigActionWidth := true

            Gui, importWaypointGUI:Default
            Gui, ListView, LV_Waypoints_Import
            LV_Add("", "" A_Index, type, label, coordinates, CavebotGUI.actionStringRow(A_Index, type, action) ) ; no icon

        }

        _ListviewHandler.setColumnInteger(1, "LV_Waypoints_Import", "importWaypointGUI")

        Loop, Parse, % this.listviewColumns, |
        {
            Gui, ListView, LV_Waypoints_Import
            LV_ModifyCol(A_Index, "autohdr")
        }
        if (bigActionWidth = true)
            LV_ModifyCol(6, "500")
    }

    startLoadingImporter(msg := "") {
        CarregandoGUI( (msg  != "" ? msg : txt("Importando waypoints...", "Importing waypoints...")) )
        ; Gui, importWaypointGUI:+Disabled
        OldBotSettings.disableGuisLoading()
    }

    finishLoadingImporter() {
        if (this.newTabCreated = true) {
            this.newTabCreated := false
            gosub, CavebotGUI
        }
        Gui, Carregando:Destroy
        Gui, importWaypointGUI:-Disabled
        OldBotSettings.enableGuisLoading()
    }

    msgboxImporter(msg, title, icon := 48, timeout := 10) {
        this.finishLoadingImporter()
        Msgbox, % icon, % title, % msg, % timeout
    }


    checkCreateCurrentWaypointTab() {
        this.newTabCreated := false
        if (!waypointsObj.hasKey(this.tabName)) {
            try 
                CavebotScript.addScriptTab(this.tabName)
            catch e {
                this.msgboxImporter(e.Message, A_ThisFunc, icon := 48, timeout := 20)
                return false
            }
            this.newTabCreated := true
        }
        return true
    }

    importSelectedTab() {
        this.startLoadingImporter()
        GuiControlGet, scriptsTab
        this.tabName := scriptsTab
        if (this.checkCreateCurrentWaypointTab() = false)
            return false

        if (this.validateWaypoints() = false) {
            this.finishLoadingImporter()
            return false
        }

        this.lastWaypoint := WaypointHandler.getLastWaypoint(this.tabName)
        Loop, % this.scriptObj.waypoints[this.tabName].Count()
            WaypointHandler.add(this.scriptObj.waypoints[this.tabName][A_Index], this.tabName, save := false)

        this.afterAddWaypointsImporter()

        this.finishLoadingImporter()
        Msgbox, 64,, % txt("Waypoints da aba """ this.tabName """ importados com sucesso.", "Waypoints of tab """ this.tabName """ imported with success."), 10
    }

    afterAddWaypointsImporter(chooseTab := true) {
        WaypointHandler.saveWaypoints()

        CavebotGUI.loadLVsWaypoints()

        if (chooseTab = true) {
            if (this.newTabCreated = true) {
                this.newTabCreated := false
                gosub, CavebotGUI
            }
            CavebotGUI.chooseScriptTabByName(this.tabName)
        }

        Loop, % this.scriptObj.waypoints[this.tabName].Count()
            _ListviewHandler.selectRow("LV_Waypoints_" this.tabName, this.lastWaypoint + A_Index, defaultGUI := "CavebotGUI")
    }

    validateWaypoints() {

        /**
        first loop through all wayoints to validate
        */
        Loop, % this.scriptObj.waypoints[this.tabName].Count()
        {
            waypointObj := this.scriptObj.waypoints[this.tabName][A_Index]
            waypointAtributesObj := this.createWaypointAtributesObj(waypointObj.type, waypointObj.rangeX, waypointObj.rangeY)

            if (this.validateSingleWaypoint(waypointObj, A_Index) = false)
                return false
        }
    }

    validateSingleWaypoint(waypointAtributesObj, waypointNumber) {
        try validation := WaypointValidation.validateWaypoint(waypointAtributesObj, this.tabName, waypointNumber)
        catch e {
            if (e.What != "NotWalkable" && e.What != "TooFar") && (e.Message != "") {
                this.msgboxImporter("Waypoint: " waypointNumber ", tab: " this.tabName "`n" e.Message "`n" e.What, A_ThisFunc, icon := 48, timeout := 20)
                return false
            }
        }
        if (validation != "") {
            this.msgboxImporter("Waypoint: " waypointNumber ", tab: " this.tabName "`nValidation:" validation, A_ThisFunc, icon := 48, timeout := 20)
            return false
        }
    }

    importSelectedWaypoints() {

        this.startLoadingImporter()
        GuiControlGet, scriptsTab
        this.tabName := scriptsTab
        ; if (this.checkCreateCurrentWaypointTab() = false)
        ;     return false

        Gui, importWaypointGUI:Default
        Gui, ListView, LV_Waypoints_Import


        try selectedWaypoints := _ListviewHandler.getSelectedRowsLV("LV_Waypoints_Import", column := 1, defaultGUI := "importWaypointGUI", checked := true)
        catch e {
            this.msgboxImporter(e.Message, A_ThisFunc, icon := 48, timeout := 20)
            return false
        }

        for key, waypointNumber in selectedWaypoints
        {
            waypointObj := this.scriptObj.waypoints[this.tabName][waypointNumber]
            waypointAtributesObj := this.createWaypointAtributesObj(waypointObj.type, waypointObj.rangeX, waypointObj.rangeY)

            if (this.validateSingleWaypoint(waypointObj, waypointNumber) = false)
                return false
        }

        this.lastWaypoint := WaypointHandler.getLastWaypoint(tab)
        for key, waypointNumber in selectedWaypoints
            WaypointHandler.add(this.scriptObj.waypoints[this.tabName][waypointNumber], tab, save := false)

        this.afterAddWaypointsImporter(false)

        this.finishLoadingImporter()
        Msgbox, 64,, % selectedWaypoints.Count() " " txt("waypoints da aba """ this.tabName """ importados para a aba """ tab """.", "waypoints of tab """ this.tabName """ imported to tab """ tab """."), 10
    }

    selectWaypointImportTab() {
        this.startLoadingImporter(txt("Carregando waypoints...", "Loading waypoints..."))
        GuiControlGet, scriptsTab
        this.tabName := scriptsTab

        this.loadTabWaypoints(this.tabName)
        this.finishLoadingImporter()

    }

    selectAllWaypointsImport() {
        GuiControlGet, scriptsTab
        this.tabName := scriptsTab


        toggleCheckAllWaypoints := !toggleCheckAllWaypoints
        Loop, % this.scriptObj.waypoints[this.tabName].Count()
        {
            if (toggleCheckAllWaypoints = 1)
                _ListviewHandler.checkRow("LV_Waypoints_Import", A_Index, defaultGUI := "importWaypointGUI", focus := true)
            else 
                _ListviewHandler.uncheckRow("LV_Waypoints_Import", A_Index, defaultGUI := "importWaypointGUI")
        }


    }



}