
#If

#If (WinActive(MAIN_GUI_TITLE) && MainTab = "Cavebot")

!Numpad1::
!1::
    GuiControl, CavebotGUI:, WaypointSQM_1, 1
    TrayTipHotkey("Direction set to SW")
return

!Numpad2::
!2::
    GuiControl, CavebotGUI:, WaypointSQM_2, 1
    TrayTipHotkey("Direction set to S")
return

!Numpad3::
!3::
    GuiControl, CavebotGUI:, WaypointSQM_3, 1
    TrayTipHotkey("Direction set to SE")
return

!Numpad4::
!4::
    GuiControl, CavebotGUI:, WaypointSQM_4, 1
    TrayTipHotkey("Direction set to W")
return

!Numpad5::
!5::
    GuiControl, CavebotGUI:, WaypointSQM_5, 1
    TrayTipHotkey("Direction set to C")
return

!Numpad6::
!6::
    GuiControl, CavebotGUI:, WaypointSQM_6, 1
    TrayTipHotkey("Direction set to E")
return

!Numpad7::
!7::
    GuiControl, CavebotGUI:, WaypointSQM_7, 1
    TrayTipHotkey("Direction set to NW")
return

!Numpad8::
!8::
    GuiControl, CavebotGUI:, WaypointSQM_8, 1
    TrayTipHotkey("Direction set to N")
return

!Numpad9::
!9::
    GuiControl, CavebotGUI:, WaypointSQM_9, 1
    TrayTipHotkey("Direction set to NE")
return
^+Home::
    if (DisableEditScript = 1)
        return
    fromHotkey := true
    TrayTipHotkey("Walk waypoint added")
    Gosub, AddWaypoint_Walk
return

^+End::
    if (CavebotScript.isMarker())
        return
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

^End::
    SendMessage, 0x0115, 7, 0,, ahk_id %hLV_Waypoints% ;WM_VSCROLL    
return

!Home::
    if (DisableEditScript = 1)
        return
    if (breakvar)
        return
    WaypointHandler.moveWaypoint(1)
    CavebotGUI.loadLV()
    LV_Modify(1, "Focus Select") 
    LV_Modify(1, "Vis") 
return

!End::
    if (DisableEditScript = 1)
        return
    if (breakvar)
        return
    waypointNumber := WaypointHandler.getLastWaypoint()
    WaypointHandler.moveWaypoint(waypointNumber + 1)
    CavebotGUI.loadLV()
    LV_Modify(waypointNumber, "Focus Select") 
    LV_Modify(waypointNumber, "Vis") 
return

!WheelUp::
!Up::
MoverWaypointUp_Hotkey:
    if (DisableEditScript = 1)
        return
    if (breakvar)
        return
    selectedWaypoint :=  _ListviewHandler.getSelectedItemOnLV("LV_Waypoints_" tab, 1)
    if (selectedWaypoint = "" OR selectedWaypoint = "WP")
        return
    if (selectedWaypoint = 1)
        return
    breakvar := true
    waypointNumber := selectedWaypoint - 1
    WaypointHandler.moveWaypoint(waypointNumber, "", false, fromHotkey := true)
    CavebotGUI.loadLV()
    LV_Modify(waypointNumber, "Focus Select") 
    LV_Modify(waypointNumber, "Vis") 
    breakvar := false
return

!WheelDown::
!Down::
MoverWaypointDown_Hotkey:
    if (DisableEditScript = 1)
        return
    if (breakvar)
        return
    selectedWaypoint :=  _ListviewHandler.getSelectedItemOnLV("LV_Waypoints_" tab, 1)
    if (selectedWaypoint = "" OR selectedWaypoint = "WP")
        return
    waypointNumber := selectedWaypoint + 1
    if (waypointNumber = WaypointHandler.getLastWaypoint() + 1)
        return
    breakvar := true
    WaypointHandler.moveWaypoint(waypointNumber, "", false, fromHotkey := true)
    CavebotGUI.loadLV()
    LV_Modify(waypointNumber, "Focus Select") 
    LV_Modify(waypointNumber, "Vis") 
    breakvar := false
return

!d::
    if (DisableEditScript = 1)
        return
    Goto, DuplicarWaypoint

!Delete::
    if (DisableEditScript = 1)
        return
    Goto, DeleteWaypoints

    #If

