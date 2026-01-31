global lootListObj
global sellListObj
global trashListObj
global lootingSettingsObj

global saveLootingTimerTrigger

Class _LootingHandler
{
    __New()
    {
        global


        this.loadLootingSettings()
    }

    loadLootingSettings() {
        global
        if (!IsObject(lootingObj["depositSettings"]))
            lootingObj["depositSettings"] := {}

        if (!IsObject(lootingObj["trashSettings"]))
            lootingObj["trashSettings"] := {}

        if (!IsObject(lootingObj["lootSettings"]))
            lootingObj["lootSettings"] := {}

        if (!IsObject(lootingObj["settings"]))
            lootingObj["settings"] := {}

        lootingSettingsObj := lootingObj.settings
        if (!IsObject(lootingSettingsObj))
            lootingSettingsObj := {}

        trashListObj := lootingObj.trashList
        if (!IsObject(trashListObj))
            trashListObj := {}

        lootListObj := lootingObj.lootList
        if (!IsObject(lootListObj))
            lootListObj := {}

        sellListObj := lootingObj.sellList
        if (!IsObject(sellListObj))
            sellListObj := {}

        if (!IsObject(lootingObj.depositList))
            lootingObj.depositList := {}

        this.checkDefaultLootingSettings()
        this.checkDefaultLootListSettings()
        this.checkDefaultSellListSettings()
        this.checkDefaultDepositCategories()
        this.checkBackpackSettings()

        lootingEnabled := (lootingObj.settings.lootingEnabled = "" && lootingObj.settings.lootingEnabled != false) ? false : lootingObj.settings.lootingEnabled
        lootingMode := lootingObj.settings.lootingMode
        lootingPolicy := lootingObj.settings.lootingPolicy
        lootAfterAllKill := lootingObj.settings.lootAfterAllKill
        openNextBackpack := lootingObj.settings.openNextBackpack
        fastManualLooting := lootingObj.settings.fastManualLooting
        smartLootingSqms := lootingObj.settings.smartLootingSqms
        lootCreaturesPosition := lootingObj.settings.lootCreaturesPosition
        searchCorpseImages := lootingObj.settings.searchCorpseImages
        showCreaturePosition := lootingObj.settings.showCreaturePosition
    }

    checkDefaultLootingSettings() {
        lootingObj.settings.lootingEnabled := (lootingObj.settings.lootingEnabled = "" && lootingObj.settings.lootingEnabled != false) ? true : lootingObj.settings.lootingEnabled += 0
        lootingObj.settings.lootingMode := (lootingObj.settings.lootingMode = "") ? "Loot around char position" : lootingObj.settings.lootingMode
        lootingObj.settings.lootingPolicy := (lootingObj.settings.lootingPolicy = "") ? "Loot after kill" : lootingObj.settings.lootingPolicy

        lootingObj.settings.lootCreaturesPosition := (lootingObj.settings.lootCreaturesPosition = "" && lootingObj.settings.lootCreaturesPosition != false) ? false : lootingObj.settings.lootCreaturesPosition += 0
        lootingObj.settings.searchCorpseImages := (lootingObj.settings.searchCorpseImages = "" && lootingObj.settings.searchCorpseImages != false) ? false : lootingObj.settings.searchCorpseImages += 0
        lootingObj.settings.showCreaturePosition := (lootingObj.settings.showCreaturePosition = "" && lootingObj.settings.showCreaturePosition != false) ? false : lootingObj.settings.showCreaturePosition += 0
        lootingObj.settings.lootAfterAllKill := (lootingObj.settings.lootAfterAllKill = "" && lootingObj.settings.lootAfterAllKill != false) ? false : lootingObj.settings.lootAfterAllKill += 0
        if (lootingObj.settings.lootCreaturesPosition = true)
            lootingObj.settings.lootAfterAllKill := true

        lootingObj.settings.openNextBackpack := (lootingObj.settings.openNextBackpack = "" && lootingObj.settings.openNextBackpack != false) ? false : lootingObj.settings.openNextBackpack += 0

        lootingObj.settings.fastManualLooting := (lootingObj.settings.fastManualLooting = "" && lootingObj.settings.fastManualLooting != false) ? OldbotSettings.settingsJsonObj.settings.looting.fastManualLootingByDefault : lootingObj.settings.fastManualLooting += 0

        lootingObj.settings.fastManualLooting := (lootingObj.settings.fastManualLooting = "" && lootingObj.settings.fastManualLooting != false) ? OldbotSettings.settingsJsonObj.settings.looting.fastManualLootingByDefault : lootingObj.settings.fastManualLooting += 0

        lootingObj.settings.triesToUseItem := lootingObj.settings.triesToUseItem = "" ? 1 : lootingObj.settings.triesToUseItem
        lootingObj.settings.triesToUseItem := lootingObj.settings.triesToUseItem < 1 ? 1 : lootingObj.settings.triesToUseItem
        lootingObj.settings.triesToUseItem := lootingObj.settings.triesToUseItem > 10 ? 10 : lootingObj.settings.triesToUseItem

        lootingObj.settings.smartLootingSqms := lootingObj.settings.smartLootingSqms = "" ? 3 : lootingObj.settings.smartLootingSqms
        lootingObj.settings.smartLootingSqms := lootingObj.settings.smartLootingSqms < 1 ? 1 : lootingObj.settings.smartLootingSqms
        lootingObj.settings.smartLootingSqms := lootingObj.settings.smartLootingSqms > 3 ? 3 : lootingObj.settings.smartLootingSqms

        /**
        force Shift+Right click
        */
        ; lootingObj.settings.quickLootingHotkey := "Shift & Right Click"
        if (lootingObj.settings.quickLootingHotkey = "") {
            if (OldbotSettings.settingsJsonObj.settings.looting.defaultQuickLootingHotkey != "") {
                lootingObj.settings.quickLootingHotkey := OldbotSettings.settingsJsonObj.settings.looting.defaultQuickLootingHotkey
            } else {
                if (LootingSystem.lootingJsonObj.options.openCorpsesAround = true)
                    lootingObj.settings.quickLootingHotkey := "Shift & Right Click"
                else
                    lootingObj.settings.quickLootingHotkey := "Ctrl & Right Click"
            }
        }
        switch LootingSystem.lootingJsonObj.options.openCorpsesAround {
            case true:
                if (lootingObj.settings.quickLootingHotkey = "Shift & Right Click")
                    lootingObj.settings.quickLootingHotkey := "Ctrl & Right Click"
            default:
                if (lootingObj.settings.quickLootingHotkey = "Ctrl & Right Click")
                    lootingObj.settings.quickLootingHotkey := "Shift & Right Click"
        }

        lootingObj.settings.quickLootingHotkey := lootingObj.settings.quickLootingHotkey = "" ? "Shift & Right Click" : lootingObj.settings.quickLootingHotkey

    }

    checkDefaultLootListSettings() {
        for itemName, atributes in lootListObj
        {
            /**
            boolean
            */
            lootListObj[itemName].drop := (lootListObj[itemName].drop = "" && lootListObj[itemName].drop != false) ? false : lootListObj[itemName].drop += 0
            lootListObj[itemName].use := (lootListObj[itemName].use = "" && lootListObj[itemName].use != false) ? false : lootListObj[itemName].use += 0

            /**
            number
            */
            lootListObj[itemName].tries := (lootListObj[itemName].tries = "") ? 10 : lootListObj[itemName].tries += 0
            lootListObj[itemName].tries := (lootListObj[itemName].tries > 10) ? 10 : lootListObj[itemName].tries += 0
            lootListObj[itemName].tries := (lootListObj[itemName].tries < 1) ? 1 : lootListObj[itemName].tries
            ; m(itemName "`n" serialize(atributes))

        }
    }

    checkDefaultSellListSettings() {
        for itemName, atributes in sellListObj
        {
            /**
            boolean
            */
            sellListObj[itemName].ignore := (sellListObj[itemName].ignore = "" && sellListObj[itemName].ignore != false) ? false : sellListObj[itemName].ignore += 0
            ; sellListObj[itemName].mustBeVisible := (sellListObj[itemName].mustBeVisible = "" && sellListObj[itemName].mustBeVisible != false) ? false : sellListObj[itemName].mustBeVisible += 0
            ; m(itemName "`n" serialize(atributes))

        }
    }

    setLootingSettingOption(optionName, number := true) {
        GuiControlGet, %optionName%
        if (number = true)
            lootingObj.settings[optionName] := %optionName% += 0
        else
            lootingObj.settings[optionName] := %optionName%
        ; msgbox, % optionName " = " lootingObj.settings[optionName]
        this.saveLootingSettings()
    }

    setLootingSettingOptionValue(optionName, value) {
        lootingObj.settings[optionName] := value
        ; msgbox, % optionName " = " lootingObj.settings[optionName]
        this.saveLootingSettings()
    }

    setLootingEnabled() {
        global
        GuiControlGet, lootingEnabled
        lootingObj.settings.lootingEnabled := lootingEnabled += 0
        this.saveLootingSettings()
    }

    setLootingMode() {
        global
        GuiControlGet, lootingMode
        lootingObj.settings.lootingMode := lootingMode
        this.saveLootingSettings()
    }

    setLootingPolicy() {
        global
        GuiControlGet, lootingPolicy
        lootingObj.settings.lootingPolicy := lootingPolicy
        this.saveLootingSettings()
    }

    setlootAfterAllKill() {
        global
        GuiControlGet, lootAfterAllKill
        lootingObj.settings.lootAfterAllKill := lootAfterAllKill
        this.saveLootingSettings()
    }

    setOpenNextBackpack() {
        global
        GuiControlGet, openNextBackpack
        lootingObj.settings.openNextBackpack := openNextBackpack += 0
        this.saveLootingSettings()
    }


    checkBackpackSettings() {
        if (!IsObject(lootingObj["depositSettings"]["backpackSettings"]))
            lootingObj["depositSettings"]["backpackSettings"] := {}

        if (!lootingObj["depositSettings"]["backpackSettings"]["mainBackpack"])
            lootingObj["depositSettings"]["backpackSettings"]["mainBackpack"] := ""

        Loop, 4 {
            if (!lootingObj["depositSettings"]["backpackSettings"]["backpack" A_Index])
                lootingObj["depositSettings"]["backpackSettings"]["backpack" A_Index] := ""
        }

        if (backpackList.Count() < 1) ; in case the backpacklist has not been created yet
            return
        mainBp := lootingObj.depositSettings.backpackSettings.mainBackpack
        if (mainBp != "") && (!InArray(backpackList, mainBp)) {
            ; msgbox, % serialize(backpackList)
            ; msgbox, % A_ThisFunc " / " mainBp
            lootingObj.depositSettings.backpackSettings.mainBackpack := ""
            this.saveLooting(true, A_ThisFunc)
        }
        Loop, 4 {
            bp := lootingObj["depositSettings"]["backpackSettings"]["backpack" A_Index]
            if (bp != "") && (!InArray(backpackList, bp)) {
                ; msgbox, % A_ThisFunc " / " bp
                lootingObj["depositSettings"]["backpackSettings"]["backpack" A_Index] := ""
                this.saveLooting(true, A_ThisFunc)
            }

        }
    }

    moveFromDepositToTrashList() {
        try selectedItem :=  _ListviewHandler.checkSelectedItem("LV_DepositList")
        catch e
            throw e

        GuiControlGet, buttonText,, %A_GuiControl%
        GuiControl, CavebotGUI:Disable, MoveDepositItemTrashList
        GuiControl, CavebotGUI:, MoveDepositItemTrashList, Moving...

        selectedItems := _ListviewHandler.getSelectedRowsLV("LV_DepositList")

        for row, itemName in selectedItems
        {
            this.addTrashListItem(itemName)
            lootingObj.depositList.Delete(itemName)
        }

        LootingGUI.LoadDepositListLV()
        LootingGUI.LoadTrashListLV()
        this.saveTrashList()
        GuiControl, CavebotGUI:Enable, MoveDepositItemTrashList
        GuiControl, CavebotGUI:, MoveDepositItemTrashList, % buttonText
    }

    moveFromDepositToLootList() {
        try selectedItem :=  _ListviewHandler.checkSelectedItem("LV_DepositList")
        catch e
            throw e

        GuiControlGet, buttonText,, %A_GuiControl%
        GuiControl, CavebotGUI:Disable, MoveDepositItemLootList
        GuiControl, CavebotGUI:, MoveDepositItemLootList, Moving...

        selectedItems := _ListviewHandler.getSelectedRowsLV("LV_DepositList")

        for row, itemName in selectedItems
        {
            this.addLootListItem(itemName)
            lootingObj.depositList.Delete(itemName)
        }

        LootingGUI.LoadDepositListLV()
        LootingGUI.LoadLootListLV()
        this.saveLootList()
        GuiControl, CavebotGUI:Enable, MoveDepositItemLootList
        GuiControl, CavebotGUI:, MoveDepositItemLootList, % buttonText
    }

    moveFromDepositToSellList() {
        try selectedItem :=  ListviewHandler.checkSelectedItem("LV_DepositList")
        catch e
            throw e

        GuiControlGet, buttonText,, %A_GuiControl%
        GuiControl, CavebotGUI:Disable, MoveDepositItemSellList
        GuiControl, CavebotGUI:, MoveDepositItemSellList, Moving...

        selectedItems := _ListviewHandler.getSelectedRowsLV("LV_DepositList")

        for row, itemName in selectedItems
        {
            this.addSellListItem(itemName)
            lootingObj.depositList.Delete(itemName)
        }

        LootingGUI.LoadDepositListLV()
        LootingGUI.LoadSellListLV()
        this.saveSellList()
        GuiControl, CavebotGUI:Enable, MoveDepositItemSellList
        GuiControl, CavebotGUI:, MoveDepositItemSellList, % buttonText
    }

    setMainBackpack() {
        Gui, CavebotGUI:Default
        GuiControlGet, depositerMainBackpack
        if (depositerMainBackpack = "Optional...")
            depositerMainBackpack := ""

        if (depositerMainBackpack != "") {
            GuiControl, CavebotGUI:Enable, depositerBackpack1
            GuiControl, CavebotGUI:Enable, depositerBackpack2
            GuiControl, CavebotGUI:Enable, depositerBackpack3
            GuiControl, CavebotGUI:Enable, depositerBackpack4

        } else {
            GuiControl, CavebotGUI:Disable, depositerBackpack1
            GuiControl, CavebotGUI:Disable, depositerBackpack2
            GuiControl, CavebotGUI:Disable, depositerBackpack3
            GuiControl, CavebotGUI:Disable, depositerBackpack4
        }
        lootingObj.depositSettings.backpackSettings.mainBackpack := depositerMainBackpack
        this.saveLooting(true, A_ThisFunc)

    }

    setBackpacksDepositer() {
        Gui, CavebotGUI:Default
        Gui, CavebotGUI:Submit, NoHide

        backpack := %A_GuiControl%
        if (backpack = "Optional...")
            backpack := ""

        StringTrimLeft, backpackNumber, A_GuiControl, StrLen("depositerBackpack")

        if (backpack != "") {
            Loop, 4 {
                if (A_Index = backpack)
                    continue
                if (lootingObj["depositSettings"]["backpackSettings"]["backpack" A_Index] = backpack) {
                    bp := lootingObj["depositSettings"]["backpackSettings"]["backpack" backpackNumber]
                    try GuiControl, CavebotGUI:ChooseString, depositerBackpack%backpackNumber%, % bp = "" ? "Optional..." : bp
                    catch {
                    }
                    throw Exception(backpack " already in use on Backpack " A_Index ".")
                }
            }
        }

        lootingObj["depositSettings"]["backpackSettings"]["backpack" backpackNumber] := backpack
        this.saveLooting(true, A_ThisFunc)
    }

    addToListName(listName) {
        try selectedItem := _ListviewHandler.checkSelectedItem("LV_" listName)
        catch e
            throw e
        /**
        - atributes
        name
        category: gold | stackable | nonstackable
        */
        selectedItems := _ListviewHandler.getSelectedRowsLV("LV_ItemList")
        for row, itemName in selectedItems
        {
            this.addItemToList(listName, itemName)
        }

        this.updateListLvAndSave(listName)
    }

    addItemToList(listName, itemName) {
        switch listName {
            case "LootList":
                this.addLootListItem(itemName)
            case "SellList":
                this.addSellListItem(itemName)
            case "TrashList":
                this.addTrashListItem(itemName)
            case "DepositList":
                this.addDepositListItem(itemName)
            default:
                if (!A_IsCompiled)
                    msgbox, 48, % A_ThisFunc, % "List not implemented: " listName
        }
    }

    updateListLvAndSave(listName) {
        switch listName {
            case "LootList":
                LootingGUI.LoadLootListLV()
                this.saveLootList()
            case "SellList":
                LootingGUI.LoadSellListLV()
                this.saveSellList()
            case "TrashList":
                LootingGUI.LoadTrashListLV()
                this.saveTrashList()
            case "DepositList":
                LootingGUI.LoadDepositListLV()
                this.saveDepositList()
            default:
                if (!A_IsCompiled)
                    msgbox, 48, % A_ThisFunc, % "List not implemented: " listName
        }
    }

    addLootListItem(itemName) {
        if (lootListObj[itemName])
            return
        itemObj := {}
        itemObj.use := false
        itemObj.drop := false
        itemObj.tries := 10
        if (itemsObj[itemName].primarytype = "Food") {
            itemObj.use := true
            itemObj.tries := 3
        }
        lootListObj[itemName] := itemObj
    }

    addSellListItem(itemName) {
        if (sellListObj[itemName])
            return
        itemObj := {}
        itemObj.ignore := false

        sellListObj[itemName] := itemObj
    }

    addTrashListItem(itemName) {
        if (trashListObj[itemName])
            return
        itemObj := {}
        itemObj.use := false
        if (itemsObj[itemName].primarytype = "Food")
            itemObj.use := true
        trashListObj[itemName] := itemObj
    }

    addDepositListItem(itemName) {
        if (lootingObj.depositList[itemName])
            return
        itemObj := {}
        switch itemName {
            case "gold coin", case "platinum coin", case "crystal coin":
                itemObj.category := "gold"
            default:
                itemObj.category := itemsImageObj[itemName].stackable
        }
        lootingObj.depositList[itemName] := itemObj
    }

    moveItemToList(listFrom, listTo) {
        selectedItems := _ListviewHandler.getSelectedRowsLV("LV_" listFrom)

        for row, itemName in selectedItems
            %listFrom%Obj.Delete(itemName)
        switch listTo {
            case "DepositList":
                for row, itemName in selectedItems
                    this.addDepositListItem(itemName)
            case "LootList":
                for row, itemName in selectedItems
                    this.addLootListItem(itemName)
            case "SellList":
                for row, itemName in selectedItems
                    this.addSellListItem(itemName)
            case "TrashList":
                for row, itemName in selectedItems
                    this.addTrashListItem(itemName)
        }

        this.updateListLvAndSave(listFrom)
        this.updateListLvAndSave(listTo)
    }

    removeFromList(listName)
    {
        selectedItems := _ListviewHandler.getSelectedRowsLV("LV_" listName)

        for row, itemName in selectedItems
            lootingObj[listName].Delete(itemName)

        this.updateListLvAndSave(listName)
    }

    editLootDestination()
    {
        Gui, CavebotGUI:Submit, NoHide
        Gui, CavebotGUI:Default
        try
            newValue := %A_GuiControl%
        catch
            throw Exception("No value for option: " A_GuiControl)

        lootingObj["depositSettings"]["depositLootDestination"][A_GuiControl] := newValue

        this.saveLooting(true, A_ThisFunc)
    }

    editItemCategory() {
        GuiControlGet, depositerItemNameEdit
        if (depositerItemNameEdit = "") {

            try selectedItem :=  _ListviewHandler.checkSelectedItem("LV_DepositList")
            catch e
                throw e
        } else {
            selectedItem := depositerItemNameEdit
        }

        GuiControlGet, depositerItemCategoryEdit
        lootingObj.depositList[selectedItem].category := depositerItemCategoryEdit
        this.updateListLvAndSave("DepositList")
    }

    editUseTrashItem() {
        GuiControlGet, TrashItemNameEdit
        if (TrashItemNameEdit = "") {
            try selectedItem :=  _ListviewHandler.checkSelectedItem("LV_TrashList")
            catch e
                throw e
        } else {
            selectedItem := TrashItemNameEdit
        }

        GuiControlGet, UseTrashItemEdit
        trashListObj[selectedItem].use := UseTrashItemEdit
        this.updateListLvAndSave("TrashList")
    }

    editItemAtributeListName(listName, selectedItem, atribute, value) {
        %listName%Obj[selectedItem][atribute] := value
        this.updateListLvAndSave(listName)
    }

    editUseLootItem() {
        GuiControlGet, LootListItemNameEdit
        if (LootListItemNameEdit = "") {
            try selectedItem :=  _ListviewHandler.checkSelectedItem("LV_LootList")
            catch e
                throw e
        } else {
            selectedItem := LootListItemNameEdit
        }

        GuiControlGet, useItemLootList
        this.editItemAtributeListName(listName, selectedItem, "use", useItemLootList)
    }

    editignoreItemLootList() {
        GuiControlGet, LootListItemNameEdit
        if (LootListItemNameEdit = "") {
            try selectedItem :=  _ListviewHandler.checkSelectedItem("LV_LootList")
            catch e
                throw e
        } else {
            selectedItem := LootListItemNameEdit
        }

        GuiControlGet, ignoreItemLootList
        this.editItemAtributeListName(listName, selectedItem, "ignore", ignoreItemLootList)
    }

    editDropLootItem() {
        GuiControlGet, LootListItemNameEdit
        if (LootListItemNameEdit = "") {
            try selectedItem :=  _ListviewHandler.checkSelectedItem("LV_LootList")
            catch e
                throw e
        } else {
            selectedItem := LootListItemNameEdit
        }

        GuiControlGet, dropItemLootList
        this.editItemAtributeListName(listName, selectedItem, "drop", dropItemLootList)
    }

    listScriptCategories(excludeGold := false) {
        categories := ""
        for key, value in lootingObj.depositSettings.depositCategories
        {
            if (excludeGold = true) && (value = "gold")
                continue
            categories .= value "|"
        }
        return categories
    }

    checkDefaultDepositCategories() {
        if (!lootingObj["depositSettings"]["depositLootDestination"])
            lootingObj["depositSettings"]["depositLootDestination"] := {}

        if (!lootingObj["depositSettings"]["depositLootDestination"]["depositerLocker2Category"])
            lootingObj["depositSettings"]["depositLootDestination"]["depositerLocker2Category"] := "stackable"
        if (!lootingObj["depositSettings"]["depositLootDestination"]["depositerLocker3Category"])
            lootingObj["depositSettings"]["depositLootDestination"]["depositerLocker3Category"] := "nonstackable"
        if (!lootingObj["depositSettings"]["depositLootDestination"]["depositerLocker4Category"])
            lootingObj["depositSettings"]["depositLootDestination"]["depositerLocker4Category"] := "other"


        if (!lootingObj["depositSettings"]["depositCategories"]) {
            lootingObj["depositSettings"]["depositCategories"] := {}
            lootingObj["depositSettings"]["depositCategories"].Push("gold")
            lootingObj["depositSettings"]["depositCategories"].Push("stackable")
            lootingObj["depositSettings"]["depositCategories"].Push("nonstackable")
            lootingObj["depositSettings"]["depositCategories"].Push("other")
            ; this.saveLooting(true, A_ThisFunc)
        }
    }

    saveLootingSettings(origin := "") {
        global
        lootingObj.settings := lootingObj.settings
        this.saveLooting(true, A_ThisFunc)
    }

    saveLootList(funcOrigin := "") {
        global
        lootingObj.lootList := lootListObj
        this.saveLooting(true, A_ThisFunc)
    }

    saveSellList(funcOrigin := "") {
        global
        lootingObj.sellList := sellListObj
        this.saveLooting(true, A_ThisFunc)
    }

    saveTrashList() {
        global
        lootingObj.trashList := trashListObj
        this.saveLooting(true, A_ThisFunc)
    }

    saveDepositList() {
        global
        lootingObj.depositList := lootingObj.depositList
        this.saveLooting(true, A_ThisFunc)
    }

    /**
    save "lootingObj" looting.waypoints section
    */
    saveLooting(saveCavebotScript := true, origin := "", loadingGuis := true) {
        global
        if (lootingObj = "") {
            Msgbox, 16, % A_ThisFunc ", origin: " origin, % "Empty looting settings to save, origin: " origin
            return
        }
        if (!IsObject(OldBotSettings)) {
            Msgbox, 16, % A_ThisFunc ", origin: " origin, % "OldBotSettings not initialized."
        }
        if (loadingGuis = true) {
            ; msgbox,, % A_ThisFunc, % loadingGuis
            OldBotSettings.disableGuisLoading()
        }
        scriptFile.looting := lootingObj
        if (saveCavebotScript = true) {
            try CavebotScript.saveSettings(A_ThisFunc)
            catch e {
                msgbox, 16, % A_ThisFunc, % e.Message "`n" e.what
            }
        }
        if (loadingGuis = true)
            OldBotSettings.enableGuisLoading()
    }

    editItemAtributesList(listName, atribute, value := "") {
        if (value = A_Space)
            value := ""

        try GuiControlGet, %listName%ItemNameEdit
        catch {
        }
        selectedItem := %listName%ItemNameEdit
        if (selectedItem = "")
            throw Exception("No item selected.")

        %listName%Obj[selectedItem][atribute] := value

        this.updateListLvAndSave(listName)
    }

}
