global alertsSystemObj
Class _AlertsSystem
{
    __New()
    {
        global
        classLoaded("MemoryManager", MemoryManager)

        IniRead, version, % "Data/Files/version.ini", settings, cavebotVersion, %A_Space%
        if (version = "" or version = A_Space) {
            IniRead, version, % "Data/Files/version.ini", settings, version, %A_Space%
            if (version = "" or version = A_Space) {
                msgbox, 48,, % "Failed to read version for Alerts, please contact support.", 10
            }
        }

        /**
        Must be the same as in Cavebot.ahk
        */
        this.cavebotLogsWindowTitle := "Logs (v" version ") - " currentScript


        alertsSystemObj := {}

        this.alertsScreenshotFolder := "Data\Screenshots\Alerts"

        if (!FileExist(this.alertsScreenshotFolder))
            FileCreateDir, % this.alertsScreenshotFolder


        this.telegramMessageDelay := 20
        this.telegramScreenshotDelay := 40

        this.timeSinceLastScreenshot := 0
        this.timeSinceLastMessage := 0


        this.pauseCavebotToSay := false
        this.isCavebotPaused := false

        this.wasDisconnected := false


        this.userValuesCache := {}
        for alertName, _ in alertsObj
        {
            alertsSystemObj[alertName] := {}
            this.userValuesCache[alertName] := {}
        }


        this.alertsDefaultSearchArea := "sideBarsArea"
        this.settingsKey := "settings"



        this.pkImages := {}
        this.pkImages.Push("white_skull")
        this.pkImages.Push("red_skull")
    }

    /**
    * actions to do before checking the alert
    * @param bool checkDisconnected
    * @param string alertName
    * @return bool
    */
    beforeCheckAlert(checkDisconnected, alertName) {
        ; TibiaClient.isClientClosed(false, "Alerts") ; check if client is closed and reload if true

        if (checkDisconnected = true) && (isDisconnected()) {
            this.wasDisconnected := true
            Sleep, 1000
            return false
        }
        /**
        if was disconnected before, wait a bit before releasing the alert
        */
        if (this.wasDisconnected) {
            this.wasDisconnected := false
            Sleep, 2000
        }

        if (this.getUserValue(alertName, "ignoreInProtectionZone") = "true") {
            if (isInProtectionZone()) {
                return false
            }
        }

        return this.checkIgnoreTab(alertName)
    }

    /**
    * @param string alertName
    * @return bool
    */
    checkIgnoreTab(alertName) {
        IniRead, CurrentWaypointTab, %DefaultProfile%, cavebot, CurrentWaypointTab, %A_Space%
        if (empty(CurrentWaypointTab)) {
            return true
        }

        ignoreTab := this.getUserValue(alertName, "ignoreIfCurrentWaypointTab")
        ignoreTabs := StrSplit(ignoreTab, "|")

        if (ignoreTabs.Count() > 1) {
            for _, ignoreTabName in ignoreTabs
            {
                ignoreTabName := LTrim(RTrim(ignoreTabName))
                if (CurrentWaypointTab = ignoreTabName) {
                    return false
                }
            }
        } else {
            if (CurrentWaypointTab = ignoreTab) {
                return false
            }
        }

        return true
    }

    alertCharacterStuck(alertName) {
        ; OutputDebug(A_ThisFunc, "")
        this.beforeCheckAlert(true, alertName)

        isStuck := false
        if (isStuck = true) {
            telegramMessage := this.userValueMessageAlerts(alertName)
            this.alertFunctions(alertName, "character_stuck.mp3", !empty(telegramMessage) ? telegramMessage : "Character stuck.")
        }
    }

    alertDisconnected(alertName) {
        ; OutputDebug(A_ThisFunc, isDisconnected())

        this.beforeCheckAlert(false, alertName)

        if (isDisconnected()) {
            telegramMessage := this.userValueMessageAlerts(alertName)
            this.alertFunctions(alertName, "disconnected.mp3", !empty(telegramMessage) ? telegramMessage : "Character disconnected.")
        }
    }

    alertPlayerOnBattleList(alertName) {
        if (!this.beforeCheckAlert(true, alertName)) {
            return
        }

        try {
            _search := new _SearchPlayersBattleList()
        } catch e {
            _Logger.exception(e, A_ThisFunc, alertName)
            return false
        }

        if (_search.notFound()) {
            telegramMessage := this.userValueMessageAlerts(alertName)
            this.alertFunctions(alertName, "player_on_screen.mp3", !empty(telegramMessage) ? telegramMessage : "Player on screen.", 1800)
        }
    }

    /**
    * @param string alertName
    * @return void
    */
    alertPrivateMessage(alertName) {
        static baseSearch
        if (!this.beforeCheckAlert(true, alertName)) {
            return
        }

        if (!baseSearch) {
            baseSearch := new _ImageSearch()
                .setFolder(ImagesConfig.clientFolder)
                .setVariation(10)
        }

        privateMessageArea := new _PrivateMessageArea()

        try {
            _search := baseSearch
                .setFile("private_message_pixel")
                .setArea(privateMessageArea)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, alertName)
            return
        }

        if (_search.notFound()) {
            return
        }

        try {
            _search := baseSearch
                .setFile("npc_message_pixel")
                .setCoordinates(privateMessageArea.getNpcMessageArea())
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, alertName)
            return
        }

        if (_search.found()) {
            return
        }

        telegramMessage := this.userValueMessageAlerts(alertName)
        this.alertFunctions(alertName, "private_message.mp3", !empty(telegramMessage) ? telegramMessage : "Private message.")
    }

    alertImageIsFound(alertName) {
        if (!this.beforeCheckAlert(true, alertName)) {
            return
        }

        images := this.validateImages(alertName)
        if (!images) {
            return false
        }

        variation := this.getUserValueVariation(alertName)

        searchArea := this.getSearchAreaAlert(alertName)
        for _, imageName in images
        {
            vars := this.searchImageAlert(LTrim(RTrim(imageName)), variation, searchArea)
            if (vars.x) {
                break
            }
            Sleep, 25
        }

        if (!vars.x) {
            return
        }

        telegramMessage := this.userValueMessageAlerts(alertName)
        this.alertFunctions(alertName, "image_is_found.mp3", !empty(telegramMessage) ? telegramMessage : alertName, 1800)
    }

    alertImageIsNotFound(alertName) {
        if (!this.beforeCheckAlert(true, alertName)) {
            return
        }

        images := this.validateImages(alertName)
        if (!images) {
            return false
        }

        variation := this.getUserValueVariation(alertName)

        searchArea := this.getSearchAreaAlert(alertName)
        for _, imageName in images
        {
            vars := this.searchImageAlert(LTrim(RTrim(imageName)), variation, searchArea)
            if (!vars.x) {
                break
            }
            Sleep, 25
        }

        if (vars.x) {
            return
        }

        telegramMessage := this.userValueMessageAlerts(alertName)
        this.alertFunctions(alertName, "image_is_not_found.mp3", !empty(telegramMessage) ? telegramMessage : alertName, 2000)
    }

    validateImages(alertName) {
        images := StrSplit(this.getUserValue(alertName, "image"), "|")
        if (images.Count() < 1) {
            OutputDebug(A_ThisFunc, "No images to search on ""image"" user value, alert: " imageName)
            return false
        }

        return images
    }

    /**
    * @param string alertName
    * @return int
    */
    getUserValueVariation(alertName) {
        variation := this.getUserValue(alertName, "variation")
            , variation := variation < 1 ? 30 : variation
            , variation := variation > 100 ? 100 : variation

        return variation
    }

    /**
    * @return _Coordinate
    */
    searchImageAlert(imageName, variation, searchArea := "sideBarsArea") {
        try {
            _search := _ScriptImages.search(imageName, variation, searchArea)
        } catch e {
            _Logger.exception(e, A_ThisFunc, alertName)
            return false
        }

        return _search.getResult()
    }

    alertPkOnScreen(alertName) {
        if (!this.beforeCheckAlert(true, alertName)) {
            return
        }

        for _, image in this.pkImages
        {
            try {
                _search := new _ImageSearch()
                    .setFile(image)
                    .setFolder(ImagesConfig.folder)
                    .setVariation(30)
                    .setArea(new _SideBarsArea())
                    .search()
            } catch e {
                _Logger.exception(e, A_ThisFunc, alertName)
                return false
            }
            if (_search.found()) {
                break
            }
        }

        if (_search.notFound()) {
            return
        }

        telegramMessage := this.userValueMessageAlerts(alertName)
        this.alertFunctions(alertName, "pk_on_screen.mp3", !empty(telegramMessage) ? telegramMessage : "PK on screen.", 1800)
    }

    alertBattleListNotEmpty(alertName) {
        if (!this.beforeCheckAlert(true, alertName)) {
            return
        }

        try {
            battleEmpty := new _IsBattleListEmpty()
        } catch e {
            _Logger.exception(e, A_ThisFunc, alertName)
            return false
        }

        if (!battleEmpty) {
            telegramMessage := this.userValueMessageAlerts(alertName)
            this.alertFunctions(alertName, "battlelist_not_empty.mp3", !empty(telegramMessage) ? telegramMessage : "Battle list not empty.", 1800)
        }
    }

    alertNotListedTarget(alertName)
    {
        if (!this.beforeCheckAlert(true, alertName)) {
            return
        }

        if (this.searchBattleListAlert()) {
            return
        }

        Sleep, 100

        if (this.searchBattleListAlert()) {
            return
        }

        if (this.searchRedPixelAlert()) {
            return
        }

        noneFound := this.searchCreaturesNonListedTarget()

        if (this.searchRedPixelAlert() || this.searchBattleListAlert()) {
            return
        }

        if (noneFound) {
            telegramMessage := this.userValueMessageAlerts(alertName)
            this.alertFunctions(alertName, "not_listed_target.mp3", !empty(telegramMessage) ? telegramMessage : "Not listed target.", 1800)
        }
    }

    searchRedPixelAlert() {
        Loop, 2 {
            Sleep, 75
            if (new _IsAttacking().found()) {
                return true
            }
        }

        return false
    }

    searchBattleListAlert() {
        try {
            return new _IsBattleListEmpty()
        } catch e {
            _Logger.exception(e, A_ThisFunc, alertName)
            return false
        }
    }

    searchCreaturesNonListedTarget()
    {
        for creatureName, _ in targetingObj.targetList
        {
            if (creatureName = "all") {
                continue
            }

            try {
                creatureSearch := new _SearchCreature(creatureName)
            } catch e {
                _Logger.exception(e, A_ThisFunc, alertName)
                return false
            }
            ; m(serialize(creatureSearch))
            if (creatureSearch.found()) {
                return false
            }
        }

        return true
    }

    alertFunctions(alertName, playSoundName := "", telegramMessage := "", sleepSound := 1700) {
        /**
        save screenshot before logou
        */
        if (alertsObj[alertName].screenshot = true) {
            try this.pBitmap := _BitmapEngine.getClientBitmap().get()
            catch e {
                _Logger.exception(e, A_ThisFunc, alertName)
                return false
            }
        }

        /**
        actions before logout/exitgame
        */
        sayMessage := this.getUserValue(alertName, "say")
        if (sayMessage = "true")
            this.sayAlertMessages(alertName)

        pressKey := StrSplit(this.getUserValue(alertName, "pressKey"), "|")
        if (pressKey.Count() > 0)
            this.pressKeyAlert(alertName)

        if (alertsObj[alertName].exitGame = true) {
            this.exitGame()
        } else {
            if (alertsObj[alertName].logout = true)
                this.logout()
        }

        /**
        actions after logout/exitgame
        */

        if (alertsObj[alertName].playSound = true)
            this.playSound(playSoundName)

        if (this.getUserValue(alertName, "closeCavebot") = "true")
            this.closeCavebot()
        else if (alertsObj[alertName].pauseCavebot = true)
            this.pauseCavebot(alertName)

        if (alertsObj[alertName].goToLabel = true)
            this.goToLabelAlert(alertName)

        runFile := this.getUserValue(alertName, "runFile")
        if (runFile != "")
            this.runFileAlert(alertName)

        if (alertsObj[alertName].telegram = true) {
            this.telegram(telegramMessage " | Logout: " (alertsObj[alertName].logout = true ? "true" : "false") " | Exit game: " (alertsObj[alertName].exitGame = true ? "true" : "false")  " | Pause bot: " (alertsObj[alertName].pauseCavebot = true ? "yes" : "no") " | Go to label: " (alertsObj[alertName].gotolabel = true ? (alertsObj[alertName].labelName = "" ? "<no label>" : alertsObj[alertName].labelName) : "false") )
        }

        if (alertsObj[alertName].screenshot = true)
            this.screenshot(alertName, alertsObj[alertName].telegram)

        if (alertsObj[alertName].playSound = true)
            Sleep, % sleepSound
    }

    sayAlertTrigger(alertName) {
        if (alertName = "Disconnected")
            return

        sayMessage := this.getUserValue(alertName, "say")
        if (sayMessage = "true") {
            this.sayAlertMessages(alertName)
        }
    }

    sayAlertMessages(alertName) {

        if (alertName = "Disconnected")
            return

        if (alertsSystemObj[alertName].cooldown = "")
            alertsSystemObj[alertName].cooldown := 0
        elapsedSayCooldown := (A_TickCount - alertsSystemObj[alertName].cooldown)
        cooldown := this.getUserValue(alertName, "cooldown")
        cooldown := (cooldown < 1 ? 1 : cooldown) * 1000

        ; OutputDebug(A_ThisFunc, elapsedSayCooldown " / " cooldown)
        if (elapsedSayCooldown > 0) && (elapsedSayCooldown < cooldown)
            return

        messages := StrSplit(this.getUserValue(alertName, "messages"), "|")
        ; m(serialize(messages))
        if (messages.Count() < 1)
            return
        if (this.pauseCavebotToSay = true) {
            this.pauseCavebot(alertName)
            Sleep, 50
        }
        this.turnChatOnAlert()
        Sleep, 25
        /**
        words with '
        such as Ab'dendriel
        */

        delay := this.getUserValue(alertName, "delay")

        ; m(serialize(messages))
        ; msgbox, % delay

        this.activateDefaultChatTabAlert()


        for _, msg in messages
        {
            this.sayAlert( RTrim(LTrim(msg)), (messages.Count() = 1) ? 0 : delay)
        }

        this.turnChatOffAlert()

        alertsSystemObj[alertName].cooldown := A_TickCount
        if (this.pauseCavebotToSay = true) {
            Sleep, 25
            this.unpauseCavebot()
        }
        ; Sleep, 10000

    }

    sayAlert(message, delay := 300) {

        this.turnChatOnAlert()
        Sleep, 25
        /**
        words with '
        such as Ab'dendriel
        */
        if (containsSpecialCharacter(message)) {
            clipboardOld := Clipboard
            copyToClipboard(message)
            SendModifier("Ctrl", "v")
            copyToClipboard(clipboardOld)
        } else {
            Send(message)
        }
        Sleep, 25
        Send("Enter")
        Sleep, 50
        if (delay > 1)
            Sleep, % delay
    }

    turnChatOnAlert() {
        Try {
            _ := new _ToggleChat("on")
        } catch e {
            _Logger.exception(e, A_ThisFunc, alertName)
            return false
        }

        return true
    }

    turnChatOffAlert() {
        Try {
            _ := new _ToggleChat("off")
        } catch e {
            _Logger.exception(e, A_ThisFunc, alertName)
            return false
        }
    }

    playSound(soundFile) {
        filePath := "Data\Files\Sounds\" soundFile
        if (!FileExist(filePath)) {
            _Logger.error("Sound file doesn't exist: " filePath, A_ThisFunc)
            return false
        }
        SoundPlay, % filePath
        return true
    }

    goToLabelAlert(alertName) {
        ; OutputDebug(alertName, alertsObj[alertName].labelName " | " alertsSystemObj[alertName].labelTriggered)
        if (alertsObj[alertName].labelName = "") OR (alertsSystemObj[alertName].labelTriggered = true)
            return
        ; OutputDebug(alertName "|" alertsObj[alertName].labelName)

        if (Send_WM_COPYDATA("gotolabel/" alertsObj[alertName].labelName, this.cavebotLogsWindowTitle, 2000) = true) {
            alertsSystemObj[alertName].labelTriggered := true
            ; OutputDebug(alertName, "LABEL | " alertsSystemObj[alertName].labelTriggered " / " alertsSystemObj[alertName].labelTriggered )
        }
        return
    }

    closeCavebot()
    {
        _CavebotExe.stop()
    }

    pauseCavebot(alertName) {
        this.readCavebotPaused()
        if (this.isCavebotPaused = true)
            return

        Send_WM_COPYDATA("PauseAll", this.cavebotLogsWindowTitle)
        Sleep, 150
        this.readCavebotPaused()

        ; OutputDebug(A_ThisFunc, "Cavebot paused: " this.isCavebotPaused)

        if (this.isCavebotPaused = true)
            alertsSystemObj[alertName].unpauseBotAfter := A_TickCount
    }

    readCavebotPaused() {
        IniRead, CavebotPaused, %DefaultProfile%, others_cavebot, CavebotPaused, 0
        this.isCavebotPaused := CavebotPaused
    }

    checkUnpauseCavebot(alertName) {
        ; OutputDebug(A_ThisFunc, "Pause: " alertsObj[alertName].pauseCavebot ", isPaused: " this.isCavebotPaused)
        if (!alertsObj[alertName].pauseCavebot) {
            return
        }

        if (!this.isCavebotPaused) {
            return
        }

        if (alertsSystemObj[alertName].unpauseBotAfter = "") {
            alertsSystemObj[alertName].unpauseBotAfter := 0
        }

        elapsedUnpauseBotAfter := (A_TickCount - alertsSystemObj[alertName].unpauseBotAfter) / 1000
            , unpauseBotAfter := this.getUserValue(alertName, "unpauseBotAfter")
            , unpauseBotAfter := (unpauseBotAfter < 2 ? 2 : unpauseBotAfter)

        if (elapsedUnpauseBotAfter < unpauseBotAfter) {
            return
        }

        this.unpauseCavebot()
            , alertsSystemObj[alertName].unpauseBotAfter := 0
    }

    unpauseCavebot(alertName := "") {
        if (this.isCavebotPaused = false)
            return
        if (!WinExist(this.cavebotLogsWindowTitle)) {
            OutputDebug(A_ThisFunc, """" this.cavebotLogsWindowTitle """ window does not exist.")
            return
        }

        OutputDebug(A_ThisFunc, "[" alertName "] Unpausing Cavebot")
        PostMessage, 0x111, 65306, 2,, % this.cavebotLogsWindowTitle ; Pause Off.
        ; msgbox unpaused
        if (ErrorLevel)
            OutputDebug(A_ThisFunc, "Failed to unpause Cavebot. ErrorLevel: " ErrorLevel)
        Send_WM_COPYDATA("Unpause", this.cavebotLogsWindowTitle)
        Sleep, 150
        this.readCavebotPaused()
    }

    logout() {
        Loop, 3 {
            if (isDisconnected()) {
                return true
            }
            Send("Esc")
            SleepR(70, 120)
            loop, 3
                Send("^q")
            SleepR(150, 220)
        }
        return false
    }

    exitGame() {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFile(OldBotSettings.settingsJsonObj.images.client.buttons.exit)
                .setFolder(ImagesConfig.clientButtonsFolder "\exit")
                .setVariation(OldBotSettings.settingsJsonObj.images.client.buttons.exitVariation)
                .setClickOffsets(8)
        }

        Loop, 3 {
            if (isDisconnected()) {
                return true
            }
            Send("Esc")
            Sleep, 100
            WinClose, ahk_id %TibiaClientID%
            Sleep, 200
            _search := searchCache
                .search()
                .click()
            ; Send("e")
            Sleep, 200
        }
        Send("Esc")

        return false
    }

    telegram(message) {
        ; OutputDebug(A_ThisFunc, this.timeSinceLastMessage " | " message)
        if (this.timeSinceLastMessage != 0)
            return

        if (this.timeSinceLastMessage = 0)
            this.startMessageTimer()
        try TelegramAPI.sendMessageTelegram(message, 48, false)
        catch e {
            _Logger.exception(e, A_ThisFunc, alertName)
            return false
        }
        return true
    }

    screenshot(screenshotName, sendTelegram := false) {
        ; OutputDebug(A_ThisFunc, this.timeSinceLastScreenshot " | " screenshotName " | " sendTelegram)
        if (this.timeSinceLastScreenshot != 0)
            return
        outfile := this.alertsScreenshotFolder "\" screenshotName ".png"

        Gdip_SaveBitmapToFile(this.pBitmap, outfile, 100)

        if (sendTelegram = true) {
            if (this.timeSinceLastScreenshot = 0)
                this.startScreenshotTimer()
            try TelegramAPI.sendFileTelegram(screenshotName, outfile, true, false)
            catch e {
                _Logger.exception(e, A_ThisFunc, alertName)
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

    getUserValue(alertName, userValueKey) {
        if (this.userValuesCache[alertName][userValueKey]) {
            return this.userValuesCache[alertName][userValueKey]
        }

        for _, values in alertsObj[alertName].userValue
        {
            for key, value in values
            {
                if (key = userValueKey) {
                    this.userValuesCache[alertName][userValueKey] := value
                    return value
                }
            }
        }
    }

    userValueMessageAlerts(alertName) {
        for _, values in alertsObj[alertName].userValue
        {
            for key, value in values
            {
                if (key = "telegramMessage")
                    return value
            }
        }
    }

    runFileAlert(alertName) {

        fileDir := this.getUserValue(alertName, "runFile")

        try, {
            Run, % fileDir
        } catch e {
            _Logger.exception(e, A_ThisFunc, "Failed to run file, dir: """ fileDir """")
            return false
        }

    }

    pressKeyAlert(alertName) {
        if (alertName = "Disconnected")
            return

        elapsedPressKeyCooldown := (A_TickCount - alertsSystemObj[alertName].pressKeyCooldown)
        pressKeyCooldown := this.getUserValue(alertName, "pressKeyCooldown")
        pressKeyCooldown := (pressKeyCooldown < 1 ? 1 : pressKeyCooldown) * 1000

        ; OutputDebug(A_ThisFunc, alertName ": " elapsedPressKeyCooldown " / " pressKeyCooldown)
        if (elapsedPressKeyCooldown > 0) && (elapsedPressKeyCooldown < pressKeyCooldown)
            return

        if (alertsSystemObj[alertName].pressKeyCooldown = "")
            alertsSystemObj[alertName].pressKeyCooldown := 0

        keys := StrSplit(this.getUserValue(alertName, "pressKey"), "|")
        pressKeyDelay := this.getUserValue(alertName, "pressKeyDelay")

        for _, key in keys
        {
            key := LTrim(RTrim(key))
            Send(key)
            if (A_Index > 1)
                Sleep, % pressKeyDelay
        }

        alertsSystemObj[alertName].pressKeyCooldown := A_TickCount

    }

    searchDefaultChatTabAlert() {
        if (OldBotSettings.settingsJsonObj.images.client.chat.defaultChatTab = "") {
            OutputDebug(A_ThisFunc, "Chat images are not configured for this client")
            return false
        }

        vars := ""
        try {
            vars := ImageClick({"image": OldBotSettings.settingsJsonObj.images.client.chat.defaultChatTab
                    , "directory": ImagesConfig.clientChatFolder
                    , "variation": OldBotSettings.settingsJsonObj.images.client.chat.chatImagesVariation
                    , "funcOrigin": A_ThisFunc
                    , "debug": false})
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }
        Sleep, 50

        if (!vars.x) {
            try {
                vars := ImageClick({"image": OldBotSettings.settingsJsonObj.images.client.chat.defaultChatTabUnselected
                        , "directory": ImagesConfig.clientChatFolder
                        , "variation": OldBotSettings.settingsJsonObj.images.client.chat.chatImagesVariation
                        , "funcOrigin": A_ThisFunc
                        , "debug": false})
            } catch e {
                _Logger.exception(e, A_ThisFunc)
                return false
            }
            if (!vars.x) {
                Sleep, 25
                try {
                    vars := ImageClick({"image": OldBotSettings.settingsJsonObj.images.client.chat.defaultChatTabUnselectedRed
                            , "directory": ImagesConfig.clientChatFolder
                            , "variation": OldBotSettings.settingsJsonObj.images.client.chat.chatImagesVariation
                            , "funcOrigin": A_ThisFunc
                            , "debug": false})
                } catch e {
                    _Logger.exception(e, A_ThisFunc)
                    return false
                }
                if (!vars.x) {
                    OutputDebug(A_ThisFunc, "Couldn't find the Default chat")
                    return false
                }
            }
        }
        return vars
    }

    activateDefaultChatTabAlert() {
        defaultChatPos := this.searchDefaultChatTabAlert()
        if (defaultChatPos = false)
            return false


        /**
        Click to active the chat first
        */
        MouseClick("Left", defaultChatPos.x + 12, defaultChatPos.y + 5, false)
        Sleep, 50

    }

    /**
    * @param string alertName
    * @return string
    */
    getSearchAreaAlert(alertName) {
        searchArea := this.getUserValue(alertName, "searchArea")
        if (!searchArea) {
            return this.alertsDefaultSearchArea
        }

        return searchArea
    }

}