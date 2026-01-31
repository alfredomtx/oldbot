global selectedWaypointColEdit
global selectedWaypointEdit

global w_LVWaypoints := 660
global LV_Waypoints_lines := 27
global LV_Waypoints_height := 502
global tabsHeight := LV_Waypoints_height + 40
global tabsWidth := 835

global x_groupbox_listview := 682
global h_groupbox_listview := LV_Waypoints_height + 4

global TT
global Tab_Script_Cavebot_IL := ""
global hTab_Script_Cavebot
global IMAGE_LIST_LV_Waypoints

global ID_VariaveisGUI
global IDWhereToStartGUI
global actionAddWaypointMarker
global imageAddWaypointMarker

global CavebotGUI_ICON_COUNTER := 0
global CavebotGUI_ICONBUTTONS

global DisabledShowWaypoints


global SET_START_MENU := txt("Setar como waypoint inicial", "Set as start waypoint")


IL_Destroy(Tab_Script_Cavebot_IL)  ; Required for image lists used by tab controls.
Tab_Script_Cavebot_IL := ""
Tab_Script_Cavebot_IL:=TAB_CreateImageList(14,14)

global ICON_SETTINGS := (isWin11() = true ) ? 315 : 317
IL_Add(Tab_Script_Cavebot_IL,"shell32.dll", ICON_SETTINGS)

IL_Add(Tab_Script_Cavebot_IL,"Data\Files\Images\GUI\Icons\running2.ico","")


/*
tooltip messages translations
*/
notScriptSettingScript := (LANGUAGE = "PT-BR" ? "`n`n*Configuração de Perfil, não é configuração de Script." : "`n`n*Profile setting, not a Script setting.")

tooltip_higherMapTolerancyPositionSearch := (LANGUAGE = "PT-BR" ? "Quando há diferenças em ""pixels pretos"" no minimapa de áreas não descobertas, isso geralmente causa problemas para detectar as coordenadas do personagem.`n`nAo marcar essa opção, é aumentado a tolerância dos pixels pretos, o que irá causar com que seja localizado as coordenadas do personagem em locais com diferenças no minimapa, mas também pode fazer com que fique menos preciso e detecte as coordenadas erradas." : "When there are ""black pixels"" differences in the minimap of areas not discovered, it usually causes problem to search the character coordinates.`n`nBy checking this option, it increases the tolerancy of the black pixels, which will cause to find the coordinates in places with differences in the minimap, but can also make it less accurate and find a wrong coordinates.") (notScriptSettingScript)

tooltip_cavebotFunctioningMode := (LANGUAGE = "PT-BR" ? "O modo de funcionamento ""Coordinates"", SEM A OPÇÃO ""injeção de memória"" marcada, funciona somente no " TibiaClient.Tibia13Identifier ", pois ele se baseia no minimapa ingame do jogo e um mapa interno do bot para localizar as coordenadas do personagem.`n`nO modo de ""Markers"" funciona em vários clientes diferentes, irá usar somente os Marcadores do minimapa ou imagens capturadas para caminhar pelo mapa.`nEsse modo também é mais limitado, várias funcionalidades e funções não estão disponíveis ou não funcionam no modo de Markers" : "The ""Coordinates"" functioning mode, WITHOUT THE OPTION ""memory injection"" checked, only works with " TibiaClient.Tibia13Identifier ", because it is based on the ingame minimap and an internal map of the bot to find the charater coordinates.`n`n""Markers"" mode works in many different clients, it will only use the minimap Markers or images taken to walk through the map.`nThis mode is also more limited, many features and functions won't be available or won't work on Markers mode.")


