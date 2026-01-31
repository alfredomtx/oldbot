



ImportWaypointsLabel:
	WaypointImporter.importWaypointsStart()
	return

selectWaypointImportTabLabel:
	WaypointImporter.selectWaypointImportTab()
	return

selectAllWaypointsImportLabel:
	WaypointImporter.selectAllWaypointsImport()
	return

importSelectedTabLabel:
	WaypointImporter.importSelectedTab()
	return
importSelectedWaypointsLabel:
	WaypointImporter.importSelectedWaypoints()
	return

importWaypointGUIGuiEscape:
importWaypointGUIGuiClose:
    Gui, importWaypointGUI:Destroy
    toggleCheckAllWaypoints := 0
    return