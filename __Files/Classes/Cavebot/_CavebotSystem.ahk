global cavebotSystemObj

global logsFile

global sessionHour
global sessionMinute
global sessionSecond

global stringCoordsObj
global stringCoords



/*
set equipment positions
*/
global helmetX
global helmetY
global backpackX
global backpackY
global amuletX
global amuletY
global armorX
global armorY
global handX
global handY
global shieldX
global shieldY
global legsX
global legsY
global ringX
global ringY
global arrowX
global arrowY
global bootsX
global bootsY

/*
char position variables
*/
global CHAR_POS_X
global CHAR_POS_Y
global CharArea1X
global CharArea1Y
global CharArea2X
global CharArea2Y


/*
Cavebot logs window params
must not be inside function otherwise will bug the logs
*/
global hSB
global hCavebotLogsEdit
global CavebotLogsHWND
global CavebotLogsMinimized


global ERRORS_LOG
global ERRORS_COUNTER
global COUNT_ICON
global ICON_COUNTER
global fast_creation
global cavebotPart
global cavebotIconDll
global cavebotIconNumber
global targetingPart
global targetingIconDll
global targetingIconNumber
global lootingPart
global lootingIconDll
global lootingIconNumber
global reloadPart
global pausePart
global errorsCounterPart
global charPositionPart
global sessionCounterPart
global enabledIconDll
global enabledIconNumber
global disabledIconDll
global disabledIconNumber
global targetNotReleasedIcon


/*
SQMS
*/
global SQM1X
global SQM1Y
global SQM1X_X1
global SQM2X
global SQM2Y
global SQM3X
global SQM3Y
global SQM2X_X1
global SQM3X_X1
global SQM4X
global SQM4Y
global SQM5X
global SQM5Y
global SQM6X
global SQM6Y
global SQM4X_X1
global SQM5X_X1
global SQM6X_X1
global SQM7X
global SQM7Y
global SQM8X
global SQM8Y
global SQM9X
global SQM9Y
global SQM7X_X1
global SQM8X_X1
global SQM9X_X1
global SQM1X_X1, SQM1Y_Y1, SQM1X_X2, SQM1Y_Y2
global SQM2X_X1, SQM2Y_Y1, SQM2X_X2, SQM2Y_Y2
global SQM3X_X1, SQM3Y_Y1, SQM3X_X2, SQM3Y_Y2
global SQM4X_X1, SQM4Y_Y1, SQM4X_X2, SQM4Y_Y2
global SQM5X_X1, SQM5Y_Y1, SQM5X_X2, SQM5Y_Y2
global SQM6X_X1, SQM6Y_Y1, SQM6X_X2, SQM6Y_Y2
global SQM7X_X1, SQM7Y_Y1, SQM7X_X2, SQM7Y_Y2
global SQM8X_X1, SQM8Y_Y1, SQM8X_X2, SQM8Y_Y2
global SQM9X_X1, SQM9Y_Y1, SQM9X_X2, SQM9Y_Y2

/*
ini settings
*/
global higherMapTolerancyPositionSearch


