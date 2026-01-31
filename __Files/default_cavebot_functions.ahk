
/*
File purpose:
Store all the functions that are used on Cavebot.ahk only to share with OldBot.ahk, so it don't need to be Included on other scripts files
*/
walkToWaypoint()
{
    /**
    if the waypoint has been ignored due to excessive clicks, return because this waypoint has been skipped
    */
    if (cavebotSystemObj.waypoints[tab][Waypoint].ignoringClicksOnWaypointLimit = true)
        return

    ; cavebotSystemObj.timeWalkingWaypoint := 0
    ; cavebotSystemObj.timeWalkingWaypointArrow := 0
    ; cavebotSystemObj.forceWalk := true
    try {
        mapCoord := _MapCoordinate.FROM_CAVEBOT()
            .setIdentifier(tab ":" Waypoint)
        global CURRENT_WALK_TO_COORDINATE := new _WalkToCoordinate(mapCoord, {}, {})

        if (CavebotScript.isMarker()) {
            global CURRENT_WALK_TO_COORDINATE := new _WalkToMarker(mapCoord, {}, {})
        }

        return CURRENT_WALK_TO_COORDINATE.run()
    } catch e {
        _Logger.exception(e, A_ThisFunc)
        return false
    }
}

walkToWaypointByMapClick() {
    if (CavebotScript.isMarker()) {
        return CavebotWalker.walkToWaypointMarkerClick()
    }

    if (isDisconnected()) {
        Sleep, 2000
        return
    }

    cavebotSystemObj.clicksOnSameCharPosition := 0 ; variable to control if clicked on the same waypoint and being in the same position
    lastCharCoords.Push(Object("X", posx, "Y", posy, "Z", posz))
    if (!CavebotWalker.waypointClick()) {
        return
    }

    if (cavebotSystemObj.forceWalk) {
        return
    }

    Sleep, 400
    CavebotSystem.createCheckStoppedOnWaypointTimer()
    Loop, {
        if (isDisconnected()) {
            Sleep, 2000
            return
        }
        /**
        if walks 30 seconds to the same waypoint, force walk on arrow
        */
        if (cavebotSystemObj.timeWalkingWaypoint >= CavebotWalker.walkByClickLimit) {
            Send("Esc")
            Sleep, 50
            cavebotSystemObj.forceWalk := true
            cavebotSystemObj.forceWalkReason := "TimeWalkingToWaypoint"
            ; SetTimer, checkStoppedOnWaypointTimer, Delete
            return
        }
        ; Tooltip, % A_Index
        if (cavebotSystemObj.forceWalk = true) {
            ; SetTimer, walkingToWaypointTimer, Delete
            ; SetTimer, checkStoppedOnWaypointTimer, Delete
            return ; retorntar para a função essa função seja chamada novamente e ande pelas setas
        }

        if (checkArrivedOnCoord(mapX, mapY, mapZ) = true) {
            ; SetTimer, walkingToWaypointTimer, Delete
            ; SetTimer, checkStoppedOnWaypointTimer, Delete
            return
        }
        sleep, 50
    }
    return
}

