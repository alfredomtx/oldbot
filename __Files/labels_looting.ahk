
LootOnlyWithXMonsters:
    GuiControlGet, LootOnlyWithXMonsters
    IniWrite, %LootOnlyWithXMonsters%, %DefaultProfile%, cavebot_settings, LootOnlyWithXMonsters
    if (LootOnlyWithXMonsters = 1) {
        GuiControl, CavebotGUI:Enable, LootOnlyWithXMonsters_Text
        GuiControl, CavebotGUI:Enable, AmountMonstersToLoot
    } else {
        GuiControl, CavebotGUI:Disable, LootOnlyWithXMonsters_Text
        GuiControl, CavebotGUI:Disable, AmountMonstersToLoot

    }

    if (LootOnlyWithXMonsters = 1) && (lootingMode = "1") {
        NaoRealizarContagem = 0
        GuiControl, CavebotGUI:Disable, NaoRealizarContagem
        IniWrite, %NaoRealizarContagem%, %DefaultProfile%, cavebot_settings, NaoRealizarContagem
        GuiControl, CavebotGUI:, NaoRealizarContagem, %NaoRealizarContagem%
    } else {
        if (DisabledBK != "")
            GuiControl, CavebotGUI:Enable, NaoRealizarContagem
    }
return
submitLootingSettings:
    Gui, CavebotGUI:Submit, NoHide
    OldBotSettings.disableGuisLoading()
    _GuiHandler.submitSetting("looting", "settings/" . A_GuiControl, %A_GuiControl%)
    LootingGUI.checkLootingGuiSettingsControls()
    OldBotSettings.enableGuisLoading()
return



lootingEnabled:
    LootingHandler.setLootingEnabled()
return

lootingMode:
    LootingHandler.setLootingMode()
return

lootingPolicy:
    LootingHandler.setLootingPolicy()
return

lootAfterAllKill:
    LootingHandler.setlootAfterAllKill()
return

fastManualLooting:
    LootingHandler.setLootingSettingOption("fastManualLooting")
return

triesToUseItem:
    LootingHandler.setLootingSettingOption("triesToUseItem")
return

smartLootingSqms:
    GuiControlGet, smartLootingSqms
    string := StrSplit(smartLootingSqms, " ")
    smartLootingSqms := string.1
    LootingHandler.setLootingSettingOptionValue("smartLootingSqms", smartLootingSqms)
return

lootingMethod:
    GuiControlGet, lootingMethod
    try {
        switch lootingMethod {
            case "Click around", case "Click on the item":
                GuiControl, CavebotGUI:Hide, lootingHotkey
                GuiControl, CavebotGUI:Hide, lootingHotkeyText
                GuiControl, CavebotGUI:Show, quickLootingHotkey
                GuiControl, CavebotGUI:Show, quickLootingHotkeyText
                GuiControl, CavebotGUI:Show, quickLootingHotkeyImage
                if (LootingSystem.lootingJsonObj.options.openCorpsesAround = true)
                        && (jsonConfig("targeting", "options", "disableCreaturePositionCheck") != true) {

                        GuiControl, CavebotGUI:Enable, fastManualLooting
                    GuiControl, CavebotGUI:Enable, smartLootingSqms
                }
            case "Press hotkey":
                GuiControl, CavebotGUI:Show, lootingHotkey
                GuiControl, CavebotGUI:Show, lootingHotkeyText
                GuiControl, CavebotGUI:Hide, quickLootingHotkey
                GuiControl, CavebotGUI:Hide, quickLootingHotkeyText
                GuiControl, CavebotGUI:Hide, quickLootingHotkeyImage
                GuiControl, CavebotGUI:Disable, fastManualLooting
                GuiControl, CavebotGUI:Disable, smartLootingSqms
        }
    } catch {
    }
return

quickLootingHotkey:
    GuiControlGet, quickLootingHotkey
    lootingSettingsObj.quickLootingHotkey := quickLootingHotkey
    LootingHandler.saveLooting()
