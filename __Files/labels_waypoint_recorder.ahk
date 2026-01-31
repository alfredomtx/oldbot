
autoRecordWaypointsLabel:
    WaypointRecorder.autoRecordWaypoints()
return

submitWaypointRecorderSetting:
    Gui, recordWaypointSettingsGUI:Submit, NoHide
    ; msgbox, % A_GuiControl "," %A_GuiControl%
    WaypointRecorder.writeIniWaypointRecorderSettings(A_GuiControl, %A_GuiControl%)
return

recordWaypointSettingsGUIGuiClose:
recordWaypointSettingsGUIGuiEscape:
    Gui, recordWaypointSettingsGUI:Destroy

return
