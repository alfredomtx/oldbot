
minimapViewer:
    if (TibiaClient.clientMinimapPath = "") {
        Msgbox, 64,, % (LANGUAGE = "PT-BR" ? "Diretório da pasta ""minimap"" do cliente do Tibia não está setado, clique em ""Definir diretório do Minimap"" em Selecionar Client." : "Tibia client ""minimap"" folder directory is not set, click on ""Set Minimap directory"" in Select Client."), 20
        Gosub, selectTibiaClientLabel
        return
    }

    try {
        MinimapGUI.minimapViewerGUI()
    } catch e{
        _Logger.msgboxExceptionOnLocal(e)
    }

    try {
        MinimapGUI.minimapViewerGUI()
        MinimapGUI.guiControlGetCoordinates()
        MinimapGUI.cropFromMinimapImage(MinimapGUI.viewerX, MinimapGUI.viewerY, MinimapGUI.viewerZ)
    } catch e {
        _Logger.msgboxExceptionOnLocal(e)
    }
return

minimapViewerCavebot:
    MinimapGUI.minimapViewerCavebotGUI()

    MinimapGUI.guiControlGetCoordinates()
    MinimapGUI.cropFromMinimapImage(MinimapGUI.viewerX, MinimapGUI.viewerY, MinimapGUI.viewerZ)
return

generateCustomMinimap:
    Msgbox, 68, % "Generate Custom Map", % "This may take a while, usually less than 30 seconds.`n`nDo you want to continue?"
    IfMsgBox, No
        return
    Gui, minimapViewerGUI:Destroy
    Gui, CavebotGUI:Hide
    try MinimapFiles.drawMinimapFilesFromCustomMinimapFolder()
    catch e {
        Msgbox, 48,, % e.Message, 5
        return
    } finally {
        Gui, CavebotGUI:Show
    }
    msgbox, 64,, % "Done!`n" MinimapFiles.minimapFilesCount " minimap file(s).", 3
    Goto, minimapViewer
return

generateCustomMapFromMinimapFolder:
    if (TibiaClient.isClientOpened() = true) {
        Msgbox, 64,, % (LANGUAGE = "PT-BR" ? "Feche o cliente do Tibia antes de gerar." : "Close the Tibia Client before generating.")
        return
    }

    try MinimapFiles.minimapFolderExists()
    catch e {
        Msgbox, 48,, % e.Message
        return
    }
    Msgbox, 68, % "Generate Custom Map", % (LANGUAGE = "PT-BR" ? "Isso poderá levar um tempo, geralmente menos de 30 segundos.`n`nDeseja continuar?" : "This may take a while, usually less than 30 seconds.`n`nDo you want to continue?")
    IfMsgBox, No
        return
    Gui, CavebotGUI:Hide
    Gui, minimapViewerGUI:Destroy
    try MinimapFiles.drawMinimapFilesFromClientMinimapFolder()
    catch e {
        Msgbox, 48,, % e.Message, 5
        return
    } finally {
        Gui, CavebotGUI:Show
    }
    msgbox, 64,, % "Done!`n" MinimapFiles.minimapFilesCount " minimap file(s).", 3
    Goto, minimapViewer
return

resetDefaultMinimap:
    Msgbox, 68, % "Reset Default Map", % (LANGUAGE = "PT-BR" ? "Isso poderá levar um tempo, geralmente menos de 30 segundos.`n`nDeseja continuar?" : "This may take a while, usually less than 30 seconds.`n`nDo you want to continue?")
    IfMsgBox, No
        return
    Gui, CavebotGUI:Hide
    Gui, minimapViewerGUI:Destroy
    try MinimapFiles.resetMinimapFilesToDefault()
    catch e {
        Msgbox, 48,, % e.Message, 5
        return
    } finally {
        Gui, CavebotGUI:Show
    }
    msgbox, 64,, % "Done!`n" MinimapFiles.minimapFilesCount " minimap file(s).", 3
    Goto, minimapViewer
return


showCostFiles:
    MinimapGUI.checkboxCostFiles()
return
showGrayFiles:
    MinimapGUI.checkboxGrayFiles()
return

showCrosshair:
    MinimapGUI.checkboxShowCrosshair()
return

floorUp:
    MinimapGUI.navigateFloor("Up")
return
floorDown:
    MinimapGUI.navigateFloor("Down")
return
navUp:
    MinimapGUI.navigate("Up")
return
navLeft:
    MinimapGUI.navigate("Left")
return
navRight:
    MinimapGUI.navigate("Right")
return
navDown:
    MinimapGUI.navigate("Down")
return


minimapViewerGUIGuiClose:
minimapViewerGUIGuiEscape:

    gosub, saveMapViewerWindowPosition
    Gui, minimapViewerGUI:Destroy
