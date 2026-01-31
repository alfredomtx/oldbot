
Class _SioGUI extends _BaseClass
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        if (_SioGUI.INSTANCE) {
            return _SioGUI.INSTANCE
        }

        this.settings := new _SioSettings()

        this.listviewLoadableControls := {}

        this.enabledText := LANGUAGE = "PT-BR" ? "Ativar Sio" : "Enable Sio"
        this.disabledText := LANGUAGE = "PT-BR" ? "Desativar Sio" : "Disable Sio"

        _SioGUI.INSTANCE := this
    }

    PostCreate_SioGUI()
    {

        if (OldbotSettings.uncompatibleModule("sioFriend") = true)
            return

        this.loadSioListLV()
        this.defaultPlayerImage()

        this.sioRuneName.list(this.getSioItemsList())
    }

    set(control)
    {
        _Validation.instanceOf("control", value, _AbstractControl)
        return this.controls[control.getName()] := control
    }

    /**
    * @return string
    */
    getPlayerName()
    {
        return this.get("playerName").get()
    }

    /**
    * @return _AbstractControl
    */
    get(controlName)
    {
        _Validation.hasKey(this.__Class ".controlName", this, controlName)
        return this[controlName]
    }

    createSioGUI()
    {
        global

        main_tab := "Sio"
        child_tabs_%main_tab% := "Settings"

        Gui, CavebotGUI:Add, Tab2, x6 vTab_%main_tab% y%y_tab% w%tabsWidth% h%tabsHeight% hWndhTab_%main_tab% %TabStyle% +Theme, % child_tabs_%main_tab%
        if (load_order[1] != main_tab)
            GuiControl, Hide, Tab_%main_tab% ; esconder a tab antes de adicionar os elementos a ela

        if (OldbotSettings.uncompatibleModule("sioFriend") = true) {
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
                    this.ChildTab_SioSettings()
            }
        }

        return


    }

    ChildTab_SioSettings() {
        global

        mod := 50
        w_lv := w_LVWaypoints - mod
        w_group := 150 + 10

        this.colums := "Player Name|Enabled|Hotkey|Rune|Sio HP|Gran Sio|Gran Sio HP|HP|MP|Follow|Attack|Creatures|Rune Hotkey"

        Gui, CavebotGUI:Add, ListView, x15 y+6 h%LV_Waypoints_height% w%w_lv% AltSubmit -Multi vLV_SioList gLV_SioList hwndhLV_SioList LV0x1 LV0x10, % this.colums

        x_group1 := x_groupbox_listview - mod

        w_group := 150 + mod
        w_controls := w_group - 20

        Disabled := ""



        Gui, CavebotGUI:Add, Groupbox, x%x_group1% y50 w%w_group% h55 Section, Add Player
        w := w_controls / 2 - 2

            new _ControlFactory(_ControlFactory.ADD_NEW_BUTTON)
            .w(w + 15)
            .event(this.addNewPlayerEvent.bind(this))
            .add()

            new _Button().title(lang("delete"))
            .x("+3").y("p+0").w(w - 15)
            .tt("Segure ""Ctrl"" para pular o diálogo de confirmação", "Hold ""Ctrl"" to skip the confirmation dialog")
            .event(this.deletePlayer.bind(this))
            .icon(_Icon.get(_Icon.DELETE), "a0 l3 s14 b0")
            .add()

        Gui, CavebotGUI:Add, Groupbox, x%x_group1% y+20 w%w_group% h442 Section, % lang("edit") " Player"

        _Sio.CHECKBOX := new _Checkbox().name("enabled")
            .title(this.enabledText)
            .tt("Você também pode ativar o Sio clicando com o botão direito do mouse no Player na lista.", "You can also enable the Sio by right clicking on the Player in the list.")
            .x("s+10").y("p+20").w(w_controls).h(23)
            .button()
            .disabled()
            .icon(_Icon.get(_Icon.CHECK_ROUND_WHITE), "a0 l3 s14 b0")
            .event(_Sio.toggle.bind(_Sio))
            .add()

        Gui, CavebotGUI:Add, Text, xs+10 y+10, % lang("name") ":"

        this.playerName := new _Edit().name("name")
            .prefix("sio")
            .x("s+10").y("+3").w(w_controls).h(18)
            .disabled(true)
            .add()

        xsMod := (w_controls - new _SioSystem().sioFriendJsonObj.options.playerImageWidth) / 2 - 5
        Gui, CavebotGUI:Add, Picture, xs+%xsMod% y+5 w117 h14 vsioPlayerImage,

        this.getPlayerImageButton := new _Button().title("Capturar imagem do Player", "Get Player image")
            .tt("Para capturar a imagem do Player, dê FOLLOW no jogador e clique no botão de capturar.`n`nOBS: No " TibiaClient.Tibia13Identifier ", é necessário criar um Battle List adicional com o nome ""Sio"".", "To get the Player image, FOLLOW the player and then click on the button to get.`n`nPS: On " TibiaClient.Tibia13Identifier ", it's needed to create an additional Battle List named ""Sio"".")
            .x("s+10").y("+3").w(w_controls)
            .event(this.getPlayerImage.bind(this))
            .disabled()
            .icon(_Icon.get(_Icon.CAMERA), "a0 l3 s16 b0")
            .add()

        w_text := 75
        w_edit := w_group - w_text - 25

        if (new _SioSystem().sioFriendJsonObj.options.enableFollowOption != false) {
            this.followPlayer := new _SioCheckbox().name("followPlayer")
                .title("Follow Player")
                .tt("Se marcado, irá tentar manter o Follow no Player, clicando no Battle List quando o player estiver visível", "If checked, it will try to keep Follow in the Player, by clicking on it in the Battle list when the player is visible.")
                .x("s+10").y("+7").w(w_controls)
                .add()
            this.listviewLoadableControls.Push(this.followPlayer)
        }

        this.healWithRune := new _SioCheckbox().name("healWithRune")
            .title("Healar com runa", "Heal with rune")
            .tt("Se a Hotkey é de uma Runa ou outro item, essa opção deve ser marcada. Irá pressionar a hotkey e depois clicar no Player no Battle List.`n`nOBS: a hotkey deve estar configurada como ""use with crosshair"" no Tibia.", "If the Hotkey is of a Rune or other item, this option must be checked. It will press the hotkey and then click on the Player in the Battle List.`n`nPS: the hotkey must be set as  ""use with crosshair"" in Tibia.")
            .x("s+10").y("+7").w(w_controls)
            .add()
        this.listviewLoadableControls.Push(this.healWithRune)

        if (!clientHasFeature("useItemWithHotkey")) {
            ml := 10
            _ := new _Text().title("Potion/runa:", "Potion/rune:")
                .x("s+" 10 + ml).y("+8").w(w_text - ml)
                .add()

            this.sioRuneName := new _SioDropdown().name("sioRuneName")
                .x("p+0").y("+3").w(w_controls - ml)
                .add()
            this.listviewLoadableControls.Push(this.sioRuneName)
        }

        _ := new _Text().title("Sio:")
            .x("s+10").y("+10").w(w_text)
            .option("Right")
            .add()
        this.sioHotkey := new _SioHotkey().name("sioHotkey")
            .tt("Hotkey da magia ""Heal Friend""(exura sio) ou Runa para healar", "Hotkey of the ""Heal Friend""(exura sio) spell or Rune to heal")
            .x("+5").y("p-2").w(w_edit).h(18)
            .add()
        this.listviewLoadableControls.Push(this.sioHotkey)

        _ := new _Text().title("Gran Sio:")
            .x("s+10").y("+5").w(w_text)
            .option("Right")
            .add()
        this.granSioHotkey := new _SioHotkey().name("granSioHotkey")
            .tt("Hotkey da magia ""exura gran sio"".", "Hotkey of the ""exura gran sio"" spell.")
            .x("+5").y("p-2").w(w_edit).h(18)
            .add()
        this.listviewLoadableControls.Push(this.granSioHotkey)


            new _Text()
            .x("s+10").y("+1").w(w_text).h(5)
            .add()


        baseText :=  new _Text()
            .x("s+10").y("+5").w(w_text)
            .option("Right")

        baseEdit := new _SioEdit()
            .x("+5").y("p-2").w(w_edit).h(18)
            .numeric()
            .limit(2)
            .rule(new _ControlRule().min(5).max(99))
            .center()


        baseText.clone()
            .title("Sio HP %:")
            .add()
        this.sioLife := baseEdit.clone()
            .name("sioLife")
            .tt("Porcentagem de vida do player para começar a healar com Exura Sio ou Runa.`n`nExemplo: se o valor for 60, irá healar o Player sempre que a vida dele estiver abaixo de 60%", "Percentage of the Player's HP to start healing with Exura Sio or Rune.`n`nExample: if set 60, it will heal the Player everytime his life is below 60%")
            .add()
        this.listviewLoadableControls.Push(this.sioLife)

        baseText.clone()
            .title("Gran Sio HP %:")
            .add()
        this.granSioLife := baseEdit.clone()
            .name("granSioLife")
            .tt("Porcentagem de vida do player para começar a healar com Exura Gran Sio.`n`nExemplo: se o valor for 60, irá healar o Player sempre que a vida dele estiver abaixo de 60%", "Percentage of the Player's HP to start healing with Exura Gran Sio.`n`nExample: if set 60, it will heal the Player everytime his life is below 60%")
            .add()
        this.listviewLoadableControls.Push(this.granSioLife)

        baseText.clone()
            .title("Min HP %:")
            .add()
        this.minLife := baseEdit.clone()
            .name("minLife")
            .tt("Porcentagem de HP do SEU personagem, se o seu HP for menor do que o definido nessa opção, não irá healar o Player", "Percentage of YOUR character's HP, if your HP is below what is set in this option, it won't heal the Player")
            .add()
        this.listviewLoadableControls.Push(this.minLife)

        baseText.clone()
            .title("Min Mana %:")
            .add()
        this.minMana := baseEdit.clone()
            .name("minMana")
            .tt("Porcentagem de mana do SEU personagem, se a sua mana for menor do que o definido nessa opção, não irá healar o Player", "Percentage of YOUR character's mana, if your mana is below what is set in thsi option, it won't heal the Player")
            .add()
        this.listviewLoadableControls.Push(this.minMana)

        _ := new _Edit()
            .x("s+10").y("+10").w(w_controls).h(20)
            .value(txt("Opções de ataque", "Attack options"))
            .disabled(true)
            .option("Center")
            .add()

        this.useAttackRune := new _SioCheckbox().name("useAttackRune")
            .title("Usar runa de ataque", "Use attack rune")
            .tt("Se marcado, irá usar continuamente a Attack rune no Player no Battle List", "If checked, it will continuously use the Attack rune on the Player in the Battle List")
            .x("s+10").y("+8").w(w_controls)
            .add()
        this.listviewLoadableControls.Push(this.useAttackRune)

        this.attackRuneText := baseText.clone().name("attackRuneText")
            .title("Rune hotkey:")
            .y("+10")
        ; .hidden()
            .option("Right")
            .add()
        this.attackRuneHotkey := new _SioHotkey().name("attackRuneHotkey")
            .tt("Hotkey da runa de ataque para usar no player.`n`nOBS: a hotkey deve estar configurada como ""use with crosshair"" no Tibia.", "Hotkey of the Attack rune to use on the Player.`nPS: the hotkey must be set as ""use with crosshair"" in Tibia.")
            .x("+5").y("p-2").w(w_edit).h(18)
            .add()
        this.listviewLoadableControls.Push(this.attackRuneHotkey)

        this.creatureCondition := new _SioCheckbox().name("creatureCondition")
            .title("Somente com criaturas no Battle", "Only with creatures on Battle")
            .tt("Se marcado irá usar a runa de ataque somente quando pelo menos um número de criaturas estiverem no Battle List.`nAs criaturas para contar devem ser adicionadas no Targeting (TargetList)", "If checked, it will only use the attack rune when at least a number of creatures are in the Battle List.`nThe creatures to count must be added in the Targeting (TargetList)")
            .x("s+10").y("+10").w(w_controls)
            .add()
        this.listviewLoadableControls.Push(this.creatureCondition)

        this.attackRuneText := baseText.clone().name("creaturesText")
            .title("Criaturas:" , "Creatures:")
        ; .hidden()
            .add()

        this.creatures := new _SioEdit().name("creatures")
            .tt("Número de criaturas no Battle List para começar a usar a runa de ataque no Player", "Number of creatures in the Battle List to start using attack rune on the Player")
            .x("+5").y("p-2").w(w_edit).h(18)
            .limit(1)
            .numeric()
            .center()
            .rule(new _ControlRule().min(1).max(8))
            .add()
        this.listviewLoadableControls.Push(this.creatures)

        _GuiHandler.tutorialButtonModule("SioFriend")
    }

    LV_SioList()
    {
        Gui, CavebotGUI:Default
        Gui, ListView, LV_SioList

        playerName := _ListviewHandler.getSelectedItemOnLV("LV_SioList", column := 1, defaultGUI := "CavebotGUI", returnRow := false)
        if (playerName = "" OR playerName = "Player Name") {
            return
        }
        playerName := playerName

        this.playerName.set(playerName)

        this.getPlayerImageButton.enable()

        _Sio.CHECKBOX.enable()
        this.syncCheckboxState(_Sio.CHECKBOX, playerName)

        for _, control in this.listviewLoadableControls {
            control.load().enable()
        }

        this.loadPlayerImage(playerName)

        this.followPlayer.show() ; for some reason is getting hidden sometimes
        if (!new _SioSystem().sioFriendJsonObj.options.enableFollowOption) {
            this.followPlayer.disable()
            if (this.followPlayer.get()) {
                this.followPlayer.uncheck()
            }
        }

        If (A_GuiEvent = "DoubleClick" OR A_GuiEvent = "RightClick") {
            if (_Sio.CHECKBOX.get()) {
                _Sio.CHECKBOX.uncheck()
            } else {
                _Sio.CHECKBOX.check()
            }
        }
    }

    loadPlayerImage(playerName)
    {
        if (empty(sioFriendObj[playerName].image)) {
            this.defaultPlayerImage()
            return
        }

        pBitmap := GdipCreateFromBase64(sioFriendObj[playerName].image), hBitmap:=Gdip_CreateHBITMAPFromBitmap(pBitmap)
        GuiControl, CavebotGUI:, sioPlayerImage, % "HBITMAP:*" hBitmap
        Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
    }

    /**
    * @return void
    */
    syncCheckboxState(checkbox, playerName)
    {
        _Validation.instanceOf("checkbox", checkbox, _Checkbox)

        checkbox.setWithoutEvent(this.settings.get("enabled", playerName))
        checkbox.setWithoutEvent(checkbox.get() ? this.disabledText : this.enabledText)
    }

    loadSioListLV()
    {
        try {
            _ListviewHandler.loadingLV("LV_SioList")
        } catch {
            return
        }

        /**
        */
        IL_Destroy(ImageListID_LV_SioList)  ; Required for image lists used by tab_name controls.

        IconWidth    := 1
        IconHeight   := 30
        IconBitDepth := 24 ;
        InitialCount :=  1 ; The starting Number of Icons available in ImageList
        GrowCount    :=  1

        ImageListID_LV_SioList  := DllCall( "ImageList_Create", Int,IconWidth,    Int,IconHeight
            , Int,IconBitDepth, Int,InitialCount
            , Int,GrowCount )

        Gui, ListView, LV_SioList
        LV_SetImageList( ImageListID_LV_SioList, 1 ) ; 0 for large icons, 1 for small icons


        ; msgbox, % serialize(sioFriendObj)
        for playerName, _ in sioFriendObj
        {
            Gui, ListView, LV_SioList
            LV_Add()
            ; msgbox, % playerName " / " serialize(atributes) "`n`n" serialize(sioFriendObj[playerName])
            this.changeRow(A_Index, playerName)
        }

        Loop, % StrSplit(this.colums, "|").Count() {
            Gui, ListView, LV_SioList
            LV_ModifyCol(A_Index, "autohdr")
        }

        return
    }

    boolRow(playerName, key) {
        return boolToString(this.settings.get(key, playerName))
    }

    rowEnabled(playerName) {
        return this.boolRow(playerName, _Sio.CHECKBOX)
    }

    rowUseRune(playerName) {
        return this.boolRow(playerName, this.healWithRune)
    }

    rowAttackRune(playerName) {
        return this.boolRow(playerName, this.useAttackRune)
    }

    rowFollow(playerName) {
        return this.boolRow(playerName, this.followPlayer)
    }

    rowGranSioHotkey(playerName) {
        hotkey := this.settings.get(this.granSioHotkey, playerName)
        if (empty(hotkey)) {
            return "<disabled>"
        }

        return hotkey
    }

    rowSioHotkey(playerName) {
        if (clientHasFeature("useItemWithHotkey")) {
            return this.settings.get(this.sioHotkey, playerName)
        }

        if (!this.settings.get(this.healWithRune, playerName)) {
            return this.settings.get(this.sioHotkey, playerName)
        }

        return this.settings.get(this.sioRuneName, playerName)
    }

    rowCreature(playerName) {
        if (!this.settings.get(this.creatureCondition, playerName)) {
            return "<disabled>"
        }

        return this.settings.get(this.creatures, playerName)
    }

    rowsioLife(playerName) {
        return this.settings.get(this.sioLife, playerName) "%"
    }

    rowgranSioLife(playerName) {
        return this.settings.get(this.granSioLife, playerName) "%"
    }

    rowHP(playerName) {
        return this.settings.get(this.minLife, playerName) "%"
    }

    rowMP(playerName) {
        return this.settings.get(this.minMana, playerName) "%"
    }

    rowAttackRuneHotkey(playerName) {
        return this.settings.get(this.attackRuneHotkey, playerName)
    }

    updateSioRow(playerName)
    {
        if (isFunction(playerName)) {
            playerName := %playerName%()
        }

        rowNumber := _ListviewHandler.findRowByContent(playerName, 1, "LV_SioList", defaultGUI := "CavebotGUI")
        if (rowNumber < 1) {
            if (!A_IsCompiled) {
                Msgbox, 48, % A_ThisFunc, % "playerName = " playerName ", rowNumber = "  rowNumber
            }
            return
        }

        this.changeRow(rowNumber, playerName)
    }

    changeRow(number, p)
    {
        LV_Modify(number, "", p, this.rowEnabled(p), this.rowSioHotkey(p), this.rowUseRune(p), this.rowsioLife(p), this.rowGranSioHotkey(p), this.rowgranSioLife(p), this.rowHP(p), this.rowMP(p), this.rowFollow(p), this.rowAttackRune(p), this.rowCreature(p), this.rowAttackRuneHotkey(p))
    }

    defaultPlayerImage()
    {
        GuiControl, CavebotGUI:, sioPlayerImage, % "Data\Files\Images\Sio\default_picture.png"
    }

    /**
    * @return array<_ListOption>
    */
    getSioItemsList()
    {
        static list
        if (list) {
            return list
        }

        sioLifeItemsList := ItemsHandler.getItemListArray("health|life|spirit|intense|ultimate", {1: "Liquids", 2: "Attack Runes"}, "mana potion", "")


        list := {}
        list.Push(new _ListOption(A_Space, true))
        for _, item in sioLifeItemsList {
            list.Push(new _ListOption(item))
        }

        return list
    }

    deletePlayer()
    {
        try {
            Gui, CavebotGUI:Default
            Gui, ListView, LV_SioList

            playerName := this.playerName.get()
            if (playerName = "" OR playerName = "Player Name") {
                return
            }

            GetKeyState, CtrlPressed, Ctrl, D
            if (CtrlPressed != "D") {
                Msgbox, 52,, % "Delete player """ playerName """?"
                IfMsgBox, No
                    return
            }

            sioFriendObj.Delete(playerName)

            SioGUI.loadSioListLV()

            this.playerName.set("")
            this.defaultPlayerImage()

            _Sio.saveSioFriend()
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc)
        }
    }

    getPlayerImage()
    {
        try {
            this.getPlayerImageFollow()
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc)
        }
    }

    addNewPlayerEvent()
    {
        try {
            this.addNewPlayer()
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc)
        }
    }

    /**
    * @throws
    */
    getPlayerImageFollow()
    {
        playerName := this.getPlayerName()
        if (playerName = "") {
            throw exception("Player not selected")
        }

        _Validation.connected()

        if (sioFriendObj[playerName].image != "") {
            Msgbox,36,, % LANGUAGE = "PT-BR" ? "Essa ação irá sobrescrever a imagem atual do player """ playerName """.`n`nDeseja continuar?" : "This action will overwrite the current image of player """ playerName """.`n`nContinue?"
            IfMsgBox, No
                return
        }

            new _SioBattleListArea().destroyInstance()

        _search := new _SioSystem().isFollowing(true)
        if (_search.notFound()) {
            msgbox, 64,, % txt("Dê ""Follow"" no player que você quer capturar seu nome no Battle List.", "Follow the Player you want to get its name in the Battle List."), 10
            return
        }

        tempImagePath := A_Temp "\__player.png"
        try {
            FileDelete, % tempImagePath
        } catch {
        }

        WinActivate()
        /**
        to cancel the follow
        */
        Send("Esc")
        Sleep, 200

        c1 := new _Coordinate(_search.getX(), _search.getY())
            .addX(new _TargetingJson().get("redPixelArea.getCreatureImage.offsetX", 2))
            .addY(new _TargetingJson().get("redPixelArea.getCreatureImage.offsetY", 3))

        c2 := new _Coordinate(c1.getX(), c1.getY())
            .addX(new _SioSystem().sioFriendJsonObj.options.playerImageWidth)
            .addY(_SioSystem.PLAYER_IMAGE_HEIGHT)

        coordinates := new _Coordinates(c1, c2)
        ; coordinates.debug()
        screenImage := _BitmapEngine.getClientBitmap()

        playerBitmap := new _BitmapImage(screenImage.cropFromArea(new _WindowArea().getCoordinates(), coordinates))

        playerBitmap.save(tempImagePath)

        try {
            _search := new _BitmapImageSearch()
                .setBitmap(playerBitmap)
                .setVariation(TargetingSystem.targetingJsonObj.options.searchCreatureVariation)
                .setArea(new _SioBattleListArea())
                .search()

            if (_search.notFound()) {
                msgbox,48,, % "Player image not found, try to get it again.", 5
                Gui, CavebotGUI:Show
                return
            }
        } catch e {
            throw e
        } finally {
            playerBitmap.dispose()
        }

        try GuiControl, CavebotGUI:, sioPlayerImage, % tempImagePath
        catch {
        }

        sioFriendObj[playerName].image := FileToBase64(tempImagePath)

        _Sio.saveSioFriend()

        Gui, CavebotGUI:Show
    }

    addNewPlayer()
    {
        InputBox, newPlayerName, % "Enter the player name", % "Player name:", ,200,122, X := "", Y := "", Font := "", 20
        if (newPlayerName = "")
            return
        if (ErrorLevel = 1)
            return
        newPlayerName := getStringNoSpecialCharacters(newPlayerName, false)
        _Validation.empty("newPlayerName", newPlayerName)

        if (sioFriendObj.HasKey(newPlayerName))
            throw Exception("Player """ newPlayerName """ is already in the list.")

        sioFriendObj[newPlayerName] := {}

        this.loadSioListLV()
        _Sio.saveSioFriend()
    }
}
