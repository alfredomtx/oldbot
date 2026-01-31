
/**
* Convert a real coord of Tibia Map to a relative position of the screen(screen width and height) to click on the minimap.
* @return _Coordinate
* @throws
*/
realCoordsToMinimapScreen(coordX := "", coordY := "")
{
    static minimapArea
    if (!minimapArea) {
        minimapArea := new _MinimapArea()
    }

    _Validation.empty("coordX", coordX)
    _Validation.empty("coordY", coordY)

    if (CavebotWalker.isCoordVisibleMinimap(coordX, coordY) = false) {
        throw Exception(txt("Coordenadas não visíveis(clicáveis) no minimapa(muito longe)", "Coordinates not visible(clickable) on minimap(too far)"), "CoordNotVisible")
    }

    coords := new _Coordinate()
        , distanceX := coordX - posx
        , distanceY := coordY - posy

    ; minimapArea.getCenter().debug()

    if (distanceX < 0)
        coords.setX(minimapArea.getCenter().getX() - abs(distanceX))
    else
        coords.setX(minimapArea.getCenter().getX() + distanceX)

    if (distanceY < 0)
        coords.setY(minimapArea.getCenter().getY() - abs(distanceY))
    else
        coords.setY(minimapArea.getCenter().getY() + distanceY)

    if (isTibia13() = true) {
        coords.subY(1) ; diminuir 1 px no y para clicar corretamente no SQM
    } else {
        coords.addX(CavebotSystem.cavebotJsonObj.coordinates.offsetClickX)
        coords.addY(CavebotSystem.cavebotJsonObj.coordinates.offsetClickY)
    }

    if (coords.X < 0)
        throw Exception("Invalid X coordinate. Coord: " coordX " (" coords.X ")")
    if (coords.Y < 0)
        throw Exception("Invalid Y coordinate. Coord: " coordY " (" coords.Y ")")

    return coords
}


realCoordsToMinimapRelative(coordX, coordY)
{
    return {"X": coordX - posx, "Y": coordY - posy}
}


/**
calculate how many sqms away from the char is a position of the screen
return the amount of x and y sqms
*/
getSqmDistanceByScreenPos(screenPosX, screenPosY)
{
    static charPosition
    if (!charPosition) {
        charPosition := new _CharPosition()
    }

    return new _Coordinate(charPosition.getX(),  charPosition.getY())
        .subX(screenPosX)
        .subY(screenPosY)
        .div(new _GameWindowArea().getSqmSize())
}



tryToGetNewMemoryAddresses()
{
    if (OldBotSettings.settingsJsonObj.settings.cavebot.getCharCoordinatesFromMemory != true)
            OR (scriptSettingsObj.charCoordsFromMemory = false)
        return false

    ; m(A_ThisFunc)
    MemoryManager.clientName := TibiaClient.getClientIdentifier(true)
    MemoryManager.findClientMemory(false, false)
    if (!A_IsCompiled) {
        msgbox, 64, % "Files read", % MemoryManager.filesRead
    }
    return true
}

now()
{
    return A_Year "-" A_MM "-" A_DD " " A_Hour ":" A_Min ":" A_Sec
}

/**
* @return bool
*/
isRubinot()
{
    static value
    if (value = "") {
        value := clientIdentifier() = "Rubinot RTC"
    }

    return value
}