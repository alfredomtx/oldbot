global searchFilter_Name
global searchFilter_Category
global searchFilter_Rows
global searchFilter_Client

global hLV_ItemList ; set hwnd lv global here otherwise it w on't work as global variable when creating the listview
global LV_ItemListColors
global hLV_DepositList
global hLV_TrashList
global hLV_LootList
global hLV_SellList

global loading_LV_ItemList := false
global itemSpriteSelected

Class _LootingGUI
{
    __New()
    {
        ItemsHandler.createMainBackpacksList()

        this.itemLists := {}
        this.itemLists.Push("DepositList")
        this.itemLists.Push("LootList")
        this.itemLists.Push("SellList")
        this.itemLists.Push("TrashList")
    }

    checkSelectedItem(LV) {
        selectedItem :=  _ListviewHandler.getSelectedItemOnLV(LV)
        if (selectedItem = "" OR selectedItem = "Name")
            Throw Exception("No item selected.")
        return selectedItem
    }

    filterItemList() {
        try {
            Gui, CavebotGUI:Default
            GuiControlGet, searchFilter_Name
            GuiControlGet, searchFilter_Category
            GuiControlGet, searchFilter_Rows
            GuiControlGet, searchFilter_ShowAllRows
            GuiControlGet, searchFilter_Client
        } catch {
        }

        this.LoadItemListLV(searchFilter_Name, searchFilter_Category = "Filter category..." ? "" : searchFilter_Category, searchFilter_Rows, searchFilter_ShowAllRows)
    }

    PostCreateLootingGUI() {
        this.LoadDepositListLV()
        this.LoadLootListLV()
        this.LoadSellListLV()
        this.LoadTrashListLV()
        this.LoadItemListLV()

        for key, value in this.numberControls {
            try {
                GuiControl, % "CavebotGUI:+g" this.editLootListAtributesLabel, % value
            } catch {
            }
        }

        this.checkLootingGuiSettingsControls()
    }

    createLootingGUI() {
        global

        main_tab := "Looting"
        child_tabs_%main_tab% := "Settings|DepositList|TrashList|LootList|SellList|ItemList"

        Gui, CavebotGUI:Add, Tab2, x6 vTab_%main_tab% y%y_tab% w%tabsWidth% h%tabsHeight% hWndhTab_%main_tab% %TabStyle% +Theme, % child_tabs_%main_tab%
        if (load_order[1] != main_tab)
            GuiControl, Hide, Tab_%main_tab% ; esconder a tab antes de adicionar os elementos a ela

        if (OldbotSettings.uncompatibleModule("looting") = true)
            _GuiHandler.uncompatibleModuleWarning()

        Loop, parse, child_tabs_%main_tab%, |
        {
            current_child_tab := A_LoopField
            ; msgbox, % main_tab "`n`ncurrent_child_tab = " current_child_tab
            Gui, CavebotGUI:Tab, %current_child_tab%
            switch current_child_tab
            {
                case "Settings":
                    if (OldbotSettings.uncompatibleModule("looting") = true)
                        continue
                    this.ChildTab_Looting()
                case "DepositList":
                    this.ChildTab_DepositList()
                case "TrashList":
                    this.ChildTab_TrashList()
                case "LootList":
                    this.ChildTab_LootList()
                case "SellList":
                    this.ChildTab_SellList()
                case "ItemList":
                    this.ChildTab_ItemList()
            }
        }
    }

    ChildTab_Looting() {
        global
        wedit := 60, xedit := 180

        w := tabsWidth - 20
        h := tabsHeight - 37
        Gui CavebotGUI:Add, GroupBox, x15 y+6 w%w% h%h% Section,
        lootingEnabled := lootingObj.settings.lootingEnabled

            new _Checkbox().title(txt("Looting ", "Looting ") lang("enabled"))
            .name("lootingEnabled")
            .xs(10).ys()
            .event("lootingEnabled")
            .value(lootingEnabled)
            .tt(txt("O Looting precisa do Targeting estar habilitado para funcionar.", "Looting needs Targeting to be enabled to work."))
            .add()

        w -= 20
        h -= 33
        Gui CavebotGUI:Add, GroupBox, xs+10 y+10 w%w% h%h% Section, % (LANGUAGE = "PT-BR" ? "Opções" : "Options")
        ; Gui, CavebotGUzI:Add, Checkbox, xs+30 yp+30 vFastLoot gFastLoot Checked%FastLoot% Ultra Fast Loot
        ; Gui, CavebotGUI:Add, Button, x+5 yp-1 w16 h16 Center gInfoFastLoot hwndInfo_Button,
        ; GuiButtonIcon(Info_Button, "imageres.dll", 77, "a0 l0 b0 t0 s10")


        lootAfterAllKill := lootingObj.settings.lootAfterAllKill
        Gui, CavebotGUI:Add, Checkbox, xs+10 yp+25 vlootAfterAllKill gsubmitLootingSettings hwndhlootAfterAllKill Checked%lootAfterAllKill%, % (LANGUAGE = "PT-BR" ? "Lootear após matar todos" : "Loot after all killed")
        TT.Add(hlootAfterAllKill, txt("Se marcado, irá lootear somente após matar todos os monstros", "If checked, it will loot only after killing all creatures"))

        openNextBackpack := lootingObj.settings.openNextBackpack
        Gui, CavebotGUI:Add, Checkbox, xs+10 y+5 vopenNextBackpack gopenNextBackpack hwndhopenNextBackpack Checked%openNextBackpack%, % LANGUAGE = "PT-BR" ? "Abrir próxima backpack" : "Open next backpack"
        TT.Add(hopenNextBackpack, (LANGUAGE = "PT-BR" ? "Procura por Script Images que o nome começa com ""nextBackpack"", e se encontrado, clica para abrir a backpack`n`nA imagem ""nextBackpack"" deve ser configurada corretamente para funcionar.`nDeve ser a imagem da backpack para ser aberta no ÚLTIMO slot da backpack, junto com o scroll bar." : "Search for Script Images where the name starts with ""nextBackpack"", and if found, click on it to open the backpack`n`nThe ""nextBackpack"" image needs to be configured correctly for it to work.`nMust be a image of the backpack to be opened in the LAST slot of a backpack, together with the scroll bar."))


        this.lootingMethodElements()

        this.fastManualLooting()


        this.distanceLooting()


        showButtons :=LootingSystem.lootingJsonObj.options.openCorpsesAround && !isRubinot()
        if (showButtons) {
                new _ControlFactory(_ControlFactory.SCRIPT_IMAGES_BUTTON)
                .xs(-10).yadd(45).w(150)
                .add()

                new _ControlFactory(_ControlFactory.SET_GAME_AREAS_BUTTON)
                .xp().yadd(7).w(150)
                .add()
        }



        if (new _ClientInputIniSettings().get("classicControlDisabled")) {
            Gui, CavebotGUI:Font, cRed
            Gui, CavebotGUI:Add, Text, xs+0 y+10, % (LANGUAGE = "PT-BR" ? "A configuração de ""Classic Control"" no cliente deve estar DESABILITADA para o looting nesse client.`nVocê pode mudar essa configuração na aba Settings -> ""Classic control"" desativado." : """Classic Control"" in client settings must be DISABLED for looting in this client.`nYou can change this setting in Settings tab -> ""Classic control"" disabled.")
            Gui, CavebotGUI:Font,
        }

        if (LootingSystem.lootingJsonObj.input.backgroundMouseDrag = false) {
            Gui, CavebotGUI:Font, cRed
            Gui, CavebotGUI:Add, Text, xs+0 y+10 w300, % (LANGUAGE = "PT-BR" ? "Ações de ""mouse drag""(arrastar o mouse) em background(segundo plano) não funcionam nesse cliente, o bot irá ativar a janela do cliente sempre que for tentar arrastar um item." : "Background ""mouse drag"" doesn't work for this client, the bot will active the client window everytime it tries to drag an item.")
            Gui, CavebotGUI:Font,
        }


        ; for some reason some settings are without value when they reach this looting gui function
        try {
            GuiControl, CavebotGUI:ChooseString, lootingCondition, % (!lootingMode) ? lootingCondition := lootingObj.settings.lootingCondition : lootingCondition
            GuiControl, CavebotGUI:ChooseString, lootingMode, % (!lootingMode) ? lootingMode := lootingObj.settings.lootingMode : lootingMode
            GuiControl, CavebotGUI:ChooseString, lootingPolicy, % (!lootingPolicy) ? lootingPolicy := lootingObj.settings.lootingPolicy : lootingPolicy
        } catch {
        }

        _GuiHandler.tutorialButtonModule("Looting")
    }

    distanceLooting()
    {
        global

        if (!lootCreaturesPosition) {
            return
        }


        lootCreaturesPosition := lootingObj.settings.lootCreaturesPosition
            new _Groupbox()
            .x(35).yadd(15).w(300).h(85)
            .add()

        disabled := CavebotScript.isCoordinate() ? "" : "Disabled"
        Gui, CavebotGUI:Add, Checkbox, xs+0 yp+20 vlootCreaturesPosition gsubmitLootingSettings hwndhlootCreaturesPosition Checked%lootCreaturesPosition% %disabled%, % txt("Lootear criaturas distantes(Distance Looting)", "Loot distant creatures(Distance Looting)")
        if (!CavebotScript.isCoordinate()) {
                new _Text().title("Habilite o ""Modo de Coordenadas"" no Cavebot para usar essa opção.", "Enable the ""Coordinates Mode"" on Cavebot to use this option.")
                .xadd(20).yp()
                .color("red")
                .add()
        }

        TT.Add(hlootCreaturesPosition, txt("ATENÇÃO: Esse é um novo método experimental, leia para entender como funciona antes de usá-lo.`n`nO sistema de Distance Looting funciona da seguinte forma:`n- Após matar uma criatura que está sendo atacada, o bot irá salvar a sua posição(coordenada), criando uma fila(queue) de posições de criaturas para serem looteadas.`n- Após matar TODAS as criaturas, o Distance Looting iniciará e irá caminhar para a posição de cada uma das criaturas mortas, looteando os SQMs do centro e em volta do char.", "ATTENTION: This is a new experimental mode, read to understand how it works before using it.`n`nThe Distance Looting system works as follows:`n-After killing a creature that is being attacked, the bot will save its position(coordinate), creating a queue of positions to be looted.`n- After killing ALL creatures, the Distance Looting will start and will walk to the position of every dead creatures, looting the center SQMs and around the character.") )

        searchCorpseImages := lootingObj.settings.searchCorpseImages
        Gui, CavebotGUI:Add, Checkbox, xs+15 y+5 vsearchCorpseImages gsubmitLootingSettings hwndhsearchCorpseImages Checked%searchCorpseImages% %disabled%, % txt("Procurar imagem de corpos", "Search corpse images")
        TT.Add(hsearchCorpseImages, txt("Por padrão o bot detecta a posição da criatura que está sendo atacada e salva a ultima posíção quando ela morre para lootear o SQM.`nCom essa opção, adicionalmente é realizado uma busca de todas as Script Images com a categoria ""Corpse"", ao encontrar o corpo, o Distance Looting irá caminhar até o SQM do corpo e lootear.", "By default the bot detects the position of creature that is being attacked and save its last position when it dies to loot the SQM.`nWith this option, additionall is performed a search for all Script Images with the category ""Corpse"", when the corpse is found, the Distance Looting will walk to the SQM and loot."))

        showCreaturePosition := lootingObj.settings.showCreaturePosition
        Gui, CavebotGUI:Add, Checkbox, xs+15 y+5 vshowCreaturePosition gsubmitLootingSettings hwndhshowCreaturePosition Checked%showCreaturePosition%, % txt("Mostrar posição da criatura na tela", "Show creature position on screen")
        TT.Add(hshowCreaturePosition, txt("Mostrar um pequeno quadrado branco indicando a posição da criatura na tela que o bot está identificando", "Show a small white square indicating the creature position on screen where the bot is identifying."))

    }

    lootingMethodElements()
    {
        global

        this.lootingMethodClickAround()

        yLast := _AbstractControl.getLastAdded().getGuiY()

        this.quickLootingHotkey()
        this.lootingMethodHotkey()
    }

    lootingMethodClickAround()
    {
        global

        if (LANGUAGE= "PT-BR") {
            lootingMethodText := ""
                . "- Click around: é o método padrão, irá clicar em todos os 8 sqms em volta do char para lootear com ""Shift + Right Click"", e após abrir o corpo irá procurar pelos items do LootList e arrastar para backpack."
                . "`n"
                . "`n"
                . "- Click on the item: método de looting para OT servers onde é possível lootear apenas clicando com o botão esquerdo no item, sem precisar arrastar para a backpack. Abre os corpos da mesma forma que o método ""Click Around""."
                . "`n"
                . "`n"
                . "- Press hotkey: em alguns OT Servers, é possível lootear comandos tal como ""exeta loot""(Taleon OT), então você pode colocar esse comando em uma hotkey e pressionar a hotkey para lootear ao invés de clicar em volta"
        } else {
            lootingMethodText := ""
                . "- Click around: is the default method, it will click on all 8 sqms around the character to loot with ""Shift+Right Click"", and after opening the corpse it will search for the items of the LootList and drag to the backpack. Open the corpses the same way as the ""Click around"" method."
                . "`n"
                . "`n"
                . "- Click on the item: looting method where it's possible to loot by just clicking with the left button on the item, without the need to drag the item to the backpack."
                . "`n"
                . "`n"
                . "- Press hotkey: in some OT Servers, it's possible to loot with a command such as ""exeta loot""(Taleon OT), so you can put this command in a hotkey and press the hotkey to loot instead of clicking around"
        }



            new _Groupbox()
            .xs(10).yadd(13).w(300).h(130)
            .add()


        disabled := LootingSystem.lootingJsonObj.options.openCorpsesAround && !OldBotSettings.settingsJsonObj.settings.looting.enableLootingMethodChange
            new _Text().title("Método de Looting:", "Looting Method:")
            .xs(xs := 20).yp(20)
            .section()
            .tt(lootingMethodText)
            .disabled(disabled)
            .add()

        this.lootingMethod := new _Listbox().title(_Arr.concat(new _LootingSettings().getAttribute("lootingMethod").getValues(), "|"))
            .name("lootingMethod")
            .xs(xs + 105).yp(-3)
            .event("lootingMethod")
            .state(_LootingSettings)
            .disabled(disabled)
            .parent()
            .add()
    }

    quickLootingHotkey()
    {
        global

        switch (LootingSystem.lootingJsonObj.options.openCorpsesAround) {
            case true:
                text := "Looting Hotkey:"
                options := "Ctrl & Right Click|Right Click"
                tooltipMessage := txt("Hotkey usada durante o Looting, por padrão a hotkey é ""Ctrl & Right Click"", para clicar no SQM segurando Ctrl para aparecer o menu e clicar na opção ""Open"".`n`nCUIDADO: ao usar somente ""Right Click"", caso haja criatura no mesmo SQM do corpo, irá atacar a criatura ao invés de lootear, e se houver uma escada, ira subi-la.", "Hotkey used during the Looting, by default is ""Ctrl & Right Click"", to click on the SQM holding Ctrl to show the menu and click on the ""Open"" option.`n`nCAUTION: when using only ""Right Click"", in case there is a creature in the same SQM of the corpse, it will attack the creature instead of looting, and if there is a ladder, it will climb it.")
            default:
                text := "Quick Looting Hotkey:"
                options := "Shift & Right Click|Right Click|Left Click"
                tooltipMessage := txt("Hotkey do Quick Looting, a melhor hotkey é sempre ""Shift & Right Click"", outras hotkeys poderão causar perdas no looting.", "Hotkey of the Quick Looting, the best hotkey is always Shift & Right Click, other hotkeys can cause looting losses.")
        }


        disabled := LooltingSystem.lootingJsonObj.options.openCorpsesAround && !OldBotSettings.settingsJsonObj.settings.looting.enableQuickLootingHotkeyChange
            new _Text().title(text)
            .name("quickLootingHotkeyText")
            .xs().y(yLast + 10)
            .hidden(new _LootingSettings().get("lootingMethod") = "Press hotkey")
            .tt(tooltipMessage)
        ; .disabled(disabled)
            .add()
        ; Gui, CavebotGUI:Add, Text, xs+0 ys+25 vquickLootingHotkeyText %Hidden2%, % text
        Hidden2 := new _LootingSettings().get("lootingMethod") = "Press hotkey" ? "Hidden" : ""

        DisabledQuickLootingHotkeyChange := disabled ? "Disabled" : ""
        Gui, CavebotGUI:Add, Listbox, xs+125 yp-2 w150 r3 vquickLootingHotkey gquickLootingHotkey hwndhquickLootingHotkey %Hidden2% %DisabledQuickLootingHotkeyChange% , % options
        TT.Add(hquickLootingHotkey, tooltipMessage)
        GuiControl, CavebotGUI:ChooseString, quickLootingHotkey, % lootingObj.settings.quickLootingHotkey
        if (isTibia13()) {
            Gui, CavebotGUI:Add, Picture, xp+0 y+5 vquickLootingHotkeyImage %Hidden2%, % "Data\Files\Images\GUI\Looting\quick_looting_hotkey.png"
        }


        Disabled := jsonConfig("targeting", "options", "disableCreaturePositionCheck") = true ? "Disabled" : ""
    }

    lootingMethodHotkey()
    {
        global

        Disabled := (LootingSystem.lootingJsonObj.options.openCorpsesAround = true) ? "Disabled" : ""

            new _Text().title("Hotkey:")
            .name("lootingHotkeyText")
            .xs().y(yLast + 10)
            .hidden(new _LootingSettings().get("lootingMethod") != "Press hotkey")
            .add()

            new _Hotkey().name("lootingHotkey")
            .xs(115).w(150)
            .tt("Hotkey para pressionar e lootear", "Hotkey to press and loot")
            .parent()
            .hidden(new _LootingSettings().get("lootingMethod") != "Press hotkey")
            .state(_LootingSettings)
            .add()
    }

    fastManualLooting()
    {
        global

        if (isTibia13() && !LootingSystem.lootingJsonObj.options.openCorpsesAround) {
            return
        }

            new _Groupbox()
            .x(35).yadd(40).w(300).h(73)
            .add()

            new _Checkbox().title("Fast manual looting")
            .xs().yp(20)
            .name("fastManualLooting")
            .tt("Se marcado, irá lootear somente os 3 sqms perto de onde a criatura morreu(quando foi possível detectar sua posição), caso contrário irá lootear todos os sqms em volta como é por padrão.`n`nOBS: funciona somente com a opção ""Lootear após matar todos"" desabilitada. Em clientes sem Full Light(iluminação), é necessário usar uma fonte de luz no char(tocha, utevo liux, etc).", "If checked, it will loot only the 3 sqms near where the creature died(when it was possible to detect its position), otherwise it will loot all the sqms around as it is by default.`n`nNOTE: works only with the option ""Loot after all killed"" disabled. On clients without Full Light(lighting), it is necessary to use a light source on the character(torch, utevo lux, etc).")
            .event("fastManualLooting")
            .disabled(disabled := new _LootingSettings().get("lootingMethod") = "Press hotkey", LootingSystem.lootingJsonObj.options.openCorpsesAround != true)
            .value(fastManualLooting)
            .add()


        DisabledQuickLooting := (LootingSystem.lootingJsonObj.options.openCorpsesAround != true) ? "Disabled" : ""
        DisabledPressHotkey := new _LootingSettings().get("lootingMethod") = "Press hotkey" ? "Disabled" : ""
        ; Gui, CavebotGUI:Add, Checkbox, xs+0 y%y% vfastManualLooting gfastManualLooting hwndhfastManualLooting Checked%fastManualLooting% %Disabled% %DisabledPressHotkey% %DisabledQuickLooting%, Fast manual looting
        Gui, CavebotGUI:Add, DDL, x+10 yp-2 w130 vsmartLootingSqms gsmartLootingSqms hwndhsmartLootingSqms %DisabledQuickLooting% %DisabledPressHotkey%, % "1 sqm|3 sqms"
        TT.Add(hsmartLootingSqms, (LANGUAGE = "PT-BR" ? "Sqms perto de onde a criatura morreu(sua última posição detectada) para abrir, 1 é mais rápido porém pode perder mais loots." : "Sqms near where the creature died(its last detected position) to open, 1 is faster but may miss more loots."))
        GuiControl, CavebotGUI:ChooseString, smartLootingSqms, % lootingObj.settings.smartLootingSqms = 1 ? "1 sqm" : "3 sqm"


            new _Checkbox().title(txt("Não lootear em volta se falhar","Don't loot around if fails"))
            .xs(15).yadd(7)
            .name("dontLootAroundIfFastManualLootingFails")
            .tt(tooltip := txt("Por padrão, o bot looteia todos os SQMs em volta do char quando o ""Fast manual looting"" esta ativo e o bot não consegue detectar a posição da criatura.`n`nSe marcado, o bot não irá lootear em volta quando falhar, o que causa mais perda de loots, porém pode ajudar na eficiência do bot e detecção de bots via Tibia Cam(parecendo mais humano).", "By default, the bot loots all the sqms around the character when ""Fast manual looting"" is active and the bot cannot detect the creature's position.`n`nIf checked, the bot will not loot around when it fails, which causes more looting losses, but can help the bot's efficiency and detection of bots via Tibia Cam(appearing more human)."))
            .disabled(disabled)
            .state(_LootingSettings)
            .add()

            new _Text().title("ℹ️")
            .xadd(1).yp(-6)
            .disabled(disabled)
            .font("s14")
            .tt(tooltip)
            .add()
    }


    ChildTab_DepositList() {
        global
        if (LootingSystem.lootingJsonObj.options.openCorpsesAround = true) {
            Gui CavebotGUI:Font, cRed
            Gui CavebotGUI:Add, Text, x20 y+10, % (LANGUAGE = "PT-BR" ? "DepositList está disponível somente para " TibiaClient.Tibia13Identifier "." : "DepositList is available only for " TibiaClient.Tibia13Identifier ".")
            Gui CavebotGUI:Font,
            return
        }

        w_lv := w_LVWaypoints - 190
        x_group1 := x_groupbox_listview - 190
        Gui, CavebotGUI:Add, ListView, x15 y+6 h%LV_Waypoints_height% w%w_lv% AltSubmit vLV_DepositList gLV_DepositList hwndhLV_DepositList LV0x1 LV0x10, #|Name|Category|Weight|Price|Sprites|Animation

        w_group := 150 + 10
        w_group2 := w_group + 10
        w_controls := w_group - 20

        x_group2 := x_group1 + w_group + 10

            new _Button().title("Deletar item(s) da lista", "Delete item(s) from list")
            .x(x_group1).y(50).w(w_group)
            .event("RemoveItemDepositList")
            .icon(_Icon.get(_Icon.DELETE), "a0 l3 s14 b0")
            .add()

        ; Gui, CavebotGUI:Add, Button, x%x_group1% y50 w%w_group% vRemoveItemDepositList gRemoveItemDepositList, % txt(


        Gui, CavebotGUI:Add, Groupbox, x%x_group1% y+5 w%w_group% h105 Section, % txt("Editar item", "Edit item")
        Gui, CavebotGUI:Add, Text, xs+10 yp+18, % txt("Nome do item:", "Item name:")
        Gui, CavebotGUI:Add, Edit, xs+10 y+3 w%w_controls% h18 vdepositerItemNameEdit  Disabled, % depositerItemNameEdit

        Gui, CavebotGUI:Add, Text, xs+10 y+7, % txt("Categoria:", "Category:")
        Gui, CavebotGUI:Add, DDL, xs+10 y+3 w%w_controls% gEditDepositItemCategory vdepositerItemCategoryEdit, % LootingHandler.listScriptCategories()

        this.moveToListControls("DepositList", "s+0", y := "+15", w := w_group)

        wgroup_double := w_group * 2 + 20

        this.backpacksSettings()

        this.lootDestination()

        _GuiHandler.tutorialButtonModule("Looting")
    }


    lootDestination()
    {
        global

        Gui, CavebotGUI:Add, Groupbox, x%x_group2% y50 w%w_group2% h239 Section, % txt("Destino do loot", "Loot destination")
        Gui, CavebotGUI:Add, Picture, xs+10 yp+22, Data\Files\Images\GUI\Looting\depot_locker_1.png
        Gui, CavebotGUI:Add, DDL, x+5 yp+9 vdepositerLocker1Category hwndhdepositerLocker1Category gEditDepositLootDestination w103 Disabled, Default||
        try {
            ; GuiControl, CavebotGUI:ChooseString, depositerLockerOneCategory, % depositerLockerOneCategory
        } catch {
        }

        Gui, CavebotGUI:Add, Picture, xs+10 y+22, Data\Files\Images\GUI\Looting\depot_locker_2.png
        Gui, CavebotGUI:Add, DDL, x+5 yp+9 vdepositerLocker2Category hwndhdepositerLocker2Category gEditDepositLootDestination w103, % "Category...||" LootingHandler.listScriptCategories(true)
        try {
            GuiControl, CavebotGUI:ChooseString, depositerLocker2Category, % lootingObj.depositSettings.depositLootDestination.depositerLocker2Category
        } catch {
        }
        TT.Add(hdepositerLocker2Category, (LANGUAGE = "PT-BR" ? "Selecione a categoria do item para ir para o segundo depot locker.`nAs categorias sem depot selecionado são colocados no primeiro depot por padrão" : "Select the item category to go to the second depot locker.`nThe categories with no selected depot are set in the first depot by default"))

        Gui, CavebotGUI:Add, Picture, xs+10 y+22, Data\Files\Images\GUI\Looting\depot_locker_3.png
        Gui, CavebotGUI:Add, DDL, x+5 yp+9 vdepositerLocker3Category hwndhdepositerLocker3Category gEditDepositLootDestination w103, % "Category...||" LootingHandler.listScriptCategories(true)
        try {
            GuiControl, CavebotGUI:ChooseString, depositerLocker3Category, % lootingObj.depositSettings.depositLootDestination.depositerLocker3Category
        } catch {
        }
        TT.Add(hdepositerLocker3Category, (LANGUAGE = "PT-BR" ? "Selecione a categoria do item para ir para o terceiro depot locker.`nAs categorias sem depot selecionado são colocados no primeiro depot por padrão" : "Select the item category to go to the third depot locker.`nThe categories with no selected depot are set in the first depot by default"))

        Gui, CavebotGUI:Add, Picture, xs+10 y+22, Data\Files\Images\GUI\Looting\depot_locker_4.png
        Gui, CavebotGUI:Add, DDL, x+5 yp+9 vdepositerLocker4Category hwndhdepositerLocker4Category gEditDepositLootDestination w103, % "Category...||" LootingHandler.listScriptCategories(true)
        try {
            GuiControl, CavebotGUI:ChooseString, depositerLocker4Category, % lootingObj.depositSettings.depositLootDestination.depositerLocker4Category
        } catch {
        }
        TT.Add(hdepositerLocker4Category, (LANGUAGE = "PT-BR" ? "Selecione a categoria do item para ir para o quarto depot locker.`nAs categorias sem depot selecionado são colocados no primeiro depot por padrão" : "Select the item category to go to the fourth depot locker.`nThe categories with no selected depot are set in the first depot by default"))

    }

    backpacksSettings()
    {
        global

        w_groupsub := w_group - 5
        w_controls := w_groupsub - 20

        Gui, CavebotGUI:Add, Groupbox, x%x_group1% y328 w%wgroup_double% h227 Section, % LANGUAGE = "PT-BR" ? "Configurações de Backpack (opcional)" : "Backpack Settings (optional)"

        Gui, CavebotGUI:Add, Groupbox, xs+10 yp+20 w%w_groupsub% h54 Section, % LANGUAGE = "PT-BR" ? "Backpack equipada(principal)" : "Equipped backpack (main)"

            new _Dropdown().name("depositerMainBackpack")
            .x("s+10").y("p+20").w(w_controls)
            .tt("Selecione a backpack principal onde as backpacks ""filhas"" estarão dentro(para abrir próximas backpacks)", "Choose the main backpack where the ""child"" backpacks will be in(to open next backpacks)")
            .event("ChooseMainBackpack")
            .add()
            .list(this.getMainBackpackList())

            new _Button().title("Tutorial Depositer")
            .x("s+0").y("523").h(22).w(w_groupsub)
            .event(Func("openUrl").bind("https://youtu.be/XboGV6gUFJo?si=D_bJO9rxKaRrcB7M&t=637"))
            .icon(_Icon.get(_Icon.YOUTUBE), "a0 l2 b0 s14")
            .add()

        Disabled := lootingObj.depositSettings.backpackSettings.mainBackpack != "" ? "" : "Disabled"
        text := (LANGUAGE = "PT-BR" ? "Backpack ""filha"", deve estar dentro do container da Main Backpack, você pode colocar varias da mesma backpack filha dentro uma da outra" : """child"" backpack, it must be inside the Main Backpack container, you can put many of the same child backpack into one another")
        Gui, CavebotGUI:Add, Groupbox, xs+165 ys+0 w%w_groupsub% h198 Section, % LANGUAGE = "PT-BR" ? "Abrir próximas backpacks" : "Open next backpacks"

        Loop, 4 {
                new _Text().title("Backpack " A_Index ":")
                .x("s+10").y(A_Index = 1 ? "p+18" : "+8")
                .add()

                new _Dropdown().name("depositerBackpack" A_Index)
                .x("p+0").y("+3").w(w_controls)
                .tt("Primeira", "First ")
                .disabled(empty(lootingObj.depositSettings.backpackSettings.mainBackpack))
                .event("ChooseBackpacksDepositer")
                .add()
                .list(this.getBackpacksList(A_Index))
        }

    }

    /**
    * @return array<_ListOption>
    */
    getMainBackpackList()
    {
        list := {}
        list.Push(new _ListOption("Optional...", true))

        for key, bp in ItemsHandler.mainBackpacks {
            list.Push(new _ListOption(bp, lootingObj.depositSettings.backpackSettings.mainBackpack = bp))
        }

        return list
    }

    /**
    * @return array<_ListOption>
    */
    getBackpacksList(number)
    {
        list := {}
        list.Push(new _ListOption("Optional...", true))

        for key, bp in ItemsHandler.backpackList {
            list.Push(new _ListOption(bp, lootingObj.depositSettings.backpackSettings["backpack" number] = bp))
        }

        return list
    }

    ChildTab_TrashList() {
        global

        w_group := 150
        w_controls := w_group - 20

        Gui, CavebotGUI:Add, ListView, x15 y+6 h%LV_Waypoints_height% w%w_LVWaypoints% AltSubmit vLV_TrashList gLV_TrashList hwndhLV_TrashList LV0x1 LV0x10, #|Name|Use item|Weight|Price|Sprites|Animation

        Gui, CavebotGUI:Add, Groupbox, x%x_groupbox_listview% y50 w150 h90 Section, % (LANGUAGE = "PT-BR" ? "Editar item" : "Edit item")
        Gui, CavebotGUI:Add, Text, xs+10 yp+20, % (LANGUAGE = "PT-BR" ? "Nome do item" : "Item name:")
        Gui, CavebotGUI:Add, Edit, xs+10 y+3 vTrashItemNameEdit w%w_controls% h18 Disabled, % TrashItemNameEdit

        Gui, CavebotGUI:Add, Checkbox, xs+10 y+10 vUseTrashItemEdit gEditUseAtributeTrashItem, % (LANGUAGE = "PT-BR" ? "Usar item antes de jogar" : "Use item before drop")
        this.moveToListControls("TrashList", x_groupbox_listview, y := "+20")

            new _Button().title("Deletar item(s) da lista", "Delete item(s) from list")
            .xs().yadd(20).w(150)
            .event("RemoveItemTrashList")
            .icon(_Icon.get(_Icon.DELETE), "a0 l3 s14 b0")
            .add()

        Gui, CavebotGUI:Font, cGray
        Gui, CavebotGUI:Add, Text, xs+0 y+10 w150 Center, %  txt("TrashList é usada somente pra dropar lixos da backpack com a action ""droptrash()"".", "TrashList is used only to drop trash from the backpack with the ""droptrash()"" action.")
        Gui, CavebotGUI:Font,

        _GuiHandler.tutorialButtonModule("Looting")
    }

    moveToListControls(list, x_groupbox_listview, y := "+25", w := 150) {
        global
        options := ""
        index := 1
        for key, value in this.itemLists
        {
            if (value = list)
                continue
            options .= value "|" (index = 1 ? "|" : "")
            index++
        }
        Gui, CavebotGUI:Add, Groupbox, % "x" x_groupbox_listview " y" y " w" w " h100 Section", % txt("Mover item para a lista:" , "Move item to the list:")
        Gui, CavebotGUI:Add, Listbox, % "xp+10 yp+18 w" w - 20 " vmoveItemToList" list " ", % options

            new _Button().title("Mover item(s)", "Move item(s)")
            .name("moveItemFromList" list)
            .xp().y().w(w - 20)
            .event("moveItemToList")
            .icon(_Icon.get(_Icon.MOVE_ITEM), "a0 l3 s16 b0 t1")
            .add()
        ; Gui, CavebotGUI:Add, Button, % "xp+0 y+5 w" w - 20 " vmoveItemFromList" list " gmoveItemToList", % txt(


    }

    ChildTab_LootList() {
        global

        ; if (LootingSystem.lootingJsonObj.options.openCorpsesAround != true) {
        ;     Gui CavebotGUI:Font, cRed
        ;     Gui CavebotGUI:Add, Text, x20 y+10, LootList is available only for Old Tibia(manual looting without quick looting).
        ;     Gui CavebotGUI:Font,
        ;     return
        ; }

        w_group := 150
        w_controls := w_group - 20

        this.editLootListAtributesLabel := "editLootListItemAtribute"
        this.numberControls := {}
        this.numberControls.Push("triesItemLootList")

        DisabledTibia11 := (isTibia13()) ? "Disabled" : ""

        Gui, CavebotGUI:Add, ListView, x15 y+6 h%LV_Waypoints_height% w%w_LVWaypoints% AltSubmit vLV_LootList gLV_LootList hwndhLV_LootList LV0x1 LV0x10, #|Name|Destination|Ignore|Use item|Tries|Weight|Price|Sprites|Animation

        Gui, CavebotGUI:Add, Groupbox, x%x_groupbox_listview% y50 w150 h210 Section %DisabledTibia11%, % (LANGUAGE = "PT-BR" ? "Editar item" : "Edit item")
        Gui, CavebotGUI:Add, Text, xs+10 yp+20 , % txt("Nome do item:", "Item name:")
        Gui, CavebotGUI:Add, Edit, xs+10 y+3 vLootListItemNameEdit w%w_controls% h18 Disabled, % LootListItemNameEdit

        Gui, CavebotGUI:Add, Text, xs+10 y+7, % (LANGUAGE = "PT-BR" ? "Destino:" : "Destination:")
        Gui, CavebotGUI:Add, DDL, % "xp+0 y+3 vdestinationItemLootList hwndhdestinationItemLootList g" this.editLootListAtributesLabel " w" w_controls " " DisabledTibia11 " ", % A_Space "||" ItemsHandler.listBackpacksAndBags()
        TT.Add(hdestinationItemLootList, (LANGUAGE = "PT-BR" ? "Backpack de destino para mover o loot, se não selecionado, irá mover para a posição dixa do ""backpack position"" configurado em Game Areas" : "Backpack destination to move the loot to, if not selected, it will move to the fixed ""backpack position"" set in Game Areas"))

        Gui, CavebotGUI:Add, Text, xs+10 y+7, % txt("Tentativas lootear:", "Tries to loot:")
        Gui, CavebotGUI:Add, Edit, xp+0 y+3 vtriesItemLootList hwndhtriesItemLootList w%w_controls% h18 0x2000 Limit2 %DisabledTibia11%
        Gui, CavebotGUI:Add, UpDown, Range1-10
        TT.Add(htriesItemLootList, (LANGUAGE = "PT-BR" ? "Tentativas máximas para lootear o item caso haja mais de um na tela, ou por exemplo, quando você está com a backpack cheia e tenta lootear um item menos valioso como um food" : "Maximum times to try to loot the item in case there are more than one on screen or, for example, when you the backpack is full and try to loot a less valuable loot like a food"))


        Gui, CavebotGUI:Add, Checkbox, % "xs+10 y+8 vignoreItemLootList g" this.editLootListAtributesLabel " hwndhignoreItemLootList " DisabledTibia11 " ", % (LANGUAGE = "PT-BR" ? "Ignorar item" : "Ignore item")
        TT.Add(hignoreItemLootList, (LANGUAGE = "PT-BR" ? "Ignorar esse item" : "Ignore this item"))

        Gui, CavebotGUI:Add, Checkbox, % "xs+10 y+7 vuseItemLootList g" this.editLootListAtributesLabel " hwndhuseItemLootList " DisabledTibia11 " ", % (LANGUAGE = "PT-BR" ? "Usar o item(não lootear)" : "Only use item(don't loot)")
        TT.Add(huseItemLootList, (LANGUAGE = "PT-BR" ? "Se marcado, irá somente usar o item(como um food) no corpo (até 3 vezes) e não irá mover para a backpack(não irá lootear)" : "If checked, it will only use the item(like food) in the corpse (up to 3 times) and not move it to the backpack(won't loot)"))

        Gui, CavebotGUI:Add, Checkbox, % "xs+10 y+7 vdropItemLootList g" this.editLootListAtributesLabel " hwndhdropItemLootList " DisabledTibia11 " ", % (LANGUAGE = "PT-BR" ? "Jogar loot no chão" : "Drop loot on ground")
        TT.Add(hdropItemLootList, (LANGUAGE = "PT-BR" ? "Se marcado, irá jogar o loot no sqm do personagem(não irá lootear)" : "If checked, it will drop the loot in the character's sqm (it won't loot)"))

        this.moveToListControls("LootList", x_groupbox_listview, y := "+15")


            new _Button().title("Deletar item(s) da lista", "Delete item(s) from list")
            .xs().yadd(17).w(150)
            .event("RemoveItemLootList")
            .icon(_Icon.get(_Icon.DELETE), "a0 l3 s14 b0")
            .add()


        HiddenLootingOptions := ""
        if (isTibia13()) {
            HiddenLootingOptions := "Hidden"
            Gui, CavebotGUI:Font, cGray
            Gui, CavebotGUI:Add, Text, xs+0 y+10 w150 Center, %  txt("LootList no " StrReplace(TibiaClient.Tibia13Identifier, "+", "") " é usado somente para vender itens com a action ""sellitemnpc(LootList)"".", "LootList in " StrReplace(TibiaClient.Tibia13Identifier, "+", "") " is only used for selling items with ""sellitemnpc(LootList)"" action.")
            Gui, CavebotGUI:Font,
        } else if (LootingSystem.lootingJsonObj.options.openCorpsesAround = false) {
            HiddenLootingOptions := "Hidden"
            Gui, CavebotGUI:Font, cRed
            Gui, CavebotGUI:Add, Text, xs+0 y+10 w150 Center +BackgroundTrans, % (LANGUAGE = "PT-BR" ? "O cliente atual possui Quick Looting, LootList será usado somente para vender itens com a action ""sellitemnpc(LootList)""." : "Current client has Quick Looting, LootList will only be used for selling items with ""sellitemnpc(LootList)"" action.")
            Gui, CavebotGUI:Font,
        }


        Gui, CavebotGUI:Add, Groupbox, x%x_groupbox_listview% ym+450 w150 h70 Section %DisabledTibia11%  %HiddenLootingOptions%, Looting Options
        Gui, CavebotGUI:Add, Text, xs+10 yp+20 %DisabledTibia11%  %HiddenLootingOptions%, % (LANGUAGE = "PT-BR" ? "Tentativas de usar item:" : "Tries to use item:")
        Gui, CavebotGUI:Add, Edit, xs+10 y+3 vtriesToUseItem hwndhtriesToUseItem gtriesToUseItem w%w_controls% h18 0x2000 Limit2 %DisabledTibia11% %HiddenLootingOptions%, % lootingObj.settings.triesToUseItem
        Gui, CavebotGUI:Add, UpDown, Range1-99 %DisabledTibia11% %HiddenLootingOptions%, % lootingObj.settings.triesToUseItem
        TT.Add(htriesToUseItem, (LANGUAGE = "PT-BR" ? "Tentativas para usar o item caso haja mais de um na tela ou, por exemplo, quando o personagem está cheio(sem fome) e tenta usar um food" : "Times to try to use the item in case there are more than one on screen or, for example, when the character is full(not hungry) and try to use a food"))

            new _ControlFactory(_ControlFactory.SET_GAME_AREAS_BUTTON)
            .xs(0).ym(525).w(150)
            .hidden(HiddenLootingOptions ? true : false)
            .add()

        _GuiHandler.tutorialButtonModule("Looting")
    }

    ChildTab_ItemList() {
        global
        local Disabled

        Gui, CavebotGUI:Add, Text,x15 y+5 +BackgroundTrans, Name:
        Gui, CavebotGUI:Add, Edit, x+5 yp-3 w100 h21 vsearchFilter_Name hwndhsearchFilter_Name gSearchItemList, % searchFilter_Name
        SetEditCueBanner(hsearchFilter_Name, "Search item...")

        searchFilter_Rows := (searchFilter_Rows < 1) ? 100 : searchFilter_Rows
        searchFilter_Rows := (searchFilter_Rows > 200) ? 200 : searchFilter_Rows
        Gui, CavebotGUI:Add, Combobox, x+5 yp+0 w125 vsearchFilter_Category gSearchItemList, % "Filter category...||" ItemsHandler.listCategories()


        DisabledIsTibia11 := (isTibia13()) ? "Disabled" : ""

        if (!A_IsCompiled) {
            Gui, CavebotGUI:Add, Checkbox,x+5 yp+3 vsearchFilter_Client gSearchItemList Checked%0% %DisabledIsTibia11% +BackgroundTrans, % "*" txt("Cliente atual", "Current client")
        }

        Gui, CavebotGUI:Add, Text,xm+565 yp+0 vsearchFilter_RowsText +BackgroundTrans, Rows:
        Gui, CavebotGUI:Add, Edit, x+5 yp-3 w60 h21 Limit3 0x2000 vsearchFilter_Rows hwndhsearchFilter_Rows gSearchItemList, % searchFilter_Rows
        Gui, CavebotGUI:Add, Updown, w60 h21 Range1-200 0x80, % searchFilter_Rows
        ; Gui, CavebotGUI:Add, Checkbox,x+5 yp+3 vsearchFilter_ShowAllRows gSearchItemList Checked%0%, Show all
        ; Gui, CavebotGUI:Add, Slider, x+5 yp+0 h21 w200

        h := LV_Waypoints_height - 18

        Gui, CavebotGUI:Add, ListView, x15 ym+66 h%h% w%w_LVWaypoints% AltSubmit vLV_ItemList gLV_ItemList hwndhLV_ItemList LV0x1 LV0x10, Image|Name|Category|Stackable|Animation|Sprites|Weight|#|Timestamp

        Disabled :=  ""

        Gui, CavebotGUI:Font,

        Gui, CavebotGUI:Add, Groupbox, x%x_groupbox_listview% y50 w150 h310 Section %Disabled% , Add/edit item

            new _Button().title("Testar item", "Test item")
            .name("testItemImage")
            .xs(10).yp(18).w(130).h(30)
            .tt("Procura pela imagem do item(todas as sprites caso tenha mais de uma) na tela.", "Search for the image of the item(all its sprites in case it has more than one) on screen.")
            .event("testItemImage")
            .icon(_Icon.get(_Icon.CAMERA), "a0 l5 s18 b0")
            .add()

        Gui, CavebotGUI:Add, Text, xs+10 y+5 %Disabled%, % txt("Nome do item:", "Item name:")
        Gui, CavebotGUI:Add, Edit, xs+10 y+3 vitemNameToAdd w130 h18 %Disabled%, % itemNameToAdd

        Gui, CavebotGUI:Add, Text, xs+10 y+8 %Disabled%, % txt("Categoria:", "Category:")
        Gui, CavebotGUI:Add, DDL, xs+10 y+3 vitemCategory geditItemListCategory w130, % ItemsHandler.listCategories()

        ; Gui, CavebotGUI:Add, Checkbox, xs+10 y+8 vanimatedSprite Checked%0% %Disabled%, % txt("Sprite com animação", "Animated sprite")
        ; Gui, CavebotGUI:Add, Checkbox, xs+10 y+7 vstackableItem gstackableItem Checked%0% %Disabled%, % txt("Item stackável", "Stackable item")
        ; Gui, CavebotGUI:Add, Checkbox, xs+10 y+7 vdifferentSprites gdifferentSprites Checked%0% %Disabled%, % txt("Item c/ diferentes sprites", "Item with sprites")
        Gui, CavebotGUI:Add, Text, xs+10 y+10 %Disabled%, Sprite:
        itemSpriteSelected := ""

        Gui, CavebotGUI:Add, Radio, % "xs+11 y+3 vItemSprite1 gItemSprite " Disabled " " (itemSpriteSelected = "1" ? "Checked" : ""), 1
        Gui, CavebotGUI:Add, Radio, % "x+6 yp+0 vItemSprite2 gItemSprite " Disabled " " (itemSpriteSelected = "2" ? "Checked" : ""), 2
        Gui, CavebotGUI:Add, Radio, % "x+6 yp+0 vItemSprite3 gItemSprite " Disabled " " (itemSpriteSelected = "3" ? "Checked" : ""), 3
        Gui, CavebotGUI:Add, Radio, % "x+6 yp+0 vItemSprite4 gItemSprite " Disabled " " (itemSpriteSelected = "4" ? "Checked" : ""), 4
        Gui, CavebotGUI:Add, Radio, % "xs+11 y+5 vItemSprite5 gItemSprite " Disabled " " (itemSpriteSelected = "5" ? "Checked" : ""), 5
        Gui, CavebotGUI:Add, Radio, % "x+6 yp+0 vItemSprite6 gItemSprite " Disabled " " (itemSpriteSelected = "6" ? "Checked" : ""), 6
        Gui, CavebotGUI:Add, Radio, % "x+6 yp+0 vItemSprite7 gItemSprite " Disabled " " (itemSpriteSelected = "7" ? "Checked" : ""), 7
        Gui, CavebotGUI:Add, Radio, % "x+6 yp+0 vItemSprite8 gItemSprite " Disabled " " (itemSpriteSelected = "8" ? "Checked" : ""), 8


        Gui, CavebotGUI:Add, Groupbox, xs+10 y+5 w130 h8 cBlack

        Disabled := OldBotSettings.settingsJsonObj.configFile = "settings.json" ? "" : "Disabled"

        ; if (!A_IsCompiled) {
        ; Gui, CavebotGUI:Add, Checkbox, xs+10 y+9 vsearchItem Checked%0%, Search on cyclopedia?
        ; Gui, CavebotGUI:Add, Button, xs+10 y+5 w130 vAddNewItem_ItemListCyclopedia gAddItemPictureCyclopedia, Add from Cyclopedia
        ; }
        ; if (!A_IsCompiled)
        ; Gui, CavebotGUI:Add, Button, xs+10 y+5 w130 gGetItemsImageCyclopedia, Add all from custom list


        Gui, CavebotGUI:Add, Text, xs+10 y+6, % txt("Item está na Backpack:", "Item is in Backpack:")
        Gui, CavebotGUI:Add, DDL, xs+10 y+3 w130 vselectedBackpack hwndhselectedBackpack, % _ItemsHandler.mainBackpackAlias() "||"


            new _Button().title("Add from backpack")
            .name("AddNewItem_ItemListBackpack")
            .xs(10).yadd(3).w(130)
            .tt(text := txt("O item deve estar no PRIMEIRO slot da backpack", "The item must be in the FIRST slot of the backpack"))
            .event("AddItemPictureBackpack")
            .icon(_Icon.get(_Icon.PLUS), "a0 l3 s14 b0")
            .add()

        TT.Add(hselectedBackpack, (LANGUAGE = "PT-BR" ? "Backpack em que o item está dentro." : "Backpack where the item is inside") "`n" text)

        Disabled := ""

            new _Button().title("Add do clipboard", "Add from clipboard")
            .xs(10).yadd(3).w(130)
            .tt("Adicionar uma imagem do clipboard", "Add an image from the clipboard", " (Ctrl+C)")
            .event("AddItemPictureClipboard")
            .icon(_Icon.get(_Icon.PLUS), "a0 l3 s14 b0")
            .add()

        Gui, CavebotGUI:Add, Groupbox, x%x_groupbox_listview% ym+365 w150 h119 Section, Add to List

            new _Button().title("Add to LootList")
            .xs(10).yp(16).w(130)
            .event("AddItemLootList")
            .icon(_Icon.get(_Icon.MOVE_ITEM), "a0 l3 s16 b0 t1")
            .add()

            new _Button().title("Add to SellList")
            .xs(10).yadd(1).w(130)
            .event("AddItemSellList")
            .icon(_Icon.get(_Icon.MOVE_ITEM), "a0 l3 s16 b0 t1")
            .add()

            new _Button().title("Add to DepositList")
            .xs(10).yadd(1).w(130)
            .event("AddItemDepositList")
            .icon(_Icon.get(_Icon.MOVE_ITEM), "a0 l3 s16 b0 t1")
            .add()

            new _Button().title("Add to TrashList")
            .xs(10).yadd(1).w(130)
            .event("AddItemTrashList")
            .icon(_Icon.get(_Icon.MOVE_ITEM), "a0 l3 s16 b0 t1")
            .add()

        ; Gui, CavebotGUI:Add, Button, xs+10 yp+16 w130 vAddItemLootList gAddItemLootList, Add to LootList
        ; Gui, CavebotGUI:Add, Button, xs+10 y+1 w130 vAddItemSellList gAddItemSellList, Add to SellList
        ; Gui, CavebotGUI:Add, Button, xs+10 y+1 w130 vAddItemDepositList gAddItemDepositList, Add to DepositList
        ; Gui, CavebotGUI:Add, Button, xs+10 y+1 w130 vAddItemTrashList gAddItemTrashList, Add to TrashList
        Disabled := (LootingSystem.lootingJsonObj.options.openCorpsesAround = true) ? "" : "Disabled"


        ; Gui, CavebotGUI:Add, Button, xs+0 y+15 w150 gItemDatabaseGUI hwndhitemDatabase, % txt("Database de Items", "Items Database")
        ; iconNumber := (isWin11() = true) ? 233 : 232
        ; TT.Add(hitemDatabase, txt("As imagens dos itens ficam salvas localmente no seu pc em um arquivo, que pode ser sobrescrito ao rodar o instalado.`n`nPara não perder as imagens de novos itens capturados, você pode fazer upload das imagens no banco de dados do OldBot, dessa forma todos os usuários alimentam um banco de dados com as imagens dos itens em diferentes OT servers.", "The items images are saved locally in your pc in a file, that can be overwritten when running the installer.`n`nTo not lose the image of new itens captured, you can upload the imagens in the database of OldBot, in this way all users feed a database with the image of items from different OT servers.")),
        ; GuiButtonIcon(hitemDatabase, "imageres.dll", iconNumber, "a0 l5 s18 b0")

        Disabled := A_IsCompiled ? "Disabled" : ""

            new _Button().title("Deletar item(s)", "Delete item(s)")
            .xs().ym(527).w(150)
            .event("DeleteItem_ItemList")
            .icon(_Icon.get(_Icon.DELETE), "a0 l5 s14 b0")
            .add()
        ; Gui, CavebotGUI:Add, Button, xs+0 ym+527 w150 vDeleteItem_Itemlist gDeleteItem_ItemList, % txt(
        ; Gui, CavebotGUI:Add, Button, xs+0 y+5 w150 vRefreshList_ItemList gRefreshList_ItemList, Refresh list


        _GuiHandler.tutorialButtonModule("Looting")
    }

    ChildTab_SellList() {
        global

        w_group := 150
        w_controls := w_group - 20

        this.editSellListAtributesLabel := "editSellListItemAtribute"
        this.numberControls := {}
        this.numberControls.Push("triesItemSellList")


        Gui, CavebotGUI:Add, ListView, x15 y+6 h%LV_Waypoints_height% w%w_LVWaypoints% AltSubmit vLV_SellList gLV_SellList hwndhLV_SellList LV0x1 LV0x10, #|Name|Ignore|Weight|Price|Sprites|Animation

        Gui, CavebotGUI:Add, Groupbox, x%x_groupbox_listview% y50 w150 h90 Section, % (LANGUAGE = "PT-BR" ? "Editar item" : "Edit item")
        Gui, CavebotGUI:Add, Text, xs+10 yp+20, % (LANGUAGE = "PT-BR" ? "Nome do item:" : "Item name:")
        Gui, CavebotGUI:Add, Edit, xs+10 y+3 vSellListItemNameEdit w%w_controls% h18 Disabled, % SellListItemNameEdit


        Gui, CavebotGUI:Add, Checkbox, % "xs+10 y+10 vignoreItemSellList g" this.editSellListAtributesLabel " hwndhignoreItemSellList", % (LANGUAGE = "PT-BR" ? "Ignorar item" : "Ignore item")
        TT.Add(hignoreItemSellList, (LANGUAGE = "PT-BR" ? "Ignorar esse item(não irá vender)" : "Ignore this item(it won't sell)"))

        ; Gui, CavebotGUI:Add, Checkbox, % "xs+10 y+10 vmustBeVisibleItemSellList g" this.editSellListAtributesLabel " hwndhmustBeVisibleItemSellList "  " ", % (LANGUAGE = "PT-BR" ? "Item deve estar visível" : "Item must be visible")
        ;     TT.Add(hmustBeVisibleItemSellList, (LANGUAGE = "PT-BR" ? "Ignorar esse item" : "Ignore this item"))

        this.moveToListControls("SellList", x_groupbox_listview, y := "+20")

            new _Button().title("Deletar item(s) da lista", "Delete item(s) from list")
            .xs().yadd(20).w(150)
            .event("RemoveItemSellList")
            .icon(_Icon.get(_Icon.DELETE), "a0 l3 s14 b0")
            .add()


        Gui, CavebotGUI:Font, cGray
        Gui, CavebotGUI:Add, Text, xs+0 y+10 w150 Center, % (LANGUAGE = "PT-BR" ? "SellList no " StrReplace(TibiaClient.Tibia13Identifier, "+", "") " é usado somente para vender itens com a action ""sellitemnpc(SellList)""." : "SellList on " StrReplace(TibiaClient.Tibia13Identifier, "+", "") " is only used for selling items with ""sellitemnpc(SellList)"" action.")
        Gui, CavebotGUI:Font,


        _GuiHandler.tutorialButtonModule("Looting")
    }


    createItemDatabaseGUI() {
        global

        Gui, ItemDatabaseGUI:Destroy
        Gui, ItemDatabaseGUI: -MinimizeBox
        Gui, ItemDatabaseGUI:Add, Text, x10 y+5, % "Current client: """ TibiaClient.getClientIdentifier() """"
        Gui, ItemDatabaseGUI:Add, Button, x10 y+5 w150 h25 guploadItemsDatabase, Upload items
        Gui, ItemDatabaseGUI:Add, Button, x10 y+5 w150 h25 gdownloadItemsDatabase, Download items
        Gui, ItemDatabaseGUI:Show,, % "Items Database"

    }

    selectItemOnItemList(itemName, offset := 0) {
        Gui, CavebotGUI:Default
        Gui, ListView, LV_ItemList
        maxRow := LV_GetCount()
        Loop,% LV_GetCount()
        {
            LV_GetText(RetrievedText, A_Index, 2)
            if (RetrievedText = itemName) {
                LV_Modify( A_Index, "Focus Select")
                LV_Modify((A_Index + offset > maxRow) ? A_Index : A_Index + offset, "Vis")
                break
            }
        }
    }


    LV_DepositList() {
        Gui, CavebotGUI:Default
        Gui, ListView, LV_DepositList

        GuiControl, CavebotGUI:-g, LV_DepositList

        selectedLine := LV_GetNext()
        LV_GetText(selectedItem,selectedLine,2)
        if (selectedItem = "" OR selectedItem = "Name") {
            GuiControl, CavebotGUI:+gLV_DepositList, LV_DepositList
            return
        }
        GuiControl, CavebotGUI:, depositerItemNameEdit, % selectedItem

        GuiControl, CavebotGUI:ChooseString, depositerItemCategoryEdit, % lootingObj.depositList[selectedItem].category

        GuiControl, CavebotGUI:+gLV_DepositList, LV_DepositList
    }


    LV_TrashList() {
        Gui, CavebotGUI:Default
        Gui, ListView, LV_TrashList

        GuiControl, CavebotGUI:-g, LV_TrashList

        selectedLine := LV_GetNext()
        LV_GetText(selectedItem,selectedLine,2)
        if (selectedItem = "" OR selectedItem = "Name") {
            GuiControl, CavebotGUI:+gLV_TrashList, LV_TrashList
            return
        }
        GuiControl, CavebotGUI:, trashItemNameEdit, % selectedItem

        UseTrashItemEdit := trashListObj[selectedItem].use

        GuiControl, CavebotGUI:, UseTrashItemEdit, % UseTrashItemEdit

        GuiControl, CavebotGUI:+gLV_TrashList, LV_TrashList
    }

    LV_LootList() {
        Gui, CavebotGUI:Default
        Gui, ListView, LV_LootList

        GuiControl, CavebotGUI:-g, LV_LootList

        selectedLine := LV_GetNext()
        LV_GetText(selectedItem,selectedLine,2)
        if (selectedItem = "" OR selectedItem = "Name") {
            GuiControl, CavebotGUI:+gLV_LootList, LV_LootList
            return
        }
        GuiControl, CavebotGUI:, lootListItemNameEdit, % selectedItem

        ignoreItemLootList := lootListObj[selectedItem].ignore = "" ? false : lootListObj[selectedItem].ignore
        useItemLootList := lootListObj[selectedItem].use = "" ? false : lootListObj[selectedItem].use
        dropItemLootList := lootListObj[selectedItem].drop = "" ? false : lootListObj[selectedItem].drop

        GuiControl, CavebotGUI:, ignoreItemLootList, % ignoreItemLootList
        GuiControl, CavebotGUI:, useItemLootList, % useItemLootList
        GuiControl, CavebotGUI:, dropItemLootList, % dropItemLootList
        GuiControlEdit("CavebotGUI", "triesItemLootList", lootListObj[selectedItem].tries, this.editLootListAtributesLabel)
        GuiControl, CavebotGUI:ChooseString, destinationItemLootList, % A_Space
        GuiControl, CavebotGUI:ChooseString, destinationItemLootList, % lootListObj[selectedItem].destination

        GuiControl, CavebotGUI:+gLV_LootList, LV_LootList
    }

    LV_SellList() {
        Gui, CavebotGUI:Default
        Gui, ListView, LV_SellList

        GuiControl, CavebotGUI:-g, LV_SellLaist

        selectedLine := LV_GetNext()
        LV_GetText(selectedItem,selectedLine,2)
        if (selectedItem = "" OR selectedItem = "Name") {
            GuiControl, CavebotGUI:+gLV_SellList, LV_SellList
            return
        }
        GuiControl, CavebotGUI:, SellListItemNameEdit, % selectedItem

        GuiControl, CavebotGUI:, ignoreItemSellList, % sellListObj[selectedItem].ignore = "" ? false : SellListObj[selectedItem].ignore
        ; GuiControl, CavebotGUI:, mustBeVisibleItemSellList, % sellListObj[selectedItem].mustBeVisible = "" ? false : SellListObj[selectedItem].mustBeVisible

        GuiControl, CavebotGUI:+gLV_SellList, LV_SellList
    }

    LV_ItemList() {
        Gui, CavebotGUI:Default
        Gui, ListView, LV_ItemList

        GuiControl, CavebotGUI:-g, LV_ItemList

        selectedLine := LV_GetNext()
        LV_GetText(selectedItem,selectedLine,2)
        if (selectedItem = "" OR selectedItem = "Name") {
            GuiControl, CavebotGUI:+gLV_ItemList, LV_ItemList
            return
        }
        itemNameToAdd := selectedItem
        GuiControl, CavebotGUI:, itemNameToAdd, % itemNameToAdd

        GuiControl, CavebotGUI:, animatedSprite, % itemsImageObj[selectedItem].animated_sprite = true ? 1 : 0
        stackableItem := itemsImageObj[selectedItem].stackable = "stackable" ? 1 : 0
        GuiControl, CavebotGUI:, stackableItem, % stackableItem

        GuiControl, CavebotGUI:Enable, itemCategory

        category := ItemsHandler.getItemAtribute(selectedItem, "category")
        if (category = "" || IsObject(category)) {
            category := ItemsHandler.getItemAtribute(selectedItem, "primarytype")
        }
        GuiControl, CavebotGUI:ChooseString, itemCategory, % category


        if (InStr(selectedItem, "_", 0) OR itemsImageObj[selectedItem].sprites > 1) {
            if (InStr(selectedItem, "_", 0)) {
                StringTrimRight, itemNameToAdd, selectedItem, 2
                StringTrimLeft, itemNumber, selectedItem, StrLen(selectedItem) - 1
            } else {
                itemNumber := 1
            }

            GuiControl, CavebotGUI:, itemNameToAdd, % itemNameToAdd
            GuiControl, CavebotGUI:Enable, differentSprites
            GuiControl, CavebotGUI:, differentSprites, 1

            Loop, 8 {
                GuiControl, CavebotGUI:, ItemSprite%A_Index%, 0
                GuiControl, CavebotGUI:Enable, ItemSprite%A_Index%
            }

            itemSpriteSelected := itemNumber
            GuiControl, CavebotGUI:, ItemSprite%itemNumber%, 1
        } else {
            itemSpriteSelected := ""
            GuiControl, CavebotGUI:, differentSprites, 0
            if (stackableItem = 1)
                GuiControl, CavebotGUI:Enable, differentSprites
            ; else
            ; GuiControl, CavebotGUI:Disable, differentSprites
            Loop, 8 {
                GuiControl, CavebotGUI:Disable, ItemSprite%A_Index%
                GuiControl, CavebotGUI:, ItemSprite%A_Index%, 0
            }
        }

        ; msgbox, % itemsImageObj[selectedItem].stackable
        GuiControl, CavebotGUI:+gLV_ItemList, LV_ItemList



    }

    LoadDepositListLV() {
        try {
            _ListviewHandler.loadingLV("LV_DepositList")
        } catch {
            return
        }

        index := 1
        for itemName, item in lootingObj.depositList
        {

            price := (InStr(itemsObj[itemName].value, "Negotiable",0) ? "?" : itemsObj[itemName].value) " gps"
            weight := (itemsObj[itemName].weight = "") ? "" : itemsObj[itemName].weight " oz"

            Gui, ListView, LV_DepositList
            LV_Add("", index, itemName, item.category, weight, price, itemsImageObj[itemName].sprites, (itemsImageObj[itemName].animated_sprite = 1) ? "true" : "false")
            index++
        }


        Loop, 7 {
            Gui, ListView, LV_DepositList
            LV_ModifyCol(A_Index, "autohdr")
        }


        _ListviewHandler.setColumnInteger(1, "LV_DepositList")
        _ListviewHandler.setColumnInteger(4, "LV_DepositList") ; weight
        ; _ListviewHandler.setColumnInteger(5, "LV_DepositList") ; price
        _ListviewHandler.setColumnInteger(6, "LV_DepositList") ; sprites
        _ListviewHandler.setColumnInteger(6, "LV_DepositList") ; sprites
        return
    }

    LoadItemListLV(searchFilter_Name := "", searchFilter_Category := "", searchFilter_Rows := "", searchFilter_ShowAllRows := 0) {
        try {
            _ListviewHandler.loadingLV("LV_ItemList")
        } catch {
            return
        }

        searchFilter_Rows := searchFilter_Rows ? searchFilter_Rows : 100

        loading_LV_ItemList := true

        ; LV_ItemListColors.Clear()
        Gui, ListView, LV_ItemList
        IL_Destroy(ImageListID_LV_ItemList)  ; Required for image lists used by tab_name controls.

        IconWidth      :=  32
            , IconHeight   := 32
            , IconBitDepth := 24 ;
            , InitialCount :=  1 ; The starting Number of Icons available in ImageList
            , GrowCount    :=  1

        Gui, ListView, LV_ItemList
        ImageListID_LV_ItemList  := DllCall( "ImageList_Create", Int,IconWidth,    Int,IconHeight
            , Int,IconBitDepth, Int,InitialCount
            , Int,GrowCount )

        Gui, ListView, LV_ItemList
        LV_SetImageList( ImageListID_LV_ItemList, 1 ) ; 0 for large icons, 1 for small icons
        ; LV_SetImageList( DllCall( "ImageList_Create", Int,2, Int,rh, Int,0x18, Int,1, Int,1 ), 1 )
        ; msgbox, % serialize(itemsImageObj)
        index := 1
        ; list := isTibia13() ? itemsImageObj : itemsImageObj
        for itemName, item in itemsImageObj
        {
            ; m("searchFilter_ShowAllRows " searchFilter_ShowAllRows, index, "searchFilter_Rows " searchFilter_Rows)
            if (!searchFilter_ShowAllRows) && (index > searchFilter_Rows)
                break
            itemNameNoSprite := ItemsHandler.itemNameNoSprite(itemName)

            if (searchFilter_Category != "") && (ItemsHandler.getItemAtribute(itemNameNoSprite, "category") != "") && (ItemsHandler.getItemAtribute(itemNameNoSprite, "category") != searchFilter_Category)
                continue


            if (searchFilter_Name != "") && (!InStr(itemName, searchFilter_Name, 0))
                continue

            if (searchFilter_Client = true) && (!customItemsImageObj[itemName])
                continue

            if (customItemsImageFile) && (customItemsImageObj[itemName] != "") {
                item := customItemsImageObj[itemName]
            }

            pBitmap := GdipCreateFromBase64(item.image_full)
                , hBitmap:=Gdip_CreateHBITMAPFromBitmap(pBitmap)
            ; pBitmap := GdipCreateFromBase64(InStr(itemName, "_") ? item.image : item.image_full)

            Gui, ListView, LV_ItemList
            IL_Add(ImageListID_LV_ItemList , "HBITMAP:" hBitmap, 0xFFFFFF, 1)  ; 0xFFFFFF to use with imanges insted of icons
            Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
            ; IL_Add(ImageListID_LV_ItemList, "Data\Items\" itemName ".png", 0xFFFFFF, 1)  ; 0xFFFFFF to use with imanges insted of icons

            ItemsHandler.addItemListRow(itemName, index)

            ; LV_Add("Icon" index,"", itemName, itemsObj[itemNameNoSprite].primarytype, (item.stackable = "stackable") ? "yes" : "no", (item.animated_sprite = 1) ? "true" : "false", item.sprites, weight, index, item.timestamp)
            index++
        }


        Loop, 10
        {
            Gui, ListView, LV_ItemList
            LV_ModifyCol(A_Index, "autohdr")
        }

        LV_ModifyCol(2, 140)
        LV_ModifyCol(3, 70) ; category
        LV_ModifyCol(8, 45)
        LV_ModifyCol(9, 98)


        ; GuiControl, CavebotGUI:Enable, LV_Waypoints_Waypoints
        /*
        sprites|weight|timestamp|#
        */
        Loop, 3
            _ListviewHandler.setColumnInteger(5 + A_Index, "LV_ItemList")

        ; _ListviewHandler.setColumnInteger(9, "LV_ItemList") ; timestamp

        loading_LV_ItemList := false
    }

    LoadTrashListLV() {
        try {
            _ListviewHandler.loadingLV("LV_TrashList")
        } catch {
            return
        }
        ; if (LootingSystem.lootingJsonObj.options.openCorpsesAround = true)
        ; return


        /*
        IL_Destroy(ImageListID_LV_TrashList)  ; Required for image lists used by tab_name controls.

        local IconWidth    :=  32
        local IconHeight   := 19
        local IconBitDepth := 24 ;
        local InitialCount :=  1 ; The starting Number of Icons available in ImageList
        local GrowCount    :=  1

        ImageListID_LV_TrashList  := DllCall( "ImageList_Create", Int,IconWidth,    Int,IconHeight
        , Int,IconBitDepth, Int,InitialCount
        , Int,GrowCount )

        LV_SetImageList( ImageListID_LV_TrashList, 1 ) ; 0 for large icons, 1 for small icons
        */

        index := 1
        for itemName, item in trashListObj
        {
            if (InStr(itemName, "_"))
                continue

            ; pBitmap := GdipCreateFromBase64(item.image) ; 640x384 Base64 encoded PNG image string returned as HBITMAP]
            ; , hBitmap:=Gdip_CreateHBITMAPFromBitmap(pBitmap)

            ; IL_Add(ImageListID_LV_TrashList , "HBITMAP:" hBitmap, 0xFFFFFF, 1)  ; 0xFFFFFF to use with imanges insted of icons
            ; Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
            ; IL_Add(ImageListID_LV_TrashList, "Data\Items\" itemName ".png", 0xFFFFFF, 1)  ; 0xFFFFFF to use with imanges insted of icons

            price := (InStr(itemsObj[itemName].value, "Negotiable",0) ? "?" : itemsObj[itemName].value) " gps"
            weight := (itemsObj[itemName].weight = "") ? "" : itemsObj[itemName].weight " oz"
            Gui, ListView, LV_TrashList
            LV_Add("",index, itemName, (item.use = true) ? "true" : "false", weight, price,itemsImageObj[itemName].sprites, (itemsImageObj[itemName].animated_sprite = 1) ? "true" : "false")
            index++
        }

        Loop, 7 {
            Gui, ListView, LV_TrashList
            LV_ModifyCol(A_Index, "autohdr")
        }

        _ListviewHandler.setColumnInteger(1, "LV_TrashList")
        ; _ListviewHandler.setColumnInteger(3, "LV_TrashList") ; use item
        _ListviewHandler.setColumnInteger(4, "LV_TrashList") ; weight
        ; _ListviewHandler.setColumnInteger(5, "LV_TrashList") ; price
        _ListviewHandler.setColumnInteger(6, "LV_TrashList") ; sprites
    }

    LoadLootListLV() {
        try {
            _ListviewHandler.loadingLV("LV_LootList")
        } catch {
            return
        }

        ; msgbox, % serialize(itemsImageObj)
        index := 1
        for itemName, atributes in lootListObj
        {
            if (InStr(itemName, "_"))
                continue

            price := (InStr(itemsObj[itemName].value, "Negotiable",0) ? "?" : itemsObj[itemName].value) " gps"
            weight := (itemsObj[itemName].weight = "") ? "" : itemsObj[itemName].weight " oz"
            Gui, ListView, LV_LootList
            LV_Add("",index, itemName, atributes.destination = "" ? "position (backpack)" : atributes.destination, (atributes.ignore = true) ? "true" : "false", (atributes.use = true) ? "true" : "false", atributes.tries, weight, price,itemsImageObj[itemName].sprites, (itemsImageObj[itemName].animated_sprite = 1) ? "true" : "false")
            index++
        }

        Loop, 10 {
            Gui, ListView, LV_LootList
            LV_ModifyCol(A_Index, "autohdr")
        }

        /*
        weight|price|sprites
        */
        loop, 3
            _ListviewHandler.setColumnInteger(6 + A_Index, "LV_LootList")
    }

    LoadSellListLV() {
        try {
            _ListviewHandler.loadingLV("LV_SellList")
        } catch {
            return
        }

        ; msgbox, % serialize(itemsImageObj)
        index := 1
        for itemName, atributes in sellListObj
        {
            if (InStr(itemName, "_"))
                continue

            price := (InStr(itemsObj[itemName].value, "Negotiable",0) ? "?" : itemsObj[itemName].value) " gps"
            weight := (itemsObj[itemName].weight = "") ? "" : itemsObj[itemName].weight " oz"
            Gui, ListView, LV_SellList
            LV_Add("",index, itemName, (atributes.ignore = true) ? "true" : "false", weight, price,itemsImageObj[itemName].sprites, (itemsImageObj[itemName].animated_sprite = 1) ? "true" : "false")
            index++
        }

        Loop, 7 {
            Gui, ListView, LV_SellList
            LV_ModifyCol(A_Index, "autohdr")
        }

        /*
        weight|price|sprites
        */
        loop, 3
            _ListviewHandler.setColumnInteger(3 + A_Index, "LV_SellList")
    }

    checkLootingGuiSettingsControls() {
        /*
        Enable every beforehand control that has a Disabled action condition below
        */
        GuiControl, CavebotGUI:Enable, lootAfterAllKill
        GuiControl, CavebotGUI:Enable, lootCreaturesPosition
        GuiControl, CavebotGUI:Enable, showCreaturePosition
        GuiControl, CavebotGUI:Enable, openNextBackpack
        /*
        DISABLE control must be after ENABLE
        */
        if (lootingObj.settings.lootCreaturesPosition) {
            GuiControl, CavebotGUI:Disable, lootAfterAllKill
            if (lootingObj.settings.lootAfterAllKill = false)
                GuiControl,, lootAfterAllKill, % lootingObj.settings.lootAfterAllKill := 1
        } else {
            if (!CavebotScript.isCoordinate()) {
                GuiControl, CavebotGUI:Disable, lootCreaturesPosition
                GuiControl, CavebotGUI:Disable, searchCorpseImages
                if (jsonConfig("targeting", "options", "disableCreaturePositionCheck")) {
                    GuiControl, CavebotGUI:Disable, showCreaturePosition
                }
            }

        }

        switch LootingSystem.lootingJsonObj.options.openCorpsesAround {
            case true:
            default:
                GuiControl, CavebotGUI:Disable, openNextBackpack
        }

        switch jsonConfig("targeting", "options", "disableCreaturePositionCheck") {
            case true:
                GuiControl, CavebotGUI:Disable, showCreaturePosition
                if (lootingObj.settings.showCreaturePosition = true)
                    GuiControl,, showCreaturePosition, % lootingObj.settings.showCreaturePosition := 0
        }

    }



}
