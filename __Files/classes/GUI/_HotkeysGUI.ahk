
global hotkeyID

Class _HotkeysGUI  {
    __New()
    {

        this.hotkeyListDropdown := ""
        this.hotkeyListDropdown .= A_Space "|"
        for key, value in HotkeysHandler.hotkeyList
            this.hotkeyListDropdown .= value "|"


        this.controls := {}
        for key, option in HotkeysHandler.hotkeyOptions
        {
            this.controls.Push("hotkey" option)
        }


        this.enabledText := LANGUAGE = "PT-BR" ? "Ativar Hotkey" : "Enable Hotkey"
        this.disabledText := LANGUAGE = "PT-BR" ? "Desativar Hotkey" : "Disable Hotkey"


        this.userValueColumnSize := 200

    }

    PostCreate_HotkeysGUI() {
        if (OldbotSettings.uncompatibleModule("hotkeys") = true)
            return
        this.loadHotkeysListLV()
    }

    createHotkeysGUI() {
        global

        main_tab := "Hotkeys"
        child_tabs_%main_tab% := "Settings"

        Gui, CavebotGUI:Add, Tab2, x6 vTab_%main_tab% y%y_tab% w%tabsWidth% h%tabsHeight% hWndhTab_%main_tab% %TabStyle% +Theme, % child_tabs_%main_tab%
        if (load_order[1] != main_tab)
            GuiControl, Hide, Tab_%main_tab% ; esconder a tab antes de adicionar os elementos a ela

        if (OldbotSettings.uncompatibleModule("hotkeys") = true) {
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
                    this.ChildTab_Hotkey()
            }
        }

        return
    }

    ChildTab_Hotkey() {
        global

        mod := 50
        w_lv := w_LVWaypoints - mod
        w_group := 150 + 10

        this.LVColumnsCount := 6
        columns := "ID|Action|Enabled|Hotkey|User Value|Comment"

        Gui, CavebotGUI:Add, ListView, x15 y+6 h%LV_Waypoints_height% w%w_lv% AltSubmit -Multi vLV_HotkeysList gLV_HotkeysList hwndhLV_HotkeysList LV0x1 LV0x10, % columns


        x_group1 := x_groupbox_listview - mod

        w_group := 150 + mod
        w_controls := w_group - 20

        Disabled := ""

        w := w_group / 2 - 2

            new _Button().name("toggleAllHotkeysEnabled").title(txt("Ativar todos", "Enable all"))
            .x(x_group1).y(50).w(w_group / 2 - 1)
            .event("toggleAllHotkeysEnabled")
            .icon(_Icon.get(_Icon.CHECK_ROUND), "a0 l2 b0 s14")
            .add()

            new _Button().name("toggleAllHotkeysDisabled").title(txt("Desativar todos", "Disable all"))
            .x("+1").y("p+0").w((w_group / 2) + 1)
            .event("toggleAllHotkeysDisabled")
            .icon(_Icon.get(_Icon.DELETE_ROUND), "a0 l2 b0 t1 s14")
            .add()

        Gui, CavebotGUI:Add, Groupbox, x%x_group1% y+8 w%w_group% h55 Section, Add Hotkey
        w := w_controls / 2 - 2
        w1 := w + 15
        w2 := w - 15

            new _ControlFactory(_ControlFactory.ADD_NEW_BUTTON)
            .w(w1)
            .event("addHotkey")
            .add()

            new _Button().title(lang("delete"))
            .name("deleteHotkeysButton")
            .xadd(3).yp().w(w2)
            .icon(_Icon.get(_Icon.DELETE), "a0 l3 s14 b0")
            .tt("Segure ""Ctrl"" para pular o diálogo de confirmação", "Hold ""Ctrl"" to skip the confirmation dialog")
            .event("deleteHotkey")
            .add()


        Gui, CavebotGUI:Add, Groupbox, x%x_group1% y+20 w%w_group% h322 Section, Edit Hotkey
        Gui, CavebotGUI:Add, Checkbox, xs+10 yp+20 w%w_controls% h23 vhotkeyEnabled ghotkeyEnabled hwndhhotkeyEnabled Disabled 0x1000, % this.enabledText
        icon := _Icon.get(_Icon.CHECK_ROUND_WHITE)
        CavebotGUI.cavebotGUIButtonIcon(hhotkeyEnabled, icon.dllName, icon.number, "a0 l5 s16 b0")
        Gui, CavebotGUI:Add, Button, xs+10 y+5 w%w_controls% h23 vhotkeySaveChangesButton gsaveHotkeyChanges hwndhhotkeySaveChangesButton Disabled, %  LANGUAGE = "PT-BR" ? "Salvar alterações" : "Save changes"
        icon := _Icon.get(_Icon.CHECK)
        CavebotGUI.cavebotGUIButtonIcon(hhotkeySaveChangesButton, icon.dllName, icon.number, "a0 l5 s16 b0")

            new _ControlFactory(_ControlFactory.EDIT_USER_VALUES_BUTTON)
            .name("hotkeyEditUserValueButton")
            .xs(10).yadd(5).w(w_controls).h(23)
            .disabled()
            .event("editHotkeyUserValue")
            .add()

        Gui, CavebotGUI:Add, Button,xs+10 y+5 w%w_controls% h23 vhotkeyEditActionButton geditHotkeyAction Disabled,% LANGUAGE = "PT-BR" ? "Editar Action Script" : "Edit Action Script"

        Gui, CavebotGUI:Add, Text, xs+10 y+7 %Disabled%, Action:
        Gui, CavebotGUI:Add, DDL, xs+10 y+3 w%w_controls% vhotkeyAction ghotkeyAction Disabled, % this.hotkeyListDropdown

        Gui, CavebotGUI:Add, Text, xs+10 y+7 %Disabled%, Hotkey:
        Gui, CavebotGUI:Add, Combobox, xs+10 y+3 w%w_controls% vhotkeyHotkey ghotkeySubmit hwndhhotkeyHotkey Disabled, % A_Space "|" HotkeysHandler.allowedHotkeysList



        Gui, CavebotGUI:Add, Text, xs+10 y+7 %Disabled%, Comment:
        Gui, CavebotGUI:Add, Edit, xs+10 y+3 w%w_controls% r4 vhotkeyComment ghotkeySubmit -HSCroll Disabled,


        Gui, CavebotGUI:Add, Text, xs+10 y+10 %Disabled% Hidden, Hotkey ID:
        Gui, CavebotGUI:Add, Edit, xs+10 y+3 w%w_controls% h18 vhotkeyID Disabled Hidden,

        ; Gui, CavebotGUI:Add, Checkbox, xs+10 y+10 w%w_controls% h18 vhotkeyPlaySound hwndhhotkeyPlaySound ghotkeySubmit %Disabled%, % "Play sound"



        ; TT.Add(hhotkeyHotkey, "aaaaaaa")
        TT.Add(hhotkeyHotkey, "Interval to repeat the selected action")

        screenshotsCount := HotkeysHandler.countScreenshotsHotkeyFolder()
        Gui, CavebotGUI:Add, Groupbox, x%x_group1% ym+465 w%w_group% h85 Section, Options

            new _ControlFactory(_ControlFactory.SCRIPT_IMAGES_BUTTON)
            .xs(10).yp(20).w(w_controls)
            .add()

            new _ControlFactory(_ControlFactory.SET_GAME_AREAS_BUTTON)
            .xs(10).y().w(w_controls)
            .add()

        ; TT.Add(hopenHotkeyImagesFolder, "Open the folder where the images of ""Image is found"" and ""Images is not found"" hotkeys are stored")



        /**
        Gui, CavebotGUI:Add, Groupbox, x%x_group1% y390 w%w_group% h165 Section, Telegram Settings
        Gui, CavebotGUI:Add, Text, xs+10 yp+20, Chat ID:
        Gui, CavebotGUI:Add, Edit, xs+10 y+3 w%w_controls% h18 vtelegramChatID ReadOnly, % telegramChatID
        Gui, CavebotGUI:Add, Button, xs+10 y+5 w%w_controls% ggetTelegramChatID, % "Get chat ID"

        Gui, CavebotGUI:Add, Button, xs+10 y+20 w%w_controls% vtelegramTestMessageButton gsendTelegramTestMessage, % "Send test message"
        Gui, CavebotGUI:Add, Button, xs+10 y+5 w%w_controls% vtelegramTestScreenshotButton gsendTelegramTestScreenshot, % "Send test screenshot"
        */


        _GuiHandler.tutorialButtonModule("Hotkeys")
    }

    LV_HotkeysList() {

        Gui, CavebotGUI:Default
        Gui, ListView, LV_HotkeysList

        hotkeyID := _ListviewHandler.getSelectedItemOnLV("LV_HotkeysList", column := 1, defaultGUI := "CavebotGUI")
        if (hotkeyID = "" OR hotkeyID = "ID")
            return

        this.loadHotkeysGUIElements(hotkeyID)

        If (A_GuiEvent = "DoubleClick" OR A_GuiEvent = "RightClick") {

            hotkeysObj[hotkeyID].enabled := !hotkeysObj[hotkeyID].enabled
            if (hotkeysObj[hotkeyID].enabled = 1) {
                if (CheckClientMC() = false) {
                    hotkeysObj[hotkeyID].enabled := 0
                    return
                }
            }
            GuiControl, CavebotGUI:, hotkeyEnabled, % hotkeysObj[hotkeyID].enabled = true ? 1 : 0
            HotkeysHandler.changeHotkeyEnabled(hotkeyID, save := true)
            if (hotkeysObj[hotkeyID].enabled = 1)
                HotkeysHandler.runHotkeysExe()
        }


        ; LV_GetText(UseItemText,selectedLine,4)
        ; UseTrashItemEdit := UseItemText = "true" ? 1 : 0

        ; GuiControl, CavebotGUI:, UseTrashItemEdit, % UseTrashItemEdit
    }

    loadHotkeysGUIElements(hotkeyID := "") {
        if (hotkeyID = "") {
            hotkeyID := _ListviewHandler.getSelectedItemOnLV("LV_HotkeysList", column := 1, defaultGUI := "CavebotGUI")
            if (hotkeyID = "" OR hotkeyID = "ID")
                return
        }

        GuiControl, CavebotGUI:, hotkeyID, % hotkeyID
        if (hotkeysObj[hotkeyID].action) {
            GuiControl, CavebotGUI:ChooseString, hotkeyAction, % hotkeysObj[hotkeyID].action
        }
        GuiControl, CavebotGUI:ChooseString, hotkeyHotkey, % A_Space
        if (hotkeysObj[hotkeyID].hotkey) {
            GuiControl, CavebotGUI:ChooseString, hotkeyHotkey, % hotkeysObj[hotkeyID].hotkey
        }
        if (hotkeysObj[hotkeyID].action = "")
            GuiControl, CavebotGUI:ChooseString, hotkeyAction, % A_Space

        GuiControlEdit("CavebotGUI", "hotkeyComment", hotkeysObj[hotkeyID].comment, "hotkeySubmit")

        /**  
        enabling controls
        */
        this.changeOptions("Enable")

        GuiControl, CavebotGUI:Enable, hotkeyEnabled
        GuiControl, CavebotGUI:Enable, hotkeyEditUserValueButton
        GuiControl, CavebotGUI:Enable, hotkeyHotkey

        if (InStr(hotkeysObj[hotkeyID].action, "Action Script"))
            GuiControl, CavebotGUI:Enable, hotkeyEditActionButton
        else
            GuiControl, CavebotGUI:Disable, hotkeyEditActionButton

        GuiControl, CavebotGUI:, hotkeyEnabled, % hotkeysObj[hotkeyID].enabled = true ? this.disabledText : this.enabledText
        GuiControl, CavebotGUI:, hotkeyEnabled, % hotkeysObj[hotkeyID].enabled = true ? 1 : 0
    }

    changeOptions(action) {
        for key, control in this.controls
        {
            if (control = "hotkeyID")
                continue
            GuiControl, CavebotGUI:%action%, % control
        }
    }

    loadHotkeysListLV() {
        try {
            _ListviewHandler.loadingLV("LV_HotkeysList")
        } catch {
            return
        }


        /**
        */
        IL_Destroy(ImageListID_LV_HotkeysList)  ; Required for image lists used by tab_name controls.

        IconWidth    := 1
        IconHeight   := 30
        IconBitDepth := 24 ;
        InitialCount :=  1 ; The starting Number of Icons available in ImageList
        GrowCount    :=  1

        ImageListID_LV_HotkeysList  := DllCall( "ImageList_Create", Int,IconWidth,    Int,IconHeight
            , Int,IconBitDepth, Int,InitialCount
            , Int,GrowCount )

        Gui, ListView, LV_HotkeysList
        LV_SetImageList( ImageListID_LV_HotkeysList, 1 ) ; 0 for large icons, 1 for small icons

        for index, hotkeyAtributes in hotkeysObj
        {
            if (InStr(hotkeyAtributes.action, "Loot") && uncompatibleModule("looting")) {
                continue
            }

            Gui, ListView, LV_HotkeysList
            LV_Add("", index, this.rowAction(index), this.rowEnabled(index), this.rowHotkey(index), this.rowUserValue(index), this.rowComment(index))
            ; msgbox, % hotkeyID " / " serialize(hotkeyAtributes) "`n`n" serialize(LV_HotkeysList[hotkeyID])
        }

        this.resizeColumns()

        _ListviewHandler.setColumnInteger(1, "LV_HotkeysList")

        ; if (hotkeyID > 0)
        ; _ListviewHandler.selectRow("LV_HotkeysList", row, defaultGUI := "CavebotGUI")

    }

    rowAction(hotkeyID) {
        return hotkeysObj[hotkeyID].action = "" ? "none" : hotkeysObj[hotkeyID].action
    }

    rowEnabled(hotkeyID) {
        return hotkeysObj[hotkeyID].enabled = true ? "true" : "false"
    }

    rowHotkey(hotkeyID) {
        ; return hotkeysObj[hotkeyID].hotkey = "" ? "null" : hotkeysObj[hotkeyID].interval
        return hotkeysObj[hotkeyID].hotkey
    }

    rowComment(hotkeyID) {
        return hotkeysObj[hotkeyID].comment
    }

    rowUserValue(hotkeyID) {
        string := "{"
        ; msgbox, % hotkeyID "`n" serialize(hotkeysObj[hotkeyID]["userValue"])
        for a, values in hotkeysObj[hotkeyID]["userValue"]
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

    updateHotkeyRow(hotkeyID, funcOrigin := "") {
        if (hotkeyID = "") {
            if (!A_IsCompiled) {
                Msgbox, 48, % A_ThisFunc, % "(1) hotkeyID = " hotkeyID ", rowNumber = "  rowNumber ", funcOrigin = "  funcOrigin
            }
            return
        }
        rowNumber := _ListviewHandler.getSelectedItemOnLV("LV_HotkeysList", column := 1, defaultGUI := "CavebotGUI")
        if (rowNumber = "" OR rowNumber = "ID")
            return
        if (rowNumber < 1) {
            if (!A_IsCompiled) {
                Msgbox, 48, % A_ThisFunc, % "(2) hotkeyID = " hotkeyID ", rowNumber = "  rowNumber
            }
            return
        }
        ; msgbox, % A_ThisFunc
        Gui, ListView, LV_HotkeysList
        LV_Modify(rowNumber, "", hotkeyID, this.rowAction(hotkeyID), this.rowEnabled(hotkeyID), this.rowHotkey(hotkeyID), this.rowUserValue(hotkeyID), this.rowComment(hotkeyID))
    }


    resizeColumns() {
        Gui, ListView, LV_HotkeysList
        LV_ModifyCol(1, "autohdr") ; ID
        LV_ModifyCol(2, "autohdr") ; Action
        LV_ModifyCol(3, "autohdr") ; Enabled
        Gui, ListView, LV_HotkeysList
        LV_ModifyCol(4, "autohdr") ; interval
        LV_ModifyCol(5, this.userValueColumnSize) ; user Valuel
        LV_ModifyCol(6, "autohdr") ; comment
        ; Loop, % this.LVColumnsCount {
        ; }
    }





}
