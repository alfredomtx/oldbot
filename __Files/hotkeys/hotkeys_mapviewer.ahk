


#If (WinActive(MinimapGUI.mapViewerGuiTitle))

^+Home::
    if (DisableEditScript = 1)
        return
    fromHotkey := true
    TrayTipHotkey("Walk waypoint added")
    Gosub, AddWaypoint_Walk
return
^+End::
    if (DisableEditScript = 1)
        return
    fromHotkey := true
    TrayTipHotkey("Stand waypoint added")
    Gosub, AddWaypoint_Stand
return
+!Del::
    if (DisableEditScript = 1)
        return
    waypointNumber := WaypointHandler.getLastWaypoint()
    if (waypointNumber = "")
        return
    TrayTipHotkey("Deleted last waypoint")
    WaypointHandler.delete(waypointNumber, tab)
    CavebotGUI.loadLV()

return

^+q::
    IniRead, SmartExit, %DefaultProfile%, settings, SmartExit, 1
    if (SmartExit != 1)
        return

    WinGet, ProcessID, PID, ahk_id %TibiaClientID%

    ; Process, Exist, %ProcessID%
    ; clipboard := ProcessID
    ; msgbox, % ErrorLevel " | " ProcessID
    if (ProcessID = 0 OR ProcessID = "") {
        Tooltip, % "Tibia client is not opened"
        Sleep, 1000
        ToolTip
        return
    }
    ; só funciona rodando como admin
    Tooltip, % "Smart exit triggered"

    if (portsToClose = "") {
        portsToClose := {}
        portsToClose.Push("7190")
        portsToClose.Push("7171")
        portsToClose.Push("7172")
        portsToClose.Push("9092")
        ; portsToClose.Push("443")
    }

    for key, port in portsToClose
    {
        try
            Run, Data\Files\Third Part Programs\Cports\cports.exe /close * * * %port% %ProcessID%
        catch
            Msgbox,48,, % LANGUAGE = "PT-BR" ? "Erro ao realizar o smart exit (" key ")." : "Error performing the smart exit (" key ")."
    }

    Sleep, 500
    ToolTip
return

+Esc::
    Gui, minimapViewerGUI:Destroy
return

~Up::
    MinimapGUI.navigate("Up")
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonUp
return
~Down::
    MinimapGUI.navigate("Down")
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonDown
return
~Left::
    MinimapGUI.navigate("Left")
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonLeft
return
~Right::
    MinimapGUI.navigate("Right")
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonRight
return

~^Up::
    MinimapGUI.navigate("Up", 5)
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonUp
return
~^Down::
    MinimapGUI.navigate("Down", 5)
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonDown
return
~^Left::
    MinimapGUI.navigate("Left", 5)
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonLeft
return
~^Right::
    MinimapGUI.navigate("Right", 5)
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonRight
return
~+W::
    MinimapGUI.navigate("Up")
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonUp
return
~+S::
    MinimapGUI.navigate("Down")
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonDown
return
~+A::
    MinimapGUI.navigate("Left")
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonLeft
return
~+D::
    MinimapGUI.navigate("Right")
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonRight
return
~^W::
    MinimapGUI.navigate("Up", 5)
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonUp
return
~^S::
    MinimapGUI.navigate("Down", 5)
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonDown
return
~^A::
    MinimapGUI.navigate("Left", 5)
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonLeft
return
~^D::
    MinimapGUI.navigate("Right", 5)
    GuiControl, % (MinimapGUI.cavebotGUI = false ? "minimapViewerGUI:Focus" : "minimapViewerCavebotGUI:Focus"), minimapButtonRight
return

!WheelDown::
    MinimapGUI.floorDown()
return
!WheelUp::
    MinimapGUI.floorUp()
return