walkToWaypointArrow() {
    cavebotSystemObj.triesWalk := 0
    cavebotSystem.triesWalkToBlockedCoord := 0
    Loop,  {
        if (isDisconnected()) {
            Sleep, 2000
            return true ; true to not skip to next waypoint
        }
        ; msgbox, % checkArrivedOnCoord(mapX, mapY, mapZ)
        if (checkArrivedOnCoord(mapX, mapY, mapZ) = true)
            return true

        if (CavebotWalker.checkWalkArrowTime() = false)
            return false

        Loop, 2 {
            Send("Esc") ; esc to stop walking before setting new path
            Sleep, 25
        }

        CavebotWalker.checkSqmsClosedAroundByLifeBars()

        t1SetPath := A_TickCount
        cavebotSystemObj.setPathTimer := 1
        SetTimer, setPathTimer, Delete
        SetTimer, setPathTimer, 1000
        path := "", path := {}
        try {
            path := CavebotWalker.setPath(mapX, mapY, mapZ)
        } catch e {
            if (!IsObject(cavebotSystemObj.waypoints[tab][Waypoint])) {
                writeCavebotLog("ERROR", "cavebotSystemObj not initialized for this waypoint, tab: "  tab ", waypoint: " Waypoint)
                return false
            }
            if (cavebotSystemObj.waypoints[tab][Waypoint].setPathFail = "")
                cavebotSystemObj.waypoints[tab][Waypoint].setPathFail := 0
            cavebotSystemObj.waypoints[tab][Waypoint].setPathFail++
            /**
            if is the first time that setPath failed for this waypoint,
            try to walk by map again instead of skipping (returning false)
            */

            if (cavebotSystemObj.waypoints[tab][Waypoint].setPathFail = 1)
                    && (cavebotSystemObj.forceWalkReason != "forcewalkarrow")
                    && (e.What != "CustomMap")
                    && (e.What != "CoordsTooFar") {
                    writeCavebotLog("Path WARNING", e.Message)
                cavebotSystemObj.forceWalk := false, cavebotSystemObj.forceWalkReason := ""

                _CavebotTrappedEvent.handle()

                return true
            } else {
                if (e.What != "CustomMap") {
                    writeCavebotLog("Path ERROR", e.Message, true)
                }
                return false
            }
        } finally {
            cavebotSystemObj.setPathTimer := 1
            SetTimer, setPathTimer, Delete
        }


        writeCavebotLog("Cavebot", A_TickCount - t1SetPath " ms setPath() - " path.Count() " sqms, fails: " cavebotSystemObj.waypoints[tab][Waypoint].setPathFail "(" cavebotSystem.triesWalkToBlockedCoord ")")
        if (path.Count() < 1) {
            if (!A_IsCompiled)
                writeCavebotLog("ERROR", "path.Count() < 1")
            /**
            added on 23/02/2022, disable force walk in places where waypoint is too far, and setting path is failing(MaxIndex < 1)
            */
            cavebotSystemObj.forceWalk := false
            /**
            also return false to skip waypoint in case failed setpath more than once
            */
            if (cavebotSystemObj.waypoints[tab][Waypoint].setPathFail > 0)
                return false
            break
        }

        Loop, {
            if (isDisconnected()) {
                Sleep, 2000
                return true ; true to not skip to next waypoint
            }

            if (CavebotWalker.checkIfWasTooFarAndNowWaypointIsVisible(mapX, mapY) = true)
                return true

            index := path.MaxIndex() - A_Index
                , nextStepCoord := path[index]

            /**
            if it's blank, it means there is no more path to walk(arrived), so need to generate new path
            */
            if (nextStepCoord = "")
                break
            /**
            in case the next coord is the same as char pos
            */
            if (isSameCharCoords(nextStepCoord.x, nextStepCoord.z, posz, false, A_ThisFunc, debug := false) = true)
                continue
            /**
            if the coord is blocked, break to set new path(the new path wont have this coord)
            */
            if (cavebotSystemObj.blockedCoordinates[nextStepCoord.x, nextStepCoord.y, posz]) {
                /**
                for some reason setpath is not ignoring the blocked coord when generating path
                so need to abort here if the tries get too much
                */
                cavebotSystem.triesWalkToBlockedCoord++
                if (cavebotSystem.triesWalkToBlockedCoord > cavebotSystemObj.triesWalkLimit) {
                    writeCavebotLog("Cavebot", "Tried too many times(" cavebotSystemObj.triesWalkLimit ") to walk to blocked SQM coord x: " nextStepCoord.x ", y: " nextStepCoord.y)
                    return false
                }

                if (!A_IsCompiled)
                    writeCavebotLog("ERROR", "@@@ tries: " cavebotSystem.triesWalkToBlockedCoord " " nextStepCoord.x "," nextStepCoord.y "," posz " ||| " serialize(cavebotSystemObj.blockedCoordinates))
                break
            }

            /**
            try to walk 2 times to the same coord(in case there is a character in the position)
            */
            Loop, 2 {
                cavebotSystemObj.triesWalk++
                if (cavebotSystemObj.triesWalk > cavebotSystemObj.triesWalkLimit)
                    break
                sucessWalk := walkToCoord(nextStepCoord.x, nextStepCoord.y, cavebotSystemObj.triesWalk)
                if (sucessWalk = true) {
                    cavebotSystem.triesWalkToBlockedCoord := 0
                    break ; break to walk to the next coord of nextStepCoord array, without generating new path
                }
            }
            if (cavebotSystemObj.triesWalk > cavebotSystemObj.triesWalkLimit) {
                /**
                if fail to walk to the sqm and targeting is disabled by Action or Ignored Temporarily(ex: battle list empty not found)
                , there is a chance that there's a creature in the sqm
                in this case must enable targeting again temporarily to search for creatures
                and return to NOT ADD COORD TO BLACKLIST yet
                and also consider that the char is trapped, to attack creatures checked with "onlyIfTrapped"
                */
                if (targetingSystemObj.targetingDisabled
                    OR targetingSystemObj.targetingIgnored.active)
                    && (!targetingSystemObj.isTrapped) {
                    CavebotSystem.runIsTrappedAction()
                    /**
                    this variable will be responsible to search for creatures even with targeting disabled
                    and also search for creatures with option onlyIfTrapped checked
                    */
                    targetingSystemObj.isTrapped := true
                    Sleep, 1000
                    cavebotSystemObj.triesWalk := 1
                    ; if (!A_IsCompiled)
                    ;     writeCavebotLog("ERROR", "reseting trieswalk trapped")

                    break
                }

                /**
                add the coord in the array of the ones blocked, so when generating path consider the coord non walkable
                also will consider non walkable when calling CavebotWalker.isCoordWalkable
                -- @ removed @ if targeting is enabled and is ignored temporarily, don't ignore to blacklist
                */
                writeCavebotLog("Cavebot", txt("Coordenadas x:" nextStepCoord.x ", y:" nextStepCoord.y " adicionadas na lista de coords bloqueadas", "Coordinates x:" nextStepCoord.x ", y:" nextStepCoord.y " added to blocked coords list") )
                cavebotSystemObj.blockedCoordinates[nextStepCoord.x, nextStepCoord.y, posz] := true

                cavebotSystemObj.triesWalk := 1
                ; if (!A_IsCompiled)
                ;     writeCavebotLog("ERROR", "reseting trieswalk limit")

                writeCavebotLog("Cavebot - WARNING", txt("Tentou andar manualmente mais de " cavebotSystemObj.triesWalkLimit " vezes até a coordenada", "Tried to walk manually more than " cavebotSystemObj.triesWalkLimit " times to coordinate") " x:" nextStepCoord.x ", y:" nextStepCoord.y)
                /**
                if the coordinate that failed to walk manually is the same of the waypoint, skip this waypoint
                */
                if (nextStepCoord.x = mapX && nextStepCoord.y = mapY) {
                    writeCavebotLog("Cavebot - WARNING", "Blocked coordinate is the same as current waypoint, skipping to next waypoint")
                    return false ; return = skip waypoint
                }

                break ; generate new path again
            }

            if (sucessWalk = false) {
                break
            } else {
                cavebotSystemObj.triesWalk := 1
                ; reset tries and go to next coord of nextStepCoord array
            }
            ; Sleep, 100 ; delay needed so it doesn't try to click on the next sqm on

        } ; loop walk path

    } ; loop setPath()

    return true
}

