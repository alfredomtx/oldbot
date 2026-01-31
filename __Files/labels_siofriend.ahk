
LV_SioList:
    switch A_GuiEvent {
        Case "Normal", case "DoubleClick", case "RightClick":
            SioGUI.LV_SioList()   
    }
return

tutorialButtonSioFriend:
    openURL(LinksHandler.SioFriend.tutorial)
return