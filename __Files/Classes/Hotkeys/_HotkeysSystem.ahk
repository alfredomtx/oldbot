global hotkeysSystemObj
global Waypoint ; for action script


Class _HotkeysSystem
{
    __New()
    {
        global

        classLoaded("MemoryManager", MemoryManager)

        hotkeysSystemObj := {}

        this.telegramMessageDelay := 5
        this.telegramScreenshotDelay := 10

        this.timeSinceLastScreenshot := 0
        this.timeSinceLastMessage := 0


        this.userValuesCache := {}
        for hotkeyID, atributes in hotkeysObj
        {
            this.userValuesCache[hotkeyID] := {}
        }

    }

    throwError(func, error) {
        FileAppend, % "`n" A_Hour ":" A_Min ":" A_Sec " " A_MDay "/" A_Mon " | " error, Data\Files\logs_errors_hotkeys.txt
        OutputDebug(func, error) 
    }

    getUserValueHotkey(hotkeyID, userValueKey) {
        if (this.userValuesCache[hotkeyID][userValueKey] != "") {
            return this.userValuesCache[hotkeyID][userValueKey]
        }

        for i, values in hotkeysObj[hotkeyID].userValue
        {
            for key, value in values
            {
                if (key = userValueKey) {
                    this.userValuesCache[hotkeyID][userValueKey] := value
                    return value
                }
            }
        }

    }

    userValueMessage(hotkeyID) {
        for i, values in hotkeysObj[hotkeyID].userValue
        {
            for key, value in values
            {
                if (key = "message")
                    return value
            }
        }
    }

    createHotkeysActionScriptsVariablesObj() {
        if (!IsObject(ActionScriptHandler)) {
            msgbox, 16, % A_ThisFunc, % "ActionScriptHandler not initialized."
            return
        }

        for hotkeyID, atributes in hotkeysObj
        {
            if (!InStr(atributes.action, "Action Script"))
                continue

            ; msgbox, % atributes.action
            ArrayVars := StrSplit(StrReplace(atributes.actionScript, "`n", "<br>"), "<br>")
            ; msgbox, % serialize(ArrayVars)
            ActionScriptHandler.setActionScriptsVariablesObjValues(ArrayVars, tabName := "", hotkeyID, "hotkey")
        }
    }

    /**
    * @return _ItemSearch
    */
    searchItemHotkey(hotkeyID) {
        try {
            return new _ItemSearch()
                .setName(this.getUserValueHotkey(hotkeyID, "item"))
                .search()
                .getResult()
        } catch e {
            _Logger.exception(e, A_ThisFunc, itemName)
        }
    }

    /**
    * @return _Coordinate|bool
    */
    searchImageHotkey(imageName := "", variation := "", searchArea := "sideBarsArea") {
        if (imageName = "")
            return false

        try {
            _search := _ScriptImages.search(imageName, variation, searchArea)
        } catch e {
            this.throwError(A_ThisFunc, e.Message " | " e.What)   
            return false
        }

        if (_search.notFound())
            return false

        return _search.getResult()
    }


    actionScriptHotkey(hotkeyID) {

        ; msgbox, % hotkeysObj[otkeyID].actionScript
        showTooltip := this.getUserValueHotkey(hotkeyID, "showTooltip")
        showTooltip := showTooltip = "true" ? true : false


        if (showTooltip = true)
            Tooltip, % "Hotkey " hotkeyID "..."
        global Waypoint := hotkeyID


        result := ActionScript.ActionScriptWaypoint(hotkeyID, hotkeysObj[hotkeyID].actionScript, "hotkey")
        ; result := ActionScript.performActionScriptFunction(functionName, functionValues, "HotkeysModule")

        ; msgbox, % result
        if (showTooltip = true)
            Tooltip

    }

    lootItemsHotkey(hotkeyID) {
        if (!IsObject(LootingSystem.lootingFromHotkeyOptions)) {
            LootingSystem.createFromHotkeyOptions(this.getUserValueHotkey(hotkeyID, "moveOnlyOneItem")
                , this.getUserValueHotkey(hotkeyID, "showTooltipWhenFinished")
                , this.getUserValueHotkey(hotkeyID, "pressEnterAfterMoveItem")
                , this.getUserValueHotkey(hotkeyID, "tooltipDuration") )
        }
        LootingSystem.searchLoot(fromHotkey := true)
    }

    lootAroundHotkey() {
        LootingSystem.startLootingAround(fromHotkey := true)
    }

    lootAroundQuickLootingHotkey() {
        LootingSystem.lootSqmsAround()
    }

    shootRuneOnTargetHotkey(hotkeyID) {
        _search := new _IsAttacking()
        ; msgbox, % redPixFound

        if (_search.notFound()) {
            return
        }

        if (!this.searchAndUseItem(hotkeyID)) {
            return
        }

        _search.setClickOffsets(8)
            .click()
    }

    hotkeyUseItemOnCharacterHotkey(hotkeyID) {
        ; static charPosition
        ; if (!charPosition) {
        ;     charPosition := new _CharPosition()
        ; }

        if (!this.searchAndUseItem(hotkeyID)) {
            return
        }

        coord := new _CharPosition().getPosition()
        if (this.getUserValueHotkey(hotkeyID, "debug")) {
            coord.debug()
        }

        try {
            BlockInput, MouseMove
            Sleep, 25
            coord.click()
        } finally {
            Sleep, 25
            BlockInput, MouseMoveOff
        }
    }

    /**
    * @param string itemName
    * @return bool
    */
    searchAndUseItem(hotkeyID) {
        itemSearch := this.searchItemHotkey(hotkeyID)
        if (!itemSearch) {
            return false
        }

        itemSearch.use()
        Sleep, 75

        return true
    }

    useItemOnTargetHotkey(hotkeyID) {
        _search := new _SioSystem().isFollowing()
        if (_search.notFound()) {
            return
        }

        if (!this.searchAndUseItem(hotkeyID)) {
            return
        }

        _search.click()
    }

    useItemOnMousePositionHotkey(hotkeyID) {
        if (!this.getMousePosition()) {
            return
        }

        if (!this.searchAndUseItem(hotkeyID)) {
            return
        }

        MouseClick("Left", this.mouseX, this.mouseY, false)
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

    clickMouseHotkey(clickButton, x, y, holdCtrl := false) {
        if (holdCtrl = true) {
            MouseClickModifier("Ctrl", clickButton, x, y)
            return
        } 

        MouseClick(clickButton, x, y)
        /**
        if (holdCtrl = true)
        HoldCtrl()
        MouseClick(clickButton, x, y)
        if (holdCtrl = true) {
        Sleep, 50
        ReleaseCtrl()
        }
        */
    }

    dragMouseHotkey(x1, y1, x2, y2, holdCtrl := false, holdShift := false) {
        ; mousemove, WindowX + x1, WindowY + y1
        ; msgbox, a
        ; mousemove, WindowX + x2, WindowY + y2
        ; msgbox, b
        sleepDelay := false
        if (holdCtrl = true)
            HoldCtrl(), sleepDelay := true
        else if (holdShift = true)
            HoldShift(), sleepDelay := true
        if (sleepDelay = true)
            Sleep, 25
        MouseDrag(x1, y1, x2, y2)
        if (holdCtrl = true) {
            Sleep, 50
            ReleaseCtrl()
        } else if (holdShift = true) {
            Sleep, 50
            ReleaseShift()
        }
    }

    dragMouseToItemHotkey(hotkeyID) {
        holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        if (!this.getMousePosition()) {
            return
        }

        itemSearch := this.searchItemHotkey(hotkeyID)
        if (!itemSearch) {
            return
        }

        this.dragMouseHotkey(this.mouseX, this.mouseY, itemSearch.x, itemSearch.y, holdCtrl, holdShift)
    }

    dragMouseToImageHotkey(hotkeyID, variation := 40) {

        imageName := this.getUserValueHotkey(hotkeyID, "image")
            , holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        if (!this.getMousePosition()) {
            return
        }

        searchArea := this.getSearchAreaHotkeys(hotkeyID)
        vars := this.searchImageHotkey(imageName, variation, searchArea)
        if (vars = false)
            return

        this.dragMouseHotkey(this.mouseX, this.mouseY, vars.x, vars.y, holdCtrl, holdShift)
    }

    dragItemToMouseHotkey(hotkeyID) {
        if (!this.getMousePosition()) {
            return
        }

        holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        itemSearch := this.searchItemHotkey(hotkeyID)
        if (!itemSearch) {
            return
        }

        this.dragMouseHotkey(itemSearch.x, itemSearch.y, this.mouseX, this.mouseY, holdCtrl, holdShift)
    }

    dragImageToMouseHotkey(hotkeyID, variation := 40) {

        imageName := this.getUserValueHotkey(hotkeyID, "image")
            , holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        if (!this.getMousePosition()) {
            return
        }

        searchArea := this.getSearchAreaHotkeys(hotkeyID)
        vars := this.searchImageHotkey(imageName, variation, searchArea)
        if (vars = false)
            return

        this.dragMouseHotkey(vars.x, vars.y, this.mouseX, this.mouseY, holdCtrl, holdShift)
    }

    dragPositionToCharacterPosition(hotkeyID) {

        x := this.getUserValueHotkey(hotkeyID, "x")
            , y := this.getUserValueHotkey(hotkeyID, "y")
            , holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        if (x < 1 OR y < 1)
            return

        this.dragMouseHotkey(x, y, CHAR_POS_X, CHAR_POS_Y, holdCtrl, holdShift)
    }

    dragPositionToMouse(hotkeyID) {

        x := this.getUserValueHotkey(hotkeyID, "x")
            , y := this.getUserValueHotkey(hotkeyID, "y")
            , holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        if (x < 1 OR y < 1)
            return

        if (!this.getMousePosition()) {
            return
        }

        this.dragMouseHotkey(x, y, this.mouseX, this.mouseY, holdCtrl, holdShift)
    }

    dragMouseToPositionHotkey(hotkeyID) {

        x := this.getUserValueHotkey(hotkeyID, "x")
            , y := this.getUserValueHotkey(hotkeyID, "y")
            , holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        if (x < 1 OR y < 1)
            return

        if (!this.getMousePosition()) {
            return
        }

        this.dragMouseHotkey(this.mouseX, this.mouseY, x, y, holdCtrl, holdShift)
    }

    dragPositionToItemHotkey(hotkeyID)
    {
        x := this.getUserValueHotkey(hotkeyID, "x")
            , y := this.getUserValueHotkey(hotkeyID, "y")
            , holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        if (x < 1 OR y < 1) {
            return
        }

        itemSearch := this.searchItemHotkey(hotkeyID)
        if (!itemSearch) {
            return
        }

        this.dragMouseHotkey(x, y, itemSearch.x, itemSearch.y, holdCtrl, holdShift)
    }

    dragPositionToPositionHotkey(hotkeyID) {

        x1 := this.getUserValueHotkey(hotkeyID, "x1")
            , y1 := this.getUserValueHotkey(hotkeyID, "y1")
            , x2 := this.getUserValueHotkey(hotkeyID, "x2")
            , y2 := this.getUserValueHotkey(hotkeyID, "y2")
            , holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        if (x1 < 1 OR y1 < 1) OR (x2 < 1 OR y2 < 1)
            return

        this.dragMouseHotkey(x1, y1, x2, y2, holdCtrl, holdShift)
    }

    dragImageToPositionHotkey(hotkeyID, variation := 40) {

        imageName := this.getUserValueHotkey(hotkeyID, "image")
            , x := this.getUserValueHotkey(hotkeyID, "x")
            , y := this.getUserValueHotkey(hotkeyID, "y")
            , holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        if (x < 1 OR y < 1)
            return

        searchArea := this.getSearchAreaHotkeys(hotkeyID)
        vars := this.searchImageHotkey(imageName, variation, searchArea)
        if (vars = false)
            return

        this.dragMouseHotkey(vars.x, vars.y, x, y, holdCtrl, holdShift)
    }

    dragImageToCharacterPositionHotkey(hotkeyID, variation := 40) {

        imageName := this.getUserValueHotkey(hotkeyID, "image")
            , holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        searchArea := this.getSearchAreaHotkeys(hotkeyID)
        vars := this.searchImageHotkey(imageName, variation, searchArea)
        if (vars = false)
            return

        this.dragMouseHotkey(vars.x, vars.y, CHAR_POS_X, CHAR_POS_Y, holdCtrl, holdShift)
    }

    dragItemToPositionHotkey(hotkeyID)
    {
        x := this.getUserValueHotkey(hotkeyID, "x")
            , y := this.getUserValueHotkey(hotkeyID, "y")
            , holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        if (x < 1 OR y < 1) {
            return
        }

        itemSearch := this.searchItemHotkey(hotkeyID)
        if (!itemSearch) {
            return
        }

        this.dragMouseHotkey(itemSearch.x, itemSearch.y, x, y, holdCtrl, holdShift)
    }

    dragItemToCharacterPositionHotkey(hotkeyID)
    {
        static charPosition
        if (!charPosition) {
            charPosition := new _CharPosition()
        }

        holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        itemSearch := this.searchItemHotkey(hotkeyID)
        if (!itemSearch) {
            return
        }

        this.dragMouseHotkey(itemSearch.x, itemSearch.y, charPosition.getPosition().getX(), charPosition.getPosition().getY(), holdCtrl, holdShift)
    }

    dragMouseToBackpackPositionHotkey(hotkeyID) {

        holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        if (ClientAreas.lootBackpackPosition.x = "")
            return

        if (!this.getMousePosition()) {
            return
        }

        this.dragMouseHotkey(this.mouseX, this.mouseY, ClientAreas.lootBackpackPosition.x, ClientAreas.lootBackpackPosition.y, holdCtrl, holdShift)
    }

    dragCharacterPositionToMouse(hotkeyID) {

        holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        if (!this.getMousePosition()) {
            return
        }

        this.dragMouseHotkey(CHAR_POS_X, CHAR_POS_Y, this.mouseX, this.mouseY, holdCtrl, holdShift)
    }

    dragMouseToCharacterPositionHotkey(hotkeyID) {

        holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , holdShift := this.getUserValueHotkey(hotkeyID, "holdShift"), holdShift := holdShift = "true" ? true : false

        if (!this.getMousePosition()) {
            return
        }

        this.dragMouseHotkey(this.mouseX, this.mouseY, CHAR_POS_X, CHAR_POS_Y, holdCtrl, holdShift)
    }

    clickOnImageHotkey(hotkeyID) {
        imageName := this.getUserValueHotkey(hotkeyID, "item")
            , clickButton := this.getUserValueHotkey(hotkeyID, "button")
            , holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false
            , variation := this.getUserValueHotkey(hotkeyID, "variation"), variation < 1 ? 30 : variation

        if (imageName = "")
            return
        if (clickButton != "Left" && clickButton != "Right")
            return

        searchArea := this.getSearchAreaHotkeys(hotkeyID)
        vars := this.searchImageHotkey(imageName, variation, searchArea)
        if (vars = false)
            return

        this.clickMouseHotkey(clickButton, vars.x, vars.y, holdCtrl)
    }

    clickOnItemHotkey(hotkeyID)
    {
        clickButton := this.getUserValueHotkey(hotkeyID, "button")
            , holdCtrl := this.getUserValueHotkey(hotkeyID, "holdCtrl"), holdCtrl := holdCtrl = "true" ? true : false

        ; msgbox, % serialize(hotkeysObj[hotkeyID].userValue)
        ; msgbox, % clickButton
        if (clickButton != "Left" && clickButton != "Right")
            return

        itemSearch := this.searchItemHotkey(hotkeyID)
        if (!itemSearch) {
            return
        }

        this.clickMouseHotkey(clickButton, itemSearch.x, itemSearch.y, holdCtrl)
    }

    healingPotion(type) {

        switch type {
            case "life":
                healingItemName := healingObj.life["lowItemName"]
                if (healingItemName = "")
                    healingItemName := healingObj.life["midItemName"]
            case "mana":
                healingItemName := healingObj.mana.manaItemName
        }

        if (healingItemName = "")
            return
        HealingSystem.useItemOnChar(healingItemName)

        MouseClick("Left", CHAR_POS_X, CHAR_POS_Y)
    }

    getSearchAreaHotkeys(hotkeyID) {
        searchArea := this.getUserValueHotkey(hotkeyID, "searchArea")
        if (searchArea = "")
            return "searchArea"
        return searchArea
    }
} ; Class
