/*
labels shared between oldbot.exe and cavebot.exe
*/



minimapViewerCavebotGUIGuiClose:
minimapViewerCavebotGUIGuiEscape:
    ; gosub, saveMapViewerWindowPosition
    Gui, minimapViewerCavebotGUI:Destroy
return

changeFloor:
    MinimapGUI.changeFloorSlider()
return

changeZoom:
    MinimapGUI.setDefaultMinimapGUI()
    GuiControlGet, zoomLevel
    MinimapGUI.changeZoomLevel(zoomLevel)
return

viewerCoordinates:
    MinimapGUI.guiControlGetCoordinates()
return

clickOnViewerMap:
    coords := MinimapGUI.getCoordinatesFromMousePosition()

    x := tibiaMapX1 + coords.x, y := tibiaMapY1 + coords.y
    if (x = MinimapGUI.viewerX && y = MinimapGUI.viewerY)
        return
    MinimapGUI.cropFromMinimapImage(coords.x, coords.y, MinimapGUI.viewerZ)
return