~WheelDown::
    MouseGetPos, OutputVarX, OutputVarY, OutputVarWin, controlHwnd
    WinGetTitle, activeWindow, A
    if (activeWindow = minimapGUI.minimapGuiTitle && InStr(controlHwnd, "Static")) {
        MinimapGUI.setDefaultMinimapGUI()

        GuiControlGet, zoomLevel
        if (zoomLevel = MinimapGUI.minZoomLevel)
            return
        zoomLevel--
        MinimapGUI.changeZoomLevel(zoomLevel, true)
    }
return

~WheelUp::
    MouseGetPos, OutputVarX, OutputVarY, OutputVarWin, controlHwnd
    WinGetTitle, activeWindow, A
    if (activeWindow = minimapGUI.minimapGuiTitle && InStr(controlHwnd, "Static")) {
        MinimapGUI.setDefaultMinimapGUI()
        GuiControlGet, zoomLevel
        if (zoomLevel = MinimapGUI.maxZoomLevel)
            return
        zoomLevel++
        MinimapGUI.changeZoomLevel(zoomLevel, true)
    }
return


~^WheelDown::
    MouseGetPos, OutputVarX, OutputVarY, OutputVarWin, controlHwnd
    WinGetTitle, activeWindow, A
    if (activeWindow = minimapGUI.minimapGuiTitle && InStr(controlHwnd, "Static")) {
        MinimapGUI.setDefaultMinimapGUI()

        coords := MinimapGUI.getCoordinatesFromMousePosition()
        MinimapGUI.changeCoordinatesControl(coords.x, coords.y)

        GuiControlGet, zoomLevel
        if (zoomLevel = MinimapGUI.minZoomLevel)
            return
        zoomLevel--
        MinimapGUI.changeZoomLevel(zoomLevel, true)
    }
return

~^WheelUp::
    MouseGetPos, OutputVarX, OutputVarY, OutputVarWin, controlHwnd
    WinGetTitle, activeWindow, A
    if (activeWindow = minimapGUI.minimapGuiTitle && InStr(controlHwnd, "Static")) {
        MinimapGUI.setDefaultMinimapGUI()
        coords := MinimapGUI.getCoordinatesFromMousePosition()
        MinimapGUI.changeCoordinatesControl(coords.x, coords.y)
        GuiControlGet, zoomLevel
        if (zoomLevel = MinimapGUI.maxZoomLevel)
            return
        zoomLevel++
        MinimapGUI.changeZoomLevel(zoomLevel, true)
    }
return



/*
add waypoint hotkeys
*/
a::
    MinimapGUI.addWaypointFromViewer("Action")
return
MButton::
w::
    MinimapGUI.addWaypointFromViewer("Walk")
return
+MButton::
s::
    MinimapGUI.addWaypointFromViewer("Stand")
return
d::
    MinimapGUI.addWaypointFromViewer("Door")
return
^MButton::
l::
    switch TibiaClient.getClientIdentifier() {
        case "rltibia":
            MinimapGUI.addWaypointFromViewer("Ladder")
        default:
            MinimapGUI.addWaypointFromViewer("Ladder Up")

    }
return
!MButton::
r::
    MinimapGUI.addWaypointFromViewer("Rope")
return

u:: MinimapGUI.addWaypointFromViewer("Use")
h:: MinimapGUI.addWaypointFromViewer("Shovel")
m:: MinimapGUI.addWaypointFromViewer("Machete")

!w:: _MinimapGUI.sendNavigation(new _NavigationWalk())
!s:: _MinimapGUI.sendNavigation(new _NavigationStand())
!u:: _MinimapGUI.sendNavigation(new _NavigationUse())
!r:: _MinimapGUI.sendNavigation(new _NavigationUseRope())
!h:: _MinimapGUI.sendNavigation(new _NavigationUseShovel())
!1:: _MinimapGUI.sendNavigation(new _NavigationAction(1))
!2:: _MinimapGUI.sendNavigation(new _NavigationAction(2))
!3:: _MinimapGUI.sendNavigation(new _NavigationAction(3))
#If