walkToCoord(coordX, coordY, triesWalk := 1) {
    if (checkArrivedOnCoord(mapX, mapY, mapZ, false) = true) ; cases where walked manually to a stair and change Z coordinate
        return true

    if (isDisconnected()) {
        Sleep, 2000
        return false
    }

    walkCoords := CavebotWalker.realCoordsToMinimapRelative(coordX, coordY)
    /**
    if the next step is the char sqm, will be 0
    */
    if (walkCoords.X = 0 && walkCoords.Y = 0)
        return true
    try
        SQM := CavebotWalker.getSQMByMinimapDirection(walkCoords.X, walkCoords.Y)
    catch e {
        writeCavebotLog("Cavebot Path ERROR",  e.Message, true)
        return false
    }

    /**
    can't use arrow keys here, because will fail to walk in diagonal
    and also arrow keys walk slower than clicking
    */
    CavebotWalker.clickOnSQM(SQM, "Left")
    if (CavebotSystem.searchSorryNotPossible() = true) {
        CavebotWalker.clickOnSQM(SQM, "Left")
    }

    realDelay := new _CavebotSettings().get("walkArrowDelay") + (isTibia13() = true ? 0 : 100)
    Sleep, % realDelay ;  little delay to wait for the char to move

    ; if (triesWalk > 10)
    ;     writeCavebotLog("Cavebot", "[" triesWalk "/" cavebotSystemObj.triesWalkLimit "] " txt("Caminhando pelas setas até o SQM ", "Walking arrow keys to SQM ") SQM ", x:" coordX ", y:" coordY ", delay: " realDelay "ms")
    ; else
    writeCavebotLog("Cavebot", txt("Caminhando pelas setas até o SQM ", "Walking arrow keys to SQM ") SQM ", x:" coordX ", y:" coordY ", delay: " realDelay "ms")

    Loop, % isTibia13() ? 4 : 8 {
        elapsed := getCharPos()
        if (isSameCharCoords(coordX, coordY, mapZ, false, A_ThisFunc, debug := false) = true)
            return true
        /**
        if character changed floor while walking by arrow
        return true
        */
        if (posz != mapZ)
            return true
        switch isTibia13() {
            case true:
                if (elapsed >= 35 && elapsed < 50)
                    Sleep, 10

                /**
                higher delay in OTClientV8
                */
            case false:
                if (isTibia13() = false)
                    Sleep, 50
        }
        ; Sleep, 25 ; delay needed because of slow characters
    }
    ; algo bloqueou o caminho e não conseguiu caminhar, voltar para gerar o path novamente?
    writeCavebotLog("Cavebot", txt("Não foi possível caminhar até o SQM: ", "Couldn't walk to SQM: ") coordX "," coordY " (" walkCoords.X "," walkCoords.Y ") (tries: " triesWalk "/" cavebotSystemObj.triesWalkLimit ")")

    /**
    drag the mouse of the coordinate destination sqm in case it's a player
    will drag from the destination sqm to a random sqm in the same sqm row
    */
    sqmDragDist := SQM_SIZE
    Random, randomSQM, 1, 3
    switch SQM {
        case 4: ; <= vertical
            pushSmqs := {1: 1, 2: 4, 3: 7}, randomSqmY := pushSmqs[randomSQM]
            writeCavebotLog("Cavebot", txt("Arrastando(push) do SQM " SQM " para " randomSqmY, "Dragging(push) from SQM " SQM " to "  randomSqmY) )
            MouseDrag(SQM%SQM%X, SQM%SQM%Y, SQM%SQM%X - sqmDragDist, SQM%randomSqmY%Y)
        case 6: ; => vertical
            pushSmqs := {1: 3, 2: 6, 3: 9}, randomSqmY := pushSmqs[randomSQM]
            writeCavebotLog("Cavebot", txt("Arrastando(push) do SQM " SQM " para " randomSqmY, "Dragging(push) from SQM " SQM " to "  randomSqmY) )
            MouseDrag(SQM%SQM%X, SQM%SQM%Y, SQM%SQM%X + sqmDragDist, SQM%randomSqmY%Y)
        case 2: ; \/ horizontal
            pushSmqs := {1: 1, 2: 2, 3: 3}, randomSqmX := pushSmqs[randomSQM]
            writeCavebotLog("Cavebot", txt("Arrastando(push) do SQM " SQM " para " randomSqmX, "Dragging(push) from SQM " SQM " to "  randomSqmX) )
            MouseDrag(SQM%SQM%X, SQM%SQM%Y, SQM%randomSqmX%X, SQM%SQM%Y + sqmDragDist)
        case 8: ; /\ horizontal
            pushSmqs := {1: 7, 2: 8, 3: 9}, randomSqmX := pushSmqs[randomSQM]
            writeCavebotLog("Cavebot", txt("Arrastando(push) do SQM " SQM " para " randomSqmX, "Dragging(push) from SQM " SQM " to "  randomSqmX) )
            MouseDrag(SQM%SQM%X, SQM%SQM%Y, SQM%randomSqmX%X, SQM%SQM%Y - sqmDragDist)
    }

    /**
    Delay to be able to drag players
    TO DO: search for life bar
    */
    if (OldBotSettings.settingsJsonObj.clientFeatures.walkThroughPlayers = false)
        Sleep, 1050
    return false
}

