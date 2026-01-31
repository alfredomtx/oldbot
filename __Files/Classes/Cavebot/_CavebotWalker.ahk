
global lastCharCoords := {}

global posx
global posy
global posz
global lastRealCharPositions := {}
global timeWalkingWaypoint
global indexMinimapArea


global mapCoords

global stringCoords
global mapX
global mapY
global mapZ


global minimapFloorX
global minimapFloorY1
global minimapFloorY2

/*
bitmaps
*/

/*
Imagens amarelas do minimap
*/
global pBitmapPathFloor00
global pBitmapPathFloor01
global pBitmapPathFloor02
global pBitmapPathFloor03
global pBitmapPathFloor04
global pBitmapPathFloor05
global pBitmapPathFloor06
global pBitmapPathFloor07
global pBitmapPathFloor08
global pBitmapPathFloor09
global pBitmapPathFloor10
global pBitmapPathFloor11
global pBitmapPathFloor12
global pBitmapPathFloor13
global pBitmapPathFloor14
global pBitmapPathFloor15

global pBitmapPathFloorWC00
global pBitmapPathFloorWC01
global pBitmapPathFloorWC02
global pBitmapPathFloorWC03
global pBitmapPathFloorWC04
global pBitmapPathFloorWC05
global pBitmapPathFloorWC06
global pBitmapPathFloorWC07
global pBitmapPathFloorWC08
global pBitmapPathFloorWC09
global pBitmapPathFloorWC10
global pBitmapPathFloorWC11
global pBitmapPathFloorWC12
global pBitmapPathFloorWC13
global pBitmapPathFloorWC14
global pBitmapPathFloorWC15
/*
Imagens coloridas do minimap
*/
; global this.pBitmapGrayFloor

global pBitmapColoredFloor00
global pBitmapColoredFloor01
global pBitmapColoredFloor02
global pBitmapColoredFloor03
global pBitmapColoredFloor04
global pBitmapColoredFloor05
global pBitmapColoredFloor06
global pBitmapColoredFloor07
global pBitmapColoredFloor08
global pBitmapColoredFloor09
global pBitmapColoredFloor10
global pBitmapColoredFloor11
global pBitmapColoredFloor12
global pBitmapColoredFloor13
global pBitmapColoredFloor14
global pBitmapColoredFloor15


global pBitmapColoredFloorWC00
global pBitmapColoredFloorWC01
global pBitmapColoredFloorWC02
global pBitmapColoredFloorWC03
global pBitmapColoredFloorWC04
global pBitmapColoredFloorWC05
global pBitmapColoredFloorWC06
global pBitmapColoredFloorWC07
global pBitmapColoredFloorWC08
global pBitmapColoredFloorWC09
global pBitmapColoredFloorWC10
global pBitmapColoredFloorWC11
global pBitmapColoredFloorWC12
global pBitmapColoredFloorWC13
global pBitmapColoredFloorWC14
global pBitmapColoredFloorWC15

global pBitmapClientScreen
global elapsedCharPos