Class _CavebotSystem
{
    __New()
    {
        global

        cavebotSystemObj := {}

        cavebotSystemObj.waypoints := {}
        cavebotSystemObj.blockedCoordinates := {}
        cavebotSystemObj.blockedCoordinatesByCreatures := {}

        cavebotSystemObj.checkDisconnected := true
        cavebotSystemObj.tradeWindowWithSearchBox := false

        cavebotSystemObj.triesWalkLimit := 15
        cavebotSystemObj.clicksOnWaypointLimit := 30
        cavebotSystemObj.clicksOnWaypointTrappedLimit := 40
        cavebotSystemObj.scrollDownLimit := 60
        cavebotSystemObj.scrollDownSellLimit := 20
        if (OldBotSettings.settingsJsonObj.settings.cavebot.tradeWindowSummerUpdate1290 = true) {
            cavebotSystemObj.scrollDownLimit := 5
            cavebotSystemObj.scrollDownSellLimit := 2
            cavebotSystemObj.tradeWindowWithSearchBox := true
        }
        cavebotSystemObj.buyItemDelay := 1100
        cavebotSystemObj.sellItemTimesLimit := 50
        cavebotSystemObj.sellAllItemsLimit := 1000


        this.pauseHotkeys := {}
        this.pauseHotkeys.Push("Delete")
        this.pauseHotkeys.Push("End")
        this.pauseHotkeys.Push("Home")
        this.pauseHotkeys.Push("Insert")
        this.pauseHotkeys.Push("Mouse Forward Button")
        this.pauseHotkeys.Push("Mouse Back Button")
        this.pauseHotkeys.Push("Mouse Scroll Button")
        this.pauseHotkeys.Push("Page Down")
        this.pauseHotkeys.Push("Page Up")
        /*
        for some reason Shift + PauseBreak does not work
        */
        ;this.pauseHotkeys.Push("PauseBreak")


        cavebotSystemObj.depositItemLimit := 100

        this.readIniCavebotGlobalSettings()

        this.cavebotJsonSetup()

        this.invervalSessionHourCheck := (60) * 1000
        this.sessionHourCheckCooldown := 0


        this.specialLabels := {}
        this.specialLabels.Push("BeforeWaypoint")
        this.specialLabels.Push("AfterWaypoint")
        this.specialLabels.Push("AfterAttack")
        this.specialLabels.Push("AfterStopAttack")
        this.specialLabels.Push("BeforeAttack")
        this.specialLabels.Push("BeforeLooting")
        this.specialLabels.Push("BeforeLootingQueue")
        this.specialLabels.Push("AfterLooting")
        this.specialLabels.Push("AfterLootingQueue")
        this.specialLabels.Push("IsTrapped")
        this.specialLabels.Push("Navigation")

        /*
        35 or higher is finding honeycomb in the action bar
        */
        this.itemSearchActionBarVariation := 40


    }

    cavebotJsonSetup()
    {
        try this.cavebotJsonObj := OldBotSettings.loadModuleJsonSettingsFile("cavebot")
        catch e {
            Msgbox, 16, % e.What, % e.Message, 30
            ExitApp
        }

        try this.validateCavebotJsonSettings()
        catch e {
            Msgbox, 16, % e.What, % e.Message, 30
            ExitApp
        }

        if (this.cavebotJsonObj.options.debug = true) {
            ; ClipBoard := serialize(this.cavebotJsonObj)
            ; msgbox, % ClipBoard
        }
    }

    checkDefaultJsonCategories() {

        this.categories := {}
        this.categories.Push("coordinates")
        this.categories.Push("images")
        this.categories.Push({"minimap": ["images", "areaSetup", "options"]})
        this.categories.Push({"settings": ["capacity","level","soulpoints","stamina"]})
        this.categories.Push("options")

        for key, category in this.categories
        {
            if (!IsObject(this.cavebotJsonObj[category]))
                this.cavebotJsonObj[category] := {}

            if (IsObject(category)) {
                for key2, subCategories1 in category
                {
                    if (!IsObject(this.cavebotJsonObj[key2]))
                        this.cavebotJsonObj[key2] := {}
                    for key3, subCategories2 in subCategories1
                    {
                        ; msgbox, % key3 "`na:" subCategories2 "`nb:" serialize(subCategories2)
                        /*
                        to not create an object as key
                        */
                        if (!IsObject(subCategories2)) {
                            if (!IsObject(this.cavebotJsonObj[key2][subCategories2]))
                                this.cavebotJsonObj[key2][subCategories2] := {}
                        }

                        for key4, subCategories3 in subCategories2
                        {
                            ; m( "key2: " key2 "`n" "key4: "  key4 "`n" "`na: " subCategories3 "`nb: " serialize(subCategories3) "`n`nc:" serialize(this.cavebotJsonObj[key2][key4]) )
                            if (!IsObject(this.cavebotJsonObj[key2][key4])) {
                                ; m(key2 "/"  key4 "/" subCategories3 "`n`n" serialize(this.cavebotJsonObj[key2]))
                                this.cavebotJsonObj[key2][key4] := {}
                            }

                            for key5, subCategories4 in subCategories3
                            {
                                ; m("key2: " key2 "`n" "key4: " key4 "`n" "`na: " subCategories4 "`nb: " serialize(subCategories4) "`n`nc:" serialize(this.cavebotJsonObj[key2]))
                                if (!IsObject(this.cavebotJsonObj[key2][key4][subCategories4])) {
                                    ; m(key2 "/"  key4 "/" subCategories4 "`n`n" serialize(this.cavebotJsonObj[key2][key4]))
                                    this.cavebotJsonObj[key2][key4][subCategories4] := {}
                                }

                            }

                        }
                    }
                }
            }
        }
        ; msgbox, % serialize(this.cavebotJsonObj["minimap"])
    }

    validateCavebotJsonSettings() {
        if (this.cavebotJsonObj = "")
            Throw Exception("Empty cavebot.json settings", A_ThisFunc)

        this.checkDefaultJsonCategories()

        /*
        coordinates
        */
        this.cavebotJsonObj.coordinates.offsetX := this.cavebotJsonObj.coordinates.offsetX = "" ? 0 : this.cavebotJsonObj.coordinates.offsetX
        this.cavebotJsonObj.coordinates.offsetY := this.cavebotJsonObj.coordinates.offsetY = "" ? 0 : this.cavebotJsonObj.coordinates.offsetY
        this.cavebotJsonObj.coordinates.offsetClickX := this.cavebotJsonObj.coordinates.offsetClickX = "" ? 0 : this.cavebotJsonObj.coordinates.offsetClickX
        this.cavebotJsonObj.coordinates.offsetClickY := this.cavebotJsonObj.coordinates.offsetClickY = "" ? 0 : this.cavebotJsonObj.coordinates.offsetClickY

        /*
        images
        */
        this.cavebotJsonObj.images.protectionZone := this.cavebotJsonObj.images.protectionZone = "" ? "pz_zone.png" : this.cavebotJsonObj.images.protectionZone
        this.cavebotJsonObj.images.protectionZoneVariation := this.cavebotJsonObj.images.protectionZoneVariation = "" ? 30 : this.cavebotJsonObj.images.protectionZoneVariation

        /*
        minimap
        */
        /*
        areaSetup
        */
        this.cavebotJsonObj.minimap.areaSetup.baseImage := this.cavebotJsonObj.minimap.areaSetup.baseImage = "" ? "zoom_minus.png" : this.cavebotJsonObj.minimap.areaSetup.baseImage
        this.cavebotJsonObj.minimap.areaSetup.baseImageVariation := this.cavebotJsonObj.minimap.areaSetup.baseImageVariation = "" ? 30 : this.cavebotJsonObj.minimap.areaSetup.baseImageVariation
        this.cavebotJsonObj.minimap.areaSetup.offsetFromBaseImagePositionX := this.cavebotJsonObj.minimap.areaSetup.offsetFromBaseImagePositionX = "" ? -118 : this.cavebotJsonObj.minimap.areaSetup.offsetFromBaseImagePositionX
        this.cavebotJsonObj.minimap.areaSetup.offsetFromBaseImagePositionY := this.cavebotJsonObj.minimap.areaSetup.offsetFromBaseImagePositionY = "" ? -51 : this.cavebotJsonObj.minimap.areaSetup.offsetFromBaseImagePositionY
        this.cavebotJsonObj.minimap.areaSetup.offsetHeightAdjustX := this.cavebotJsonObj.minimap.areaSetup.offsetHeightAdjustX = "" ? 0 : this.cavebotJsonObj.minimap.areaSetup.offsetHeightAdjustX
        this.cavebotJsonObj.minimap.areaSetup.offsetHeightAdjustY := this.cavebotJsonObj.minimap.areaSetup.offsetHeightAdjustY = "" ? 3 : this.cavebotJsonObj.minimap.areaSetup.offsetHeightAdjustY
        this.cavebotJsonObj.minimap.areaSetup.offsetHeightAfterAdjust := this.cavebotJsonObj.minimap.areaSetup.offsetHeightAfterAdjust = "" ? 0: this.cavebotJsonObj.minimap.areaSetup.offsetHeightAfterAdjust

        this.cavebotJsonObj.minimap.areaSetup.widthImageVariation := this.cavebotJsonObj.minimap.areaSetup.widthImageVariation = "" ? 50 : this.cavebotJsonObj.minimap.areaSetup.widthImageVariation
        this.cavebotJsonObj.minimap.areaSetup.heightImageVariation := this.cavebotJsonObj.minimap.areaSetup.heightImageVariation = "" ? 50 : this.cavebotJsonObj.minimap.areaSetup.heightImageVariation

        /*
        options
        */
        this.cavebotJsonObj.options.walkWithMapClicks := this.cavebotJsonObj.options.walkWithMapClicks = "" ? true : this.cavebotJsonObj.options.walkWithMapClicks
        this.cavebotJsonObj.options.checkStoppedInterval := this.cavebotJsonObj.options.checkStoppedInterval = "" ? 800 : this.cavebotJsonObj.options.checkStoppedInterval
        this.cavebotJsonObj.options.checkStoppedInterval := this.cavebotJsonObj.options.checkStoppedInterval < 300 ? 300 : this.cavebotJsonObj.options.checkStoppedInterval


        /*
        settings
        */
        this.cavebotJsonObj.settings.items.offsetFromItemX := this.cavebotJsonObj.settings.items.offsetFromItemX = "" ? 120 : this.cavebotJsonObj.settings.items.offsetFromItemX
        this.cavebotJsonObj.settings.items.offsetFromItemY := this.cavebotJsonObj.settings.items.offsetFromItemY = "" ? -2 : this.cavebotJsonObj.settings.items.offsetFromItemY

        this.cavebotJsonObj.settings.capacity.offsetFromImageX := this.cavebotJsonObj.settings.capacity.offsetFromImageX = "" ? 100 : this.cavebotJsonObj.settings.capacity.offsetFromImageX
        this.cavebotJsonObj.settings.capacity.offsetFromImageY := this.cavebotJsonObj.settings.capacity.offsetFromImageY = "" ? -2 : this.cavebotJsonObj.settings.capacity.offsetFromImageY
        this.cavebotJsonObj.settings.level.offsetFromImageX := this.cavebotJsonObj.settings.level.offsetFromImageX = "" ? 110 : this.cavebotJsonObj.settings.level.offsetFromImageX
        this.cavebotJsonObj.settings.level.offsetFromImageY := this.cavebotJsonObj.settings.level.offsetFromImageY = "" ? -2 : this.cavebotJsonObj.settings.level.offsetFromImageY
        this.cavebotJsonObj.settings.soulPoints.offsetFromImageX := this.cavebotJsonObj.settings.soulPoints.offsetFromImageX = "" ? 110 : this.cavebotJsonObj.settings.soulPoints.offsetFromImageX
        this.cavebotJsonObj.settings.soulPoints.offsetFromImageY := this.cavebotJsonObj.settings.soulPoints.offsetFromImageY = "" ? -2 : this.cavebotJsonObj.settings.soulPoints.offsetFromImageY
        this.cavebotJsonObj.settings.stamina.offsetFromImageX := this.cavebotJsonObj.settings.stamina.offsetFromImageX = "" ? 110 : this.cavebotJsonObj.settings.stamina.offsetFromImageX
        this.cavebotJsonObj.settings.stamina.offsetFromImageY := this.cavebotJsonObj.settings.stamina.offsetFromImageY = "" ? -2 : this.cavebotJsonObj.settings.stamina.offsetFromImageY

    }

    cavebotLogsWindowParams() {
        global ERRORS_LOG := {}
        global ERRORS_COUNTER := 0
        global COUNT_ICON := false
        global ICON_COUNTER = 0 ; variável que controla quantos itens foram criados com a função GuiButtonICon junto da interface, para ser usado no label DeleteIconsFromMemory e não dar memory leak sempre que abre a GUI
        global fast_creation := false



        /*
        Status bar variables
        */
        global cavebotPart := 1
        global cavebotIconDll := "ieframe.dll"
        global cavebotIconNumber := 35
        global targetingPart := cavebotPart + 1
        global targetingIconDll := "pifmgr.dll"
        global targetingIconNumber := 35
        global lootingPart := targetingPart + 1
        global lootingIconDll := "Data\Files\Images\GUI\Icons\gloves_01a.png"
        global lootingIconNumber := 0

        global reloadPart := lootingPart + 1
        global pausePart := reloadPart + 1
        global errorsCounterPart := pausePart + 1
        global charPositionPart := errorsCounterPart + 1
        global sessionCounterPart := charPositionPart + 1

        global enabledIconDll := "shell32.dll"
        global disabledIconDll := "imageres.dll"

        global enabledIconNumber := (isWin11() = true ) ? 295 : 297
        global disabledIconNumber := (isWin11() = true ) ? 261 : 260

        global targetNotReleasedIcon := false

    }


    setEquipmentPositions() {
        if (isNotTibia13())
            return

        equipmentArea := new _EquipmentArea()

        helmetX := equipmentArea.getX1() + 56
        helmetY := equipmentArea.getY1() + 20

        backpackX := helmetX + 36
        backpackY := helmetY + 16

        amuletX := helmetX - 36
        amuletY := backpackY

        armorX := helmetX
        armorY := helmetY + 36

        handX := amuletX
        handY := armorY + 16

        shieldX := backpackX
        shieldY := helmetY + 46

        ringX := amuletX
        ringY := handY + 36

        legsX := helmetX
        legsY := armorY + 36

        arrowX := backpackX
        arrowY := shieldY + 36

        bootsX := helmetX
        bootsY := legsY + 36
    }


    /**
    * @return void
    */
    adjustMinimap()
    {
        if (!_CavebotWalker.couldDependOnMinimapWithCorrectZoom()) {
            return
        }

        if (CavebotScript.isMarker()) {
            return
        }

        if (CavebotSystem.cavebotJsonObj.minimap.manualAdjust.enabled) {
            this.manualAdjustMinimapZoom()

        }

        if (isRubinot()) {
            this.adjustMinimapRubinot()
            return
        }

        writeCavebotLog("Cavebot", txt("Ajustando zoom do minimap...", "Adjusting minimap zoom..."))
        if (!isTibia13()) {
            this.adjustMinimapOtClient()
            return
        }

        coords := new _MinimapArea().getCoordinates()
        coords.setX2(coords.getX2() + 32)

        _search := new _ImageSearch()
            .setFile("minimap_minus")
            .setFolder(ImagesConfig.minimapFolder)
            .setCoordinates(coords)
            .setVariation(50)
            .setClickOffsets(4)
            .search()

        if (_search.notFound()) {
            return
        }

        _search.click("Left", 3, 50)

        _search.setClickOffsetY(24)
            .click()

        Sleep, 100

        MouseMove(CHAR_POS_X, CHAR_POS_Y)
    }

    adjustMinimapRubinot()
    {
        _search := new _MinimapArea().searchBaseImage()
        if (_search.notFound()) {
            throw Exception(txt("Imagem base do minimap não encontrada, por favor contate o suporte", "Minimap base image not found, please contact support"))
        }

        Loop, 2 {
            _search.getResult()
                .addX(90)
                .addY(30)
                .click()
            Sleep, 50
        }
    }

    /**
    * @return void
    * @throws
    */
    adjustMinimapOtClient()
    {
        if (CavebotSystem.cavebotJsonObj.minimap.manualAdjust.enabled) {
            this.manualAdjustMinimapZoom()
            return
        }

        area := new _CavebotJson().get("options.searchCenterButtonEntireScreen") ? new _WindowArea() : new _MinimapArea()
        coordinates := area.getCoordinates()

        _search := new _ImageSearch()
            .setFile(new _MinimapArea().images("center"))
            .setFolder(ImagesConfig.minimapCenterFolder)
            .setCoordinates(coordinates)
            .setVariation(new _MinimapArea().images("variation"))
            .setClickOffsets(6)
        ; .setDebug(true)
            .search()
            .click()

        if (_search.notFound()) {
            c := new _WindowArea().getCoordinates()

            c := c.getX2()
            coordinates := new _Coordinates(coordinates.getC1(), coordinates.getC2())
                .setX2(c)

            _search.setCoordinates(coordinates)
                .search()
                .click()

            if (_search.notFound()) {
                Throw Exception("Minimap ""Center"" button not found.")
            }
        }

        Sleep, 75

        MouseMove(CHAR_POS_X, CHAR_POS_Y)
    }

    /**
    * @return void
    * @throws
    */
    manualAdjustMinimapZoom()
    {
        button := "plus"
        plusButton := this.searchMinimapZoom(button)
        if (!plusButton.x) {
            throw Exception("Minimap """ button """ button not found.")
        }

        button := "minus"
        minusButton := this.searchMinimapZoom(button)
        if (!minusButton.x) {
            throw Exception("Minimap """ button """ button not found.")
        }

        delay := this.cavebotJsonObj.minimap.manualAdjust.delayBetweenClicks ? this.cavebotJsonObj.minimap.manualAdjust.delayBetweenClicks : 75

        Loop, % this.cavebotJsonObj.minimap.manualAdjust.clicks.plus {
            MouseClick("Left", plusButton.x + 4, plusButton.y + 4)
            Sleep, % delay
        }

        Loop, % this.cavebotJsonObj.minimap.manualAdjust.clicks.minus {
            MouseClick("Left", minusButton.x + 4, minusButton.y + 4)
            Sleep, % delay
        }


        MouseClick("Left", CHAR_POS_X, CHAR_POS_Y)
        Sleep, 25
    }

    checkLootFrames() {
        vars := ""
        try {
            vars := ImageClick({"image": "loot_frames"
                    , "directory": ImagesConfig.clientFolder
                    , "variation": 30
                    , "bitmapScreen": pBitmapClientScreen
                    , "funcOrigin": A_ThisFunc
                    , "debug": false})
        } catch e {
            throw e
        }

        if (!vars.x) {
            return
        }

        Gui,Carregando:Destroy
        Msgbox, 48,, % "Colourised loot frames are enabled in the Tibia client ""Interface"" settings, it must be disabled.`n`nClick on Tibia Client and press Ctrl+P to trigger the check settings function."
        Reload()
    }

    /**
    * @return bool
    */
    searchThereIsNoWay() {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFolder(ImagesConfig.cavebotFolder)
                .setVariation(15)
                .setTransColor("0")
                .setCoordinates(new _GameWindowArea().getConsoleMessagesArea())
        }

        Loop, 3 {
            try {
                _search := searchCache
                    .setFile("there_is_no_way_" A_Index)
                    .search()
            } catch e {
                _Logger.exception(e, A_ThisFunc)
                return false
            }

            if (_search.found()) {
                return true
            }
        }

        return false
    }

    searchSorryNotPossible() {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFolder(ImagesConfig.cavebotFolder)
                .setVariation(15)
                .setTransColor("0")
                .setCoordinates(new _GameWindowArea().getConsoleMessagesArea())
        }

        Loop, 4 {
            try {
                _search := searchCache
                    .setFile("sorry_not_possible_" A_Index)
                    .search()
            } catch e {
                _Logger.exception(e, A_ThisFunc)
                return false
            }

            if (_search.found()) {
                return true
            }
        }

        return false
    }

    readIniCavebotGlobalSettings() {
        global

        IniRead, higherMapTolerancyPositionSearch, %DefaultProfile%, cavebot_settings, higherMapTolerancyPositionSearch, %A_Space%
        /*
        Disabled by default on Tibia 12, enabled by default for all others
        */
        if (higherMapTolerancyPositionSearch = "" OR higherMapTolerancyPositionSearch = A_Space)
            higherMapTolerancyPositionSearch := (isTibia13()) ? 0 : 1
        IniRead, currentFloorLevel, %DefaultProfile%, cavebot_settings, currentFloorLevel, 7
    }

    initialCharacterPosition() {
        if (CavebotScript.isMarker()) OR (CavebotEnabled = 0)
            return

        if (!OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection) {

            posx := ""
            if (scriptSettingsObj.tryToIdentifyFloorLevelOnStart = true) {
                posz := waypointsObj[startTab][startWaypoint].coordinates.z
                writeCavebotLog("Cavebot", "Trying to get first character position, floor level: " posz "...")
                _CharCoordinate.GET()
                ; getCharPos(firstTryCavebot := true)
            }

            if (posx = "")
                this.findFloorLevelOtClient()
            ; writeCavebotLog("WARNING", "Could not detect...")
            writeCavebotLog("Cavebot", "Getting first character position (again)...")
        } else {
            writeCavebotLog("Cavebot", "Getting first character position...")
        }

        _CharCoordinate.GET()
        ; getCharPos()
    }

    findFloorLevelOtClient() {
        _search := new _ImageSearch()
            .setFile("sea_otclientv8")
            .setFolder(ImagesConfig.minimapFolder)
            .setVariation(30)
            .search()

        posz := ""
        if (_search.notFound()) {
            writeCavebotLog("Cavebot", "Could not identify character floor level, specify the floor level manually")

            While (posz = "") {
                this.characterFloorLevelInputbox()
                Sleep, 250
            }

            return true
        }

        posz := "07"

        writeCavebotLog("Cavebot", "Auto detected floor ""posz"": 07...")
        return true
    }

    characterFloorLevelInputbox() {
        if (MinimapGUI.waitingMapViewerFloor = true)
            return
        MinimapGUI.waitingMapViewerFloor := true

        ; m(serialize(waypointsObj[startTab][startWaypoint]))
        MinimapGUI.minimapViewerCavebotGUI()
        MinimapGUI.cropFromMinimapImage(waypointsObj[startTab][startWaypoint].coordinates.x, waypointsObj[startTab][startWaypoint].coordinates.y, waypointsObj[startTab][startWaypoint].coordinates.z)

        return
        m("aaa")
        ; InputBox, floorCharacter, % "Set Character Floor Level", % "Floor could not be detected automatically.`nPlease specify the current floor level:", , 300, 140, X, Y, Font, Timeout, 7
        InputBox, floorCharacter, % "Set Character Floor Level", % "Floor could not be detected automatically.`nPlease specify the current floor level:", , 300, 140

        return floorCharacter
    }

    isValidFloorLevel(floorCharacter) {
        try posz := CavebotWalker.fixFloorLevelString(floorCharacter)
        catch e
            Throw e
        return true
    }

    runIsTrappedAction() {
        if (!waypointsObj.HasKey("Special"))
            return
        ActionScript.runactionwaypoint({1: "IsTrapped", 2: "Special"}, log := false)
    }

    initializeSystemWaypointAtributes(waypointAtributes) {
        global
        cavebotSystemObj.waypoints[tab] := {}
            , cavebotSystemObj.waypoints[tab][Waypoint] := {}
            , cavebotSystemObj.waypoints[tab][Waypoint].arrived := false
            , cavebotSystemObj.waypoints[tab][Waypoint].setPathFail := 0 ; variable that controls how many times tried to setPath to walk by arrow
            , cavebotSystemObj.waypoints[tab][Waypoint].ignoringClicksOnWaypointLimit := false

            , stringCoordsObj := waypointAtributes.coordinates
            , stringCoordsObj.rangeX := waypointAtributes.rangeX
            , stringCoordsObj.rangeY := waypointAtributes.rangeY
            , stringCoords := serialize(stringCoordsObj)
    }

    setArrivedWaypoint(setArrived := true) {
        if (setArrived = true)
            cavebotSystemObj.waypoints[tab][Waypoint].arrived := true
        return true
    }

    /**
    * @param string type
    * @param ?int x2
    * @return _Coordinate
    */
    searchMinimapZoom(type, x2 := "")
    {
        if (type != "minus" && type != "plus") {
            throw Exception("Invalid type: " type, A_ThisFunc)
        }

        minimapArea := new _MinimapArea()
        coordinates := minimapArea.getCoordinates().Clone()
        /*
        On Tibia 11/12 the zoom buttons are outside the minimap area
        so the X2 need to be increased a little
        */
        coordinates.setX2(minimapArea.getX2() + 60)
        if (x2) {
            coordinates.setX2(x2)
        }

        return new _ImageSearch()
            .setFile(new _MinimapArea().images("zoom" type))
            .setFolder(ImagesConfig["minimapZoom" type "Folder"])
            .setVariation(new _MinimapArea().images("variation"))
            .setCoordinates(coordinates)
            .search()
            .getResult()
    }

    /**
    * @return void
    */
    registerHotkeys()
    {
        global cavebotPauseHotkey := cavebotIniSettings.get("pauseHotkey")
        global cavebotUnpauseHotkey := cavebotIniSettings.get("unpauseHotkey")

        _HotkeyRegister.register(cavebotPauseHotkey, Func("PauseCavebot"), "CavebotPauseHotkey")
        _HotkeyRegister.register(cavebotUnpauseHotkey, Func("UnpauseCavebot"), "CavebotunpauseHotkey")
    }

    /**
    * @return ?string
    */
    checkExternalGoToLabel()
    {
        static settingsToRead
        if (!settingsToRead) {
            settingsToRead := {}
            settingsToRead.Push("scriptSettings")
            settingsToRead.Push("scriptImages")
            settingsToRead.Push("waypoints")
        }

        t := new _Timer()

        label := _Ini.read("gotolabel", "temp_cavebot")
        if (!label) {
            return
        }

        _Logger.log(A_ThisFunc, label)
        _Ini.delete("gotolabel", "temp_cavebot")

        labelSearch := _GoToLabelAction.labelSearch(label)

        if (!labelSearch.labelFound) {
            return
        }

        if (tab = labelSearch.tabFound && Waypoint = labelSearch.waypointFound) {
            return
        }

        for _, setting in settingsToRead {
            try {
                CavebotScript.loadSpecificSettingFromExe(setting, currentScript, A_ScriptName)
            } catch e {
                _Logger.exception(e, A_ThisFunc, currentScript)
            }
        }

        _Logger.log(A_ThisFunc, "Time to load settings: " t.elapsed())

        return label
    }
}