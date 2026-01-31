global clickHotkeyOn := false
global escHotkeyOn := false
global enterHotkeyOn := false

Class _FishingGUI {
    __New()
    {


    }

    PostCreate_FishingGUI() {
        if (OldbotSettings.uncompatibleModule("fishing") = true)
            return
        this.loadFishingListLV()
    }

    goToFishingRodItemList() {
        ; Navigate to Looting > ItemList tab
        GuiControl, CavebotGUI:Choose, MainTab, Looting
        try {
            Gosub, MainTab
        } catch e {
        }
        GuiControl, CavebotGUI:Choose, Tab_Looting, ItemList
        GuiControl, CavebotGUI:, searchFilter_Name, fishing rod

        Gui, CavebotGUI:Default
        LootingGUI.filterItemList()

        Sleep, 500
        LootingGUI.selectItemOnItemList("fishing rod")
    }

    createFishingGUI() {
        global

        main_tab := "Fishing"
        child_tabs_%main_tab% := "Settings"

        Gui, CavebotGUI:Add, Tab2, x6 vTab_%main_tab% y%y_tab% w%tabsWidth% h%tabsHeight% hWndhTab_%main_tab% %TabStyle% +Theme, % child_tabs_%main_tab%
        if (load_order[1] != main_tab)
            GuiControl, Hide, Tab_%main_tab% ; esconder a tab antes de adicionar os elementos a ela

        if (OldbotSettings.uncompatibleModule("fishing") = true) {
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
                    this.ChildTab_Fishing()
            }
        }

        return
    }

    ChildTab_Fishing()
    {
        global
        notScriptSettingScript := "`n`n*Profile setting, not a Script setting."


        DisabledNotTibia13 := isTibia13() ? "" : "Disabled"

        w := tabsWidth - 20
        h := tabsHeight - 37

        Gui CavebotGUI:Add, GroupBox, x15 y+6 w%w% h%h% Section,


        fishingEnabled := fishingObj.fishingEnabled
        Gui CavebotGUI:Add, Checkbox, xs+10 ys  vfishingEnabled gfishingEnabled hwndhfishingEnabled Checked%fishingEnabled%, Fishing Enabled
        TT.Add(hfishingEnabled, "Enable and start the Auto Fishing.`n`nPS: The Fishing Rod must be visible on screen to be used(inside a bag/BP).`n`nCAUTION! Be careful when clicking on items with the Fishing running, it can throw what's under the mouse on the sea!")


        w -= 20

        xsControls := 130
        wControls := 180

        groupHeight := 150

        Gui CavebotGUI:Add, GroupBox, xs+10 y+10 w%w% h%groupHeight%, % txt("Opções", "Options")

        Gui, CavebotGUI:Add, Text, xs+20 yp+25, Fishing delay:
        Gui, CavebotGUI:Add, Edit, xs+%xsControls% yp-2 w%wControls% h18 0x2000 Limit5 vfishingDelay gSubmitFishingOption hwndhfishingDelay, % fishingObj.fishingDelay
        TT.Add(hfishingDelay, txt("Delay após cada fishing(usando a fishing rod na agua)", "Delay after each fishing(using fishing rod on the water)") )


        if (clientHasFeature("useItemWithHotkey")) {
            Gui, CavebotGUI:Add, Text, xs+20 y+10, Fishing Rod Hotkey:
            Gui, CavebotGUI:Add, Hotkey, xs+%xsControls% yp-2 w%wControls% h18 vfishingRodHotkey gSubmitFishingOption hwndhfishingRodHotkey, % fishingObj.fishingRodHotkey
            TT.Add(hfishingRodHotkey, txt("Hotkey da Fishing Rod, se o OT não possui hotkeys, deixe em branco(""Nenhum"") para que o bot clique na rod(usar item sem hotkey).", "Fishing Rod hotkey, if the OT do not have hotkeys, leave it blank(""None"") so the bot click on the rod(use item without hotkey).") )
        } else {
            Gui, CavebotGUI:Add, Text, xs+20 y+10, Fishing Rod:
                new _Button().title("fishing rod")
                .xp(xsControls - 20).yp(-2).w(wControls).h(38)
                .icon(_BitmapIcon.FROM_ITEM("fishing rod"), "a0 l5 b0 t0 s30")
                .event(this.goToFishingRodItemList.bind(this))
                .tt(txt("Clique para ir para a Lista de Itens e alterar ou testar a imagem da Fishing Rod", "Click to go to Item List to change or test the Fishing Rod image"))
                .add()
        }

        Gui, CavebotGUI:Add, Text, xs+20 y+10, Pause Hotkey:
        Gui, CavebotGUI:Add, Hotkey, xs+%xsControls% yp-2 w%wControls% h18 vfishingPauseHotkey gfishingPauseHotkey hwndhfishingPauseHotkey, % fishingPauseHotkey
        TT.Add(hfishingPauseHotkey, txt("Hotkey para pausar o módulo de Fishing", "Hotkey to Pause the Fishing module." notScriptSettingScript) )

        pressEscFishingRod := fishingObj.pressEscFishingRod
        Gui, CavebotGUI:Add, Checkbox, xs+20 y+10 vpressEscFishingRod gSubmitFishingOption Checked%pressEscFishingRod%, % txt("Pressionar ""Esc"" antes de usar fishing rod", "Press ""Esc"" before using fishing rod")


        y := groupHeight + 80
        Gui CavebotGUI:Add, GroupBox, xs+10 y%y% w%w% h130, % txt("Condições", "Conditions")

        xsControls := 190

        fishingOnlyFreeSlot := fishingObj.fishingOnlyFreeSlot
        Gui, CavebotGUI:Add, Checkbox, xs+20 yp+25 vfishingOnlyFreeSlot gSubmitFishingOption hwndhfishingOnlyFreeSlot Checked%fishingOnlyFreeSlot% %DisabledNotTibia13%, % txt("Somente se slot vazio encontrado", "Only if free slot found")
        TT.Add(hfishingOnlyFreeSlot, txt("Pescar somente se qualquer slot vazio de backpack for encontrado na tela.", "Fish only if any empty backpack slot is found on screen.") )

        fishingIfNoFish := fishingObj.fishingIfNoFish
        Gui, CavebotGUI:Add, Checkbox, xs+20 yp+25 vfishingIfNoFish gSubmitFishingOption hwndhfishingIfNoFish Checked%fishingIfNoFish% %DisabledNotTibia13%, % txt("Somente se não houver fish na BP", "Only if no fish on BP")
        TT.Add(hfishingIfNoFish, txt("Pescar somente se não houver nenhum peixe encontrado em nenhum slot de backpack na tela.", "Fish only if there is no fish found in any backpack slot on screen.") )


        fishingCapCondition := fishingObj.fishingCapCondition
        Gui, CavebotGUI:Add, Checkbox, xs+20 y+10  vfishingCapCondition gSubmitFishingOption hwndhfishingCapCondition Checked%fishingCapCondition% %DisabledNotTibia13%, % txt("Se cap maior que:", "If cap higher than:")
        Gui, CavebotGUI:Add, Edit, xs+%xsControls% yp-2 w%wControls% h18 0x2000 Limit5 vfishingCap gSubmitFishingOption hwndhfishingCap %DisabledNotTibia13%, % fishingObj.fishingCap
        TT.Add(hfishingCapCondition, txt("Pescar somente se o cap do char for maior do que o valor setado.", "Fish only if character's Capacity is higher than the value set.") )
        TT.Add(hfishingCap, txt("Quantidade de cap para continuar pescando.", "Amount of cap to keep fishing.") )

        fishingIgnoreIfWaypointTab := fishingObj.fishingIgnoreIfWaypointTab
        Gui, CavebotGUI:Add, Checkbox, xs+20 y+10  vfishingIgnoreIfWaypointTab gSubmitFishingOption hwndhfishingIgnoreIfWaypointTab Checked%fishingIgnoreIfWaypointTab%, % txt("Ignorar se na aba de Waypoint:" , "Ignore if in Waypoint tab:")
        Gui, CavebotGUI:Add, Edit, xs+%xsControls% yp-2 w%wControls% h18 vfishingWaypointTab gSubmitFishingOption hwndhfishingWaypointTab, % fishingObj.fishingWaypointTab
        TT.Add(hfishingIgnoreIfWaypointTab, txt("Se marcado e o Cavebot estiver rodando, irá checar qual a aba atual do Waypoint que o Cavebot está, se for uma das abas setadas no parametro, não irá pescar.", "If checked and the Cavebot is running, it will check which is the current Waypoint Tab the cavebot is at, if is one of the tabs set in the param, it won't fish.") )
        TT.Add(hfishingWaypointTab, txt("Um ou mais nomes de Abas de Waypoint, separados por ""|"", exemplo: ", "One or more Waypoint Tab names, separated by ""|"", example: ") "Depositer|Hunt|BuySupply")

        Gui CavebotGUI:Add, GroupBox, xs+10 y+20 w%w% h95, Fishing Setup
        Gui, CavebotGUI:Add, Button, xp+10 yp+25 w140 vSetFishingSqms gSetFishingSqms hwndhSetFishingSqms, Set Fishing SQMs
        Gui, CavebotGUI:Add, Button, xp+0 y+10 w140 vResetFishingSQMs gResetFishingSQMs hwndhResetFishingSQMs, Reset Fishing SQMs

            new _Groupbox()
            .x("s+10").y("+20").w(w).h(95)
            .add()

            new _Button().title("Set Game Window area")
            .x("p+10").y("p+25").w(140)
            .event("SetGameWindowArea")
            .disabled(isTibia13())
            .add()

            new _Button().title("Show Game Window area")
            .x("p+0").y("+10").w(140)
            .event("ShowGameWindowArea")
            .disabled(isTibia13())
            .add()

        _GuiHandler.tutorialButtonModule("Fishing")
    }


    selectFishingSqms() {
        GuiControl, CavebotGUI:Disable, SetFishingSqms
        ; setSystemCursor("IDC_HAND")
        if (this.sqmsLayerGUI() = false)
            this.finishSelectedFishingSqms()
    }

    sqmsLayerGUI() {
        global
        if (enterHotkeyOn = true)
            return false

        ; if (WindowX = "") {
        if (TibiaClient.getClientArea() = false)
            return false
        ; }
        try {
            gameWindowArea := new _GameWindowArea()
        } catch e {
            Msgbox, 48, % A_ThisFunc, % e.Message
            return false
        }

        this.sizeSQM := gameWindowArea.getSqmSize() + 0.5
        this.sizeSQM := gameWindowArea.getSqmSize()
        ; this.sizeSQM -= 1
        ; m(serialize(fishingObj.sqms))
        ; this.selectedFishingGuiSqms := {}
        ; for key, value in fishingObj.sqms
        ; this.selectedFishingGuiSqms[key] := value
        this.selectedFishingGuiSqms := fishingObj.sqms
        if (!IsObject(this.selectedFishingGuiSqms))
            this.selectedFishingGuiSqms := {}
        ; m(serialize(this.selectedFishingGuiSqms))




        this.sqmsCounter := 1
        this.sqmVerticalCounter := 1

        this.sqmPositions := {}


        /**
        Values to create in the character position
        */
        this.initialSqmX := WindowX + CHAR_POS_X - (this.sizeSQM / 2)
        this.initialSqmY := SQMY := WindowY + CHAR_POS_Y - (this.sizeSQM / 2)

        WinActivate()
        indexSqm := 1
        Loop, % FishingSystem.sqmsVertical {

            this.sqmPositions[this.sqmVerticalCounter] := {}

            this.sqmHorizontalCounter := 1
            Loop, % FishingSystem.sqmsHorizontal {


                /**
                Skip character SQM
                */
                if (this.sqmHorizontalCounter = 7) && (this.sqmVerticalCounter = 5) {
                    ; this.sqmsCounter++
                    ; this.sqmHorizontalCounter++
                    ; continue
                }


                redSqm := this.selectedFishingGuiSqms["sqm" this.sqmVerticalCounter]["sqm" this.sqmHorizontalCounter] = true ? "Red" : "White"

                ; this.singleSqmGUI(this.selectedFishingGuiSqms["sqm" this.sqmVerticalCounter]["sqm" this.sqmHorizontalCounter] = true ? "Red" : "White")

                this.singleSqmGUI(redSqm, redSqm = "Red" ? indexSqm : "")

                ; if (this.sqmVerticalCounter > 4)
                ; m("this.sqmVerticalCounter = " this.sqmVerticalCounter "`n" "this.sqmHorizontalCounter = " this.sqmHorizontalCounter "`n" )
                this.sqmsCounter++

                this.sqmHorizontalCounter++
                this.sqmPositions[this.sqmVerticalCounter][this.sqmHorizontalCounter] := {}
                if (redSqm = "Red")
                    indexSqm++
            }

            this.sqmVerticalCounter++


        }


        SplashTextOn, 310,, % "Select SQMs and press ""Enter"" to Save, or ""Esc"" to Cancel."
        ; Hotkey, LButton, ClickOnFishingSQM, On
        ; Hotkey, Enter, FinishSelectedFishingSqms, On
        ; Hotkey, Esc, CancelSelectFishingSqms, On
        clickHotkeyOn := true
        escHotkeyOn := true
        enterHotkeyOn := true

        return true


        ; m(serialize(this.sqmPositions))
    }

    singleSqmGUI(sqmColor, index := "") {
        global

        Gui, % "FishingSqmGUI" this.sqmsCounter ": Destroy"
        ; Gui, SQMGUI%index%: +alwaysontop -Caption +Border +ToolWindow +LastFound +E0x20 ; +E0x20 = click through window when trasparent
        Gui, % "FishingSqmGUI" this.sqmsCounter ": +alwaysontop -Caption +Border +ToolWindow +LastFound" ; +E0x20 = click through window when trasparent
        Gui, % "FishingSqmGUI" this.sqmsCounter ": Color", %sqmColor%
        if (index != "") {
            Gui, % "FishingSqmGUI" this.sqmsCounter ": Font", s20
            Gui, % "FishingSqmGUI" this.sqmsCounter ": Add", Text, x5 y5 , %index%
        }

        WinSet, Transparent, 70

        SQMX := this.initialSqmX
            , SQMY := this.initialSqmY

        /**
        Changing values to start from top left
        */
        if (this.sqmHorizontalCounter < 7)
            SQMX -= this.sizeSQM * (FishingSystem.halfHorizontal - this.sqmHorizontalCounter)
        if (this.sqmHorizontalCounter > 7)
            SQMX += this.sizeSQM * (this.sqmHorizontalCounter - FishingSystem.halfHorizontal)
        /**
        Adjust because Counters start at 1 and not 0
        */
        SQMX -= this.sizeSQM

        if (this.sqmVerticalCounter < 5)
            SQMY -= this.sizeSQM * (FishingSystem.halfVertical - this.sqmVerticalCounter)
        if (this.sqmVerticalCounter > 5)
            SQMY += this.sizeSQM * (this.sqmVerticalCounter - FishingSystem.halfVertical)
        SQMY -= this.sizeSQM


        this.sqmPositions[this.sqmVerticalCounter][this.sqmHorizontalCounter] := {}
        this.sqmPositions[this.sqmVerticalCounter][this.sqmHorizontalCounter].x := SQMX
        this.sqmPositions[this.sqmVerticalCounter][this.sqmHorizontalCounter].y := SQMY
        this.sqmPositions[this.sqmVerticalCounter][this.sqmHorizontalCounter].sqmIndex := this.sqmsCounter


        Gui, % "FishingSqmGUI" this.sqmsCounter ": Show", % "w" this.sizeSQM "  h" this.sizeSQM " x" SQMX " y" SQMY " NoActivate"

        ; m(serialize(this.sqmPositions[this.sqmVerticalCounter]))

        ; WinMove, %SQMX%, %SQMY%

    }

    destroyAllFishingSqmsGUIs() {
        Loop, % this.sqmsCounter {
            Gui, % "FishingSqmGUI" A_Index ": Destroy"
        }
    }


    toggleFishingSqms() {
        CoordMode, Mouse, Screen

        this.sqmStates := {}
        While (GetKeyState("LButton", "P")) {
            Sleep, 25
            MouseGetPos, mouseX, mouseY

            ; m(serialize(this.sqmPositions))

            sqmFound := false
            sqmChanged := false
            for verticalKey, verticalValues in this.sqmPositions
            {
                ; m("verticalKey" "`n" verticalKey "`n" serialize(verticalValues))
                for horizontalKey, screenCoordinates in verticalValues
                {
                    ; m("horizontalKey" "`n" horizontalKey "`n" serialize(screenCoordinates))
                    ; m("verticalKey" "`n" verticalKey "`n" serialize(verticalValues) "`n`n" "horizontalKey" "`n" horizontalKey "`n" serialize(screenCoordinates))
                    x2 := screenCoordinates.x + SQM_SIZE, y2 := screenCoordinates.y + SQM_SIZE
                    ; m(mouseX " >= " screenCoordinates.x  " && " mouseX " <= " x2 "`n" mouseY " >= " screenCoordinates.y " && " mouseY " <= " y2)
                    if (mouseX >= screenCoordinates.x && mouseX <= x2) && (mouseY >= screenCoordinates.y && mouseY <= y2) {
                        ; m(serialize(screenCoordinates))
                        if (!IsObject(this.selectedFishingGuiSqms["sqm" verticalKey]))
                            this.selectedFishingGuiSqms["sqm" verticalKey] := {}
                        if (!IsObject(this.sqmStates["sqm" verticalKey]))
                            this.sqmStates["sqm" verticalKey] := {}

                        ; Tooltip, % verticalKey "`n" horizontalKey "`n" this.sqmStates["sqm" verticalKey]["sqm" horizontalKey]
                        if (this.sqmStates["sqm" verticalKey]["sqm" horizontalKey] = true) {
                            sqmChanged := true
                            break
                        }
                        /**
                        if SQM is already selected
                        */
                        if (this.selectedFishingGuiSqms["sqm" verticalKey]["sqm" horizontalKey] = true) {
                            this.selectedFishingGuiSqms["sqm" verticalKey]["sqm" horizontalKey] := false
                            Gui, % "FishingSqmGUI" screenCoordinates.sqmIndex ": Color", White
                        } else {
                            this.selectedFishingGuiSqms["sqm" verticalKey]["sqm" horizontalKey] := true
                            Gui, % "FishingSqmGUI" screenCoordinates.sqmIndex ": Color", Red
                        }
                        this.sqmStates["sqm" verticalKey]["sqm" horizontalKey] := true

                        ; msgbox,64,, % verticalKey "`n" horizontalKey "`n" serialize(this.selectedFishingGuiSqms), 3
                        sqmFound := true
                        break
                    }
                }
                if (sqmFound = true)
                    break
                if (sqmChanged = true)
                    break
            }

        }
        return false
    }


    toggleAllHotkeysOff() {
        ; Hotkey, LButton, ClickOnFishingSQM, Off
        ; Hotkey, Enter, FinishSelectedFishingSqms, Off
        ; Hotkey, Esc, CancelSelectFishingSqms, Off
        clickHotkeyOn := false
        escHotkeyOn := false
        enterHotkeyOn := false

    }

    finishSelectedFishingSqms() {


        Gui, CavebotGUI:Show
        SplashTextOff
        this.toggleAllHotkeysOff()
        this.destroyAllFishingSqmsGUIs()

        GuiControl, CavebotGUI:Enable, SetFishingSqms
        ; restoreCursor()
    }

    saveSelectedFishingSqms() {
        ; msgbox, % A_ThisFunc
        ; fishingObj.sqms := {}
        ; for key, value in this.selectedFishingGuiSqms
        ; {
        ;     fishingObj.sqms[key] := value
        ; }
        fishingObj.sqms := this.selectedFishingGuiSqms
        this.finishSelectedFishingSqms()
        FishingHandler.saveFishing()
    }



} ; class