#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_LootingJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ContainersJson.ahk

global itemsFile
global itemsObj

global itemsImageFile
global itemsImageObj
global customItemsImageFile
global customItemsImageObj

/*
variables userd on GetItemPictureCyclopedia()
*/
global backpackList := {}
global backpackListDropdown
global itemCategoriesList := {}
global itemCategoriesListDropdown
global dontSaveItemimages
/*
Class that handles items.json(itemObj) and items_image.json (itemsImageObk)
*/

Class _ItemsHandler
{
    static WORD_BACKPACK_VARIATION := 50

    __New(itemsJson := false, itemsImageJson := false, loadAdditionalStuff := false){

        this.itemsJsonFolder := OldbotSettings.JsonFolder "\Items"

        this.loadItemsJsonStart(itemsJson, itemsImageJson)

        this.openPaint := false


        this.mainBackpacks := {}
        this.mainBackpacksList := ""

        if (loadAdditionalStuff) {
            this.createBackpackList()
            this.createBackpacksAndBagsList()
            this.createItemCategoriesList()
        }

        this.itemImageWidth := 32
        this.itemImageHeight := 32

        /**
        positions paint the item sprite corner
        */
        this.itemCornerPos := {}
        Loop, 6
            this.itemCornerPos.Push({x: A_Index - 1, y: 0})
        Loop, 5
            this.itemCornerPos.Push({x: A_Index - 1, y: 1})
        Loop, 4
            this.itemCornerPos.Push({x: A_Index - 1, y: 2})
        Loop, 3
            this.itemCornerPos.Push({x: A_Index - 1, y: 3})
        Loop, 2
            this.itemCornerPos.Push({x: A_Index - 1, y: 4})
        Loop, 1
            this.itemCornerPos.Push({x: A_Index - 1, y: 5})

        this.createGrayBackgroundPixels()
    }

    loadItemsJsonStart(itemsJson := false, itemsImageJson := false)
    {
        if (itemsJson = true) {
            itemsFile := new JSONFile(this.itemsJsonFolder  "\items.json")
            itemsObj := itemsFile.Object()
        }

        if (itemsImageJson = true) {
            itemsImageFile := "", itemsImageObj := ""

            itemsImageFile := new JSONFile(this.itemsJsonFolder "\items_image.json")
            itemsImageObj := itemsImageFile.Object()

            this.loadOtherItemJsons()
        }
    }

    loadOtherItemJsons() {

        if (isTibia13() && OldbotSettings.settingsJsonObj.tibiaClient.clientImagesCategoryIdentifier = "rltibia")
            return

        fileLoad := this.itemsJsonFolder "\items_image_" TibiaClient.getClientIdentifier(false) ".json"

        saveFileNotExist := !FileExist(fileLoad)

        /**
        clean the objects in case this is a reload
        */
        customItemsImageFile := ""
        customItemsImageObj := ""

        customItemsImageFile := new JSONFile(fileLoad)
        customItemsImageObj := customItemsImageFile.Object()

        if (file := customItemsImageObj.__extends) {
            extendedData := _Json.load(this.itemsJsonFolder "\" file)
            for itemName, atributes in extendedData {
                this.addToItemsImageObj(itemName, atributes)
            }
        }

        for itemName, atributes in customItemsImageObj {
            this.addToItemsImageObj(itemName, atributes)
        }

        if (saveFileNotExist = true)
            customItemsImageFile.save(true)
    }

    addToItemsImageObj(itemName, atributes)
    {
        if (itemName = "__extends") {
            return
        }

        if (itemsImageObj.hasKey(itemName)) {
            itemsImageObj[itemName] := {}
        }

        itemsImageObj[itemName] := atributes
    }

    switchAtribute(atributeName := "", value := "") {
        Gui, CavebotGUI:Default

        selectedItems := _ListviewHandler.getSelectedRowsLV("LV_ItemList")

        for row, itemName in selectedItems
        {
            switch atributeName {
                case "switch Animated":
                    this.switchAnimated(itemName, row)
                case "switch Stackable":
                    this.switchStackable(itemName, row)
                case "Change Sprites Count":
                    this.changeSprites(itemName, row, value)
            }
        }
        this.saveItemsImage()
    }

    changeSprites(itemName, selectedRow, sprites := 1) {
        if (sprites = "")
            throw Exception("Amount of sprites not set.")
        if (sprites < 1)
            throw Exception("Amount of sprites can't be lower than 1.")

        this.setItemAtribute(itemName, "sprites", "" sprites "")

        LV_Modify(selectedRow,"", "", itemName, this.rowCategory(itemName), this.rowStackable(itemName), this.rowAnimation(itemName), this.rowSprites(itemName))
    }

    switchAnimated(itemName, selectedRow) {
        value := !this.getItemAtribute(itemName, "animated_sprite") ; don't put the "!func() += 0" below, it will make the next lines bug
        this.setItemAtribute(itemName, "animated_sprite", value += 0)

        Gui, ListView, LV_ItemList
        teste3 := this.getItemAtribute(itemName, "primarytype")
        LV_Modify(selectedRow,"", "", itemName, this.rowCategory(itemName), this.rowStackable(itemName), this.rowAnimation(itemName))
    }

    switchStackable(itemName, selectedRow) {
        if (this.getItemAtribute(itemName, "stackable") = "stackable")
            this.setItemAtribute(itemName, "stackable", "nonstackable")
        else
            this.setItemAtribute(itemName, "stackable", "stackable")

        Gui, ListView, LV_ItemList
        LV_Modify(selectedRow,"", "", itemName, this.rowCategory(itemName), this.rowStackable(itemName) )
    }

    setItemAtribute(itemName, atribute, value := "") {
        if (customItemsImageFile) {
            /**
            create item with atributes from itemsImageObj if doesn't exist on customItemsImageObj
            */
            if (!customItemsImageObj[itemName]) {
                customItemsImageObj[itemName] := {}
                for itemAtribute, itemAtributeValue in itemsImageObj[itemName]
                    customItemsImageObj[itemName][itemAtribute] := itemAtributeValue
            }
            customItemsImageObj[itemName][atribute] := value
            return
        }

        itemsImageObj[itemName][atribute] := value
    }

    createBackpackList() {
        backpackListDropdown := ""
        this.backpackList := {}
        for itemName, itemAtributes in itemsImageObj
        {
            if (RegExMatch(itemName,"(chest|old and used backpack|silver key|parcel|bag|ring)") OR itemName = "box")
                continue
            if (!itemsObj[itemName]["volume"])
                continue
            if (itemsObj[itemName].primarytype != "Containers") && (itemsObj[itemName].secondarytype != "Containers")
                continue
            if (!itemsImageObj[itemName]) ; if it is not on the items_image.json file
                continue
            if (itemsObj[itemName]["volume"] < 8)
                continue

            this.backpackList.Push(itemName)
        }
        for key, value in this.backpackList
            backpackListDropdown .= value "|"
    }

    createBackpacksAndBagsList() {
        this.backpacksAndBagsList := ""
        this.backpacksAndBags := {}

        this.backpacksAndBags.Push("bag")

        for itemName, itemAtributes in itemsImageObj
        {
            if (!RegExMatch(itemName,"(backpack|bag)"))
                continue
            ; if (RegExMatch(itemName,"(chest|old and used backpack|silver key|parcel|bag|ring)") OR itemName = "box")
            if (!itemsObj[itemName]["volume"])
                continue
            if (itemsObj[itemName].primarytype != "Containers") && (itemsObj[itemName].secondarytype != "Containers")
                continue
            if (!itemsImageObj[itemName]) ; if it is not on the items_image.json file
                continue
            if (itemsObj[itemName]["volume"] < 8)
                continue

            this.backpacksAndBags.Push(itemName)
        }


        for key, value in this.backpacksAndBags
            this.backpacksAndBagsList .= value "|"
    }

    createItemCategoriesList() {
        itemCategoriesListDropdown := ""
        for itemName, itemAtributes in itemsObj
        {
            if (itemAtributes.primarytype = "")
                continue
            if (InArray(itemCategoriesList, itemAtributes.primarytype) = 0) {
                itemCategoriesList.Push(itemAtributes.primarytype)
                itemCategoriesListDropdown .= itemAtributes.primarytype "|"
            }
        }
        itemCategoriesList := {} ; cleaning the array again to create it on alphabetic order

        Sort, itemCategoriesListDropdown, CL D|
        Loop, Parse, itemCategoriesListDropdown, |
            itemCategoriesList.Push(A_LoopField)
    }

    listCategories() {
        return itemCategoriesListDropdown
    }

    listBackpacksAndBags() {
        return this.backpacksAndBagsList
    }

    deleteItemList()
    {
        Gui, CavebotGUI:Submit, NoHide

        selectedItems := _ListviewHandler.getSelectedRowsLV("LV_ItemList")

        items := ""
        for _, itemName in selectedItems
        {
            if (A_Index > 10) {
                items .= "... " selectedItems.Count() " more items ..."
                break
            }

            items .= "- " itemName "`n"
        }

        Msgbox, 68,, Delete item(s)?`n%items%
        IfMsgBox, No
            return

        for _, itemName in selectedItems
        {
            if (customItemsImageObj[itemName] != "")
                customItemsImageObj.Delete(itemName)
            else
                itemsImageObj.Delete(itemName)
        }

        LootingGUI.filterItemList()
        this.saveItemsImage()
    }

    searchValidation(itemName, stackableItem := false, animatedSprite := false, differentSprites := false, spriteSelected := "") {
        if (differentSprites = 1 && spriteSelected = "")
            throw Exception("Select the sprite number of the ""Different sprite"".")

        if (itemName != "" && StrLen(itemName) < 3)
            throw Exception("Item name must have at least 3 characters.")
    }

    searchItemOnScreen(itemName := "") {
        this.checkItemName(itemName, txt("Selecione um item na lista para testar.", "Select an item on the list to test."))

        if (!itemsImageObj.hasKey(itemName))
            throw Exception(txt("O item """ itemName """ não existe na lista.", "The item """ itemName """ does not exist in the list."))
        if (WindowWidth = "")
            TibiaClient.getClientArea()

        _SideBarsArea.destroyInstance()

        _search := new _ItemSearch()
            .setName(itemName)
            .setArea(new _SideBarsArea())
            .setDebug(GetKeyState("Alt") && GetKeyState("Shift"))
            .search()


        if (_search.notFound()) {
            throw Exception(txt("Item não encontrado na tela.", "Item not found on screen."))
        }

        _search.getResult().moveMouse(background := false)

        ; MouseMove, WindowX + vars.x, WindowY + vars.y
        OldBotSettings.enableGuisLoading()
        msgbox, 64, % "Item search", % txt("Item encontrado." , "Item found."), 2

    }

    addItemImageFromClipboard(itemName := "", stackableItem := false, animatedSprite := false, differentSprites := false, spriteSelected := "") {
        this.checkItemName(itemName)

        clipboardBitmap := new _BitmapImage(_BitmapImage.SOURCE_CLIPBOARD)

        w := clipboardBitmap.getW()
        h := clipboardBitmap.getH()
        if (w != this.itemImageWidth OR h != this.itemImageHeight) {
            clipboardBitmap.dispose()
            throw Exception(txt("A tamanho da imagem precisa ser " this.itemImageWidth " x " this.itemImageHeight " pixels, recorte a imagem no Paint e tente novamente.`nAlém disso, a imagem precisa conter corretamente o item no slot de uma backpack.`n`nLargura atual: ", "The image size must be " this.itemImageWidth " x " this.itemImageHeight " pixels, crop the image on Paint add try again.`nBesides that, the image must contain correctly the item in the slot of a backpack.`n`nCurrent width:") w " x " h )
        }

        itemBitmap := new _BitmapImage(clipboardBitmap.crop(0, 0, 0, 13))

        this.addItemFromBitmaps(itemBitmap, clipboardBitmap, itemName, itemAtributes, stackableItem, animatedSprite, differentSprites, spriteSelected)

        itemBitmap.dispose()
        clipboardBitmap.dispose()

        this.afterAddItemImageGuiChanges(itemName, stackableItem, animatedSprite, differentSprites, spriteSelected)
    }

    AddItemBackpack(itemName := "", selectedBackpack := "", stackableItem := false, animatedSprite := false, differentSprites := false, spriteSelected := "") {
        this.checkItemName(itemName)

        this.searchValidation(itemName, stackableItem, animatedSprite, differentSprites, spriteSelected)

        this.findBackpack(selectedBackpack)

        try {
            this.GetItemImageBackpack(itemName, itemsObj[itemName], stackableItem, animatedSprite, differentSprites, spriteSelected)
        } catch e {
            ToolTip
            throw e
        }

        this.afterAddItemImageGuiChanges(itemName, stackableItem, animatedSprite, differentSprites, spriteSelected)
    }


    checkItemName(itemName := "", msg := "") {
        if (empty(itemName))
            throw Exception(msg != "" ? msg : txt("Selecione um item na lista ou preencha o campo ""Nome do item"" para adicionar.", "Select an item on the list or fill the ""Item name"" field to add."))
    }

    isNewItem(itemName) {
        if (customItemsImageFile) {
            if (!customItemsImageObj.hasKey(itemName))
                return true
        } else {
            if (!itemsImageObj.hasKey(itemName))
                return true
        }
        return false
    }

    afterAddItemImageGuiChanges(itemName, stackableItem := false, animatedSprite := false, differentSprites := false, spriteSelected := "") {

        isNewItem := this.isNewItem(itemName)

        if (isNewItem = false) {
            LootingGUI.filterItemList()
            if (spriteSelected > 1)
                itemName .= "_" spriteSelected
            LootingGUI.selectItemOnItemList(itemName, (stackableItem = true && spriteSelected < 2) ? 7 : 1)

            this.saveItemsImage()
        }

        if (spriteSelected > 1 && spriteSelected < 8) {
            lastSpriteSelected := spriteSelected
            spriteSelected++
            itemSpriteSelected := spriteSelected
            try GuiControl, CavebotGUI:, itemSprite%spriteSelected%, 1
            catch {
            }
            ; GuiControl, CavebotGUI:, itemSprite%lastSpriteSelected%, 0
        }

        /**
        if is a new item that is not in the item list
        recreate the entire item list to show the new item on the ListView
        */

        if (isNewItem = true) {
            if (customItemsImageFile) {
                if (!customItemsImageObj.hasKey(itemName))
                    this.loadItemsJsonStart(itemsJson := false, itemsImageJson := true)
            } else {
                if (!itemsImageObj.hasKey(itemName))
                    this.loadItemsJsonStart(itemsJson := false, itemsImageJson := true)
            }

            LootingGUI.filterItemList()
            if (spriteSelected > 1)
                itemName .= "_" spriteSelected
            LootingGUI.selectItemOnItemList(itemName, (stackableItem = true && spriteSelected < 2) ? 7 : 1)

            this.saveItemsImage()
        }


    }

    AddItemCyclopedia(itemName := "", searchItem := true, stackableItem := false, animatedSprite := false, differentSprites := false, spriteSelected := "") {
        ; msgbox, % itemName " / " searchItem " / " stackableItem " / "  animatedSprite " / " differentSprites " / " spriteSelected
        t1 := A_TickCount
        try
            this.searchValidation(itemName, stackableItem, animatedSprite, differentSprites, spriteSelected)
        catch e
            throw e

        if (differentSprites = 1 && spriteSelected = "")
            throw Exception("Select the sprite number of the ""Different sprite"".")

        if (itemName != "" && !itemsObj[itemName])
            throw Exception("Item """ itemName """ not found in the item list.`nEnsure that it is the actual item name and try again.")

        try
            this.openCyclopedia()
        catch e
            throw e


        if (itemName != "") {
            try {
                if (!this.GetItemImageCyclopedia(itemName, itemsObj[itemName], searchItem, stackableItem, animatedSprite, differentSprites, spriteSelected, false)) {
                    return false
                }
            } catch e {
                ToolTip
                throw e
            }
        } else {
            searchItem := true
            itemCount := 1
            itemLimit := 500
            for item, itemAtributes in itemsObj
            {
                if (itemsImageObj[item]) { ;  if the item is already on itemsImageObj
                    continue
                }

                if (itemCount > itemLimit)
                    break
                ; if (!InStr(itemAtributes.marketable, "yes", 0) && itemAtributes.marketable != "") ; torch não tem o atributo de marketable
                if (InStr(itemAtributes.marketable, "no",0))
                    continue
                if (InStr(itemAtributes.primarytype, "Furniture", 0))
                    continue
                ToolTip, % itemCount " / " itemLimit " (" itemsObj.Count() ")"
                itemName := StrReplace(item, "  ", " ") ; replace 2 spaces for one, some items have 2 spaces in the name
                try {

                    if (!this.GetItemImageCyclopedia(itemName, itemAtributes, searchItem, stackableItem, animatedSprite, differentSprites, spriteSelected, A_Index)) {
                        return false
                    }
                } catch e {
                    ToolTip
                    this.saveItemsImage()
                    throw e
                }
                itemCount++
            }
            ToolTip
        }

        LootingGUI.filterItemList()
        LootingGUI.selectItemOnItemList(itemName, (stackableItem = true && spriteSelected < 2) ? 7 : 1)

        if (dontSaveItemimages != true)
            this.saveItemsImage()
        return
    }

    GetItemImageCyclopedia(item, itemAtributes, searchItem := true, stackableItem := false, animatedSprite := false, differentSprites := false, spriteSelected := "", loopItems := false) {
        ; msgbox, % item " / " searchItem " / " stackableItem " / "  animatedSprite " / " differentSprites " / " spriteSelected
        ; ToolTip, % key " / " itemsObj.Count(), WindowX + 10, WindowY + 50
        if (searchItem = true) {
            if (this.selectItemOnCyclopedia(item) = false) {
                return false
            }
        }

        c1 := _Coordinate.FROM(this.searchField)
            .subX(108)
            .subY(26)

        c2 := new _Coordinate(c1.getX(), c1.getY())
            .addX(32)
            .addY(19)
        coordinates := new _Coordinates(c1, c2)

        ; if (!A_IsCompiled) {
        msgbox, 68,, % "Add selected item image on Cyclopedia for """ item """?"
        ifmsgbox, no
            return false
        ; }
        ; coordinates.debug()

        this.addItemImageFromArea(coordinates, item, itemAtributes, stackableItem, animatedSprite, differentSprites, spriteSelected)

        return true
    }

    GetItemImageBackpack(item, itemAtributes, stackableItem := false, animatedSprite := false, differentSprites := false, spriteSelected := "") {
        if (_ContainersJson.exists()) {
            c1 := new _FirstSlotArea().getCoordinates().getC1().CLONE()
                .add(1)
        } else {
            c1 := new _Coordinate(this.backpacksearch.getX(), this.backpacksearch.getY())
                .addX(10)
                .addY(20)

            if (LootingSystem.lootingJsonObj.mainBackpacks.options.offsetFromImageX) {
                c1.addX(LootingSystem.lootingJsonObj.mainBackpacks.options.offsetFromImageX)
            }

            if (LootingSystem.lootingJsonObj.mainBackpacks.options.offsetFromImageY) {
                c1.addY(LootingSystem.lootingJsonObj.mainBackpacks.options.offsetFromImageY)
            }
        }

        c2 := new _Coordinate(c1.getX(), c1.getY())
            .addX(32)
            .addY(19)
        coordinates := new _Coordinates(c1, c2)
        ; coordinates.debug()

        this.addItemImageFromArea(coordinates, item, itemAtributes, stackableItem, animatedSprite, differentSprites, spriteSelected)
    }

    addItemImageFromArea(coordinates, item, itemAtributes, stackableItem, animatedSprite, differentSprites, spriteSelected) {
        screenImage := _BitmapEngine.getClientBitmap()

        itemBitmapHalf := new _BitmapImage(screenImage.cropFromArea(new _WindowArea().getCoordinates(), coordinates))

        c2 := new _Coordinate(coordinates.getC2().getX(), coordinates.getC2().getY())
            .addY(13)
        coordinates := new _Coordinates(coordinates.getC1(), c2)
        ; coordinates.debug()

        itemBitmapFull := new _BitmapImage(screenImage.cropFromArea(new _WindowArea().getCoordinates(), coordinates))
        if (!A_IsCompiled) {
            itemBitmapFull.toClipboard()
        }
        ; itemBitmapFull.debug()

        try {
            this.addItemFromBitmaps(itemBitmapHalf, itemBitmapFull, item, itemAtributes, stackableItem, animatedSprite, differentSprites, spriteSelected)
        } catch e {
            throw e
        } finally {
            itemBitmapHalf.dispose()
            itemBitmapFull.dispose()
        }
    }

    addItemFromBitmaps(pBitmapItem, pBitmapItemFull, item, itemAtributes, stackableItem, animatedSprite, differentSprites, spriteSelected) {
        _Validation.instanceOf("pBitmapItem", pBitmapItem, _BitmapImage)
        _Validation.instanceOf("pBitmapItemFull", pBitmapItemFull, _BitmapImage)

        halfImagePath := A_Temp "\__item.png"
        fullImagePath := A_Temp "\__itemFull.png"
        pBitmapItem.save(halfImagePath)
        pBitmapItemFull.save(fullImagePath)

        Sleep, 25
        ; msgbox, % this.cropItemImageBackpackLeft "," this.cropItemImageBackpackRight "," this.cropItemImageBackpackUp "," this.cropItemImageBackpackDown

        base64 := FileToBase64(halfImagePath)
        base64Full := FileToBase64(fullImagePath)

        this.setAtributesAndAdd(item, itemAtributes, base64, base64Full, stackableItem, animatedSprite, differentSprites, spriteSelected)

        base64 := ""
        base64Full := ""
    }

    setAtributesAndAdd(item, itemAtributes, base64, base64Full, stackableItem := false, animatedSprite := false, differentSprites := false, spriteSelected := "", bulkSearch := false) {

        newAtributes := this.setItemImageAtributes(item, itemAtributes, base64, base64Full, stackableItem, animatedSprite, differentSprites, spriteSelected, bulkSearch)
        ; m(item "`n" serialize(newAtributes))

        this.addItemImage(item, newAtributes, spriteSelected)

        ; _ := new _ItemImage(item).dispose()

        if (this.openPaint = true) {
            imageDir := A_Temp "\__item.png"
            run, C:\Windows\system32\mspaint.exe "%imageDir%"
            Sleep, 600
            msgbox 64,, paint opened
        }

    }

    setItemImageAtributes(item, itemAtributes, base64, base64Full, stackableItem := false, animatedSprite := false, differentSprites := false, spriteSelected := "", bulkSearch := false) {

        ; , atributes.id := itemAtributes.itemid.1
        ; , atributes.category := itemAtributes.primarytype
        atributes := {}
            , atributes.image := base64
            , atributes.image_full := base64Full
            , atributes.stackable := stackableItem = true ? "stackable" : "nonstackable"
            , atributes.animated_sprite := animatedSprite += 0
            , atributes.timestamp := A_Now

        atributes.sprites := this.getSprite(item)

        if (bulkSearch = true) {
            atributes.stackable := InStr(itemAtributes.stackable, "yes",0) ? "stackable" : "nonstackable"
                , atributes.animated_sprite := false
        }


        if (spriteSelected > 7) OR (this.getItemAtribute(item, "sprites") != "" && spriteSelected > this.getItemAtribute(item, "sprites"))
            this.setItemAtribute(item, "sprites", spriteSelected)

        switch item {
            case "gold coin", case "platinum coin", case "crystal coin":
                atributes.sprites := 8
        }


        switch itemAtributes.primarytype {
            case "Ammunition", case "Food":
                atributes.sprites := 8
            case "Wands", case "Rods":
                atributes.animated_sprite := true
        }
        if (InStr(itemAtributes.primarytype, "Enchanted", 0))
            atributes.animated_sprite := true

        return atributes
    }

    getSprite(itemName) {

        highestSprite := 1
        loop, 8 {

            if (this.getItemAtribute(itemName "_" A_Index, "sprites") != "")
                highestSprite++
        }
        return "" highestSprite ""

    }

    selectItemOnCyclopedia(itemName)
    {
        newItemName := ""
        if (InStr(itemName, "_")) {
            str := StrSplit(itemName, "_")
            newItemName := str.1
        }

        this.clearInputPosition.click()
        Sleep, 75
        this.searchField.click()
        Sleep, 75
        Send(newItemName ? newItemName : itemName)
        Sleep, 75

        this.firstItemPosition.click()
        Sleep, 100


        _search := new _ImageSearch()
            .setPath("Data\Files\Images\Cyclopedia\cyclopedia_empty_item")
            .setCoordinates(this.emptyItemArea)
            .setVariation(60)
        ; .debug()
            .search()

        if (_search.found()) {
            return false
        }

        return true
    }

    getMainBackpacksList()
    {
        if (!OldBotSettings.settingsJsonObj.files.containers) {
            return new _LootingJson().get("mainBackpacks.backpacksList")
        }

        return new _ContainersJson().get("backpack.list")
    }

    resolveMainBackpack()
    {
        static value
        if (value) {
            return value
        }

        if (bps := this.getMainBackpacksList()) {
            return value := _Arr.first(bps)
        }

        if (bag := new _LootingJson().get("mainBackpacks.bag")) {
            bag := StrReplace(bag, "_", " "), bag := StrReplace(bag, ".png", "")
            alias := new _LootingJson().get("mainBackpacks.alias")

            return value := alias ? alias : bag
        }

        throw Exception("Failed to resolve main backpack/bag")
    }

    /**
    * @throws
    */
    findBackpack(selectedBackpack, clientArea := "")
    {
        if (empty(selectedBackpack)) {
            throw Exception("Choose a backpack.")
        }

        if (bps := this.getMainBackpacksList()) {
            for key, bp in bps {
                string := StrSplit(bp, "_")
                backpack := string.1
                if (selectedBackpack = backpack) {
                    selectedBackpack := StrReplace(bp, ".png", "")
                    break
                }
            }
        }

        this.backpackSearch := this.getMainBackpackSearch(StrReplace(selectedBackpack, " ", "_"), clientArea).search()

        if (this.backpackSearch.notFound()) {
            throw Exception("Backpack """ selectedBackpack """ not found, make sure the backpack is opened on screen.")
        }

        return this.backpackSearch
    }

    isWordBackpack(selectedBackpack)
    {
        return InStr(selectedBackpack, "_word")
    }

    resolveBackpackVariation(selectedBackpack)
    {
        return this.isWordBackpack(selectedBackpack) ? this.WORD_BACKPACK_VARIATION : 60
    }

    getMainBackpackSearch(selectedBackpack, clientArea := "")
    {
        return new _ImageSearch()
            .setFile(selectedBackpack)
            .setFolder(ImagesConfig.mainBackpacksFolder)
            .setArea(clientArea ? clientArea : new _WindowArea())
            .setVariation(this.resolveBackpackVariation(selectedBackpack))
            .setDebug(GetKeyState("Alt") && GetKeyState("Shift"))
        ; .setDebug()
    }

    openCyclopedia() {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFolder("Data\Files\Images\Cyclopedia")
                .setVariation(60)
        }

        if (WindowWidth = "") {
            TibiaClient.getClientArea()
        }

        seletedItemsSearch := searchCache
            .setFile("cyclopedia_items_selected")
            .search()

        if (seletedItemsSearch.notFound()) {
            _search := searchCache
                .setFile("cyclopedia_button")
                .setClickOffsets(2)
                .search()

            if (_search.found()) {
                _search.click()
                Sleep, 200
            }

            _search
                .setFile("cyclopedia_items")
                .search()

            if (_search.found()) {
                _search.click()
                Sleep, 200
            }

        }

        seletedItemsSearch.search()
        if (seletedItemsSearch.notFound()) {
            throw Exception("Cyclopedia ""Items"" section not selected.")
        }

        _search := searchCache
            .setFile("cyclopedia_window")
            .search()

        if (_search.notFound()) {
            throw Exception("Cyclopedia window not found.")
        }

        c1 := new _Coordinate(_search.getX(), _search.getY())
            .subX(305)
            .addY(375)

        c2 := _Coordinate.FROM(c1)
            .addX(45)
            .addY(45)

        this.emptyItemArea := new _Coordinates(c1, c2)
        ; .debug()


        this.searchField := new _Coordinate(_search.getX(), _search.getY())
            .subX(190)
            .addY(408)

        this.clearInputPosition := _Coordinate.FROM(this.searchField)
            .addX(80)

        this.firstItemPosition := _Coordinate.FROM(this.searchField)
            .subY(150)
    }

    /**
    Depends on LootingSystem
    */
    createMainBackpacksList() {

        this.mainBackpacks := {}
        this.mainBackpacksList := ""

        Path := ImagesConfig.mainBackpacksFolder "\*.png"
        classLoaded("LootingSystem", LootingSystem)

        ; msgbox, % TibiaClient.getClientIdentifier()
        if (isNotTibia13()) {
            this.loadCustomMainBackpacks()
            return
        }

        Loop, % Path {
            ; msgbox, % A_LoopFileName
            if (InStr(A_LoopFileName, "_2"))
                continue
            backpackName_ := StrReplace(A_LoopFileName, ".png", "")
            ; if (!FileExist("Data\Files\Images\Main Backpacks\" backpackName_ "_2.png"))
            ; continue
            backpackName := StrReplace(backpackName_, "_", " ")
            /**
            if the item array does not have the backpack
            means it is a custom backpack
            */
            if (!itemsObj.hasKey(backpackName))
                continue
            ; msgbox, % backpackName

            if (OldBotSettings.settingsJsonObj.configFile = "settings.json") && (RegExMatch(backpackName,"(otclient)"))
                continue
            if (OldBotSettings.settingsJsonObj.configFile != "settings_medivia.json") && (RegExMatch(backpackName,"(medivia)"))
                continue

            this.mainBackpacks.Push(backpackName)
            this.mainBackpacksList .= backpackName "|"
        }
    }

    loadCustomMainBackpacks() {
        /**
        if is a custom client and only have the "bag" available to use, only list the bag
        */
        if (LootingSystem.lootingJsonObj.mainBackpacks.bag != "") {

            backpackName_ := StrReplace(LootingSystem.lootingJsonObj.mainBackpacks.bag, ".png", "")
            backpackName := StrReplace(backpackName_, "_", " ")

            this.mainBackpacks.Push({"name": backpackName, "alias": LootingSystem.lootingJsonObj.mainBackpacks.alias})
            this.mainBackpacksList .= (LootingSystem.lootingJsonObj.mainBackpacks.alias != "" ? LootingSystem.lootingJsonObj.mainBackpacks.alias : backpackName) "|"
            return
        }

        bps := this.getMainBackpacksList()
        aliases := new _ContainersJson().get("backpack.aliases")


        if (bps) {
            for index, bp in bps {
                backpack := _A.first(StrSplit(bp, "_"))
                this.mainBackpacks.Push({"name": backpack, "alias": alias := aliases[index]})
                this.mainBackpacksList .= (alias ? alias : backpack) "|"
            }
            return
        }
    }

    mainBackpackImageName()
    {
        return _A.first(StrSplit(this.resolveMainBackpack(), "_"))
    }

    mainBackpackAlias()
    {
        return _A.first(new _ContainersJson().get("backpack.aliases"))
    }

    addItemImage(itemName, itemObj, newSprite := "") {
        if (newSprite > 1) {
            itemName .= "_" newSprite
            itemObj.sprites := ""
        }

        if (customItemsImageFile) {
            customItemsImageObj[itemName] := itemObj
        }

        itemsImageObj[itemName] := itemObj

    }

    /**
    save "itemsImageObj" on itemsImageFile
    */
    saveItemsImage() {
        Gui, CarregandoCavebot:Destroy
        Gui, CarregandoCavebot:-Caption +Border +Toolwindow +AlwaysOnTop
        Gui, CarregandoCavebot:Add, Progress, y+8 HwndpHwnd1 +0x8 w120
        Gui, CarregandoCavebot:Show, NoActivate,
        PostMessage,0x40a,1,38,, ahk_id %pHwnd1%

        if (customItemsImageFile) {
            customItemsImageFile.Fill(customItemsImageObj)
            customItemsImageFile.Save(true)
            Gui, CarregandoCavebot:Destroy
            return
        }

        itemsImageFile.Fill(itemsImageObj)
        itemsImageFile.Save(true)
        Gui, CarregandoCavebot:Destroy
    }

    /**
    Generates and returns dropdown-like string based on the filters below.

    @param string filterNames regexmatch of the item name.
    ex: star|stone|knife
    @param array<string> filterCategories array of categories, categories are primarytype atribute of TibiaWiki's API.
    @param string excludeNames same as filterNames, but will exclude.
    @param array<string> excludeCategories same as filterNafilterCategorieses, but will exclude.
    @return string
    */
    getItemList(filterNames := "", filterCategories := "", excludeNames := "", excludeCategories := "") {
        itemListDropdown := ""

        for key, value in this.getItemListArray(filterNames, filterCategories, excludeNames, excludeCategories) {
            itemListDropdown .= value "|"
        }

        return itemListDropdown
    }

    /**
    * @return array<string>
    */
    getItemListArray(filterNames := "", filterCategories := "", excludeNames := "", excludeCategories := "") {
        itemListArray := {}
        for itemName, itemAtributes in itemsImageObj
        {
            if (filterNames != "") && (!RegExMatch(itemName,"(" filterNames ")"))
                continue
            if (excludeNames != "") && (RegExMatch(itemName,"(" excludeNames ")"))
                continue
            if (filterCategories) {
                /**
                filter array of categories
                */
                matchCategory := false
                for key, categoryName in filterCategories
                {
                    if (itemsObj[itemName].primarytype = categoryName) {
                        matchCategory := true
                        break
                    }
                    if (itemsImageObj[itemName].category = categoryName) {
                        matchCategory := true
                        break
                    }
                }
            }
            if (excludeCategories) {
                /**
                filter array of categories
                */
                matchExcludeCategory := false
                for key, categoryName in excludeCategories
                {
                    if (itemsObj[itemName].primarytype = categoryName) {
                        matchExcludeCategory := true
                        break
                    }
                    if (itemsImageObj[itemName].category = categoryName) {
                        matchExcludeCategory := true
                        break
                    }
                }
            }
            if (excludeCategories) && (matchExcludeCategory = true)
                continue
            if (filterCategories) && (matchCategory = false)
                continue
            itemListArray.Push(itemName)
        }

        return itemListArray
    }

    paintCornerPink(byRef itemBitmap) {
        for key, pos in this.itemCornerPos
        {
            try Gdip_SetPixel(itemBitmap, pos.x, pos.y, ImagesConfig.pinkColor)
            catch e {
                Gui, Carregando:Destroy
                throw Exception("Item: " itemName "`n" e.Message "`n" e.What)
            }
        }

    }

    paintBackgroundPink(byRef itemBitmap) {

        try Gdip_GetDimensions(itemBitmap, w,h)
        catch e
            throw e

        Loop, % h {
            y := A_Index - 1

            Loop, % w {
                x := A_Index - 1
                    , pixColorARGB := Gdip_GetPixel(itemBitmap, x, y, A_ThisFunc)
                    , pixColor := ConvertARGB(pixColorARGB)
                ; msgbox, % Clipboard := StrReplace(pixColor, "0x", "")
                SetFormat, Integer, D

                paint := false
                for key, value in this.grayBackgroundPixels
                {
                    if (pixColor = value) {
                        paint := true
                        break
                    }

                }

                if (paint = true) {
                    Gdip_SetPixel(itemBitmap, x, y, ImagesConfig.pinkColor)
                    ; Gdip_SetBitmapToClipboard(itemBitmap)
                    ; msgbox, bitmap to clipboard
                }
            }
        }
    }

    addItemListRow(itemName, index := "") {
        Gui, ListView, LV_ItemList
        LV_Add( (index = "" ? "" : "Icon" index),"", itemName, this.rowCategory(itemName), this.rowStackable(itemName), this.rowAnimation(itemName), this.rowSprites(itemName), this.rowWeight(itemName), index, this.rowTimestamp(itemName) )
    }

    itemNameNoSprite(itemName) {
        return InStr(itemName, "_") ? SubStr(itemName, -1) : itemName
    }

    rowCategory(itemName) {
        return this.getItemAtribute(this.itemNameNoSprite(itemName), "primarytype")
    }

    rowStackable(itemName) {
        return (this.getItemAtribute(itemName, "stackable") = "stackable") ? "yes" : "no"
    }

    rowAnimation(itemName) {
        return (this.getItemAtribute(itemName, "animated_sprite") = 1) ? "true" : "false"
    }

    rowWeight(itemName) {
        return this.getItemAtribute(this.itemNameNoSprite(itemName), "weight") = "" ? "" : this.getItemAtribute(this.itemNameNoSprite(itemName), "weight") " oz"
    }

    rowTimestamp(itemName) {
        return this.getItemAtribute(itemName, "timestamp")
    }

    rowSprites(itemName) {
        if (customItemsImageObj[itemName] != "")
            return customItemsImageObj[itemName].sprites
        return this.getItemAtribute(itemName, "sprites")
    }

    getItemAtribute(itemName, atribute) {
        switch atribute {
            case "primarytype", case "category":
                if (customItemsImageObj[itemName].category != "")
                    return customItemsImageObj[itemName].category

                if (itemsImageObj[itemName].category != "") {
                    ; msgbox, % itemName "/" itemsImageObj[itemName].category
                    return itemsImageObj[itemName].category
                }

                return itemsObj[itemName][atribute]

            case "secondarytype", case "weight":
                return itemsObj[itemName][atribute]
        }
        if (customItemsImageObj[itemName] != "")
            return customItemsImageObj[itemName][atribute]
        return itemsImageObj[itemName][atribute]
    }

    changeItemCategory() {
        GuiControlGet, itemNameToAdd

        if (itemNameToAdd = "")
            throw Exception(LANGUAGE = "PT-BR" ? "Selecione um item na lista ou preencha o campo ""Item name"" para adicionar." : "Select an item on the list or fill the ""Item name"" field to add.")

        GuiControlGet, itemCategory
        if (customItemsImageFile)
            customItemsImageObj[itemNameToAdd].category := itemCategory
        else
            itemsImageObj[itemNameToAdd].category := itemCategory

        LV_Modify(selectedRow,"", "", itemNameToAdd, this.rowCategory(itemNameToAdd), this.rowStackable(itemNameToAdd), this.rowAnimation(itemNameToAdd), this.rowSprites(itemNameToAdd))

        LootingGUI.filterItemList()
        this.saveItemsImage()
    }

    getMissingItemsImageFromCyclopedia() {
        global dontSaveItemimages := true
        itemsGetImage := {}

        ; itemsGetImage.push("eaaaaa")
        ; itemsGetImage.push("Abomination's Eye")
        ; itemsGetImage.push("Abomination's Tail")
        ignore := {}
        ; ignore["arcane dragon robe"] := 1

        for item, at in itemsObj
        {
            ; if (item = "head_2") {
            ;     out(item)
            ; }
            /**
            replace 2 spaces for 1
            */
            item := StrReplace(item, "  ", " ")
            /**
            replace " '" for ","
            */
            item := StrReplace(item, " 's", "'s")

            /**
            ignore items with less than 2 words
            */
            str := StrSplit(item, " ")
            nameStr := StrSplit(at.name, " ")
            if (str.MaxIndex() < 2 && nameStr.MaxIndex() < 2)
                continue
            /**
            ignore if first character is a number
            */
            ; if (at.marketable = "")
            ;     continue
            if (at.weight = "")
                continue
            if (at.npcvalue = "0" && !this.isEquipment(at))
                continue
            if (at.npcvalue = "?")
                continue
            if (InStr(at.marketable, "no") && !this.isEquipment(at))
                continue
            if (RegExMatch(at.primarytype,"i)(Decoration|Furniture|Wall Hangings)"))
                continue
            if (RegExMatch(at.secondarytype,"i)(Party Items|Illumination)"))
                continue
            if (RegExMatch(item,"i)( replica| mayhem| carving| remedy|conjurer wand|arrow EARTH|arrow ENERGY|arrow ICE|arrow FIRE| (Weak)| (Used)| book_| rune emblem_))"))
                continue
            /*
            item such "ancient iks ritual chalice"
            */
            if (!at.marketable && !at.stackable) && (!at.npcvalue || at.npcvalue = "0")
                continue

            if (ignore.HasKey(item)) {
                continue
            }

            firstChar := SubStr(item, 1, 1)
            if firstChar is number
                continue

            if (itemsImageObj.hasKey(item)) {
                continue
            }

            itemsGetImage.push(item)
        }

        ; m(itemsGetImage.MaxIndex()"`n`n" serialize(itemsGetImage))

        for key, item in itemsGetImage
        {
            StringLower, item, item

            tooltip, % item

            if (GetKeyState("Ctrl") = true) {
                global dontSaveItemimages := false
                msgbox, will stop
                break
            }

            try
                this.AddItemCyclopedia(item, searchItem := true, stackableItem := false, animatedSprite := false, differentSprites := false, itemSpriteSelected := "")
            catch e {
                GuiControl, CavebotGUI:, AddNewItem_ItemListCyclopedia, Add new item
                GuiControl, CavebotGUI:Enable, AddNewItem_ItemListCyclopedia
                Msgbox, 48,, % e.Message "`n" e.What "`n" e.Extra
                continue
            } finally {

            }


            if (GetKeyState("Ctrl") = true) {
                msgbox, will stop
                break
            }

        }
        global dontSaveItemimages := false

        msgbox, will save
        ToolTip
        ItemsHandler.saveItemsImage()
    }

    isEquipment(itemAtributes) {
        return RegExMatch(itemAtributes.primarytype,"(Ammunition|Armors|Weapon|Boots|Legs|Rods|Wands|Shields|Rings)")
    }

    checkInvalidItemImage() {
        invalidImages := {}
        invalidImages.Push("iVBORw0KGgoAAAANSUhEUgAAAB4AAAATCAYAAACHrr18AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAK3SURBVEhLxZRLbhNBEIYHtllAFigyfsQzHs/LDxzHiSUkjsGOQyBOwD24CTfgAJyBLQdAavqrmb9ddsKaRam76/H/1VXVnb2+vg7/Q7L1eh2KYhHWm01omjbkRWHCvu3atOKTZZkJuvl8bjFt1w0+XVhWVSjL0laEGNamqUNV1YYre0YA5JvtNgEjk+k0JSPdnx+fw69vN7YHYDKZhLppYvzKiMHZ7e6eYEkgxG9RxksQuIqBGL5+fBc+HUfhff7qLICz1x0OBwOHXDqqAnAdb6cYsBBwEfla9ciAgzcgIvOE/sa73e6JTuJjvJwlYPUelKyUy5cXadvurMfcVD7fv1yl1SdKRWiV+spMKH7gOpEKECGQfvmhUB9JVol4YlZkPB6bb9f1vcd/WS0NYza7ld+JWE6DwUiVgJLqQaqw3fYxvtT0Hoyy7EnYC4vbk/SzxLexHPv7e9sDyErWehaUvInDyH4RgQHHB1FlSHK1WofR29EZDklgx2+IOREDKDBKl4IiodmW/W15CfixBwjhllQEPckSR7xawFu+2+9Dnhd2jpLZyLNSCt4vWXP25IBBhA1iyNQa9nXdxAHKLQH8PSnlJSEql26sZyFypg8w9gQWb14kcpFwM3rGwECuVujjwJ84EdM+WqNE0WXUnY2IyUxZMzSeGGCE20MMIED0nV+MauF3SQwHpCTM2bgIUBZ6g3pzAkA0uSnjCxHoczHYwJwXuZ2NmBvy7lCImNsI5MPyZQJhjz78/pkEHxFgFzF76aezWZyf/nVwNuLNdmPvD8Xpxv1bE5knBviSWOT/In48HlP/xWFfJgPz8PhwZqBvrB6UniGcRSi7bCIXKfPCa6HHHj+DVD+NN2jsPaAIRS7hLDKfIPEaOI9tA60pns6mNvLeAfEkl6WVSIddOhELT5gk0rZd+AtI3XXEYuUUSwAAAABJRU5ErkJggg==")
        invalidImages.Push("iVBORw0KGgoAAAANSUhEUgAAAB4AAAATCAYAAACHrr18AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAMSSURBVEhLxdVXdhsxDAXQWUL8F0XF6lNU7diy978xZi4oyNpBPng4RHl4KOQ0v15eyv9YzfF4LOv1phxPp9J1fVmt17F890P/2Nns9vtyOp9Dtlwuw6cfhrvNEPrtdhu7lT5d15b9vg3c1DccBAf49v4eQchm8/mDjMWGEzuAvmezWWm7btQdwofN9foWNvT8ck9i9s12UxqOh9GRkOPleg12HOwMa8BTZCnox8fHA3yxeL0D94HRjtklCefMEpazHUZknCXN4OfLNc5Akq1MupGkQICuI8H0+T2ZRBbkZFWnEsd727qw2253gSOBhkAGjLCxc1aFmvmu9P0QLN///h2dauAaoJaVvzMb5UeUXKsyY8HqWpVhOJTGgeJ8vjwALY6ABU/n5xIKEoHGWaBLW7LpdBq2AtjZ7/a7sMuKxVQLYqURAOW3J4EkVUH2QVRGKkJOL3MYZM6++bNnK5bAzg2GPkz065i9cnLI/mKdNkqe/dqMwMB9W1kZJA+HY5n8mZS2Hft8v3IWfU1qqD0GcLleAsC34chgggsYul0N4iZkUEDWc+bIkknk50q2kdxqtY7MGwYATCWBnmHNmFxpyIE50wmczDO47AwOAjI7nc5lOg7afLF49FUybGE3sst+Uho2YEqepSFLIukoEwMjeFZHP/nQzeeLIIk0LK1Jogg2tS/joIwGOeG1bF0YYguQ3G7JHjhAQGxdo3jt7jgIIqQSYsBCGE5kzIHzT3l34fjT4zbakCXPzJQbARXzqvH1kCit78yuYtS3fblehdxqMHDvMBRcQNmQ17L+vEACAmHDmR0bFZK9K4ZgBrXDQcZ7zq/OwXiPsXX/ZMrYt9dJgBwK33azANx1EVDGXjgBnOmeM05it6+vIC0BVUEgrhPl5+0zgmdv7ZaAnJJAklDquKcjGH0OIFDgSGc12MDUFmTMQlwnSmDKBZAhOWMlzqGrmdRfJPDM7PN2C3vEs5z8EBOETU2m3gy66LHA88U8Rh5A9pKcg/JxyN56bJ7LJovv7+/Q8alkV6GDZzc/MIJIP5R/akI1gfVgOPcAAAAASUVORK5CYII=")
        ; invalidImages.Push()
        ; invalidImages.Push()
        ; invalidImages.Push()

        deletedItems := ""
        for itemName, itemAtributes in itemsImageObj
        {
            for key, value in invalidImages
            {
                if (itemAtributes.image = value) {
                    deletedItems .= itemName ","
                    itemsImageObj.Delete(itemName)
                    break
                }
            }

        }

        ItemsHandler.saveItemsImage()
        clipboard := deletedItems
        msgbox, % deletedItems
    }

    createGrayBackgroundPixels() {
        this.grayBackgroundPixels := {}
        this.grayBackgroundPixels.Push("0x2C2C2C")
        this.grayBackgroundPixels.Push("0x222223")
        this.grayBackgroundPixels.Push("0x2C2D2D")
        this.grayBackgroundPixels.Push("0x282829")
        this.grayBackgroundPixels.Push("0x212222")
        this.grayBackgroundPixels.Push("0x292A29")
        this.grayBackgroundPixels.Push("0x252626")
        this.grayBackgroundPixels.Push("0x2D2E2E")
        this.grayBackgroundPixels.Push("0x202020")
        this.grayBackgroundPixels.Push("0x292A2A")
        this.grayBackgroundPixels.Push("0x242424")
        this.grayBackgroundPixels.Push("0x282827")
        this.grayBackgroundPixels.Push("0x262627")
        this.grayBackgroundPixels.Push("0x202021")
        this.grayBackgroundPixels.Push("0x313232")
        this.grayBackgroundPixels.Push("0x1C1D1D")
        this.grayBackgroundPixels.Push("0x1C1C1C")
        this.grayBackgroundPixels.Push("0x272828")
        this.grayBackgroundPixels.Push("0x2C2C2B")
        this.grayBackgroundPixels.Push("0x303031")
        this.grayBackgroundPixels.Push("0x232423")
        this.grayBackgroundPixels.Push("0x242526")
        this.grayBackgroundPixels.Push("0x1E1E1F")
        this.grayBackgroundPixels.Push("0x2B2C2B")
        this.grayBackgroundPixels.Push("0x2F3030")
        this.grayBackgroundPixels.Push("0x2D2E2D")
        this.grayBackgroundPixels.Push("0x343434")
        this.grayBackgroundPixels.Push("0x272827")
        this.grayBackgroundPixels.Push("0x232424")
        this.grayBackgroundPixels.Push("0x2E2F30")
        this.grayBackgroundPixels.Push("0x272827")
        this.grayBackgroundPixels.Push("0x282828")
        this.grayBackgroundPixels.Push("0x303030")
        this.grayBackgroundPixels.Push("0x181919")
        this.grayBackgroundPixels.Push("0x242425")
        this.grayBackgroundPixels.Push("0x29292A")
        this.grayBackgroundPixels.Push("0x323333")
        this.grayBackgroundPixels.Push("0x20201F")
        this.grayBackgroundPixels.Push("0x2A2A2B")
        this.grayBackgroundPixels.Push("0x1A1A1A")
        this.grayBackgroundPixels.Push("0x2E2E2F")
        this.grayBackgroundPixels.Push("0x1B1B1B")
        this.grayBackgroundPixels.Push("0x252625")
        this.grayBackgroundPixels.Push("0x2E2E2F")
        this.grayBackgroundPixels.Push("0x1F2020")
        this.grayBackgroundPixels.Push("0x2B2B2C")
        this.grayBackgroundPixels.Push("0x191A19")
        this.grayBackgroundPixels.Push("0x272728")
        this.grayBackgroundPixels.Push("0x2F302F")
        this.grayBackgroundPixels.Push("0x212122")
        this.grayBackgroundPixels.Push("0x30302F")
        this.grayBackgroundPixels.Push("0x202221")
        this.grayBackgroundPixels.Push("0x353635")
        this.grayBackgroundPixels.Push("0x1D1E1D")
        this.grayBackgroundPixels.Push("0x353636")
        this.grayBackgroundPixels.Push("0x2D2D2E")
        this.grayBackgroundPixels.Push("0x1B1C1C")
        this.grayBackgroundPixels.Push("0x1D1E1E")
        this.grayBackgroundPixels.Push("0x1D1D1E")
        this.grayBackgroundPixels.Push("0x363737")
        this.grayBackgroundPixels.Push("0x3A3A3A")
        this.grayBackgroundPixels.Push("0x383838")
    }


    addItemFromBackback()
    {
        Gui, CavebotGUI:Submit, NoHide
        GuiControlGet, selectedBackpack
        GuiControlGet, itemNameToAdd
        if (empty(selectedBackpack)) {
            Msgbox, 64,, % txt("Selecione a backpack.", "Select the backpack"), 2
            return
        }

        bp := selectedBackpack
        for key, value in ItemsHandler.mainBackpacks
        {
            if (selectedBackpack = value.alias) {
                bp := value.name
                break
            }
        }

        if (TibiaClient.getClientArea() = false) {
            return
        }

        OldBotSettings.disableGuisLoading()
        try {
            this.AddItemBackpack(itemNameToAdd, bp, stackableItem, animatedSprite, differentSprites, itemSpriteSelected)
        } catch e {
            OldBotSettings.enableGuisLoading()
            GuiControl, CavebotGUI:, AddNewItem_ItemListBackpack, Add new item
            GuiControl, CavebotGUI:Enable, AddNewItem_ItemListBackpack
            ; if (A_IsCompiled)
            Msgbox, 48,, % e.Message, 10
            return
            ; else
            ; Msgbox, 48,, % e.Message "`n" e.What "`n" e.File "`n" e.Line
        }
        OldBotSettings.enableGuisLoading()
    }

}