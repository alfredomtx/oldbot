
global scriptNameSearch
global hscriptNameSearch

global ScriptListGUI_ICON_COUNTER := 0
global ScriptListGUI_ICONBUTTONS


/*
ini settings
*/
global higherMapTolerancyPositionSearch


Class _ScriptListGUI  {

    __New()
    {
        this.iconButtons := {}

        this.scriptListGUI := {}

        this.vocationList := {}
        this.vocationList.Push("All")
        this.vocationList.Push("Druid")
        this.vocationList.Push("Knight")
        this.vocationList.Push("Paladin")
        this.vocationList.Push("Sorcerer")


        this.functioningList := {}
        this.functioningList.Push("Coordinate")
        this.functioningList.Push("Marker")

        /**
        load clientlist from TibiaClient
        */
        this.clientList := {}
        ; m(serialize(TibiaClient.clientsJsonList))
        this.clientList.Push(TibiaClient.Tibia13Identifier)
        for key, value in TibiaClient.clientsJsonList
        {
            if (value.text = TibiaClient.Tibia13Identifier)
                continue
            ; if (value.text = "Senobra")
            ; m(serialize(value))
            switch value.text {
                case "Dolera Global":
                    continue
                default:
                    if(value.tibia12 = true) && (value.text != TibiaClient.Tibia13Identifier)
                    continue
                    ; if(value.tibia7x = true) && (value.text != TibiaClient.Tibia7xIdentifier)
                    ;     continue

            }

            this.clientList.Push(value.text)
        }
        this.clientList.Push("Other")

        this.vocationDropdown := ""
        for key, value in this.vocationList
            this.vocationDropdown .= value "|"

        this.clientDropdown := ""
        for key, value in this.clientList
            this.clientDropdown .= value "|"

        this.scriptFilters := {}
        this.scriptFilters.Push("scriptNameSearch")
        this.scriptFilters.Push("clientFilter")
        this.scriptFilters.Push("levelMinFilter")
        this.scriptFilters.Push("vocationFilter")
        this.scriptFilters.Push("functioningCoordinateFilter")
        this.scriptFilters.Push("functioningMarkerFilter")

        this.scriptFilters.Push("vocationAllFilter")
        this.scriptFilters.Push("vocationDruidFilter")
        this.scriptFilters.Push("vocationKnightFilter")
        this.scriptFilters.Push("vocationSorcererFilter")
        this.scriptFilters.Push("vocationPaladinFilter")


        this.scriptAtributes := {}
        this.scriptAtributes.Push("authorScriptAtribute")
        this.scriptAtributes.Push("levelScriptAtribute")
        this.scriptAtributes.Push("clientScriptAtribute")
        this.scriptAtributes.Push("functioningModeScriptAtribute")

        this.scriptAtributes.Push("vocationAllAtribute")
        this.scriptAtributes.Push("vocationDruidAtribute")
        this.scriptAtributes.Push("vocationKnightAtribute")
        this.scriptAtributes.Push("vocationSorcererAtribute")
        this.scriptAtributes.Push("vocationPaladinAtribute")

        this.readIniScriptListGlobalSettings()

        this.clientFilterString := "Client filter..."

    }

    destroyButtonIconsCavebotGUI() {
        ; m(A_ThisFunc)
        Loop, % ScriptListGUI_ICON_COUNTER {
            ; msgbox, % "a " ScriptListGUI_ICONBUTTONS%A_Index%
            IL_Destroy(ScriptListGUI_ICONBUTTONS%A_Index%)
            ScriptListGUI_ICONBUTTONS%A_Index% := ""
            ; msgbox, % "b " ScriptListGUI_ICONBUTTONS%A_Index%
        }

        ScriptListGUI_ICON_COUNTER := 0
    }

    ScriptListGUIButtonIcon(Handle, File, Index := 1, Options := "") {
        global
        RegExMatch(Options, "i)w\K\d+", W), (W="") ? W := 16 :
        RegExMatch(Options, "i)h\K\d+", H), (H="") ? H := 16 :
        RegExMatch(Options, "i)s\K\d+", S), S ? W := H := S :
        RegExMatch(Options, "i)l\K\d+", L), (L="") ? L := 0 :
        RegExMatch(Options, "i)t\K\d+", T), (T="") ? T := 0 :
        RegExMatch(Options, "i)r\K\d+", R), (R="") ? R := 0 :
        RegExMatch(Options, "i)b\K\d+", B), (B="") ? B := 0 :
        RegExMatch(Options, "i)a\K\d+", A), (A="") ? A := 4 :
        Psz := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"
        VarSetCapacity( button_il, 20 + Psz, 0 )
        NumPut( ScriptListGUI_ICONBUTTONS%ScriptListGUI_ICON_COUNTER% := DllCall( "ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1 ), button_il, 0, Ptr )   ; Width & Height
        NumPut( L, button_il, 0 + Psz, DW )     ; Left Margin
        NumPut( T, button_il, 4 + Psz, DW )     ; Top Margin
        NumPut( R, button_il, 8 + Psz, DW )     ; Right Margin
        NumPut( B, button_il, 12 + Psz, DW )    ; Bottom Margin 
        NumPut( A, button_il, 16 + Psz, DW )    ; Alignment
        SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %Handle%
        IL_Add( ScriptListGUI_ICONBUTTONS%ScriptListGUI_ICON_COUNTER%, File, Index )
        ScriptListGUI_ICON_COUNTER++
        ; msgbox, % ScriptListGUI_ICON_COUNTER
        ; return IL_Add( ScriptListGUI_ICONBUTTONS, File, Index )
        return
    }

    createScriptListGUI() {
        global
        _AbstractControl.SET_DEFAULT_GUI_NAME("ScriptListGUI")

        this.deleteButtonsFromMemory()

        this.scriptListGUI.width := 520
        ; this.scriptListGUI.height := 517
        this.scriptListGUI.height := 405 ; without filters
        this.scriptListGUI.controls := {}
        this.scriptListGUI.controls.listviewX := 15

        this.scriptListGUI.groupbox := {}
        this.scriptListGUI.groupbox.x := this.scriptListGUI.controls.listviewX
        this.scriptListGUI.groupbox.y := 30
        this.scriptListGUI.groupbox.height := 110


        this.scriptListGUI.controls.listviewWidth := this.scriptListGUI.width - 31
        this.scriptListGUI.controls.listviewHeight := 300
        ; this.scriptListGUI.controls.listviewY := this.scriptListGUI.groupbox.y + this.scriptListGUI.groupbox.height + 7
        this.scriptListGUI.controls.listviewY := 30 ; disabled script cloud and filters

        this.scriptListGUI.controls.listviewColumns := "#|Name|Level|Vocation|Mode|Client|Author (Discord)|Last Update|Uploaded"
        this.scriptListGUI.controls.listviewColumns := "#|Name"
        StrReplace(this.scriptListGUI.controls.listviewColumns, "|", "|", columnsCount)
        this.scriptListGUI.controls.listviewColumnCount := columnsCount

        this.filters := {}
        this.filters.LV_Scripts := {}
        this.filters.LV_ScriptsCloud := {}

        Gui, ScriptListGUI:Destroy
        ; Gui, ScriptListGUI:-Caption +Border

        Gui, ScriptListGUI:Add, Tab2, % "x7 y+5 w766 vScriptsListTab +Theme w" this.scriptListGUI.width - 12 " h" this.scriptListGUI.height - 10, % "Scripts"
        ; 
        Gui, ScriptListGUI:Tab, 1
        ; this.createScriptListFilters("LV_Scripts")
        this.scriptsListTab()

        ; Gui, ScriptListGUI:Tab, 2
        ; this.createScriptListFilters("LV_ScriptsCloud")
        ; this.scriptsCloudListTab()

        Gui, ScriptListGUI:Tab


        Gui, ScriptListGUI:Show, % "w" this.scriptListGUI.width " h" this.scriptListGUI.height, Scripts List
        _AbstractControl.RESET_DEFAULT_GUI()

        GuiControl, ScriptListGUI:Focus, scriptNameSearchLV_Scripts




        this.loadFiltersFromIni("LV_Scripts")
        ; this.loadFiltersFromIni("LV_ScriptsCloud")

        this.filterLV_Scripts("LV_Scripts")


    }


    loadFiltersFromIni(LV) {


        for key, filterName in this.scriptFilters
        {
            value := %filterName%%LV%
            if (value = "")
                continue
            ; m(filterName "`n" LV "`n" value)

            switch filterName {
                    /**
                    checkbox
                    */
                case "functioningCoordinateFilter", case "functioningMarkerFilter":
                    GuiControl, ScriptListGUI:, % filterName "" LV, % (value = true) ? 1 : 0
                    /**
                    checkbox vocations
                    */
                case "vocationAllFilter", case "vocationDruidFilter", case "vocationKnightFilter", case "vocationSorcererFilter", case "vocationPaladinFilter":
                    GuiControl, ScriptListGUI:, % filterName "" LV, % (value = true) ? 1 : 0
                    /**
                    edit
                    */
                case "levelMinFilter", case "levelMaxFilter":
                    GuiControlEdit("ScriptListGUI", filterName "" LV, value, "applyFilterScriptList")
                case "scriptNameSearch":
                    GuiControlEdit("ScriptListGUI", filterName "" LV, value, "SearchScript")
                    filterName := "name"
                    /**
                    dropdown
                    */
                case "clientFilter":
                    GuiControl, ScriptListGUI:ChooseString, % "clientFilter" LV, % (value = "") ? this.clientFilterString : value

            }
            this.applyFilterCondition(LV, StrReplace(filterName, "filter", ""), value, loadLV := false)
            ; this.filters[LV][filterName] := value

        }


        if (vocationAllFilter%LV% = 1) {
            GuiControl, ScriptListGUI:, % "vocationDruidFilter" LV, 1
            GuiControl, ScriptListGUI:Disable, % "vocationDruidFilter" LV
            GuiControl, ScriptListGUI:, % "vocationKnightFilter" LV, 1
            GuiControl, ScriptListGUI:Disable, % "vocationKnightFilter" LV
            GuiControl, ScriptListGUI:, % "vocationSorcererFilter" LV, 1
            GuiControl, ScriptListGUI:Disable, % "vocationSorcererFilter" LV
            GuiControl, ScriptListGUI:, % "vocationPaladinFilter" LV, 1
            GuiControl, ScriptListGUI:Disable, % "vocationPaladinFilter" LV
        }
    }

    loadScriptAtributesFromIni() {

        for key, atributeName in this.scriptAtributes
        {
            controlAtributeName := StrReplace(atributeName, "Atribute", "")
            GuiControlGet, %controlAtributeName%
            value := %controlAtributeName%

            ; m(controlAtributeName " = " value)
            if (value != "")
                continue

            value := %atributeName%
            ; m(controlAtributeName "`n" atributeName " = " value)
            if (value = "")
                continue

            switch controlAtributeName {
                    /**
                    checkbox
                    */
                    ; case "funciotning", case "functioningMarkerFilter":
                    ; GuiControl, ScriptAtributesGUI:, % controlAtributeName, % (value = true) ? 1 : 0
                    /**
                    checkbox vocations
                    */
                case "vocationAll", case "vocationDruid", case "vocationKnight", case "vocationSorcerer", case "vocationPaladin":
                    GuiControl, ScriptAtributesGUI:, % controlAtributeName, % (value = true) ? 1 : 0
                    /**
                    edit
                    */
                case "authorScript", case "levelScript":
                    GuiControlEdit("ScriptAtributesGUI", controlAtributeName, value, "saveScriptAtribute")
                    /**
                    dropdown
                    */
                case "clientScript", case "functioningModeScript":
                    GuiControl, ScriptAtributesGUI:ChooseString, % controlAtributeName, % (value = "") ? TibiaClient.Tibia13Identifier : value

            }
        }

    }

    createScriptListFilters(LV) {
        global 

        this.scriptListGUI.groupbox.width := 100

        this.scriptListGUI.groupbox.controls := {}
        this.scriptListGUI.groupbox.controls.editWidth := 100

        this.scriptListGUI.levelFilterGroupbox := {}
        this.scriptListGUI.levelFilterGroupbox.title := "Level Filter"
        this.scriptListGUI.levelFilterGroupbox.x := this.scriptListGUI.groupbox.x + this.scriptListGUI.groupbox.width + 10
        this.scriptListGUI.levelFilterGroupbox.width := 100
        this.scriptListGUI.levelFilterGroupbox.controls := {}
        this.scriptListGUI.levelFilterGroupbox.controls.width := this.scriptListGUI.levelFilterGroupbox.width - 20

        this.scriptListGUI.clientFilterGroupbox := {}
        this.scriptListGUI.clientFilterGroupbox.title := "Client Filters"
        this.scriptListGUI.clientFilterGroupbox.x := this.scriptListGUI.levelFilterGroupbox.x + this.scriptListGUI.levelFilterGroupbox.width + 10
        this.scriptListGUI.clientFilterGroupbox.width := 150
        this.scriptListGUI.clientFilterGroupbox.controls := {}
        this.scriptListGUI.clientFilterGroupbox.controls.width := this.scriptListGUI.clientFilterGroupbox.width - 20


        this.scriptListGUI.otherFiltersGroupbox := {}
        this.scriptListGUI.otherFiltersGroupbox.title := "Other Filters"
        this.scriptListGUI.otherFiltersGroupbox.x := this.scriptListGUI.clientFilterGroupbox.x + this.scriptListGUI.clientFilterGroupbox.width + 10
        this.scriptListGUI.otherFiltersGroupbox.width := 150
        this.scriptListGUI.otherFiltersGroupbox.controls := {}
        this.scriptListGUI.otherFiltersGroupbox.controls.width := this.scriptListGUI.otherFiltersGroupbox.width - 20




        this.scriptListGUI.featureFiltersGroupbox := {}
        this.scriptListGUI.featureFiltersGroupbox.title := "Feature Filters"
        this.scriptListGUI.featureFiltersGroupbox.x := this.scriptListGUI.otherFiltersGroupbox.x + this.scriptListGUI.otherFiltersGroupbox.width + 10
        this.scriptListGUI.featureFiltersGroupbox.width := 150
        this.scriptListGUI.featureFiltersGroupbox.controls := {}
        this.scriptListGUI.featureFiltersGroupbox.controls.width := this.scriptListGUI.featureFiltersGroupbox.width - 20


        Gui, ScriptListGUI:Add, Groupbox, % "x" this.scriptListGUI.groupbox.x " y" this.scriptListGUI.groupbox.y " w" this.scriptListGUI.groupbox.width " h" this.scriptListGUI.groupbox.height " Section", Vocation Filter

        for key, vocation in this.vocationList
        {
            y := A_Index = 1 ? this.scriptListGUI.groupbox.y + 20 : "+3"
            Gui, ScriptListGUI:Add, Checkbox, % "xs+10 y" y " vvocation" vocation "Filter" LV " gapplyFilterScriptList", % vocation
        }

        Gui, ScriptListGUI:Add, Groupbox, % "x" this.scriptListGUI.levelFilterGroupbox.x " y" this.scriptListGUI.groupbox.y " w" this.scriptListGUI.levelFilterGroupbox.width " h" this.scriptListGUI.groupbox.height " Section", % this.scriptListGUI.levelFilterGroupbox.title
        ; Gui, ScriptListGUI:Add, DDL, % "xp+0 y+3 w" this.scriptListGUI.groupbox.controls.editWidth " vvocationFilter" LV " gapplyFilterScriptList", % this.vocationDropdown
        ; GuiControl, ScriptListGUI:ChooseString, % "vocationFilter" LV, % "All"

        Gui, ScriptListGUI:Add, Text, % "xs+10 y" this.scriptListGUI.groupbox.y + 20, Level min:
        Gui, ScriptListGUI:Add, Edit, % "xp+0 y+3 h18 w" this.scriptListGUI.levelFilterGroupbox.controls.width " vlevelMinFilter" LV " Limit3 gapplyFilterScriptList 0x2000",

        Gui, ScriptListGUI:Add, Text, xs+10 y+10, Level max:
        Gui, ScriptListGUI:Add, Edit, % "xp+0 y+3 h18 w" this.scriptListGUI.levelFilterGroupbox.controls.width " vlevelMaxFilter" LV " Limit3 gapplyFilterScriptList 0x2000",



        Gui, ScriptListGUI:Add, Groupbox, % "x" this.scriptListGUI.otherFiltersGroupbox.x " y" this.scriptListGUI.groupbox.y " w" this.scriptListGUI.otherFiltersGroupbox.width " h" this.scriptListGUI.groupbox.height " Section", % this.scriptListGUI.otherFiltersGroupbox.title


        Gui, ScriptListGUI:Add, Text, % "xs+10 y" this.scriptListGUI.groupbox.y + 20, Cavebot Mode:
        Gui, ScriptListGUI:Add, Checkbox, % "xp+0 y+5 w" this.scriptListGUI.otherFiltersGroupbox.controls.width " vfunctioningCoordinateFilter" LV " gapplyFilterScriptList", % "Coordinate"
        Gui, ScriptListGUI:Add, Checkbox, % "xp+0 y+5 w" this.scriptListGUI.otherFiltersGroupbox.controls.width " vfunctioningMarkerFilter" LV " gapplyFilterScriptList", % "Marker"


        Gui, ScriptListGUI:Add, Groupbox, % "x" this.scriptListGUI.clientFilterGroupbox.x " y" this.scriptListGUI.groupbox.y " w" this.scriptListGUI.clientFilterGroupbox.width " h" this.scriptListGUI.groupbox.height " Section", % this.scriptListGUI.clientFilterGroupbox.title

        Gui, ScriptListGUI:Add, Checkbox, % "xs+10 y" this.scriptListGUI.groupbox.y + 20 " w" this.scriptListGUI.otherFiltersGroupbox.controls.width " vclientTibia12Filter" LV " gapplyFilterScriptList", % TibiaClient.Tibia13Identifier
        Gui, ScriptListGUI:Add, Checkbox, % "xp+0 y+5 w" this.scriptListGUI.otherFiltersGroupbox.controls.width " vclientTibia7xFilter" LV " gapplyFilterScriptList", % "Tibia 7.X"

        Gui, ScriptListGUI:Add, DDL, % "xp+0 y+5 w" this.scriptListGUI.clientFilterGroupbox.controls.width " vclientFilter" LV " gapplyFilterScriptList", % this.clientFilterString "||" A_Space "|" this.clientDropdown

        Gui, ScriptListGUI:Add, Groupbox, % "x" this.scriptListGUI.featureFiltersGroupbox.x " y" this.scriptListGUI.groupbox.y " w" this.scriptListGUI.featureFiltersGroupbox.width " h" this.scriptListGUI.groupbox.height " Section", % this.scriptListGUI.featureFiltersGroupbox.title

        Gui, ScriptListGUI:Add, Checkbox, % "xs+10 y" this.scriptListGUI.groupbox.y + 20 " w" this.scriptListGUI.featureFiltersGroupbox.controls.width " vfeatureDepositerFilter" LV " gapplyFilterScriptList Disabled", % "Depositer"
        Gui, ScriptListGUI:Add, Checkbox, % "xs+10 y+5 w" this.scriptListGUI.featureFiltersGroupbox.controls.width " vfeatureRefillerFilter" LV " gapplyFilterScriptList Disabled", % "Refiller"
        Gui, ScriptListGUI:Add, Checkbox, % "xs+10 y+5 w" this.scriptListGUI.featureFiltersGroupbox.controls.width " vfeature100afkFilter" LV " gapplyFilterScriptList Disabled", % "100% AFK"
        ; Gui, ScriptListGUI:Add, Checkbox, % "xs+10 y+5 w" this.scriptListGUI.featureFiltersGroupbox.controls.width " vfeatureSellLootFilter" LV " gapplyFilterScriptList Disabled", % "Sell Loot"



    }

    scriptsListTab() {
        global

        this.createScriptListLV("LV_Scripts")

        h_buttons := 35

        Gui, ScriptListGUI:Add, Button, % "x" this.scriptListGUI.controls.listviewX " y+2 w105 h" h_buttons " gLoadSelectedScript vLoadSelectedScript hwndLoadSelectedScript 0x1", % txt("&Carregar script", "&Load script")


        icon := _Icon.get(_Icon.CHECK)
        this.ScriptListGUIButtonIcon(LoadSelectedScript, icon.dllName, icon.number, "a0 l5 s16 b0")


        Gui, ScriptListGUI:Add, Button, x+3 yp+0 w70 h%h_buttons% gDeleteSelectedScript vDeletarScript_Button2 hwndDeletarScript_Button, % "&" txt("Deletar", "Delete")
        icon := _Icon.get(_Icon.DELETE)
        this.ScriptListGUIButtonIcon(DeletarScript_Button, icon.dllName, icon.number, "a0 l5 s16 b0")


        ; new _Button().title("&Upload script")
        ; .xadd(3).yp().w(100).h(h_buttons)
        ; .event("uploadSelectedScript")
        ; .icon(_Icon.get(_Icon.CLOUD), "a0 l5 s18 b0")
        ; .add()

        Gui, ScriptListGUI:Add, Button, x+3 yp+0 w55 h%h_buttons% gSaveScriptAsNew vSalvarScript_Button2 hwndSalvarScript_Button, % "&" txt("Salvar...", "Save...")
        Gui, ScriptListGUI:Add, Button, x+3 yp+0 w50 h%h_buttons% gOpenScript hwndAbrircurrentScript_Button, % txt("Abrir", "Open")
        Gui, ScriptListGUI:Add, Button, x+3 yp+0 w60 h%h_buttons% vCreateNewScript gCreateNewScriptFromMenu hwndhCreateNewScript, % "&" txt("Novo`nscript", "New`nscript")
        Gui, ScriptListGUI:Add, Button, x+3 yp+0 w60 h%h_buttons% gImportCavebotScript, % "&" txt("Importar`nscript", "Import`nscript")
        Gui, ScriptListGUI:Add, Button, x+3 yp+0 w70 h%h_buttons% gimportWaypointsLabel, % txt("Importar", "Import") "`n&Waypoints"

    }

    createScriptListLV(LV) {
        global

        Gui, ScriptListGUI:Add, Edit, % "x" this.scriptListGUI.controls.listviewX " y" this.scriptListGUI.controls.listviewY " w" this.scriptListGUI.controls.listviewWidth " vscriptNameSearch" LV " gSearchScript hwndhscriptNameSearch"
        SetEditCueBanner(hscriptNameSearch, LANGUAGE = "PT-BR" ? "Pesquisar script" : "Search script...")

        Gui, ScriptListGUI:Add, ListView, % "xp0 y+3 w" this.scriptListGUI.controls.listviewWidth " h" this.scriptListGUI.controls.listviewHeight " AltSubmit v" LV " g" LV " hwndh" LV " -Multi LV0x1 LV0x10", % this.scriptListGUI.controls.listviewColumns
    }

    scriptsCloudListTab() {
        global

        this.createScriptListLV("LV_ScriptsCloud")

        Gui, ScriptListGUI:Add, Button,% "x" this.scriptListGUI.controls.listviewX " y+5 w115 h" h_buttons " gDownloadSelectedScript vDownloadSelectedScript hwndDownloadSelectedScript", Download script
        this.ScriptListGUIButtonIcon(DownloadSelectedScript, "imageres.dll", 176, "a0 l2 s18 b0")


        Disabled := (loginEmail = "") ? "Disabled" : ""

        Gui, ScriptListGUI:Add, Button, x+3 yp+0 w100 h%h_buttons% gupdateScriptsList vupdateScriptList hwndhupdateScriptList %Disabled%, % txt("Atualizar lista", "Update list")
        this.ScriptListGUIButtonIcon(hupdateScriptList, "imageres.dll", (isWin11() = true) ? 230 : 229, "a0 l3 s16 t1")

        w := 165
        x := this.scriptListGUI.width - w - 18
        Gui, ScriptListGUI:Font, cGray
        Gui, ScriptListGUI:Add, Text, x%x% yp+3 vlastUpdatedScriptListDate w%w%, % "Last list update"
        Gui, ScriptListGUI:Font, 
    }

    filterLV_Scripts(LV := "LV_Scripts", debug := false) {
        this.loadLV_Scripts(LV, debug)
    }


    loadBothScriptLVs() {
        this.filterLV_Scripts("LV_Scripts")
        this.filterLV_Scripts("LV_ScriptsCloud")
    }

    loadLV_Scripts(LV, debug := false) {
        try {
            _ListviewHandler.loadingLV(LV, "ScriptListGUI")
        } catch {
            return
        }

        switch LV {
            case "LV_Scripts":
                Path := "Cavebot\*.json"
                Loop %Path% {

                    scriptName := StrReplace(A_LoopFileName, ".json", "")
                    if (scriptName = "")
                        continue

                    ; if (scriptName = "teste")
                    ;     debug := true
                    ; else 
                    ;     debug := false
                    if (this.checkLVFilters(LV, this.rowInfoScriptName(scriptName, debug), debug) = false)
                        continue

                    this.addScriptListRow(LV, scriptName)
                }

            case "LV_ScriptsCloud":
                for key, scriptInfo in scriptsList
                {
                    scriptName := scriptInfo.script_name
                    if (this.checkLVFilters(LV, this.rowInfoScriptName(scriptName, debug), debug) = false)
                        continue

                    this.addScriptListRow(LV, scriptName)
                }
        }

        Loop, % this.scriptListGUI.controls.listviewColumnCount {
            Gui, ListView, % LV
            LV_ModifyCol(A_Index, "autohdr")
        }

        LV_ModifyCol(2, 300) ; name
        LV_ModifyCol(8, 175) ; updated
        LV_ModifyCol(9, 130) ; uploaded
        _ListviewHandler.setColumnInteger(1, LV, "ScriptListGUI")
        _ListviewHandler.setColumnInteger(3, LV, "ScriptListGUI") ; level
        _ListviewHandler.setColumnInteger(8, LV, "ScriptListGUI")
        _ListviewHandler.setColumnInteger(9, LV, "ScriptListGUI")
    }

    addScriptListRow(LV, scriptName) {
        Gui, Listview, % LV
        LV_Add("", A_Index, scriptName, scriptsListByName[scriptName].script_level, this.rowVocation(scriptsListByName[scriptName].script_vocation), scriptsListByName[scriptName].script_functioning_mode, scriptsListByName[scriptName].script_client, scriptsListByName[scriptName].script_author, scriptsListByName[scriptName].script_date_updated, scriptsListByName[scriptName].script_date_added)
    }

    rowInfoScriptName(scriptName, debug := false) {
        scriptInfo := scriptsListByName[scriptName]
        if (debug)
            msgbox, % scriptName "`n" serialize(scriptInfo)
        return {"name": scriptName, "vocation": scriptInfo.script_vocation, "level": scriptInfo.script_level, "functioning": scriptInfo.script_functioning_mode, "client": scriptInfo.script_client}
    }

    rowVocation(vocation) {
        StringLower, vocation, vocation, T
        return vocation
    }

    checkLVFilters(LV, rowInfo, debug := false) {

        if (debug)
            msgbox, % serialize(this.filters[LV]) "`n`n" serialize(rowInfo)

        if (this.filters[LV].name != "") {
            if (!InStr(rowInfo.name, this.filters[LV].name))
                return false
        }

        if (this.filters[LV].client != "" && this.filters[LV].client != this.clientFilterString && this.filters[LV].client != " ") {
            if (rowInfo.client != this.filters[LV].client)
                return false
        }

        if (this.filters[LV].vocation.Count() > 0) {
            if (rowInfo.vocation = "")
                return false
            vocationFound := false
            ; msgbox, % serialize(this.filters[LV].vocation)

            for key, vocationFilter in this.filters[LV].vocation
            {
                if (vocationFilter = "All") {
                    vocationFound := true
                    break
                }
                ; msgbox, % key " = " vocationFilter
                if (InStr(rowInfo.vocation, vocationFilter)) {
                    vocationFound := true
                    break
                }
            }
            ; msgbox, % "vocationFound = " vocationFound
            if (vocationFound = false)
                return false
        }

        if (this.filters[LV].functioning.Count() > 0) {
            if (rowInfo.functioning = "")
                return false
            functioningFound := false
            ; msgbox, % serialize(this.filters[LV].functioning)

            for key, functioningFilter in this.filters[LV].functioning
            {
                if (functioningFilter = "All") {
                    functioningFound := true
                    break
                }
                ; msgbox, % key " = " functioningFilter
                if (InStr(rowInfo.functioning, functioningFilter)) {
                    functioningFound := true
                    break
                }
            }
            ; msgbox, % "functioningFound = " functioningFound
            if (functioningFound = false)
                return false
        }

        if (this.filters[LV].levelMin > 0) {
            if (rowInfo.level = "")
                return false
            if (rowInfo.level < this.filters[LV].levelMin)
                return false
        }

        if (this.filters[LV].levelMax > 0) {
            if (rowInfo.level = "")
                return false
            if (rowInfo.level > this.filters[LV].levelMax)
                return false
        }


        if (this.filters[LV].clientTibia12 = 1) {

            if (this.clientTypeFilter("Tibia12", rowInfo, rowInfo.client) = false)
                return false
        }

        if (this.filters[LV].clientTibia7x = 1) {
            if (this.clientTypeFilter("Tibia7X", rowInfo, rowInfo.client) = false)
                return false

        }

        return true
    }

    clientTypeFilter(filterType := "", rowInfo := "", clientIdentifier := "") {
        if (clientIdentifier = "")
            return false

        if (rowInfo.client = "")
            return false

        switch filterType {
            case "Tibia12":
                if (rowInfo.client != TibiaClient.Tibia13Identifier) {
                    ; msgbox, 16,, % serialize(rowInfo)
                    return false
                }
            case "Tibia7X":
        }

        for index, clientInfo in TibiaClient.clientsJsonList
        {
            if (clientInfo.text != rowInfo.client)
                continue
            switch filterType {
                case "Tibia12":
                    if (clientInfo.tibia12 = true) {
                        ; msgbox, 48,, % serialize(clientInfo) "`n`n" serialize(rowInfo)
                        return true
                    }
                case "Tibia7X":
                    if (clientInfo.tibia7x = true) {
                        ; msgbox, 48,, % serialize(clientInfo) "`n`n" serialize(rowInfo)
                        return true
                    }

            }
            ; msgbox, 64,, % serialize(clientInfo) "`n`n" serialize(rowInfo)

        }
        return false

    }

    manageScriptHandler(action := "") {
        switch action {
            case "delete":
            case "delete":
            case "delete":
            case "delete":
            case "delete":
        }
    }

    applyFilterCondition(LV, filterName := "", filterValue := "", loadLV := true) {

        ; msgbox, % LV "`n" filterName "`n" filterValue

        if (InStr(filterName, "vocation")) {
            ; vocationName := StrReplace(filterName, "vocation", "")
            this.filters[LV]["vocation"] := {}

            Gui, ScriptListGUI:Default
            for key, vocationFilter in this.vocationList
            {
                GuiControlGet, vocation%vocationFilter%Filter%LV%
                if (vocation%vocationFilter%Filter%LV% = 1)
                    this.filters[LV].vocation.Push(vocationFilter)
            }
            ; msgbox, % serialize(this.filters[LV].vocation)
            if (loadLV = true)
                this.filterLV_Scripts(LV, debug := false)
            return
        }

        if (InStr(filterName, "functioning")) {
            functioningName := StrReplace(filterName, "functioning", "")
            this.filters[LV]["functioning"] := {}

            Gui, ScriptListGUI:Default
            for key, functioningFilter in this.functioningList
            {
                GuiControlGet, functioning%functioningFilter%Filter%LV%
                if (functioning%functioningFilter%Filter%LV% = 1)
                    this.filters[LV].functioning.Push(functioningFilter)
            }
            ; msgbox, % serialize(this.filters[LV].functioning)
            if (loadLV = true)
                this.filterLV_Scripts(LV, debug := false)
            return
        }

        ; msgbox, % filterName " / " filterValue

        this.filters[LV][filterName] := filterValue

        if (loadLV = true)
            this.filterLV_Scripts(LV, debug := false)

    }

    createScriptAtributesGUI() {
        global

        selectedScript :=  _ListviewHandler.getSelectedItemOnLV("LV_Scripts", 2, "ScriptListGUI")
        if (selectedScript = "" OR selectedScript = "Name") {
            Msgbox, 64,, % txt("Selecione um script na lista.", "Select a script on the list."), 2
            return
        }

        if (selectedScript = "Default") {
            Msgbox, 48,, % "The ""Default"" script can't be uploaded.`nSave your script with another name and try again.", 6
            return
        }

        if (selectedScript = "")
            return

        this.ScriptAtributesGUI := {}
        this.ScriptAtributesGUI.controls := {}
        this.ScriptAtributesGUI.controls.width := 250

        ScriptCloud.uploadScriptName := selectedScript


        Gui, ScriptAtributesGUI:Destroy
        Gui, ScriptAtributesGUI:+AlwaysOnTop -MinimizeBox +Owner
        Gui, ScriptAtributesGUI:Default


        Gui, ScriptAtributesGUI:Add, Text, % "x10 y+5 w" this.ScriptAtributesGUI.controls.width, Script:
        Gui, ScriptAtributesGUI:Add, Edit, % "xp+0 y+3 h18 w" this.ScriptAtributesGUI.controls.width " Disabled -HScroll", % selectedScript



        Gui, ScriptAtributesGUI:Add, Text, % "x10 y+10 w" this.ScriptAtributesGUI.controls.width, % (LANGUAGE = "PT-BR" ? "Autor:" : "Author:") " (Discord Username)"
        Gui, ScriptAtributesGUI:Add, Edit, % "xp+0 y+3 h18 w" this.ScriptAtributesGUI.controls.width " vauthorScript gsaveScriptAtribute Limit20", % scriptsListByName[selectedScript].script_author

        Gui, ScriptAtributesGUI:Font, cGray
        Gui, ScriptAtributesGUI:Add, Text, % "x10 y+3 w" this.ScriptAtributesGUI.controls.width, % LANGUAGE = "PT-BR" ? "O campo ""Autor"" será seu identificador na lista do Script Cloud. Você deve usar seu nome de usuário do Discord, exemplo: OldBotUser#1234" : "The author field that will be your identifier in the Script Cloud List. You must use for your Discord Username, exempla: OldBotUser#1234"
        Gui, ScriptAtributesGUI:Font, norm
        Gui, ScriptAtributesGUI:Font,

        Gui, ScriptAtributesGUI:Add, Text, x10 y+10, Level:
        Gui, ScriptAtributesGUI:Add, Edit, % "xp+0 y+3 h18 w" this.ScriptAtributesGUI.controls.width " vlevelScript gsaveScriptAtribute 0x2000", % scriptsListByName[selectedScript].script_level



        x := 10


        Gui, ScriptAtributesGUI:Add, Text, x%x% y+10, % LANGUAGE = "PT-BR" ? "Vocação:" : "Vocation:"


        for key, vocation in this.vocationList
        {
            checked := 0

            for key2, scriptVocation in scriptsListByName[selectedScript].vocations
            {
                ; msgbox, % vocation " / " scriptVocation
                if (scriptVocation = vocation) {
                    checked := 1
                    break
                }
            }

            Gui, ScriptAtributesGUI:Add, Checkbox, % "x" x " y+3 vvocation" vocation " gselectVocationScript w" this.ScriptAtributesGUI.controls.width " checked" checked, % vocation

        }

        Gui, ScriptAtributesGUI:Add, Text, x%x% y+10, Client:
        Gui, ScriptAtributesGUI:Add, DropdownList, % "xp+0 y+3 w" this.ScriptAtributesGUI.controls.width " vclientScript gsaveScriptAtribute", % this.clientDropdown


        Gui, ScriptAtributesGUI:Add, Text, x%x% y+10, Cavebot Functioning Mode:
        Gui, ScriptAtributesGUI:Add, DropdownList, % "xp+0 y+3 w" this.ScriptAtributesGUI.controls.width " vfunctioningModeScript gsaveScriptAtribute", % "Coordinate|Marker"

        x := this.ScriptAtributesGUI.controls.width + 30
        Gui, ScriptAtributesGUI:Add, Text, x%x% y5, % LANGUAGE = "PT-BR" ? "Configurações para upload:" : "Settings to upload:"
        Gui, ScriptAtributesGUI:Add, Checkbox, % "x" x " y+3 gmoduleSelectAll vmoduleSelectAll w" this.ScriptAtributesGUI.controls.width " checked" Checked1, % LANGUAGE = "PT-BR" ? "Selecionar todas" : "Select all"

        this.objectsList := {}
        for key, module in CavebotScript.objectsList
        {
            if module in fullLight,reconnect,scriptVariables,scriptSettings
                continue

            this.objectsList.Push(module)
        }
        this.objectsList.Push("attackSpells")

        for key, module in this.objectsList
        {

            ; firstLetter := SubStr(module, 1, 1)
            ; StringUpper, firstLetter, firstLetter
            ; StringTrimLeft, functionText, module, 1
            ; functionText := firstLetter "" functionText

            Gui, ScriptAtributesGUI:Add, Checkbox, % "x" x " y+3 gmoduleUploadSelect vmodule" module " checked" Checked1, % module
        }

        Gui, ScriptAtributesGUI:Add, Button, % "x" x " y+15 w" this.ScriptAtributesGUI.controls.width " gsubmitUploadScript", Upload Script
        Gui, ScriptAtributesGUI:Show,, % LANGUAGE = "PT-BR" ? "Atributos do Script para upload" "Script upload atributes"

        try {
            GuiControl, ScriptAtributesGUI:ChooseString, clientScript, % scriptsListByName[selectedScript].script_client = "" ? A_Space : scriptsListByName[selectedScript].script_client
            GuiControl, ScriptAtributesGUI:ChooseString, functioningModeScript, % scriptsListByName[selectedScript].script_functioning_mode = "" ? "" : scriptsListByName[selectedScript].script_functioning_mode
        } catch {
        }


        this.afterScriptAtributeGUICreation()
    }

    afterScriptAtributeGUICreation() {

        this.loadScriptAtributesFromIni()

        GuiControlGet, vocationAll
        if (vocationAll = 1) {
            for key, vocation in this.vocationList
            {
                if (vocation = "All")
                    continue
                GuiControl, ScriptAtributesGUI:Disable, % "vocation" vocation
                GuiControl, ScriptAtributesGUI:, % "vocation" vocation, 1
            }
        }

        for key, module in this.objectsList
        {
            IniRead, moduleValue, %DefaultProfile%, script_upload, % module, %A_Space%
            if (moduleValue = "") {
                switch module {
                    case "alerts", case "healing", case "itemRefill", case "selectedFunctions", case "support", case "sioFriend", case "attackSpells":
                        moduleValue := 0
                    default:
                        moduleValue := 1

                }
            }
            GuiControl, ScriptAtributesGUI:, % "module" module, % moduleValue
        }


    }


    readIniScriptListGlobalSettings() {
        global 


        LV := "LV_Scripts"
        for key, filterName in this.scriptFilters
        {
            IniRead, %filterName%%LV%, %DefaultProfile%, script_list_filters, %filterName%%LV%, %A_Space%
            ; m(filterName " = " %filterName%)
        }

        LV := "LV_ScriptsCloud"
        for key, filterName in this.scriptFilters
        {
            IniRead, %filterName%%LV%, %DefaultProfile%, script_list_filters, %filterName%%LV%, %A_Space%
            ; m(filterName " = " %filterName%)
        }

        for key, atributeName in this.scriptAtributes
        {
            IniRead, %atributeName%, %DefaultProfile%, script_list_atributes, %atributeName%, %A_Space%
            ; m(filterName " = " %filterName%)
        }
    }

    getSelectedScript(showMsgbox := true) {
        selectedScript := _ListviewHandler.getSelectedItemOnLV("LV_Scripts", 2, "ScriptListGUI")
        if (selectedScript = "" OR selectedScript = "Name") {
            if (showMsgbox = true)
                Msgbox, 64,, % txt("Selecione um script na lista.", "Select a script on the list."), 2
            throw Exception("")
        }
        return selectedScript
    }



}
