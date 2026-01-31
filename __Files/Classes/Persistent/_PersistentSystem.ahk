global persistentSystemObj
global Waypoint ; for action script

Class _PersistentSystem
{
    __New()
    {
        global

        classLoaded("MemoryManager", MemoryManager)

        persistentSystemObj := {}


        this.telegramMessageDelay := 5
        this.telegramScreenshotDelay := 10

        this.timeSinceLastScreenshot := 0
        this.timeSinceLastMessage := 0


        this.userValuesCache := {}
        for persistentID, atributes in persistentObj
        {
            persistentSystemObj[persistentID] := {}
            this.userValuesCache[persistentID] := {}
        }

    }

    createPersistentActionScriptsVariablesObj() {
        if (!IsObject(ActionScriptHandler)) {
            msgbox, 16, % A_ThisFunc, % "ActionScriptHandler not initialized."
            return
        }

        for persistentID, atributes in persistentObj
        {
            ; msgbox, % serialize(atributes)
            if (!InStr(atributes.action, "Action Script"))
                continue

            ArrayVars := StrSplit(StrReplace(atributes.actionScript, "`n", "<br>"), "<br>")
            ; msgbox, % serialize(ArrayVars)
            ActionScriptHandler.setActionScriptsVariablesObjValues(ArrayVars, tabName := "", persistentID, "persistent")
        }
    }

    telegramMessage(persistentID) {
        if (this.timeSinceLastMessage != 0)
            return
        message := this.getUserValuePersistent(persistentID, "message")
        icon := this.getUserValuePersistent(persistentID, "icon")

        if (message = "") {
            _Logger.error("Empty telegram message for persistent " persistentID, A_ThisFunc)
            return
        }

        switch icon {
            case "error":
                icon := 16
            case "alert":
                icon := 48
            default:
                icon := 64
        }

        if (this.timeSinceLastMessage = 0) {
            this.startMessageTimer()
        }

        try {
            TelegramAPI.sendMessageTelegram(message, icon := 32, waitThreadFinish := false)
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }

        return true
    }

    saveScreenshot(persistentID, sendTelegram := false) {
        if (sendTelegram = true) && (this.timeSinceLastScreenshot != 0)
            return

        switch sendTelegram {
            case false:
                lastScreenshot := 1
                loop, % PersistentHandler.persistentScreenshotFolder "\*.png"{
                    if (InStr(A_LoopFileName, "telegram"))
                        continue
                    lastScreenshot++
                }
                screenshotName := "persistent" persistentID "_" lastScreenshot
            case true:
                screenshotName := "telegram_persistent" persistentID
        }
        caption := "Persistent ID: " persistentID " | Interval: " persistentObj[persistentID].interval " seconds"

        outfile := PersistentHandler.persistentScreenshotFolder "\" screenshotName ".png"

        try {
            pBitmap := _BitmapEngine.getClientBitmap().get()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }

        Gdip_SaveBitmapToFile(pBitmap, outfile, 100)

        if (sendTelegram = true) {
            if (this.timeSinceLastScreenshot = 0) {
                this.startScreenshotTimer()
            }

            try {
                TelegramAPI.sendFileTelegram(caption, outfile, photo := true, waitThreadFinish := false)
            } catch e {
                _Logger.exception(e, A_ThisFunc, outfile)
                return false
            }
        }

        return true
    }

    startMessageTimer() {
        this.timeSinceLastMessage := 1
        SetTimer, messageTimer, Delete
        SetTimer, messageTimer, 1000
    }

    startScreenshotTimer() {
        this.timeSinceLastScreenshot := 1
        SetTimer, screenshotTimer, Delete
        SetTimer, screenshotTimer, 1000
    }

    incrementMessageTime() {
        if (this.timeSinceLastMessage < 1)
            this.timeSinceLastMessage := 1
        if (this.timeSinceLastMessage > this.telegramMessageDelay) {
            SetTimer, messageTimer, Delete
            this.timeSinceLastMessage := 0
            return
        }

        this.timeSinceLastMessage++
    }

    incrementScreenshotTime() {
        if (this.timeSinceLastScreenshot < 1)
            this.timeSinceLastScreenshot := 1
        if (this.timeSinceLastScreenshot > this.telegramScreenshotDelay) {
            SetTimer, screenshotTimer, Delete
            this.timeSinceLastScreenshot := 0
            return
        }

        this.timeSinceLastScreenshot++
    }

    getUserValuePersistent(persistentID, userValueKey) {
        if (this.userValuesCache[persistentID][userValueKey] != "") {
            return this.userValuesCache[persistentID][userValueKey]
        }

        for i, values in persistentObj[persistentID].userValue
        {
            for key, value in values
            {
                if (key = userValueKey) {
                    this.userValuesCache[persistentID][userValueKey] := value
                    return value
                }
            }
        }

    }

    userValueMessage(persistentID) {
        for i, values in persistentObj[persistentID].userValue
        {
            for key, value in values
            {
                if (key = "message")
                    return value
            }
        }
    }

    actionScriptPersistent(persistentID, clientWindowID := "") {
        if (!IsObject(ActionScript)) {
            msgbox, 16, % A_ThisFunc, % "ActionScript not initialized."
            return
        }
        ; msgbox, % persistentObj[persistentID].actionScript
        showTooltip := this.getUserValuePersistent(persistentID, "showTooltip")
        showTooltip := showTooltip = "true" ? true : false

        if (showTooltip = true)
            Tooltip, % "Persistent " persistentID "..."
        global Waypoint := persistentID


        result := ActionScript.ActionScriptWaypoint(persistentID, persistentObj[persistentID].actionScript, "persistent")
        ; result := ActionScript.performActionScriptFunction(functionName, functionValues, "persistentModule")

        ; msgbox, % result
        if (showTooltip = true)
            Tooltip
    }

    antiIdle(clientWindowID := "")
    {
        new _AntiIdle().run()
    }

    goToLabelItemCount(persistentID, label := "", item := "", condition := "", value := "") {
        if (label = "")
            return
        if (item = "")
            return
        if (condition = "")
            return
        if (value = "" OR value < 0)
            return
        if (persistentSystemObj[persistentID].labelTriggered = true)
            return

        countValue := ActionScript.itemcount({1: item}, true)
        if (countValue < 0)
            return

        conditionTrue := false
        switch condition {
            case "<":
                if (countValue < value)
                    conditionTrue := true
            case "<=":
                if (countValue <= value)
                    conditionTrue := true
            case "=":
                if (countValue = value)
                    conditionTrue := true
            case ">":
                if (countValue > value)
                    conditionTrue := true
            case ">=":
                if (countValue >= value)
                    conditionTrue := true
            default:
                _Logger.error("Invalid condition: """ condition """.", A_ThisFunc)
                return false

        }

        if (conditionTrue = false)
            return

        this.goToLabelPersistent(persistentID, label)
    }

    goToLabelPersistent(persistentID, label) {
        ; OutputDebug(persistentID, label " | " persistentSystemObj[persistentID].labelTriggered)
        if (persistentSystemObj[persistentID].labelTriggered = true)
            return
        ; msgbox, going to label: %label%

        persistentSystemObj[persistentID].labelTriggered := true
        OutputDebug(persistentID, "Going to label: " label )
        Send_WM_COPYDATA("gotolabel/" label, "Cavebot Logs", 2000)
        return 
    }

    pressHotkey(key := "", clientWindowID := "") {
        if (key = "")
            return
        Send(key, clientWindowID)
        return
    }

    /**
    * @return void
    */
    pressHotkeyIfImageIsFoundPersistent(key := "", imageName := "", variation := 40) {
        if (key = "") OR (imageName = "") {
            return
        }

        try {
            _search := _ScriptImages.search(imageName, variation)
        } catch e {
            _Logger.exception(e, A_ThisFunc, imageName)
            return
        }

        if (_search.notFound()) {
            return
        }

        Send(key)
    }

    pressHotkeyIfImagePersistent(persistentID, condition := "", hotkey := "", images := "", variation := 40) {
        if (hotkey = "") OR (images = "")
            return
        ; OutputDebug(A_ThisFunc, condition)
        condition := LTrim(RTrim(condition))
        condition := (condition = "is found") ? condition : "not found"

        images := StrSplit(images, "|")
        if (images.Count() < 1) {
            OutputDebug(A_ThisFunc, "No images to search on ""image"" user value, persistent: " persistentID) 
            return
        }

        delayAfterKeyPress := this.getUserValuePersistent(persistentID, "delayAfterKeyPress")
        searchArea := this.getSearchAreaPersistent(persistentID)
        for key, imageName in images
        {
            imageName := LTrim(RTrim(imageName))
            vars := this.searchImagePersistent(imageName, variation, searchArea)
            ; msgbox, % imageName "`n" serialize(vars)
            switch condition {
                case "is found":
                    if (!vars.x)
                        continue
                default:
                    if (vars.x)
                        continue
            }
            Send(hotkey)
            if (key > 1)
                Sleep, % delayAfterKeyPress

        }


    }

    runFile(directory := "") {

        if (directory = "")
            return

        if (!FileExist(directory)) {
            _Logger.error("File doesn't exist in directory: " A_WorkingDir "\" directory, A_ThisFunc, imageName)
            return
        }

        try {
            Run, % directory
        } catch e {
            _Logger.exception(e, A_ThisFunc, directory)
        }
    }

    clickOnImagePersistent(persistentID, images := "", clickButton := "", holdCtrl := "false", variation := 40) {
        ; msgbox, % A_ThisFunc
        if (images = "")
            return

        clickButton := this.getUserValuePersistent(persistentID, "button")
        if (clickButton != "Left" && clickButton != "Right")
            return

        images := StrSplit(images, "|")
        if (images.Count() < 1) {
            OutputDebug(A_ThisFunc, "No images to search on ""image"" user value, persistent: " persistentID) 
            return
        }

        delayAfterClick := this.getUserValuePersistent(persistentID, "delayAfterClick")
        searchArea := this.getSearchAreaPersistent(persistentID)
        for key, imageName in images
        {
            imageName := LTrim(RTrim(imageName))
            vars := this.searchImagePersistent(imageName, variation, searchArea)
            if (vars.x) {
                if (holdCtrl = "true")
                    this.clickActionPersistent(clickButton, vars.x, vars.y, "withCtrl", clientWindowID)
                else
                    this.clickActionPersistent(clickButton, vars.x, vars.y, "", clientWindowID)
                if (key > 1)
                    Sleep, % delayAfterClick
            }
        }
    }

    /**
    * @return _Coordinate
    */
    searchImagePersistent(imageName, variation, searchArea := "sideBarsArea") {
        try {
            _search := _ScriptImages.search(imageName, variation, searchArea)
        } catch e {
            _Logger.exception(e, A_ThisFunc, imageName)
            return
        }

        return _search.getResult()
    }

    useItemPersistent(persistentID, itemName) {
        try {
            _ := new _ItemSearch()
                .setName(itemName)
                .search()
                .use()
        } catch e {
            _Logger.exception(e, A_ThisFunc, itemName)
        }
    }

    /**
    * @return void
    */
    clickOnPosition(persistentID, clickButton := "", holdCtrl := "false", clientWindowID := "") {
        if (clickButton != "Left" && clickButton != "Right") {
            return
        }

        x := this.getUserValuePersistent(persistentID, "x")
            , y := this.getUserValuePersistent(persistentID, "y")
        if (x = "" OR y = "") {
            return
        }

        if (holdCtrl = "true") {
            this.clickActionPersistent(clickButton, x, y, "withCtrl", clientWindowID)
        } else {
            this.clickActionPersistent(clickButton, x, y, "", clientWindowID)
        }
    }  

    /**
    * @param int persistentID
    * @return void
    */
    convertGold(persistentID) {
        hotkey := this.getUserValuePersistent(persistentID, "hotkey")

        baseSearch := new _ImageSearch()
            .setFolder(ImagesConfig.cavebotFolder)
            .setVariation(OldBotSettings.settingsJsonObj.options.itemSearchVariation)
            .setArea(new _SideBarsArea())
        try {
            _search := baseSearch
                .setFile(OldBotSettings.settingsJsonObj.images.convertGold.100goldCoin)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return
        }

        this.clickConvertGoldPersistent(_search.getResult(), hotkey)

        try {
            _search := baseSearch
                .setFile(OldBotSettings.settingsJsonObj.images.convertGold.100platinumCoin)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return
        }

        this.clickConvertGoldPersistent(_search.getResult(), hotkey)
    }

    clickConvertGoldPersistent(goldPos, hotkey) {
        if (goldPos.x = "")
            return
        if (hotkey != "") {
            Send(hotkey)
            Sleep, 50
            this.clickActionPersistent("Left", goldPos.x + 4, goldPos.y + 4)
            return
        }

        this.clickActionPersistent("Right", goldPos.x + 4, goldPos.y + 4, "useClassicControl")
    }

    clickActionPersistent(clickButton, x, y, clickAction := "", clientWindowID := "") {
        Loop, {
            IniRead, CavebotClickingOnMinimap, %DefaultProfile%, others_cavebot, CavebotClickingOnMinimap, 0
            if (CavebotClickingOnMinimap = 0)
                break
            Sleep, 100
            ; msgbox, % "Waiting for cavebot minimap click: " clickAction
            if (A_Index > 100)
                IniDelete, %DefaultProfile%, others_cavebot, CavebotClickingOnMinimap

        }
        switch clickAction {
            case "withCtrl":
                MouseClickModifier("Ctrl", clickButton, x, y, false, clientWindowID)
            case "useClassicControl":
                rightClickUseClassicControl(x, y, debug := false, clientWindowID)
            default:
                MouseClick(clickButton, x, y, debug := false, clientWindowID)
        }

    }

    getSearchAreaPersistent(persistentID) {
        searchArea := this.getUserValuePersistent(persistentID, "searchArea")
        if (searchArea = "")
            return "searchArea"
        return searchArea
    }

}