return



MinimapViewerHotkeysGUI:
    MinimapGUI.MinimapViewerHotkeysGUI()
return

MinimapViewerHotkeysGUIGuiEscape:
MinimapViewerHotkeysGUIGuiClose:
    Gui, MinimapViewerHotkeysGUI:Destroy
return

openCoordMinimapFile:
    Gui, minimapViewerGUI:Submit, NoHide

    try MinimapGUI.validateCoords(MinimapGUI.viewerX, MinimapGUI.viewerY, MinimapGUI.viewerZ)
    catch e {
        msgbox, 48,, % e.Message, 6
        return
    }
    coords := {}
    coords.Push(MinimapGUI.viewerX "," MinimapGUI.viewerY "," MinimapGUI.viewerZ)

    type   := MinimapGUI.showCostFiles = false ? "Color" : "Cost"
    open   := true

    try MinimapFiles.openCoordinateMinimapFile(coords, type, open)
    catch e {
        Msgbox, 48,, % e.Message
        return
    }
return

copyToCustomMap:
    try MinimapGUI.copyToCustomMinimapFolder()
    catch e {
        Msgbox,64,, % e.Message, 6
        return
    }
return

showMinimapCoord:
    Gui, minimapViewerGUI:Default

    MinimapGUI.guiControlGetCoordinates()

    try MinimapGUI.validateCoords(MinimapGUI.viewerX, MinimapGUI.viewerY, MinimapGUI.viewerZ)
    catch e {
        Msgbox, 48,% "Go to coordinates", % e.Message, 2
        return
    }

    MinimapGUI.cropFromMinimapImage(MinimapGUI.viewerX, MinimapGUI.viewerY, MinimapGUI.viewerZ)
return

gotoLastCharCoords:
    if (posx = "" OR posy = "" OR posz = "")
        return
    try MinimapGUI.validateCoords(posx, posy, posz)
    catch e {
        Msgbox, 48,% "Go to coordinates", % e.Message, 2
        return
    }
    MinimapGUI.cropFromMinimapImage(posx, posy, posz)
return

characterPositionMapViewer:

    MinimapGUI.loadingDisableMinimapGUI()
    if (TibiaClient.isClientClosed() = true) {
        MinimapGUI.loadingDisableMinimapGUI(false)
        Msgbox, 64,, % txt("O cliente do Tibia está fechado.", "Tibia client is closed."), 2
        return
    }
    if (isDisconnected()) {
        MinimapGUI.loadingDisableMinimapGUI(false)
        Msgbox, 48,, % "Char must be logged in.", 2
        return
    }
    Critical, On
    GuiControl, minimapViewerGUI:Disable, characterPositionMapViewer
    GuiControl, minimapViewerGUI:, characterPositionMapViewer, % "Getting character position..."
    TibiaClient.getClientArea()



    try WaypointHandler.getCharPosition(true, new _CavebotIniSettings().get("adjustMinimapAddWaypoint"))
    catch e {
        Critical, Off
        posx := "", posy := "", posz := ""
        showWaypointLoad := false

        enableButtonTimer := Func("enableButton").bind("minimapViewerGUI", "characterPositionMapViewer", "Character position")
        MinimapGUI.loadingDisableMinimapGUI(false)
        SetTimer, % enableButtonTimer, Delete
        SetTimer, % enableButtonTimer, -100
        Msgbox, 48, Map viewer - Failed to get character position, % e.Message
        return
    }
    Critical, Off

    gosub, updateLastCharacterCoordinatesMapViewer

    enableButtonTimer := Func("enableButton").bind("minimapViewerGUI", "characterPositionMapViewer", "Character position")

    MinimapGUI.cropFromMinimapImage(posx, posy, posz)
    MinimapGUI.loadingDisableMinimapGUI(false)

    SetTimer, % enableButtonTimer, Delete
    SetTimer, % enableButtonTimer, -100
return



addWalkWaypointViewer:
    MinimapGUI.addWaypointFromViewer("Walk")

return

addStandWaypointViewer:
    MinimapGUI.addWaypointFromViewer("Stand")

return
addActionWaypointViewer:
    MinimapGUI.addWaypointFromViewer("Action")

return