Class _CavebotWalker
{
    __New(loadMinimapFiles := false) {
        if (loadMinimapFiles = true) && (!IsObject(MinimapFiles))
            throw Exception("MinimapFiles not initialized.")

        this.Matrix := "0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1"
        global tibiaMapX1 := 31744
        global tibiaMapY1 := 30976

        ; msgbox, % MinimapFiles.mapWidth "\"  MinimapFiles.mapHeight

        global tibiaMapX2 := tibiaMapX1 + MinimapFiles.mapWidth
        global tibiaMapY2 := tibiaMapY1 + MinimapFiles.mapHeight

        this.walkByArrowLimit := 45
        this.walkByClickLimit := 45


        this.stairPixColor :=  "0xFFFF00"

        minimapWidth := 106
        minimapHeight := 109

        this.offsetDistW := minimapWidth * 2
        this.offsetDistH := minimapHeight * 2

        this.offsetObj := {}

        if (loadMinimapFiles = true) && (!FileExist(MinimapFiles.minimapTXTFilesFolder))
            throw Exception("Minimap folder doesn't exist.")

        if (!pToken)
            throw Exception("Gdip not initialized")

        if (loadMinimapFiles = true)
            this.loadMinimapFilesBitmaps()


        this.cityBoatPos := {}
        this.cityBoatPos["ankhrahmun"]       := {x: 33090, y: 32884, z: 6}
        this.cityBoatPos["ab'dendriel"]      := {x: 32733, y: 31668, z: 6}
        this.cityBoatPos["abdendriel"]       := {x: 32733, y: 31668, z: 6}
        this.cityBoatPos["carlin"]           := {x: 32387, y: 31820, z: 6}
        this.cityBoatPos["cormaya"]          := {x: 33288, y: 31956, z: 6} ; boat
        this.cityBoatPos["darashia"]         := {x: 33289, y: 32480, z: 6}
        this.cityBoatPos["edron"]            := {x: 33176, y: 31765, z: 6}
        this.cityBoatPos["farmine"]          := {x: 33025, y: 31551, z: 10} ; steamboat
        this.cityBoatPos["folda"]            := {x: 32045, y: 31580, z: 7}
        this.cityBoatPos["goroma"]           := {x: 32161, y: 32558, z: 6}
        this.cityBoatPos["grimvale"]         := {x: 33340, y: 31688, z: 7}
        this.cityBoatPos["gray island"]      := {x: 33196, y: 31984, z: 7}
        this.cityBoatPos["issavi"]           := {x: 33900, y: 31463, z: 6}
        this.cityBoatPos["kazordoon"]        := {x: 32659, y: 31959, z: 15} ; steamboat
        this.cityBoatPos["liberty bay"]      := {x: 32283, y: 32892, z: 6}
        this.cityBoatPos["port hope"]        := {x: 32528, y: 32784, z: 6}
        this.cityBoatPos["roshamuul"]        := {x: 33494, y: 32567, z: 7}
        this.cityBoatPos["senja"]            := {x: 32126, y: 31665, z: 7}
        this.cityBoatPos["shortcut"]         := {x: 33774, y: 31346, z: 6}
        this.cityBoatPos["svargrond"]        := {x: 32341, y: 31110, z: 6}
        this.cityBoatPos["oramond"]          := {x: 33479, y: 31985, z: 7}
        this.cityBoatPos["venore"]           := {x: 32955, y: 32024, z: 6}
        this.cityBoatPos["yalahar"]          := {x: 32816, y: 31272, z: 6}
    }

    loadMinimapFilesBitmaps() {
        this.pBitmapGrayFloor := {}

        Loop, 16 {
            index := A_Index - 1
            floorString := (StrLen(index) = 1) ? "0" index : index

            fileExist := true
            file := MinimapFiles.minimapTXTFilesFolder "\" floorString "-m.o"
            if (!FileExist(file)) {
                fileExist := false
                if (!InStr(floorString, "00"))
                    throw Exception(file " doesn't exist.`n`n" A_ThisFunc)
            }
            if (fileExist = true) {
                FileRead, base64, % file
                pBitmapColoredFloor%floorString% := GdipCreateFromBase64(base64)
                if (pBitmapColoredFloor%floorString% = "" OR pBitmapColoredFloor%floorString% = 0)
                    throw Exception("Error loading minimap (1/" floorString ")")
            }

            fileExist := true
            file := MinimapFiles.minimapTXTFilesFolder "\" floorString "-m-g.o"
            if (!FileExist(file)) {
                fileExist := false
                if (!InStr(floorString, "00"))
                    throw Exception(file " doesn't exist.`n`n" A_ThisFunc)
            }
            if (fileExist = true) {
                FileRead, base64, % file
                this.pBitmapGrayFloor[floorString] := GdipCreateFromBase64(base64)
                if (this.pBitmapGrayFloor[floorString] = "" OR this.pBitmapGrayFloor[floorString] = 0)
                    throw Exception("Error loading minimap (3/" floorString ")")
            }

            if (MinimapFiles.hasPathFiles = true) {
                fileExist := true
                file := MinimapFiles.minimapTXTFilesFolder "\" floorString "-p.o"
                if (!FileExist(file)) {
                    fileExist := false
                    if (!InStr(floorString, "00"))
                        throw Exception(file " doesn't exist.`n`n" A_ThisFunc)
                }
                if (fileExist = true) {
                    FileRead, base64, % file
                    pBitmapPathFloor%floorString% := GdipCreateFromBase64(base64)
                    if (pBitmapPathFloor%floorString% = "" OR pBitmapPathFloor%floorString% = 0)
                        throw Exception("Error loading minimap (5/" floorString ")")
                }
            }

            /**
            only floors that have some custom minimap image
            will exist on world change map files
            */
            file := MinimapFiles.minimapTXTFilesFolder "\" floorString "-m-wc.o"
            if (FileExist(file)) {
                FileRead, base64, % file
                pBitmapColoredFloor%floorString% := GdipCreateFromBase64(base64)
                if (pBitmapColoredFloor%floorString% = "" OR pBitmapColoredFloor%floorString% = 0)
                    throw Exception("Error loading minimap (2/" floorString ")")
            }

            file := MinimapFiles.minimapTXTFilesFolder "\" floorString "-m-wc-g.o"
            if (FileExist(file)) {
                FileRead, base64, % file
                this.pBitmapGrayFloorWC[floorString] := GdipCreateFromBase64(base64)
                if (this.pBitmapGrayFloorWC[floorString] = "" OR this.pBitmapGrayFloorWC[floorString] = 0)
                    throw Exception("Error loading minimap (4/" floorString ")")
            }

            if (MinimapFiles.hasPathFiles = true) {
                file := MinimapFiles.minimapTXTFilesFolder "\" floorString "-p-wc.o"
                if (FileExist(file)) {
                    FileRead, base64, % file
                    pBitmapPathFloorWC%floorString% := GdipCreateFromBase64(base64)
                    if (pBitmapPathFloorWC%floorString% = "" OR pBitmapPathFloorWC%floorString% = 0)
                        throw Exception("Error loading minimap (6/" floorString ")")
                }
            }

        }

    }

    checkinjectClientMemory() {
        static validated
        if (validated) {
            return
        }

        classLoaded("MemoryManager", MemoryManager)
        if (!IsObject(MemoryManager.mem)) {
            MemoryManager.injectClientMemory()
        }


        validated := true
    }

    getCharCoordinatesFromMemory() {
        this.checkinjectClientMemory()

        posx := MemoryManager.readPosX()
        posy := MemoryManager.readPosY()
        if (OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection = true)
            posz := MemoryManager.readPosZ()

        if (OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection = true) {
            try posz := this.getMinimapFloorLevelMemory()
            catch e
                throw e
        }

        this.checkIfCharCoordWasBlocked()
    }

    checkIfCharCoordWasBlocked() {
        if (cavebotSystemObj.blockedCoordinates[posx, posy, posz] = true)
            cavebotSystemObj.blockedCoordinates[posx][posy].Delete(posz)

        if (cavebotSystemObj.blockedCoordinatesByCreatures[posx, posy, posz] = true)
            cavebotSystemObj.blockedCoordinatesByCreatures[posx][posy].Delete(posz)
    }

    getCharCoords(addingWaypoint := false, firstTryCavebot := false, funcOrigin := "") {

        if (CavebotScript.isMarker())
            return

        if (scriptSettingsObj.charCoordsFromMemory = true)
            return this.getCharCoordinatesFromMemory()


        DEBUG := false
        this.DEBUG_FOUND := false
        DEBUG_SHOWFLOORMAP := false

        minimapArea := new _MinimapArea()

        if (!minimapArea.getX1())
            throw Exception("(3) No minimap area defined.")
        if (TibiaClientID = "")
            throw Exception("Empty TibiaClientID.")


        this.searchWorldChangeMap := false

        trySearchWorldChange:

        timesTried := 1
        this.offsetReseted1 := false
        this.checkResetOffset1()

        trySecondTime:
        ; timer := A_TickCount

        this.triesGetCharPos := 1
        /**
        try to get the char position 3 times, one with character offset(or entire map minus a little),
        2 the same and 3 and another with entire map as offset
        */
        Loop, % (firstTryCavebot = false ? 3 : 1) {

            ; if (this.triesGetCharPos < 3) {
            ;     this.triesGetCharPos++
            ;     continue
            ; }
            /**
            Sleep on the third try to fix situations where go down a start and the minimap
            part of the screen takes longer to update(redraw)
            */
            if (this.triesGetCharPos = 3)
                Sleep, % A_Index = 1 ? 150 : 100

            this.minimapBitmap.dispose()
            this.minimapBitmap := _BitmapEngine.getClientBitmap(new _MinimapArea().getCoordinates())

            try posz := this.getMinimapFloorLevel()
            catch e
                throw e


            ; Gdip_SetBitmapToClipboard(this.minimapBitmap)
            ; Msgbox, minimap to clipboard

            this.checkResetOffset2()
                , floorString := (StrLen(posz) = 1) ? "0" posz : posz
            ; if (this.pBitmapGrayFloor[floorString] = "" OR this.pBitmapGrayFloor[floorString] = 0)
            ; throw Exception("Error get char pos pbgf invalid.")

            if (DEBUG_SHOWFLOORMAP = true)
                this.saveBitmapToTempFile(this.pBitmapGrayFloor[floorString], true, true)

            this.offsetObj.X1 := (posx > 1) ? (posx - tibiaMapX1) - this.offsetDistH : 170
                , this.offsetObj.Y1 := (posy > 1) ? (posy - tibiaMapY1) - this.offsetDistW : 30
                , this.offsetObj.X2 := (posx > 1) ? (posx - tibiaMapX1) + this.offsetDistH : MinimapFiles.mapWidth - 330
                , this.offsetObj.Y2 := (posy > 1) ? (posy - tibiaMapY1) + this.offsetDistW : MinimapFiles.mapHeight - 30
                , this.offsetObj.X1 := this.offsetObj.X1 < 0 ? 0 : this.offsetObj.X1, this.offsetObj.Y1 := this.offsetObj.Y1 < 0 ? 0 : this.offsetObj.Y1, this.offsetObj.X2 := this.offsetObj.X2 > MinimapFiles.mapWidth ? MinimapFiles.mapWidth : this.offsetObj.X2, this.offsetObj.Y2 := this.offsetObj.Y2 > MinimapFiles.mapHeight ? MinimapFiles.mapHeight : this.offsetObj.Y2
            ; /\ check if positions are not over the limit
            /**
            in case it's the third trie, search with no offset
            this will happen in places that are near the edge of tibia's map, such as tortoises
            */
            if (this.triesGetCharPos = 3)
                this.offsetObj.X1 := 0, this.offsetObj.Y1 := 0, this.offsetObj.X2 := MinimapFiles.mapWidth, this.offsetObj.Y2 := MinimapFiles.mapHeight

            try searchResult := this.searchMinimap(floorString, firstTryCavebot, DEBUG)
            catch e
                throw e

            if (searchResult[1] != "")
                break
            this.triesGetCharPos++
        }

        this.indexMinimapArea := indexMinimapArea

        if (searchResult[1] = "") {

            if (isTibia13() = true) && (this.searchWorldChangeMap = false) && (this.pBitmapGrayFloorWC[floorString] != "") {
                this.searchWorldChangeMap := true
                /**
                check disconnected before searching again inthe world change map
                */
                if (isDisconnected())
                    throw Exception("Character disconnected.")
                goto, trySearchWorldChange
            }
            if (firstTryCavebot = true)
                return
            this.errorPositionNotFound()
        }

        foundX := searchResult[1], foundY := searchResult[2]
        calcPosX := (minimapArea.getCenterRelative().getX() - minimapCropImageArea%indexMinimapArea%["left"]), calcPosY := (minimapArea.getCenterRelative().getY() - (minimapCropImageArea%indexMinimapArea%["up"] + 6))
            , posx := tibiaMapX1 + foundX + calcPosX + (CavebotSystem.cavebotJsonObj.coordinates.offsetX)
            , posy := tibiaMapY1 + foundY + calcPosY + (CavebotSystem.cavebotJsonObj.coordinates.offsetY)

        if (posx < tibiaMapX1 OR posy < tibiaMapY1) OR (posx > tibiaMapX2 OR posy > tibiaMapY2) {
            this.screenshotErrorCharPosition()
            throw Exception("Wrong character position detected, x: " posx ", y: " posy ", please contact support. Screenshot saved on Data\Screenshots\_ERROR_GetCharPosition" Number ".png")
        }

        if (this.DEBUG_FOUND = true) {
            Clipboard := posx "," posy "," posz
            msgbox, % posx "," posy "," posz
        }


        ; pegar as ultimas 10 posições do array antigo
        if (lastRealCharPositions.Count() > 200) {
            lastRealCharPositionsNew := {} ; novo array que irá guardar as ultimas posições
            Loop, 10
                index := lastRealCharPositions.Count() - A_Index, lastRealCharPositionsNew.Push(lastRealCharPositions[index])
            lastRealCharPositions := {}, lastRealCharPositions := lastRealCharPositionsNew
        }

        lastRealCharPositions.Push(Object("X", posx, "Y", posy, "Z", posz))
        /**
        checar se houve uma distance de maior de 200 sqms entre a ultima posição
        */
        if (lastRealCharPositions.Count() < 2) OR (addingWaypoint = true) {
            return
        }

        index := lastRealCharPositions.Count() - 1
            , lastX := lastRealCharPositions[index]["X"], lastY := lastRealCharPositions[index]["Y"], lastZ := lastRealCharPositions[index]["Z"]
        try this.isWaypointTooFar(lastX, lastY, lastZ, posx, posy, posz, ignoreZ := true, true, false)
        catch e {
            ; msgbox, % "timesTried = " timesTried "`n`n" lastX "," lastY "," lastZ  "`n" posx "," posy "," posz "`n`n" serialize(lastRealCharPositions)
            /**
            try to get the char position a second time in case the current position got is too far from the last one
            this can happen usually when going up/down a floor and bugging the char position
            */
            if (timesTried = 1) {
                timesTried++
                /**
                delete the probably wrong new position and
                */
                lastRealCharPositions.Delete(lastRealCharPositions.Count())
                writeCavebotLog("Char pos", "Last position too far from current, checking again, last pos: " lastX "," lastY "," lastZ " | new pos: " posx "," posy "," posz)
                /**
                set the char pos to the last valid position
                */
                ; posx := lastX, posy := lastY, posz := lastZ
                /**
                changed on 02/03/2021
                reset char position to reset offset, because of trouble in fire teleport when going to feyrist
                */
                posx := "", posy := ""
                ; msgbox, % "timesTried = " timesTried "`n`n" lastX "," lastY "," lastZ  "`n" posx "," posy "," posz "`n`n" serialize(lastRealCharPositions)
                /**
                in cases where is changing ground, sleep a bit before searching again, DONT DECREASE
                */
                Sleep, 500 ; 500 instead of 400 to see if improves problems when changing grounds bugging character position
                goto, trySecondTime
            }
            throw e
        }

        this.checkIfCharCoordWasBlocked()

    }

    errorPositionNotFound() {
        ; this.screenshotErrorCharPosition()
        ; throw Exception("Fail to get character position, it happens due to differences in the minimap. Generate the map again clicking in the ""Map viewer"" > ""Generate from Minimap folder"" button. Screenshot saved on Data\Screenshots\_ERROR_GetCharPosition" Number ".png", "errorGetCharPos")
        throw Exception((LANGUAGE = "PT-BR" ? "Falha para encontrar as coordenadas do personagem, isso acontece devido a diferenças no minimapa(ou há marcadores visíveis nesse local). Gere o mapa novamente clicando no botão ""Map viewer"" > ""Generate from Minimap folder""." : "Fail to get character coordinates, it happens due to differences in the minimap(or there are markers visible in this location). Generate the map again clicking in the ""Map viewer"" > ""Generate from Minimap folder"" button."), "errorGetCharPos")
    }

    screenshotErrorCharPosition() {
        Path := "Data\Screenshots\_ERROR_GetCharPosition*.png", Number := 1
        Loop, %Path%
            Number++
        ScreenshotTela("_ERROR_GetCharPosition" Number, true)

    }

    searchMinimap(floorString, firstTryCavebot, debug := false)
    {
        minimapArea := new _MinimapArea()

        ; search for 10 small pieces of the minimap
        Loop, 11 {
            /**
            minimap indexes 10 and 11 can only be searched in floor 7 and tries 2 or 3

            those 2 index were used just because of the cupcake event in edron due to the house location
            now it can be disabled.

            original condition:
            if (A_Index > 9) && (this.triesGetCharPos != 3 OR floorString != "07")
            continue
            */
            if (A_Index > 9)
                continue
            if (A_Index = 2) ; skip minimap area 2
                continue
            ; if (A_Index = 6) ; skip 6 also
            ; continue

            if (this.triesGetCharPos = 3)
                Sleep, 100

            switch A_Index {
                    ; swap 4 for 8
                case 4: indexMinimapArea := 8
                case 8: indexMinimapArea := 4
                    ; swap 5 for 9
                case 5: indexMinimapArea := 9
                case 9: indexMinimapArea := 5
                default: indexMinimapArea := A_Index
            }
            ; if indexMinimapArea in 8,9,6,4,5
            ; continue


            this.triesIndexMinimap := 1

            searchIndexAgain:
            /**
            for some reason, the pBitmapMinimap gets problem sometimes and so i use setpixel to check if is a "valid" bitmap and get a new one if it isn't
            */
            if (this.minimapBitmap.isInvalid()) {
                this.minimapBitmap.dispose()
                throw Exception("Invalid minimap image, please try again.")
            }

            /**
            60 to be able to find in roogard sheep place OTClient(fences are not red), at 31941,31691,7
            75 to be able to find in roogard sheep place OTClient(fences are not red), at 31920,31692,7
            */
            switch indexMinimapArea {
                case 1:
                    variationTries3 := (isTibia13() = true) ? 47 : 95
                case 3:
                    variationTries3 := (isTibia13() = true) ? 47 : 75
                    /**
                    75 to find position index 5 at 31918,31708,7
                    */
                case 4, case 5:
                    variationTries3 := (isTibia13() = true) ? 47 : 75
                    /**
                    75 to find position index 8 at 31941,31691,7
                    */
                case 8, case 9:
                    variationTries3 := (isTibia13() = true) ? 47 : 75
                default:
                    variationTries3 := (isTibia13() = true) ? 47 : 60

            }


            /** VARIATION INDEX
            1) variation 40 because of gray mountain on glooth mountain was getting wrong position (x:33651, y:32015, z:13)
            2) 47 to be able to found the position at thais depot
            3) 47 to be able to found position at rathleon (x:33635, y:31921, z:6) index 4/5
            4) variation 32 because of x:32625, y:31869, z:7 getting wrong position map index 5 and 3
            5) with variation 47 the red wall pixel doesn't impact in contrast with the gray ground, like in venore house when open door https://tibiamaps.io/map#32937,32153,6:2
            */
            switch indexMinimapArea {
                case 1: this.Variation := (this.triesIndexMinimap = 1 && this.triesGetCharPos < 3) ? 8 : (this.triesGetCharPos = 1 OR this.triesGetCharPos = 2 ? 47 : variationTries3) ; 5)
                    /**
                    if is the first time searching for the minimap index 5, searches with 32 of tolerancy, otherwise 47
                    32 for variation index 5, 47 for this.variation index 3
                    */
                case 3: this.Variation := this.triesGetCharPos = 1 ? (firstTryCavebot = false ? 32 : 8) : (this.triesGetCharPos = 2 ? 47 : variationTries3)
                    /**
                    changed 32 : 47 to 32 : 40 because of finding wrong positions at 33527,31947,12
                    problems of door closed/opened around
                    */
                    /**
                    search with higher tolerancy only on triesGetCharPos = 2
                    */
                case 8, case 9: this.Variation := this.triesGetCharPos = 1 ? (firstTryCavebot = false ? 32 : 8) : (this.triesGetCharPos = 2 ? 47 : variationTries3)
                    /**
                    if is higher than 40, will find wrong position at 33527,31947,12
                    problems of door closed/opened around
                    */

                case 10, case 11: this.Variation := 40

                    /**
                    search with higher tolerancy only on triesGetCharPos = 2
                    */
                default: this.Variation := this.triesGetCharPos = 1 ? (firstTryCavebot = false ? 40 : 8) : (this.triesGetCharPos = 2 ? 47 : variationTries3)
            }


            try searchResult := this.searchMinimapIndex(minimapArea, indexMinimapArea, floorString, debug)
            catch e
                throw e

            if (searchResult[1] != "")
                break

            /**
            variable to control when searching the same minimap index more than once
            */
            if (this.triesIndexMinimap > 1)
                continue
            this.triesIndexMinimap++

            ; if (indexMinimapArea = 1 OR indexMinimapArea = 8 OR indexMinimapArea = 9)
            ; if (indexMinimapArea = 1 && this.triesGetCharPos < 3)
            if (indexMinimapArea = 1 && this.triesGetCharPos < 3)
                goto, searchIndexAgain
        }

        return searchResult
    }

    searchMinimapIndex(minimapArea, indexMinimapArea, floorString, showMsg := false) {
        if (floorString = "")
            throw Exception("Empty floorString")

        pBitmapMinimapPiece := new _BitmapImage(this.minimapBitmap.crop(minimapCropImageArea%indexMinimapArea%["left"], minimapCropImageArea%indexMinimapArea%["right"], minimapCropImageArea%indexMinimapArea%["up"], minimapCropImageArea%indexMinimapArea%["down"]))
        ; pBitmapMinimapPiece.debug()

        if (pBitmapMinimapPiece.isInvalid()) {
            throw Exception("Invalid minimap bitmap piece(0), index: " indexMinimapArea)
        }


        /*
        TODO: fix this, not working
        */


        ; Gdip_SetBitmapToClipboard(pBitmapMinimapPiece)
        ; msgbox, a

        bitmapWidth := Gdip_GetImageWidth(pBitmapMinimapPiece), bitmapHeight := Gdip_GetImageHeight(pBitmapMinimapPiece)
        if (bitmapWidth = "")
            throw Exception("Error get image width")
        if (bitmapHeight = "")
            throw Exception("Error get image height")


        this.pBitmapGray := Gdip_CreateBitmap(bitmapWidth,bitmapHeight)
        if (this.pBitmapGray = "" OR this.pBitmapGray = 0)
            throw Exception("Error char pos (1)")

        G := Gdip_GraphicsFromImage(this.pBitmapGray)
            , Gdip_DrawImage(G, pBitmapMinimapPiece, 0, 0, bitmapWidth, bitmapHeight, 0, 0, bitmapWidth, bitmapHeight, this.Matrix)
            , Gdip_DisposeImage(pBitmapMinimapPiece), DeleteObject(pBitmapMinimapPiece), Gdip_DeleteGraphics(G)

        switch this.searchWorldChangeMap {
            case true:
                if (this.pBitmapGrayFloorWC[floorString] = "" OR this.pBitmapGrayFloorWC[floorString] = 0)
                    throw Exception("Error char pos WC (4)")
            case false:
                if (this.pBitmapGrayFloor[floorString] = "" OR this.pBitmapGrayFloor[floorString] = 0)
                    throw Exception("Error char pos (4)")
        }



        this.setPinkPixelMinimap(indexMinimapArea)
        if (higherMapTolerancyPositionSearch = 1)
            this.paintBlackPixelsPink(bitmapWidth, bitmapHeight)
        ; Gdip_SetBitmapToClipboard(this.pBitmapGray)
        ; msgbox, a


        /**
        paint a 10 x 10 area of the center of the minimap as white
        for situations of holes in the ground that makes the pixel different and fail imagesearch
        */
        if (this.triesGetCharPos = 3)
            this.paintPinkPixelsCenter(bitmapWidth, bitmapHeight, indexMinimapArea)

        cavebotSystemObj.criticalCharPosSearch := true
        ; tooltip, % this.triesGetCharPos " / " indexMinimapArea
        ; msgbox, % this.triesGetCharPos " / " indexMinimapArea
        if (this.triesGetCharPos = 3)
            writeCavebotLog("Char pos", this.triesGetCharPos ", " indexMinimapArea " " serialize(this.offsetObj))


        ; Gdip_SetBitmapToClipboard((this.searchWorldChangeMap = false ? this.pBitmapGrayFloor[floorString] : this.pBitmapGrayFloorWC[floorString]))
        try {
            status := Gdip_ImageSearch((this.searchWorldChangeMap = false ? this.pBitmapGrayFloor[floorString] : this.pBitmapGrayFloorWC[floorString]), this.pBitmapGray, list_image, this.offsetObj.X1, this.offsetObj.Y1, this.offsetObj.X2, this.offsetObj.Y2, this.Variation, ImagesConfig.pinkColorTrans, , 1, "`n", ",", funcOrigin := "")
        } catch e {
            throw Exception(A_ThisFunc " | " e.Message " | " e.What " | " e.Line)
        } finally {
            cavebotSystemObj.criticalCharPosSearch := false
        }

        result := StrSplit(list_image, ",")
        ; if (A_Index = 5)
        ; msgbox, % serialize(result)
        if (showMsg = true) OR (this.DEBUG_FOUND = true && result[1] != "") {
            ; this.saveBitmapToTempFile(this.pBitmapGrayFloor[floorString], true, true)
            ; this.saveBitmapToTempFile(this.minimapBitmap, true, true)
            ; this.saveBitmapToTempFile(this.pBitmapGray, true, true)

            ; this.saveBitmapToTempFile(this.pBitmapGray, true, false)
            Gdip_SetBitmapToClipboard(this.pBitmapGray)


            msgbox,68,, % A_TickCount - t1 "ms status = " status " `n triesGetCharPos  = " this.triesGetCharPos " triesIndexMinimap = " this.triesIndexMinimap " (" this.searchWorldChangeMap ")`nindex = " A_Index " / indexMinimapArea = " indexMinimapArea " `n result = " serialize(result) "`n`nfloorString = " floorString " | " this.offsetObj.X1 "," this.offsetObj.Y1 "," this.offsetObj.X2 "," this.offsetObj.Y2 "`nVariation = " this.Variation "`n`n Show image?"
            ifmsgbox, yes
            {
                this.saveBitmapToTempFile(this.pBitmapGray, true, false)
            }
        }
        Gdip_DisposeImage(this.pBitmapGray)

        return result
    }

    /**
    paint an area around the character center minimap white to cover any holes or different pixels
    was necessary to be able to get the char position on this location https://tibiamaps.io/map#32376,32908,10:2
    where there are 2 holes
    */
    paintPinkPixelsCenter(w, h, indexMinimapArea) {
        if (this.pBitmapGray = "")
            throw Exception(A_ThisFunc ": Empty this.pBitmapG.")

        if (isTibia13() = false)
            return this.paintPinkPixelsCenterOtClient(w, h, indexMinimapArea)

        switch indexMinimapArea {
            case 1:
                pixelsWidth := 12, pixelsHeight := 12
            case 3:
                pixelsWidth := 8, pixelsHeight := 8
            case 8:
                pixelsWidth := 8, pixelsHeight := 12
            case 9:
                pixelsWidth := 12, pixelsHeight := 8
            case 6, case 7:
                pixelsWidth := 12, pixelsHeight := 8
            case 4:
                pixelsWidth := 8, pixelsHeight := 12
            case 5:
                pixelsWidth := 8, pixelsHeight := 12
            default:
                return
        }

        switch indexMinimapArea {
            case 6:
                x := w / 2 - (pixelsWidth / 2), y := 0
            case 7:
                x := w / 2 - (pixelsWidth / 2), y := h - pixelsHeight
            case 4:
                x := w - pixelsWidth, y := h / 2 - (pixelsHeight / 2)
            case 5:
                x := 0, y := h / 2 - (pixelsHeight / 2)
            default:
                x := w / 2 - (pixelsWidth / 2), y := h / 2 - (pixelsHeight / 2)
        }


        try {
            indexY := 0
            Loop, % pixelsHeight {
                indexX := 0
                Loop, % pixelsWidth {
                    Gdip_SetPixel(this.pBitmapGray, x + indexX, y + indexY, ImagesConfig.pinkColor)
                        , indexX++
                }
                indexY++
            }
        } catch {
            throw Exception("Failed to set white pixel minimap.")
        }
        ; this.saveBitmapToTempFile(this.pBitmapGray, true, true)
    }

    paintPinkPixelsCenterOtClient(w, h, indexMinimapArea) {
        ; m(indexMinimapArea)
        switch indexMinimapArea {
            case 1:
                pixelsWidth := OldBotSettings.settingsJsonObj.map.minimap.crossSize + (OldBotSettings.settingsJsonObj.map.minimap.crossSize / 2)
                    , pixelsHeight := OldBotSettings.settingsJsonObj.map.minimap.crossSize + (OldBotSettings.settingsJsonObj.map.minimap.crossSize / 2)
            case 3:
                pixelsWidth := OldBotSettings.settingsJsonObj.map.minimap.crossSize + 2
                    , pixelsHeight := OldBotSettings.settingsJsonObj.map.minimap.crossSize + 2
            case 8:
                pixelsWidth := OldBotSettings.settingsJsonObj.map.minimap.crossSize - 1
                    , pixelsHeight := OldBotSettings.settingsJsonObj.map.minimap.crossSize - 1
            case 9:
                pixelsWidth := OldBotSettings.settingsJsonObj.map.minimap.crossSize + (OldBotSettings.settingsJsonObj.map.minimap.crossSize / 2)
                    , pixelsHeight := OldBotSettings.settingsJsonObj.map.minimap.crossSize
            case 6:
                pixelsWidth := OldBotSettings.settingsJsonObj.map.minimap.crossSize + (OldBotSettings.settingsJsonObj.map.minimap.crossSize / 2) - 1
                    , pixelsHeight := OldBotSettings.settingsJsonObj.map.minimap.crossSize
            case 7:
                pixelsWidth := OldBotSettings.settingsJsonObj.map.minimap.crossSize + (OldBotSettings.settingsJsonObj.map.minimap.crossSize / 2)
                    , pixelsHeight := OldBotSettings.settingsJsonObj.map.minimap.crossSize + 2
            case 4:
                pixelsWidth := OldBotSettings.settingsJsonObj.map.minimap.crossSize + 2
                    , pixelsHeight := OldBotSettings.settingsJsonObj.map.minimap.crossSize + (OldBotSettings.settingsJsonObj.map.minimap.crossSize / 2)
            case 5:
                pixelsWidth := OldBotSettings.settingsJsonObj.map.minimap.crossSize + 2
                    , pixelsHeight := OldBotSettings.settingsJsonObj.map.minimap.crossSize + (OldBotSettings.settingsJsonObj.map.minimap.crossSize / 2)
            default:
                return
        }

        switch indexMinimapArea {
            case 1:
                x := w / 2 - (pixelsWidth / 2) - 8, y := h / 2 - (pixelsHeight / 2) + 1
            case 6:
                x := w / 2 - (pixelsWidth / 2), y := 0
            case 7:
                x := w / 2 - (pixelsWidth / 2), y := h - pixelsHeight
            case 4:
                x := w - pixelsWidth, y := h / 2 - (pixelsHeight / 2)
            case 5:
                x := 0, y := h / 2 - (pixelsHeight / 2)
            case 9:
                x := w / 2 - (pixelsWidth / 2), y := h / 2 - (pixelsHeight / 2)
            default:
                x := w / 2 - (pixelsWidth / 2), y := h / 2 - (pixelsHeight / 2) + 1
        }


        try {
            indexY := 0
            Loop, % pixelsHeight {
                indexX := 0
                Loop, % pixelsWidth {
                    Gdip_SetPixel(this.pBitmapGray, x + indexX, y + indexY, ImagesConfig.pinkColor)
                        , indexX++
                }
                indexY++
            }
        } catch {
            throw Exception("Failed to set white pixel minimap.")
        }
    }

    checkResetOffset1() {
        if (Waypoint <= 1)
            return
        /**
        dont run this check if the previous waypoints is Action
        because action can have distant waypoints and the script
        will still run normally, example: duplicating action waypoints

        commented because the right way is to make the action waypoints near
        the other waypoints just like a normál waypoint
        */
        ; if (WaypointHandler.getAtribute("type", Waypoint - 1, Tab) = "Action")
        ;     return

        /**
        teleport from too distant waypoints situation, reset the offset instead of trying to search in the last previous area
        if current waypoint is "too far" from previous, and the floor of current is different from the last
        */
        x := waypointsObj[tab][Waypoint].coordinates.x, y := waypointsObj[tab][Waypoint].coordinates.y, z := waypointsObj[tab][Waypoint].coordinates.z
            , x2 := waypointsObj[tab][Waypoint - 1].coordinates.x, y2 := waypointsObj[tab][Waypoint - 1].coordinates.y, z2 := waypointsObj[tab][Waypoint - 1].coordinates.z

        if (this.isWaypointTooFar(x, y, z, x2, y2, z2, ignoreZ := true, false, debug := false) = true) {
            posx := "", posy := ""
            this.offsetReseted1 := true
            if (!A_IsCompiled)
                writeCavebotLog("Char pos", "Offset reseted (1), waypoint " Waypoint ": " x "," y "," z " | prev. waypoint " Waypoint - 1 ": " x2 "," y2 "," z2 " [" this.triesGetCharPos ", " indexMinimapArea "]")
        }
    }

    checkResetOffset2() {
        if (Waypoint <= 1)
            return
        /**
        if last character position is "too far" from current waypoint, reset the offset
        */
        maxIndex := lastRealCharPositions.Count()
        if (maxIndex <= 1)
            return

        if (this.isWaypointTooFar(x, y, z
                , lastRealCharPositions[maxIndex].x, lastRealCharPositions[maxIndex].y, lastRealCharPositions[maxIndex].z
                , ignoreZ := true, false, debug := false) = true) {
            posx := "", posy := ""
            writeCavebotLog("Char pos", "Offset reseted (2): " this.triesGetCharPos ", " indexMinimapArea)
        }
    }

    generatePixelMap(bigMinimapDistance := false) {
        floorString := floorString(posz)

        try {
            if (OldBotSettings.settingsJsonObj.map.settings.pathFiles) {
                mapFileWidth := Gdip_GetImageWidth(pBitmapPathFloor%floorString%)
                mapFileHeight := Gdip_GetImageHeight(pBitmapPathFloor%floorString%)
                Gdip_LockBits(pBitmapPathFloor%floorString%, 0, 0, mapFileWidth, mapFileHeight, Stride, Scan0, BitmapData)
            } else {
                mapFileWidth := Gdip_GetImageWidth(pBitmapColoredFloor%floorString%)
                mapFileHeight := Gdip_GetImageHeight(t%floorString%)
                Gdip_LockBits(pBitmapColoredFloor%floorString%, 0, 0, mapFileWidth, mapFileHeight, Stride, Scan0, BitmapData)
            }
        } catch e {
            throw e
        }

        ; Gdip_SetBitmapToClipboard(pBitmapPathFloor%floorString%)
        ; msgbox, % floorString

        Y_Index := this.minimapPictureCoordY1, pathHeight := minimapHeight, pathWidth := minimapWidth
        if (bigMinimapDistance) {
            Y_Index := abs(this.minimapPictureCoordY1 - (minimapHeight / 2)), pathHeight := minimapHeight * 2, pathWidth := minimapWidth * 2
        }

        if (Y_Index < 1) {
            Y_Index := 1
        }

        if (X_Index > mapFileWidth || Y_Index > mapFileHeight) {
            throw Exception("Invalid map file coords(custom map)", "CustomMap")
        }

        pixelMap := {}
        try {
            Loop, %pathHeight% {
                X_Index := this.minimapPictureCoordX1 - (bigMinimapDistance ? (minimapWidth / 2) : 0)
                if (X_Index < 1) {
                    X_Index := 1
                }

                Loop, %pathWidth% {
                    if (!pixelMap[Y_Index])
                        pixelMap[Y_Index] := {}

                    ARGB := Gdip_GetLockBitPixel(Scan0, X_Index, Y_Index, Stride)
                    pixelMap[Y_Index][X_Index] := ConvertARGB(ARGB)
                    SetFormat, IntegerFast, D

                    X_Index++
                    if (X_Index >= MinimapFiles.mapWidth) {
                        break
                    }
                }

                Y_Index++
                if (Y_Index >= MinimapFiles.mapHeight) {
                    break
                }
            }
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            throw e
        }

        try {
            if (OldBotSettings.settingsJsonObj.map.settings.pathFiles) {
                Gdip_UnlockBits(pBitmapPathFloor%floorString%, BitmapData, A_ThisFunc)
            } else {
                Gdip_UnlockBits(pBitmapColoredFloor%floorString%, BitmapData, A_ThisFunc)
            }
        } catch e {
            _Logger.exception(e, A_ThisFunc, "Gdip_UnlockBits")
        } finally {
            DeleteObject(BitmapData)
        }

        for Y_index, value1 in pixelMap
        {
            for X_Index, value2 in value1
            {
                if (X_Index = this.charImagePosX && Y_Index = this.charImagePosY) {
                    string .= "A"
                    continue
                }

                if (X_Index = this.mapImageX && Y_Index = this.mapImageY) {
                    if (this.checkWalkablePixelmap(X_Index, Y_Index, posz, true) = "*") {
                        throw exception("Failed to set path, destination(B) coordinate sqm is blocked")
                    }

                    string .= "B"
                    continue
                }

                walkable := this.checkWalkablePixelmap(X_Index, Y_Index, posz)
                if (!walkable) {
                    throw Exception("Empty walkable.`nX: " X_Index, "Y: " Y_Index " / " value2)
                }

                string .= walkable
            }

            string .= "`n"
        }

        return string
    }

    checkWalkablePixelmap(X_Index, Y_Index, pathCoordZ, allowStair := false) {
        if (!this.isCoordWalkable(tibiaMapX1 + X_Index, tibiaMapY1 + Y_Index, pathCoordZ, allowStair)) {
            return "*"
        }

        return " "
    }

    isCoordWalkable(coordWalkableX, coordWalkableY, coordWalkableZ, allowStair := false) {
        /**
        check if coords are outside the tibia map limits to check from the big map .png images
        */
        if (scriptSettingsObj.charCoordsFromMemory) {
            try {
                _Validation.mapCoordinates("coordWalkable", coordWalkableX, coordWalkableY, coordWalkableZ)
            } catch {
                return true
            }
        }

        /**
        added on 27/10/22
        if the coord is in the blocked coordinates, consider as non walkable
        */

        if (cavebotSystemObj.blockedCoordinates[coordWalkableX, coordWalkableY, coordWalkableZ]) {
            return false
        }

        return new _CoordinatePixelCondition(coordWalkableX, coordWalkableY, coordWalkableZ, {"allowStair": allowStair}).handle()
    }

    isCoordStair(coordX, coordY, coordZ) {
        pixColor := _CoordinatePixelCondition.getCoordPixel(coordX, coordY, coordZ)
        if (pixColor = this.stairPixColor)
            return true
        return false
    }

    setPath(coordX, coordY, coordZ := "")
    {
        ; throw Exception("")
        if (coordZ = "")
            coordZ := posz

        coords := new _MapCoordinate(coordX, coordY, coordZ)
        distance :=   coords.getDistance(posx, posy)

        if (coords.getDistance(posx, posy) > 100) {
            throw Exception(txt("Coordenadas estão muito longe do char para andar pelas setas com rota traçada", "Coordinates are too far from the character to walk by arrow keys with traced route"), "CoordTooFar")
        }

        minimapArea := new _MinimapArea()

        this.minimapPictureCoordX1 := posx - minimapArea.getCenterRelative().getX() - tibiaMapX1
        this.minimapPictureCoordY1 := posy - minimapArea.getCenterRelative().getY() - tibiaMapY1

        distance := this.distanceCoordFromCharPos(coordX, coordY)

        /**
        if the dest coord is one of the blocked coords by creatures
        */
        if (cavebotSystemObj.blockedCoordinatesByCreatures[coordX, coordY, coordZ] = true)
            throw Exception("Coordinate SQM is blocked by creature")

        /**
        if the dest coord is one of the blocked coords by many trials to walk
        */
        if (cavebotSystemObj.blockedCoordinates[coordX, coordY, coordZ] = true)
            throw Exception("Coordinate SQM is blocked by previous attempt to walk")

        try this.isWaypointTooFar(coordX, coordY, coordZ, posx, posy, posz, false)
        catch e
            throw e

        generateBigPath := this.isCoordVisibleMinimap(coordX, coordY) = true ? false : true
        ; msgbox, % generateBigPath

        this.charImagePosX := posx - tibiaMapX1
            , this.charImagePosY := posy - tibiaMapY1
        ; msgbox, % this.charImagePosX "," this.charImagePosY

        this.mapImageX := coordX - tibiaMapX1
            , this.mapImageY := coordY - tibiaMapY1
        ; msgbox, % this.mapImageX "," this.mapImageY


        string := this.generatePixelMap(generateBigPath)

        if (posx = coordX) && (posy = coordY) {
            return
            ; throw Exception("Already arrived in the position", -1)
        }

        ; Clipboard := string
        ; msgbox, % string


        Grid := string
        ; Create Array from Grid data
        Closed := {}
        for Y, Line in StrSplit(Grid, "`n")
            for X, val in StrSplit(Line)
                if (val = "*")
                    Closed[X,Y] := true
        else if (val = "B")
            X1 := X, Y1 := Y
        else if (val = "A")
            X2 := X, Y2 := Y, AX := X, AY := Y

        /**
        check if the the north, south, east and west sqms are closed
        */
        if (Closed[AX - 1, AY] = true)  ; left
                && (Closed[AX + 1, AY] = true)  ; right
                && (Closed[AX - 1, AY - 1] = true)  ; up
                && (Closed[AX, AY + 1] = true) { ; down
                throw Exception(txt("Falha ao setar rota: sqms N, S, W e E estão fechados", "Failed to set path: N, S, W and E sqms are closed") )
        }

        Path := this.Astar_Grid(X1, Y1, X2, Y2, Closed)

        if (Path.MaxIndex() < 1) {
            ; Path := "Data\Screenshots\_ERROR_SetPath*.png"
            ; , Number := 1
            ; Loop, %Path%
            ;     Number++
            ; ScreenshotTela("_ERROR_SetPath" Number)
            throw Exception("Could not set path, distance x: " distance.x ", y: " distance.y ". From: " posx ", " posy  ", " posz " to: " coordX ", " coordY  ", " coordZ)
            ; throw Exception("Could not set path, screenshot saved ""_ERROR_SetPath" Number ".png"". From: " posx ", " posy  ", " posz " to: " coordX ", " coordY  ", " coordZ)
            ; throw Exception("Could not set path, screenshot saved on Data\Screenshots\_ERROR_SetPath" Number ".png.`nFrom`n`nX: " posx ", Y: " posy  ", Z: " posz " to X: " coordX ", Y: " coordY  ", Z: " coordZ "`n" Path.MaxIndex() "`n" serialize(Path))
        }
        ; Path.Remove(Path.MaxIndex())
        ; msgbox, % serialize(Path)

        ; Display Grid and Path
        Display := ""
        for Y, Line in StrSplit(Grid, "`n")
        {
            for X, val in StrSplit(Line "`n")
            {
                for index, Cell in Path
                    if (Cell.X = X and Cell.Y = Y and index > 1 and index < Path.MaxIndex())
                    {
                        ; msgbox, %X%, %Y%
                        ; diminuindo 1 na posição pois por algum motivo esse X,Y está errado no valor original
                        ; coord_x := X - 1, coord_y := Y - 1
                        ; path_to_walk.Push(X "," Y - 1)
                        Display .= "x"

                        ; msgbox, % coord_x ", " coord_y
                        continue 2
                    }
                Display .= val
            }
        }
        ; Clipboard := Display
        ; msgbox, %Display%

        ; Gui, font, s8, courier new
        ; Gui, Add, Text,, % Grid
        ; Gui, Add, Text, x+10 yp+0, % Display
        ; Gui, Show


        print := false
        if (print = true) {
            minimapArea := new _MinimapArea()
            pBitmapScreen:=Gdip_BitmapFromScreen(WindowX + minimapArea.getX1() "|" WindowY + minimapArea.getY1() "|" minimapWidth "|" minimapHeight)
            Color := "0xFFFFFFFF" ; WHITE
            Color := "0xFF000000" ; BLACK
        }

        pathRealCoords := {}
        for key, value in Path
        {
            if (print = true)
                Gdip_SetPixel(pBitmapScreen, Path[key]["X"], Path[key]["Y"] - 1, Color) ; -1 pra ajustar o pixel y na foto que esta errado

            ; ajustes para a coordenada ficar certa(real - não no display)
            if (generateBigPath = true)
                Path[key]["X"] -= 54, Path[key]["Y"] -= isTibia13() = true ? 55: 56 ; 56 in OTClientV8
            else {
                Path[key]["X"] -= 1, Path[key]["Y"] -= isTibia13() = true ? 1 : 1 ; 2 in OTClientV8
            }
            pathRealCoords.Push(this.minimapToRealCoords(Path[key]["X"], Path[key]["Y"], minimapArea))
            ; msgbox, % serialize(pathRealCoords)
        }
        if (print = true)
            this.saveBitmapToTempFile(pBitmapScreen, true, false)
        ; msgbox, % serialize(pathRealCoords)

        return pathRealCoords
    }

    ; Astar_Grid and supporting functions
    Astar_Grid(X1, Y1, X2, Y2, Closed := "") {
        if !IsObject(Closed)
            Closed := {}
        Open := {}, From := {}, G := {}, F := {}
            , Open[X1, Y1] := true, G[X1, Y1] := 0
            , F[X1, Y1] := this.Estimate_F(X1, Y1, X2, Y2)
        while Open.MaxIndex()
        {
            if (cavebotSystemObj.setPathTimer > 5)
                throw Exception("set path timed out (5 seconds)", "setPathTimeout")
            this.Lowest_F_Set(X, Y, F, Open)
            if (X = X2 and Y = Y2)
                return this.From_Path(From, X, Y)
            Open[X].Delete(Y)
            if !Open[X].MaxIndex()
                Open.Delete(X)
            Closed[X, Y] := true
            for index, Near in [{"X": X, "Y": Y-1},{"X": X-1, "Y": Y},{"X": X+1, "Y": Y},{"X": X, "Y": Y+1}]
            {
                if (Closed[Near.X, Near.Y] = true)
                    continue
                Open[Near.X, Near.Y] := true, tG := G[X, Y] + 1
                if (IsObject(G[Near.X, Near.Y]) and tG >= G[Near.X, Near.Y])
                    continue
                From[Near.X, Near.Y] := {"X": X, "Y": Y}
                    , G[Near.X, Near.Y] := tG
                    , F[Near.X, Near.Y] := G[Near.X, Near.Y] + this.Estimate_F(Near.X, Near.Y, X2, Y2)
            }
        }
    }

    Estimate_F(X1, Y1, X2, Y2) {
        return Abs(X1-X2) + Abs(Y1-Y2)
    }

    Lowest_F_Set(ByRef X, ByRef Y, ByRef F, ByRef Set) {
        l := 0x7FFFFFFF
        for tX , element in Set
            for tY, val in element
                if (F[tX, tY] < l)
                    l := F[tX, tY], X := tX, Y := tY
        return l
    }

    From_Path(From, X, Y) {
        Path := {}, XY := {"X": X, "Y": Y}
        Path.InsertAt(1, XY)
        while (IsObject(From[XY.X, XY.Y]))
            Path.InsertAt(1, XY:= From[XY.X, XY.Y])
        return Path
    }

    waypointClick()
    {
        if (!cavebotSystemObj.clicksOnWaypoint) {
            cavebotSystemObj.clicksOnWaypoint := 1
        }

        writeCavebotLog("Cavebot", "Clicking " cavebotSystemObj.clicksOnWaypoint "x... " stringCoords)

        cavebotSystemObj.clicksOnWaypoint++
        if (cavebotSystemObj.clicksOnWaypoint > cavebotSystemObj.clicksOnWaypointTrappedLimit) {
            cavebotSystemObj.forceWalk := true
        }

        if (scriptSettingsObj.cavebotFunctioningMode = "markers") {
            if (!_CavebotByImage.clickOnMarker()) {
                return false
            }

            return true
        }

        if (!mapX || !mapY) {
            return
        }

        try {
            coords := this.realCoordsToMinimapScreen(mapX, mapY)
        } catch e {
            if (e.What = "CoordNotVisible") {
                cavebotSystemObj.forceWalk := true
                cavebotSystemObj.forceWalkReason := "CoordNotVisible"
                writeCavebotLog("Cavebot - ATTENTION", e.Message)
                return true
            } else {
                _Logger.exception(e, A_ThisFunc)
                return false
            }
        }

        if (!this.checkCoordIsStairBeforeClickDistanceLooting(mapX, mapY)) {
            return false
        }

        coords := this.centerCoordRange(coords, waypointsObj[tab][Waypoint].rangeX, waypointsObj[tab][Waypoint].rangeY)

        if (!this.clickMinimap(coords.x, coords.y)) {
            return false
        }

        return true
    }

    /**
    * @param _Coordinate coords
    * @param int rangeX
    * @param int rangeY
    * @return _Coordinate
    * @throws
    */
    centerCoordRange(coords, rangeX, rangeY)
    {
        if (Mod(rangeX, 2) = 1) {
            coords.addX(this.getCenterRangeModifier(rangeX))
        }

        if (Mod(rangeY, 2) = 1) {
            coords.addY(this.getCenterRangeModifier(rangeY))
        }

        return coords
    }

    /**
    * @param int range
    * @return int
    */
    getCenterRangeModifier(range)
    {
        switch (range) {
            case 3: return 1
            case 5: return 2
            case 7: return 3
            case 9: return 4
            case 11: return 5
            case 13: return 6
            case 15: return 7
        }

        return 0
    }

    checkCoordIsStairBeforeClickDistanceLooting(coordX, coordY) {
        if (!this.isCoordWalkable(coordX, coordY, posz)) {
            writeCavebotLog("WARNING", txt("Coordenada do clique no mapa looting não é caminhável: ", "Looting coordinate of map click is not walkable: ") coordX "," coordY "," posz)
            return false
        }

        return true
    }

    clickMinimap(coordX, coordY) {
        clickCoord := new _Coordinate(coordX, coordY)

        if (scriptSettingsObj.cavebotFunctioningMode = "markers") {
            clickCoord := new _Coordinate(coordX, coordY)
            /**
            if is a marker
            */
            if (!waypointsObj[tab][Waypoint].imageBitmap) {
                clickCoord.addX((7/2) - 1)
                    .addY((5/2) - 1)
            } else {
                clickCoord.addX(waypointsObj[tab][Waypoint].imageWidth > 0 ? waypointsObj[tab][Waypoint].imageWidth / 2 : 0)
                    .addY(waypointsObj[tab][Waypoint].imageHeight > 0 ? waypointsObj[tab][Waypoint].imageHeight / 2 : 0)
            }
        }

        /**
        Used for Persistents to not click if Cavebot is clicking on minimap
        */
        IniWrite, 1, %DefaultProfile%, others_cavebot, CavebotClickingOnMinimap

        try {

            ; clickCoord.click()
            ; msgbox, gonna click
            clickCoord.click("Left", 1, "", false)
            /**
            added to see if stop dragging the minimap after click
            */

            if (backgroundMouseInput) {
                Loop, 2 {
                    ClickButtonUp("Left", clickCoord.getX(), clickCoord.getY(), debug)
                    Sleep, 25
                }
            }

            Sleep, 50
            MouseMove(CHAR_POS_X, CHAR_POS_Y)
        } finally {
            IniWrite, 0, %DefaultProfile%, others_cavebot, CavebotClickingOnMinimap
        }

        return true
    }

    isWaypointTooFar(fromCoordX, fromCoordY, fromCoordZ, toCoordX, toCoordY, toCoordZ, ignoreZ := false, throwException := true, debug := false) {
        distX := abs(fromCoordX - toCoordX) , distY := abs(fromCoordY - toCoordY) , distZ := abs(fromCoordZ - toCoordZ)
        if (debug) {
            msgbox, % fromCoordX "," fromCoordY "`n" toCoordX "," toCoordY "`n" fromCoordZ "," fromCoordZ "`n" distX " / " distY
        }

        if (distX >= 51 * 2) {
            if (throwException = true)
                throw Exception("Distance too far from X coordinate: " distX " (from: " fromCoordX "," fromCoordY "," fromCoordZ " to: " toCoordX "," toCoordY "," toCoordZ ")", -1)
            return true
        }
        if (distY >= 52 * 2) {
            if (throwException = true)
                throw Exception("Distance too far from Y coordinate: " distY " (from: " fromCoordX "," fromCoordY "," fromCoordZ " to: " toCoordX "," toCoordY "," toCoordZ ")", -1)
            return true
        }
        if (ignoreZ = false) {
            if (distZ > 1) {
                if (throwException = true)
                    throw Exception("Different Z coordinate: " distZ " (from: " fromCoordX "," fromCoordY "," fromCoordZ " to: " toCoordX "," toCoordY "," toCoordZ ")", -1)
                return true
            }
        }
        return false
    }

    fixFloorLevelString(level) {
        switch level {
            case "7": return 0
            case "6": return 1
            case "5": return 2
            case "4": return 3
            case "3": return 4
            case "2": return 5
            case "1": return 6
            case "0": return 7
            case "-1": return 8
            case "-2": return 9
            case "-3": return 10
            case "-4": return 11
            case "-5": return 12
            case "-6": return 13
            case "-7": return 14
            case "-8": return 15
        }

        throw Exception("(1) " (LANGUAGE = "PT-BR" ? "Floor level invalido: """ level """`nReabra o bot e o cliente do Tibia e tente novamente." : "Invalid floor level: """ level """`nPlease reopen the bot and the tibia client and try again.") )
    }

    saveBitmapToTempFile(bitmap, clip := false, showMsg := true) {
        image_name := "__tempfile2.png"
        if (clip = true) {
            ; msgbox, % "saveBitmapToTempFile.bitmap = " bitmap
            try
                Gdip_SetBitmapToClipboard(bitmap)
            catch
                msgbox, 16,, saveBitmapToTempFile.Gdip_SetBitmapToClipboard
            run, C:\Windows\system32\mspaint.exe
            Sleep, 500
            Send, ^v

        } else {
            Gdip_SaveBitmapToFile(bitmap, image_name)
            run, C:\Windows\system32\mspaint.exe "%image_name%"
        }
        if (showMsg = true)
            msgbox, 64,, saved temp file %n%
        return
    }

    paintBlackPixelsPink(bitmapWidth, bitmapHeight) {
        y := 0
        Loop, % bitmapHeight
        {
            x := 0
            Loop, % bitmapWidth
            {
                pixColor := Gdip_GetPixel(this.pBitmapGray, x, y, A_ThisFunc)
                ; clipboard := pixColor
                ; , pix := ConvertARGB(pixColor)
                ; msgbox, % pixColor "/" pix
                if (pixColor != "4278190080") { ; black
                    x++
                    continue
                }
                ; SetFormat, Integer, D
                ; if (pix = "")
                try {
                    Gdip_SetPixel(this.pBitmapGray, x, y, ImagesConfig.pinkColor)
                } catch {
                    throw Exception("(2) Failed to set pixel color minimap.")
                }
                x++
            }
            y++
        }
    }

    setPinkPixelMinimap(indexMinimapArea) {
        if (isTibia13() = false)
            return this.setPinkPixelMinimapOtClient(indexMinimapArea)

        pixels := {}
        switch indexMinimapArea {
            case 1:
                x := 28, y := 26
                x2 := x - 2, y2 := y + 2
            case 3:
                x := 18, y := 16
            case 8:
                x := 9, y := 21
            case 9:
                x := 22, y := 9

                /**
                ------
                |_  _|
                |_|
                */
            case 6:
                index := 0
                Loop, 6 {
                    pixels.Push({x: 21 + index, y: 0})
                        , pixels.Push({x: 21 + index, y: 1})
                        , index++
                }
                pixels.Push({x: 23, y: 2})
                    , pixels.Push({x: 24, y: 2})
                    , pixels.Push({x: 23, y: 3})
                    , pixels.Push({x: 24, y: 3})

                /**     __
                _| |_
                |____|
                */
            case 7:
                index := 0
                Loop, 6 {
                    pixels.Push({x: 21 + index, y: 18})
                        , pixels.Push({x: 21 + index, y: 19})
                        , index++
                }
                pixels.Push({x: 23, y: 16})
                    , pixels.Push({x: 24, y: 16})
                    , pixels.Push({x: 23, y: 17})
                    , pixels.Push({x: 24, y: 17})

                /**     __
                _| |
                |_  |
                |_|
                */
            case 4:
                index := 0
                Loop, 6 {
                    pixels.Push({x: 18, y: 23 + index})
                        , pixels.Push({x: 19, y: 23 + index})
                        , index++
                }
                pixels.Push({x: 16, y: 25})
                    , pixels.Push({x: 16, y: 26})
                    , pixels.Push({x: 17, y: 25})
                    , pixels.Push({x: 17, y: 26})

                /**    __
                | |_
                |  _|
                |_|
                */
            case 5:
                index := 0
                Loop, 6 {
                    pixels.Push({x: 0, y: 23 + index})
                        , pixels.Push({x: 1, y: 23 + index})
                        , index++
                }
                pixels.Push({x: 2, y: 25})
                    , pixels.Push({x: 2, y: 26})
                    , pixels.Push({x: 3, y: 25})
                    , pixels.Push({x: 3, y: 26})
            default:
                return
                msgbox, 16,, % A_ThisFunc " " indexMinimapArea
        }
        x2 := x - 2, y2 := y + 2
        index := 0
        switch indexMinimapArea {
                /**
                full cross minimap
                */
            case 1, case 3, case 8, case 9:
                try {
                    Loop, 6 {
                        Gdip_SetPixel(this.pBitmapGray, x, y + index, ImagesConfig.pinkColor), Gdip_SetPixel(this.pBitmapGray, x + 1, y + index, ImagesConfig.pinkColor)
                            , Gdip_SetPixel(this.pBitmapGray, x2 + index, y2, ImagesConfig.pinkColor), Gdip_SetPixel(this.pBitmapGray, x2 + index, y2 + 1, ImagesConfig.pinkColor)
                            , index++
                    }
                } catch {
                    throw Exception("Failed to set white pixel minimap.")
                }
            default:
                for key, pixelPos in pixels
                {
                    ; msgbox, % key " = " serialize(pixelPos)
                    try {
                        Gdip_SetPixel(this.pBitmapGray, pixelPos.x, pixelPos.y, ImagesConfig.pinkColor)
                    } catch {
                        throw Exception("(1) Failed to set pixel color minimap.")

                    }
                }


        }
    }

    setPinkPixelMinimapOtClient(indexMinimapArea) {
        pixels := {}

        ; m(indexMinimapArea)

        switch indexMinimapArea {
            case 1:
                x := 27, y := 23
            case 3:
                x := 17, y := 13
            case 8:
                x := 8, y := 18
            case 9:
                x := 21, y := 6

                /**
                ------
                |_  _|
                |_|
                */
            case 6:
                x := 18
                y := 0
                /**     __
                |_|
                */
                indexX := 0
                Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossSize {
                    indexY := 0
                    Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossThickness - 1
                    {
                        pixels.Push({"x": x + indexX, "y": y + indexY})
                        indexY++
                    }
                    indexX++
                }
                /**   _____
                |_____|
                */
                x += OldBotSettings.settingsJsonObj.map.minimap.crossThickness
                y += OldBotSettings.settingsJsonObj.map.minimap.crossThickness / 2
                index := 0
                Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossThickness {
                    Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossThickness
                    {
                        pixels.Push({"x": x + index, "y": y + A_Index})
                    }
                    index++
                }

                /**     __
                _| |_
                |____|
                */
            case 7:
                x := 18
                y := 17
                /**     __
                |_|
                */
                indexX := 0
                Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossSize {
                    indexY := 0
                    Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossThickness - 1
                    {
                        pixels.Push({"x": x + indexX, "y": y + indexY})
                        indexY++
                    }
                    indexX++
                }
                /**   _____
                |_____|
                */
                x += OldBotSettings.settingsJsonObj.map.minimap.crossThickness
                y -= OldBotSettings.settingsJsonObj.map.minimap.crossThickness + 1
                index := 0
                Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossThickness {
                    Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossThickness
                    {
                        pixels.Push({"x": x + index, "y": y + A_Index})
                    }
                    index++
                }

                /**     __
                _| |
                |_  |
                |_|
                */
            case 4:
                x := 16
                y := 20
                /**     __
                | |
                | |
                |_|
                */
                index := 0
                Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossSize {
                    Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossThickness - 1
                    {
                        pixels.Push({"x": x + A_Index, "y": y + index})
                    }
                    index++
                }
                /**  __
                |__|
                */
                x -= OldBotSettings.settingsJsonObj.map.minimap.crossThickness - 1
                y += OldBotSettings.settingsJsonObj.map.minimap.crossThickness - 1
                index := 0
                Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossThickness {
                    Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossThickness
                    {
                        pixels.Push({"x": x + index, "y": y + A_Index})
                    }
                    index++
                }

                /**    __
                | |_
                |  _|
                |_|
                */
            case 5:
                x := 0
                y := 20
                ; y axis
                /**     __
                | |
                | |
                |_|
                */
                indexY := 0
                Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossSize {
                    indexX := 0
                    Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossThickness - 1
                    {
                        pixels.Push({"x": x + indexX, "y": y + indexY})
                        indexX++
                    }
                    indexY++
                }
                /**  __
                |__|
                */
                x += OldBotSettings.settingsJsonObj.map.minimap.crossThickness - 1
                y += OldBotSettings.settingsJsonObj.map.minimap.crossThickness - 1
                index := 0
                Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossThickness {
                    Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossThickness
                    {
                        pixels.Push({"x": x + index, "y": y + A_Index})
                    }
                    index++
                }
            default:
                return
                msgbox, 16,, % A_ThisFunc " " indexMinimapArea
        }
        x2 := x - (OldBotSettings.settingsJsonObj.map.minimap.crossSize / 2 - 2)
            , y2 := y + (OldBotSettings.settingsJsonObj.map.minimap.crossSize / 2 - 2)
        index := 0
        switch indexMinimapArea {
                /**
                full cross minimap
                */
            case 1, case 3, case 8, case 9:
                try {
                    Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossSize {
                        Gdip_SetPixel(this.pBitmapGray, x, y + index, ImagesConfig.pinkColor)
                            , Gdip_SetPixel(this.pBitmapGray, x2 + index, y2, ImagesConfig.pinkColor)

                        indexThickness := 1
                        Loop, % OldBotSettings.settingsJsonObj.map.minimap.crossThickness - 1 {
                            Gdip_SetPixel(this.pBitmapGray, x + indexThickness, y + index, ImagesConfig.pinkColor)
                            Gdip_SetPixel(this.pBitmapGray, x2 + index, y2 + indexThickness, ImagesConfig.pinkColor)
                                , indexThickness++
                        }
                        index++
                    }
                } catch {
                    throw Exception("Failed to set white pixel minimap.")
                }
            default:
                for key, pixelPos in pixels
                {
                    ; msgbox, % key " = " serialize(pixelPos)
                    try {
                        Gdip_SetPixel(this.pBitmapGray, pixelPos.x, pixelPos.y, ImagesConfig.pinkColor)
                    } catch {
                        throw Exception("(1) Failed to set pixel color minimap.")

                    }
                }


        }
    }

    getMinimapFloorPosition() {
        if (isNotTibia13()) {
            return
        }

        if (CavebotScript.isMemoryCoords() && CavebotScript.isCoordinate()) {
            return
        }


        if (CavebotScript.isMarker()) {
            return
        }

        minimapArea := new _MinimapArea()

        baseSearch := new _ImageSearch()
            .setFolder(ImagesConfig.minimapFolder)
            .setVariation(40)
            .setCoordinates(minimapArea.getFloorArea())

        _search := baseSearch
            .setFile("minimap_first_floor")
            .search()

        if (_search.notFound()) {
            _search := baseSearch
                .setFile("minimap_first_floor_2")
                .search()

            if (_search.notFound()) {
                _search := baseSearch
                    .setFile("minimap_first_floor_3")
                    .search()

                if (_search.notFound()) {
                    msg := txt("Houve um problema ao localizar o floor do Minimapa.`nCertifique-se de que o a área está 100% visível e tente novamente.", "There was a problem locating Minimap floor.`nMake sure that the area 100% visible and try again.")
                    msgbox_image(msg, "Data\Files\Images\GUI\Others\minimap_floor.png", txt("3", "2"))

                    Reload()
                    return
                }

            }
        }

        minimapFloorX := _search.getX() - 5
            , minimapFloorY1 := _search.getY() - 5
            , minimapFloorY2 := _search.getY() + 69
        return
    }

    /**
    * @return ?_Coordinate
    * @throws
    */
    searchMinimapFloor() {
        if (isTibia13() = false) {
            return
        }

        minimapArea := new _MinimapArea()

        Loop, 3 {
            _search := new _ImageSearch()
                .setFile("minimap_floor_pointer_" A_Index)
                .setFolder(ImagesConfig.minimapFolder)
                .setVariation(30)
                .setCoordinates(minimapArea.getFloorArea())
                .search()

            if (_search.found()) {
                break
            }
        }

        if (_search.notFound()) {
            throw Exception("Error to find floor level, probably moved the minimap to another position.`n`nReopen the bot and try again.")
        }

        return _search.getResult()
    }

    tryToGetNewMemoryAddresses() {
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

    isInvalidFloor(level := "")
    {
        invalidFloor := (level < 0 OR level > 15)
        ; if (posx != "" && !invalidFloor) {
        ;     return posx = 0
        ; }

        return invalidFloor
    }

    getMinimapFloorLevelMemory() {
        static triedToGetNewMemory

        this.checkinjectClientMemory()

        level := MemoryManager.readPosZ()
        invalidFloor := this.isInvalidFloor(level)
        if (invalidFloor = true) {
            if (triedToGetNewMemory) {
                return
            }

            triedToGetNewMemory := true
            if (this.tryToGetNewMemoryAddresses() = true) {
                level := MemoryManager.readPosZ()
                invalidFloor := this.isInvalidFloor(level)
            }
        }

        _CharCoordinate.guardAgainstInvalidMemoryCoordinates(level, invalidFloor)

        return level
    }


    getMinimapFloorLevel() {
        if (CavebotScript.isMarker()) {
            return
        }

        if (scriptSettingsObj.charCoordsFromMemory = true) {
            try posz := this.getMinimapFloorLevelMemory()
            catch e {
                throw e
            }

            return posz
        }

        if (!OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection) {
            return posz = "" ? "07" : posz
        }

        minimapArea := new _MinimapArea()

        ; if (minimapFloorY1 = "") {
        ;     if (scriptSettingsObj.charCoordsFromMemory = true) {
        ;         if (OldBotSettings.settingsJsonObj.settings.cavebot.getCharCoordinatesFromMemory = true)
        ;                 && (scriptSettingsObj.charCoordsFromMemory = false) {
        ;                 throw Exception(txt("Posição do minimapa não definida.`n`nMarque a opção de ""Coordenadas do char da memória do cliente"" na tela do Cavebot e tente novamente", "Minimap position not set.`n`nCheck the option ""Character coordinates from client memory"" and try again."))
        ;         }
        ;         throw Exception("No minimap floor position defined.")
        ;     }
        ; }

        try vars := this.searchMinimapFloor()
        catch e {
            throw e
        }

        if (!vars.x) {
            throw Exception("Failed to find minimap floor")
        }

        floor_position_y := vars.y - minimapFloorY1

        level := ""
        switch floor_position_y {
            case "6": level := "7"
            case "10": level := "6"
            case "14": level := "5"
            case "18": level := "4"
            case "22": level := "3"
            case "26": level := "2"
            case "30": level := "1"
            case "34": level := "0"
            case "38": level := "-1"
            case "42": level := "-2"
            case "46": level := "-3"
            case "50": level := "-4"
            case "54": level := "-5"
            case "58": level := "-6"
            case "62": level := "-7"
            case "65", case "66": level := "-8"
        }

        if (level = "") {
            throw Exception( txt("Erro ao definir o floor level. Selecione o cliente do OT Server que voce esta usando no botao ""Selecionar Client"".`n`nCaso voce nao encontre na lista, clique no botao ""Adicionar novo cliente"" em baixo da lista.", "Error to define the floor level. Select the client of the OT server you are using in the ""Select Client"" button.`n`nIn case you don't find the client on the list, click on the ""Add new client"" button below the list.") "`n`n[ Info: ] " "`nSelected Client: " OldBotSettings.settingsJsonObj.configFile "`nExe name: " TibiaClientExeName "`nWindow: " TibiaClientTitle)
        }

        ; MouseMove, FloorX, FloorY
        ; msgbox, % floor_position_y "  /  " level
        try
            return this.fixFloorLevelString(level)
        catch e
            throw e
    }

    /**
    calculate how many sqms away from the char is a position of the screen
    return the amount of x and y sqms
    */
    getSqmDistanceByScreenPos(screenPosX, screenPosY) {
        static charPosition
        if (!charPosition) {
            charPosition := new _CharPosition()
        }

        return new _Coordinate(charPosition.getX(),  charPosition.getY())
            .subX(screenPosX)
            .subY(screenPosY)
            .div(new _GameWindowArea().getSqmSize())
    }
    /**
    return the x and y coords from a position of the screen
    */
    getMapCoordByScreenPos(screenPosX, screenPosY, getPos := true) {
        sqmsDist := this.getSqmDistanceByScreenPos(screenPosX, screenPosY)

        if (getPos) {
            getCharPos()
        }

        if (sqmsDist.x < 0)
            coordX := posx + abs(sqmsDist.x)
        else
            coordX := posx - sqmsDist.x
        if (sqmsDist.y < 0)
            coordY := posy + abs(sqmsDist.y)
        else
            coordY := posy - sqmsDist.y

        return {x: coordX, y: coordY, z: posz}
    }

    /**
    return the real map coordinates of a sqm around
    */
    getMapCoordBySqmAround(SQM) {
        switch SQM {
            case 1: return {x: posx - 1, y: posy + 1}
            case 2: return {x: posx, y: posy + 1}
            case 3: return {x: posx + 1, y: posy + 1}
            case 4: return {x: posx - 1, y: posy }
            case 5: return {x: posx, y: posy}
            case 6: return {x: posx + 1, y: posy}
            case 7: return {x: posx - 1 , y: posy - 1}
            case 8: return {x: posx, y: posy - 1}
            case 9: return {x: posx + 1, y: posy - 1}
            default:
                throw Exception(A_ThisFunc ": Invalid SQM around")
        }
    }

    /**
    * returns the real position on screen of the coordinate's SQM
    * @param int coordX
    * @param int coordY
    * @return _Coordinate
    * @throws
    */
    getSqmPosByMapCoord(coordX, coordY) {
        coords := this.realCoordsToMinimapRelative(coordX, coordY)
        if (abs(coords.X) > 40) OR (abs(coords.Y) > 22) {
            throw Exception("SQM too distant, distance x:" coords.X ", y:" coords.Y ".")
        }

        coordsX := coords.X
            , coordsY := coords.Y

            , widthSQM := SQM_SQUARE_GUI * rangeWidth
            , heightSQM := SQM_SQUARE_GUI * rangeHeight


        SQMX := CHAR_POS_X - (SQM_SIZE / 2)
        if (coordsX < 0)
            SQMX -= SQM_SIZE * abs(coordsX)
        else
            SQMX += SQM_SIZE * coordsX

        SQMY := CHAR_POS_Y - (SQM_SIZE / 2)
        if (coordsY < 0)
            SQMY -= SQM_SIZE * abs(coordsY)
        else
            SQMY += SQM_SIZE * coordsY

        ; adjust to the center
        SQMX += SQM_SIZE / 2
        SQMY += SQM_SIZE / 2

        return new _Coordinate(SQMX, SQMY)
    }

    getDirectionBySQM(SQM)
    {
        switch SQM {
            case "8": return "Up"
            case "2": return "Down"
            case "4": return "Left"
            case "6": return "Right"
        }
    }

    getSQMByMinimapDirection(XAxis, YAxis)
    {
        if (XAxis > 1)
            throw Exception("XAxis(" XAxis ") higher 1")
        if (YAxis > 1)
            throw Exception("YAxis(" YAxis ") higher 1")
        if (XAxis < -1)
            throw Exception("XAxis(" XAxis ") lower than -1")
        if (YAxis < -1)
            throw Exception("YAxis(" YAxis ") lower than -1")

        switch XAxis {
            case 0:
                switch YAxis {
                    case 0: return 5
                    case 1: return 2
                    case -1: return 8
                }
            case 1:
                switch YAxis {
                    case 0: return 6
                    case 1: return 3
                    case -1: return 9
                }

            case -1:
                switch YAxis {
                    case 0: return 4
                    case 1: return 1
                    case -1: return 7
                }
        }

    }

    clickOnSQM(SQM, ClickButton := "") {
        ClickButton := ClickButton = "" ? "Left" : ClickButton

        MouseClick(ClickButton, SQM%SQM%X, SQM%SQM%Y, debug := false)

        ; Send(direction)
        return
    }

    realCoordsToMinimapRelative(coordX, coordY) {
        return {"X": coordX - posx, "Y": coordY - posy}
    }

    isCoordVisibleMinimap(coordX, coordY) {
        distance := this.distanceCoordFromCharPos(coordX, coordY)
        ; m(serialize(distance))

        switch isTibia13() {
            case true:
                if (distance.x >= 51)
                    return false
                if (distance.y >= 52)
                    return false

                /**
                OTClientV8
                */
            case false:
                if (distance.x >= 80)
                    return false
                if (distance.y >= 80)
                    return false

        }
        return true
    }

    distanceCoordFromOtherCoord(fromCoordX, fromCoordY, coordX, coordY) {
        return {x: abs(fromCoordX - coordX), y: abs(fromCoordY - coordY)}
    }

    distanceCoordFromCharPos(coordX, coordY) {
        return {x: abs(posx - coordX), y: abs(posy - coordY)}
    }

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

        if (this.isCoordVisibleMinimap(coordX, coordY) = false) {
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

        if (isTibia13() && !isRubinot()) {
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

    /**
    * Convert a pixel position on minimap screen to real coord
    * Example: MinimapAreaX1 + 5 (5 pixels from the start of the minimap area)
    * @param coordX int
    * @param coordY int
    * @param _MinimapArea minimapArea
    * @return object
    */
    minimapToRealCoords(coordX, coordY, minimapArea) {
        return {"X": (posx - minimapArea.getCenterRelative().getX()) + coordX, "Y": (posy - minimapArea.getCenterRelative().getY()) + coordY}
    }

    isInWaypointRange(coordX, coordY, rangeX, rangeY) {
        if (this.isInRangeArea(posx, coordX, coordX + rangeX - 1) && this.isInRangeArea(posy, coordY, coordY + rangeY - 1))
            return true
        return false
    }

    isInRangeArea(value, low, high) {
        ; msgbox, % value " = " low " OR " high
        if (value = low OR value = high)
            return true
        if value between %low% and %high%
            return true
        return false
    }

    markerStatusBarIcon() {
        if (!waypointsObj[tab][Waypoint].image) {
            SB_SetIcon(ImagesConfig.minimapMarkersFolder "\GUI\Statusbar\mark" waypointsObj[tab][Waypoint].marker ".png", 0, charPositionPart)
            return
        }

        try {
            waypointImage := new _Base64Image(tab "." Waypoint, waypointsObj[tab][Waypoint].image)
            SB_SetIcon("HBITMAP:" waypointImage.getHBitmap(), 0, charPositionPart)
        } catch e {
            writeCavebotLog("ERROR", "Failed to update status bar waypoint icon: " e.Message " | " e.What)
        }
    }

    /**
    * @return void
    */
    beforePerformUseActionSqm()
    {
        /**
        * Stop walking and get current char position to use sqms etc precisely
        */
        Loop, 2 {
            Send("Esc")
            Sleep, 200
        }

        getCharPos()
    }

    /**
    * @return void
    */
    arrivedAtWaypointAction()
    {
        type := WaypointHandler.getAtribute("type", Waypoint, Tab)

        switch type {
            case "Walk", case "Stand", case "Node":
                return
        }

        targetingSystemObj.targetingDisabledAction := true
            , targetingSystemObj.targetingDisabledActionReason := type
        this.changeFloorDelay := 500

        this.beforePerformUseActionSqm()


        coordinate := _MapCoordinate.FROM_CAVEBOT()
        sqmPosition := coordinate.getSqmPosition()

        /**
        need to handle a situation where it has considered as arrived while walking,
        but for some reason the char walks another sqm
        */
        switch type {
            case "Rope":
                    new _UseChangeFloorItem(coordinate, "rope")

            case "Shovel":
                    new _UseChangeFloorItem(coordinate, "shovel")

            case "Machete":
                    new _UseItemOnSqm(sqmPosition, "Machete")

            case "Use":
                try {
                        new _UseSqm(sqmPosition)
                } catch {
                }

                Sleep, % this.changeFloorDelay

            case "Door": ; try to walk to the coord, if fail, use SQM then try again, try to do this 3 times
                sqmPosition.click()
                MouseClick("Left", sqmPosArray.x, sqmPosArray.y)
                Sleep, 400
                tries := 0
                Loop 3 {
                    getCharPos()
                    if (isSameCharCoords(mapX, mapY, mapZ) = true)
                        return

                    walkToCoord(mapX, mapY)
                    ; if (walkToCoord(mapX, mapY) = true)
                    ; return

                        new _UseSqm(sqmPosition, "door")
                    /**
                    on experience gate doors where the char walks automatically to the door sqm when using
                    must check if it is inside the door before clicking on the door sqm
                    */
                    Loop, 3 {
                        if (A_Index = 1)
                            Sleep, 100
                        else
                            Sleep, % elapsedCharPos > 100 ? 100 : elapsedCharPos
                        getCharPos()
                        if (isSameCharCoords(mapX, mapY, mapZ) = true)
                            return
                    }
                    getCharPos()
                    sqmPosition.click()
                    Sleep, % this.changeFloorDelay
                    tries++
                }

                if (tries = 3) {
                    this.checkUseRightClickFallback(sqmPosition)
                }

            case "Ladder", case "Ladder Up":
                this.ladderWaypointAction("Up")

            case "Ladder Down":
                this.ladderWaypointAction("Down")

            case "Stair Up":
                this.stairWaypointAction("Up")

            case "Stair Down":
                this.stairWaypointAction("Down")

        }

        this.updateStatusBarPositionFloorChange()
    }

    updateStatusBarPositionFloorChange() {
        if (!OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection) {
            Gui, CavebotLogs:Default
            SB_SetText(posx "," posy "," posz, charPositionPart)
        }
    }

    arrivedAtWaypointActionMarker() {
        type := WaypointHandler.getAtribute("type", Waypoint, Tab)

        switch type {
            case "Walk", case "Stand", case "Node":
                return
        }
        targetingSystemObj.targetingDisabledAction := true
            , targetingSystemObj.targetingDisabledActionReason := type
        this.changeFloorDelay := 500
        Send("Esc")
        Sleep, 200
        _CavebotByImage.saveLastMinimapPosition()
        ; Gdip_SetBitmapToClipboard(lastCharCoords[lastCharCoords.Count()])
        ; msgbox, a

        /**
        need to handle a situation where it has considered as arrived while walking,
        but for some reason the char walks another sqm
        */
        switch type {
            case "Use":
                try {
                        new _UseSqm(this.getSqmPosMarker())
                } catch {
                }
                Sleep, % this.changeFloorDelay

            case "Ladder":
                this.ladderWaypointAction()

            case "Rope":
                    new _UseChangeFloorItem(_MapCoordinate.FROM_CAVEBOT(), "Rope")

            case "Shovel":
                    new _UseChangeFloorItem(_MapCoordinate.FROM_CAVEBOT(), "Shovel")

            case "Machete":
                if (!new _UseItemOnSqm(this.getSqmPosMarker(), "Machete")){
                    return
                }

            case "Door": ; try to walk to the coord, if fail, use SQM then try again, try to do this 3 times
                return
                sqmPosArray := this.getSqmPosMarker()
                MouseClick("Left", sqmPosArray.x, sqmPosArray.y)
                Sleep, 400
                Loop 3 {
                    getCharPos()
                    if (isSameCharCoords(mapX, mapY, mapZ) = true)
                        return

                    walkToCoord(mapX, mapY)
                    ; if (walkToCoord(mapX, mapY) = true)
                    ; return

                    sqmPosition := this.getSqmPosMarker()
                        new _UseSqm(sqmPosition, "door")
                    /**
                    on experience gate doors where the char walks automatically to the door sqm when using
                    must check if it is inside the door before clicking on the door sqm
                    */
                    Loop, 3 {
                        if (A_Index = 1)
                            Sleep, 100
                        else
                            Sleep, % elapsedCharPos > 100 ? 100 : elapsedCharPos

                        getCharPos()
                        if (isSameCharCoords(mapX, mapY, mapZ) = true)
                            return
                    }
                    ; walkToCoord(mapX, mapY)
                    getCharPos()
                    sqmPosition := this.getSqmPosMarker()
                    MouseClick("Left", sqmPosition.x, sqmPosition.y)
                    Sleep, % this.changeFloorDelay

                }

            case "Ladder", case "Ladder Up":
                this.ladderWaypointAction("Up")

            case "Ladder Down":
                this.ladderWaypointAction("Down")

            case "Stair Up":
                this.stairWaypointAction("Up")

            case "Stair Down":
                this.stairWaypointAction("Down")
        }
    }

    ladderWaypointAction(direction := "Up")
    {
        if (CavebotScript.isMarker()) OR (!OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection) {
            success := this.ladderWaypointActionMarker()
            /**
            set posz as the waypoint one
            */
            if (success = true) && (OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection = false)
                posz := direction = "Up" ? waypointsObj[tab][Waypoint].coordinates.z - 1 : waypointsObj[tab][Waypoint].coordinates.z + 1
            return success
        }

        coordinate := _MapCoordinate.FROM_CAVEBOT()
        sqmPosition := coordinate.getSqmPosition()
        tries := 0
        Loop, 3 {
            if (A_Index > 1) {
                getCharPos()
            }

            if (coordinate.isDifferentFloor()) {
                return true
            }

            if (new _UseSqm(sqmPosition, "ladder")) {
                Sleep, % this.changeFloorDelay
            }

            tries++
        }

        if (tries = 3) {
            this.checkUseRightClickFallback(sqmPosition)

            getCharPos()
            if (coordinate.isDifferentFloor()) {
                return true
            }
        }

        return false
    }

    ladderWaypointActionMarker()
    {
        Sleep, % _Delay.markerStandWaypoint()

        tries := 0

        Loop, 3 {
            _CavebotByImage.saveLastMinimapPosition()

            if (_CavebotByImage.isInTheSameLastPositionMinimap() = false) ; check if the floor changed after climbing the ladder
                return true

            sqmPosition := this.getSqmPosMarker()

            if (new _UseSqm(sqmPosition, "ladder")) {
                Sleep, % this.changeFloorDelay
            }

            if (_CavebotByImage.isInTheSameLastPositionMinimap() = false)
                return true
            tries++
        }
        if (tries = 3) {
            if (this.checkLastTryFloorChangedMarker(sqmPosition) = false)
                return false
        }

        return true
    }

    stairWaypointAction(direction := "Up") {
        if (CavebotScript.isMarker()) OR (!OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection) {
            success := this.stairWaypointActionMarker(direction)
            /**
            set posz as the waypoint one
            */
            if (success = true) && (OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection = false)
                posz := direction = "Up" ? waypointsObj[tab][Waypoint].coordinates.z - 1 : waypointsObj[tab][Waypoint].coordinates.z + 1

            return success
        }

        coordinate := _MapCoordinate.FROM_CAVEBOT()
        sqmPosition := coordinate.getSqmPosition()
        tries := 0
        Loop, 3 {
            if (A_Index > 1)
                getCharPos()
            if (posz != mapZ) ; checar se o andar (floor) mudou após subir a escada
                return true

            writeCavebotLog("Cavebot", "Clicking on the stair SQM")
            sqmPosition.click()

            Sleep, % this.changeFloorDelay * 2

            tries++
        }

        return false
    }

    stairWaypointActionMarker() {

        Sleep, % _Delay.markerStandWaypoint()

        tries := 0
        Loop, 3 {
            _CavebotByImage.saveLastMinimapPosition()

            ; check if the floor changed after climbing the stair
            if (_CavebotByImage.isInTheSameLastPositionMinimap() = false) {
                return true
            }

            sqmPosArray := this.getSqmPosMarker()

            writeCavebotLog("Cavebot", "Clicking on the stair SQM")
            MouseClick("Left", sqmPosArray.x, sqmPosArray.y true)

            Sleep, % this.changeFloorDelay * 2

            if (_CavebotByImage.isInTheSameLastPositionMinimap() = false)
                return true

            tries++
        }
        if (tries = 3) {
            if (this.checkLastTryFloorChangedMarker(sqmPosArray) = false)
                return false
        }

        return true
    }

    checkLastTryFloorChangedMarker(sqmPosArray) {
        _CavebotByImage.saveLastMinimapPosition()
        type := WaypointHandler.getAtribute("type", Waypoint, Tab)

        switch type {
            case "Ladder", case "Ladder Up", case "Ladder Down":
                this.checkUseRightClickFallback(sqmPosArray)
            case "Stair Up", case "Stair Down":
                MouseClick("Left", sqmPosArray.x, sqmPosArray.y, false)
        }

        Sleep, % this.changeFloorDelay
        if (_CavebotByImage.isInTheSameLastPositionMinimap() = true)
            return false
        return true
    }

    dragItemFromSqmToChar(sqmPosArray) {
        if (OldBotSettings.settingsJsonObj.settings.cavebot.dragItemsFromSqmBeforeUsingRopeShovel != true) {
            return
        }

        MouseDrag(sqmPosArray.x, sqmPosArray.y, CHAR_POS_X, CHAR_POS_Y)

        LootingSystem.confirmOkDialogBox()
        Sleep, 50
    }

    /**
    * @return _Coordinate
    */
    getSqmPosMarker() {
        sqmIdentifier := waypointsObj[tab][Waypoint].sqm
        return new _Coordinate(SQM%sqmIdentifier%X, SQM%sqmIdentifier%Y)
    }

    useAction(sqmPosArray, action := "")
    {
        ; msgbox,% serialize(sqmPosArray)
        if (sqmPosArray = false)
            return false
        if (sqmPosArray.x = "") {
            writeCavebotLog("ERROR", "Empty sqm position for action """ action """")
            return false
        }

        switch action {
            case "ladder":
                writeCavebotLog("Cavebot", "Clicking on the ladder SQM")
            case "door":
                writeCavebotLog("Cavebot", "Opening door on SQM")
            case "action":
            default:
                writeCavebotLog("Cavebot", "Use on SQM")
        }

        coords := new _Coordinate(sqmPosArray.x, sqmPosArray.y)

        Loop, 3 {
            try {
                if (coords.clickOnUse()) {
                    return true
                }
            } catch e {
                _Logger.exception(e, A_ThisFunc)
            }
            Sleep, 200
        }

        Send("Esc")
        writeCavebotLog("ERROR", """Use"" option not found")
        return false
    }

    checkUseRightClickFallback(sqmPosArray)
    {
        /**
        In Tibia 12 client, click in "Use" option doesn't work if it's not visible on screen(no window over it),
        in this case, as last resort, we can click manualy in the sqm
        */
        writeCavebotLog("Cavebot", "Right clicking as fallback for ""Use""")
        rightClickUseClassicControl(sqmPosArray.x, sqmPosArray.y, false)
        Sleep, 300
    }

    checkSqmsClosedAroundByLifeBars()
    {
        cavebotSystemObj.blockedCoordinatesByCreatures := "", cavebotSystemObj.blockedCoordinatesByCreatures := {} ; reset the array

        /**
        new flow, if is in protection zone
        dont search for life bars and closed SQMs
        */
        if (OldBotSettings.settingsJsonObj.clientFeatures.walkThroughPlayers) {
            if (isInProtectionZone()) {
                return
            }
        }

        for _, sqm in TargetingSystem.searchLifeBars()
        {
            try sqmCoord := this.getMapCoordBySqmAround(sqm)
            catch {
                writeCavebotLog("ERROR", e.Message)
                continue
            }

            cavebotSystemObj.blockedCoordinatesByCreatures[sqmCoord.x, sqmCoord.y, posz] := true
        }
    }

    checkLastCharCoordsArrayTooBig() {
        if (lastCharCoords.Count() < 10)
            return
        lastCoordsBackup := {}
            , lastCoordsBackup.x := lastCharCoords[lastCharCoords.Count()].x
            , lastCoordsBackup.y := lastCharCoords[lastCharCoords.Count()].y
            , lastCoordsBackup.z := lastCharCoords[lastCharCoords.Count()].z

        lastCharCoords := ""
            , lastCharCoords := {}
            , lastCharCoords.Push(Object("X", lastCoordsBackup.x, "Y", lastCoordsBackup.y, "Z", lastCoordsBackup.z))
            , lastCoordsBackup := ""
    }

    isSameCoords(coordX, coordY, coordZ, isSameCoordX, isSameCoordY, isSameCoordZ) {
        if (CavebotScript.isMarker())
            return false

        if (coordX = isSameCoordX && coordY = isSameCoordY && coordZ = isSameCoordZ) {
            return true
        }
        return false
    }

    walkDistX()
    {
        if (this.distX < 0) {
            writeCavebotLog("Cavebot", txt("Caminhando na direção: ", "Walking towards direction: ") "right (delay: " this.realDelay " ms)")
            Send("Right")
            Sleep, % this.realDelay ;  little delay to wait for the char to move
            return
        }

        if (this.distX > 0) {
            writeCavebotLog("Cavebot", txt("Caminhando na direção: ", "Walking towards direction: ") "left (delay: " this.realDelay " ms)")
            Send("Left")
            Sleep, % this.realDelay ;  little delay to wait for the char to move
            return
        }
    }

    walkDistY()
    {
        if (this.distY < 0) {
            writeCavebotLog("Cavebot", txt("Caminhando na direção: ", "Walking towards direction: ") "down (delay: " this.realDelay " ms)")
            Send("Down")
            Sleep, % this.realDelay ;  little delay to wait for the char to move
            return
        }

        if (this.distY > 0) {
            writeCavebotLog("Cavebot", txt("Caminhando na direção: ", "Walking towards direction: ") "up (delay: " this.realDelay " ms)")
            Send("Up")
            Sleep, % this.realDelay ;  little delay to wait for the char to move
            return
        }
    }

    checkIfWasTooFarAndNowWaypointIsVisible(mapX, mapY) {
        if (cavebotSystemObj.forceWalk = true && cavebotSystemObj.forceWalkReason = "CoordNotVisible" && (this.isCoordVisibleMinimap(mapX, mapY) = true)) {
            writeCavebotLog("Cavebot", txt("Waypoint visível novamente, abortando walk pelas setas", "Waypoint visible again, aborting arrow walk") )
                , cavebotSystemObj.forceWalk := false
            return true
        }
        return false
    }

    checkWalkArrowTime() {
        if (cavebotSystemObj.timeWalkingWaypointArrow > this.walkByArrowLimit) {
            writeCavebotLog("Cavebot - WARNING",txt("Mais de " this.walkByArrowLimit " segundos caminhando pelas setas, pulando waypoint", "More than " this.walkByArrowLimit " seconds walking by arrow, skipping waypoint"), true)
            return false
        }

        return true
    }

    sleepWalkArrowDelay() {
        realDelay := new _CavebotSettings().get("walkArrowDelay") + (isTibia13() ? 0 : 100)
        Sleep, % realDelay ;  little delay to wait for the char to move
    }

    checkEnableForceWalkByClicksOnWaypoint() {
        if (cavebotSystemObj.clicksOnSameCharPosition >= 3) {
            cavebotSystemObj.forceWalk := true
            cavebotSystemObj.forceWalkReason := "cavebotSystemObj.clicksOnSameCharPosition >= 3"
            return true
        }

        return false
    }

    runBeforeWaypointAction() {
        if (!waypointsObj.HasKey("Special"))
            return

        ActionScript.runactionwaypoint({1: "BeforeWaypoint", 2: "Special"}, log := false)
    }

    runAfterWaypointAction() {
        if (!waypointsObj.HasKey("Special"))
            return

        ActionScript.runactionwaypoint({1: "AfterWaypoint", 2: "Special"}, log := false)
    }

    /**
    * @return bool
    */
    couldDependOnMinimapWithCorrectZoom()
    {
        if (CavebotEnabled) {
            return true
        }

        if (lootingObj.settings.lootCreaturesPosition) {
            return true
        }

        return false
    }


    walkToWaypointMarkerClick() {
        if (isDisconnected()) {
            Sleep, 2000
            return
        }

        ; SetTimer, checkStoppedOnWaypointTimer, Delete
        cavebotSystemObj.clicksOnSameCharPosition := 0 ; variable to control if clicked on the same waypoint and being in the same position
        _CavebotByImage.saveLastMinimapPosition()

        _CavebotByImage.clickOnMarker()


        if (cavebotSystemObj.forceWalk) {
            return
        }

        Sleep, 400
        ; SetTimer, checkStoppedOnWaypointTimer, Delete
        ; SetTimer, checkStoppedOnWaypointTimer, % (CavebotScript.isMarker()) ? CavebotSystem.cavebotJsonObj.options.checkStoppedInterval : cavebotSystemObj.checkStoppedOnWaypointTimerDelay

        Loop, {
            if (isDisconnected()) {
                Sleep, 2000
                return
            }
            /**
            if walks 45 seconds to the same waypoint, force walk on arrow
            */
            if (cavebotSystemObj.timeWalkingWaypoint >= 45) {
                Send("Esc")
                Sleep, 50
                cavebotSystemObj.forceWalk := true
                cavebotSystemObj.forceWalkReason := "TimeWalkingToWaypoint"
                ; SetTimer, checkStoppedOnWaypointTimer, Delete
                return
            }
            ; Tooltip, % A_Index
            ; msgbox, % cavebotSystemObj["waypoints"][tab][Waypoint].arrived "`n`n" checkArrivedOnCoord(mapX, mapY, mapZ)
            if (cavebotSystemObj.forceWalk = true) {
                ; msgbox, b
                ; SetTimer, walkingToWaypointTimer, Delete
                ; SetTimer, checkStoppedOnWaypointTimer, Delete
                return ; retorntar para a função essa função seja chamada novamente e ande pelas setas
            }


            t1charpos := A_TickCount

            if (_CavebotByImage.checkArrivedOnMarker() = true) {
                ; SetTimer, walkingToWaypointTimer, Delete
                ; SetTimer, checkStoppedOnWaypointTimer, Delete
                return
            }
            Gui, CavebotLogs:Default
            Random, R, 0, 10 ; randomize the result a bit to differenciate visually everytime it checks
            elapsedCharPos := A_TickCount -  t1charpos
            ; SB_SetIcon("Data\Files\Images\Cavebot\Marks\Background\mark" waypointsObj[tab][Waypoint].marker ".png", 0, charPositionPart)
            SB_SetText( (vars.x = "" ? "Waypoint: " Waypoint "..." : "Stopped.") " (" elapsedCharPos + R " ms)", charPositionPart)
            sleep, 200
        }
        return
    }

}