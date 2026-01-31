global fishingSystemObj

/*
ini settings
*/
global fishingPauseHotkey

Class _FishingSystem
{
    __New()
    {
        global
        fishingSystemObj := {}

        this.readIniFishingGlobalSettings()


        this.sqmsVertical := 11
        this.sqmsHorizontal := 15

        this.halfHorizontal := Floor((this.sqmsHorizontal / 2))
        this.halfVertical := Floor((this.sqmsVertical / 2))

        this.startFishingSetup()

        this.useItemWithHotkey := !empty(Trim(fishingObj.fishingRodHotkey))
    }

    startFishingSetup() {
        this.loadFishingJsonSettings()

        try this.validateFishingJsonSettings()
        catch e {
            Msgbox, 16, % e.What, % e.Message, 10
            ExitApp
        }

    }

    loadFishingJsonSettings() {
        try this.fishingJsonObj := OldBotSettings.loadModuleJsonSettingsFile("fishing")
        catch e {
            Msgbox, 16, % e.What, % e.Message, 30
            ExitApp
        }
    }

    checkDefaultJsonCategories() {

        this.categories := {}
        this.categories.Push("images")
        this.categories.Push("options")

        for key, category in this.categories
        {
            if (!IsObject(this.fishingJsonObj[category]))
                this.fishingJsonObj[category] := {}

            if (IsObject(category)) {
                for subcategory, subcategories in category
                {
                    if (!IsObject(this.fishingJsonObj[subcategory]))
                        this.fishingJsonObj[subcategory] := {}
                    for key3, subcategoryName in subcategories
                    {
                        if (!IsObject(this.fishingJsonObj[subcategory][subcategoryName]))
                            this.fishingJsonObj[subcategory][subcategoryName] := {}
                    }
                }
            }
        }
        ; msgbox, % serialize(this.fishingJsonObj["minimap"])
    }

    validateFishingJsonSettings() {
        if (this.fishingJsonObj = "")
            throw Exception("Empty fishing.json settings", A_ThisFunc)


        this.fishingJsonObj.images.freeSlot := this.fishingJsonObj.images.freeSlot = "" ? "free_slot_otclientv8.png" : this.fishingJsonObj.images.freeSlot
        this.fishingJsonObj.images.freeSlotVariation := this.fishingJsonObj.images.freeSlotVariation = "" ? 20 : this.fishingJsonObj.images.freeSlotVariation
    }

    throwError(func, error) {
        FileAppend, % "`n" A_Hour ":" A_Min ":" A_Sec " " A_MDay "/" A_Mon " | " error, Data\Files\logs_errors_fishing.txt
        OutputDebug(func, error) 
    }

    antiIdleFishing(clientWindowID := "") {
        Random, direction, 0, 1
        if (direction = 1) {
            SendModifier("Ctrl", "Up", clientWindowID)
            Sleep, 50
            SendModifier("Ctrl", "Down", clientWindowID)
        } else {
            SendModifier("Ctrl", "Left", clientWindowID)
            Sleep, 50
            SendModifier("Ctrl", "Right", clientWindowID)
        }
        return
    }

    /**
    * @return ?_Coordinate
    */
    searchItemFishing(itemName) {
        try {
            return new _ItemSearch()
                .setName(itemName)
                .search()
                .getResult()
        } catch e {
            _Logger.exception(e, A_ThisFunc, itemName)
        }
    }

    getMousePosition() {
        MouseGetPos, mouseX, MouseY
        x := mouseX - WindowX, y := mouseY - WindowY
        if (x < 0 OR y < 0)
            return false
        limitX := WindowX + WindowWidth, limitY := WindowY + WindowHeight
        if (mouseX > limitX OR MouseY > limitY)
            return false
        this.mouseX := x, this.mouseY := y
        return true

    }

    dragMouseFishing(x1, y1, x2, y2, holdCtrl := false, holdShit := false) {
        ; mousemove, WindowX + x1, WindowY + y1
        ; msgbox, a
        ; mousemove, WindowX + x2, WindowY + y2
        ; msgbox, b
        if (holdCtrl = true)
            HoldCtrl()
        else if (holdShift = true)
            HoldShift()
        MouseDrag(x1, y1, x2, y2)
        if (holdCtrl = true) {
            Sleep, 50
            ReleaseCtrl()
        } else if (holdShift = true) {
            Sleep, 50
            ReleaseShift()
        }
    }

    clickOnImageFishing(imageName := "", clickButton := "", holdCtrl := false) {
        try {
            _search := _ScriptImages.search(imageName)
        } catch e {
            _Logger.exception(e, A_ThisFunc, itemName)
            return false
        }

        if (_search.notFound()) {
            return
        }

        this.clickMouseFishing(clickButton, _search.getX(), _search.getY(), holdCtrl)
    }

    clickOnItemFishing(itemName := "", clickButton := "", holdCtrl := false) {

        vars := this.searchItemFishing(itemName)
        if (vars = false)
            return
        this.clickMouseFishing(clickButton, vars.x, vars.y, holdCtrl)
    }

    clickMouseFishing(clickButton, x, y, holdCtrl := false) {
        if (holdCtrl = true) {
            MouseClickModifier("Ctrl", clickButton, x, y)
            return
        } 

        MouseClick(clickButton, x, y)
    }


    createSqmPositionsArray() {
        global


        if (SQM_SIZE = "") {
            Msgbox, 48,, % "CavebotSystem size SQM not initialized."
            Reload()
            return false
        }
        this.sizeSQM := SQM_SIZE + 0.5
        this.sizeSQM := SQM_SIZE

        this.sqmsCounter := 1
        this.sqmVerticalCounter := 1

        this.sqmPositions := {}


        /**
        Values to create in the character position
        */
        this.initialSqmX := WindowX + CHAR_POS_X - (this.sizeSQM / 2)
        this.initialSqmY := SQMY := WindowY + CHAR_POS_Y - (this.sizeSQM / 2)

        Loop, % this.sqmsVertical {

            this.sqmPositions["sqm" this.sqmVerticalCounter] := {}

            this.sqmHorizontalCounter := 1
            Loop, % this.sqmsHorizontal {

                this.singleSqmPosition()

                ; if (this.sqmVerticalCounter > 4)
                ; m("this.sqmVerticalCounter = " this.sqmVerticalCounter "`n" "this.sqmHorizontalCounter = " this.sqmHorizontalCounter "`n" )
                this.sqmsCounter++

                this.sqmHorizontalCounter++
            }

            this.sqmVerticalCounter++


        }

        ; m(serialize(this.sqmPositions))
    }

    singleSqmPosition() {
        global

        SQMX := this.initialSqmX
            , SQMY := this.initialSqmY

        /**
        Changing values to start from top left
        */
        if (this.sqmHorizontalCounter < 7)
            SQMX -= this.sizeSQM * (this.halfHorizontal - this.sqmHorizontalCounter)
        if (this.sqmHorizontalCounter > 7)
            SQMX += this.sizeSQM * (this.sqmHorizontalCounter - this.halfHorizontal)

        /**  
        Adjust because Counters start at 1 and not 0
        */
        SQMX -= this.sizeSQM

        if (this.sqmVerticalCounter < 5)
            SQMY -= this.sizeSQM * (this.halfVertical - this.sqmVerticalCounter)
        if (this.sqmVerticalCounter > 5)
            SQMY += this.sizeSQM * (this.sqmVerticalCounter - this.halfVertical)
        SQMY -= this.sizeSQM


        this.sqmPositions["sqm" this.sqmVerticalCounter]["sqm" this.sqmHorizontalCounter] := {}
            , this.sqmPositions["sqm" this.sqmVerticalCounter]["sqm" this.sqmHorizontalCounter].x := SQMX
            , this.sqmPositions["sqm" this.sqmVerticalCounter]["sqm" this.sqmHorizontalCounter].y := SQMY
            , this.sqmPositions["sqm" this.sqmVerticalCounter]["sqm" this.sqmHorizontalCounter].sqmIndex := this.sqmsCounter
        ; m(serialize(this.sqmPositions["sqm" this.sqmVerticalCounter]["sqm" this.sqmHorizontalCounter]))
    }

    startFishing() {
        this.orderFishingSqms()
        ; m(serialize(this.fishingSqms))

        for verticalKey, verticalValues in this.fishingSqms
        {
            this.verticalKey := "sqm" verticalKey
            ; m("verticalKey" "`n" verticalKey "`n" serialize(verticalValues))
            if (A_IsCompiled && !fishingObj.fishingEnabled) {
                break
            }

            for horizontalKey, fishThisSqm in verticalValues
            {
                if (A_IsCompiled && !fishingObj.fishingEnabled) {
                    break
                }
                ; m("horizontalKey" "`n" horizontalKey "`n" fishThisSqm)
                if (!fishThisSqm) {
                    continue
                }

                this.horizontalKey := "sqm" horizontalKey
                this.t1Fishing := A_TickCount
                Loop, {
                    While (isDisconnected())
                        Sleep, 1000

                    if (this.checkFishingConditions() = true) {
                        break
                    }

                    Sleep, 1000
                }

                this.fishingActions()

                this.fishingSleep()
            } ; for horizontal


        } ; for vertical

    }

    fishingSleep() {
        actionsDuration := A_TickCount - this.t1Fishing
        if (actionsDuration > fishingObj.fishingDelay) {
            OutputDebug("Fishing", "No sleep, actionsDuration > fishing delay | " actionsDuration " > " fishingObj.fishingDelay)
            return
        }
        Random, fishingRandom, 1, 60
        sleepDelay := (fishingObj.fishingDelay - actionsDuration) + fishingRandom
        if (sleepDelay < 1)
            sleepDelay := fishingRandom
        if (this.fishingJsonObj.options.debugLog = true)
            OutputDebug("Fishing", "fishing delay: " fishingObj.fishingDelay ", actionsDuration = " actionsDuration ", sleepDelay = " sleepDelay ", random = " fishingRandom)
        Sleep, % sleepDelay
        ; msgbox, a
    }

    /**
    order the array in ascending order sqm1, sqm2, sqm10, sqm11...
    */
    orderFishingSqms() {
        this.fishingSqms := {}

        for verticalKey, verticalValues in fishingObj.sqms
        {
            vKey := StrReplace(verticalKey, "sqm", "")
            if (!IsObject(this.fishingSqms[vKey]))
                this.fishingSqms[vKey] := {}
            ; m("verticalKey" "`n" verticalKey "`n" serialize(verticalValues))
            for horizontalKey, fishThisSqm in verticalValues
            {
                hKey := StrReplace(horizontalKey, "sqm", "")
                if (!IsObject(this.fishingSqms[hKey]))
                    this.fishingSqms[hKey] := {}

                this.fishingSqms[vKey][hKey] := fishThisSqm
                ; m("horizontalKey" "`n" horizontalKey "`n" fishThisSqm)
            }
            ; m(serialize(this.fishingSqms))
        }
    }

    fishingActions()
    {
        seaSqmPos := this.findSeaSqmToClick()
        if (seaSqmPos.x = "")
            return false

        this.pauseCavebotFishing()

        if (!this.useFishingRod()) {
            return false
        }

        Random, randomPos, -5, 5

        button := this.fishingJsonObj.options.rightClickOnSea ? "Right" : "Left"

        MouseClick(button, GetRelativeCoordX(seaSqmPos.x + randomPos), GetRelativeCoordY(seaSqmPos.y + randomPos), debug := false)

        this.unpauseCavebotFishing()
    }

    useFishingRod()
    {
        if (fishingObj.pressEscFishingRod) {
            Send("Esc")
        }

        SleepR(50, 80)

        if (clientHasFeature("useItemWithHotkey")) {
            Send(fishingObj.fishingRodHotkey)

            return true
        }

        if (this.fishingJsonObj.options.rightClickOnSea) {
            return true
        }

        fishingRodPos := this.searchItemFishing("fishing rod")
        ; m("fishingRodPos = " serialize(fishingRodPos))
        if (fishingRodPos.x = "")
            return false

        Random, randomPos, -5, 5
        rightClickUseClassicControl(fishingRodPos.x + randomPos, fishingRodPos.y + randomPos)

        SleepR(50, 90)
        MouseMove(CHAR_POS_X, CHAR_POS_Y)
        ; OutputDebug("Fishing", A_TickCount - this.t1Fishing )

        return true
    }

    findSeaSqmToClick() {
        x := this.sqmPositions[this.verticalKey][this.horizontalKey].x + (SQM_SIZE / 2)
            , y := this.sqmPositions[this.verticalKey][this.horizontalKey].y + (SQM_SIZE / 2)

        ; MouseMove, x, y
        ; m("this.verticalKey = " this.verticalKey "`n" "this.horizontalKey = " this.horizontalKey "`n" serialize(horizontalValues) "`n`n" serialize(this.sqmPositions[this.verticalKey][this.horizontalKey]))


        return {"x": x, "y": y}

    }

    checkFishingConditions() {

        this.conditionDelays := 25

        if (fishingObj.fishingIgnoreIfWaypointTab = true) {
            if (this.checkCavebotWaypointTabCondition() = false) {
                if (this.fishingJsonObj.options.debugLog = true)
                    OutputDebug("Fishing", "fishingIgnoreIfWaypointTab false")
                return false
            }
        }

        if (fishingObj.fishingOnlyFreeSlot = true) {
            Sleep, % this.conditionDelays
            if (this.checkFreeSlotCondition() = false) {
                if (this.fishingJsonObj.options.debugLog = true)
                    OutputDebug("Fishing", "fishingOnlyFreeSlot false")
                return false
            }
        }

        if (fishingObj.fishingIfNoFish = true) {
            Sleep, % this.conditionDelays
            if (this.checkOnlyIfNoFishCondition() = false) {
                if (this.fishingJsonObj.options.debugLog = true)
                    OutputDebug("Fishing", "fishingIfNoFish false")
                return false
            }
        }

        if (fishingObj.fishingCapCondition = true) {
            if (this.checkCapCondition() = false) {
                if (this.fishingJsonObj.options.debugLog = true)
                    OutputDebug("Fishing", "fishingCapCondition false")
                return false
            }
        }

        return true

    }

    checkCapCondition() {
        ; msgbox, % "fishingObj.fishingCap = " fishingObj.fishingCap
        if (fishingObj.fishingCap < 1)
            return true

        Sleep, 50

        cap := ActionScript.readSkillWindow(A_ThisFunc, "capacity")
        ; msgbox, % cap " > " fishingObj.fishingCap
        if (cap = -1)
            return true

        if (cap > fishingObj.fishingCap)
            return true

        Sleep, 500

        return false

    }

    checkFreeSlotCondition() {
        _search := new _ImageSearch()
            .setFile(this.fishingJsonObj.images.freeSlot)
            .setFolder(ImagesConfig.fishingFolder)
            .setVariation(this.fishingJsonObj.images.freeSlotVariation)
            .search()

        return _search.found()
    }

    checkOnlyIfNoFishCondition() {
        try {
            return new _ItemSearch()
                .setName("fish")
                .search()
                .notFound()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return true
        } 
    }

    /**
    return false if current label in cavebot
    */
    checkCavebotWaypointTabCondition() {
        IniRead, CurrentWaypointTab, %DefaultProfile%, cavebot, CurrentWaypointTab, %A_Space%
        ignoreTab := fishingObj.fishingWaypointTab
            , ignoreTabs := StrSplit(fishingObj.fishingWaypointTab, "|")
        if (this.fishingJsonObj.options.debugLog = true)
            OutputDebug("Fishing", "CurrentWaypointTab = " CurrentWaypointTab ", ignoreTab = " ignoreTab)
        if (CurrentWaypointTab = "")
            return true
        if (ignoreTabs.Count() > 1) {
            for key, ignoreTabName in ignoreTabs
            {
                ignoreTabName := LTrim(RTrim(ignoreTabName))
                (CurrentWaypointTab = ignoreTabName)
                return false
            }
        } else {
            if (CurrentWaypointTab = ignoreTab)
                return false    
        }

    }

    conditonsSleep() {

    }

    pauseCavebotFishing() {

    }

    unpauseCavebotFishing() {

    }

    readIniFishingGlobalSettings() {
        global 

        IniRead, fishingPauseHotkey, %DefaultProfile%, fishing_settings, fishingPauseHotkey, End
    }
} ; Class