return

openNextBackpack:
    GuiControlGet, openNextBackpack
    if (openNextBackpack = 1) && (scriptImagesObj["nextBackpack"].image = "") {
        GuiControl, CavebotGUI:, openNextBackpack, 0
        gosub, ScriptImagesGUI
        msgbox_image("You must add a Script Image named ""nextBackpack"" that identifies the next backpack to be opened in the LAST slot of the backpack (with the Scroll Bar appearing), like in the image below.`nAdditionally, you can add up to 10 nextBackpackImages, like ""nextBackpack1"", ""nextBackpack2""...", "Data\Files\Images\GUI\Others\open_next_backpack_config.png", 3)
        return
    }
    LootingHandler.setOpenNextBackpack()
return


ItemSprite:
    Gui, CavebotGUI:Submit, NoHide
    StringTrimLeft, itemSpriteSelected, A_GuiControl, 10
return

stackableItem:
    Gui, CavebotGUI:Submit, NoHide
    if (stackableItem = 1) {
        GuiControl, CavebotGUI:Enable, differentSprites
        gosub, differentSprites
    } else{
        GuiControl, CavebotGUI:Disable, differentSprites
        Loop, 8
            GuiControl, CavebotGUI:Disable, ItemSprite%A_Index%
    }
return

differentSprites:
    Gui, CavebotGUI:Submit, NoHide
    if (differentSprites = 1) {
        Loop, 8
            GuiControl, CavebotGUI:Enable, ItemSprite%A_Index%
    } else{
        Loop, 8
            GuiControl, CavebotGUI:Disable, ItemSprite%A_Index%
    }
return

LV_ItemList:
    switch A_GuiEvent
    {
        Case "Normal":
            LootingGUI.LV_ItemList()
        Case "RightClick":
            Menu, ItemListMenu, Show

            action := GetKeyState("Alt") ? "Enable" : "Disable"

            Menu, ItemListMenu, % Action, switch Animated
            Menu, ItemListMenu, % Action, switch Stackable
            Menu, ItemListMenu, % Action, Change Sprites Count

    }
return

LV_DepositList:
    if (A_GuiEvent != "Normal")
        return
    LootingGUI.LV_DepositList()
return

LV_TrashList:
    if (A_GuiEvent != "Normal")
        return
    LootingGUI.LV_TrashList()
return

LV_LootList:
    if (A_GuiEvent != "Normal")
        return
    LootingGUI.LV_LootList()
return

LV_SellList:
    if (A_GuiEvent != "Normal")
        return
    LootingGUI.LV_SellList()
return

RefreshList_ItemList:
    GuiControl, CavebotGUI:Disable, RefreshList_ItemList
    LootingGUI.filterItemList()
    GuiControl, CavebotGUI:Enable, RefreshList_ItemList
return

ChooseBackpacksDepositer:
    try
        LootingHandler.setBackpacksDepositer()
    catch e
        Msgbox, 48,, % e.Message
return

RemoveItemDepositList:
    try
        LootingHandler.removeFromList("DepositList")
    catch e
        Msgbox, 48,, % e.Message
return

RemoveItemTrashList:
    try
        LootingHandler.removeFromList("TrashList")
    catch e
        Msgbox, 48,, % e.Message
return

EditUseAtributeTrashItem:
    try
        LootingHandler.editUseTrashItem()
    catch e
        Msgbox, 48,, % e.Message
return

RemoveItemLootList:
    try
        LootingHandler.removeFromList("LootList")
    catch e
        Msgbox, 48,, % e.Message
return

editLootListItemAtribute:
    GuiControlGet, %A_GuiControl%
    atribute := StrReplace(A_GuiControl, "ItemLootList", "")
    try
        LootingHandler.editItemAtributesList("LootList", atribute, %A_GuiControl%)
    catch e
        Msgbox, 48,, % e.Message, 2
