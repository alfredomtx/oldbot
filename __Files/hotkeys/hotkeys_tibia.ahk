#If (WinActive("ahk_class AutoHotkeyGUI") OR WinActive("ahk_id " TibiaClientID))

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

^+p:: Goto, ChecarConfiguracoesCliente

#If