Class _CavebotGUI {

    __New()
    {
        this.selectedFunctions := {}
        this.selectedFunctionsOptions := {}


        func := {}
        func.name := "persistentsToggleAll"
        func.disabled := ""
        if (OldbotSettings.uncompatibleModule("persistent") = true)
            func.disabled := "Disabled"
        this.selectedFunctionsOptions.Push(func)

        for key, value in cavebotFunctions
        {
            func := {}
            func.name := value
            func.disabled := ""
            if (value = "cavebotEnabled") && (OldbotSettings.uncompatibleModule("cavebot") = true)
                func.disabled := "Disabled"
            this.selectedFunctionsOptions.Push(func)
        }

        for key, value in healingFunctions
        {
            func := {}
            func.name := value
            func.disabled := ""
            if (uncompatibleFunction("healing", value) = true)
                func.disabled := "Disabled"
            this.selectedFunctionsOptions.Push(func)
        }

        for key, value in itemRefillFunctions
        {
            func := {}
            func.name := value
            func.disabled := ""
            if (uncompatibleFunction("itemRefill", value) = true)
                func.disabled := "Disabled"
            this.selectedFunctionsOptions.Push(func)
        }

        for key, value in reconnectFunctions
        {
            func := {}
            func.name := value
            func.disabled := ""
            if (uncompatibleFunction("reconnect", value) = true)
                func.disabled := "Disabled"
            this.selectedFunctionsOptions.Push(func)
        }

        for key, value in supportFunctions
        {
            func := {}
            func.name := value
            func.disabled := ""
            if (uncompatibleFunction("support", value) = true)
                func.disabled := "Disabled"
            this.selectedFunctionsOptions.Push(func)
        }


        this.createWaypointListviewIcons()

    }

    PostCreateCavebotGUI() {
        global

        if (OldbotSettings.uncompatibleModule("cavebot") = true)
            return

        AutoShowWaypoints := 0
        ; CavebotGUI.loadLVsWaypoints(true)
    }

    startWaypointLV(waypointRow := "", oldStartWaypoint := "", oldStartTab := "") {
        if (waypointRow = "")
            return

        Gui, CavebotGUI:Default
        ; Gui, ListView, LV_Waypoints_%tab% ; commented on 25/04
        Gui, ListView, LV_Waypoints_%startTab%

        /**
        icons
        1: red
        2: orange
        3: yellow
        4: light green
        5: green
        6: lime green
        */

        LV_Modify(waypointRow, "Icon5")
        ; msgbox, % A_DefaultListview " / " startTab
        ; msgbox, % waypointRow ", " tab " | " IMAGE_LIST_LV_Waypoints
        if (oldStartTab = startTab) && (oldStartWaypoint = startWaypoint)
            return

        ; msgbox, % waypointRow "`n" oldStartTab " / " oldStartWaypoint "`n" startTab " / " startWaypoint
        /**
        remove the icon of the first waypoint
        in case for some reason more than one icon is remaining in the listview
        */
        if (startWaypoint != 1) {
            LV_Modify(1, "Icon" (scriptSettingsObj.cavebotFunctioningMode != "markers" ? "0" : this.setWaypointIcon(1, oldStartTab, waypointsObj[oldStartTab][1]) ))
        }
        if (oldStartTab != "" && oldStartWaypoint != "") {
            Gui, ListView, LV_Waypoints_%oldStartTab%
            LV_Modify(oldStartWaypoint, "Icon" this.setWaypointIcon(oldStartWaypoint, oldStartTab, waypointsObj[oldStartTab][oldStartWaypoint]))
        }
    }

    selectStartWaypoint(waypointRow := "", tabName := "", save := true)
    {
        if (waypointRow < 1)
            return

        oldStartWaypoint := startWaypoint
            , startWaypoint := waypointRow
            , oldStartTab := startTab
        if (tabName = "")
            tabName := startTab

        for key, value in ScriptTabsList
        {
            if (value = tabName) {
                this.setTabIcons(key + 1)
                break
            }
        }

        startTab := tabName
            , this.startWaypointLV(waypointRow, oldStartWaypoint, oldStartTab)
            , CavebotScript.setStartWaypoint(startWaypoint, false), CavebotScript.setStartTab(startTab, save)
    }

    getTabNumber(tabName) {
        for key, value in ScriptTabsList
        {
            if (value = tabName)
                return key
        }

    }

    createRenameTabGUI() {
        global
        if (ScriptTabsList.MaxIndex() <= 1) {
            msgbox, 64,, % LANGUAGE = "PT-BR" ? "Não há abas adicionais no script." : "There are no additional tabs in the script.", 3
            return
        }

        options := ""
        rows := 1
        for key, value in ScriptTabsList
        {
            if (value = "Waypoints")
                continue
            options .= value "|"
            rows++
        }
        if (rows > 15)
            rows := 15
        Gui, RenameTabGUI:Destroy
        Gui, RenameTabGUI: +AlwaysOnTop -MinimizeBox
        Gui, RenameTabGUI:Add, Text, x10 y+5, % LANGUAGE = "PT-BR" ? "Selecione a aba para renomear:" : "Select the tab to rename:"
        Gui, RenameTabGUI:Add, Listbox, gSelectTabRename vRenameTabSelected x10 y+3 w200 r%rows%, % options
        Gui, RenameTabGUI:Add, Text, x10 y+7, % LANGUAGE = "PT-BR" ? "Novo nome da aba de waypoints:" : "New tab name:"
        Gui, RenameTabGUI:Add, Edit, vRenameTabName gRenameTabName x10 y+3 w200 -VScroll -HScroll, %RenameTabName%
        Gui, RenameTabGUI:Add, Button, x10 y+5 w200 gRenameTabLabel 0x1, % LANGUAGE = "PT-BR" ? "Renomear aba" : "Rename tab"
        Gui, RenameTabGUI:Show,, % LANGUAGE = "PT-BR" ? "Renomear aba" : "Rename tab"
    }

    createNewTabGUI() {
        global



        Gui, NewTabGUI:Destroy
        Gui, NewTabGUI: +AlwaysOnTop -MinimizeBox
        Gui, NewTabGUI:Add, Text, x10 y+5, % LANGUAGE = "PT-BR" ? "Nome da aba de waypoints:" : "Waypoints tab name:"
        Gui, NewTabGUI:Add, Edit, vNewTabName gNewTabName x10 y+3 w160 -VScroll -HScroll, %NewTabName%
        Gui, NewTabGUI:Add, Button, x10 y+5 w160 0x1 gAddNewTabLabel, % LANGUAGE = "PT-BR" ? "Adicionar aba" : "Add tab"
        Gui, NewTabGUI:Show,, % LANGUAGE = "PT-BR" ? "Adicionar aba" : "Add tab"
    }

    createDeleteTabGUI() {
        global

        options := ""
        rows := 1
        for key, value in ScriptTabsList
        {
            options .= value "|"
            rows++
        }
        if (rows > 15)
            rows := 15


        Gui, DeleteTabGUI:Destroy
        Gui, DeleteTabGUI:+AlwaysOnTop -MinimizeBox

        Gui, DeleteTabGUI:Add, Text, x10 y+5, % "Select the tab to delete:"
        Gui, DeleteTabGUI:Add, Listbox, vDeleteTabName x10 y+3 w200 r%rows%, % options


        ; Gui, DeleteTabGUI:Add, Text, x10 y+7, % "Type ""confirm"" to delete the tab:"
        ; Gui, DeleteTabGUI:Add, Edit, vDeleteTabConfirmation hwndhDeleteTabConfirmation x10 y+3 w200 -VScroll -HScroll,
        ; SetEditCueBanner(hDeleteTabConfirmation, "confirm")

        Gui, DeleteTabGUI:Font, cRed
        Gui, DeleteTabGUI:Add, Text, x10 y+7 w200, % "All the waypoints of the tab will be deleted."
        Gui, DeleteTabGUI:Font,
        ; Gui, DeleteTabGUI:Add, Listview, x10 y+3 w200 r3 -VScroll -HScroll AltSubmit,

        Gui, DeleteTabGUI:Add, Button, x10 y+7 w200 0x1 gDeleteTabLabel hwndDeleteTabName_Button 0x1, % LANGUAGE = "PT-BR" ? "Deletar aba" : "Delete tab"
        ; switch A_OSVersion {
        ;     case "10.0.22000", case "10.0.22621": ; windows 11
        ;         iconNumber := 94
        ;     default:
        ;         iconNumber := 260
        ; }
        GuiButtonIcon(DeleteTabName_Button, "imageres.dll", 94, "a0 l5 s16 b0")
        Gui, DeleteTabGUI:Show,, % LANGUAGE = "PT-BR" ? "Deletar aba" : "Delete tab"
    }

    listviewColumnsCount() {
        return 6
    }

    listviewColumns() {

        return "WP|Type|Label|Coordinates|" (scriptSettingsObj.cavebotFunctioningMode = "markers" ? "SQM" : "Range") "|Action"
    }

    loadLVsWaypoints(selectStartWp := true) {
        if (CavebotScript.isMarker())
            this.createWaypointListviewIcons()

        for tabName, atributes in waypointsObj
            this.loadLV_Waypoints(tabName)
        if (selectStartWp = true)
            this.selectStartWaypoint(startWaypoint, startTab)

    }

    loadLV(tabName := "") {

        if (CavebotScript.isMarker())
            this.loadLVsWaypoints()
        else
            this.loadLV_Waypoints(tabName)
    }

    createWaypointListviewIcons() {
        IL_Destroy(IMAGE_LIST_LV_Waypoints)  ; Required for image lists used by tab_name controls.
        IMAGE_LIST_LV_Waypoints := ""
        IconWidth      := (CavebotScript.isMarker()) ? 24 : 18
            , IconHeight   := (CavebotScript.isMarker()) ? 24 : 18
            , IconBitDepth := 32 ;
            , InitialCount :=  1 ; The starting Number of Icons available in ImageList
            , GrowCount    :=  1

        IMAGE_LIST_LV_Waypoints  := DllCall( "ImageList_Create", Int,IconWidth,    Int,IconHeight
            , Int,IconBitDepth, Int,InitialCount
            , Int,GrowCount )

        Loop 6 {
            if (A_Index = 5) {
                IL_Add(IMAGE_LIST_LV_Waypoints,"Data\Files\Images\GUI\Icons\running2.ico", 1)
                continue
            }
            IL_Add(IMAGE_LIST_LV_Waypoints, "Data\Files\Images\GUI\scale-circ.icl", A_Index)
        }

        if (CavebotScript.isMarker()) {
            Loop 20 {
                marker := ImagesConfig.minimapMarkersFolder "\GUI\mark" A_Index ".png"
                ; if (!FileExist(marker))
                ; msgbox, % marker
                IL_Add(IMAGE_LIST_LV_Waypoints, marker, 0xFFFFFF, 1)  ; 0xFFFFFF to use with imanges insted of icons
            }
        }

        for tabName, waypoints in waypointsObj
        {
            for key, waypointObj in waypoints
            {
                if (waypointObj.image = "") {
                    IL_Add(IMAGE_LIST_LV_Waypoints, "Data\Files\Images\GUI\scale-circ.icl", 1) ; red icon as place holder for waypoint with no image
                    continue
                }
                ; msgbox, % lastRow

                pBitmap := GdipCreateFromBase64(waypointObj.image)
                    , hBitmap:=Gdip_CreateHBITMAPFromBitmap(pBitmap)
                    , IL_Add(IMAGE_LIST_LV_Waypoints , "HBITMAP:" hBitmap, 0xFFFFFF, 1)  ; 0xFFFFFF to use with imanges insted of icons
                    , Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap), pBitmap := "", hBitmap := ""
            }
        }


    }

    loadLV_Waypoints(waypointTabName := "") {
        global

        if (waypointTabName = "")
            waypointTabName := tab
        Gui, CavebotGUI:Default
        prefix := tab_name "_"
        ; msgbox, % "tab_name = '" tab_name "'`nprefix = '" prefix "'"

        try {
            _ListviewHandler.loadingLV("LV_Waypoints_" waypointTabName)
        } catch {
            return
        }


        LV_SetImageList( IMAGE_LIST_LV_Waypoints, 1 ) ; 0 for large icons, 1 for small icons
        ; msgbox, % waypointTabName "`n`n" serialize(waypointsObj[waypointTabName])

        ; isOwner := ScriptRestriction.isScriptOwner()
        try CavebotScript.isEncryptedScript(currentScript)
        catch e {
            Msgbox, 48, % A_ThisFunc,  % e.Message "`n" e.What "`n" e.File "`n" e.Line
            return false
        }

        encryptedScript := CavebotScript.isEncrypted

        ; LV_Waypoints_%waypointTabName%_Colors.Clear()
        Loop, % waypointsObj[waypointTabName].Count()
        {
            ; msgbox, % "A_Index = " A_Index "`nActionWP = " action "`ntab_name = " waypointTabName
            waypointObj := waypointsObj[waypointTabName][A_Index]
                , type := waypointObj.type
                , label := waypointObj.label
                , coordinates := (CavebotScript.isMarker()) ? "Marker: " (waypointObj.marker = "" ? "none" : waypointObj.marker) : "x:" waypointObj.coordinates.x ", y:" waypointObj.coordinates.y ", z:" waypointObj.coordinates.z
                , range := (CavebotScript.isMarker()) ? this.sqmText(waypointObj.sqm) : WaypointHandler.getDisplayRangeSize(A_Index, waypointTabName)
                , action := StrReplace(waypointObj.action, "<br>", "  ")
            if (StrLen(action) > 100) {
                bigActionWidth := true
            }

            waypointIcon := this.setWaypointIcon(A_Index, waypointTabName, waypointObj)

            Gui, ListView, LV_Waypoints_%waypointTabName%
            LV_Add("Icon" waypointIcon, "" A_Index, type, label, coordinates, range, this.actionStringRow(A_Index, type, action) ) ; no icon

            if (A_Index > 1) && (WaypointHandler.isWaypointTooFarFromPrevious(waypointTabName, A_Index, waypointObj.coordinates.x, waypointObj.coordinates.y, waypointObj.coordinates.z, type, false, false) = true) {
                Gui, ListView, LV_Waypoints_%waypointTabName%
                LV_Modify(A_Index, "Icon1") ; red
            }

            if (A_Index = startWaypoint) && (waypointTabName = startTab) {
                Gui, ListView, LV_Waypoints_%waypointTabName%
                LV_Modify(A_Index, "Icon5")
            }

        }

        _ListviewHandler.setColumnInteger(1, "LV_Waypoints_" waypointTabName)

        Loop, % this.listviewColumnsCount()
        {
            Gui, ListView, LV_Waypoints_%waypointTabName%
            LV_ModifyCol(A_Index, "autohdr")
        }
        if (bigActionWidth = true)
            LV_ModifyCol(6, "500")

        if (CavebotScript.isCoordinate()) {
            LV_ModifyCol(1, 43)

        } else {
            LV_ModifyCol(1, 53)
        }



        ; if (setStartWaypoint = true) && (waypointTabName = startTab)
        ; this.startWaypointLV(startWaypoint)

        return
    }

    actionStringRow(waypointNumber, type, action := "") {
        if (CavebotScript.isEncrypted = false) OR (action = "")
            return action
        if (ScriptRestriction.isScriptOwner() = true)
            return action
        if (WaypointValidation.validateType(type) != "")
            return txt("@Warning: Type do waypoint é inválido para o cliente atual.", "@Warning: invalid waypoint Type for current client.")

        restricedString := txt("... script restrito ...", "... restricted script ...")

        return (WaypointHandler.getAtribute("actionAddedByUser", waypointNumber) = true) ? action : restricedString
    }

    setWaypointIcon(waypointNumber, waypointTabName, waypointObj) {
        if (waypointObj.image != "") {
            ; msgbox, % serialize(waypointObj)  "`n`n" this.getWaypointImageIconNumber(waypointNumber)

            ; text := waypointNumber ", " waypointTabName " @ " this.getWaypointImageIconNumber(waypointNumber, waypointTabName)
            ; OutputDebug(text)
            ; msgbox, %

            return this.getWaypointImageIconNumber(waypointNumber, waypointTabName)
        }
        if (waypointObj.marker = "")
            return "0"
        ; msgbox, % serialize(waypointObj)  "`n`n" this.getMarkerIconNumber(waypointObj.marker)
        return this.getMarkerIconNumber(waypointObj.marker)
    }

    sqmText(sqmNumber) {
        switch sqmNumber {
            case 1:
                return "SW"
            case 2:
                return "S"
            case 3:
                return "SE"
            case 4:
                return "W"
            case 5:
                return "C"
            case 6:
                return "E"
            case 7:
                return "NW"
            case 8:
                return "N"
            case 9:
                return "NE"
            default:
                return "----"

        }

    }

    getMarkerIconNumber(markerNumber) {
        return 6 + markerNumber  ; marker icons starts in position 6
    }


    getWaypointImageIconNumber(waypointNumber, waypointTabName) {


        initialNumber := 6 + 20  ; marker icons starts in position 6, and there are  20 markers
        for tabName, waypoints in waypointsObj
        {
            if (waypointTabName = tabName)
                break

            initialNumber += waypointsObj[tabName].Count()
        }

        return initialNumber + waypointNumber
    }

    createCavebotIcons() {
        global

        TAB_SetImageList(hTab_Script_Cavebot,Tab_Script_Cavebot_IL)
    }

    setTabIcons(tabNumber)
    {
        global
        ; static tabIcons := {}
        ; if (tabIcons[tabNumber]) {
        ;     return
        ; }

        ; tabIcons[tabNumber] := true

        /**
        adicionar icones as tabs
        */
        Loop, % ScriptTabsList.Count() + 1 {
            if (A_Index = 1) {
                TAB_SetIcon(hTab_Script_Cavebot,A_Index,1)
                continue
            }
            if (A_Index = tabNumber)
                continue
            TAB_SetIcon(hTab_Script_Cavebot, A_Index,0)
        }

        TAB_SetIcon(hTab_Script_Cavebot, tabNumber,2)
        ; if (tabNumber > 1)
        ; TAB_SetIcon(hTab_Script_Cavebot,2,1)
        ; TAB_SetIcon(hTab_Script_Cavebot,2,2)
        ; TAB_SetIcon(hTab_Script_Cavebot,2,3) ; use the third image of the  of the ImageList created
        ;-- (Slightly) increase the height of the tabs
        ;   ##### Experimental.  This is done so that icon fits comfortably within each
        ;   tab.
        TAB_SetItemSize(hTab_Script_Cavebot,1,20)
        GUIControl,,% hTab_Script_Cavebot
        TAB_GetDisplayArea(hTab_Script_Cavebot,DisplayAreaX,DisplayAreaY,DisplayAreaW,DisplayAreaH)
        ControlW :=DisplayAreaW-(MarginX*2)
    }

    getScriptTabNumber(tabName) {
        for key, value in ScriptTabsList
        {
            if (value = tabName) {
                return key + 1 ; the first tab is the Script Settings tab
            }
        }
        return false

    }

    chooseScriptTabByName(tabName) {

        tabNumber := this.getScriptTabNumber(tabName)
        if (tabNumber = false)
            return false

        GuiControl, CavebotGUI:Choose, Tab_Script_Cavebot, % tabNumber
        tab := tabName
        tab_prefix := tabName "_"
        return true
    }


    createTabControl(childtabs) {
        global
        w := w_LVWaypoints + 17

        ; for para escolher a tab corretamente
        ChooseTabScript := this.getScriptTabNumber(tab)

        Gui, CavebotGUI:Add, Tab2, x6 y23 w%tabsWidth% h%tabsHeight% vTab_Script_Cavebot gScriptTabsNavigation hWndhTab_Script_Cavebot %TabStyle% Choose%ChooseTabScript% +Theme -Wrap, % child_tabs_%main_tab%
        ; GuiControl, CavebotGUI:Choose, Tab_%main_tab%, Waypoints ; selecionar a tab Waypoints como padrão
        if (load_order[1] != main_tab)
            GuiControl, Hide, Tab_Script_Cavebot ; esconder a tab antes de adicionar os elementos a ela


        if (OldbotSettings.uncompatibleModule("cavebot") = true) {
            return
        }

        this.createCavebotIcons()
        ; for some reason they are both image lists are getting the same value and so messing with the tab icons
        While (Tab_Script_Cavebot_IL = IMAGE_LIST_LV_Waypoints) {
            Tooltip, % "Loading " A_Index "..."
            Sleep, 100
            this.createCavebotIcons()
            if (A_Index > 5) {
                break
            }
        }
        Tooltip

        for key, value in ScriptTabsList
        {
            if (value = startTab) {
                tabNumber := key + 1
                break
            }
        }
        this.setTabIcons(startTab = "" ? 99 : tabNumber)
    }

    createCavebotGUI() {
        global

        ; if (OldbotSettings.uncompatibleModule("cavebot") = true) {
        ;     _GuiHandler.uncompatibleModuleWarning()
        ;     return
        ; }
        main_tab := "Cavebot"
        /**
        1 - criar as "childs" da tab Waypoints
        */
        child_tabs_%main_tab% := ("Script Settings|") ScriptTabsListDropdown "|+"

        this.createTabControl(child_tabs_%main_tab%)




        Loop, parse, child_tabs_%main_tab%, |
        {
            current_child_tab := A_LoopField
            if (current_child_tab = "" OR current_child_tab = "+")
                continue

            try Gui, CavebotGUI:Tab, %current_child_tab%
            catch {
                msgbox, 16,, % txt("Falha ao criar a aba :" current_child_tab "`nPor favor contate o suporte.", "Failed to create the tab: " current_child_tab "`nPlease contact support.")
            }

            if ((IsSettingScriptTab(current_child_tab) = true)) {
                this.createScripterSettings()
                continue
            }

            this.createLVWaypoints(current_child_tab)
            /**
            aqui ao invés do gosub teria que criar e popular o Listview com os waypoints de cada Tab do Script
            */
        }

        /**
        1 - criar as "childs" da tab Cavebot
        */

        use_icon := false
        if (use_icon = true) {
            ;-- Create and populate image list
            Tab_Cavebot_IL:=TAB_CreateImageList(16,16)
            IL_Add(Tab_Cavebot_IL,"ieframe.dll", 35)
            IL_Add(Tab_Cavebot_IL, "Data\Files\Images\GUI\icons\icon_tibia.png", 1)
            IL_Add(Tab_Cavebot_IL,"shell32.dll", 317)
        }
        ; se o choose for da aba de configurações
        ; if (ChooseTabScript = 1)

        ; Gosub, ScriptTabsNavigation

        this.createTooltips()
    }

    createLVWaypoints(tabName) {
        global

        if (OldbotSettings.uncompatibleModule("cavebot") = true) {
            _GuiHandler.uncompatibleModuleWarning()
            return
        }


        try {
            Gui, CavebotGUI:Add, ListView, x15 y+6 h%LV_Waypoints_height% w%w_LVWaypoints% AltSubmit Grid NoSort NoSortHdr gLV_Waypoints_tab vLV_Waypoints_%tabName% hwndhLV_Waypoints_%tabName% LV0x10, % this.listviewColumns()
        }
        catch e {
            Msgbox, 16,, % e.Message "`n" e.Where
            return
        }

        Gui, CavebotGUI:Default
        Gui, ListView, LV_Waypoints_%tabName%

        LvHandle_%tabName% := ""
        LvHandle_%tabName% := New LV_Rows(hLV_Waypoints_%tabName%)
    }



    createScriptSettingsGUI() {
        global
        ; WinClose, ahk_id %ID_VariaveisGUI%
        ; OnMessage(0x115, "OnScroll") ; WM_VSCROLL

        ; OnMessage(0x114, "OnScroll") ; WM_HSCROLL

        if (WinExist("ahk_id " ID_VariaveisGUI)) {
            Gui, %ID_VariaveisGUI%:Default
            Gui, Destroy
        }

        Gui, New
        Gui, +0x300000 ; WS_VSCROLL | WS_HSCROLL

        w_gui := 830

        ; Gui, -MinimizeBox

        ; Gui, Add, Button, x65 y0 w135 h20 vSalvarVariaveisButton gSalvarVariaveisNewFromVariaveisGUI hwndSalvarVariaveis_Button, % LANGUAGE = "PT-BR" ? "Salvar configurações" : "Save settings"
        ;     GuiButtonIcon(SalvarVariaveis_Button, "shell32.dll", 297, "a0 l2 s16")

        this.ScriptSettingsTab()

        creatingGUI := true
        try this.createScripterSettingsElements()
        catch e {
            creatingGUI := false
            Msgbox, 48,, % e.Message "`n" e.What "`n" e.Extra "`n" e.Line "`n" e.File
        }
        Gui, Tab

        Gui, Add, Button, x691 y1  w110 h22 gScriptVariablesJsonGUI hwndVariavesScript_Button %DisabledBlockEdit%, % LANGUAGE = "PT-BR" ? "Editar User Options" : "Edit User Options"
        ; GuiButtonIcon(VariavesScript_Button, "ieframe.dll", 37, "a0 l3 s14")


        ; if (!A_IsCompiled)
        ; Gui, Show, x750 y1120 w%w_gui% h500,% LANGUAGE = "PT-BR" ? "Configurações do script - " currentScript : "Script settings - " currentScript
        ; else
        Gui, Show, w%w_gui% h500,% LANGUAGE = "PT-BR" ? "Configurações do script - " currentScript : "Script settings - " currentScript

        Gui, +LastFound

        ID_VariaveisGUI := WinExist()


        for key, value in groupboxesNoName
            string .= "- " value "`n"

        if (groupboxesNoName.MaxIndex() > 0) {
            Msgbox, 64,, % "Some Groupboxes where not created because they have no ""name"" atribute, groupboxes text:`n" string
        }
        creatingGUI := false

        ; GuiControl, +gnodeRange, nodeRange
        GuiControl, +gstartWaypoint, startWaypoint

    }

    getElementHeightRow(rows) {
        if (rows > 1)
            height := 25 * rows
        else
            height := 25
        if (height > 300)
            height := 300
        return height
    }

    createScripterSettingsElements() {
        global



        x_base := 275
        w_tab := 513 + 15

        x1 := x_base
        x2 := x_base + 15

        x_button := x2 + 50 ; botão de mostrar configurações adicionais


        Gui, Add, Tab3, x1 y5 x%x1% w%w_tab%  +Theme, % "Script Setup"

        Gui, Tab, 1

        DisabledBlockEdit := (DisableEditScript = 1) ? "Disabled" : ""

        w_groupbox := 245

        w_textandcheckbox := w_groupbox - 20


        x_groupbox_column1 := x2


        w_text := 110

        w_field := 110

        BlockNameEdit := true
        ReadOnly := (BlockNameEdit = true) ? "ReadOnly" : ""

        Error = 0
        variable_counter = 1
        line_value := {}

        glabel := "SubmitScriptVariableControl"


        groupboxesToCreate := {}
        groupboxesColumn1 := {}
        groupboxesColumn2 := {}

        groupboxesNoName := {}
        for key, groupName in scriptVariablesObj
        {
            if (groupName.name = "") {
                groupboxesNoName.Push(groupName.Text)
                continue
            }
            if (groupName.column = 2)
                groupboxesColumn2.Push(groupName)
            else
                groupboxesColumn1.Push(groupName)
        }
        for key, groupName in groupboxesColumn1
            groupboxesToCreate.Push(groupName)

        for key, groupName in groupboxesColumn2
            groupboxesToCreate.Push(groupName)

        ; m(serialize(groupboxesToCreate)) s


        /**
        calculating the groupbox height
        base on the elements on it
        */
        for key, groupObj in groupboxesToCreate
        {
            groupboxesToCreate[key].height := 30 ; base height of a groupbox
            ; Msgbox, % groupboxesToCreate[key].height "`n"  key " / " groupObj

            for key2, element in groupObj.children
            {
                switch element.type {
                    case "combobox", case "hotkey", case "lineedit", case "number", case "supply":
                        controlHeight := 29
                    case "checkbox", case "text":
                        controlHeight := this.getElementHeightRow(element.rows)
                    default:
                        msgbox, 48,, % "Invalid control type:`n- Group: " groupObj.Name "`n- Type: " element.type
                }

                groupboxesToCreate[key].height += controlHeight
                ; msgbox, % "element:`n" serialize(element) "`n`nGroup " groupObj.Name " = " groupboxesToCreate[key].height
                ; Msgbox, % "element " element.name " = " element.type "`nGroup " groupObj.Name " = " groupboxesToCreate[key].height "`n" key " / " groupboxesColumn1.Count() " elements"
            }
            ; Msgbox, % "final" groupboxesToCreate[key].height "`n" serialize(element)

        }

        indexColumn := {}

        indexColumn[1] := 1
        indexColumn[2] := 1
        for key1, groupName in groupboxesToCreate
        {
            /**
            name: The name of the widget. It's used to retrieve its current value.
            text: The title of the group box; if none is provided, name is used.
            description: The description to be displayed on info box; if none is provided, text is used.
            column: The column the group box should be place on; 1 for first column, 2 for second.
            children: The widgets the group box will contain.
            rows: size in rows of the control, only for Text and Checkbox.
            */
            ; msgbox, % key1 " = " serialize(groupName)
            groupHeight := groupName.height
            groupName.column := groupName.column = "" ? 1 : groupName.column
            ; msgbox, % groupHeight "/" groupName.name " = " groupName.children.Count() "`n`n" serialize(groupName)
            ; m(indexColumn[groupName.column] " `n " groupName.name " `n " groupName.column)



            y_groupbox := (indexColumn[groupName.column] = 1) ? "35" : "+20"
            x_group := x_groupbox_column1

            switch groupName.column {
                case 2:
                    x_groupbox_column2 := x_group + w_groupbox + 7
                    x_group := x_groupbox_column2
            }

            ; msgbox, % x_group " / " y_groupbox " / " y_groupbox " / " groupHeight
            if (groupHeight = "") {
                throw Exception("Wrong groupbox height.`n`nGroupbox name: " groupName.name "`nText: " groupName.text)
            }
            try Gui, Add, Groupbox, x%x_group% y%y_groupbox% w%w_groupbox% h%groupHeight% Section, % groupName.text != "" ? groupName.text : groupName.name
            catch {
                ; Msgbox, 48,, % "Error creating groupbox, check if groupbox.name is duplicated.`n`nName: " groupName.name "`nText: " groupName.text
                throw Exception("Error creatingGUIng groupbox, check if groupbox.name is duplicated.`n`nName: " groupName.name "`nText: " groupName.text)
            }

            indexColumn[groupName.column]++
            for key2, element in groupName.children
            {
                /**
                name: The name of the widget. It's used to retrieve its current value.
                text: The title of the group box; if none is provided, name is used.
                description: The description to be displayed on info box; if none is provided, text is used.
                column: The column the group box should be place on; 1 for first column, 2 for second.
                children: The widgets the group box will contain.
                */
                if (element.type != "text") && (element.name = "")
                    continue
                ; msgbox, % "element " key2 " = " serialize(element)

                y := A_Index = 1 ? "p+25" : "+10"
                x2 := "s+10"

                /**
                text element has no variable name
                */
                if (element.type != "text")
                    variableName := "__" groupName.name "__" element.name


                /**
                elements that have a text
                */
                switch element.type {
                    case "text":
                        r := (element.rows > 1 && element.rows < 10) ? element.rows : 1
                        h := 20 * r
                        try Gui, Add, Text, x%x2% y%y% w%w_textandcheckbox% h%h% , % element.text
                        catch {
                        }
                        variable_counter++
                        continue
                    case "checkbox":
                        ; msgbox, % element.name "`n" variableName "`n'" element.value "'`n`n" items
                        r := (element.rows > 1 && element.rows < 10) ? element.rows : 1
                        /**
                        - 3 to ajust, because a groupbox with 3 checkbox is not fitting the checkboxes
                        */
                        h := 16 * r
                        checked := element.value = "1" ? 1 : 0
                        try Gui, Add, Checkbox, x%x2% y%y% w%w_textandcheckbox% h%h% v%variableName% hwndh%variableName% g%glabel% Checked%checked%, % element.text
                        catch {
                        }
                        TT.Add(h%variableName%, element.description = "" ? txt("Sem descrição", "No description") : element.description)

                        variable_counter++
                        continue
                }


                try Gui, Add, Text, x%x2% y%y% w%w_text% h20 %ReadOnly%, % element.text != "" ? element.text : element.name
                catch {
                }

                switch element.type {

                    case "lineedit":
                        try Gui, Add, Edit, x+4 yp-2 h20 w%w_field% v%variableName% hwndh%variableName% g%glabel%, % element.value
                        catch {
                        }
                        TT.Add(h%variableName%, element.description = "" ? txt("Sem descrição", "No description") : element.description)

                    case "number":
                        try Gui, Add, Edit, x+4 yp-2 h20 w%w_field% v%variableName% hwndh%variableName% g%glabel% 0x2000, % element.value
                        catch {
                        }
                        TT.Add(h%variableName%, element.description = "" ? txt("Sem descrição", "No description") : element.description)
                        try Gui, Add, UpDown, 0x80 Range1-9999999999, % element.value
                        catch {
                        }

                    case "hotkey":
                        try Gui, Add, Hotkey, x+4 yp-2 h20 w%w_field% v%variableName% hwndh%variableName% g%glabel% 0x2000, % element.value
                        catch {
                        }
                        TT.Add(h%variableName%, element.description = "" ? txt("Sem descrição", "No description") : element.description)

                    case "supply", case "combobox":
                        if (element.type = "combobox" && (IsObject(element.items))) {

                            items := ""
                            for key, value in element.items
                                items .= value "|"

                            try Gui, Add, DDL, x+4 yp-2 w%w_field% v%variableName% hwndh%variableName% g%glabel%, % items
                            catch {
                            }
                            TT.Add(h%variableName%, element.description = "" ? txt("Sem descrição", "No description") : element.description)
                            ; msgbox, % element.name "`n" variableName "`n'" element.value "'`n`n" items
                            try GuiControl, ChooseString, %variableName%, % element.value
                            catch {
                            }
                            variable_counter++
                            continue
                        }

                        /**
                        to do: create better filter, with search filter, for example, words with the word "rune" on it.
                        */
                        if (element.filter = "")
                            items := potionAndSupplyListdropdown
                        else {
                            if (IsObject(element.filter)) {
                                items := ItemsHandler.getItemList(filterNames := "", element.filter)
                            } else {
                                switch element.filter {
                                    case "potion":          items := potionListDropdown
                                    case "supply":          items := supplyListDropdown
                                    case "imbuement":       items := imbuementItemsList
                                    default:                items := ItemsHandler.getItemList(filterNames := "", {1: element.filter})
                                }
                            }
                        }

                        try Gui, Add, DDL, x+4 yp-2 w%w_field% v%variableName% hwndh%variableName% g%glabel%, % items
                        catch {
                        }
                        TT.Add(h%variableName%, element.description = "" ? txt("Sem descrição", "No description") : element.description)
                        ; msgbox, % element.name "`n" variableName "`n'" element.value "'`n`n" items
                        try  GuiControl, ChooseString, %variableName%, % element.value
                        catch {
                        }

                }
                variable_counter++
            }
        }

        for key, groupObj in groupboxesToCreate
            groupboxesToCreate[key].Delete("height")


        return
    }


    ScriptSettingsTab() {
        global

        DisabledBlockEdit := (DisableEditScript = 1) ? "Disabled" : ""

        w_tab := 300 - 35
        w_groupboxes := w_tab - 25

        gui, Add, Tab3, x5 y5 w%w_tab% Section +Theme, % LANGUAGE = "PT-BR" ? "Opções" : "Options"

        Gui, Tab, 1

        w_whereToStart := 65
        Gui, Add, Button, x15 yp30 w110 h40 vScriptInfo_Button gScriptInfoGUI hwndScriptInfo_Button 0x1, % LANGUAGE = "PT-BR" ? "Informações do script" : "Script information`n&& instructions"
        GuiButtonIcon(ScriptInfo_Button, "imageres.dll", 100, "a0 l5 s30")


        Gui, Add, Button, x+3 w60 h40 gWhereToStartGUI hwndScriptInfo_Button, % (LANGUAGE = "PT-BR" ? "Onde`nIniciar" : "Where to`nStart")
        Gui, Add, Button, x+3 w65 h40 gScriptImagesGUI hwndScriptInfo_Button, % txt("Abrir Script Images", "Open Script Images")


        w_text := 71
        w_controls := 140

        xs_ := 98

        Gui, Add, Groupbox, x15 y+8 w%w_groupboxes% h105, % LANGUAGE = "PT-BR" ? "Opções do script" : "Script options"

        Gui, Add, Checkbox, xs+20 yp+25  vforceStartWaypoint gforceStartWaypoint hwndhforceStartWaypoint Checked%forceStartWaypoint%, % (LANGUAGE = "PT-BR" ? "Forçar início no waypoint:" : "Force start on waypoint:")
        TT.Add(hforceStartWaypoint, (LANGUAGE = "PT-BR" ? "Se desmarcado, o Cavebot irá iniciar na aba/waypoint setada com o ícone do ""Homem correndo"", caso contrário irá iniciar na aba/waypoint setado abaixo" : "If unchecked, the Cavebot will start on the tab/waypoint set with the ""Running man"" icon, otherwise it will start on the tab/waypoint set below"))
        Disabled := forceStartWaypoint = 1 ? "" : "Disabled"

        Gui, Add, Text, xs+20 yp+25 w%w_text% Right, % LANGUAGE = "PT-BR" ? "Aba:" : "Tab:"
        Gui, Add, DDL ,xs+%xs_% yp-3 w%w_controls% vstartTabSet gstartTabSet %DisabledBlockEdit% %Disabled%, %ScriptTabsListDropdown%
        GuiControl, ChooseString, startTabSet, % startTabSet

        Gui, Add, Text, xs+20 y+8  w%w_text% Right, % "Waypoint:"
        Gui, Add, Edit,xs+%xs_% yp-3 h18 w%w_controls% vstartWaypointSet gstartWaypointSet Limit3 -VScroll -HScroll 0x2000  %Disabled%, % startWaypointSet


        this.itemHotkeys()

        Gui, Add, GroupBox, x15 y+20 w%w_groupboxes% h450, Selected Functions
        Gui, Add, Picture, xs+20 yp+20, Data\Files\Images\GUI\Cavebot\selected_functions.png
        Gui, Add, Text, xp+0 y+5, % (LANGUAGE = "PT-BR" ? "Selecione as funções para iniciar/parar:" : "Select the functions to start/stop:")

        for key, func in this.selectedFunctionsOptions
        {
            checked := selectedFunctionsObj[func.name] = "" && selectedFunctionsObj[func.name] != 0 ? 0 : selectedFunctionsObj[func.name]
            Gui, Add, Checkbox, % "xs+20 y+5 gselectedFunctionsOption vselectedFunctions_" func.name " Checked" checked " " func.disabled, % StrReplace(func.name, "Enabled", "")
        }
    }

    itemHotkeys()
    {
        global

        if (!clientHasFeature("useItemWithHotkey")) {
            return
        }

        Disabled := (!clientHasFeature("useItemWithHotkey")) ? "Disabled" : ""

        h := 95
        Gui, Add, GroupBox, x15 y+20 w%w_groupboxes% h%h%, Item Hotkeys


        tooltipMsg := (!clientHasFeature("useItemWithHotkey")) ? "" : txt("A hotkey do item deve estar configurada como ""Use with crosshair"" no cliente do Tibia.", "The item hotkey must be set as ""Use with crosshair"" in the Tibia client.")


        Gui, Add, Text, xs+20 yp+25 w%w_text% Right, Rope:
        Gui, Add, % (!clientHasFeature("useItemWithHotkey")) ? "Edit" : "Hotkey", xs+%xs_% yp-3 gRopeHotkey vRopeHotkey hwndhRopeHotkey w%w_controls% h18 0x1000 %Disabled%, % (!clientHasFeature("useItemWithHotkey")) ? "Item ""rope""" : RopeHotkey
        TT.Add(hRopeHotkey, tooltipMsg)

        Gui, Add, Text, xs+20 y+6 w%w_text% Right, Shovel:
        Gui, Add, % (!clientHasFeature("useItemWithHotkey")) ? "Edit" : "Hotkey", xs+%xs_% yp-3 gShovelHotkey vShovelHotkey hwndhShovelHotkey w%w_controls% h18 %Disabled%, % (!clientHasFeature("useItemWithHotkey")) ? "Item ""shovel""" : ShovelHotkey
        TT.Add(hShovelHotkey, tooltipMsg)

        Gui, Add, Text, xs+20 y+6 w%w_text% Right, Machete:
        Gui, Add, % (!clientHasFeature("useItemWithHotkey")) ? "Edit" : "Hotkey", xs+%xs_% yp-3 gMacheteHotkey vMacheteHotkey hwndhMacheteHotkey w%w_controls% h18 %Disabled%, % (!clientHasFeature("useItemWithHotkey")) ? "Item ""machete""" : MacheteHotkey
        TT.Add(hMacheteHotkey, tooltipMsg)
    }

    WaypointButtons() {
        global

        if (OldbotSettings.uncompatibleModule("cavebot") = true) {
            OldbotSettings.uncompatibleModuleWarning("60")
            return
        }


        x_base := x_groupbox_listview
        x := x_base + 10
        buttonsHeight := 22

            new _Checkbox().name("CavebotEnabled").title("&Cavebot " lang("enabled"))
            .x(x_groupbox_listview).y(54)
            .tt(txt("Iniciar o Cavebot", "Start the Cavebot") " (Cavebot.exe)")
            .event("CavebotEnabled")
            .value(CavebotEnabled)
            .add()


            new _ControlFactory(_ControlFactory.SETTINGS_BUTTON)
            .event(new _CavebotSettingsGUI().open.bind(new _CavebotSettingsGUI()))
            .tt("Configurações do Cavebot e Waypoints", "Cavebot and Waypoints settings")
            .add()


        h := h_groupbox_listview - 16

        Gui, CavebotGUI:Add, Groupbox, x%x_groupbox_listview% yp+25 w150 h120 vGroupbox_AddWaypoints1  -BackgroundTrans Section, % "Waypoint"

        DisabledBlockEdit := (DisableEditScript = 1) ? "Disabled" : ""

            new _Button().title("Adicionar", "Add", " &Waypoint")
            .x(x).yp(20).w(130).h(25)
            .event("LAddWaypointGUI")
            .icon(_Icon.get(_Icon.PLUS), "a0 l3 s14 b0")
            .focused()
            .add()

            new _Button().title("Auto record waypoints...")
            .name("autoRecordWaypointsButton")
            .x(x).y().w(103).h(33)
            .tt("Gravar automaticamente os waypoints de Walk enquanto o seu char anda.`n`nATENÇÃO: Ao descer/subir andares, você terá que adicionar/ajustar manualmente o waypoint para subir/descer.", "Auto record Walk waypoints while your char walks.`n`nATTENTION: When going up/down floors, you will need to add/adjust manually the waypoint to go up/down.")
            .icon(_Icon.get(_Icon.AUTO_RECORD), "a0 l3 b0 t1 s18")
            .event("autoRecordWaypointsLabel")
            .disabled(CavebotScript.isMarker())
            .add()

            new _Button()
            .x("+1").y("p+0").w(26).h(33)
            .name("autoRecordSettings")
            .tt("Configurações do Auto record waypoints", "Auto record waypoints settings")
            .event(_WaypointRecorder.autoRecordWaypointsSettings.bind(_WaypointRecorder))
            .icon(_Icon.get(_Icon.SETTINGS), "a0 l1 b0 t1 s18")
            .disabled(CavebotScript.isMarker())
            .add()

        DisabledShowWaypoints := scriptSettingsObj.cavebotFunctioningMode = "markers" ? "Disabled" : ""

            new _ControlFactory(_ControlFactory.HOTKEYS_BUTTON, {"iconSize": 20, "iconLeft": 2})
            .title("")
            .x(x).y().h(24).w(30)
            .event("HotkeysWaypoints")
            .tt("Visualizar hotkeys disponíveis para gerenciar waypoints", "View available hotkeys to manage waypoints")
            .add()

        _WaypointViewer.checkboxes()

        if (OldbotSettings.settingsJsonObj.options.manualCharacterPosition = true) {
                new _ControlFactory(_ControlFactory.SET_GAME_AREAS_BUTTON)
                .x(x_base).yadd(15).h(buttonsHeight).w(150)
                .add()
        }

        if (!backgroundMouseInput && !backgroundKeyboardInput) {
                new _Text().title("O cliente atual (" clientIdentifier() ") não possui controle de mouse/teclado em segundo plano(background), o mouse será usado e movido ""físicamente"" na tela para realizar as ações e a janela do cliente precisa estar visivel e ativa para se controlada.`n`nSegure ""Ctrl"" ou ""Shift"" para pausar temporariamente as ações manuais do bot.", "The current client (" clientIdentifier() ") does not have background mouse/keyboard control, the mouse will be used and moved ""physically"" on the screen to perform the actions and the client window needs to be visible and active to be controlled.`n`nHold ""Ctrl"" or ""Shift"" to temporarily pause the manual bot actions.")
                .x(x_groupbox_listview).w(150).y("+15")
                .color("red")
                .center()
                .add()
        } else if (!backgroundMouseInput) {
                new _Text().title("O cliente atual (" clientIdentifier() ") não possui CLIQUE em segundo plano(background), o mouse será usado e movido ""físicamente"" na tela para realizar as ações.", "The current client (" clientIdentifier() ") does not have background CLICK, the mouse will be used and moved ""physically"" on the screen to perform the actions.")
                .x(x_groupbox_listview).w(150).y("+15")
                .color("red")
                .center()
                .add()
        }

        this.cavebotFunctioningMode()



        h := 33
            new _Button().title("Runemaker")
            .xs().y("m+450").w(150).h(h)
            .event(_RunemakerGUI.open.bind(new _RunemakerGUI()))
            .add()

            new _Button().title("Marketbot")
            .xs().y("m+488").w(150).h(h)
        ; .xs().y("m+460").w(120).h(33)
            .event(_MarketbotGUI.open.bind(new _MarketbotGUI()))
        ; .icon(_Icon.get(_Icon.SQUARES), "a0 l3 s18 b0")
            .add()

        ; new _ControlFactory(_ControlFactory.SETTINGS_BUTTON)
        ; .yp().w(26).h(33)
        ; .event(new _SpecialAreasSettingsGUI().open.bind(new _SpecialAreasSettingsGUI()))
        ; .icon(_Icon.get(_Icon.SETTINGS), "a0 l1 b0 t1 s18")
        ; .add()

        ; new _ControlFactory(_ControlFactory.SCRIPT_IMAGES_BUTTON)
        ; .xs().y().w(150).h(25)
        ; .add()

            new _Button().title("Map &Viewer    ")
            .name("minimapViewerButton")
            .x(x_base).yadd(5).w(150).h(23)
            .tt("No Map Viewer você pode ver o minimapa do Tibia, ver a posição dos waypoints nas coordenadas do mapa, e também adicionar waypoints através do mapa, sem precisar estar logado no jogo.", "In the Map Viewer you can see the minimap of Tibia, see the position of waypoints in the map coordinates, and also add waypoints through the map, without needing to be logged in the game.")
            .event("minimapViewer")
            .icon(_Icon.get(_Icon.MAP), "a0 l5 b0 s16")
            .disabled(!isTibia13Or14())
            .disabled(!CavebotScript.isCoordinate())
            .add()

    }

    cavebotFunctioningMode()
    {
        global

        getCharCoordinatesFromMemory := OldBotSettings.settingsJsonObj.settings.cavebot.getCharCoordinatesFromMemory
        if (getCharCoordinatesFromMemory && CavebotScript.isCoordinate() && isTibia13Or14() && A_IsCompiled) {
            return
        }

        if (!getCharCoordinatesFromMemory && CavebotScript.isMarker()) {
            return
        }



        Gui, CavebotGUI:Add, Groupbox, x%x_groupbox_listview% y+15 w150 h120 vGroupbox_AddWaypoints2 -BackgroundTrans, % LANGUAGE = "PT-BR" ? "Opções" : "Options"

        ; Disabled := (OldBotSettings.settingsJsonObj.settings.cavebot.coordinatesFunctioningMode = true) ? "" : "Disabled"
        Disabled := ""

        if (!OldBotSettings.settingsJsonObj.settings.cavebot.getCharCoordinatesFromMemory) {
            Disabled := CavebotScript.isMarker() ? "Disabled" : ""
        }

        Gui, CavebotGUI:Add, Text, x%x% yp+20 -BackgroundTrans %Disabled%, % txt("Modo funcionamento Cavebot:", "Cavebot Functioning Mode:")
        Gui, CavebotGUI:Add, DDL, xp+0 y+3 w130 vcavebotFunctioningMode gcavebotFunctioningMode hwndhcavebotFunctioningMode %Disabled%, % "Coordinates|Markers"

        TT.Add(hcavebotFunctioningMode, tooltip_cavebotFunctioningMode)
        GuiControl, CavebotGUI:ChooseString, cavebotFunctioningMode, % scriptSettingsObj.cavebotFunctioningMode

        DisabledNotSupportCoordinatesFromMemory := (getCharCoordinatesFromMemory = true) ? "" : "Disabled"
        DisabledMarkersMode := (CavebotScript.isMarker()) ? "Disabled" : ""
        DisabledNotSupportCoordinates := (OldBotSettings.settingsJsonObj.settings.cavebot.coordinatesFunctioningMode = true) ? "" : "Disabled"

        charCoordsFromMemory := scriptSettingsObj.charCoordsFromMemory
        Disabled := (OldBotSettings.settingsJsonObj.settings.cavebot.coordinatesFunctioningMode = true && charCoordsFromMemory = 1 && charCoordsFromMemory = 1) ? "Disabled" : ""


        ; new _Checkbox().name("charCoordsFromMemory").title(txt("Coordenadas do char da memória do cliente", "Character coordinates from client memory"))
        ; .x("p+0").y("+7").w(130)
        ; .disabled(Disabled, DisabledMarkersMode, DisabledNotSupportCoordinatesFromMemory, DisabledNotSupportCoordinates)
        ; .tt(txt("Iniciar o Cavebot", "Start the Cavebot") " (Cavebot.exe)")
        ; .event("charCoordsFromMemory")
        ; .value(charCoordsFromMemory)
        ; .add()

        if (CavebotScript.isMarker())
                && (getCharCoordinatesFromMemory = true) {
                Gui, CavebotGUI:Font, cRed
            Gui, CavebotGUI:Add, Text, xp+0 y+7 w130 Center, % txt("É recomendado mudar o Cavebot Functioning Mode para ""Coordinates"".", "It's recommended to change the Cavebot Functioning Mode ""Coordinates"".")
            Gui, CavebotGUI:Font,
        }

        if (scriptSettingsObj.cavebotFunctioningMode != "markers" && getCharCoordinatesFromMemory != true) {
            Gui, CavebotGUI:Font, cRed
            Gui, CavebotGUI:Add, Text, xp+0 y+7 w130 Center, % txt("Escolha o cliente do OT em ""Selecionar Client"" para usar o bot.", "Choose the OT client on ""Select client"" to use the bot")
            Gui, CavebotGUI:Font,
        }

        if (getCharCoordinatesFromMemory = true)
                && (scriptSettingsObj.charCoordsFromMemory = false)
                && (scriptSettingsObj.cavebotFunctioningMode != "markers") {
                Gui, CavebotGUI:Font, cGreen
            Gui, CavebotGUI:Add, Text, xp+0 y+7 w130 Center, % txt("É recomendado ativar a opção de coordenadas da memória do cliente.", "It's recommended to enable the option of coordinates from client memory.")
            Gui, CavebotGUI:Font,
        }
    }

    stopAutoShowWaypoints() {
        CavebotHandler.stopShowWaypointTimer(true)
        GuiControl, CavebotGUI:, AutoShowWaypoints, 0
    }

    beforeAddWaypointGuiControls(GUIControl) {
        GuiControl, AddWaypointGUI:Disable, %GUIControl%
        GuiControl, CavebotGUI:Disable, AutoShowWaypoints
        this.buttonName := ""
        GuiControlGet, buttonName,, %GUIControl%
        this.buttonName := buttonName
        if (this.buttonName != "")
            GuiControl, AddWaypointGUI:, %GUIControl%, % (type = "Action") ? "Adding..." : "Adding, please wait..."
        ; msgbox, % GUIControl " / " type " / " this.buttonName

        this.showTimerOnBeforeAdd := false
        if (showWaypointsTimer = true) {
            this.showTimerOnBeforeAdd := true
            CavebotHandler.stopShowWaypointTimer(destroyGUI := true, true)
        }
    }

    afterAddWaypointGuiControls(GUIControl) {
        _ListviewHandler.selectRow(LV_Waypoints_%tab%, waypointsObj[tab].MaxIndex())

        if (this.showTimerOnBeforeAdd = true)
            CavebotHandler.startShowWaypointTimer()

        try {
            if (GUIControl != "AddWaypoint_UseTool") {
                if (this.buttonName) {
                    GuiControl, AddWaypointGUI:, %GUIControl%, % this.buttonName
                }

                GuiControl, AddWaypointGUI:Enable, %GUIControl%
            }

            GuiControl, CavebotGUI:Enable, AutoShowWaypoints
        } catch e {
        }

        gosub, updateLastCharacterCoordinatesMapViewer
    }

    addWaypointException(e) {
        if (e.Message != 1) {
            if (e.What = "errorGetCharPos") {
                string3 := (LANGUAGE = "PT-BR" ? "Se o cliente possuir injeção de memória do bot, marque a opção ""Coordenadas do char da memória do cliente"" na tela principal do Cavebot (e ignore possibilidades 2 e 3 abaixo). Se a opção de memória estiver desabilitada(cinza), selecione o OT que está usando no botão ""Selecionar Client""." : "If the client has memory injection from the bot, check the option ""Char coords from client memory"" on the main Cavebot screen (and ignore the  possibilities 2 and 3 below). If the memory option is disabled(gray), select the OT you are using on the ""Select Client"" button.")
                string5 := (LANGUAGE = "PT-BR" ? "Certifique-se de que o minimapa está completamente aberto." : "Make sure that the minimap is completely opened.")

                switch OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection {
                    case true:
                        string1 := txt("Falha para encontrar as coordenadas do personagem, possíveis causas:`n`n", "Failed to get the character position, possible causes:`n`n")
                        string2 := (LANGUAGE = "PT-BR" ? "Há diferenças no minimap, gere o mapa novamente clicando no botão ""Map viewer"" > ""Generate from Minimap folder""." : "There are differences in the minimap, generate the map again clicking in the ""Map viewer"" > ""Generate from Minimap folder"" button.")
                        string4 := (LANGUAGE = "PT-BR" ? "Certifique-se de que não há nenhum marcador(Marker) visível no mapa." : "Make sure there are no Markers visible in the minimap.")
                        Msgbox, 48, % txt("Falha ao adicionar waypoint", "Failure adding waypoint"), % ""
                            . string1
                            . "1) " string3
                            . "`n`n"
                            . "2) " string2
                            . "`n`n"
                            . "3) " string4
                            . "`n`n"
                            . "4) " string5, 120
                    default:
                        string := (LANGUAGE = "PT-BR" ? "Certifique-se de que você setou corretamente o ""Floor Level"" manualmente e tente novamente." : "Ensure that the you set correctly the ""Floor level"" manually and try again.")

                        Msgbox, 48, % txt("Falha ao adicionar waypoint", "Failure adding waypoint") " (" _Version.getDisplayVersion() ")", % ""
                            . txt("Falha para encontrar as coordenadas do personagem, possíveis causas:`n`n", "Failed to get the character position, possible causes:`n`n")
                            . "1) " string3
                            . "`n`n"
                            . "2) " string
                            . "`n`n"
                            . "3) " string4
                            . "`n`n"
                            . "4) " string5, 120
                }
            } else {
                Msgbox, 48, % "Error adding waypoint (" _Version.getDisplayVersion() ")", % e.Message, 30
            }
            posx := "", posy := "", posz := ""
            GuiControl, minimapViewerGUI:, lastCharacterCoordinates, % (posz = "") ? "None" : "x: " posx ", y: " posy ", z: " posz

        }
    }

    selectMarkerGUI(waypointNumber := "", newWaypointImageType := "") {
        global
        edit := waypointNumber > 0 ? true : false
        Gui, selectMarkerGUI:Destroy
        if (edit = true)
            Gui, selectMarkerGUI:+AlwaysOnTop -MinimizeBox +Owner
        else
            Gui, selectMarkerGUI:-MinimizeBox +Owner


        Gui, selectMarkerGUI:Add, Text, x10 y+5, % "Waypoint type:"
        Gui, selectMarkerGUI:Add, Listbox, % "x10 y+3 w120 vwaypointImageType r2 g" (edit = true ? "waypointImageTypeEdit" : "waypointImageType"), % "Marker|Image"


        switch edit {
            case true:
                if (waypointsObj[tab][waypointNumber].image != "")
                    GuiControl, selectMarkerGUI:ChooseString, waypointImageType, % waypointImageType := "Image"
                else
                    GuiControl, selectMarkerGUI:ChooseString, waypointImageType, % waypointImageType := "Marker"
            case false:
                GuiControl, selectMarkerGUI:ChooseString, waypointImageType, % waypointImageType
        }

        if (newWaypointImageType != "")
            GuiControl, selectMarkerGUI:ChooseString, waypointImageType, % waypointImageType := newWaypointImageType


        switch waypointImageType {
            case "Marker":
                Gui, selectMarkerGUI:Add, Text, x10 y+15, % "Select the Marker:"
                imageAddWaypointMarker := ""

                Loop, 20 {

                    marker := ImagesConfig.minimapMarkersFolder "\GUI\mark" A_Index ".png"

                    if (A_Index = 1) {
                        x = 10
                        y = +10
                    } else if (A_Index < 11) {
                        x = +5
                        y = p+0
                    }
                    if (A_Index = 11) {
                        x = 10
                        y = +10
                    }
                    if (A_Index > 11) {
                        x = +5
                        y = p+0
                    }

                    if (edit = true && A_Index = waypointsObj[tab][waypointNumber].marker) {
                        Gui, selectMarkerGUI:Add, Progress, x%x% y%y% w36 h36 cBlue, 100
                        x = p+2
                        y = p+2
                    }

                    Gui, selectMarkerGUI:Add, Picture, % "x" x " y" y " w32 h32 vminimapMarker" A_Index " g" (edit = true ? "editWaypointAtributeMarkerLabel" : "SelectMarkerAddWaypoint") " hwndhminimapMarker" A_Index, % marker
                    TT.Add(hminimapMarker%A_Index%, "Marker: " A_Index)

                }
            case "Image":
                this.waypointImageGUIElements(waypointNumber)
        }



        Gui, selectMarkerGUI:Show,, % (edit = true) ? "Edit Minimap Marker (Waypoint " waypointNumber ")"  : "Select Minimap Marker (" actionAddWaypointMarker ")"


    }

    waypointImageGUIElements(waypointNumber) {
        global

        Gui, selectMarkerGUI:Add, Groupbox, x10 y+15 w365 h265 Section, % "Waypoint Image"
        defaultSize := 16
        w := minimapWaypointWidth, h := minimapWaypointHeight

        loadImage := (waypointNumber > 0 && waypointsObj[tab][waypointNumber].image != "") ? true : false
        if (loadImage) {
            pBitmap := GdipCreateFromBase64(waypointsObj[tab][waypointNumber].image)
                , hBitmap:=Gdip_CreateHBITMAPFromBitmap(pBitmap)
                , w := Gdip_GetImageWidth( pBitmap )
                , h := Gdip_GetImageHeight( pBitmap )
        }

        sliderWidth := 30
        sliderLength := 75

        ; dummyW := w < 1 ? defaultSize : w
        dummyW := w < 1 ? defaultSize : w
        dummyH := h < 1 ? defaultSize : h
        edit := waypointNumber > 0 ? true : false



        /**
        Gui, selectMarkerGUI:Add, Slider, xs+0 y+3 w50 h20 vminimapWaypointWidth gminimapWaypointWidth Range10-40 ToolTipBottom Thick1 TickInterval1 Line1 Page1 Center, % w
        Gui, selectMarkerGUI:Add, Slider, xs+0 y+3 w20 h50 vminimapWaypointHeight gminimapWaypointHeight Range10-40 ToolTipBottom Thick1 TickInterval1 Line1 Page1 Vertical Center, % w
        */

        Gui, selectMarkerGUI:Add, Slider, % "xs+" sliderWidth + 10 - 2 " ys+15 w" sliderLength " h" sliderWidth " vminimapWaypointWidth gminimapWaypointWidth Thick12 TickInterval2 Range10-30 ToolTipTop Line2 Page2 Center AltSubmit hwndhminimapWaypointWidth", % dummyW
        Gui, selectMarkerGUI:Font, cGray
        Gui, selectMarkerGUI:Add, Text, % "x+3 yp" + sliderWidth / 2 - 8, width
        Gui, selectMarkerGUI:Font,
        Gui, selectMarkerGUI:Add, Slider, % "xs+10 ys+" sliderWidth + 10 " w" sliderWidth " h" sliderLength " vminimapWaypointHeight gminimapWaypointHeight Thick12 TickInterval2 Range10-30 ToolTipTop Line2 Page2 Center AltSubmit hwndhminimapWaypointHeight Vertical", % dummyH

        Gui, selectMarkerGUI:Font, cGray
        Gui, selectMarkerGUI:Add, Text, % "xp+2 y+0", height
        Gui, selectMarkerGUI:Font,
        Gui, selectMarkerGUI:Add, Picture, % "xs+" sliderWidth + 10 + 5 " ys+" sliderWidth + 17 " w" dummyW " h" dummyH " vminimapWaypointImageDummy", % ""


        text := "Hold ""Ctrl"" to change individually"
        TT.Add(hminimapWaypointWidth, text)
        TT.Add(hminimapWaypointHeight, text)


        Gui, selectMarkerGUI:Add, Picture, % "x20 y195 w" dummyW * 2 " h" dummyH * 2 " vminimapWaypointImage", % (loadImage) ? "HBITMAP:" hBitmap : ""

        if (waypointNumber > 0) {
            Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
            pBitmap := "", hBitmap := ""
        }

        Gui, selectMarkerGUI:Add, Button, % "x20 y260 w150 gAddImageWaypointMinimap 0x1", % waypointsObj[tab][waypointNumber].image != "" ? "Change waypoint image" : "Add waypoint image"
        Gui, selectMarkerGUI:Add, Button, % "x+3 yp+0 w100 gTestImageWaypointMinimap", % "Test image"
        Gui, selectMarkerGUI:Add, Button, % "x20 y+7 w150 vSaveImageWaypoint g" (edit = true ? "editWaypointAtributeImageLabel" : "AddWaypointImageLabel") " Disabled", % "Save waypoint"


        this.setDummyWaypointImage(dummyW, dummyH)

    }

    setDummyWaypointImage(w, h) {

        pBitmapDummy := Gdip_CreateBitmap(w, h)
        y := 0
        Loop, % h {

            x := 0
            Loop, % w {
                Gdip_SetPixel(pBitmapDummy, x, y, "0xFFed0000")
                x++
            }
            y++

        }

        ; Gdip_SetBitmapToClipboard(pBitmapDummy)
        hBitmapDummy:=Gdip_CreateHBITMAPFromBitmap(pBitmapDummy)

        GuiControl, selectMarkerGUI:, minimapWaypointImageDummy, % "HBITMAP:" hBitmapDummy
        this.changeWaypointImageControlSize("minimapWaypointImageDummy", w, h)
        Gdip_DisposeImage(pBitmapDummy), DeleteObject(hBitmapDummy)
        pBitmapDummy := "", hBitmapDummy := ""
    }

    changeWaypointImageControlSize(control, w, h) {
        GuiControl, selectMarkerGUI:Move, % control, % "w" w * 2
        GuiControl, selectMarkerGUI:Move, % control, % "h" h * 2
    }

    changeWaypointImageMinimap() {
        Gui, selectMarkerGUI:Default
        GuiControlGet, minimapWaypointWidth
        GuiControlGet, minimapWaypointHeight

        Gui, selectMarkerGUI:Hide
        WinActivate()

        if (tirar_screenshot("selectMarkerGUI", minimapWaypointImage, minimapWaypointWidth, minimapWaypointHeight,"TempMonster", "Red", 180, false, true) = false) {
            Gui, selectMarkerGUI:Show
            return
        }

        try GuiControl, selectMarkerGUI:, minimapWaypointImage, %A_Temp%\__monster.png
        catch {
        }
        this.changeWaypointImageControlSize("minimapWaypointImage", minimapWaypointWidth, minimapWaypointHeight)

        imageAddWaypointMarker := FileToBase64(A_Temp "\__monster.png")

        FileDelete, % A_Temp "\__monster.png"

        waypointAtributeName := "image"
        GuiControl, selectMarkerGUI:Enable, SaveImageWaypoint
        Gui, selectMarkerGUI:Show
    }

    setGameAreasGUI() {
        global
        Gui, setGameAreasGUI:Destroy
        Gui, setGameAreasGUI:-MinimizeBox

        w := 160
        h := 20

        Disabled := (OldbotSettings.settingsJsonObj.options.entireGameWindowArea) ? "Disabled" : ""

            new _Button().title("Tutorial áreas do cliente", "Client areas tutorial")
            .tt("Tutorial mostrando como setar corretamente as áreas do cliente.", "Tutorial showing how to set correctly the client areas.")
            .x("10").y("5").h(22).w(w)
            .event(Func("openUrl").bind("https://youtu.be/9IYJeWFSsUQ?si=l58Oz3GUJmaoQI53&t=299"))
            .gui("setGameAreasGUI")
            .icon(_Icon.get(_Icon.YOUTUBE), "a0 l2 b0 s14")
            .add()

        Gui, setGameAreasGUI:Add, Text, x10 y+10 w%w% , % "Game Window area:"
        Gui, setGameAreasGUI:Add, Button, x10 y+3 w%w% h%h% gShowGameWindowArea, % txt("Mostrar área", "Show area")
        Gui, setGameAreasGUI:Add, Button, x10 y+2 w%w% h%h% gSetGameWindowArea %Disabled%, % txt("Setar área", "Set area")

        if (OldbotSettings.settingsJsonObj.options.entireGameWindowArea) {
            Gui, setGameAreasGUI:Font, cGray
            Gui, setGameAreasGUI:Add, Text, x10 y+2 w%w% , % txt("A Game Window Area para o cliente atual (" TibiaClient.getClientIdentifier(true) ") é a área da janela inteira.", "The Game Window Area for the current client (" TibiaClient.getClientIdentifier(true) ") it's the area of the entire window.")
            Gui, setGameAreasGUI:Font,
        }


        if (!uncompatibleModule("looting")) {
            Gui, setGameAreasGUI:Add, Text, x10 y+10 w%w% , % LANGUAGE = "PT-BR" ? "Posição da Backpack(Loot)" : "Backpack position(Loot):"
            Gui, setGameAreasGUI:Add, Button, x10 y+3 w%w% h%h% gShowLootBackpackPosition, % LANGUAGE = "PT-BR" ? "Mostrar posição" : "Show position"
            Gui, setGameAreasGUI:Add, Button, x10 y+2 w%w% h%h% gSetLootBackpackPosition, % LANGUAGE = "PT-BR" ? "Setar posição" : "Set position"

            Gui, setGameAreasGUI:Add, Text, x10 y+10 w%w% , % "Loot Search area:"
            Gui, setGameAreasGUI:Add, Button, x10 y+3 w%w% h%h% gShowLootSearchArea, % txt("Mostrar área", "Show area")
            Gui, setGameAreasGUI:Add, Button, x10 y+2 w%w% h%h% gSetLootSearchArea, % txt("Setar área", "Set area")
        }


        if (jsonConfig("targeting", "battleListSetup", "manualArea")) {
            Gui, setGameAreasGUI:Add, Text, x10 y+10 w%w% , % "Battle List area"
                new _Button().title("Mostrar área", "Show area")
                .xp().yadd(5).w(w).h(h)
                .event(_BattleListArea.showOnScreen.bind(_BattleListArea))
                .gui("setGameAreasGUI")
                .add()

                new _Button().title("Setar área", "Set area")
                .xs().yadd(2).w(w).h(h)
                .event(_BattleListArea.setManualScreenArea.bind(_BattleListArea))
                .gui("setGameAreasGUI")
                .add()
        }

        ; Gui, setGameAreasGUI:Add, Text, x10 y+10 w%w% , % "First Custom area"
        ;     new _Button().title("Mostrar área", "Show area")
        ;     .xp().yadd(3).w(w).h(h)
        ;     .event(_FirstCustomArea.showOnScreen.bind(_FirstCustomArea))
        ;     .gui("setGameAreasGUI")
        ;     .add()

        ;     new _Button().title("Setar área", "Set area")
        ;     .xs().yadd(2).w(w).h(h)
        ;     .event(_FirstCustomArea.setManualScreenArea.bind(_FirstCustomArea))
        ;     .gui("setGameAreasGUI")
        ;     .add()

        ; Gui, setGameAreasGUI:Add, Text, x10 y+10 w%w% , % "Second Custom area"
        ;     new _Button().title("Mostrar área", "Show area")
        ;     .xp().yadd(3).w(w).h(h)
        ;     .event(_SecondCustomArea.showOnScreen.bind(_SecondCustomArea))
        ;     .gui("setGameAreasGUI")
        ;     .add()

        ;     new _Button().title("Setar área", "Set area")
        ;     .xs().yadd(2).w(w).h(h)
        ;     .event(_SecondCustomArea.setManualScreenArea.bind(_SecondCustomArea))
        ;     .gui("setGameAreasGUI")
        ;     .add()

        ; Gui, setGameAreasGUI:Add, Text, x10 y+10 w%w% , % "Third Custom area"
        ;     new _Button().title("Mostrar área", "Show area")
        ;     .xp().yadd(3).w(w).h(h)
        ;     .event(_ThirdCustomArea.showOnScreen.bind(_ThirdCustomArea))
        ;     .gui("setGameAreasGUI")
        ;     .add()

        ;     new _Button().title("Setar área", "Set area")
        ;     .xs().yadd(2).w(w).h(h)
        ;     .event(_ThirdCustomArea.setManualScreenArea.bind(_ThirdCustomArea))
        ;     .gui("setGameAreasGUI")
        ;     .add()

        Gui, setGameAreasGUI:Show,, % "Game Areas"
    }

    closeCavebotChildWindows()
    {
        Gui, ActionScriptGUI:Destroy
        Gui, editWaypointAtributeGUI:Destroy
        Gui, manageScriptRestrictionGUI:Destroy
        Gui, selectMarkerGUI:Destroy
        Gui, ScriptSettingsGUI:Destroy
        Gui, ScriptVariablesJsonGUI:Destroy
        Gui, ScriptInfoGUI:Destroy
        Gui, minimapViewerGUI:Destroy
        Gui, ScriptInfoGUI:Destroy
        Gui, Destroy
        ; Gui, ScriptListGUI:Destroy
        if (WinExist("ahk_id " ID_VariaveisGUI)) {
            Gui, %ID_VariaveisGUI%:Default
            Gui, Destroy
        }
        if (WinExist("ahk_id " IDWhereToStartGUIH)) {
            Gui, %IDWhereToStartGUIH%:Default
            Gui, Destroy
        }
        Gui, Carregando:Destroy
    }

    ladderWaypointGUI() {
        global
        Gui, ladderWaypointGUI:Destroy
        Gui, ladderWaypointGUI:+AlwaysOnTop -MinimizeBox +Owner
        Gui, ladderWaypointGUI:Add, Text, x10 y+5, % "Floor level will go up or down?"
        Gui, ladderWaypointGUI:Add, ListBox, x10 y+3 vladderWaypointType w150 r2, % "Up||Down"
        Gui, ladderWaypointGUI:Add, Button, x10 y+5 0x1 w150 gSubmitLadderWaypointType, % "Add waypoint"
        Gui, ladderWaypointGUI:Show,, % "Ladder Waypoint"
    }

    stairWaypointGUI() {
        global
        Gui, stairWaypointGUI:Destroy
        Gui, stairWaypointGUI:+AlwaysOnTop -MinimizeBox +Owner
        Gui, stairWaypointGUI:Add, Text, x10 y+5, % "Floor level will go up or down?"
        Gui, stairWaypointGUI:Add, ListBox, x10 y+3 vstairWaypointType w150 r2, % "Up||Down"
        Gui, stairWaypointGUI:Add, Button, x10 y+5 0x1 w150 gSubmitStairWaypointType, % "Add waypoint"
        Gui, stairWaypointGUI:Show,, % "Stair Waypoint"
    }

    WhereToStartGUI() {
        global

        if (WinExist("ahk_id " IDWhereToStartGUI)) {
            Gui, %IDWhereToStartGUI%:Default
            Gui, Destroy
        }

        this.guiW := 1280
        this.guiH := 720

        Gui, New
        Gui, +0x300000 ; WS_VSCROLL | WS_HSCROLL


        ; Gui, -MinimizeBox
        ; Gui, Color, White

        highestX := 0
        highestY := 0
        spaceBetweenImages := 10
        highestHeightAll := 0
        highestWidthAll := 0
        indexImage := 0
        Loop, 6 {
            highestWidth := 0
            highestHeight := 0
            if (!scriptImagesObj.hasKey("WhereToStart" A_Index))
                continue
            indexImage++
            pBitmap := GdipCreateFromBase64(scriptImagesObj["WhereToStart" A_Index].image)
                , hBitmap:=Gdip_CreateHBITMAPFromBitmap(pBitmap)

            try Gdip_GetDimensions(pBitmap, w, h)
            catch e {
                if (!A_IsCompiled)
                    msgbox, 16, % A_ThisFunc, % e.Message " | " e.What
            }

            switch indexImage {
                case 1:
                    x := 10
                    y := "+5"
                    heightIndex1 := h
                    highestWidth := w
                    highestHeight := h
                    highestHeightAll := h
                    highestWidthAll := w
                case 2:
                    x := 10
                    y := heightIndex1 + spaceBetweenImages
                    highestWidth := w > highestWidth ? w : highestWidth
                    highestHeight += h + spaceBetweenImages

                    checkhighestWidthAll := w
                    highestWidthAll := checkhighestWidthAll > highestWidthAll ? checkhighestWidthAll : highestWidthAll

                    checkhighestHeightAll := y + h
                    highestHeightAll := checkhighestHeightAll > highestHeightAll ? checkhighestHeightAll : highestHeightAll

                case 3:
                    x := highestWidthAll + (spaceBetweenImages * 2)
                    y := 5

                    heightIndex3 := h
                    highestWidth += w
                    highestHeight := h
                    highestWidthAll := x + highestWidth

                case 4:
                    x := x
                    y := heightIndex3 + spaceBetweenImages
                    highestWidth := w > highestWidth ? w : highestWidth
                    highestHeight += h + spaceBetweenImages

                    checkhighestWidthAll := x + w
                    highestWidthAll := checkhighestWidthAll > highestWidthAll ? checkhighestWidthAll : highestWidthAll

                    checkhighestHeightAll := y + h
                    highestHeightAll := checkhighestHeightAll > highestHeightAll ? checkhighestHeightAll : highestHeightAll

                case 5:
                    x := highestWidthAll + spaceBetweenImages
                    y := 5

                    heightIndex5 := h
                    highestWidth += w
                    highestHeight := h
                    highestWidthAll := x + highestWidth
                case 6:
                    x := x
                    y := heightIndex5 + spaceBetweenImages
                    highestWidth := w > highestWidth ? w : highestWidth
                    highestHeight += h + spaceBetweenImages

                    checkhighestHeightAll := y + h
                    highestHeightAll := checkhighestHeightAll > highestHeightAll ? checkhighestHeightAll : highestHeightAll
            }

            ; msgbox, % indexImage "`n" w " / " highestWidthAll "`n" h " / " highestHeightAll

            Gui, Add, Picture, x%x% y%y% gchangeWhereToStartScriptImage vWhereToStartImage%A_Index% -HScroll , HBITMAP:%hBitmap%
            Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap), pBitmap := "", hBitmap := ""
        }

        highestHeightAll += spaceBetweenImages

        Gui, Font, cGray
        Gui, Add, Text, x10 y%highestHeightAll%, % (LANGUAGE = "PT-BR" ? "Clique em uma image para trocá-la, segure o ""Ctrl"" para deletar, segure o ""Shift"" para copiar para o clipboard." : "Click on an image to change it, hold ""Ctrl"" to delete, hold ""Shift"" to copy to clipboard.")
        Gui, Font,
        Gui, Add, Button, x10 y+5 gselectWhereToStartImage w125 h25, % "Add image"
        Gui, Add, Button, x+5 yp+0 gaddClipboardWhereToStartImage w125 h25, % "Add from clipboard"

        Disabled := scriptImagesObj["WhereToStart"].image = "" ? "Disabled" : ""
        Gui, Add, Button, x+5 yp+0 gdeleteWhereToStartImage w125 h25 %Disabled%, % "Delete image"

        ; Gui, Add, Pic, x0 y0 0x4000000, % "Data\Files\Images\GUI\GrayBackground.png"


        ; GuiButtonIcon(SalvarInfos_Button, "shell32.dll", 297, "a0 l2 s18")
        Gui, Show, % "w" this.guiW " h" this.guiH ,% "Where to Start images - " currentScript

        Gui, +LastFound

        IDWhereToStartGUI := WinExist()

    }

    addWaypointGUI() {
        global
        Gui, AddWaypointGUI:Destroy
        Gui, AddWaypointGUI:+AlwaysOnTop -MinimizeBox +Owner

        DisabledBlockEdit := (DisableEditScript = 1) ? "Disabled" : ""

        w := 130

        x_base :=0
        x := x_base + 10
        h := h_groupbox_listview - 16

        if (CavebotScript.isCoordinate()) {


            Gui, AddWaypointGUI:Add, Text, x10 y+7 vRangeText, Range:
            RangeWaypointWidth := RangeWaypointWidth = "" ? 3 : RangeWaypointWidth, RangeWaypointHeight := RangeWaypointHeight = "" ? 3 : RangeWaypointHeight
            Gui, AddWaypointGUI:Add, Edit, x+5 yp-2 h18 w38 0x2000 Limit2 vRangeWaypointWidth gRangeWaypointWidth hwndhRangeWaypointWidth, % RangeWaypointWidth
            Gui, AddWaypointGUI:Add, UpDown, Range1-99 hwndhRangeWaypointWidthUpDown, % RangeWaypointWidth
            Gui, AddWaypointGUI:Add, Text, x+4 yp+1 vRangeText_X, x
            Gui, AddWaypointGUI:Add, Edit, x+3 yp-1 h18 w38 0x2000 Limit2 vRangeWaypointHeight gRangeWaypointHeight hwndhRangeWaypointHeight, % RangeWaypointHeight
            Gui, AddWaypointGUI:Add, UpDown, Range1-99 hwndhRangeWaypointHeightUpDown, % RangeWaypointHeight

            rangeText := (LANGUAGE = "PT-BR" ? "Distância em sqm para considerar que chegou no waypoint, 1 x 1 signifca que deve estar no sqm exato da coordenada.`n" : "Range sqm to consider that it arrived on the waypoint, 1 x 1 means it must be in the exact coordinate sqm.`n")
            tipText := (LANGUAGE = "PT-BR" ? "DICA: pressione ""Ctrl"" para alterar ambos os valores junto" : "TIP: hold ""Ctrl"" to change both values together")
            TT.Add(hRangeWaypointWidth, rangeText "" tipText)
            TT.Add(hRangeWaypointHeight, rangeText "" tipText)
            TT.Add(hRangeWaypointWidthUpDown, rangeText "" tipText)
            TT.Add(hRangeWaypointHeightUpDown, rangeText "" tipText)

            if (!OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection) {
                currentFloorLevel := (currentFloorLevel = "" OR currentFloorLevel = 0) ? 7 : currentFloorLevel
                Gui, AddWaypointGUI:Add, Text, x%x% y+7, Floor level:
                Gui, AddWaypointGUI:Add, Edit, x+5 yp-2 h18 w72 0x2000 Limit2 vcurrentFloorLevel gcurrentFloorLevel hwndhcurrentFloorLevel , % currentFloorLevel
                Gui, AddWaypointGUI:Add, UpDown, Range0-15, % currentFloorLevel
                ; Gui, AddWaypointGUI:Add, Button, x+2 yp+0 h19 w45, Change
            }

            Gui, AddWaypointGUI:Add, Groupbox, % "x" x " yp+19 w" w " h8 cBlack vGroupbox_4"

        }


        buttonsHeight := 22
        Gui, AddWaypointGUI:Add, Button, x%x% y+5 h%buttonsHeight% w%w% vAddWaypoint_Walk gAddWaypointLabel hwndhAddWaypoint_Walk %DisabledBlockEdit%, &Walk
        TT.Add(hAddWaypoint_Walk, (LANGUAGE = "PT-BR" ? "Chega até a coordenada, ou perto dela dependendo dos valores do ""range"".`nÉ recomendado adicionar waypoints com cerca de 5 sqms de distância entre cada um." : "Reach the coordinate, or near them depending on the ""range"" values.`nIt's recommended to add waypoints with around 5 sqms of distance between each other.") "`n[ Insert | Ctrl + Shift + End ]")

        if (scriptSettingsObj.cavebotFunctioningMode = "coordinates") {
            Gui, AddWaypointGUI:Add, Button, x%x% y+3 h%buttonsHeight% w%w% vAddWaypoint_Stand gAddWaypointLabel hwndhAddWaypoint_Stand %DisabledBlockEdit% %HiddenNotCoordinateMode%, &Stand
            TT.Add(hAddWaypoint_Stand, (LANGUAGE = "PT-BR" ? "Pisa no sqm exato da coordenada`nUsado para teleportes, escadas, buracos..." : "Stand on the exact sqm of the coordinate`nUsed for teleports, stairs, holes...") "`n[ Alt + Insert | Ctrl + Shift + End ]" )
        }

        Gui, AddWaypointGUI:Add, Groupbox, % "xp+0 yp+" buttonsHeight - 2 " w" w " h8 cBlack vGroupbox_1"

        Gui, AddWaypointGUI:Add, Button, x%x% y+3 h%buttonsHeight% w%w% vAddWaypoint_Ladder gAddWaypoint_Ladder hwndhAddWaypoint_Ladder %DisabledBlockEdit%, &Ladder
        TT.Add(hAddWaypoint_Ladder, (LANGUAGE = "PT-BR" ? "Chega até a coordenada e usa o sqm`nSe o floor level não mudar, irá repetir" : "Reach the coordinate and use the sqm`nIf the floor level doesn't change, it will repeat"))

        if (scriptSettingsObj.cavebotFunctioningMode = "coordinates") {
            Gui, AddWaypointGUI:Add, Button, x%x% y+3 h%buttonsHeight% w%w% vAddWaypoint_Door gAddWaypointLabel hwndhAddWaypoint_Door %DisabledBlockEdit% %HiddenNotCoordinateMode%, Door
            TT.Add(hAddWaypoint_Door, (LANGUAGE = "PT-BR" ? "Tenta pisar no sqm da Porta`nSe o sqm está bloquando(porta fechada), irá usar o sqm(abrir) e repetir" : "try to step in the Door sqm`nIf the sqm is blocked (closed door), it will use the sqm(open) and repeat"))
        }

        if (CavebotScript.isMarker()) {
            Gui, AddWaypointGUI:Add, Button, x%x% y+3 h%buttonsHeight% w%w% vAddWaypoint_Stair gAddWaypoint_Stair hwndhAddWaypoint_Stair %DisabledBlockEdit%, Stair/Hole
            TT.Add(hAddWaypoint_Stair, (LANGUAGE = "PT-BR" ? "Pisa em uma Escada ou Buraco`nEsse waypoint é usado somente em clientes onde você precisa setar o FLoor Level manualmente quando usa o Cavebot.`nNesse caso você precisa usar esse waypoint quando descer/subir um andar para que o bot consiga ajustar em qual floor level irá procurar pela posição do char quando o andar mudar." : "Step in a Stair or Hole`nThis waypoint is used only on clients where you need to set the Floor Level manually when using the Cavebo.`nIn this case you need to use this waypoint when going up/down floor levels so the bot can adjust in which floor level it will search for the character position when it changes."))
        }


        Gui, AddWaypointGUI:Add, Button, x%x% y+3 h%buttonsHeight% w%w% vAddWaypoint_Use gAddWaypointLabel hwndhAddWaypoint_Use %DisabledBlockEdit%, Use
        TT.Add(hAddWaypoint_Use, (LANGUAGE = "PT-BR" ? "Faz a ação de ""Use"" no sqm da coordenada" : "Do the ""Use"" action on the sqm of the coordinate"))

        Gui, AddWaypointGUI:Add, Groupbox, % "xp+0 yp+" buttonsHeight - 2 " w" w " h8 cBlack vGroupbox_2"

            new _Button().title("Tool/Item")
            .x(x).yadd(3).w(w).h(buttonsHeight)
            .event("AddWaypoint_UseTool")
            .disabled(DisabledBlockEdit)
            .tt(txt("- Rope: Chega até a coordenada e usa a Rope no sqm`nSe o floor level não mudar, irá repetir.`n-Shovel: Chega até a coordenada, usa a Shovel no sqm e pisa no sqm`nSe o floor level não mudar, irá repetir.`n- Machete/Others: Usa o item no sqm, por padrão usa o item 2 vezes.",  "- Rope: Reach the coordinate and use Rope on the sqm`nIf the floor level doesn't change, it will repeat.`n- Shovel: Reach the coordinate, use Shovel on the sqm and step on it`nIf the floor level doesn't change, it will repeat.`n- Machete/Others: Use the item on the sqm, by default it uses the item 2 times."))
            .gui("AddWaypointGUI")
            .add()

        Gui, AddWaypointGUI:Add, Groupbox, % "xp+0 yp+" buttonsHeight - 2 " w" w " h8 cBlack vGroupbox_3"

        Gui, AddWaypointGUI:Add, Button, x%x% y+3 h%buttonsHeight% w%w% vAddWaypoint_Action gAddWaypointLabel hwndhAddWaypoint_Action %DisabledBlockEdit%, % "&Action"



        x_column1 := x + 2
        x_column2 := x + 50
        x_column3 := x_column2 + 45


        heightDistance := 17
        Gui, AddWaypointGUI:Add, Radio, x%x_column1% y+12 vWaypointSQM_7, NW
        Gui, AddWaypointGUI:Add, Radio, x%x_column2% yp+0 vWaypointSQM_8, N
        Gui, AddWaypointGUI:Add, Radio, x%x_column3% yp+0 vWaypointSQM_9, NE
        Gui, AddWaypointGUI:Add, Radio, x%x_column1% y+%heightDistance% vWaypointSQM_4, W
        Gui, AddWaypointGUI:Add, Radio, x%x_column2% yp+0 vWaypointSQM_5, C
        Gui, AddWaypointGUI:Add, Radio, x%x_column3% yp+0 vWaypointSQM_6, E
        Gui, AddWaypointGUI:Add, Radio, x%x_column1% y+%heightDistance% vWaypointSQM_1, SW
        Gui, AddWaypointGUI:Add, Radio, x%x_column2% yp+0 vWaypointSQM_2, S
        Gui, AddWaypointGUI:Add, Radio, x%x_column3% yp+0 vWaypointSQM_3, SE


            new _Button().title("Tutorial criar script 100% AFK", "Tutorial create 100% AFK script")
            .x("10").y("+10").h(30).w(w)
            .event(Func("openUrl").bind("https://youtu.be/XboGV6gUFJo"))
            .gui("AddWaypointGUI")
            .icon(_Icon.get(_Icon.YOUTUBE), "a0 l2 b0 s14")
            .add()


        Gui, AddWaypointGUI:Show,, % LANGUAGE = "PT-BR" ? "Adicionar waypoint" : "Add waypoint"
        if (this.selectedSqm = "")
            this.selectedSqm := GetSelectedSQM()
        GuiControl, AddWaypointGUI:, % "WaypointSQM_" this.selectedSqm, 1

    }


    destroyButtonIconsCavebotGUI() {
        ; m(A_ThisFunc)
        Loop, % CavebotGUI_ICON_COUNTER {
            ; msgbox, % "a " CavebotGUI_ICONBUTTONS%A_Index%
            IL_Destroy(CavebotGUI_ICONBUTTONS%A_Index%)
            CavebotGUI_ICONBUTTONS%A_Index% := ""
            ; msgbox, % "b " CavebotGUI_ICONBUTTONS%A_Index%
        }

        CavebotGUI_ICON_COUNTER := 0
    }

    cavebotGUIButtonIcon(Handle, File, Index := 1, Options := "") {
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
        NumPut( CavebotGUI_ICONBUTTONS%CavebotGUI_ICON_COUNTER% := DllCall( "ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1 ), button_il, 0, Ptr )   ; Width & Height
        NumPut( L, button_il, 0 + Psz, DW )     ; Left Margin
        NumPut( T, button_il, 4 + Psz, DW )     ; Top Margin
        NumPut( R, button_il, 8 + Psz, DW )     ; Right Margin
        NumPut( B, button_il, 12 + Psz, DW )    ; Bottom Margin
        NumPut( A, button_il, 16 + Psz, DW )    ; Alignment
        SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %Handle%
        IL_Add( CavebotGUI_ICONBUTTONS%CavebotGUI_ICON_COUNTER%, File, Index )
        CavebotGUI_ICON_COUNTER++
        ; msgbox, % CavebotGUI_ICON_COUNTER
        ; return IL_Add( CavebotGUI_ICONBUTTONS, File, Index )
        return
    }

}