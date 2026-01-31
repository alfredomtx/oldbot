CreateItemListMenu:
    Menu, ItemListMenu, Add, switch Animated, ItemListMenuHandler
    Menu, ItemListMenu, Add, switch Stackable, ItemListMenuHandler
    Menu, ItemListMenu, Add, Change Sprites Count, ItemListMenuHandler
    Menu, ItemListMenu, Disable, switch Animated
    Menu, ItemListMenu, Disable, switch Stackable
    Menu, ItemListMenu, Disable, Change Sprites Count

return


ItemListMenuHandler:
    switch A_ThisMenuItem {
        case "Change Sprites Count":
            InputBox, spritesValue, Change sprites amount, New amount of sprites, "",220,127, "", "", "", "", 8
            if ErrorLevel = 1
                return
    }
    try
        ItemsHandler.switchAtribute(A_ThisMenuItem, spritesValue)
    catch e {
        Msgbox, 48,, % e.Message "`n" e.What "`n" e.Extra
    }
return