minimapViewerMenuHandler:
    /**
    remove the space "Add Walk    A"
    */
    menuItem := StrReplace(A_ThisMenuItem, A_Tab, "")
    StringTrimRight, menuItem, menuItem, 2 ; remove hotkey
    menuItem := StrReplace(menuItem, "Alt", "")
    menuItem := StrReplace(menuItem, "Ctrl", "")
    menuItem := StrReplace(menuItem, "Shift", "")
    menuItem := trim(menuItem)

    switch menuItem {
        Case "Add Walk":
            MinimapGUI.addWaypointFromViewer("Walk")
        Case "Add Stand":
            MinimapGUI.addWaypointFromViewer("Stand")
        Case "Add Door":
            MinimapGUI.addWaypointFromViewer("Door")
        Case "Add Ladder":
            MinimapGUI.addWaypointFromViewer("Ladder")
        Case "Add Rope":
            MinimapGUI.addWaypointFromViewer("Rope")
        Case "Add Shovel":
            MinimapGUI.addWaypointFromViewer("Shovel")
        Case "Add Machete":
            MinimapGUI.addWaypointFromViewer("Machete")
        Case "Add Action":
            MinimapGUI.addWaypointFromViewer("Action")
        Case "Navigation - Walk":
            _MinimapGUI.sendNavigation(new _NavigationWalk())
        Case "Navigation - Stand":
            _MinimapGUI.sendNavigation(new _NavigationStand())
        Case "Navigation - Use":
            _MinimapGUI.sendNavigation(new _NavigationUse())
        Case "Navigation - Rope":
            _MinimapGUI.sendNavigation(new _NavigationUseRope())
        Case "Navigation - Shovel":
            _MinimapGUI.sendNavigation(new _NavigationUseShovel())
        Case "Navigation - Action 1":
            _MinimapGUI.sendNavigation(new _NavigationAction(1))
        Case "Navigation - Action 2":
            _MinimapGUI.sendNavigation(new _NavigationAction(2))
        Case "Navigation - Action 3":
            _MinimapGUI.sendNavigation(new _NavigationAction(3))

    }


return

openCustomMinimapFolder:
    if (MinimapFiles.customMinimapFolder = "") {
        Msgbox, 48,, % "Empty custom minimap folder path"
        return
    }
    try Run, % MinimapFiles.customMinimapFolder
    catch e {
        Msgbox, 48,, % "Failed to open folder:`n" MinimapFiles.customMinimapFolder, 6
        return
    }
return


saveMapViewerWindowPosition:
    WinGetPos, x, y, w, h, % MinimapGUI.mapViewerGuiTitle
    if (x = "" OR y = "")
        return
    if (x < -3000 OR y < -3000)
        return
    minimapGuiWindowX := x
    minimapGuiWindowY := y
    IniWrite, % minimapGuiWindowX, %DefaultProfile%, mapViewer, minimapGuiWindowX
    IniWrite, % minimapGuiWindowY, %DefaultProfile%, mapViewer, minimapGuiWindowY
return

ignoreWrongCoordinateMinimapFiles:
    GuiControlGet, ignoreWrongCoordinateMinimapFiles
    IniWrite, % ignoreWrongCoordinateMinimapFiles, %DefaultProfile%, mapViewer, ignoreWrongCoordinateMinimapFiles
return


changeMinimapFolder:
    MinimapGUI.minimapDirectoryGUI()
return

submitMinimapFolder:
    Gui, minimapDirectoryGUI:Submit, NoHide
    Gui, minimapDirectoryGUI:Hide
    try TibiaClient.selectMinimapFolderPath(clientMinimapDirectory)
    catch e {
        Msgbox, 48,, % e.Message
        Gui, minimapDirectoryGUI:Show
        return
    }
    MinimapGUI.minimapViewerStatusBar()
    ; if (A_IsCompiled)
    ; MinimapFiles.checkMinimapUpdate()
return


UpdateMinimap:
    switch TibiaClient.getClientIdentifier() {
        case "rltibia":
            try MinimapFiles.updateMinimapFiles(downloadFiles := true, reloadBot := true)
            catch e {
                if (A_IsCompiled)
                    Msgbox, 48,, % e.Message
                else
                    Msgbox, 48,, % e.Message "`n" e.What "`n" e.File "`n" e.Line
                return
            }
        default:
            try MinimapFiles.updateMinimapFilesOTClient()
            catch e {
                if (A_IsCompiled)
                    Msgbox, 48,, % e.Message
                else
                    Msgbox, 48,, % e.Message "`n" e.What "`n" e.File "`n" e.Line
                return
            }

    }
    msgbox, 64,, % "Minimap updated with scucess, you can now open the Tibia client.", 3
return


minimapDirectoryGUIGuiEscape:
minimapDirectoryGUIGuiClose:
    canceledLadderWaypoint := true
    Gui, minimapDirectoryGUI:Destroy
return

updateLastCharacterCoordinatesMapViewer:
    try {
        GuiControl, minimapViewerGUI:, lastCharacterCoordinates, % (posz = "") ? "None" : "x: " posx ", y: " posy ", z: " posz
    } catch e {
    }
return

resetCharacterCoords:
    posx := "", posy := "", posz := ""
    gosub, updateLastCharacterCoordinatesMapViewer
return