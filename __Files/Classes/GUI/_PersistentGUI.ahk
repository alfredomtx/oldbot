
global persistentID

Class _PersistentGUI extends _BaseClass
{
    __Init() {

        this.persistentListDropdown := ""
        this.persistentListDropdown .= A_Space "|"
        for key, value in PersistentHandler.persistentList
            this.persistentListDropdown .= value "|"


        this.controls := {}
        for key, option in PersistentHandler.persistentOptions
        {
            this.controls.Push("persistent" option)
        }


        this.userValueColumnSize := 250


        this.enableText := LANGUAGE = "PT-BR" ? "Ativar Persistent" : "Enable Persistent"
        this.disableText := LANGUAGE = "PT-BR" ? "Desativar Persistent" : "Disable Persistent"


    }

    PostCreate_PersistentGUI() {
        if (OldbotSettings.uncompatibleModule("persistent") = true)
            return
        this.loadPersistentListLV()
    }

    createPersistentGUI() {
        global

        main_tab := "Persistent"
        child_tabs_%main_tab% := "Settings"

        Gui, CavebotGUI:Add, Tab2, x6 vTab_%main_tab% y%y_tab% w%tabsWidth% h%tabsHeight% hWndhTab_%main_tab% %TabStyle% +Theme, % child_tabs_%main_tab%
        if (load_order[1] != main_tab)
            GuiControl, Hide, Tab_%main_tab% ; esconder a tab antes de adicionar os elementos a ela

        if (OldbotSettings.uncompatibleModule("persistent") = true) {
            _GuiHandler.uncompatibleModuleWarning()
            return
        }

        Loop, parse, child_tabs_%main_tab%, |
        {
            current_child_tab := A_LoopField
            ; msgbox, % child_tabs_%main_tab%
            Gui, CavebotGUI:Tab, %current_child_tab%
            switch current_child_tab
            {
                case "Settings":
                    this.ChildTab_Persistent()
            }
        }

        return
    }

    ChildTab_Persistent() {
        global

        mod := 50
        w_lv := w_LVWaypoints - mod
        w_group := 150 + 10

        this.LVColumnsCount := 6
        columns := txt("ID|Action|Enabled|Intervalo|User Value|Comentário|", "ID|Action|Enabled|Interval|User Value|Comment")

        Gui, CavebotGUI:Add, ListView, x15 y+6 h%LV_Waypoints_height% w%w_lv% AltSubmit -Multi +NoSort vLV_PersistentList gLV_PersistentList hwndhLV_PersistentList LV0x1 LV0x10, % columns


        x_group1 := x_groupbox_listview - mod

        w_group := 150 + mod
        w_controls := w_group - 20

        Disabled := ""

            new _Button().name("enableAllButton").title(txt("Ativar todos", "Enable all"))
            .x(x_group1).y(50).w(w_group / 2 - 1)
            .tt(txt("Ativar todas as Persistents da lista", "Enable all Persistents of the list"))
            .event(this.enableAllButton.bind(this))
            .icon(_Icon.get(_Icon.CHECK_ROUND), "a0 l2 b0 s14")
            .add()

            new _Button().name("disableAllButton").title(txt("Desativar todos", "Disable all"))
            .x("+1").y("p+0").w((w_group / 2) + 1)
            .tt(txt("Desativar todas as Persistents da lista", "disable all Persistents of the list"))
            .event(this.disableAllButton.bind(this))
            .icon(_Icon.get(_Icon.DELETE_ROUND), "a0 l2 b0 t1 s14")
            .add()


        Gui, CavebotGUI:Add, Groupbox, x%x_group1% y+7 w%w_group% h55 Section, Add Persistent
        w := w_controls / 2 - 2
        w1 := w + 15
        w2 := w - 15

            new _ControlFactory(_ControlFactory.ADD_NEW_BUTTON)
            .w(w1)
            .event("addPersistent")
            .add()
        ; Gui, CavebotGUI:Add, Button, xs+10 yp+20 w%w1% gaddPersistent, % LANGUAGE = "PT-BR" ? "Adicionar novo" : "Add new"

            new _Button().title(lang("delete"))
            .name("deletePersistentButton")
            .xadd(3).yp().w(w2)
            .icon(_Icon.get(_Icon.DELETE), "a0 l3 s14 b0")
            .tt("Segure ""Ctrl"" para pular o diálogo de confirmação", "Hold ""Ctrl"" to skip the confirmation dialog")
            .event("deletePersistent")
            .add()


        Gui, CavebotGUI:Add, Groupbox, x%x_group1% y+18 w%w_group% h300 Section, % txt("Editar", "Edit") " Persistent"



        Gui, CavebotGUI:Add, Checkbox, xs+10 yp+20 w%w_controls% h23 vpersistentEnabled gpersistentEnabled hwndhpersistentEnabled Disabled 0x1000, % this.enableText
        icon := _Icon.get(_Icon.CHECK_ROUND_WHITE)
        CavebotGUI.cavebotGUIButtonIcon(hpersistentEnabled, icon.dllName, icon.number, "a0 l5 s16 b0")

        TT.Add(hpersistentEnabled, (LANGUAGE = "PT-BR" ? "Você também pode ativar a Persistent clicando com o botão direito do mouse no na lista." : "You can also enable the Persistent by right clicking on the list." ))
        Gui, CavebotGUI:Add, Button, xs+10 y+5 w%w_controls% h23 vpersistentSaveChangesButton gsavePersistentChanges hwndhpersistentSaveChangesButton Disabled, % txt("Salvar alterações", "Save changes")
        icon := _Icon.get(_Icon.CHECK)
        CavebotGUI.cavebotGUIButtonIcon(hpersistentSaveChangesButton, icon.dllName, icon.number, "a0 l5 s16 b0")

        Gui, CavebotGUI:Add, Groupbox, % "xs+10 y+2 w" w_controls " h8 cBlack"


            new _ControlFactory(_ControlFactory.EDIT_USER_VALUES_BUTTON)
            .name("persistentEditUserValueButton")
            .xs(10).yadd(6).w(w_controls).h(23)
            .disabled()
            .event("editPersistentUserValue")
            .add()

        Gui, CavebotGUI:Add, Button,xs+10 y+5 w%w_controls% h23 vpersistentEditActionButton geditPersistentAction Disabled,% LANGUAGE = "PT-BR" ? "Editar Action Script" : "Edit Action Script"



        Gui, CavebotGUI:Add, Text, xs+10 y+10 %Disabled%, Action:
        Gui, CavebotGUI:Add, DDL, xs+10 y+3 w%w_controls% vpersistentAction gpersistentAction Disabled, % this.persistentListDropdown

        Gui, CavebotGUI:Add, Text, xs+10 y+10 %Disabled%, % txt("Intervalo (segundos):", "Interval (seconds):")
        Gui, CavebotGUI:Add, Edit, xs+10 y+3 w%w_controls% h18 vpersistentInterval gpersistentSubmit hwndhpersistentInterval Disabled,


        Gui, CavebotGUI:Add, Text, xs+10 y+10 %Disabled%, % txt("Comentário:", "Comment:")
        Gui, CavebotGUI:Add, Edit, xs+10 y+3 w%w_controls% r2 vpersistentComment gpersistentSubmit -HSCroll Disabled,

        Gui, CavebotGUI:Add, Text, xs+10 y+10 Hidden, Persistent:
        Gui, CavebotGUI:Add, Edit, xs+10 y+3 w%w_controls% h18 vpersistentID Disabled Hidden,

        ; Gui, CavebotGUI:Add, Checkbox, xs+10 y+10 w%w_controls% h18 vpersistentPlaySound hwndhpersistentPlaySound gpersistentSubmit %Disabled%, % "Play sound"



        ; TT.Add(hpersistentInterval, "aaaaaaa")
        TT.Add(hpersistentInterval, txt("Intervalo para repetir a ação selecionada.`nPara intervalo menor que 1 segundo, por exemplo 200ms, use ""0.2"".", "Interval to repeat the selected action. `nFor interval lower than 1 second, for example 200ms, use ""0.2""."))

        screenshotsCount := PersistentHandler.countScreenshotsPersistentFolder()
        Gui, CavebotGUI:Add, Groupbox, x%x_group1% ym+465 w%w_group% h85 Section, Options
            new _ControlFactory(_ControlFactory.SCRIPT_IMAGES_BUTTON)
            .xs(10).yp(20).w(w_controls)
            .add()
        Gui, CavebotGUI:Add, Button, xs+10 y+7 w%w_controls% gopenPersistentScreenshotsFolder hwndhopenPersistentScreenshotsFolder, % (LANGUAGE = "PT-BR" ? "Abrir pasta de Screenshots" : "Open Screenshots folder") " (" screenshotsCount ")"
        TT.Add(hopenPersistentScreenshotsFolder, "Open the folder where the screenshots of ""Save screenshot"" action are stored.`nScreenshots in the folder: " screenshotsCount)

        ; TT.Add(hopenPersistentImagesFolder, "Open the folder where the images of ""Image is found"" and ""Images is not found"" persistents are stored")




        /**
        Gui, CavebotGUI:Add, Groupbox, x%x_group1% y390 w%w_group% h165 Section, Telegram Settings
        Gui, CavebotGUI:Add, Text, xs+10 yp+20, Chat ID:
        Gui, CavebotGUI:Add, Edit, xs+10 y+3 w%w_controls% h18 vtelegramChatID ReadOnly, % telegramChatID
        Gui, CavebotGUI:Add, Button, xs+10 y+5 w%w_controls% ggetTelegramChatID, % "Get chat ID"

        Gui, CavebotGUI:Add, Button, xs+10 y+20 w%w_controls% vtelegramTestMessageButton gsendTelegramTestMessage, % "Send test message"
        Gui, CavebotGUI:Add, Button, xs+10 y+5 w%w_controls% vtelegramTestScreenshotButton gsendTelegramTestScreenshot, % "Send test screenshot"
        */

        _GuiHandler.tutorialButtonModule("Persistent")

    }

    LV_PersistentList() {

        Gui, CavebotGUI:Default
        Gui, ListView, LV_PersistentList

        persistentID := _ListviewHandler.getSelectedItemOnLV("LV_PersistentList", column := 1, defaultGUI := "CavebotGUI")
        if (persistentID = "" OR persistentID = "ID")
            return

        this.loadPersistentGuiElements(persistentID)

        If (A_GuiEvent = "DoubleClick" OR A_GuiEvent = "RightClick") {

            persistentObj[persistentID].enabled := !persistentObj[persistentID].enabled
            if (persistentObj[persistentID].enabled = 1) {
                try PersistentHandler.checkBeforeEnabling(persistentID)
                catch e {
                    PersistentHandler.disablePersistent()
                    persistentObj[persistentID].enabled := 0
                    MsgBox, 64, % A_ThisFunc, % e.Message, % e.What
                    return
                }
            }
            GuiControl, CavebotGUI:, persistentEnabled, % persistentObj[persistentID].enabled = true ? 1 : 0
            PersistentHandler.changePersistentEnabled(persistentID, save := true)
            if (persistentObj[persistentID].enabled = 1)
                PersistentHandler.runPersistentExe()
        }


        ; LV_GetText(UseItemText,selectedLine,4)
        ; UseTrashItemEdit := UseItemText = "true" ? 1 : 0

        ; GuiControl, CavebotGUI:, UseTrashItemEdit, % UseTrashItemEdit
    }

    loadPersistentGuiElements(persistentID := "") {
        if (persistentID = "") {
            persistentID := _ListviewHandler.getSelectedItemOnLV("LV_PersistentList", column := 1, defaultGUI := "CavebotGUI")
            if (persistentID = "" OR persistentID = "ID")
                return
        }

        GuiControl, CavebotGUI:, persistentID, % persistentID
        if (persistentObj[persistentID].action) {
            GuiControl, CavebotGUI:ChooseString, persistentAction, % persistentObj[persistentID].action
        }
        if (persistentObj[persistentID].action = "")
            GuiControl, CavebotGUI:ChooseString, persistentAction, % A_Space

        GuiControlEdit("CavebotGUI", "persistentInterval", persistentObj[persistentID].interval, "persistentSubmit")
        GuiControlEdit("CavebotGUI", "persistentComment", persistentObj[persistentID].comment, "persistentSubmit")

        /**  
        enabling controls
        */
        this.changeOptions("Enable")

        if (InStr(persistentObj[persistentID].action, "Action Script")) {
            GuiControl, CavebotGUI:Enable, persistentEditActionButton
            GuiControl, CavebotGUI:Disable, persistentEditUserValueButton
        } else {
            GuiControl, CavebotGUI:Disable, persistentEditActionButton
            GuiControl, CavebotGUI:Enable, persistentEditUserValueButton
        }

        GuiControl, CavebotGUI:Enable, persistentEnabled

        GuiControl, CavebotGUI:, persistentEnabled, % persistentObj[persistentID].enabled = true ? this.disableText : this.enableText
        GuiControl, CavebotGUI:, persistentEnabled, % persistentObj[persistentID].enabled = true ? 1 : 0
    }

    changeOptions(action) {
        for key, control in this.controls
        {
            if (control = "persistentID")
                continue
            GuiControl, CavebotGUI:%action%, % control
        }
    }

    loadPersistentListLV() {
        try {
            _ListviewHandler.loadingLV("LV_PersistentList")
        } catch {
            return
        }


        /**
        */
        IL_Destroy(ImageListID_LV_PersistentList)  ; Required for image lists used by tab_name controls.

        IconWidth    := 1
        IconHeight   := 30
        IconBitDepth := 24 ;
        InitialCount :=  1 ; The starting Number of Icons available in ImageList
        GrowCount    :=  1

        ImageListID_LV_PersistentList  := DllCall( "ImageList_Create", Int,IconWidth,    Int,IconHeight
            , Int,IconBitDepth, Int,InitialCount
            , Int,GrowCount )

        Gui, ListView, LV_PersistentList
        LV_SetImageList( ImageListID_LV_PersistentList, 1 ) ; 0 for large icons, 1 for small icons

        ; msgbox, % serialize(persistentObj)
        for index, persistentAtributes in persistentObj
        {

            Gui, ListView, LV_PersistentList
            LV_Add("", index, this.rowAction(index), this.rowEnabled(index), this.rowInterval(index), this.rowUserValue(index), this.rowComment(index))
            ; msgbox, % persistentID " / " serialize(persistentAtributes) "`n`n" serialize(persistentObj[persistentID])
        }

        this.resizeColumns()

        _ListviewHandler.setColumnInteger(1, "LV_PersistentList")

        if (persistentID > 0)
            _ListviewHandler.selectRow("LV_PersistentList", row, defaultGUI := "CavebotGUI")
    }

    rowAction(persistentID) {
        return persistentObj[persistentID].action = "" ? "none" : persistentObj[persistentID].action
    }

    rowEnabled(persistentID) {
        return persistentObj[persistentID].enabled = true ? "true" : "false"
    }

    rowInterval(persistentID) {
        return persistentObj[persistentID].interval = "" ? "null" : persistentObj[persistentID].interval
    }

    rowComment(persistentID) {
        return persistentObj[persistentID].comment
    }

    rowUserValue(persistentID) {
        string := "{"
        ; msgbox, % persistentID "`n" serialize(persistentObj[persistentID]["userValue"])
        for a, values in persistentObj[persistentID]["userValue"]
        {
            ; msgbox, % a " = " values
            for key, value in values
                string .= """" key """" ": " """" value """" ", "
        }
        StringTrimRight, string, string, 2
        if (StrLen(string) > 2)
            string .= "}"
        return string
    }

    updatePersistentRow(persistentID, funcOrigin := "") {
        if (persistentID = "") {
            if (!A_IsCompiled) {
                Msgbox, 48, % A_ThisFunc, % "(1) persistentID = " persistentID ", rowNumber = "  rowNumber ", funcOrigin = "  funcOrigin
            }
            return
        }
        rowNumber := _ListviewHandler.getSelectedItemOnLV("LV_PersistentList", column := 1, defaultGUI := "CavebotGUI")
        if (rowNumber = "" OR rowNumber = "ID")
            return
        if (rowNumber < 1) {
            if (!A_IsCompiled) {
                Msgbox, 48, % A_ThisFunc, % "(2) persistentID = " persistentID ", rowNumber = "  rowNumber
            }
            return
        }
        ; msgbox, % A_ThisFunc
        Gui, ListView, LV_PersistentList
        LV_Modify(rowNumber, "", persistentID, this.rowAction(persistentID), this.rowEnabled(persistentID), this.rowInterval(persistentID), this.rowUserValue(persistentID), this.rowComment(persistentID))
    }


    resizeColumns() {
        Gui, ListView, LV_PersistentList
        LV_ModifyCol(1, "autohdr") ; ID
        LV_ModifyCol(2, "autohdr") ; Action
        LV_ModifyCol(3, "autohdr") ; Enabled
        Gui, ListView, LV_PersistentList
        LV_ModifyCol(4, "autohdr") ; interval
        LV_ModifyCol(5, this.userValueColumnSize) ; user Valuel
        LV_ModifyCol(6, "autohdr") ; comment
        ; Loop, % this.LVColumnsCount {
        ; }
    }

    enableAllButton() {
        global toggleAllPersistentStatus := 0
        ; GuiControl, CavebotGUI:, toggleAllPersistents, % toggleAllPersistentsStatus := 0
        gosub, toggleAllPersistents
    }

    disableAllButton() {
        global toggleAllPersistentStatus := 1
        gosub, toggleAllPersistents
    }

    /**
    * @return BoundFunc
    */
    getHotkeyControl() {
        return this.walkCommandHotkey
    }

}
