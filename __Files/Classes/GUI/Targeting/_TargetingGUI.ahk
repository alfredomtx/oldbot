global hLV_Creatures ; set hwnd lv global here otherwise it won't work as global variable when creating the listview
global LV_CreaturesColors

global selectedSpell := 0

global IMAGE_LIST_LV_Creatures
global IMAGE_LIST_LV_CreatureList

global searchFilterCreatureName
global showAllCreaturesList

Class _TargetingGUI  {

    static checkboxList := {}
    static editList := {}
    static dropdownList := {}
    static buttonList := {}
    static controlsList := {}
    static disabledControls := {}

    __New()
    {

        this.columnsLV_CreatureList := "#|Name|EXP|HP|MaxDmg|Type|RunsAt|Walks around|Walks through|Sense invis|Behaviour"
        this.columnsCountLV_CreatureList := 0

        this.checkboxList.Push("creatureOnlyIftrapped")
        this.checkboxList.Push("creatureMustAttackMe")
        this.checkboxList.Push("creatureUseItemOnCorpse")
        this.checkboxList.Push("creatureDontLoot")
        this.checkboxList.Push("creaturePlayAlarm")
        this.checkboxList.Push("creatureIgnoreAttacking")
        this.checkboxList.Push("creatureopenBagInsideCorpse")
        ; this.checkboxList.Push("creatureIgnoreUnreachable") ; text
        this.checkboxList.Push("creatureIgnoreIfNotReached")

        ; dropdown
        this.dropdownList.Push("creatureStance")
        this.dropdownList.Push("creatureAttackMode")
        this.dropdownList.Push("creatureLifeStopAttack")
        this.dropdownList.Push("creatureLifeToExetaRes")
        this.dropdownList.Push("creatureIgnoreDistance")
        this.dropdownList.Push("creatureIgnoreDistanceTime")
        this.dropdownList.Push("creatureIgnoreAfterTime")
        this.dropdownList.Push("creatureIgnoreUnreachableTime")
        this.dropdownList.Push("creatureIgnoreIfNotReachedTime")
        this.dropdownList.Push("creatureIgnoreIfNotReachedDuration")
        this.dropdownList.Push("creatureExetaResCooldown")

        ; this.editList.Push("creatureDistanceSQM")

        ; edit / hotkey
        this.editList.Push("creatureName")
        this.editList.Push("creatureDanger")
        this.editList.Push("creatureIgnoreAfter")
        this.editList.Push("creatureCorpseItemHotkey")
        this.editList.Push("creatureitemUseOnCorpse")

        this.editList.Push("creatureRingHotkey")
        this.editList.Push("creatureAmuletHotkey")
        this.editList.Push("creatureUtitoTempoHotkey")
        this.editList.Push("creatureExetaResHotkey")

        ;button
        this.buttonList.Push("GetCreatureImage")
        this.buttonList.Push("testCreatureImage")

        for key, value in this.checkboxList
            this.controlsList.Push(value)

        for key, value in this.dropdownList
            this.controlsList.Push(value)

        for key, value in this.editList
            this.controlsList.Push(value)

        for key, value in this.buttonList
            this.controlsList.Push(value)

        ; not ready to use
        ; if (A_IsCompiled) {
        ; this.disabledControls.Push("creatureMustAttackMe")
        ; this.disabledControls.Push("creatureOnlyIftrapped")
        ; this.disabledControls.Push("creatureStance")
        ; }


        this.readIniTargetingGUISettings()

    }

    PostCreateTargetingGUI() {
        if (OldbotSettings.uncompatibleModule("targeting") = true)
            return
        this.changeAllControls("Disable")
        this.loadTargetListLV(true) ; if load spells after targeting, it's overwriting the targetlist lv rows
        this.loadTargetListLV(false)
        this.changeSpellsControls("Disable")
        GuiControl, CavebotGUI:+gsubmitTargetOptionHandler, creatureDanger

        this.checkTargetingGuiSettingsControls()

        _Listviewhandler.selectRow("LV_Creatures", 1)
        this.loadCreatureInfo("all")
    }

    createTargetingTabs() {
        global
        /*
        Criando tabs do Targeting
        */
        main_tab := "Targeting"
        child_tabs_%main_tab% := "Creatures|Magic Shooter"

        Gui, CavebotGUI:Add, Tab2, x6 vTab_%main_tab% y%y_tab% w%tabsWidth% h%tabsHeight% hWndhTab_%main_tab% %TabStyle% +Theme, % child_tabs_%main_tab%
        if (load_order[1] != main_tab)
            GuiControl, Hide, Tab_%main_tab% ; esconder a tab antes de adicionar os elementos a ela

        if (OldbotSettings.uncompatibleModule("targeting") = true) {
            _GuiHandler.uncompatibleModuleWarning()
            return
        }



        Loop, parse, child_tabs_%main_tab%, |
        {
            timer := new _Timer()
            current_child_tab := A_LoopField

            ; msgbox, % main_tab "`n`ncurrent_child_tab = " current_child_tab
            Gui, CavebotGUI:Tab, %current_child_tab%
            if (current_child_tab = "Creatures") {
                this.ChildTab_Creatures()
            }
            if (current_child_tab = "Magic Shooter") {
                this.ChildTab_Spells()
            }

            _Logger.info(current_child_tab, timer.elapsed())

        }

        return

    }


    createAddCreatureGUI() {
        global

        Gui, AddCreatureGUI:Destroy
        Gui, AddCreatureGUI:-MinimizeBox

        Gui, AddCreatureGUI:Add, Edit, x10 y+5 w150 h18 vsearchFilterCreatureName gSearchCreatureList hwndhsearchFilterCreatureName, %searchFilterCreatureName%

        this.listviewWidth := 500

        searchFilterExactCreatureName := (searchFilterExactCreatureName = "") ? 0 : searchFilterExactCreatureName
        Gui, AddCreatureGUI:Add, Checkbox, x+5 yp+3 vsearchFilterExactCreatureName gSearchCreatureList hwndhsearchFilterExactCreatureName Checked%searchFilterExactCreatureName%, % txt("Nome exato", "Exact name match")
        searchFilterHaveImage := (searchFilterHaveImage = "") ? 0 : searchFilterHaveImage
        Gui, AddCreatureGUI:Add, Checkbox, x+5 yp+0 vsearchFilterHaveImage gSearchCreatureList hwndhsearchFilterHaveImage Checked%searchFilterHaveImage%, % txt("Possui imagem", "Have image")

        showAllCreaturesList := (showAllCreaturesList = "") ? 0 : showAllCreaturesList
        Gui, AddCreatureGUI:Add, Checkbox, x+5 yp+0 vshowAllCreaturesList gshowAllCreaturesList hwndhsearchFilterHaveImage Checked%showAllCreaturesList%, % txt("Mostrar todas as criaturas", "Show all creatures")

        columns := ""
        Loop, parse, % this.columnsLV_CreatureList, |
        {
            columns .= A_LoopField "|"
            this.columnsCountLV_CreatureList++
        }

        Gui, AddCreatureGUI:Add, ListView, % "x10 y+5 w" this.listviewWidth " r20 vLV_CreatureList gLV_CreatureList hwndhLV_CreatureList LV0x1 LV0x10", % columns
        Gui, AddCreatureGUI:Add, Button, x10 y+5 w150 0x1 gAddCreatureToTargetList vAddCreatureToTargetList hwndhAddCreatureToTargetList, % txt("Adicionar criatura(s)", "Add creature(s)")

        Gui, AddCreatureGUI:Add, Button, x+5 yp+0 w120 gAddNewCreatureToList vAddNewCreatureToList hwndhAddCreatureToTargetList, % txt("Adicionar nova na lista", "Add new to list")

        Gui, AddCreatureGUI:Add, Button, % "xs+" this.listviewWidth - 205 " yp+0 w100 vdownloadCreatures hwndhdownloadCreatures gAPI_downloadCreatures", Download
        TT.Add(hdownloadCreatures, "Download creature images from OldBot's database`nThe bot will be reopened after the download")
        Gui, AddCreatureGUI:Add, Button, x+5 yp+0 w100 vuploadCreatures hwndhuploadCreatures gAPI_uploadCreatures, Upload
        TT.Add(huploadCreatures, "Upload the creature images from all scripts in the Cavebot folder to OldBot's database")

        Gui, AddCreatureGUI:Show,, % "Creatures List"
        SetEditCueBanner(hsearchFilterCreatureName, txt("Nome da criatura...", "Creature name..."))

        this.filterCreatureList()
    }

    LV_CreatureList()
    {
        GuiControl, CavebotGUI:-g, LV_CreatureList
        try
            TargetingHandler.addToTargetList()
        catch e {
            Msgbox, 48,, % e.Message
        }
        Sleep, 50
        GuiControl, CavebotGUI:+gLV_CreatureList, LV_CreatureList
    }

    LV_CreaturesSpells() {
        GuiControl, CavebotGUI:-g, LV_CreaturesSpells

        this.LoadSpellsLV()
        ; try
        ; catch e {
        ; Msgbox, 48,, % e.Message
        ; }
        Sleep, 50
        GuiControl, CavebotGUI:+gLV_CreaturesSpells, LV_CreaturesSpells
    }

    LV_Creatures() {
        GuiControl, CavebotGUI:-g, LV_Creatures
        creatureName := _ListviewHandler.getSelectedItemOnLV("LV_Creatures", 1)
        if (creatureName = "" OR creatureName = txt("Nome", "Name")) {
            GuiControl, CavebotGUI:+gLV_Creatures, LV_Creatures
            return
        }

        this.loadCreatureInfo(creatureName)
        Sleep, 50
        GuiControl, CavebotGUI:+gLV_Creatures, LV_Creatures
    }

    filterCreatureList() {
        Gui, AddCreatureGUI:Default
        GuiControlGet, searchFilterCreatureName
        GuiControlGet, searchFilterExactCreatureName
        GuiControlGet, searchFilterHaveImage
        this.LoadCreatureListLV(searchFilterCreatureName, searchFilterExactCreatureName)
    }

    createCreatureListImageList()
    {
        static created
        if (created) {
            return
        }

        created := true

        Gui, ListView, LV_CreatureList
        IL_Destroy(IMAGE_LIST_LV_CreatureList)  ; Required for image lists used by tab_name controls.

        IconWidth    :=  18
            , IconHeight   := 18
            , IconBitDepth := 24 ;
            , InitialCount :=  1 ; The starting Number of Icons available in ImageList
            , GrowCount    :=  1

        Gui, ListView, LV_CreatureList
        IMAGE_LIST_LV_CreatureList  := DllCall( "ImageList_Create", Int,IconWidth,    Int,IconHeight
            , Int,IconBitDepth, Int,InitialCount
            , Int,GrowCount )
        Gui, ListView, LV_CreatureList
        LV_SetImageList( IMAGE_LIST_LV_CreatureList, 1 ) ; 0 for large icons, 1 for small icons

        Loop 6 {
            if (A_Index = 5) {
                IL_Add(IMAGE_LIST_LV_CreatureList,"Data\Files\Images\GUI\Icons\running2.ico", 1)
                continue
            }
            IL_Add(IMAGE_LIST_LV_CreatureList, "Data\Files\Images\GUI\scale-circ.icl", A_Index)
        }

    }

    LoadCreatureListLV(searchFilterCreatureName := "", searchFilterExactCreatureName := 0, searchFilterHaveImage := 0) {
        try {
            _ListviewHandler.loadingLV("LV_CreatureList", "AddCreatureGUI")
        } catch e {
            return
        }

        this.createCreatureListImageList()

        index := 1
        for creatureName, creatureObj in creaturesObj
        {
            ; if (InStr(creatureObj.hp, "?", 0) OR InStr(creatureObj.exp, "?", 0))
            ; continue
            ; if (InStr(creatureObj.hp, "--", 0) OR InStr(creatureObj.exp, "--", 0))
            ; continue
            if (containsSpecialCharacter(creatureName) = true)
                continue


            if (searchFilterCreatureName != "") {
                switch searchFilterExactCreatureName {
                    case 0:
                        if (!InStr(creatureName, searchFilterCreatureName, 0))
                            continue
                    case 1:
                        if (creatureName != searchFilterCreatureName)
                            continue
                }
            }

            valid := this.isValidCreatureImage(creatureName, loadTargetList := false)

            ; if (creatureName = "acid blob")
            ; msgbox,% creatureName "`n" serialize(valid)

            if (searchFilterHaveImage = 1) && (valid.valid = false)
                continue

            Gui, ListView, LV_CreatureList
            ; LV_Add("Icon7", "" A_Index, type, label, coordinates, range, action) ; no icon
            icon := (valid.valid = false) ? "Icon0" : "Icon6"
            LV_Add(icon, index, creatureName, creatureObj.exp, creatureObj.hp, creatureObj.maxdmg, creatureObj.primarytype, creatureObj.runsat, creatureObj.walksaround, creatureObj.walksthrough, creatureObj.senseinvis, creatureObj.behaviour )
            index++
            if (showAllCreaturesList = false) && (index > 100)
                break
        }

        Loop, % this.columnsCountLV_CreatureList {
            Gui, ListView, LV_CreatureList
            LV_ModifyCol(A_Index, "autohdr")
        }

        LV_ModifyCol(3, 50) ; exp
        LV_ModifyCol(4, 50) ; hp
        LV_ModifyCol(5, 90) ; MaxDmg
        LV_ModifyCol(6, 90) ; type
        LV_ModifyCol(7, 50) ; RunsAt

        _ListviewHandler.setColumnInteger(1, "LV_CreatureList", "AddCreatureGUI")
        _ListviewHandler.setColumnInteger(3, "LV_CreatureList", "AddCreatureGUI") ; exp
        _ListviewHandler.setColumnInteger(4, "LV_CreatureList", "AddCreatureGUI") ; hp
        _ListviewHandler.setColumnInteger(5, "LV_CreatureList", "AddCreatureGUI") ; MaxDmg
        _ListviewHandler.setColumnInteger(7, "LV_CreatureList", "AddCreatureGUI") ; RunsAt


        return
    }

    LoadSpellsLV()
    {
        Gui, CavebotGUI:Default

        selectedCreature :=  _ListviewHandler.getSelectedItemOnLV("LV_CreaturesSpells", 1)
        if (selectedCreature = "" OR selectedCreature = "Name") {
            return
        }
        try GuiControl, CavebotGUI:, creatureNameSpell, % selectedCreature
        catch {
        }
        try GuiControlGet, creatureNameSpell
        catch {
        }


        try {
            _ListviewHandler.loadingLV("LV_Spells", "CavebotGUI")
        } catch {
            return
        }

        for key, spell in targetingObj.targetList[creatureNameSpell]["attackSpells"]
        {
            Gui, ListView, LV_Spells
            switch spell.type {
                Case "Support":
                    type := spell.supportSpell
                case "Attack":
                    if (spell.cooldownSpell = "Default")
                        Type := "Attack"
                    else
                        Type := spell.cooldownSpell
            }

            playerSafe := (spell.playerSafe = 1) ? "true" : "false"
            onlyWithPlayer := (spell.onlyWithPlayer = 1) ? "true" : "false"
            if (isTibia13()) {
                playerSafe := "----"
                onlyWithPlayer := "----"
            }

            LV_Add("", A_Index
                , boolToString(spell.enabled)
                , ((TargetingSystem.targetingJsonObj.attackSpells.useScriptImageForRunes = true && spell.scriptImage != "") ? spell.scriptImage : spell.hotkey)
                ; , boolToString(spell.enabled || spell.enabled = 1 ? 1 : 0)
                , (!clientHasFeature("cooldownBar") ? spell.cooldown : type)
                , spell.mana
                , spell.targetLife
                , spell.creatureCount
                , spell.countMethod
                , spell.countPolicy
                , spell.mode
                , spell.turnToDirection = 1 ? "true" : "false"
                , playerSafe " / " onlyWithPlayer)
        }

        Loop, 11
            LV_ModifyCol(A_Index,"AutoHdr")

        this.changeSpellsControls("Enable")
        Gui, CopySpellGUI:Destroy
    }


    loadCreatureInfo(creatureName) {
        Gui, CavebotGUI:Default


        for key, value in this.checkboxList
        {
            GuiControl,, %value%, % (targetingObj.targetList[creatureName][StrReplace(value, "creature", "")] = "") ? 0 : targetingObj.targetList[creatureName][StrReplace(value, "creature", "")]
        }

        for key, control in this.dropdownList
        {
            ; if (control = "creatureIgnoreIfNotReachedTime")
            ; msgbox, % creatureName " = " targetingObj.targetList[creatureName][StrReplace(control, "creature", "")]
            value := targetingObj.targetList[creatureName][StrReplace(control, "creature", "")]
            GuiControl, CavebotGUI:ChooseString, % control, % value

            if (!this[control].isHidden()) {
                GuiControl, CavebotGUI:Show, % control ; for some reason controls with + in the value are getting hidden
            }
        }

        for key, control in this.editList
        {
            GuiControlEdit("CavebotGUI", control, targetingObj.targetList[creatureName][StrReplace(control, "creature", "")])
            if (control = "creatureName")
                continue

            GuiControl, +gsubmitTargetOptionHandler, %control%
        }


        valid := this.isValidCreatureImage(creatureName)

        ; if (targetingObj.targetList[creatureName]["image"] != "") {
        if (valid.redIcon = false) {
            this.loadCreatureImage(creatureName)
        } else {
            GuiControl, CavebotGUI:, creatureImage, Data\Files\Images\GUI\Cavebot\default_creature_image.png
        }

        GuiControl,, creatureName, % creatureName
        this.changeAllControls("enable")

        GuiControl, % targetingObj.targetList[creatureName].image = "" ? "CavebotGUI:Disable" : "CavebotGUI:Enable", testCreatureImage

        if (targetingObj.targetList[creatureName].ignoreAttacking = false)
            GuiControl, CavebotGUI:Disable, creatureIgnoreAfter

        if (targetingObj.targetList[creatureName].useItemOnCorpse = false) {
            GuiControl, CavebotGUI:Disable, creatureCorpseItemHotkey
            GuiControl, CavebotGUI:Disable, creatureitemUseOnCorpse
        }

        this.defaultCreatureLoadControls(creatureName)
    }

    defaultCreatureLoadControls(creatureName) {
        action := (creatureName = TargetingSystem.defaultCreature) ? "Disable" : "Enable"

        GuiControl, CavebotGUI:%action%, testCreatureImage
        GuiControl, CavebotGUI:%action%, getCreatureImage
        GuiControl, CavebotGUI:%action%, creatureDanger
        GuiControl, CavebotGUI:%action%, creatureonlyIftrapped
        GuiControl, CavebotGUI:%action%, creatureImageWidth
    }

    loadCreatureImage(creatureName) {
        pBitmap := GdipCreateFromBase64(targetingObj.targetList[creatureName]["image"])
            , hBitmap:=Gdip_CreateHBITMAPFromBitmap(pBitmap)
        GuiControl, CavebotGUI:, creatureImage, % "HBITMAP:*" hBitmap
        ; size := (_Ravendawn.CREATURE_IMAGE_SIZE * 2)
        ; GuiControl, CavebotGUI:MoveDraw, creatureImage, % "w" size " h" size
        Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
    }

    changeAllControls(action) {
        for key, value in this.controlsList
        {
            switch action {
                case "enable":
                    if (jsonConfig("targeting", "options", "disableCreatureLifeCheck")) {
                        if (value = "creaturelifeStopAttack") {
                            continue
                        }

                        if (InStr(value, "Exeta")){
                            continue
                        }
                    }

                    if (value = "creatureIgnoreAfter") {
                        if (targetingObj.targetList[creatureName].creatureIgnoreAttacking = false)
                            continue
                    }

                    if (value = "creatureCorpseItemHotkey" OR value = "creatureitemUseOnCorpse") {
                        if (targetingObj.targetList[creatureName].useItemOnCorpse = false)
                            continue
                    }

                    if (value = "creatureopenBagInsideCorpse") && (LootingSystem.lootingJsonObj.options.openCorpsesAround != true || uncompatibleModule("looting"))
                        continue

                    if (uncompatibleModule("itemRefill")) {
                        if (InStr(value, "creatureRing") || InStr(value, "creatureAmulet")) {
                            continue
                        }
                    }

                case "disable":
            }
            try GuiControl, CavebotGUI:%action%, %value%
            catch {
            }
        }

        if (action = "enable") {
            ; try GuiControl, CavebotGUI:Disable, creatureName
            ; catch {
            ; }
        }
        if (action = "Disable") {
            creatureName := "",
            try GuiControl, CavebotGUI:, creatureName, % ""
            catch {
            }
        }

        for key, value in this.disabledControls
        {
            try GuiControl, CavebotGUI:Disable, % value
            catch {
            }
        }

    }

    ChildTab_Creatures() {
        global
        ; IL_Destroy(IMAGE_LIST_LV_Creatures)
        ; IMAGE_LIST_LV_Creatures := "", aFilepath := "Data\Files\Images\GUI\Others\scale-circ.icl", IMAGE_LIST_LV_Creatures := IL_Create(6)
        ; Loop 6 {
        ;     if (A_Index = 5) {
        ;         IL_Add(IMAGE_LIST_LV_Creatures,"Data\Files\Images\GUI\Icons\running2.ico", 1)
        ;         continue
        ;     }
        ;     IL_Add(IMAGE_LIST_LV_Creatures, aFilepath, A_Index)
        ; }




        w := tabsWidth - 20
        h := tabsHeight - 37
        Gui CavebotGUI:Add, GroupBox, x15 y+6 w%w% h%h% Section,
        Gui CavebotGUI:Add, Checkbox, xs+10 ys+0 vTargetingEnabled gTargetingEnabled hwndhTargetingEnabled Checked%TargetingEnabled%, % txt("Targeting ", "Targeting ") lang("enabled")
        TT.Add(hTargetingEnabled, "Enable and start the Targeting")


            new _ControlFactory(_ControlFactory.SETTINGS_BUTTON)
            .event(new _TargetingSettingsGUI().open.bind(new _TargetingSettingsGUI()))
            .tt("Configurações do Targeting", "Targeting settings")
            .add()


        if (OldbotSettings.uncompatibleModule("cavebot") = true) {
                new _ControlFactory(_ControlFactory.SET_GAME_AREAS_BUTTON)
                .xadd(10).ys(-3).w(150).h(22)
                .add()
        }


        ; Gui, CavebotGUI:Add, Button, xs+10 yp+25 h21 w145 vAddCreatureGUI gAddCreatureGUI hwndhAddCreatureGUI, % txt(
            new _Button().title("Adicionar &nova criatura", "Add &new creature")
            .xs(10).yp(25).w(145).h(21)
            .event(this.addCreature.bind(this))
            .icon(_Icon.get(_Icon.PLUS), "a0 l3 s14 b0")
            .add()

            new _Button().title(lang("delete"))
            .name("deleteCreature")
            .x().yp().w(80).h(21)
            .event(_TargetingHandler.removeFromTargetList.bind(TargetingHandler))
            .icon(_Icon.get(_Icon.DELETE), "a0 l3 s14 b0")
            .add()
        ; GuiButtonIcon(DeletarMonstro_Button, "imageres.dll", 260, "a0 l2 s16 b1")



        h -= 61
        Gui, CavebotGUI:Add, ListView, xs+10 y+5 w230 h%h% AltSubmit vLV_Creatures gLV_Creatures hwndhLV_Creatures LV0x1 LV0x20, % txt("Nome", "Name") "|Danger"
        Gui, ListView, LV_Creatures

        ; LV_CreaturesColors.OnMessage(False)
        ; LV_CreaturesColors := ""
        ; LV_CreaturesColors := new LV_Colors(hLV_Creatures, true, false, true)
        ; LV_CreaturesColors.Critical := 100

        y := 70
        x := 265
        h += 33
        Gui, CavebotGUI:Add, Groupbox, x%x% y%y% w555 h%h% Section, % txt("Editar criatura", "Edit creature")
        ; Gui, CavebotGUI:Add, Text, xp+12 yp+18, % LANGUAGE = "PT-BR" ? "Monstro:" : "Creature:"
        ; Gui, CavebotGUI:Add, Edit, x%x_childs% yp+23 w205 h19 gSalvarNomeMonstro vNovoNomeMonstro Limit40, %selectedCreature%


        Gui, CavebotGUI:Add, Text, xs+10 ys+17, % txt("Criatura:", "Creature:")
        Gui, CavebotGUI:Add, Edit, xp+0 y+3 h18 w150 vcreatureName ReadOnly,
        ; Gui, CavebotGUI:Add, Updown, Range1-9 0x80,

        this.creatureImageElements()


        DisabledNotManualLooting := (LootingSystem.lootingJsonObj.options.openCorpsesAround != true) ? "Disabled" : ""


        h_biggerGroups := 180
        h_smallerGroups := 184

        h_conditionsAndOptions := h_biggerGroups - 30
        Gui, CavebotGUI:Add, Groupbox, xs+10 y168 w205 h%h_biggerGroups% Section, % txt("Condições e Opções", "Conditions and Options")

        Gui, CavebotGUI:Add, Text, xs+10 yp+25 Right w60, Danger:
        Gui, CavebotGUI:Add, Edit, xs+77 yp-2 h18 w115 vcreaturedanger hwndhcreatureDanger 0x2000 Center,
        Gui, CavebotGUI:Add, Updown, Range1-9
        ; Gui, CavebotGUI:Add, Checkbox, xs+10 y+10 vcreaturemustAttackMe gsubmitTargetOptionHandler, Must attack me
        TT.Add(hcreatureDanger, txt("Criaturas com maior Danger tem prioridade para serem atacadas no Targeting(o bot procura pelas criaturas com maior Danger primeiro).", "Creatures with higher Danger have priority to be attacked by the Targeting(the bot searches for the creatures with higher Danger first)."))

        Gui, CavebotGUI:Add, Checkbox, xs+10 y+10 vcreatureonlyIftrapped hwndhcreatureonlyIftrapped gsubmitTargetOptionHandler, % (LANGUAGE = "PT-BR" ? "Atacar somente se trapado" : "Attack only if trapped")
        TT.Add(hcreatureonlyIftrapped, (LANGUAGE = "PT-BR" ? "Procurar por essa criatura para atacar somente quando o Cavebo detectar que o personagem está trapado" : "Only search for this creature to attack when the Cavebot detects that the character is trapped"))
        Gui, CavebotGUI:Add, Checkbox, xs+10 yp+25 vcreaturedontLoot hwndhcreaturedontLoot gsubmitTargetOptionHandler, % (LANGUAGE = "PT-BR" ? "Não lootear" : "Don't loot")
        TT.Add(hcreaturedontLoot, (LANGUAGE = "PT-BR" ? "Se marcado, não irá lootear após matar essa criatura" : "If checked, it will not loot after killing this creature"))

        ; GuiButtonIcon(UsarItemCorpo_Button, "mmcndmgr.dll", 87, "a0 l2 s14")


        h := h_smallerGroups + 30
        y_smallerGroups := "s+185"

        w_groupbox_targeting := 205
        Gui, CavebotGUI:Add, Groupbox, xs+0 y%y_smallerGroups% w205 h%h_smallerGroups%, % (LANGUAGE = "PT-BR" ? "Opções Extras" : "Extra options")

        Gui, CavebotGUI:Add, Checkbox, xs+10 yp+25 vcreatureplayAlarm hwndhcreatureplayAlarm gsubmitTargetOptionHandler, % (LANGUAGE = "PT-BR" ? "Tocar alarme" : "Play alarm")
        TT.Add(hcreatureplayAlarm, (LANGUAGE = "PT-BR" ? "Tocar um som de alarme sempre que essa criatura for encontrada no Battle List" : "Play an alarm sound everytime this creature is found on the Battle Lis t"))

        Disabled := uncompatibleModule("looting") ? "Disabled" : ""
        Hidden := DisabledNotManualLooting ? "Hidden" : ""
        Gui, CavebotGUI:Add, Checkbox, xs+10 y+10 vcreatureopenBagInsideCorpse hwndhcreatureopenBagInsideCorpse gsubmitTargetOptionHandler %DisabledNotManualLooting% %Hidden% %Disabled%, % (LANGUAGE = "PT-BR" ? "Abrir bag dentro do corpo" : "Open bag inside corpse")
        TT.Add(hcreatureopenBagInsideCorpse, (LANGUAGE = "PT-BR" ? "Se marcado, irá procurar por uma ""bag"" para abrir no loot search area" : "If checked, it will search for a ""bag"" to open in the loot search area"))


        switch TargetingSystem.targetingJsonObj.useItemOnCorpse.customCorpseImages {
            case true:
                text := (LANGUAGE = "PT-BR" ? "`n`nIrá procurar pelas imagens adicionadas em Script Images com a categoria ""Corpse""." : "`n`nIt will search for the images added in the Script Images with the ""Corpse"" category.")
            default:
                text := (LANGUAGE = "PT-BR" ? "`n`nOBS: para essa função funcionar, a configuração do cliente ""Scale Using Only Integral Multiples"" deve estar marcada, se encontra em Interface > Game Window" : "`n`nPS: for this function to work, the Tibia client setting ""Scale Using Only Integral Multiples"" must be checked, it's found on Interface > Game Window")
        }


        Gui, CavebotGUI:Add, Checkbox, xs+10 y+10 w130 vcreatureuseItemOnCorpse hwndhcreatureuseItemOnCorpse gsubmitTargetOptionHandler, % txt("Usar item no corpo", "Use item on corpse")
        TT.Add(hcreatureuseItemOnCorpse, (LANGUAGE = "PT-BR" ? "Marque para procurar pelo corpo da criatura para usar item" : "Check to search for creature's corpse to skin.") text)

            new _Button().name("tutorialUseItemOnCorpse")
            .title("Tutorial")
            .tt("Tutorial sobre a funcionalidade de ""Usar item no corpo"".", "Tutorial about the ""Use item on corpse"" feature.")
            .x("+5").y("p-3").h(18)
        ; .option(hiddenControls)
            .event(Func("openUrl").bind("https://www.youtube.com/watch?v=d2uGbzEuNmg"))
            .add()


        if (OldBotSettings.settingsJsonObj.clientFeatures.useItemWithHotkey = true) {
            Gui, CavebotGUI:Add, Text, xs+10 y+7 Right w60 vcreatureCorpseItemText, Item hotkey:
            Gui, CavebotGUI:Add, Hotkey, xs+77 yp-2 h18 w115 vcreatureCorpseItemHotkey hwndhcreatureCorpseItemHotkey 0x2000,
            TT.Add(hcreatureCorpseItemHotkey, (LANGUAGE = "PT-BR" ? "Hotkey da ferramenta usada para tirar a pele do corpo, tal como uma Obsidian Knife" : "Hotkey of the tool used to skin the corpse, such as Obsidian Knife.") text)
        } else {
            Gui, CavebotGUI:Add, Text, xs+10 y+7 Right w60 vcreatureCorpseItemText, Item:
            Gui, CavebotGUI:Add, Edit, xs+77 yp-2 h18 w115 vcreatureitemUseOnCorpse hwndhcreatureitemUseOnCorpse,
            TT.Add(hcreatureitemUseOnCorpse, (LANGUAGE = "PT-BR" ? "Nome da ferramenta usada para tirar a pele do corpo, tal como uma Obsidian Knife.`nOBS: o nome do item deve ser igual ao nome na lista em Looting -> ItemList." : "Hotkey of the tool used to skin the corpse, such as Obsidian Knife.`nPS: the name of the item must be the same as the name in the list on Looting -> ItemList.") )
            SetEditCueBanner(hcreatureitemUseOnCorpse, txt("Nome do item...", "Item name..."))
        }


        ; if (TargetingSystem.targetingJsonObj.useItemOnCorpse.customCorpseImages = true)
            new _ControlFactory(_ControlFactory.SCRIPT_IMAGES_BUTTON)
            .name("creatureCorpseItemScriptImages")
            .xs(10).yadd(10).w(140)
            .hidden(hiddenControls ? true : false)
            .add()

        x_childs := x_groupbox + 10
        text_width := 85
        x_controls := x_groupbox + text_width + 17
        w_controls := 300 - text_width - 10

        y_offset := "10"

        w_groupbox_targeting := w_groupbox

        Gui, CavebotGUI:Add, Groupbox, x%x_groupbox% ys+0 w%w_groupbox% h%h_biggerGroups% Section, Killing strategy

        ; Gui, CavebotGUI:Add, Text, x%x_childs% yp+25 w%text_width% Right Disabled, Stance:
        ; Gui, CavebotGUI:Add, DDL, x%x_controls% yp-3 w%w_controls% vcreaturestance gsubmitTargetOptionHandler, ----||
        ; Gui, CavebotGUI:Add, DDL, x%x_controls% yp-3 w%w_controls% vcreaturestance gsubmitTargetOptionHandler, No change||Avoid wave|Keep distance

        ; Gui, CavebotGUI:Add, Text, x%x_childs% y+%y_offset% w%text_width% Right Disabled, Distance:
        ; Gui, CavebotGUI:Add, Combobox, x%x_controls% w%w_controls% yp-3 Disabled vcreaturedistanceSQM gsubmitTargetOptionHandler, ----||
        ; Gui, CavebotGUI:Add, Combobox, x%x_controls% w%w_controls% yp-3 Disabled vcreaturedistanceSQM gsubmitTargetOptionHandler, ----||1 sqm|2 sqms|3 sqms||4 sqms|5 sqms|6 sqms

        this.creatureAttackModeText := new _Text().title("Modo de ataque:", "Attack mode:")
            .name("creatureAttackModeText")
            .x(x_childs).yp(25).w(text_width)
            .hidden(jsonConfig("targeting", "options", "disableAttackModeChange"))
            .alignRight()
            .add()

        this.creatureAttackMode := new _Dropdown().title("No change||Stand / Defensive|Stand / Balanced|Stand / Offensive|Chase / Defensive|Chase / Balanced|Chase / Offensive")
            .name("creatureAttackMode")
            .x(x_controls).w(w_controls).yp(-3)
            .tt("Altera o modo de ataque após atacar a criatura, para um Targeting mais rápido sete para ""No Change""", "Change the attack mode after attacking the creature, for a faster Targeting set to ""No change""")
            .event("submitTargetOptionHandler")
            .hidden(jsonConfig("targeting", "options", "disableAttackModeChange"))
            .disabled()
            .add()


        ; Gui, CavebotGUI:Add, Text, x%x_childs% yp+25 w%text_width% vcreatureAttackModeText Right, % LANGUAGE = "PT-BR" ?
        ; Gui, CavebotGUI:Add, DDL, x%x_controls% yp-3 w%w_controls% Disabled vcreatureAttackMode hwndhcreatureattackMode gsubmitTargetOptionHandler,

        Disabled := uncompatibleModule("itemRefill") ? "Disabled" : ""
        Gui, CavebotGUI:Add, Text, x%x_childs% y+%y_offset% w%text_width% vcreatureringHotkeyText Right, % LANGUAGE = "PT-BR" ? "Equipar ring:" : "Equip ring:"
        Gui, CavebotGUI:Add, Hotkey, x%x_controls% w%w_controls% yp-3 h21 vcreatureringHotkey hwndhcreatureringHotkey gsubmitTargetOptionHandler Disabled,

        string := (LANGUAGE = "PT-BR" ? "`nPara desabiltiar sete a hotkey para ""Nenhum"" (pressionando espaço)" : "`nTo disable it set the hotkey to ""None""(pressing Space)")
        TT.Add(hcreatureringHotkey, (LANGUAGE = "PT-BR" ? "Equipar ring enquanto ataca a criatura." : "Equip ring while attacking the creature.") string)

        Gui, CavebotGUI:Add, Text, x%x_childs% y+%y_offset% w%text_width% vcreatureamuletHotkeyText Right, % LANGUAGE = "PT-BR" ? "Equipar amulet:" : "Equip amulet:"
        Gui, CavebotGUI:Add, Hotkey, x%x_controls% w%w_controls% yp-3 h21 vcreatureamuletHotkey hwndhcreatureamuletHotkey gsubmitTargetOptionHandler Disabled,
        TT.Add(hcreatureamuletHotkey, (LANGUAGE = "PT-BR" ? "Equipar amulet enquanto ataca a criatura." : "Equip amulet while attacking the creature.") string)


        Disabled := jsonConfig("targeting", "options", "disableCreatureLifeCheck") = true ? "Disabled" : ""
        w := w_controls / 3 - 2
        w -= 6
        Gui, CavebotGUI:Add, Text, x%x_childs% y+%y_offset% w%text_width% vcreatureexetaResHotkeyText Right, % LANGUAGE = "PT-BR" ? "Usar Exeta com:" : "Use Exeta with:"
        Gui, CavebotGUI:Add, Hotkey, x%x_controls% w%w% yp-2 h21 vcreatureexetaResHotkey hwndhcreatureexetaResHotkey gsubmitTargetOptionHandler 0x2000 %Disabled%,
        TT.Add(hcreatureexetaResHotkey, (LANGUAGE = "PT-BR" ? "Hotkey da magia Exeta res para usar." : "Hotkey of the Exeta Res spell to cast.") string)

        w += 5
        Gui, CavebotGUI:Add, Combobox, x+3 yp+0 w%w% yp vcreaturelifeToExetaRes hwndhcreaturelifeToExetaRes gsubmitTargetOptionHandler 0x2000 Disabled, ----||10`% HP|20`% HP|30`% HP|40`% HP|50`% HP|60`% HP|70`% HP|80`% HP|90`% HP|100`% HP
        TT.Add(hcreaturelifeToExetaRes, (LANGUAGE = "PT-BR" ? "Porcentagem de vida que a criatura precisa estar abaixo para começar a usar Exeta Res" : "Life percentage of the creature that must be below to start casting Exeta Res"))

        w += 7
        Gui, CavebotGUI:Add, Combobox, x+3 yp+0 w%w% yp vcreatureExetaResCooldown hwndhcreatureExetaResCooldown gsubmitTargetOptionHandler, 1 second|2 seconds|3 seconds|4 seconds|5 seconds|6 seconds||7 seconds|8 seconds|
        TT.Add(hcreatureExetaResCooldown, (LANGUAGE = "PT-BR" ? "Cooldown da magia do Exeta Res para usar novamente.`nO padrão é 6 segundos"  "Cooldown of the Exeta res spell to cast again`nDefault is 6 seconds"))

        text_width := 105
        x_controls := x_groupbox + text_width + 17
        w_controls := 300 - text_width - 10



        w_groupbox_targeting := w_groupbox
        Gui, CavebotGUI:Add, Groupbox, x%x_groupbox% y%y_smallerGroups% w%w_groupbox% h%h_smallerGroups% Section, % (LANGUAGE = "PT-BR" ? "Opções de ignorar criatura" : "Ignore creature options")

        ignoreTimeText := (LANGUAGE = "PT-BR" ? "Tempo para ignorar a criatura, o Targeting será ignorado e o Cavebot poderá rodar enquanto isto" : "Time to ignore the creature, the Targeting will be ignored and Cavebot will be able to run meanwhile")


        y_offsetCheckbox := y_offset + 2
        w := w_controls / 2 - 2
        Gui, CavebotGUI:Add, Checkbox, x%x_childs% yp+28 w%text_width% vcreatureIgnoreAttacking gsubmitTargetOptionHandler Checked%1%, % (LANGUAGE = "PT-BR" ? "Após atacar por:" : "After attacking for:")
        Gui, CavebotGUI:Add, Edit, x%x_controls% w%w% yp-3 h21 vcreatureIgnoreAfter hwndhcreatureIgnoreAfter Disabled, 60 seconds
        Gui, CavebotGUI:Add, DDL, x+3 yp+0 w%w% yp vcreatureIgnoreAfterTime hwndhcreatureIgnoreAfterTime gsubmitTargetOptionHandler Disabled, for 1 second|for 2 seconds|for 3 seconds||for 5 seconds|for 10 seconds|for 20 seconds|for 30 seconds|for 60 seconds|

        TT.Add(hcreatureIgnoreAfter, (LANGUAGE = "PT-BR" ? "Limite de tempo atacando para ignorar a criatura`nQuando ignorado, o Targeting é desablitado por 5 segundos e o Cavebot pode rodar enquanto isto" : "Attacking time limit to ignore the creature`nWhen ignored, Targeting is disabled for 5 seconds and Cavebot can run meanwhile"))


        Disabled := jsonConfig("targeting", "options", "disableCreatureLifeCheck") = true ? "Disabled" : ""

        this.creaturelifeStopAttackText := new _Text().title("Parar ataque com:", "Stop attack with:")
            .name("creaturelifeStopAttackText")
            .x(x_childs).yadd(y_offset).w(text_width)
            .hidden(jsonConfig("targeting", "options", "disableCreatureLifeCheck"))
            .alignRight()
            .add()

        this.creatureLifeStopAttack := new _Dropdown().title("----||10`% HP|20`% HP|30`% HP|40`% HP|50`% HP|60`% HP|70`% HP|80`% HP|90`% HP|100`% HP")
            .name("creatureLifeStopAttack")
            .x(x_controls).w(w_controls).yp(-3)
            .tt("Porcentagem de vida da criatura que deve estar abaixo para parar de atacar", "Life percentage of the creature that must be below to stop attacking it")
            .event("submitTargetOptionHandler")
            .hidden(jsonConfig("targeting", "options", "disableCreatureLifeCheck"))
            .disabled()
            .add()

        this.creatureIgnoreUnreachable := new _Text().title("Se inalcançável", "If unreachable", ":")
            .name("creatureIgnoreUnreachable")
            .x(x_childs).yadd(y_offset).w(text_width)
            .hidden(jsonConfig("targeting", "options", "disableCreatureUnreachableCheck"))
            .alignRight()
            .add()

        this.creatureIgnoreUnreachableTime := new _Dropdown().title("ignore for 1 second|ignore for 2 seconds|ignore for 3 seconds||ignore for 5 seconds|ignore for 10 seconds|ignore for 20 seconds|ignore for 30 seconds|ignore for 60 seconds|")
            .name("creatureIgnoreUnreachableTime")
            .x(x_controls).w(w_controls).yp(-3)
            .tt("Checa se a criatura está inalcançável, funciona somente com Follow Attack na criatura, em OTs onde a frase ""There is no way"" aparece com a criatura inalcançável.", "Check if the creature is unreachable, this only works when Follow Attacking the creature and in OTs where the phrase ""There is no way"" appears when the creature is unreachable.")
            .hidden(jsonConfig("targeting", "options", "disableCreatureUnreachableCheck"))
            .event("submitTargetOptionHandler")
            .disabled()
            .add()


        this.creatureIgnoreDistanceText := new _Text().title("Se a distância", "If distance", ":")
            .name("creatureIgnoreDistanceText")
            .x(x_childs).yadd(y_offset).w(text_width)
            .hidden(jsonConfig("targeting", "options", "disableCreaturePositionCheck"))
            .alignRight()
            .add()

        this.creatureIgnoreDistance := new _Dropdown().title("None||3+ sqms|4+ sqms|5+ sqms|6+ sqms|7+ sqms")
            .name("creatureIgnoreDistance")
            .x(x_controls).w(w_controls / 2 - 2).yp(-3)
            .tt("Distância da criatura para ignorando enquanto atacando.`nSe selecionado 6+ sqms, irá ignorar a criatura se a distância da criatura pro char for acima de 6 sqms.`nOBS: Funciona somente em clientes com full light", "Creature distance to ignore it while attacking.`nIf chosen 6+ sqms, it will ignore the creature if the distance from the character is higher than 6 sqms.`nPS: it only work in clients with full light")
            .event("submitTargetOptionHandler")
            .disabled()
            .hidden(jsonConfig("targeting", "options", "disableCreaturePositionCheck"))
            .add()

        this.creatureignoreDistanceTime := new _Dropdown().title("for 1 second|for 2 seconds|for 3 seconds||for 5 seconds|for 10 seconds|for 20 seconds|for 30 seconds|for 60 seconds|")
            .name("creatureignoreDistanceTime")
            .xadd(3).w(w_controls / 2 - 2).yp(0)
            .tt(ignoreTimeText)
            .event("submitTargetOptionHandler")
            .disabled()
            .hidden(jsonConfig("targeting", "options", "disableCreaturePositionCheck"))
            .add()


        this.creatureIgnoreIfNotReached := new _Checkbox().title("Se não alcançar a criatura em", "If not reach creature in", ":")
            .name("creatureIgnoreIfNotReached")
            .x(x_childs).yadd(y_offset).w(text_width)
            .tt("Analisa a distância da criatura nos primeiros 3 segundos atacando, se a distância é maior do que 2 sqms após 3 segundos, irá ignorar a criatura", "It analyzes the distance of the creature in the first 3 initial seconds attacking it, if the distance is higher than 2 sqms after the 3 seconds, it will ignore the creature")
            .hidden(jsonConfig("targeting", "options", "disableCreaturePositionCheck"))
            .event("submitTargetOptionHandler")
            .disabled()
            .add()

        this.creatureIgnoreIfNotReachedTime := new _Dropdown().title("2 seconds|3 seconds||5 seconds|10 seconds|20 seconds|30 seconds|60 seconds")
            .name("creatureIgnoreIfNotReachedTime")
            .x(x_controls).w(w).yp(-2)
            .tt("Distância da criatura para ignorando enquanto atacando.`nSe selecionado 6+ sqms, irá ignorar a criatura se a distância da criatura pro char for acima de 6 sqms.`nOBS: Funciona somente em clientes com full light", "Creature distance to ignore it while attacking.`nIf chosen 6+ sqms, it will ignore the creature if the distance from the character is higher than 6 sqms.`nPS: it only work in clients with full light")
            .event("submitTargetOptionHandler")
            .hidden(jsonConfig("targeting", "options", "disableCreaturePositionCheck"))
            .disabled()
            .add()

        this.creatureIgnoreIfNotReachedDuration := new _Dropdown().title("for 1 second|for 2 seconds|for 3 seconds||for 5 seconds|for 10 seconds|for 20 seconds|for 30 seconds|for 60 seconds|")
            .name("creatureIgnoreIfNotReachedDuration")
            .xadd(3).w(w_controls / 2 - 2).yp(0)
            .tt(ignoreTimeText)
            .event("submitTargetOptionHandler")
            .hidden(jsonConfig("targeting", "options", "disableCreaturePositionCheck"))
            .disabled()
            .add()

        TT.Add(hcreatureIgnoreAfterTime, ignoreTimeText)


        _GuiHandler.tutorialButtonModule("Targeting")

    }


    creatureImageElements()
    {
        global

        x_groupbox := 490
        w_groupbox := 320

        Gui, CavebotGUI:Add, Groupbox, x%x_groupbox% ys+20 w%w_groupbox% h72, % LANGUAGE = "PT-BR" ? "Imagem da criatura" : "Creature image"

        x := x_groupbox + 13
        ; Gui, CavebotGUI:Add, Picture, xp+92 yp+19 w135 h14 vcreatureImage, Data\Files\Images\GUI\Cavebot\default_creature_image.png

            new _Picture().name("creatureImage")
            .xp(92).yp(19).w(135).h(14)
            .image("Data\Files\Images\GUI\Cavebot\default_creature_image.png")
            .add()

            new _Button().title("Capturar &imagem", "Get &image")
            .name("GetCreatureImage")
            .x(x).y().w(115).h(22)
            .event("GetCreatureImage")
            .disabled()
            .icon(_Icon.get(_Icon.CAMERA), "a0 l3 b0 s14")
            .add()

            new _Button().title("Testar imagem", "Test image")
            .name("testCreatureImage")
            .xadd(2).yp().w(82).h(22)
            .event("testCreature")
            .disabled()
        ; .icon(_Icon.get(_Icon.CAMERA), "a0 l3 b0 s14")
            .add()

        ; Gui, CavebotGUI:Add, Button, x+2 yp+0 w82 h22 vtestCreatureImage gtestCreature hwndTestarMonstro_Button, % "&" txt("Testar imagem", "Test image")

        Gui, CavebotGUI:Add, DropdownList, x+2 yp+0 w94 vcreatureImageWidth gcreatureImageWidth hwndhcreatureImageWidth AltSubmit, % TargetingSystem.creatureImageWidthsDropdown

        if creatureImageWidth is not number
        {
            GuiControl, CavebotGUI:Choose, creatureImageWidth, % TargetingSystem.creatureImageWidths.MaxIndex()
        } else
            GuiControl, CavebotGUI:Choose, creatureImageWidth, % creatureImageWidth

        ; GuiButtonIcon(TutorialMonstro_Button, "imageres.dll", 77, "a0 l2 s12")
        TT.Add(hcreatureImageWidth, (LANGUAGE = "PT-BR" ? "Nessa opção é possível alterar a largura da imagem da criatura, caso por algum motivo a largura padrão de 118 pixels esteja atrapalhando, você pode diminuir a largura para capturar uma imagem menor." : "In this option is possible to change the width of the creature image, in case for any reason the default width of 118 pixels is getting in the way of something, you can decrease the width to get a smaller image."))

    }

    ChildTab_Spells() {
        global


        moduleDisabled := false
        if (uncompatibleFunction("targeting", "attackSpells") = true) {
            moduleDisabled := _GuiHandler.uncompatibleModuleWarning()
        }

        w := 250
        h := tabsHeight - (moduleDisabled = false ? 37 : 60)
        Gui CavebotGUI:Add, GroupBox, x15 y+6 w%w% h%h% Section,

        h -= 26
        Gui, CavebotGUI:Add, ListView, xs+10 ys+15 w230 h%h% AltSubmit vLV_CreaturesSpells gLV_CreaturesSpells hwndhLV_CreaturesSpells LV0x1 LV0x20, Name|Spells

        Gui, ListView, LV_CreaturesSpells
        LV_SetImageList(iconsIL_LV_Creatures) ; attach images to ListView

        h += 26
        Gui, CavebotGUI:Add, Groupbox, xs+259 ys+0 w555 h%h% Section, Edit attack spells/runes
        Gui, CavebotGUI:Add, Text, xs+15 ys+20, Creature:
        Gui, CavebotGUI:Add, Edit, xp+0 y+3 h22 w150 vcreatureNameSpell Disabled,


            new _Button().title("Clonar magias para...", "Clone spells to...")
            .name("CloneAttackSpells")
            .xadd(3).yp().w(135).h(22)
            .event("CloneAttackSpells")
            .icon(_Icon.get(_Icon.DUPLICATE), "a0 l3 b0 s16")
            .add()

        ; Gui, CavebotGUI:Add, Button, x+3 yp+0 w120 h22 vCloneAttackSpells gCloneAttackSpells, %


        Gui, CavebotGUI:Add, ListView, xs+15 yp+25 vLV_Spells gLV_Spells w525 r8 LV0x1 LV0x20 -Multi NoSort AltSubmit, % "Order|Enabled|Hotkey|" (!clientHasFeature("cooldownBar") ? "Cooldown" : "Type") "|MP %|HP %|Count|Method|Policy|Mode|Turn|Player safe"


        ; new _Button().title(selectedSpell = 0 ? txt("Adicionar magia", "Add spell") : txt("Salvar magia", "Save spell"))
        ; .name("AddAttackSpell")
        ; .xp(0).y().w(140).h(22)
        ; .tt("Clique com o botão direito na magia para ativar/desativar.", "Right click on the spell to enable/disable.")
        ; .event("AddAttackSpell")
        ; .icon(_Icon.get(_Icon.PLUS), "a0 l3 b0 s14")
        ; .add()

        Gui, CavebotGUI:Add, Button, xp+0 y+5 w140 h22 vAddAttackSpell gAddAttackSpell hwndAdicionarMagia_Button, % txt("Add &nova magia", "Add &new spell")
        TT.Add(AdicionarMagia_Button, txt("Clique com o botão direito na magia para ativar/desativar.", "Right click on the spell to enable/disable."))
        icon := _Icon.get(_Icon.PLUS)
        GuiButtonIcon(AdicionarMagia_Button, icon.dllName, icon.number, "a0 l3 b0 s14")

            new _Button().title("&Deletar magia", "&Delete spell")
            .xadd(3).yp().w(100).h(22)
            .event("DeleteAttackSpell")
            .icon(_Icon.get(_Icon.DELETE), "a0 l3 s14 b0")
            .add()

        ; Gui, CavebotGUI:Add, Button, x+3 yp+0 w100 h22 vDeleteAttackSpell gDeleteAttackSpell hwndDeleteAttackSpell_Button, % txt("Deletar magia", "Delete spell")

            new _Button().title("Move &Up")
            .name("moveSpellUp")
            .xadd(3).yp().w(90).h(22)
            .event("moveAttackSpell")
            .icon(_Icon.get(_Icon.ARROW_UP), "a0 l3 b0 s18")
            .add()

            new _Button().title("Move D&own")
            .name("moveSpellDown")
            .xadd(3).yp().w(90).h(22)
            .event("moveAttackSpell")
            .icon(_Icon.get(_Icon.ARROW_DOWN), "a0 l3 b0 s18")
            .add()

        ; new _Text().title()
        ; .xs(10).yadd(10)
        ; .color("gray")
        ; .add()

            new _Button().title("Tutorial Attack Spells")
            .x("s+10").y("+10").h(22).w(140)
            .event(Func("openUrl").bind("https://youtu.be/WmVNpqwW7iE?si=FgnN_YEbsNv60LBD&t=323"))
            .icon(_Icon.get(_Icon.YOUTUBE), "a0 l2 b0 s14")
            .add()
    }

    changeSpellsControls(action) {
        controls := {}
        controls.Push("LV_Spells")
        controls.Push("AddAttackSpell")
        ; controls.Push("CopyAttackSpell")
        controls.Push("EditAttackSpell")
        controls.Push("DeleteAttackSpell")
        controls.Push("CloneAttackSpells")
        controls.Push("moveSpellUp")
        controls.Push("moveSpellDown")

        for key, value in controls {
            try {
                GuiControl, CavebotGUI:%action%, %value%
            } catch {
            }
        }
    }

    loadTargetListLV(creaturesSpells := false) {

        LV := (creaturesSpells = false) ? "LV_Creatures" : "LV_CreaturesSpells"

        try {
            _ListviewHandler.loadingLV(LV, "CavebotGUI")
        } catch e {
            return
        }

        Gui, ListView, %LV%
        IL_Destroy(IMAGE_LIST_%LV%)  ; Required for image lists used by tab_name controls.

        IconWidth    :=  18
            , IconHeight   := 18
            , IconBitDepth := 24 ;
            , InitialCount :=  1 ; The starting Number of Icons available in ImageList
            , GrowCount    :=  1

        Gui, ListView, %LV%
        IMAGE_LIST_%LV%  := DllCall( "ImageList_Create", Int,IconWidth,    Int,IconHeight
            , Int,IconBitDepth, Int,InitialCount
            , Int,GrowCount )
        Gui, ListView, %LV%
        LV_SetImageList( IMAGE_LIST_%LV%, 1 ) ; 0 for large icons, 1 for small icons

        Loop 6 {
            if (A_Index = 5) {
                IL_Add(IMAGE_LIST_%LV%,"Data\Files\Images\GUI\Icons\running2.ico", 1)
                continue
            }
            IL_Add(IMAGE_LIST_%LV%, "Data\Files\Images\GUI\scale-circ.icl", A_Index)
        }

        this.targetListLvRow(LV, creaturesSpells, TargetingSystem.defaultCreature, targetingObj.targetList[TargetingSystem.defaultCreature])

        for creatureName, creatureObj in targetingObj.targetList
        {
            if (creatureName = TargetingSystem.defaultCreature)
                continue
            invalidCreature := false

            for key, value in TargetingHandler.creatureSettings
            {
                if (value = creatureName) {
                    invalidCreature := true
                    break
                }
            }
            if (invalidCreature = true)
                continue
            this.targetListLvRow(LV, creaturesSpells, creatureName, creatureObj)
            ; msgbox, %creatureName% %A_DefaultListview%
        }

        try GuiControl, CavebotGUI:Enable, %LV%
        catch {
        }

        Loop, 3 {
            Gui, ListView, %LV%
            LV_ModifyCol(A_Index,"AutoHdr")
        }

        switch creaturesSpells {
            case false:
                /*
                red icon for monsters with no image
                */
                for creatureName, creatureObj in targetingObj.targetList
                {
                    valid := this.isValidCreatureImage(creatureName)
                    ; msgbox, % creatureName "`n" serialize(valid) "`n`n" targetListOj[creatureName].os "`n" creaturesImageObj[creatureName]["os"]

                    if (valid.orangeIcon = false && valid.redIcon = false)
                        continue

                    row := _ListviewHandler.findRowByContent(creatureName, 1, LV, defaultGUI := "CavebotGUI")
                    if (row > 0) {
                        Gui, ListView, %LV%
                        ; msgbox, % creatureName "\" orangeIcon

                        LV_Modify(row, valid.orangeIcon = true ? "Icon2" : "Icon1")
                    }
                }
            case true:
                this.checkSpellIconLV()

        }

    }

    targetListLvRow(LV, creaturesSpells, creatureName, creatureObj) {
        onlyIfTrappedString :=  ""
        if (creaturesSpells = false) && (targetingObj.targetList[creatureName].onlyIfTrapped = true)
            onlyIfTrappedString := " (trapped)"
        try Gui, ListView, %LV%
        catch {
        }

        LV_Add("Icon7", creatureName, (creaturesSpells = false ? creatureObj.danger : targetingObj.targetList[creatureName]["attackSpells"].Count()) onlyIfTrappedString)
    }

    isValidCreatureImage(creatureName, loadTargetList := true)
    {
        if (creatureName = TargetingSystem.defaultCreature)
            return {redIcon: false, orangeIcon: false, valid: true}

        /*
        if the creature image of creature_images.json is windows (new image)
        and the current from the script isnt
        */
        switch loadTargetList {
            case true:
                ; if (creatureName = "rotworm")
                ; msgbox, % serialize(targetingObj.targetList[creatureName])
                if (targetingObj.targetList[creatureName].image = "")
                    return {redIcon: true, orangeIcon: false, valid: false}

                if (targetingObj.targetList[creatureName].client != "") && (targetingObj.targetList[creatureName].client != TibiaClient.getClientIdentifier())
                    return {redIcon: false, orangeIcon: true, valid: true}

                ; if (targetingObj.targetList[creatureName].os != "" && creaturesImageObj[creatureName]["os"] != "windows")
                ;     return {redIcon: false, orangeIcon: true, valid: false}
                ; if (targetingObj.targetList[creatureName].os = "" && creaturesImageObj[creatureName]["os"] = "")
                ;     return {redIcon: false, orangeIcon: true, valid: false}
            case false:

                if (customCreaturesImageFile) && (customCreaturesImageObj[creatureName].image = "") {
                    return {redIcon: true, orangeIcon: false, valid: false}
                } else if (creaturesImageObj[creatureName].image = "") {
                    return {redIcon: true, orangeIcon: false, valid: false}
                }

                ; if (creaturesImageObj[creatureName].client != "") && (creaturesImageObj[creatureName].client != TibiaClient.getClientIdentifier())
                ;     return {redIcon: false, orangeIcon: true, valid: false}
        }

        return {redIcon: false, orangeIcon: false, valid: true}
    }

    checkSpellIconLV() {

        /*
        -- add green icon for monsters with spell
        update spell count
        */
        LV := "LV_CreaturesSpells"
        for creatureName, creatureObj in targetingObj.targetList
        {
            row := _ListviewHandler.findRowByContent(creatureName, 1, LV, defaultGUI := "CavebotGUI")
            if (row < 1)
                continue
            Gui, ListView, %LV%
            LV_Modify(row, "", creatureName, targetingObj.targetList[creatureName]["attackSpells"].Count())
            ; if (!targetingObj.targetList[creatureName].attackSpells.1)
            ; LV_Modify(row, "Icon7", creatureName, targetingObj.targetList[creatureName]["attackSpells"].Count())
            ; else
            ; LV_Modify(row, "Icon5", creatureName, targetingObj.targetList[creatureName]["attackSpells"].Count())
        }
    }

    readIniTargetingGUISettings() {
        global

        loop, % targetingControlsTotal
            IniRead, targetingControlsHidden%A_Index%, %DefaultProfile%, gui_targeting, targetingControlsHidden%A_Index%, 1
    }

    getTargetingControlHiddenButtonText(number) {
        return (targetingControlsHidden%number% = 0) ? txt("Ocultar", "Hide") : txt("Mostrar", "Show")
    }

    toggleTargetingControlsHidden() {
        Gui, CavebotGUI:Submit, NoHide
        number := StrReplace(A_GuiControl, "targetingControlsHidden", "")
        value := !targetingControlsHidden%number%
        targetingControlsHidden%number% := value
        IniWrite, % value, %DefaultProfile%, gui_targeting, targetingControlsHidden%number%

        GuiControl, CavebotGUI:, targetingControlsHidden%number%, % this.getTargetingControlHiddenButtonText(number)
    }

    addCreature()
    {
        TargetingGUI.createAddCreatureGUI()
        return

        try {
            name := _CreaturesHandler.addCreatureInputBox()
        } catch e {
            if (e.Message == 1) {
                return
            }

            _Logger.msgboxException(48, e)
            return
        }

        TargetingHandler.addToTargetList(_Arr.wrap(name))
    }

}