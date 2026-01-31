


testItemImage:
    Gui, CavebotGUI:Submit, NoHide
    OldBotSettings.disableGuisLoading()
    try ItemsHandler.searchItemOnScreen(itemNameToAdd)
    catch e {
        OldBotSettings.enableGuisLoading()
        Msgbox, 48,, % e.Message, 10
    return
}
return

AddItemPictureClipboard:
    Gui, CavebotGUI:Submit, NoHide
    OldBotSettings.disableGuisLoading()
    try ItemsHandler.addItemImageFromClipboard(itemNameToAdd, stackableItem, animatedSprite, differentSprites, itemSpriteSelected)
    catch e {
        OldBotSettings.enableGuisLoading()
        Msgbox, 48,, % e.Message, 10
    return
}

OldBotSettings.enableGuisLoading()
return

AddItemPictureBackpack:
    try {
        ItemsHandler.addItemFromBackback()
    } catch e {
        OldBotSettings.enableGuisLoading()
        Msgbox, 48,, % e.Message, 10
    }
return


ChooseMainBackpack:
    LootingHandler.setMainBackpack()
return




GetItemsImageCyclopedia:

    global dontSaveItemimages := true
    itemsGetImage := {}

    ; itemsGetImage.push("eaaaaa")
    ; itemsGetImage.push("Abomination's Eye")
    ; itemsGetImage.push("Abomination's Tail")

    for item, itemAtributes in itemsObj
    {

        if (!itemsImageObj.hasKey(item))
            itemsGetImage.push(item)
    }


    m(itemsGetImage.MaxIndex())
    m(serialize(itemsGetImage))




    for key, item in itemsGetImage
    {
        StringLower, item, item

        try
            ItemsHandler.AddItemCyclopedia(item, searchItem := true, stackableItem := false, animatedSprite := false, differentSprites := false, itemSpriteSelected := "")
        catch e {
            GuiControl, CavebotGUI:, AddNewItem_ItemListCyclopedia, Add new item
            GuiControl, CavebotGUI:Enable, AddNewItem_ItemListCyclopedia
            Msgbox, 48,, % e.Message "`n" e.What "`n" e.Extra
            continue
        } finally {
            global dontSaveItemimages := false

        }

    }
    ItemsHandler.saveItemsImage()
return

AddItemPictureCyclopedia:
    Gui, CavebotGUI:Submit, NoHide
    if (TibiaClient.getClientArea() = false)
        return

    try ItemsHandler.AddItemCyclopedia(itemNameToAdd, searchItem, stackableItem, animatedSprite, differentSprites, itemSpriteSelected)
    catch e {
        GuiControl, CavebotGUI:, AddNewItem_ItemListCyclopedia, Add new item
        GuiControl, CavebotGUI:Enable, AddNewItem_ItemListCyclopedia
        Msgbox, 48,, % e.Message "`n" e.What "`n" e.Extra
    return

}
return



uploadItemsDatabase:
    Gui, CavebotGUI:Hide
    Gui, ItemDatabaseGUI:Hide
    try
        API.uploadItems()
    catch e
        Msgbox, 48,, % e.Message, 10
    Gui, CavebotGUI:Show
    Gui, ItemDatabaseGUI:Show
return

downloadItemsDatabase:
    Gui, CavebotGUI:Hide
    Gui, ItemDatabaseGUI:Hide
    try
        API.downloadItems()
    catch e
        Msgbox, 48,, % e.Message, 10
    Gui, CavebotGUI:Show
    Gui, ItemDatabaseGUI:Show
return

ItemDatabaseGUI:
    LootingGUI.createItemDatabaseGUI()
return

ItemDatabaseGUIGuiClose:
ItemDatabaseGUIGuiEscape:
    Gui, ItemDatabaseGUI:Destroy
return


editItemListCategory:    
    OldBotSettings.disableGuisLoading()
    try ItemsHandler.changeItemCategory()
    catch e {
        OldBotSettings.enableGuisLoading()
        GuiControl, CavebotGUI:, AddNewItem_ItemListBackpack, Add new item
        GuiControl, CavebotGUI:Enable, AddNewItem_ItemListBackpack
        ; if (A_IsCompiled)
        Msgbox, 48,, % e.Message, 10
        ; else
        ; Msgbox, 48,, % e.Message "`n" e.What "`n" e.File "`n" e.Line
    }
    OldBotSettings.enableGuisLoading()
return