return

RemoveItemSellList:
    try
        LootingHandler.removeFromList("SellList")
    catch e
        Msgbox, 48,, % e.Message
return

editSellListItemAtribute:
    GuiControlGet, %A_GuiControl%
    atribute := StrReplace(A_GuiControl, "ItemSellList", "")
    try
        LootingHandler.editItemAtributesList("SellList", atribute, %A_GuiControl%)
    catch e
        Msgbox, 48,, % e.Message, 2
return

EditDepositItemCategory:
    try
        LootingHandler.editItemCategory()
    catch e
        Msgbox, 48,, % e.Message
return

EditDepositLootDestination:
    try
        LootingHandler.editLootDestination()
    catch e
        Msgbox, 48,, % e.Message
return

DeleteItem_ItemList:
    try
        ItemsHandler.deleteItemList()
    catch e
        Msgbox, 48,, % e.Message
return

SearchItemList:
    Gui, CavebotGUI:Default
    Gui, CavebotGUI:Submit, NoHide
    ; GuiControlGet, searchFilter_Category
    if (searchFilter_Category = "") {
        searchFilter_Category := "Filter category..."
        GuiControl, CavebotGUI:ChooseString, searchFilter_Category, % searchFilter_Category
    }
    if (searchFilter_Rows < 1) {
        searchFilter_Rows := 200
        GuiControl, -g, searchFilter_Rows
        GuiControl,,  searchFilter_Rows, % searchFilter_Rows
        GuiControl, +gSearchItemList, searchFilter_Rows
    }
    if (searchFilter_ShowAllRows = 1) {
        GuiControl, CavebotGUI:Disable, searchFilter_Rows
        GuiControl, CavebotGUI:Disable, searchFilter_RowsText
        timerDelay := 600
    } else {
        GuiControl, CavebotGUI:Enable, searchFilter_Rows
        GuiControl, CavebotGUI:Enable, searchFilter_RowsText
        timerDelay := 300
    }
    SetTimer, CheckLoadReleased, Delete
    SetTimer, CheckLoadReleased, 50
return

CheckLoadReleased:
    ; Tooltip, loading_LV_ItemList = %loading_LV_ItemList%
    if (loading_LV_ItemList = false) {
        SetTimer, SearchItemListTimer, Delete
        SetTimer, SearchItemListTimer, -%timerDelay%
        SetTimer, CheckLoadReleased, Delete
    }
return

SearchItemListTimer:
    LootingGUI.filterItemList()
return


moveItemToList:
    Gui, CavebotGUI:Submit, NoHide
    listFrom := StrReplace(A_GuiControl, "moveItemFromList", "")
    LootingHandler.moveItemToList(listFrom, moveItemToList%listFrom% )
return
MoveDepositItemTrashList:
    try
        LootingHandler.moveFromDepositToTrashList()
    catch e
        Msgbox, 48,, % e.Message, 2
return

MoveDepositItemLootList:
    try
        LootingHandler.moveFromDepositToLootList()
    catch e
        Msgbox, 48,, % e.Message, 2
return

MoveDepositItemSellList:
    try
        LootingHandler.moveFromDepositToSellList()
    catch e
        Msgbox, 48,, % e.Message, 2
return


AddItemDepositList:
    try
        LootingHandler.addToListName("DepositList")
    catch e
        Msgbox, 48,, % e.Message
return


AddItemTrashList:
    try
        LootingHandler.addToListName("TrashList")
    catch e
        Msgbox, 48,, % e.Message
return

AddItemLootList:
    try
        LootingHandler.addToListName("LootList")
    catch e
        Msgbox, 48,, % e.Message
return

AddItemSellList:
    try
        LootingHandler.addToListName("SellList")
    catch e
        Msgbox, 48,, % e.Message
return



tutorialButtonLooting:
    openURL(LinksHandler.Looting.tutorial)
return
