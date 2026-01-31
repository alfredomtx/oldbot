global lootingSystemObj


Class _LootingSystem
{
    __New()
    {
        global

        lootingSystemObj := {}

        this.lootingJsonSetup()

        this.classicControlEnabled := !new _ClientInputIniSettings().get("classicControlDisabled")

        this.lootDestinations := {}

        this.nextBackpackImages := 10

        this.lootingMethod := new _LootingSettings().get("lootingMethod")

        ; this.startlootingTimer()
    }

    lootingJsonSetup()
    {

        try this.lootingJsonObj := OldBotSettings.loadModuleJsonSettingsFile("looting")
        catch e {
            Msgbox, 16, % e.What, % e.Message, 30
            ExitApp
        }

        try this.validateLootingJsonSettings()
        catch e {
            Msgbox, 16, % e.What, % e.Message, 30
            ExitApp
        }
    }

    checkDefaultJsonCategories()
    {

        this.categories := {}
        this.categories.Push("input")
        this.categories.Push("images")
        this.categories.Push("options")

        for key, category in this.categories
        {
            if (!IsObject(this.lootingJsonObj[category]))
                this.lootingJsonObj[category] := {}

            if (IsObject(category)) {
                for subcategory, subcategories in category
                {
                    if (!IsObject(this.lootingJsonObj[subcategory]))
                        this.lootingJsonObj[subcategory] := {}
                    for key3, subcategoryName in subcategories
                    {
                        if (!IsObject(this.lootingJsonObj[subcategory][subcategoryName]))
                            this.lootingJsonObj[subcategory][subcategoryName] := {}
                    }
                }
            }
        }
        ; msgbox, % serialize(this.lootingJsonObj["minimap"])
    }

    validateLootingJsonSettings() {
        if (this.lootingJsonObj = "")
            throw Exception("Empty looting.json settings", A_ThisFunc)

        this.checkDefaultJsonCategories()

        /**
        lootingJsonObj.input
        */
        this.lootingJsonObj.input.backgroundMouseDrag := this.lootingJsonObj.input.backgroundMouseDrag = "" ? true : this.lootingJsonObj.input.backgroundMouseDrag


        /**
        lootingJsonObj.delays
        */
        this.lootingJsonObj.delays.quickLootClickAroundDelay := this.lootingJsonObj.delays.quickLootClickAroundDelay = "" ? 0 : this.lootingJsonObj.delays.quickLootClickAroundDelay
        this.lootingJsonObj.delays.quickLootClickAroundDelay := this.lootingJsonObj.delays.quickLootClickAroundDelay = "" ? 150 : this.lootingJsonObj.delays.quickLootClickAroundDelay

        this.lootingJsonObj.delays.delayAfterDraggingLoot := this.lootingJsonObj.delays.delayAfterDraggingLoot = "" ? 150 : this.lootingJsonObj.delays.delayAfterDraggingLoot

        this.lootingJsonObj.delays.delayBeforeSearchingItemsAfterOpenCorpse := this.lootingJsonObj.delays.delayBeforeSearchingItemsAfterOpenCorpse = "" ? 150 : this.lootingJsonObj.delays.delayBeforeSearchingItemsAfterOpenCorpse

        this.lootingJsonObj.delays.delayBeforeSearchingOpenCorpseOption := this.lootingJsonObj.delays.delayBeforeSearchingOpenCorpseOption = "" ? 35 : this.lootingJsonObj.delays.delayBeforeSearchingOpenCorpseOption

        this.lootingJsonObj.delays.delayBeforeSearchingForCorpseImages := this.lootingJsonObj.delays.delayBeforeSearchingForCorpseImages = "" ? 0 : this.lootingJsonObj.delays.delayBeforeSearchingForCorpseImages

        /**
        lootingJsonObj.options
        */
        this.lootingJsonObj.options.searchOpenOptionOnEntireScreen := this.lootingJsonObj.options.searchOpenOptionOnEntireScreen = "" ? false : this.lootingJsonObj.options.searchOpenOptionOnEntireScreen
        this.lootingJsonObj.options.lootCharacterSqm := this.lootingJsonObj.options.lootCharacterSqm = "" ? false : this.lootingJsonObj.options.lootCharacterSqm
        this.lootingJsonObj.options.clientHasAutoStack := this.lootingJsonObj.options.clientHasAutoStack = "" ? true : this.lootingJsonObj.options.clientHasAutoStack
        this.lootingJsonObj.options.mininumLootSearchAreaWidth := this.lootingJsonObj.options.mininumLootSearchAreaWidth = "" ? 188 : this.lootingJsonObj.options.mininumLootSearchAreaWidth
        this.lootingJsonObj.options.closeMenuMethod := this.lootingJsonObj.options.closeMenuMethod = "" ? "Esc" : this.lootingJsonObj.options.closeMenuMethod

        if (this.lootingJsonObj.options.debug = true) {
            ClipBoard := serialize(this.lootingJsonObj)
            msgbox, % ClipBoard
        }

    }

    lootCorpsesAround()
    {
        if (this.lootingJsonObj.options.dontPressEscBeforeLooting != true) {
            Send("Esc")
        }

        if (this.lootingJsonObj.delays.delayBeforeLooting > 0) {
            switch (lootingSettingsObj.fastManualLooting) {
                case true:
                    /**
                    Sleep before searching for the monster position of there is delay for looting
                    ex: in kindgom swamp it takes around 500~600ms for the corpse to die
                    so the monster position is still visible in this time
                    */
                    Sleep, % (this.lootingJsonObj.delays.delayBeforeLooting / 2) - 50

                    timeCheckPos := A_TickCount
                    TargetingSystem.getCreaturePosition(ignoreDisabled := true)
                    /**
                    Sleep, the rest of the delay
                    */
                    Sleep, % (this.lootingJsonObj.delays.delayBeforeLooting / 2) + 50 - (A_TickCount - timeCheckPos)
                default:
                    Sleep, % this.lootingJsonObj.delays.delayBeforeLooting
            }
        }

        t1Looting := A_TickCount

        this.startLootingAround()

        if (this.lootingJsonObj.options.quickLootingHotkey = "Right Click") {
            writeCavebotLog("Looting", "Looting finished: " A_TickCount - t1Looting " ms (classic control: " (this.classicControlEnabled = true ? "true" : "false") "), Right Click hotkey")
        } else {
            writeCavebotLog("Looting", "Looting finished: " A_TickCount - t1Looting " ms (classic control: " (this.classicControlEnabled = true ? "true" : "false") ")")
        }
    }

    startLootingAround(fromHotkey := false)
    {
        try {
            this.openSqmsAround()
        } catch e {
            if (e.What == "IgnoreLootingException") {
                writeCavebotLog("Looting", e.Message)
                return
            }

            throw e
        } finally {
            if (this.classicControlEnabled) {
                ReleaseCtrl()
            }
        }

        Sleep, % this.lootingJsonObj.delays.delayBeforeSearchingItemsAfterOpenCorpse


        this.anyItemLooted := false
        this.searchLoot(fromHotkey)

        if (targetingObj.targetList[TargetingSystem.currentCreature].openBagInsideCorpse = true) {
            Loop, 10 {
                if (!this.searchBag()) {
                    break
                }

                writeCavebotLog("Looting", "Searching loot inside the bag..")
                this.clickOpenWithoutCtrl(this.bagPos.x + 12, this.bagPos.y + 12)
                Sleep, % this.lootingJsonObj.delays.delayBeforeSearchingItemsAfterOpenCorpse
                this.searchLoot()
            }
        }

        /**
        turn back to chat off
        */
        if (this.anyItemLooted = true) {
            try {
                _ := new _ToggleChat("off")
            } catch e {
                writeCavebotLog("ERROR", ("Looting: ") e.Message)
            }
        }
    }

    openSqmsAround()
    {
        Gui, TargetAim:Destroy

        if (lootingSettingsObj.fastManualLooting)  {
            if (!targetingSystemObj.targetX && new _LootingSettings().get("dontLootAroundIfFastManualLootingFails")) {
                this.throwIgnoreLootingException()
            }

            corpseSqm := TargetingSystem.getAttackingCreatureSqm()
            switch corpseSqm {
                case 1:
                    sqmsLoot := lootingSettingsObj.smartLootingSqms = 1 ? {1: 1} : {1: 1, 2: 4, 3: 2}
                case 2:
                    sqmsLoot := lootingSettingsObj.smartLootingSqms = 1 ? {1: 2} : {1: 2, 2: 1, 3: 3}
                case 3:
                    sqmsLoot := lootingSettingsObj.smartLootingSqms = 1 ? {1: 3} : {1: 3, 2: 2, 3: 6}
                case 4:
                    sqmsLoot := lootingSettingsObj.smartLootingSqms = 1 ? {1: 4} : {1: 4, 2: 1, 3: 7}
                case 6:
                    sqmsLoot := lootingSettingsObj.smartLootingSqms = 1 ? {1: 6} : {1: 6, 2: 3, 3: 9}
                case 7:
                    sqmsLoot := lootingSettingsObj.smartLootingSqms = 1 ? {1: 7} : {1: 7, 2: 4, 3: 8}
                case 8:
                    sqmsLoot := lootingSettingsObj.smartLootingSqms = 1 ? {1: 8} : {1: 8, 2: 7, 3: 9}
                case 9:
                    sqmsLoot := lootingSettingsObj.smartLootingSqms = 1 ? {1: 9} : {1: 9, 2: 8, 3: 6}
                default:
                    if (new _LootingSettings().get("dontLootAroundIfFastManualLootingFails")) {
                        this.throwIgnoreLootingException()
                    }

                    this.lootAllSqms()

                    return
            }

            this.lootDefinedSqms(sqmsLoot)

            return
        }

        this.lootAllSqms()
    }

    throwIgnoreLootingException()
    {
        message := txt("Não foi possível encontrar a criatura ao redor do char, ignorando looting ao redor", "Could not find the creature around the character, ignoring loot around")

        throw Exception(message, "IgnoreLootingException")
    }

    openCorpseSqm(x, y, entireScreen := true)
    {
        static classicControlDisabled
        if (classicControlDisabled == "") {
            classicControlDisabled := new _ClientInputIniSettings().get("classicControlDisabled")
        }

        if (isRubinot()) {
            rightClickUseClassicControl(x, y, false)
            Sleep, % this.lootingJsonObj.delays.delayBeforeSearchingOpenCorpseOption
            this.clickOpen(entireScreen)

            return
        }

        switch (lootingObj.settings.quickLootingHotkey) {
            case "Right Click":
                rightClickUseClassicControl(x, y, false)
                ; if it's just looting using right click with classic control enabled, need a delay
                if (!classicControlDisabled) {
                    Sleep, 25
                }

            default:
                rightClickUse(x, y, debug := false)
                if (false) {
                    Sleep, 10
                }

                ; mousemove, WindowX + x, WindowY + y
                ; msgbox, % x "," y
                Sleep, % this.lootingJsonObj.delays.delayBeforeSearchingOpenCorpseOption

                if (classicControlDisabled && this.lootingJsonObj.delays.delayBeforeSearchingOpenCorpseOptionWithClassicControlDisabled) {
                    Sleep, % this.lootingJsonObj.delays.delayBeforeSearchingOpenCorpseOptionWithClassicControlDisabled
                }

                this.clickOpen(entireScreen)
        }
    }

    lootAllSqms()
    {
        Loop, 9 {
            if (!LootingSystem.lootCharacterSqm && !this.lootingJsonObj.options.lootCharacterSqm) && (A_Index = 5)
                continue
            this.openCorpseSqm(SQM%A_Index%X, SQM%A_Index%Y, this.lootingJsonObj.options.searchOpenOptionOnEntireScreen = true ? true : false)

            if (!this.classicControlEnabled)
                    && (this.lootingJsonObj.delays.delayClickSqmsAroundWithClassicControlDisabled > 1) {
                    Sleep, % this.lootingJsonObj.delays.delayClickSqmsAroundWithClassicControlDisabled
            }
        }
    }

    lootDefinedSqms(sqmsLoot)
    {
        for _, sqm in sqmsLoot
        {
            this.openCorpseSqm(SQM%sqm%X, SQM%sqm%Y, this.lootingJsonObj.options.searchOpenOptionOnEntireScreen = true ? true : false)
            if (!this.classicControlEnabled)
                    && (this.lootingJsonObj.delays.delayClickSqmsAroundWithClassicControlDisabled > 1) {
                    Sleep, % this.lootingJsonObj.delays.delayClickSqmsAroundWithClassicControlDisabled
            }
        }
    }

    checkOpenNextBackpack() {
        if (lootingObj.settings.openNextBackpack = 0) {
            return false
        }

        if (scriptImagesObj.HasKey("nextBackpack") = false) {
            hasImage := false
            Loop, % this.nextBackpackImages {
                if (scriptImagesObj.HasKey("nextBackpack" A_Index) = true) {
                    hasImage := true
                    break
                }
            }

            if (hasImage = false) {
                writeCavebotLog("WARNING", """Open next backpack"" option is checked but there is no ""nextBackpack"" Script Image")
                return false
            }
        }

        try {
            nextBP := _ScriptImages.search("nextBackpack", 45, "sideBarsArea", true, debug := false)
        } catch e {
            writeCavebotLog("ERROR", e.Message)
            return false
        }

        /**
        check up to 10 next backpacks
        */
        if (nextBP.notFound()) {
            Loop, % this.nextBackpackImages {
                if (scriptImagesObj.HasKey("nextBackpack" A_Index) = false) {
                    continue
                }

                try  {
                    nextBP := _ScriptImages.search("nextBackpack" A_Index, 45, "sideBarsArea")
                } catch e {
                    _Logger.exception(e, A_ThisFunc)
                    return false
                }

                if (nextBP.found()) {
                    break
                }
            }
        }

        if (nextBP.notFound()) {
            return false
        }

        writeCavebotLog("Looting", "Opening next backpack..")

        this.lootDestinations := {}

        this.clickOpenPosition(nextBP.getX(), nextBP.getY(), entireScreen := true)
        return true
    }

    searchBag()
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _ItemSearch()
                .setCoordinates(_Coordinates.FROM_ARRAY(ClientAreas.lootSearchArea))
                .setName("bag")
        }
        try {
            _search := searchCache
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }

        this.bagPos := _search.getResult()
        return _search.found()
    }

    clickOpenPosition(x, y, entireScreen := true)
    {
        rightClickUse(x, y)
        ; mousemove, WindowX + x, WindowY + y
        ; msgbox, % x "," y

        Sleep, % this.lootingJsonObj.delays.delayBeforeSearchingOpenCorpseOption
        this.clickOpen(entireScreen)
    }

    clickOpenWithoutCtrl(x, y)
    {
        static classicControlDisabled
        if (!classicControlDisabled) {
            classicControlDisabled := new _ClientInputIniSettings().get("classicControlDisabled")
        }
        /**
        if classic control is disabled, use the Open menu to open it
        otherwise just right click on it
        */
        if (classicControlDisabled) {
            this.clickOpenPosition(x, y)
            return
        }

        MouseClick("Right", x, y)
    }

    /**
    * @param bool entireScreen
    * @return void
    */
    clickOpen(entireScreen := true)
    {
        try {
            if (entireScreen) {
                coordinates := new _WindowArea().getCoordinates()
            } else {
                this.setOpenCorpseSearchArea()
                c1 := new _Coordinate(this.openCorpseSearchArea.x1, this.openCorpseSearchArea.y1)
                c2 := new _Coordinate(this.openCorpseSearchArea.x2, this.openCorpseSearchArea.y2)
                coordinates := new _Coordinates(c1, c2)
            }

            _search := new _ClickOnMenu(_ClickOnMenu.OPEN)
                .setClickParams(new _ClickParams("Left", 2))
                .setCoordinates(coordinates)
                .run()
        } catch e {
            writeCavebotLog("ERROR", A_ThisFunc " | " e.Message " | " e.What)
            this.closeTooltipMenu()
            return
        }

        if (_search.notFound()) {
            this.closeTooltipMenu()
            return
        }

        if (this.lootingJsonObj.delays.delayAfterClickOnOpenOption > 1)
            Sleep, % this.lootingJsonObj.delays.delayAfterClickOnOpenOption
    }

    closeTooltipMenu()
    {
        if (this.lootingJsonObj.options.closeMenuMethod = "Esc") {
            Send("Esc")
            Sleep, % this.lootingJsonObj.delays.delayAfterCloseMenu ? this.lootingJsonObj.delays.delayAfterCloseMenu : 50
            return
        }

        x := ClientAreas.lootBackpackPosition.x != "" ? ClientAreas.lootBackpackPosition.x : CHAR_POS_X
        y := ClientAreas.lootBackpackPosition.y != "" ? ClientAreas.lootBackpackPosition.y : CHAR_POS_Y
        MouseClick("Left", x, y, false)
        Sleep, % this.lootingJsonObj.delays.delayAfterCloseMenu ? this.lootingJsonObj.delays.delayAfterCloseMenu : 50
    }

    createFromHotkeyOptions(moveOnlyOneItemHotkey := "false", showTooltipWhenFinished := "false", pressEnterAfterMoveItem := "false", tooltipDuration := 150) {
        this.lootingFromHotkeyOptions := {}
        this.lootingFromHotkeyOptions.moveOnlyOneItemHotkey := moveOnlyOneItemHotkey = "true" ? true : false
        this.lootingFromHotkeyOptions.showTooltipWhenFinished := showTooltipWhenFinished = "true" ? true : false
        this.lootingFromHotkeyOptions.pressEnterAfterMoveItem := pressEnterAfterMoveItem = "true" ? true : false
        this.lootingFromHotkeyOptions.tooltipDuration := tooltipDuration
    }

    searchLoot(fromHotkey := false) {

        this.fromHotkey := fromHotkey

        if (ClientAreas.lootSearchArea.x1 = "")
            this.getLootSearchArea()

        if (this.fromHotkey = false)
            this.closeTooltipMenu()

        this.moveOnlyOneItemLooted := false

        t1 := A_TickCount


        for itemName, atributes in lootingObj.lootList
        {
            if (atributes.ignore = 1 OR atributes.use = 1 OR atributes.drop = 1)
                continue
            /**
            check if item is found before entering the loop and getting a new client bitmap
            */
            firstItemSearch := true
            itemSearch := this.searchLootItem(itemName)
            if (itemSearch.notFound()) {
                if (this.fromHotkey = false)
                    writeCavebotLog("Looting", "Item """ itemName """ not found")
                continue
            }

            this.anyItemLooted := true

            Loop, % atributes.tries {
                ; Sleep, 25
                if (firstItemSearch = false) {
                    itemSearch := this.searchLootItem(itemName)
                    if (itemSearch.notFound()) {
                        break
                    }
                }
                firstItemSearch := false

                switch (this.lootingMethod) {
                    case "Click on the item":
                        break
                }


                backpackX := ClientAreas.lootBackpackPosition.x, backpackY := ClientAreas.lootBackpackPosition.y
                if (atributes.destination != "") {
                    if (this.fromHotkey = false)
                        writeCavebotLog("Looting", "Moving """ itemName """, destination: """ atributes.destination """, tries: " A_Index "/" atributes.tries "..")

                    destinationPos := this.getLootDestinationPosition(atributes.destination)
                    if (destinationPos.x) {
                        backpackX := destinationPos.x, backpackY := destinationPos.y
                    }
                } else {
                    if (this.fromHotkey = false)
                        writeCavebotLog("Looting", "Moving """ itemName """, tries: " A_Index "/" atributes.tries "..")
                    if (ClientAreas.lootBackpackPosition.x = "") {
                        if (this.fromHotkey = false)
                            writeCavebotLog("Looting", "WARNING: Loot Backpack Position is not set. Click on ""Set Game Areas"" button to fix it.", true)
                        return false
                    }
                }

                if (!this.lootingJsonObj.options.clientHasAutoStack) {
                    try {
                        c1 := new _Coordinate(ClientAreas.lootSearchArea.x1, 0)
                        c2 := _Coordinate.FROM_ARRAY(ClientAreas.lootSearchArea, 2)
                        coordinates := new _Coordinates(c1, c2)

                        _search := new _ItemSearch()
                            .setCoordinates(coordinates)
                            .setName(itemName)
                            .search()
                    } catch e {
                        _Logger.exception(e, A_ThisFunc)
                        break
                    }

                    if (_search.found()) {
                        backpackX := _search.getX(), backpackY := _search.getY()
                    }
                }

                this.dragLoot(itemSearch.getX(), itemSearch.getY(), backpackX, backpackY, debug := false)
                this.moveOnlyOneItemLooted := true

                if (this.fromHotkey && this.lootingFromHotkeyOptions.moveOnlyOneItemHotkey) {
                    break
                }
            }
            if (this.fromHotkey && this.lootingFromHotkeyOptions.moveOnlyOneItemHotkey = true) && (this.moveOnlyOneItemLooted = true)
                break
        }

        /**
        search for items to use/drop after looting
        */
        for itemName, atributes in lootingObj.lootList
        {
            if (atributes.ignore = 1)
                continue
            if (atributes.use != 1) && (atributes.drop != 1)
                continue
            /**
            check if item is found before entering the loop and getting a new client bitmap
            */
            itemSearch := this.searchLootItem(itemName)
            if (itemSearch.notFound()) {
                if (this.fromHotkey = false)
                    writeCavebotLog("Looting", "Item """ itemName """ not found")
                continue
            }

            if (atributes.use = 1) {
                this.useItemInsteadOfLoot(itemName, itemSearch.getResult())
                /**
                if is checked not to drop, continue, otherwise try to drop it after use
                */
                if (atributes.drop != 1)
                    continue
            }

            if (atributes.drop = 1)
                this.dropItemInsteadOfLoot(itemName,  action := "", searchAllScreen := false)
            if (this.lootingFromHotkeyOptions.moveOnlyOneItemHotkey = true)
                break
        }

        _MiracleLooter.run()

        if (this.fromHotkey = true && this.lootingFromHotkeyOptions.showTooltipWhenFinished = true) {
            Tooltip, % "Looted (" A_TickCount - t1 "ms)"
            Sleep, % this.lootingFromHotkeyOptions.tooltipDuration
            Tooltip
        }

    }

    getLootDestinationPosition(backpack) {
        if (this.lootDestinations[backpack].x)
            return this.lootDestinations[backpack]

        try {
            _search := new _ItemSearch()
                .setName(backpack)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, backpack)
            return
        }

        this.lootDestinations[backpack] := _search.getResult()

        return this.lootDestinations[backpack]
    }

    /**
    search the item to use 3 times
    */
    useItemInsteadOfLoot(itemName, initialItemVars := "") {
        Loop, % lootingSettingsObj.triesToUseItem {
            if (A_Index = 1) {
                rightClickUseWithoutPressingCtrl(initialItemVars.x , initialItemVars.y )
                Sleep, % this.lootingJsonObj.delays.delayAfterDraggingLoot / 2
                continue
            }
            itemSearch := this.searchLootItem(itemName)
            if (itemSearch.notFound()) {
                return
            }

            itemSearch.useWithoutCtrl()
            Sleep, % this.lootingJsonObj.delays.delayAfterDraggingLoot / 2
        }
    }

    /**
    drop loot on character position
    */
    dropItemInsteadOfLoot(itemName, action := "", searchAllScreen := false) {
        ; msgbox, % A_ThisFunc "`nitemName = " itemName ", action = " action ", searchAllScreen = " searchAllScreen
        /**
        try to deposit up to 19 times each item
        */
        lootingSystemObj.limitTriesDrop := 10
        Loop, % lootingSystemObj.limitTriesDrop {
            Sleep, 25

            itemSearch := this.searchLootItem(itemName, searchAllScreen)
            if (itemSearch.notFound()) {
                break
            }
            ; writeCavebotLog("Action", (action ": ")  "Depositing """ itemName """ (" A_Index "/100) " serialize(vars) "..")
            title := "" ? "Looting" : "Action"
            actionString := action ? action . ": " : ""
            writeCavebotLog(title, actionString "Dropping """ itemName """, tries: " A_Index "/" lootingSystemObj.limitTriesDrop "..")

            this.dragLoot(itemSearch.getX(), itemSearch.getY(), CHAR_POS_X, CHAR_POS_Y, debug := false)
            ; MouseClick("Left", CHAR_POS_X, CHAR_POS_Y)
            ; Sleep, 100
        }
    }

    /**
    * @return ?_ItemSearch
    */
    searchLootItem(itemName, searchAllScreen := false) {
        try {
            _search := new _ItemSearch()
                .setName(itemName)

            if (!searchAllScreen) {
                _search.setCoordinates(_Coordinates.FROM_ARRAY(ClientAreas.lootSearchArea))
            }

            _search.search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, itemName)
            return
        }

        switch (this.lootingMethod) {
            case "Click on the item":
                _search.click("Left")
        }

        return _search
    }

    dragLoot(x1, y1, x2, y2, debug := false) {
        if (debug) {
            msgbox, % A_ThisFunc "`n`n" x1 "," y1 "," x2 "," y2 "," this.lootingJsonObj.delays.delayAfterDraggingLoot "," debug
            mousemove, WindowX + x1, WindowY + y1
            msgbox, a
            mousemove, WindowX + x2, WindowY + y2
            msgbox, b
        }

        wasBackgroundMouseInput := false
        if (this.lootingJsonObj.input.backgroundMouseDrag = false) && (backgroundMouseInput = true) {
            backgroundMouseInput := false
            WinGet, winID, ID, A
            MouseGetPos, mouseX, mouseY
            if (winID != TibiaClientID)
                WinActivate, ahk_id %TibiaClientID%
            wasBackgroundMouseInput := true
        }

        MouseDrag(x1, y1, x2, y2, "", debug := false)

        if (this.lootingJsonObj.input.backgroundMouseDrag = false) && (wasBackgroundMouseInput = true) {
            MouseMove, mouseX, mouseY
            if (winID != TibiaClientID)
                WinActivate, ahk_id %winID%
            backgroundMouseInput := true
        }
        MouseMove(CHAR_POS_X, CHAR_POS_Y)

        this.confirmOkDialogBox()

        if (this.fromHotkey && this.lootingFromHotkeyOptions.moveOnlyOneItemHotkey = true)
            return

        Sleep, % this.lootingJsonObj.delays.delayAfterDraggingLoot
    }

    confirmOkDialogBox() {
        if (this.lootingJsonObj.options.noDialogBoxToConfirmAfterMoveItem = true)
            return

        if (this.fromHotkey && this.lootingFromHotkeyOptions.pressEnterAfterMoveItem != true)
            return

        if (this.lootingJsonObj.options.clickOnOkButtonInsteadOfEnter = true) {
            Loop, 2 {
                Sleep, 50
                _search := new _ImageSearch()
                    .setFile(this.lootingJsonObj.images.okButtonImage)
                    .setFolder(ImagesConfig.clientButtonsFolder "\ok")
                    .setVariation(OldBotSettings.settingsJsonObj.images.client.menu.menuImagesVariation)
                    .setClickOffsets(4)
                    .search()
                    .click()

                if (_search.found()) {
                    break
                }
            }
        } else {
            Sleep, 100
            Send("Enter")
        }
    }

    setOpenCorpseSearchArea()
    {
        if (this.openCorpseSearchArea) {
            return
        }
            new _CharPosition()
            new _GameWindowArea()
        this.openCorpseSearchArea := {}
        this.openCorpseSearchArea.x1 := CHAR_POS_X - (SQM_SIZE * 3)
        this.openCorpseSearchArea.y1 := CHAR_POS_Y - (SQM_SIZE * 3)
        this.openCorpseSearchArea.x2 := CHAR_POS_X + (SQM_SIZE * 3)
        this.openCorpseSearchArea.y2 := CHAR_POS_Y + (SQM_SIZE * 3)
        return

        this.openCorpseSearchArea := {}
        this.openCorpseSearchArea.x1 := CHAR_POS_X - (SQM_SIZE * 2) + (SQM_SIZE / 2)
        this.openCorpseSearchArea.y1 := CHAR_POS_Y - (SQM_SIZE * 2) + (SQM_SIZE / 2)
        this.openCorpseSearchArea.x2 := CHAR_POS_X + (SQM_SIZE * 2) - (SQM_SIZE / 2)
        this.openCorpseSearchArea.y2 := CHAR_POS_Y + (SQM_SIZE * 2) - (SQM_SIZE / 2)
    }

    getLootSearchArea() {
        if (this.lootingJsonObj.options.openCorpsesAround != true)
            return

        try ClientAreas.readLootSearchArea()
        catch e {
            writeCavebotLog("ERROR", A_ThisFunc " | " e.Message " | " e.What)
            return false
        }

        try ClientAreas.readLootBackpackPosition()
        catch e {
            writeCavebotLog("ERROR", A_ThisFunc " | " e.Message " | " e.What)
            return false
        }

        if (this.lootingJsonObj.options.debug = true) {
            MouseMove, % WindowX + ClientAreas.lootSearchArea.x1, WindowY + ClientAreas.lootSearchArea.y1
            msgbox, % "lootSearchArea x1,y1"
            MouseMove, % WindowX + ClientAreas.lootSearchArea.x2, WindowY + ClientAreas.lootSearchArea.y2
            msgbox, % "lootSearchArea x2,y2"
        }
    }

    lootSqmsAround(fromHotkey := false) {
        if (fromHotkey = false) && (this.lootingJsonObj.delays.delayBeforeLooting > 0)
            Sleep, % this.lootingJsonObj.delays.delayBeforeLooting

        this.clickOnSqmsAround()

        if (lootingSettingsObj.quickLootingHotkey != "Shift & Right Click") {
            return
        }

        ; Loop, 2 {
        Sleep, 50
        ReleaseShift()
        /**
        small delay after looting itens and releasing shift
        */
        Sleep, 25
        ; }
    }

    clickOnSqmsAround(fromHotkey := false) {
        holdShift := false
        clickButton := "Right"
        switch lootingSettingsObj.quickLootingHotkey {
            case "Shift & Right Click":
                holdShift := true
            case "Left Click":
                clickButton := "Left"
        }

        ; if (holdShift) {
        ;     HoldShift()
        ;     Sleep, 25
        ; }

        this.mouseClickLoot(clickButton, SQM1X, SQM1Y, holdShift)
        this.mouseClickLoot(clickButton, SQM2X, SQM2Y, holdShift)
        this.mouseClickLoot(clickButton, SQM3X, SQM3Y, holdShift)
        this.mouseClickLoot(clickButton, SQM6X, SQM6Y, holdShift)
        this.mouseClickLoot(clickButton, SQM9X, SQM9Y, holdShift)
        this.mouseClickLoot(clickButton, SQM8X, SQM8Y, holdShift)
        this.mouseClickLoot(clickButton, SQM7X, SQM7Y, holdShift)
        this.mouseClickLoot(clickButton, SQM4X, SQM4Y, holdShift)

        if (LootingSystem.lootCharacterSqm || this.lootingJsonObj.options.lootCharacterSqm) {
            this.mouseClickLoot(clickButton, SQM5X, SQM5Y, holdShift)
        }
    }

    mouseClickLoot(clickButton, X,Y, holdShift := false)
    {
        if (holdShift) {
            ClickShift({"button": "Right", "posX": X, "posY": Y})
            sleep, 10
            return
            ; HoldShift()
        }

        if (backgroundMouseInput = false)
            MouseClick, %clickButton%, WindowX + X, WindowY + Y
        else{
            MouseClick(clickButton, X, Y, debug := false, clientWindowID := "", waitModifierKeys := false)
        }
        /**
        test to run faster on remote acess mode
        dont sleep when no background input
        */
        if (backgroundMouseInput = true)
            Sleep, 5
        if (this.lootingJsonObj.delays.quickLootClickAroundDelay > 0)
            Sleep, % this.lootingJsonObj.delays.quickLootClickAroundDelay
    }

    lootAroundFromTargeting(delayBeforeLooting := true)
    {
            new _WaitDisconnected()

        this.runBeforeLootingAction()

        lootingObj.settings.lootingMode := "Loot around char position"

        if (this.lootingJsonObj.options.openCorpsesAround) && (!this.checkOpenNextBackpack()) {
            ; small sleep to not miss target
            if (delayBeforeLooting = true)
                Sleep, 100
        }

        afterAllkillString := (lootingObj.settings.lootAfterAllKill = true) ? " (after all kill)" : ""
        switch (this.lootingMethod) {
            case "Press hotkey":
                lootingHtk := new _LootingSettings().get("lootingHotkey")
                writeCavebotLog("Looter", "Looting... Method: " this.lootingMethod ", hotkey: " lootingHtk "" afterAllkillString)
                if (lootingHtk = "") {
                    writeCavebotLog("WARNING", "Empty looting hotkey, could not loot, change the looting method to ""Click around"" or set a hotkey.", true)
                    return
                }
                if (this.lootingJsonObj.delays.delayBeforePressLootingHotkey > 0)
                    Sleep, % this.lootingJsonObj.delays.delayBeforePressLootingHotkey
                Loop, % (lootingObj.settings.lootTwice = 1) ? 2 : 1
                    Send(lootingHtk)

            default:
                hotkeyString := lootingSettingsObj.quickLootingHotkey != "" ? ", hotkey: " lootingSettingsObj.quickLootingHotkey : ""
                if (this.lootingJsonObj.options.openCorpsesAround = true)
                    hotkeyString := ", open corpses around"
                writeCavebotLog("Looter", "Looting... Method: " this.lootingMethod "" hotkeyString "" afterAllkillString)

                if (this.lootingJsonObj.options.openCorpsesAround) {
                    try {
                        this.lootCorpsesAround()
                    } catch e {
                        writeCavebotLog("ERROR", e.Message)
                    }
                } else {
                    this.lootSqmsAround()

                    if (this.lootingJsonObj.options.pressEscAfterQuickLooting) {
                        Sleep, 50
                        Loop, 2 {
                            Send("Esc")
                        }
                        Sleep, 150 ; delay after pressing esc to recognize the input and not bug the targeting attack
                    }
                }
        }

        this.runAfterLootingAction()
    }

    runAfterLootingAction() {
        if (!waypointsObj.HasKey("Special"))
            return
        ActionScript.runactionwaypoint({1: "AfterLooting", 2: "Special"}, log := false)
    }

    runBeforeLootingAction() {
        if (!waypointsObj.HasKey("Special"))
            return
        ActionScript.runactionwaypoint({1: "BeforeLooting", 2: "Special"}, log := false)
    }

    searchAttributeItemsMiracle()
    {

    }





}