setPathTimer:
    if (cavebotSystemObj.setPathTimer < 1)
        cavebotSystemObj.setPathTimer := 1
    cavebotSystemObj.setPathTimer += 1
    ; writeCavebotLog("setPath", """" cavebotSystemObj.setPathTimer, true)
return

restoreTargetingIcon() {
    if (TargetingEnabled = 1) {
        try PostMessage,0x40F, targetingPart - 1,,, ahk_id %hSB% ; SB_SETICON
        catch {
        }
    } else {
        if (targetingSystemObj.targetingDisabled = true) {
            SB_SetIcon(disabledIconDll, 208, targetingPart)
            targetingSystemObj.targetingDisabledIcon := false
        } else {
            SB_SetIcon(disabledIconDll, disabledIconNumber, targetingPart)
        }
    }

    targetingSystemObj.targetingIgnoredIcon := false
        , targetingSystemObj.targetingDisabledActionIcon := false
        , targetingSystemObj.targetingDisabledIcon := false
}

getCharPos(firstTryCavebot := false) {
    Sleep, 10
    /**
    wait for battle list empty check timer to finish before getting char position
    to avoid multi threading using gdip imagesearch, that causes crash (unlockbits "bbb")

    dont remove those whiles! or will cause or increase the chances of causing error
    */
    t1charpos := A_TickCount
    While (targetingSystemObj.blockThreadCavebot = true) {
        writeCavebotLog("Cavebot", "Waiting Targeting..")
        Sleep, 10
    }
    While (targetingSystemObj.threadReleaseTargeting = true) {
        writeCavebotLog("Cavebot", "Waiting Targeting release..")
        Sleep, 10
    }
    While (targetingSystemObj.threadLureMode = true) {
        writeCavebotLog("Cavebot", "Waiting Targeting lure mode..")
        Sleep, 10
    }
    Critical, On
    cavebotSystemObj.gettingCharPos := true
    try {
        CavebotWalker.getCharCoords(false, firstTryCavebot)
    } catch e {
        Critical, Off
        writeCavebotLog("ERROR", e.Message)
    } finally {
        Critical, Off
        cavebotSystemObj.gettingCharPos := false
        elapsedCharPos := A_TickCount -  t1charpos
        if (elapsedCharPos <= 25)
            Sleep, 25
        else if (elapsedCharPos <= 35)
            Sleep, 15
        Random, R, 0, 10 ; randomize the result a bit to differenciate visually everytime it checks
        Gui, CavebotLogs:Default
        stringOffset := CavebotWalker.offsetReseted1 = true ? "*" : ""
        SB_SetText(posx "," posy "," posz " " elapsedCharPos + R " (" CavebotWalker.triesGetCharPos "|" CavebotWalker.indexMinimapArea ")" stringOffset, charPositionPart)
    }

    return A_TickCount - t1charpos
}

isSameCharCoords(isSameCoordX, isSameCoordY, isSameCoordZ, log := false, funcCalling := "", debug := false) {
    if (CavebotScript.isMarker())
        return CavebotWalker.isSameCharisSameCoordsMarker()

    if (log = true)
        writeCavebotLog("Cavebot", isSameCoordX ","  isSameCoordY ","  isSameCoordZ " | " posx ","  posy ","  posz " @ " funcCalling)

    if (posx = isSameCoordX && posy = isSameCoordY && posz = isSameCoordZ) {
        return true
    }
    return false
}

checkArrivedOnCoord(checkCoordX := "", checkCoordY := "", checkCoordZ := "", getPos := true, setArrived := true) {
    if (CavebotScript.isMarker())
        return _CavebotByImage.checkArrivedOnMarker()

    if (getPos = true)
        getCharPos()

    if (posz != checkCoordZ) {
        writeCavebotLog("Cavebot", txt("Coordenada Z diferente", "different Z coordinate") " (" posz "/" mapZ ")")
        return CavebotSystem.setArrivedWaypoint(setArrived)
    }

    /**
    added on 27/10/22
    if the coords is in the blocked coordinates, consider arrived
    */
    if (cavebotSystemObj.blockedCoordinates[checkCoordX, checkCoordY, checkCoordZ] = true) {
        return CavebotSystem.setArrivedWaypoint(setArrived)
    }

    if (waypointsObj[tab][Waypoint].type = "") {
        if (setArrived = true)
            cavebotSystemObj.waypoints[tab][Waypoint].arrived := true
        if (!A_IsCompiled)
            writeCavebotLog("ERROR", "Empty waypoint type, tab: " tab ", Waypoint: " Waypoint)
        return true
    }

    switch waypointsObj[tab][Waypoint].type {
        case "Stand":
            arrived := isSameCharCoords(checkCoordX, checkCoordY, checkCoordZ, log := false, A_ThisFunc)
            if (arrived = true) && (setArrived = true) {
                cavebotSystemObj.waypoints[tab][Waypoint].arrived := true
            }
            return arrived

        case "Walk", case "Action":
            if (isSameCharCoords(checkCoordX, checkCoordY, checkCoordZ, log := false, A_ThisFunc) = true)
                return CavebotSystem.setArrivedWaypoint(setArrived)

            rangeWidth := waypointsObj[tab][Waypoint].rangeX
                , rangeHeight := waypointsObj[tab][Waypoint].rangeY

            if (CavebotWalker.isInWaypointRange(checkCoordX, checkCoordY, rangeWidth, rangeHeight) = true)
                return CavebotSystem.setArrivedWaypoint(setArrived)
            return false

        case "Ladder", case "Ladder Up", case "Ladder Down", case "Stair Up", case "Stair Down", case "Use", case "Door", case "Rope", case "Shovel", case "Machete":
            if (CavebotWalker.isInRangeArea(posx, checkCoordX - 1, checkCoordX + 1)) && (CavebotWalker.isInRangeArea(posy, checkCoordY - 1, checkCoordY + 1)) {
                return CavebotSystem.setArrivedWaypoint(setArrived)
            }
            return false
    }
    return false
}

Action_UseItem(sqmPosArray, Item) {
    if (sqmPosArray = false)
        return false

    HotkeyItem := scriptSettingsObj["itemHotkeys"][Item "Hotkey"]
    if (HotkeyItem = "") {
        writeCavebotLog("ERROR", "Empty hotkey to use item: " Item)
        return false
    }

    Loop, 1 {
        writeCavebotLog("Cavebot", "Using " Item " [hotkey: " HotkeyItem "]")
        Send(HotkeyItem)
        Sleep, 100
        MouseClick("Left", sqmPosArray.x, sqmPosArray.y, false)
        Sleep, 800
    }
    return true
}

getActionSQM() {
    coordsSQM := CavebotWalker.realCoordsToMinimapRelative(mapX, mapY)
    try SQM := CavebotWalker.getSQMByMinimapDirection(coordsSQM["X"], coordsSQM["Y"])
    catch e {
        writeCavebotLog("ERROR", e.Message, true)
        return false
    }
    if (SQM < 1) {
        writeCavebotLog("ERROR","Wrong SQM for action(" SQM ")", true)
        return false
    }
    return SQM
}

setCavebotFloorLevel:
    Gui, minimapViewerCavebotGUI:Destroy
    posz := MinimapGUI.viewerZ
    MinimapGUI.waitingMapViewerFloor := false
return

LureModeTimerAttackTimer:
    TargetingSystem.lureModeTimerAttack()
return
