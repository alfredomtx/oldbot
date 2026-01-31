CreateCavebotMenu:


    Menu, CavebotMenu, Add, % SET_START_MENU "`tAlt+Left Click", SetStartWaypoint
    try Menu, CavebotMenu, Icon, % SET_START_MENU "`tAlt+Left Click", % "Data\Files\Images\GUI\Icons\running2.ico",0,18
    catch {
    }

    Menu, CavebotMenu, Add, % txt("Remover waypoint inicial", "Remove start waypoint"), RemoveStartWaypoint
    try Menu, CavebotMenu, Icon, % txt("Remover waypoint inicial", "Remove start waypoint"), % "Data\Files\Images\GUI\Icons\running_x.png",0,18
    catch {
    }

    Menu, CavebotMenu, Add

    Menu, CavebotMenu, Add, % txt("Deletar", "Delete") "`tAlt+Del", DeleteWaypoints
    icon := _Icon.get(_Icon.DELETE)
    try Menu, CavebotMenu, Icon, % txt("Deletar", "Delete") "`tAlt+Del", % icon.dllName, % icon.number,16
    catch {
    }
    Menu, CavebotMenu, Add, % txt("Duplicar", "Duplicate") "`tAlt+D", DuplicarWaypoint

    icon := _Icon.get(_Icon.DUPLICATE)
    try Menu, CavebotMenu, Icon, % txt("Duplicar", "Duplicate") "`tAlt+D", % icon.dllName, % icon.number,16
    catch {
    }
    Menu, CavebotMenu, Add, % txt("Mover", "Move") "`tAlt+Arrow/Scroll Up", MoverWaypointUp_Hotkey
    try Menu, CavebotMenu, Icon, % txt("Mover", "Move") "`tAlt+Arrow/Scroll Up", shell32.dll,247,16
    catch {
    }
    Menu, CavebotMenu, Add, % txt("Mover", "Move") "`tAlt+Arrow/Scroll Down", MoverWaypointDown_Hotkey
    try Menu, CavebotMenu, Icon, % txt("Mover", "Move") "`tAlt+Arrow/Scroll Down", shell32.dll,248,16
    catch {
    }
    Menu, CavebotMenu, Add, % LANGUAGE = "PT-BR" ? "Mover para aba" : "Move to tab", MoveToTabGUI

    iconNumber := (isWin11() = true) ? 255 : 254
    try Menu, CavebotMenu, Icon, % LANGUAGE = "PT-BR" ? "Mover para aba" : "Move to tab", imageres.dll, %iconNumber%,16
    catch {
    }


    if (scriptSettingsObj.cavebotFunctioningMode != "markers") {
        Menu, CavebotMenu, Add

        Menu, SubMapViewer, Add, At start Range `tAlt+Right Click, OpenWaypointMapViewerStart
        Menu, SubMapViewer, Add, At end Range, OpenWaypointMapViewerEnd

        Menu, SubTibiaMapsIo, Add, At start Range, OpenWaypointTibiaMapsIoStart
        Menu, SubTibiaMapsIo, Add, At end Range, OpenWaypointTibiaMapsIoEnd


        Menu, CavebotMenu, Add, Open in Map Viewer, :SubMapViewer
        try Menu, CavebotMenu, Icon, Open in Map Viewer, ieframe.dll,35,16
        catch {
        }
        Menu, CavebotMenu, Add, Open in TibiaMaps.io, :SubTibiaMapsIo
        try Menu, CavebotMenu, Icon, Open in TibiaMaps.io, ieframe.dll,35,16
        catch {
        }
    }

    Menu, CavebotMenu, Add
    Menu, CavebotMenu, Add, % "Edit Type `tT", EditWaypointType
    Menu, CavebotMenu, Add, % "Edit Label `tL", EditWaypointLabel
    Menu, CavebotMenu, Add, % "Edit Coordinates `tC", EditWaypointCoordinates
    Menu, CavebotMenu, Add, % "Edit Range `tR", EditWaypointRange
    Menu, CavebotMenu, Add, % "Edit Action `tA", EditWaypointAction





    /*
    Tab menu (right click)
    */
CreateCavebotTabMenu:
    Menu, TabMenuCavebot, Add, % LANGUAGE = "PT-BR" ? "Deletar aba" : "Delete tab", DeleteTabGUI
    try Menu, TabMenuCavebot, Icon, % LANGUAGE = "PT-BR" ? "Deletar aba" : "Delete tab", imageres.dll,94,16
    catch {
    }

    Menu, TabMenuCavebot, Add, % LANGUAGE = "PT-BR" ? "Renomear aba" : "Rename tab", RenameTabGUI
    iconNumber := (isWin11() = true) ? 253 : 252
    try Menu, TabMenuCavebot, Icon, % LANGUAGE = "PT-BR" ? "Renomear aba" : "Rename tab", imageres.dll, %iconNumber%,16
    catch {
    }

    Menu, TabMenuCavebot, Add, % txt("Remover waypoint inicial", "Remove start waypoint"), RemoveStartWaypoint
    try Menu, TabMenuCavebot, Icon, % txt("Remover waypoint inicial", "Remove start waypoint"), % "Data\Files\Images\GUI\Icons\running_x.png",0,16
    catch {
    }

return



