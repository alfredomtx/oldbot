disableHealingMemory:
    GuiControlGet, disableHealingMemory
    IniWrite, %disableHealingMemory%, %DefaultProfile%, other_settings, disableHealingMemory
    Reload()
return

higherMapTolerancyPositionSearchMapViewer:
    gosub, resetCharacterCoords
    GuiControlGet, higherMapTolerancyPositionSearchMapViewer
    higherMapTolerancyPositionSearch := higherMapTolerancyPositionSearchMapViewer
    IniWrite, %higherMapTolerancyPositionSearch%, %DefaultProfile%, cavebot_settings, higherMapTolerancyPositionSearch
    GuiControl, CavebotGUI:, higherMapTolerancyPositionSearch, % higherMapTolerancyPositionSearch
return

higherMapTolerancyPositionSearch:
    gosub, resetCharacterCoords
    GuiControlGet, higherMapTolerancyPositionSearch
    GuiControl, minimapViewerGUI:, higherMapTolerancyPositionSearchMapViewer, % higherMapTolerancyPositionSearch
    IniWrite, %higherMapTolerancyPositionSearch%, %DefaultProfile%, cavebot_settings, higherMapTolerancyPositionSearch
return

charCoordsFromMemory:
    GuiControlGet, charCoordsFromMemory
    _GuiHandler.submitSetting("scriptSettings", A_GuiControl, %A_GuiControl%)
    gosub, minimapViewerGUIGuiClose
    Goto, CavebotGUI
return

charCoordsFromMemory2:
    GuiControlGet, charCoordsFromMemory2
    charCoordsFromMemory := charCoordsFromMemory2
    _GuiHandler.submitSetting("scriptSettings", "charCoordsFromMemory", charCoordsFromMemory)
    gosub, minimapViewerGUIGuiClose
    Goto, CavebotGUI
return

tryToIdentifyFloorLevelOnStart:
    GuiControlGet, tryToIdentifyFloorLevelOnStart
    _GuiHandler.submitSetting("scriptSettings", A_GuiControl, %A_GuiControl%)
return
