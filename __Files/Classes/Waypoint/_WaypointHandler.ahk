
global defaultWaypointAtributes
defaultWaypointAtributes := {}
defaultWaypointAtributes.Push("type")
defaultWaypointAtributes.Push("label")
defaultWaypointAtributes.Push("coordinates")
defaultWaypointAtributes.Push("rangeX")
defaultWaypointAtributes.Push("rangeY")
defaultWaypointAtributes.Push("action")
defaultWaypointAtributes.Push("marker")
defaultWaypointAtributes.Push("image")
defaultWaypointAtributes.Push("sqm")


global actionScriptsVariablesObj := {}


Class _WaypointHandler extends _WaypointValidation
{
    __New()
    {

        this.loadWaypointSettings()

        this.minimapZoomAdjusted := false

    }

    loadWaypointSettings() {
        this.checkMainTabExists()
        this.validateScriptWaypoints()
        this.createActionScriptsVariablesObj()
    }


    validateScriptWaypoints() {
        for tabName, tabWaypoints in waypointsObj
        {
            for waypointNumber, waypointAtributes in tabWaypoints
            {
                ; msgbox, % serialize(waypointsObj[tabName][waypointNumber])
                if (waypointsObj[tabName][waypointNumber]["range"]) {
                    range := this.getRangeOldformat(waypointNumber, tabName)
                    waypointsObj[tabName][waypointNumber]["rangeX"] := range.X
                    waypointsObj[tabName][waypointNumber]["rangeY"] := range.Y
                    waypointsObj[tabName][waypointNumber].delete("range")
                }
                waypointsObj[tabName][waypointNumber]["rangeX"] := this.getFixedRangeAtribute(waypointAtributes.type, waypointAtributes.rangeX)
                    , waypointsObj[tabName][waypointNumber]["rangeY"] := this.getFixedRangeAtribute(waypointAtributes.type, waypointAtributes.rangeY)

                waypointsObj[tabName][waypointNumber]["rangeX"] += 0
                waypointsObj[tabName][waypointNumber]["rangeY"] += 0


                ; remove action of non "action" type waypoints
                if (waypointAtributes.type != "Action" && waypointAtributes.action != "")
                    waypointsObj[tabName][waypointNumber].action := ""
            }
        }
    }

    checkMainTabExists() {
        if (!waypointsObj["Waypoints"]) {
            waypointsObj["Waypoints"] := {}
            this.saveWaypoints(false, A_ThisFunc)
        }
    }

    getAtributes(waypointNumber, tabName := "") {
        tabName := this.setTabName(TabName)

        atributes := {}

        for key, atribute in defaultWaypointAtributes
        {
            atributes[atribute] := this.getAtribute(atribute, waypointNumber, tabName)
        }
        ; msgbox, % serialize(atributes)

        return atributes

    }

    /**
    save "waypointsObj" scriptFile.waypoints section
    */
    saveWaypoints(saveCavebotScript := true, origin := "") {
        if (waypointsObj = "") {
            Msgbox, 16,, % "Empty waypoints settings to save, origin: " origin
            return
        }
        scriptFile.waypoints := waypointsObj
        if (saveCavebotScript = true)
            CavebotScript.saveSettings(A_ThisFunc (origin != "" ? " => " origin : ""))
    }

    getRangeOldformat(waypointNumber, tabName, rangeAtribute := "") {
        if (rangeAtribute = "")
            rangeStr := StrSplit(waypointsObj[tabName][waypointNumber]["range"], "x")
        else
            rangeStr := StrSplit(rangeAtribute, "x")
        return {X: StrReplace(rangeStr.1, " ", ""), Y: StrReplace(rangeStr.2, " ", "")}
    }

    getDisplayRangeSize(waypointNumber, tabName) {
        return waypointsObj[tabName][waypointNumber].rangeX " x " waypointsObj[tabName][waypointNumber].rangeY
    }

    getFixedRangeAtribute(type, rangeValue) {
        switch type {
            case "Stand", case "Door", case "Ladder", case "Ladder Up", case "Ladder Down", case "Stair Up", case "Stair Down", case "Use", case "Rope", case "Shovel", case "Machete":
                return 1
            default:
                if (rangeValue < 1)
                    rangeValue := 1
                if (rangeValue > 500)
                    rangeValue := 500
        }
        return rangeValue
    }

    getAtribute(atribute, waypointNumber, tabName := "") {
        tabName := this.setTabName(TabName)
        ; msgbox, % A_ThisFunc
        if (this.checkWaypointExists(tabName, waypointNumber) = false) {
            ; if (!A_IsCompiled)
            ; Msgbox, 16,, Waypoint: %waypointNumber%`ntab: %tabName% doesn't exist.
            return
        }
        if (waypointsObj[tabName][waypointNumber].HasKey(atribute) = false) {
            ; if (!A_IsCompiled)
            ; Msgbox, 16,, Waypoint: %waypointNumber%`Ntab: %tabName%`natribute:%atribute% doesn't exist.
            return
        }
        ; msgbox, % waypointsObj[tabName][waypointNumber][atribute]

        return waypointsObj[tabName][waypointNumber][atribute]
    }

    isCharPosOK()
    {
        return empty(posx) OR empty(posy) OR empty(posz) ? false : true
    }

    getLastWaypoint(tabName := "") {
        tabName := this.setTabName(TabName)
        return waypointsObj[tabName].Count()
    }

    setTabName(tabName := "") {
        return tabName = "" ? tab : tabName
    }

    duplicateWaypoints(tabName := "") {
        tabName := this.setTabName(TabName)
        try selectedWaypoints := this.getSelectedWaypoints()
        catch e
            return

        ; m(serialize(selectedWaypoints))
        OldBotSettings.disableGuisLoading()

        for key, waypointNumber in selectedWaypoints
        {
            ; m("insert at: " selectedWaypoints[selectedWaypoints.MaxIndex()] + A_Index "`nwaypointNumber = " waypointNumber ", that is: " selectedWaypoints[key])

            dupWaypointObj := ""
            dupWaypointObj := {}
            for key2, value in waypointsObj[tabName][selectedWaypoints[key]]
            {
                ; msgbox,% key2 ", " value
                dupWaypointObj[key2] := value
            }
            /**
            if has only one waypoint selected, add next to the selected waypoint
            if has more than one, add at the end
            */
            if (selectedWaypoints.Count() = 1)
                waypointsObj[tabName].InsertAt(selectedWaypoints[1] + A_Index, dupWaypointObj)
            else
                waypointsObj[tabName].Push(dupWaypointObj)
        }

        ; msgbox, % "c " waypointOrigin " / " waypointDest "`n" serialize(waypointsObj)
        this.saveWaypoints(true, A_ThisFunc)

        CavebotGUI.loadLV()

        if (selectedWaypoints.Count() = 1) {
            _ListviewHandler.selectRow(LV_Waypoints_%tabName%, selectedWaypoints[1] + 1)
        } else {
            index := 0
            Loop, % selectedWaypoints.Count() {
                _ListviewHandler.selectRow(LV_Waypoints_%tabName%, waypointsObj[tabName].Count() - index)
                index++
            }
        }

        OldBotSettings.enableGuisLoading()
    }

    duplicate(tabName := "") {
        tabName := this.setTabName(TabName)
        waypointNumber :=  _ListviewHandler.getSelectedItemOnLV("LV_Waypoints_" tabName, 1)
        if (waypointNumber = "" OR waypointNumber = "WP") {
            Msgbox,64,, % LANGUAGE = "PT-BR" ? "Selecione um waypoint para duplicar." : "Select a waypoint to duplicate."
            return
        }
        this.moveWaypoint(waypointNumber, tabName, true)
        CavebotGUI.loadLV()
        _ListviewHandler.selectRow(LV_Waypoints_%tabName%, waypointNumber + 1)
    }

    getSelectedWaypoints(msgbox := true) {
        try selectedWaypoints := _ListviewHandler.getSelectedRowsNumbersLV("LV_Waypoints_" tab, 1)
        catch e {
            if (msgbox) {
                msgbox,48,, % txt("Selecione pelo menos um waypoint.", "Select at least one waypoint."), 6
            }
            return
        }
        return selectedWaypoints

    }

    deleteWaypoints() {
        try selectedWaypoints := this.getSelectedWaypoints()
        catch e
            return

        index := 0
        loop, % selectedWaypoints.MaxIndex() {
            this.delete(selectedWaypoints[selectedWaypoints.MaxIndex() - index], tab, false)
            index++
        }
        CavebotGUI.loadLV(tab)

        if (selectedWaypoints.MaxIndex() = 1)
            _ListviewHandler.selectRow(LV_Waypoints_%tabName%, selectedWaypoints[1] - 1)

        this.saveWaypoints(true, A_ThisFunc)

        this.checkStartWaypoint()
        _CoordinateViewer.waypointChanged()
    }

    moveWaypointsToTab(tabOrigin, tabDest) {
        try selectedWaypoints := _ListviewHandler.getSelectedRowsNumbersLV(A_DefaultListview, 1)
        catch e {
            msgbox,48,, % "Select at least one waypoint."
            return
        }

        for key, waypointNumber in selectedWaypoints
        {
            this.add(this.getAtributes(waypointNumber, tabOrigin), tabDest)
        }

        index := 0
        loop, % selectedWaypoints.MaxIndex() {
            this.delete(selectedWaypoints[selectedWaypoints.MaxIndex() - index], tabOrigin, false)
            index++

        }

        this.saveWaypoints(true, A_ThisFunc)

        ; msgbox, % tabOrigin " / " tabDest
        CavebotGUI.loadLV(tabOrigin)
        CavebotGUI.loadLV(tabDest)
        _CoordinateViewer.waypointChanged()
    }

    moveWaypoint(waypointDest, tabName := "", duplicate := false, fromHotkey := false) {
        waypointOrigin :=  _ListviewHandler.getSelectedItemOnLV("LV_Waypoints_" tabName, 1)
        if (waypointOrigin = "" OR waypointOrigin = "WP")
            return
        if (waypointOrigin = "WP")
            return
        tabName := this.setTabName(TabName)
        if (waypointDest < 1)
            return
        lastWaypoint := this.getLastWaypoint()
        if (waypointDest > lastWaypoint)
            waypointDest := lastWaypoint + 1
        if (duplicate = false) && (waypointOrigin = waypointDest)
            return

        ; msgbox, % "a " waypointOrigin " / " waypointDest "`n" serialize(waypointsObj)
        waypointOriginAtributes := {}
        for attribute, value in waypointsObj[tabName][waypointOrigin]
        {
            waypointOriginAtributes[attribute] := value
        }
        ; msgbox, % "b " waypointOrigin " / " waypointDest "`n" serialize(waypointsObj)
        /**
        move up
        */
        if (waypointDest < waypointOrigin) {
            waypointsObj[tabName].InsertAt(waypointDest, waypointOriginAtributes)
            waypointsObj[tabName].RemoveAt(waypointOrigin + 1)
        }
        /**
        move down
        */
        if (waypointDest > waypointOrigin) {
            /**
            make the behaviour the same as moving up,
            if is dragging the same line won't move
            */
            if (fromHotkey = false)
                waypointDest--
            if (waypointDest = waypointOrigin)
                return

            pos := waypointDest + 1
            pos := pos > lastWaypoint + 1 ? lastWaypoint + 1 : pos
            waypointsObj[tabName].InsertAt(pos, waypointOriginAtributes)
            waypointsObj[tabName].RemoveAt(waypointOrigin)
        }
        /**
        duplicate
        */
        if (waypointDest = waypointOrigin)
            waypointsObj[tabName].InsertAt(waypointDest, waypointOriginAtributes)

        ; msgbox, % "c " waypointOrigin " / " waypointDest "`n" serialize(waypointsObj)
        this.saveWaypoints(true, A_ThisFunc)
        _CoordinateViewer.waypointChanged()
    }

    getCharPosition(fromHotkey := false, adjustMinimap := true, funcOrigin := "") {
        if (!OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection) {
            Gui, AddWaypointGUI:Default
            try GuiControlGet, currentFloorLevel
            catch {
            }
            Gui, CavebotGUI:Default
            posz := currentFloorLevel
            if (posz = "") {
                if (!A_IsCompiled)
                    Msgbox, 16,, % "Empty posz, origin: " funcOrigin
            }
        }

        TibiaClient.getClientArea()

        if (isDisconnected()) {
            throw Exception((LANGUAGE = "PT-BR" ? "O char deve estar logado para obter a posição do char." : "Char must be logged in to get the char position."))
        }

        if (fromHotkey = false)
            Gui, Show ; make the default window the top on again

        if (scriptSettingsObj.charCoordsFromMemory = false) {
            if (this.minimapZoomAdjusted = false) && (adjustMinimap = true) {
                CavebotSystem.adjustMinimap()
                if (!new _CavebotIniSettings().get("adjustMinimapAddWaypoint")) {
                    this.minimapZoomAdjusted := true
                }

                Sleep, 250
            }
        }

        try
            CavebotWalker.getCharCoords(true, false, funcOrigin = "" ? A_ThisFunc : funcOrigin)
        catch e
            throw e
    }

    getCharPositionAddWaypoint(type, selectedSQM, fromHotkey, rangeX, rangeY) {
        try {
            this.getCharPosition(fromHotkey, new _CavebotIniSettings().get("adjustMinimapAddWaypoint"))
        } catch e {
            throw e
        }

        if (this.isCharPosOK() = false) {
            this.getCharPosition(fromHotkey, new _CavebotIniSettings().get("adjustMinimapAddWaypoint"))
            if (this.isCharPosOK() = false) {
                if (isMemoryCoordinates()) {
                    _CharCoordinate.throwInvalidMemoryCoordinatesException(posz)
                } else {
                    if (OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection = true)
                        throw Exception((LANGUAGE = "PT-BR" ? "Erro ao detectar a posição do char, confirme se o minimapa está no zoom 2 e tente novamente." : "Error getting char position, ensure that the minimap is on zoom 2 and try again.") "`nx: " posx ", y: " posy ", z: " posz)
                    else
                        throw Exception((LANGUAGE = "PT-BR" ? "Erro ao detectar a posição do char, certifique-se de que você setou corretamente o ""Floor Level"" manualmente e tente novamente." : "Error getting char position, ensure that the you set correctly the ""Floor level"" manually and try again.") "`nx: " posx ", y: " posy ", z: " posz)
                }
            }
        }

        switch selectedSQM {
            case "1": posx -= 1, posy += 1
            case "2": posx -= 0, posy += 1
            case "3": posx += 1, posy += 1
            case "4": posx -= 1, posy -= 0
            case "5": posx -= 0, posy -= 0
            case "6": posx += 1, posy -= 0
            case "7": posx -= 1, posy -= 1
            case "8": posx -= 0, posy -= 1
            case "9": posx += 1, posy -= 1
        }

        if (type = "Walk") {
            this.adjustSqmWithCenteredRange(selectedSQM, rangeX, rangeY)
        }
    }

    /**
    * @param int rangeX
    * @param int rangeY
    * @param int selectedSQM
    * @return void
    */
    adjustSqmWithCenteredRange(selectedSQM, rangeX, rangeY)
    {
        posx -= _CavebotWalker.getCenterRangeModifier(rangeX)
        posy -= _CavebotWalker.getCenterRangeModifier(rangeY)
    }

    addWaypointMarker(type, selectedSQM, markerNumber) {
        tabName := this.setTabName(TabName)
        try this.addWaypointMarkerValidation(tabName, type, selectedSQM, markerNumber)
        catch e
            throw e
    }

    AddImageWaypointMinimapMarker(type, selectedSQM, imageB64) {
        tabName := this.setTabName(TabName)
        try this.AddImageWaypointMinimapValidation(tabName, type, selectedSQM, imageB64)
        catch e
            throw e
    }

    addWaypoint(type, selectedSQM, rangeX, rangeY, tabName := "", fromHotkey := false, debug := false) {
        tabName := this.setTabName(TabName)

        try this.getCharPositionAddWaypoint(type, selectedSQM, fromHotkey, rangeX, rangeY)
        catch e
            throw e

        try this.addWaypointValidation(tabName, type, rangeX, rangeY)
        catch e
            throw e
    }

    addWaypointValidation(tabName, type, rangeX, rangeY) {
        waypointAtributesObj := this.createWaypointAtributesObj(type, rangeX, rangeY)
        try
            validation := WaypointValidation.validateWaypoint(waypointAtributesObj, tabName)
        catch e {
            addWaypointAnyway := false
            if (scriptSettingsObj.charCoordsFromMemory = true )
                    && (isNotTibia13()) {
                    addWaypointAnyway := true
            } else if (e.What = "NotWalkable" OR e.What = "TooFar") {
                ; clipboard := "https://tibiamaps.io/map#" posx "," posy "," posz ":2"
                gosub, minimapViewer

                ; if (OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection = true)
                ; text := "`n`nIf this position is not accurate, it could be due to differences in the minimap(or markers visible).`nTry to Generate the map again clicking in the ""Map viewer"" > ""Generate from Minimap folder"" button."
                MinimapGUI.cropFromMinimapImage(posx, posy, posz)

                Msgbox, 68,, % e.Message (LANGUAGE = "PT-BR" ? "`n`nAdicionar waypoint mesmo assim?" : "`n`nAdd waypoint anyway?")
                IfMsgBox, No
                {
                    posx := "", posy := "", posz := ""
                    GuiControl, minimapViewerGUI:, lastCharacterCoordinates, % (posz = "") ? "None" : "x: " posx ", y: " posy ", z: " posz
                    return
                }
                addWaypointAnyway := true
            }
            if (addWaypointAnyway = false)
                throw e
        }
        if (validation != "")
            throw Exception(validation)

        this.add(waypointAtributesObj, tabName)
        CavebotGUI.loadLV()
    }

    addWaypointMarkerValidation(tabName, type, selectedSQM, markerNumber) {
        waypointAtributesObj := this.createWaypointAtributesObj(type, 2, 2, markerNumber, selectedSQM)
        try
            validation := WaypointValidation.validateWaypoint(waypointAtributesObj, tabName)
        catch e {
        }
        if (validation != "")
            throw Exception(validation)

        this.add(waypointAtributesObj, tabName)
        CavebotGUI.loadLV()
    }

    AddImageWaypointMinimapValidation(tabName, type, selectedSQM, imageB64 := "") {
        if (imageB64 = "")
            throw Exception("Waypoint image is empty, add a image for the waypoint and try again.")

        waypointAtributesObj := this.createWaypointAtributesObj(type, 2, 2, markerNumber := "", selectedSQM, imageB64)
        try
            validation := WaypointValidation.validateWaypoint(waypointAtributesObj, tabName)
        catch e {
        }
        if (validation != "")
            throw Exception(validation)


        this.add(waypointAtributesObj, tabName)
        CavebotGUI.loadLV()
    }

    createWaypointAtributesObj(type, rangeX, rangeY, markerNumber := "", selectedSQM := "", imageB64 := "") {
        waypointAtributesObj := {}
            , waypointAtributesObj.type := type
            , waypointAtributesObj.label := ""
            , waypointAtributesObj.coordinates := {x: posx += 0, y: posy += 0, z: posz += 0}
            , waypointAtributesObj.rangeX := this.getFixedRangeAtribute(type, rangeX)
            , waypointAtributesObj.rangeX := waypointAtributesObj.rangeX += 0
            , waypointAtributesObj.rangeY := this.getFixedRangeAtribute(type, rangeY)
            , waypointAtributesObj.rangeY := waypointAtributesObj.rangeY += 0
            , waypointAtributesObj.action := ""

        if (markerNumber != "") {
            waypointAtributesObj.marker := markerNumber += 0
            waypointAtributesObj.delete("image")
            imageB64 := ""

        }
        if (selectedSQM != "")
            waypointAtributesObj.sqm := selectedSQM += 0
        if (imageB64 != "") {
            waypointAtributesObj.image := imageB64
            waypointAtributesObj.delete("marker")
        }

        return waypointAtributesObj
    }

    add(waypointAtributesObj, tabName, save := true) {
        nextWaypoint := this.getLastWaypoint(tabName) + 1

        ; m(serialize(waypointAtributesObj))
        ; msgbox, % tabName " / " nextWaypoint

        waypointsObj[tabName][nextWaypoint] := {type: waypointAtributesObj.type, label: waypointAtributesObj.label, coordinates: waypointAtributesObj.coordinates, rangeX: waypointAtributesObj.rangeX, rangeY: waypointAtributesObj.rangeY, action: waypointAtributesObj.action}

        if (waypointAtributesObj.marker != "")
            waypointsObj[tabName][nextWaypoint].marker := waypointAtributesObj.marker

        if (waypointAtributesObj.sqm != "")
            waypointsObj[tabName][nextWaypoint].sqm := waypointAtributesObj.sqm

        if (waypointAtributesObj.image != "")
            waypointsObj[tabName][nextWaypoint].image := waypointAtributesObj.image


        /**
        if the script is restricted and the User is adding this waypoint,
        add a flag to enable him to edit this Action Script
        */
        try ScriptRestriction.checkScriptRestriction(false)
        catch {
            if (ScriptRestriction.isScriptUser() = true)
                waypointsObj[tabName][nextWaypoint].actionAddedByUser := true
        }

        ; m(serialize(waypointsObj[tabName][netWaypoint]))
        ;
        if (save = true)
            this.saveWaypoints(true, A_ThisFunc)
    }

    findLabel(labelName, labelTabName := "") {
        result := {labelFound: false, waypointFound: "", tabFound: ""}

        if (labelTabName != "") {
            if (isNumber(labelName) && waypointsObj[labelTabName].HasKey(labelName)) {
                result.labelFound := true, result.waypointFound := labelName, result.tabFound := labelTabName
                return result
            }

            for waypointNumber in waypointsObj[labelTabName]
            {
                if (this.getAtribute("label", waypointNumber, labelTabName) = labelName) {
                    result.labelFound := true, result.waypointFound := waypointNumber, result.tabFound := labelTabName
                    return result
                }
            }
            return result
        }

        for tabName in waypointsObj
        {
            for waypointNumber in waypointsObj[tabName]
            {
                ; msgbox, % tabName " / " this.getAtribute("label", waypointNumber, tabName)
                if (this.getAtribute("label", waypointNumber, tabName) = labelName) {
                    result.labelFound := true, result.waypointFound := waypointNumber, result.tabFound := tabName
                    ; msgbox, % A_ThisFunc "/ " serialize(result)
                    return result
                }
            }
        }
        /**
        if the label is the name of a tab
        */
        if (result.labelFound = false) {
            for tabName, value in waypointsObj
            {
                if (labelName = tabName) {
                    result.labelFound := true
                    result.waypointFound := 1
                    result.tabFound := tabName
                }
            }
        }

        return result
    }

    editAtribute(atributeName, atributeValue, waypointNumber, tabName)
    {
        if (this.checkWaypointExists(tabName, waypointNumber) = false) {
            Msgbox, 48,, Waypoint: %waypointNumber%, tab: %tabName% doesn't exist.
            return
        }

        StringUpper,atributeName,atributeName,T

        switch atributeName {
            case "Type": StringUpper,atributeValue,atributeValue,T
            case "Coordinates": StringLower,atributeValue,atributeValue
            case "Range":
                if (InStr(atributeValue, "x")) {
                    range := this.getRangeOldformat(waypointNumber, tabName, atributeValue)
                    atributeValue := {}
                    atributeValue.rangeX := range.X
                    atributeValue.rangeY := range.Y
                } else {
                    ; if range is 1 number only instead of "N x N"
                    range := LTrim(RTrim(atributeValue))
                    atributeValue := {}
                    atributeValue.rangeX := range
                    atributeValue.rangeY := range
                }

        }

        validation := this.validateWaypointAtribute(atributeName, atributeValue, tabName, waypointNumber)

        if (validation != "")
            throw Exception(validation)

        switch atributeName {
                ; format the coords array
            case "Coordinates": atributeValue := this.formatCoordinatesValue(atributeValue)
            case "Action": atributeValue := this.formatActionToSave(atributeValue)
            case "Marker": waypointsObj[tabName][waypointNumber].Delete("image")
            case "Image": waypointsObj[tabName][waypointNumber].Delete("marker")

        }

        switch atributeName {
            case "Range":
                waypointsObj[tabName][waypointNumber]["rangeX"] := atributeValue.rangeX
                waypointsObj[tabName][waypointNumber]["rangeY"] := atributeValue.rangeY
            default:
                StringLower, atributeName, atributeName
                waypointsObj[tabName][waypointNumber][atributeName] := atributeValue
        }

        /**
        delete the `actionAddedByUser` if the type is not an action,
        so if it's a restricted script the user can't bypass the edition restriction by changing the type
        */
        if (atributeName = "Type") {
            waypointsObj[tabName][waypointNumber].Delete("actionAddedByUser")
        }

        this.saveWaypoints(true, A_ThisFunc)

        if (atributeName = "Action")
            this.createActionScriptsVariablesObj()


        _CoordinateViewer.waypointChanged()
    }



    getCoordFromString(whichCoord, coordinatesString) {
        coordStr := StrSplit(coordinatesString, ",")
        x := StrReplace(coordStr.1, "x:")
        x := StrReplace(x, " ", "")
        y := StrReplace(coordStr.2, "y:")
        y := StrReplace(y, " ", "")
        z := StrReplace(coordStr.3, "z:")
        z := StrReplace(z, " ", "")
        switch whichCoord {
            case "x": return x
            case "y": return y
            case "z": return z
        }
    }

    edit(waypointAtributesObj, waypointNumber, tabName) {
        ; msgbox, % "aa" serialize(waypointAtributesObj)
        if (this.checkWaypointExists(tabName, waypointNumber) = false) {
            Msgbox, 16,, Waypoint: %waypointNumber%, tab: %tabName% doesn't exist.
            return
        }
        waypointsObj[tabName][waypointNumber] := {type: waypointAtributesObj.type, label: waypointAtributesObj.label, coordinates: waypointAtributesObj.coordinates, rangeX: waypointAtributesObj.rangeX, rangeY: waypointAtributesObj.rangeY, action: waypointAtributesObj.action}

        this.saveWaypoints(true, A_ThisFunc)
    }

    checkStartWaypoint() {
        ; if the waypoint doesn't exist
        if (!waypointsObj[startTab][startWaypoint]) {
            CavebotScript.removeStartWaypoint()
        }
    }

    delete(waypointNumber, tabName, save := true) {
        if (this.checkWaypointExists(tabName, waypointNumber) = false) {
            ; Msgbox, 16,, Waypoint: %waypointNumber%, tab: %tabName% doesn't exist.
            return
        }

        waypointsObj[tabName].RemoveAt(waypointNumber)

        if (save = true)
            this.saveWaypoints(true, A_ThisFunc)
    }

    checkTabExists(tabName) {
        return waypointsObj.HasKey(tabName)
    }

    checkWaypointExists(tabName, waypointNumber) {
        return waypointsObj[tabName].HasKey(waypointNumber)
    }

    createActionScriptsVariablesObj() {

        if (!IsObject(ActionScriptHandler)) {
            msgbox, 16, % A_ThisFunc, % "ActionScriptHandler not initialized."
            return
        }

        for tabName in waypointsObj
        {
            actionScriptsVariablesObj[tabName] := {}
            for waypointNumber in waypointsObj[tabName]
            {
                if (this.getAtribute("type", waypointNumber, tabName) != "Action")
                    continue
                actionScriptsVariablesObj[tabName][waypointNumber] := {}
                    , ArrayVars := StrSplit(StrReplace(this.getAtribute("action", waypointNumber, tabName), "`n", "<br>"), "<br>")

                ActionScriptHandler.setActionScriptsVariablesObjValues(ArrayVars, tabName, waypointNumber)
            } ; for waypointNumber in waypointsObj[tabName]
        }

        ; msgbox, % serialize(actionScriptsVariablesObj)
    }


}