
global TEST_VAR := false
global currentScript
global startingBot := false

global loadingGuisDisabled := false ; controls if windows are disabled when writing in the json file to avoid corruptions


; global backgroundMouseInput := false
global backgroundMouseInput :=  true
global backgroundKeyboardInput := true
global backgroundImageSearch := true

global cavebotFunctions
global fishingFunctions
global fullLighjtFunctions
global healingFunctions
global itemRefillFunctions
global reconnectFunctions
global supportFunctions


global alarmExeName
global alertsExeName
global cavebotExeName
global fishingExeName
global fullLightExeName
global healingExeName
global hotkeysExeName
global itemRefillExeName
global persistentExeName
global processMonitorExeName
global reconnectExeName
global sioFriendExeName
global supportExeName


global mainGuiPrefix := "OldBot PRO - "
global MAIN_GUI_TITLE
global SendMessageTargetWindowTitle

global settingsJson



/*
ini settings
*/
global DefaultClientJsonProfile
global disableHealingMemory
global WINDOWS_VERSION

global pToken
If !pToken := Gdip_Startup()
{
    MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
    ExitApp
}


Class _OldBotSettings
{
    __New(instanceCurrentScript := "") {
        global

        if (instanceCurrentScript = "")
            IniRead, currentScript, %DefaultProfile%, cavebot_settings, currentScript, Default
        else
            currentScript := instanceCurrentScript

        this.readExeNames()
        this.readIniOldBotGlobalSettings()

        cavebotFunctions := {}
        fishingFunctions := {}
        fullLightFunctions := {}
        healingFunctions := {}
        itemRefillFunctions := {}
        reconnectFunctions := {}
        supportFunctions := {}

        cavebotFunctions.Push("cavebotEnabled")
        cavebotFunctions.Push("targetingEnabled")

        fishingFunctions.Push("fishingEnabled")
        fullLightFunctions.Push("fullLightEnabled")

        healingFunctions.Push("lifeHealingEnabled")
        healingFunctions.Push("manaHealingEnabled")
        healingFunctions.Push("manaTrainEnabled")

        reconnectFunctions.Push("autoReconnect")

        itemRefillFunctions.Push("amuletRefillEnabled")
        itemRefillFunctions.Push("ringRefillEnabled")
        itemRefillFunctions.Push("bootsRefillEnabled")
        itemRefillFunctions.Push("quiverRefillEnabled")
        itemRefillFunctions.Push("distanceWeaponRefillEnabled")

        supportFunctions.Push("autoEatFood")
        supportFunctions.Push("autoShoot")
        ; spells
        supportFunctions.Push("autoUtamoVita")
        supportFunctions.Push("autoHaste")
        supportFunctions.Push("autoBuffSpell")
        ; conditions
        supportFunctions.Push("cureParalyze")
        supportFunctions.Push("curePoison")
        supportFunctions.Push("cureCurse")


        this.modulesList := {}
        this.modulesList.Push("alerts")
        this.modulesList.Push("cavebot")
        this.modulesList.Push("fishing")
        this.modulesList.Push("fullLight")
        this.modulesList.Push("healing")
        this.modulesList.Push("hotkeys")
        this.modulesList.Push("itemRefill")
        this.modulesList.Push("support")
        this.modulesList.Push("looting")
        this.modulesList.Push("reconnect")
        this.modulesList.Push("sioFriend")
        this.modulesList.Push("persistent")
        this.modulesList.Push("targeting")



        /**
        folders settings
        */
        this.screenshotsFolder := "Data\Screenshots"
        this.filesFolder := "Data\Files"
        this.JsonFolder := this.filesFolder "\JSON"

        this.loadSettingsJsonSettings()
        this.validateSettingsJsonSettings()
        this.applySettingsJsonSettings()
    }

    loadSettingsJsonSettings()
    {

        try {
            this.settingsJsonObj := new _SettingsJson().load()
            this.settingsJsonObj.configFile := new _SettingsJson().getFileWithExtension()
        } catch e {
            _Logger.msgboxException(16, e)
            this.settingsJsonObj := new _SettingsJson().loadDefault()
            this.settingsJsonObj.configFile := new _SettingsJson().getFileWithExtension()
        }

        return

        settingsJson := this.settingsFileJson()

        this.settingsJsonObj := settingsJson.Object()

        if (this.settingsJsonObj.HasKey("")) {
            this.settingsJsonObj.Delete("")
            settingsJson.Save(true)
        }

        this.settingsJsonObj.configFile := this.settingsJsonObj.configFile = "" ? "settings.json" : this.settingsJsonObj.configFile


        IniRead, DefaultClientJsonProfile, %DefaultProfile%, client, DefaultClientJsonProfile, %A_Space%
        ; msgbox, % this.settingsJsonObj.configFile "`n" DefaultClientJsonProfile
        /**
        Auto select the client according to the DefaultClientJsonProfileProfile
        */
        if (DefaultClientJsonProfile != "" && InStr(DefaultClientJsonProfile, ".json"))
            this.settingsJsonObj.configFile := DefaultClientJsonProfile

        settingsFileName := this.settingsJsonObj.configFile

        if (this.settingsJsonObj.configFile = "settings.json")
            return

        settingsFile := this.JsonFolder "\" this.settingsJsonObj.configFile


        if (!FileExist(settingsFile)) {
            Gui, Carregando:Destroy
            IniWrite, % "settings.json", %DefaultProfile%, client, DefaultClientJsonProfile
            Msgbox, 16, % A_ThisFunc, % "Missing file: """ A_WorkingDir "\" settingsFile """.", 10
            ExitApp
        }

        settingsJson := ""
        try {
            settingsJson := new JSONFile(settingsFile)
        } catch e {
            Msgbox, 16, % "Load JSON file: " settingsFile, % "Failed to load settings.json file:`n" e.Message "`n" e.What, 10
            ExitApp
        }

        this.settingsJsonObj := settingsJson.Object()
        this.settingsJsonObj.configFile := settingsFileName
        if (this.settingsJsonObj.HasKey("")) {
            this.settingsJsonObj.Delete("")
            settingsJson.Save(true)
        }

        if (extends := this.settingsJsonObj.__extends) {
            files := _Arr.wrap(extends)

            for _, file in files {
                data := _Json.load(this.jsonFolder "\" file)
                this.settingsJsonObj := _A.merge(data, this.settingsJsonObj)
                data := ""
            }


        }
        ; msgbox, % serialize(this.settingsJsonObj)

    }

    settingsFileJson() {
        settingsFile := this.JsonFolder "\settings.json"
        if (!FileExist(settingsFile)) {
            Msgbox, 16, % A_ThisFunc, % "Missing file: """ A_WorkingDir "\" settingsFile """."
            ExitApp
        }
        try {
            settingsJson := new JSONFile(settingsFile)
        } catch e {
            Msgbox, 16, % "Load JSON file: " settingsFile, % "Failed to load settings.json file:`n" e.Message "`n" e.What, 10
            ExitApp
        }
        return settingsJson
    }

    checkDefaultJsonCategories() {

        this.categories := {}
        this.categories.Push("clientFeatures")
        this.categories.Push("disconnectedCheck")
        this.categories.Push("files")
        this.categories.Push("input")
        this.categories.Push( {"images": ["convertGold", {"client": ["buttons", "chat", "menu"]} ] } )
        this.categories.Push("loadingOptions")
        this.categories.Push( {"map": ["folders", "minimap", "settings", "viewer"] } )
        this.categories.Push( {"settings": ["cavebot","looting","others"] } )
        this.categories.Push("tibiaClient")
        this.categories.Push("options")
        this.categories.Push("uncompatibleFunctions")
        this.categories.Push("uncompatibleModules")
        this.categories.Push("uncompatibleModuleFunctions")

        for key, category in this.categories
        {
            if (!IsObject(this.settingsJsonObj[category]))
                this.settingsJsonObj[category] := {}

            if (IsObject(category)) {
                for key2, subCategories1 in category
                {
                    if (!IsObject(this.settingsJsonObj[key2]))
                        this.settingsJsonObj[key2] := {}
                    for key3, subCategories2 in subCategories1
                    {
                        ; msgbox, % "(1) key2:" key2 "`n" "key3:" key3 "`na:" subCategories2 "`nobj:" serialize(subCategories2)
                        /**
                        to not create an object as key
                        */
                        if (!IsObject(subCategories2)) {
                            if (!IsObject(this.settingsJsonObj[key2][subCategories2]))
                                this.settingsJsonObj[key2][subCategories2] := {}
                        }
                        ; msgbox, %r"(2) key2:" key2 "`n" "key3:" key3 "`na:" subCategories2 "`nobj:" serialize(subCategories2) "`n`nnewObj:" serialize(this.settingsJsonObj[key2])

                        for key4, subCategories3 in subCategories2
                        {
                            ; m( "(3) key2: " key2 "`n" "key3: " key3 "`n" "key4: " key4 "`n" "`na: " subCategories3 "`nobj: " serialize(subCategories3) "`n`nnewObj:" serialize(this.settingsJsonObj[key2]) )
                            if (!IsObject(this.settingsJsonObj[key2][key4])) {
                                ; m(key2 "/"  key4 "/" subCategories3 "`n`n" serialize(this.settingsJsonObj[key2]))
                                this.settingsJsonObj[key2][key4] := {}
                            }
                            ; msgbox, % "(4) key2:" key2 "`n" "key3: " key3 "`n" "key4:" key4 "`na:" subCategories3 "`nobj:" serialize(subCategories3) "`n`nnewObj:" serialize(this.settingsJsonObj[key2])

                            for key5, subCategories4 in subCategories3
                            {
                                ; m( "(5) key2: " key2 "`n" "key3: " key3 "`n" "key4: " key4 "`n" "key5: " key5 "`n" "`na: " subCategories4 "`nobj: " serialize(subCategories4) "`n`nnewObj:" serialize(this.settingsJsonObj[key2]) )
                                if (!IsObject(this.settingsJsonObj[key2][key4][subCategories4])) {
                                    ; m(key2 "/"  key4 "/" subCategories4 "`n`n" serialize(this.settingsJsonObj[key2][key4]))
                                    this.settingsJsonObj[key2][key4][subCategories4] := {}
                                }
                                ; m( "(6) key2: " key2 "`n" "key3: " key3 "`n" "key4: " key4 "`n" "key5: " key5 "`n" "`na: " subCategories4 "`nobj: " serialize(subCategories4) "`n`nnewObj:" serialize(this.settingsJsonObj[key2]) )

                                ; for key6, subCategories5 in subCategories4
                                ; {
                                ;     ; m( "(7) key2: " key2 "`n" "key3: " key3 "`n" "key4: " key4 "`n" "key5: " key5  "`n" "key6: " key6 "`n" "`na: " subCategories5 "`nobj: " serialize(subCategories5) "`n`nnewObj:" serialize(this.settingsJsonObj[key2]) )
                                ;     if (!IsObject(this.settingsJsonObj[key2][key4][subCategories4])) {
                                ;         ; m(key2 "/"  key4 "/" subCategories4 "`n`n" serialize(this.settingsJsonObj[key2][key4]))
                                ;         this.settingsJsonObj[key2][key4][subCategories4] := {}
                                ;     }
                                ; }


                            }

                        }
                    }
                }
            }
        }
        ; msgbox, % serialize(this.settingsJsonObj["minimap"])
    }

    validateSettingsJsonSettings() {

        if (this.settingsJsonObj = "")
            throw Exception("Empty settings.json settings", A_ThisFunc)

        this.checkDefaultJsonCategories()
        ; m(serialize(this.settingsJsonObj.images))


        this.settingsJsonObj.disconnectedCheck.enabled := this.settingsJsonObj.disconnectedCheck.enabled = "" ? false : this.settingsJsonObj.disconnectedCheck.enabled


        /**
        clientFeatures
        */
        this.settingsJsonObj.clientFeatures.autoStack := (this.settingsJsonObj.clientFeatures.autoStack = "" && this.settingsJsonObj.clientFeatures.autoStack != false) ? true : this.settingsJsonObj.clientFeatures.autoStack
        this.settingsJsonObj.clientFeatures.chatOnOff := (this.settingsJsonObj.clientFeatures.chatOnOff = "" && this.settingsJsonObj.clientFeatures.chatOnOff != false) ? false : this.settingsJsonObj.clientFeatures.chatOnOff
        this.settingsJsonObj.clientFeatures.cooldownBar := (this.settingsJsonObj.clientFeatures.cooldownBar = "" && this.settingsJsonObj.clientFeatures.cooldownBar != false) ? true : this.settingsJsonObj.clientFeatures.cooldownBar
        this.settingsJsonObj.clientFeatures.fullLight := (this.settingsJsonObj.clientFeatures.fullLight = "" && this.settingsJsonObj.clientFeatures.fullLight != false) ? false : this.settingsJsonObj.clientFeatures.fullLight
        this.settingsJsonObj.clientFeatures.protectionZoneIndicator := (this.settingsJsonObj.clientFeatures.protectionZoneIndicator = "" && this.settingsJsonObj.clientFeatures.protectionZoneIndicator != false) ? false : this.settingsJsonObj.clientFeatures.protectionZoneIndicator
        this.settingsJsonObj.clientFeatures.walkThroughPlayers := (this.settingsJsonObj.clientFeatures.walkThroughPlayers = "" && this.settingsJsonObj.clientFeatures.cooldownBar != false) ? false : this.settingsJsonObj.clientFeatures.cooldownBar
        this.settingsJsonObj.clientFeatures.useItemWithHotkey := (this.settingsJsonObj.clientFeatures.useItemWithHotkey = "" && this.settingsJsonObj.clientFeatures.useItemWithHotkey != false) ? true : this.settingsJsonObj.clientFeatures.useItemWithHotkey

        /**
        files
        */
        this.settingsJsonObj.files.fishing := this.settingsJsonObj.files.fishing = "" ? "otclient.json" : this.settingsJsonObj.files.fishing
        this.settingsJsonObj.files.healing := this.settingsJsonObj.files.healing = "" ? "healing.json" : this.settingsJsonObj.files.healing
        this.settingsJsonObj.files.itemRefill := this.settingsJsonObj.files.itemRefill = "" ? "itemRefill.json" : this.settingsJsonObj.files.itemRefill
        this.settingsJsonObj.files.support := this.settingsJsonObj.files.support = "" ? "support.json" : this.settingsJsonObj.files.support
        this.settingsJsonObj.files.clientAreas := this.settingsJsonObj.files.clientAreas = "" ? "otclient.json" : this.settingsJsonObj.files.clientAreas


        /**
        input
        */
        this.settingsJsonObj.input.defaultImageSearch := this.settingsJsonObj.input.defaultImageSearch = "" ? false : this.settingsJsonObj.input.defaultImageSearch
        this.settingsJsonObj.input.useCSend := this.settingsJsonObj.input.useCSend = "" ? false : this.settingsJsonObj.input.useCSend
        this.settingsJsonObj.input.backgroundMouseInput := this.settingsJsonObj.input.backgroundMouseInput = "" ? true : this.settingsJsonObj.input.backgroundMouseInput
        this.settingsJsonObj.input.backgroundImageSearch := this.settingsJsonObj.input.backgroundImageSearch = "" ? true : this.settingsJsonObj.input.backgroundImageSearch
        this.settingsJsonObj.input.mouseClickDefaultMethod := this.settingsJsonObj.input.mouseClickDefaultMethod = "" ? true : this.settingsJsonObj.input.mouseClickDefaultMethod
        this.settingsJsonObj.input.mouseDragDefaultMethod := this.settingsJsonObj.input.mouseDragDefaultMethod = "" ? true : this.settingsJsonObj.input.mouseDragDefaultMethod
        this.settingsJsonObj.input.pressKeyDefaultMethod := this.settingsJsonObj.input.pressKeyDefaultMethod = "" ? true : this.settingsJsonObj.input.pressKeyDefaultMethod
        this.settingsJsonObj.input.pressLetterKeysDefaultMethod := this.settingsJsonObj.input.pressLetterKeysDefaultMethod = "" ? true : this.settingsJsonObj.input.pressLetterKeysDefaultMethod
        this.settingsJsonObj.input.pressF1toF12KeysDefaultMethod := this.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = "" ? true : this.settingsJsonObj.input.pressF1toF12KeysDefaultMethod
        this.settingsJsonObj.input.pressEscDefaultMethod := this.settingsJsonObj.input.pressEscDefaultMethod = "" ? true : this.settingsJsonObj.input.pressEscDefaultMethod

        this.settingsJsonObj.input.keyPressDelay := this.settingsJsonObj.input.keyPressDelay = "" ? 0 : this.settingsJsonObj.input.keyPressDelay
        this.settingsJsonObj.input.postMsgArrowKeys := this.settingsJsonObj.input.postMsgArrowKeys = "" ? true : this.settingsJsonObj.input.postMsgArrowKeys

        /**
        images
        */
        this.settingsJsonObj.images.convertGold.100goldCoin := this.settingsJsonObj.images.convertGold.100goldCoin = "" ? "100_gold_coin.png" : this.settingsJsonObj.images.convertGold.100goldCoin
        this.settingsJsonObj.images.convertGold.100platinumCoin := this.settingsJsonObj.images.convertGold.100platinumCoin = "" ? "100_platinum_coin.png" : this.settingsJsonObj.images.convertGold.100platinumCoin
        /**
        client
        */
        /**
        buttons
        */
        ; m(serialize(this.settingsJsonObj.images.client.buttons))
        this.settingsJsonObj.images.client.buttons.exit := this.settingsJsonObj.images.client.buttons.exit = "" ? "exit.png" : this.settingsJsonObj.images.client.buttons.exit
        this.settingsJsonObj.images.client.buttons.exitVariation := this.settingsJsonObj.images.client.buttons.exitVariation = "" ? 50 : this .settingsJsonObj.images.client.buttons.exitVariation
        /**
        chat
        */
        this.settingsJsonObj.images.client.chat.chatImagesVariation := this.settingsJsonObj.images.client.chat.chatImagesVariation = "" ? 50 : this.settingsJsonObj.images.client.chat.chatImagesVariation
        /**
        menu
        */
        this.settingsJsonObj.images.client.menu.follow := this.settingsJsonObj.images.client.menu.follow = "" ? "follow.png" : this.settingsJsonObj.images.client.menu.follow
        this.settingsJsonObj.images.client.menu.openBackpackNewWindow := this.settingsJsonObj.images.client.menu.openBackpackNewWindow = "" ? "open_backpack_new_window.png" : this.settingsJsonObj.images.client.menu.openBackpackNewWindow
        this.settingsJsonObj.images.client.menu.menuImagesVariation := this.settingsJsonObj.images.client.menu.menuImagesVariation = "" ? 50 : this.settingsJsonObj.images.client.menu.menuImagesVariation



        /**
        map
        */
        /**
        minimap
        */
        this.settingsJsonObj.map.minimap.crossSize := this.settingsJsonObj.map.minimap.crossSize = "" ? 6 : this.settingsJsonObj.map.minimap.crossSize
        this.settingsJsonObj.map.minimap.zoomButtonsOffset := this.settingsJsonObj.map.minimap.zoomButtonsOffset = "" ? 0 : this.settingsJsonObj.map.minimap.zoomButtonsOffset
        /**
        settings
        */
        this.settingsJsonObj.map.settings.mapWidth := this.settingsJsonObj.map.settings.mapWidth = "" ? 2560 : this.settingsJsonObj.map.settings.mapWidth
        this.settingsJsonObj.map.settings.mapHeight := this.settingsJsonObj.map.settings.mapHeight = "" ? 2048 : this.settingsJsonObj.map.settings.mapHeight
        this.settingsJsonObj.map.settings.pathFiles := this.settingsJsonObj.map.settings.pathFiles = "" ? true : this.settingsJsonObj.map.settings.pathFiles
        /**
        settings
        */
        this.settingsJsonObj.map.viewer.defaultCoordX := this.settingsJsonObj.map.viewer.defaultCoordX = "" ? 32346 : this.settingsJsonObj.map.viewer.defaultCoordX
        this.settingsJsonObj.map.viewer.defaultCoordY := this.settingsJsonObj.map.viewer.defaultCoordY = "" ? 32224 : this.settingsJsonObj.map.viewer.defaultCoordY



        /**
        settings
        */
        /**
        cavebot
        */
        this.settingsJsonObj.settings.cavebot.automaticFloorDetection := this.settingsJsonObj.settings.cavebot.automaticFloorDetection = "" ? true : this.settingsJsonObj.settings.cavebot.automaticFloorDetection

        this.settingsJsonObj.settings.cavebot.tradeWindowSummerUpdate1290 := this.settingsJsonObj.settings.cavebot.tradeWindowSummerUpdate1290 = "" ? false : this.settingsJsonObj.settings.cavebot.tradeWindowSummerUpdate1290

        /**
        looting
        */
        this.settingsJsonObj.settings.looting.fastManualLootingByDefault := this.settingsJsonObj.settings.looting.fastManualLootingByDefault = "" ? false : this.settingsJsonObj.settings.looting.fastManualLootingByDefault

        /**
        tibiaClient
        */
        this.settingsJsonObj.tibiaClient.isTibia12 := this.settingsJsonObj.tibiaClient.isTibia12 = "" ? true : this.settingsJsonObj.tibiaClient.isTibia12
        this.settingsJsonObj.tibiaClient.windowTitle := this.settingsJsonObj.tibiaClient.windowTitle = "" ? "" : this.settingsJsonObj.tibiaClient.windowTitle
        this.settingsJsonObj.tibiaClient.windowTitle := this.settingsJsonObj.tibiaClient.windowTitle = "" ? "" : this.settingsJsonObj.tibiaClient.windowTitle

        this.settingsJsonObj.tibiaClient.removeStringFromTitle := this.settingsJsonObj.tibiaClient.removeStringFromTitle

        this.settingsJsonObj.others.ignoreCheckClientSettings := this.settingsJsonObj.others.ignoreCheckClientSettings = "" ? false : this.settingsJsonObj.others.ignoreCheckClientSettings

        /**
        options
        */
        this.settingsJsonObj.options.itemSearchVariation := this.settingsJsonObj.options.itemSearchVariation > 1 ? this.settingsJsonObj.options.itemSearchVariation : 70

        this.settingsJsonObj.options.verticalSqms := this.settingsJsonObj.options.verticalSqms = "" ? 7 : this.settingsJsonObj.options.verticalSqms
        this.settingsJsonObj.options.horizontalSqms := this.settingsJsonObj.options.horizontalSqms = "" ? 5 : this.settingsJsonObj.options.horizontalSqms

        this.settingsJsonObj.loadingOptions.loadItems := this.settingsJsonObj.loadingOptions.loadItems = "" ? true : this.settingsJsonObj.loadingOptions.loadItems
        this.settingsJsonObj.loadingOptions.loadCreatures := this.settingsJsonObj.loadingOptions.loadCreatures = "" ? true : this.settingsJsonObj.loadingOptions.loadCreatures

        for key, value in this.settingsJsonObj.input
        {
            if (value = "")
                throw Exception("Empty JSON ""input"" setting: " key, A_ThisFunc)
        }


        ; msgbox, % serialize(this.settingsJsonObj)
    }

    applySettingsJsonSettings() {
        global

        backgroundMouseInput := this.settingsJsonObj.input.backgroundMouseInput
        backgroundKeyboardInput := this.settingsJsonObj.input.backgroundKeyboardInput
    }

    readExeNames() {
        global
        IniRead, alarmExeName, %DefaultProfile%, settings, alarmExeName, Alarm.exe
        IniRead, alertsExeName, %DefaultProfile%, settings, alertsExeName, Alerts.exe
        IniRead, cavebotExeName, %DefaultProfile%, settings, cavebotExeName, Cavebot.exe
        IniRead, fishingExeName, %DefaultProfile%, settings, fishingExeName, Fishing.exe
        IniRead, fullLightExeName, %DefaultProfile%, settings, fullLightExeName, FullLight.exe
        IniRead, healingExeName, %DefaultProfile%, settings, healingExeName, Healing.exe
        IniRead, hotkeysExeName, %DefaultProfile%, settings, hotkeysExeName, Hotkeys.exe
        IniRead, itemRefillExeName, %DefaultProfile%, settings, ItemRefillExeName, ItemRefill.exe
        IniRead, processMonitorExeName, %DefaultProfile%, settings, processMonitorExeName, ProcessMonitor.exe
        IniRead, reconnectExeName, %DefaultProfile%, settings, ReconnectExeName, Reconnect.exe
        IniRead, supportExeName, %DefaultProfile%, settings, SupportExeName, Support.exe
        IniRead, sioFriendExeName, %DefaultProfile%, settings, sioFriendExeName, SioFriend.exe
        IniRead, persistentExeName, %DefaultProfile%, settings, persistentExeName, Persistent.exe
    }

    resetIniExeNames() {
        IniDelete, %DefaultProfile%, settings, OldBotExeName
        IniDelete, %DefaultProfile%, settings, alertsExeName
        IniDelete, %DefaultProfile%, settings, alarmExeName
        IniDelete, %DefaultProfile%, settings, cavebotExeName
        IniDelete, %DefaultProfile%, settings, fishingExeName
        IniDelete, %DefaultProfile%, settings, healingExeName
        IniDelete, %DefaultProfile%, settings, hotkeysExeName
        IniDelete, %DefaultProfile%, settings, itemRefillExeName
        IniDelete, %DefaultProfile%, settings, processMonitorExeName
        IniDelete, %DefaultProfile%, settings, persistentExeName
        IniDelete, %DefaultProfile%, settings, reconnectExeName
        IniDelete, %DefaultProfile%, settings, supportExeName
        IniDelete, %DefaultProfile%, settings, sioFriendExeName
    }

    getSetting(category, key, value, defaultValue) {
        ; msgbox, % A_ThisFunc
        if (!scriptFileObj.HasKey(category)) {
            return defaultValue
            ; Throw, Exception("Category " category " doesn't exist on settings file.")
        }
        if (!scriptFileObj[category].HasKey([key])) {
            return defaultValue
            ; Throw, Exception("Key " category " > " key " doesn't exist on settings file.")
        }
        if (!scriptFileObj[category][key].HasKey([value])) {
            return defaultValue
        }

        return scriptFileObj[category][key][value]
    }

    setCurrentScript(scriptName) {
        global
        currentScript := scriptName
        IniWrite, %currentScript%, %DefaultProfile%, cavebot_settings, currentScript

        /**
        warning! cavebot and other modules uses this title to send messages
        */
        if (MAIN_OLDBOT_EXE) {
            ; if (isRubinot()){

            name := StrReplace( _AbstractExe.getRandomExeNameFromList(), ".exe", "")
            mainGuiPrefix := clientIdentifier() = "Drakmora" ? name " - " : "Chrome - "

            suffix := clientIdentifier() = "Drakmora" ? SubStr(A_TickCount, -4) : currentScript " #" SubStr(A_TickCount, -3)

            MAIN_GUI_TITLE := mainGuiPrefix " " suffix
            IniWrite, %MAIN_GUI_TITLE%, %DefaultProfile%, settings, MAIN_GUI_TITLE
        } else {
            IniRead, MAIN_GUI_TITLE, %DefaultProfile%, settings, MAIN_GUI_TITLE, A_Space
            _Validation.empty("MAIN_GUI_TITLE", MAIN_GUI_TITLE)
        }

        SendMessageTargetWindowTitle := MAIN_GUI_TITLE
    }

    autoStartFunctions()
    {
        global

        TibiaClient.autoSelectFirstClient(false)

        if (false) {
            return
        }

        clientOpened := TibiaClient.isClientOpened()
        for key, moduleName in this.modulesList
        {
            if (this.hasFunctionEnabled(moduleName)) {
                if (!clientOpened) {
                    TrayTip, % "Auto Start Functions - " txt("Cliente fechado", "Client closed"), % txt("Abra o jogo para iniciar as funções.", "Open the game to start the functions."), 4, 1
                    SetTimer, HideTrayTipFunctions, Delete
                    SetTimer, HideTrayTipFunctions, -4000

                    this.disableAllFunctions()

                    targetingEnabled := 0, targetingEnabled_2 := 0
                    cavebotEnabled := 0, cavebotEnabled_2 := 0

                    break
                }

                if (uncompatibleModule(moduleName)) {
                    continue
                }

                try {
                    startingModuleMessage(moduleName)
                    exe := new _ExeFactory(moduleName)
                    exe.stop()
                    exe.start()
                } catch e {
                    _Logger.msgboxException(48, e, "Auto Start Functions - " moduleName)
                }
            }
        }

        if (clientOpened) {
            IniRead, TargetingEnabled, %DefaultProfile%, cavebot_settings, TargetingEnabled, 0
            IniRead, CavebotEnabled, %DefaultProfile%, cavebot_settings, CavebotEnabled, 0
            this.startFunctions("CavebotGUI","targetingEnabled","TargetingEnabled_2", TargetingEnabled)
            this.startFunctions("CavebotGUI","cavebotEnabled","CavebotEnabled_2", CavebotEnabled)

            if (TargetingEnabled || CavebotEnabled) {
                if (A_IsCompiled) {
                    _CavebotExe.stop()
                    _CavebotExe.start()
                } else {
                    Run, Cavebot.ahk
                }
            }
        }

        for _, class in _Modules.getList()
        {
            for _, function in class.functions()
            {
                if (!function.isEnabled()) {
                    continue
                }

                if (!clientOpened) {
                    function.disable()
                    continue
                }

                shortcut := function.IDENTIFIER
                try {
                    function.enable()
                    value := 1
                } catch e {
                    function.disable()
                    value := 0
                    Msgbox, 48,, % e.Message
                    break
                }

                checkbox_setvalue(function.IDENTIFIER, value)
            }
        }
    }

    startFunctions(GUIName,CheckboxName, Checkbox2Name, functionEnabled, profile := "settings.ini")
    {

        if (functionEnabled = "")
            IniRead, functionEnabled, %profile%, settings, %CheckboxName%, 0

        ; msgbox, % CheckboxName " = " functionEnabled
        if (functionEnabled = 1) {
            try {
                GuiControl,%GUIName%:, %CheckboxName%, 1
            } catch e {
            }
            ; GuiControl,ShortcutScripts:, %Checkbox2Name%, 1
            ; Gosub, %CheckboxName%
        }else if (functionEnabled = 0) {
            /**
            if is running from oldbot start, doesn't go to the label, to open the bot faster
            */
            if (startingBot = true) && (!A_IsCompiled)
                return
            ; GuiControl,ShortcutScripts:, %Checkbox2Name%, 0
        }
        Gosub, %CheckboxName%

        return
    }

    hasFunctionEnabled(category) {
        if (WORKING_ON_GUI) {
            return
        }

        if (category = "alerts") {
            if (!IsObject(AlertsHandler))
                throw Exception("AlertsHandler not initialized.")
            return AlertsHandler.hasAlertEnabled()
        }
        if (category = "sioFriend") {
            classLoaded("_Sio", _Sio)
            return _Sio.hasFunctionEnabled()
        }
        if (category = "persistent") {
            if (!IsObject(PersistentHandler))
                throw Exception("PersistentHandler not initialized.")
            return PersistentHandler.hasPersistentEnabled()
        }
        if (category = "hotkeys") {
            if (!IsObject(HotkeysHandler))
                throw Exception("HotkeysHandler not initialized.")
            return HotkeysHandler.hasHotkeysEnabled()
        }

        ; if (!A_IsCompiled) && (category = "fishing")
        ; return true

        ; MsgBox, % serialize(%category%Functions)
        for key, value in %category%Functions
        {
            if (%category%Obj[value] = 1)
                return true
        }

        return false
    }

    warnBypassBotFolder()
    {
        ; Bypass functionality removed for open-source release
    }

    afterOpenedLastActions()
    {
        IniWrite, % AutoLogin := 1, %DefaultProfile%, accountsettings, AutoLogin

        this.warnBypassBotFolder()

        this.checkFontSmoothing()

        exist := false
        IfExist, %A_ProgramFiles%\Digital Communications\SAntivirus\SAntivirusIC.exe
            exist := true
        IfExist, %A_ProgramFiles% (x86)\Digital Communications\SAntivirus\SAntivirusIC.exe
            exist := true
        if (exist = true) {
            Run, https://www.youtube.com/watch?v=661V6M-0zcI
            Gui, Conectando:Destroy
            Msgbox, 48,, % "Detectado o antivirus 'Segurazo'(SAntivirusIC.exe) no seu PC - será necessário desinstalar esse antivirus para conseguir usar o bot.", 10
            ; AutoLogin = 0
            ; IniWrite, 0, %DefaultProfile%, accountsettings, AutoLogin
            ; Reload
        }

        exist := false
        IfExist, %A_ProgramFiles%\Diebold\Warsaw\core.exe
            exist := true
        IfExist, %A_ProgramFiles% (x86)\Diebold\Warsaw\core.exe
            exist := true
        if (exist = true) {
            Gui, Conectando:Destroy
            Msgbox, 48,, % "Detectado o programa 'Warsaw'(core.exe) aberto.`n`nVá no menu iniciar > Adicionar ou Remover Programas > veja se na lista de programas instalados no seu PC tem um programa com o nome **Warsaw**, desinstale e reinicie o PC", 10
            ; AutoLogin = 0
            ; IniWrite, 0, %DefaultProfile%, accountsettings, AutoLogin
            ; ExitApp
        }

        this.openProcessMonitor()

        if (!FileExist("Cavebot\Backups"))
            FileCreateDir, % "Cavebot\Backups"

        if (!FileExist("Cavebot\Logs"))
            FileCreateDir, % "Cavebot\Logs"

        this.checkScreenshotsToDelete()

        this.deleteTempScriptsJson()


        if (A_ScreenDPI > 96) {
            Gui,Carregando:Destroy
            msgbox_image(LANGUAGE = "PT-BR" ? "Sua escala de Zoom do Windows NÃO está em 100% (DPI: " DPI ").`nAltere para 100% e tente novamente." : "Your Windows Scale zoom is NOT in 100% (DPI: " DPI ").`nChange to 100% and try again.", "Data\Files\Images\GUI\Others\zoom_windows.png", 3)
            ExitApp
        }

        if (!WORKING_ON_GUI) {
            TibiaClient.autoSelectFirstClient()
        }

        this.checkTibiaClientWindowSize()

        this.checkIniSettingsByClient()

        try TibiaClient.checkIfIsOneDriveDirectory(A_ScriptDir)
        catch e {
            Msgbox, 48,, % (LANGUAGE = "PT-BR" ? "O diretório atual do OldBot está dentro da pasta do ""OneDrive"", isto irá problemas com o OneDrive restaurando arquivos antigos.`nÉ recomendado que você mova a pasta do OldBot para outro diretório fora do OneDrive.`n`nPor exemplo copie a pasta padrão que fica em ""Documentos\OldBot PRO"" e mova para ""C:\OldBot PRO""." : "The OldBot directory is inside the ""OneDrive"" folder, this will cause problems with OneDrive restoring old files.`nIt's recommended that you move OldBot's folder to another directory outside of OneDrive.`n`nFor example copy the default which is in ""Documents\OldBot PRO"" and move to ""C:\OldBot PRO"".") "`n`n" A_ScriptDir, 60
        }

        this.copyWindowsTheme()

        this.enableUnderlineAccessKeys()
    }

    enableUnderlineAccessKeys()
    {
        RegRead, AccessKeysValue, HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Preference, On
        if (AccessKeysValue = 0) {
            RegWrite, REG_SZ, HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Preference, On, 1
        }
    }

    copyWindowsTheme() {
        path := A_WinDir "\Resources\Themes"
        if (FileExist(path "\lovelace night.theme")) {
            return
        }

        src := A_WorkingDir "\Data\Files\Others\windows theme"
        try {
            FileCopyDir, % src, % path, 1
        } catch e {
            _Logger.exception(e, src, path)
        }
    }

    checkFontSmoothing() {
        RegRead, value, HKCU, Control Panel\Desktop, FontSmoothing
        if (value = 0) {
            RegWrite, REG_SZ, HKCU, Control Panel\Desktop, FontSmoothing, 2
            Msgbox, 48,, % LANGUAGE = "PT-BR" ? "A opção de ""Fontes com cantos arredondados"" do Windows estava desativada no seu PC e foi ativata automaticamente agora.`n`nÉ preciso reiniciar o seu PC para aplicar as alterações.`n`nPressione OK para REINICIAR o seu pc AGORA. Será reiniciando automaticamente após 60 segundos dessa mensagem, para cancelar, feche o bot agora." : "Windows ""Font smoothing"" option was disabled in your PC and has been enabled automatically now.`n`nIt's needed to reboot your PC to apply the changes.`n`nPress OK to REBOOT your computer NOW. It will be rebooted automatically after 60 seconds of this message, to cancel, close the bot now.", 60
            ; IfMsgBox, Yes
            ; {
            Run, Shutdown /r /t 0
            ; }
        }
    }

    openProcessMonitor() {
        ; if !A_IsCompiled
        return
        if (ProcessExistOpenOldBot(processMonitorExeName, "processMonitorExeName") = false) {
            return
            ; exitapp
        }

        fn := this.checkProcessMonitorOpened.bind(this)	; To delete the timer you need to save this reference.
        settimer % fn, Delete
        settimer % fn, -5000
    }

    checkProcessMonitorOpened() {
        Process,Exist,%processMonitorExeName%
        if (ErrorLevel = 0) {
            Msgbox, 48,, % "Failed to open Process Monitor(" processMonitorExeName "), please contact the support."
        }
    }

    /**
    check if there are more then 500 error screenshots and erase them
    */

    checkScreenshotsToDelete() {

        screenhotString := "_ERROR"
        screenshots := countScreenshots(screenhotString)
        screenshotsDeleteNumber := 200
        if (screenshots > screenshotsDeleteNumber) {
            Msgbox, 68,, % "More than " screenshotsDeleteNumber " screenshots of """ screenhotString """ in the Screenshots folder.`n`nDo you want to DELETE all?"
            IfMsgBox, Yes
            {
                CarregandoGUI("Deleting ""error"" screenhots(more than " screenshotsDeleteNumber ")...")
                Path := "Data\Screenshots\" screenhotString "*.png", Number := 1
                Loop, %Path%
                    FileDelete, % A_LoopFileFullPath
                Gui, Carregando:Destroy
            }
        }

        screenhotString := "Screenshot_ExitGame"
        screenshots := countScreenshots(screenhotString)
        if (screenshots > screenshotsDeleteNumber) {
            Msgbox, 68,, % "More than " screenshotsDeleteNumber " screenshots of """ screenhotString """ in the Screenshots folder.`n`nDo you want to DELETE all?"
            IfMsgBox, Yes
            {
                CarregandoGUI("Deleting ""ExitGame"" screenhots(more than " screenshotsDeleteNumber ")...")
                Path := "Data\Screenshots\" screenhotString "*.png", Number := 1
                Loop, %Path%
                    FileDelete, % A_LoopFileFullPath
                Gui, Carregando:Destroy
            }
        }

        screenhotString := "Screenshot_Action"
        screenshots := countScreenshots(screenhotString)
        if (screenshots > screenshotsDeleteNumber) {
            Msgbox, 68,, % "More than " screenshotsDeleteNumber " screenshots of """ screenhotString """ in the Screenshots folder.`n`nDo you want to DELETE all?"
            IfMsgBox, Yes
            {
                CarregandoGUI("Deleting ""Action"" screenhots(more than " screenshotsDeleteNumber ")...")
                Path := "Data\Screenshots\" screenhotString "*.png", Number := 1
                Loop, %Path%
                    FileDelete, % A_LoopFileFullPath
                Gui, Carregando:Destroy
            }
        }

        screenhotString := ""
        screenshots := countScreenshots(screenhotString, "Alerts")
        if (screenshots > screenshotsDeleteNumber) {
            Msgbox, 68,, % "More than " screenshotsDeleteNumber " screenshots of ""Alerts"" in the Screenshots folder.`n`nDo you want to DELETE all?"
            IfMsgBox, Yes
            {
                CarregandoGUI("Deleting ""Action"" screenhots(more than " screenshotsDeleteNumber ")...")
                Path := "Data\Screenshots\Alerts\*.png", Number := 1
                Loop, %Path%
                    FileDelete, % A_LoopFileFullPath
                Gui, Carregando:Destroy
            }
        }


    }

    /**
    delete any json file in the OldBot Temp folder
    those files are uncrypted scripts
    */
    deleteTempScriptsJson() {
        Loop, % A_Temp "\OldBot\*.json"
            FileDelete, % A_LoopFileFullPath
    }



    disableAllFunctions() {
        global
        CloseAllProcesses(false)

        for key, value in cavebotFunctions
        {
            if (value = 0)
                continue
            %value% := 0
            try GuiControl, CavebotGUI:, % value, 0
            catch {
            }
            checkbox_setvalue(value "_2", 0)
        }

        for _, moduleName in this.modulesList
        {
            for _, functionName in %moduleName%Functions
            {
                %moduleName%Obj[functionName] := 0, %functionName% := 0
                checkbox_setvalue(functionName "_2", 0)
                try GuiControl, CavebotGUI:, % functionName, 0
                catch {
                }
            }
        }


        for key, alert in alertsObj
            alertsObj[key].enabled := 0

        for key, persistent in persistentObj
            persistentObj[key].enabled := 0

        for key, hotkey in hotkeysObj
            hotkeysObj[key].enabled := 0

        checkbox_setvalue("CavebotTargeting", 0)
        checkbox_setvalue("LifeManaTrain", 0)
        checkbox_setvalue("SelectedFunctions", 0)

        CavebotScript.saveSettings(A_ThisFunc)
    }

    checkTibiaClientWindowSize() {
        if (TibiaClientID = "")
            return
        IniRead, TibiaWindowSizeHigherThan1080p, %DefaultProfile%, warnings, TibiaWindowSizeHigherThan1080p, 0
        if (TibiaWindowSizeHigherThan1080p = 1)
            return

        WinGetPos, WindowX, WindowY, WindowWidth, WindowHeight, ahk_id %TibiaClientID%

        msg := LANGUAGE = "PT-BR" ? "`n`nNão é recomendado usar com o tamanho maior do que esse, isto irá causar maior uso de CPU e diminuir a performance geral do bot.`nQuanto menor foi o tamanho da janela do Tibia, mais rápido o bot irá funcionar e menos CPU irá consumir.`n`nIsto é apenas uma dica, você pode usar o bot normalmente do jeito que está." : "`n`nIt's not recommended to use with size higher than that, it will cause more CPU usage and reduce the overall perfomance of OldBot.`nThe smaller the size of Tibia's window, faster the bot will run and also use less CPU.`n`nThis is only a tip, you can use the bot normally the way it is."

        ; if (!A_IsCompiled)
        ; return

        ; if (WindowWidth > 1940) {
        ;     IniWrite, 1, %DefaultProfile%, warnings, TibiaWindowSizeHigherThan1080p
        ;     msgbox, 64,, % LANGUAGE = "PT-BR" ? "Detectado a largura da janela do Tibia maior do que 1920 pixels(" WindowWidth "). " msg : "Detected Tibia window with Width higher than 1920 pixels(" WindowWidth "). " msg, 30
        ;     return
        ; }
        ; if (WindowHeight > 1090) {
        ;     IniWrite, 1, %DefaultProfile%, warnings, TibiaWindowSizeHigherThan1080p
        ;     msgbox, 64,, % LANGUAGE = "PT-BR" ? "Detectado a altura da janela do Tibia maior do que 1080 pixels(" WindowHeight "). " msg : "Detected Tibia window with Height higher than 1080 pixels(" WindowHeight "). " msg, 30
        ;     return
        ; }
    }

    startFunction(moduleName, functionName, startProcess := true, throwE := false, saveJson := true, loadingGui := true) {
        global
        if (loadingGui)
            this.disableGuisLoading()
        value := 1
        try {
            TibiaClient.checkClientSelected()
        } catch e {
            value := 0
            this.stopFunction(moduleName, functionName, closeProcess := false, saveJson := false)
            if (loadingGui)
                this.enableGuisLoading()

            if (throwE)
                throw e
            MsgBox, 64, % A_ThisFunc, % e.Message, 2
            return
        }

        _GuiHandler.toggleFunctionEnabledCheckbox(moduleName, functionName, value)

        if (startProcess)
            ProcessExistOpenOldBot(%moduleName%ExeName, moduleName "ExeName", closeProcess := true)
        /**
        save module obj
        */
        if (saveJson) {
            scriptFile[moduleName] := %moduleName%Obj
            CavebotScript.saveSettings(A_ThisFunc)
        }

        if (loadingGui)
            this.enableGuisLoading()
    }

    stopFunction(moduleName, functionName, closeProcess := true, saveJson := true, loadingGui := true) {
        global
        if (!IsObject(GuiHandler))
            throw Exception("GuiHandler not initialized")

        if (loadingGui)
            this.disableGuisLoading()
        _GuiHandler.toggleFunctionEnabledCheckbox(moduleName, functionName, 0)
        if (closeProcess)
            ProcessExistClose(%moduleName%ExeName, moduleName "ExeName")
        /**
        save module obj
        */
        if (saveJson) {
            scriptFile[moduleName] := %moduleName%Obj
            CavebotScript.saveSettings(A_ThisFunc)
        }
        if (loadingGui)
            this.enableGuisLoading()
    }

    downloadTutorialsMenuJSON() {

        ; if (nnnnnn = 1)
        ; return

        StringTrimRight, Now, A_Now, 6

        IniRead, LastJsonMenuDownload, %A_Temp%\OldBot\oldbot.ini, settings, LastJsonMenuDownload, %A_Space%
        DaysSinceLastJsonMenuDownload := abs(LastJsonMenuDownload - Now)
        if (DaysSinceLastJsonMenuDownload = 0) && (DaysSinceLastJsonMenuDownload != "")
            return
        IniWrite, %Now%, %A_Temp%\OldBot\oldbot.ini, settings, LastJsonMenuDownload

        downloadedJson := this.JsonFolder "\Menu\tutorials_downloaded.json"

        try UrlDownloadToFile, % API.APIUrl "\tutorials.json", % downloadedJson
        catch e {
            error := e.Message "`n" e.What
            OutputDebug(A_ThisFunc, error)
            if (!A_IsCompiled)
                Msgbox, 16, % "Failed to download tutorials.json", % error
            return
        }
        Sleep, 500

        tutorialsMenuJsonMFile := downloadedJson
        if (!FileExist(tutorialsMenuJsonMFile)) {
            Msgbox, 16, % A_ThisFunc, % "Missing file: """ A_WorkingDir "\" tutorialsMenuJsonMFile """."
            ExitApp
        }
        try {
            tutorialsMenuJsonMSettings := new JSONFile(tutorialsMenuJsonMFile)
        } catch e {
            Msgbox, 16, % A_ThisFunc, % "Failed to load tutorials.json file:`n" e.Message "`n" e.What, 10
            return
        }
        ; this.tutorialsMenuJsonMSettingsObj := tutorialsMenuJsonMSettings.Object()

        FileMove, % downloadedJson, % this.JsonFolder "\Menu\tutorials.json", 1
        Sleep, 500
    }

    loadModuleJsonSettingsFile(moduleName) {
        fileName := this.settingsJsonObj.files[moduleName]
        if (fileName = "") {
            Gui, Carregando:Destroy
            throw Exception("No setting file specified for module """ moduleName """ in settings.json.`n`nSetting file: " this.settingsJsonObj.configFile)
        }


        %moduleName%File := this.JsonFolder "\" moduleName "\" fileName
        if (!FileExist(%moduleName%File)) {
            Gui, Carregando:Destroy
            throw Exception("Missing file: """ A_WorkingDir "\" %moduleName%File """.")
        }

        try {
            %moduleName%Json := new JSONFile(%moduleName%File)
        } catch e {
            Gui, Carregando:Destroy
            throw Exception("Failed to load """ A_WorkingDir "\" fileName """ file:`n" e.Message "`n" e.What)
        }

        obj := %moduleName%Json.Object()

        if (obj = "") {
            Gui, Carregando:Destroy
            throw Exception("Empty " fileName " settings.", A_ThisFunc)
        }


        if (extends := obj.__extends) {
            files := _Arr.wrap(extends)

            for _, file in files {
                data := _Json.load(this.JsonFolder "\" moduleName "\" file)
                obj := _A.merge(data, obj)
                data := ""
            }
        }

        return obj
    }

    uncompatibleModule(moduleName) {
        for key, module in OldbotSettings.settingsJsonObj.uncompatibleModules
        {
            if (moduleName = module) {
                ; msgbox, % moduleName " = " module
                return true
            }
        }
        return false
    }

    isModuleUncompatible() {

        for key, module in OldbotSettings.settingsJsonObj.uncompatibleModules
        {
            if (MainTab = module) {
                throw Exception("The selected client """ TibiaClient.settingsFileText """ is uncompatible with the module """ module """.")
            }
        }
        return
    }

    uncompatibleModuleFunction(moduleName, functionName) {
        if (this.uncompatibleModule(moduleName) = true)
            return true
        for module, functions in OldbotSettings.settingsJsonObj.uncompatibleModuleFunctions
        {
            ; msgbox, % moduleName " != " module
            if (moduleName != module)
                continue

            for key, function in functions
            {
                ; msgbox, % functionName " != " function
                if (functionName = function)
                    return true
            }
            ; msgbox, % moduleName " = " module
        }
        return false
    }

    saveClientConfigurationJsonFile() {
        OldbotSettings.settingsJsonObj.delete("")
        OldbotSettings.settingsJsonObj.delete(" ")
        OldbotSettings.settingsJsonObj.delete(A_Space)
        settingsJson.Fill(OldbotSettings.settingsJsonObj)
        settingsJson.save(true)
    }

    readIniOldBotGlobalSettings() {
        global

        IniRead, disableHealingMemory, %DefaultProfile%, other_settings, disableHealingMemory, 0
        switch A_OSVersion {
            case "Win_7": WINDOWS_VERSION := 7
            case "Win_8": WINDOWS_VERSION := 8
            default: WINDOWS_VERSION := 10
        }

    }

    checkIniSettingsByClient() {
        this.readIniOldBotGlobalSettings()
    }

    disableGuisLoading(shortcutGui := false) {
        return
        if (shortcutGui = true) {
            try Gui, ShortcutScripts:+Disabled
            catch {
            }
        }
        if (loadingGuisDisabled = true)
            return
        if (loadingGuisSelectedFunctions = true) OR (loadingGuisDisabledScriptLoad = true)
            return
        try Gui, CavebotGUI:+Disabled
        catch {
        }
        ; setSystemCursor("IDC_APPSTARTING")
        ; m(A_ThisFunc)
        loadingGuisDisabled := true
        SetTimer, EnableGavebotGUI, Delete
        SetTimer, EnableGavebotGUI, -2000
    }

    enableGuisLoading(shortcutGui := false) {
        return
        if (shortcutGui = true) {
            try Gui, ShortcutScripts:-Disabled
            catch {
            }
        }
        if (loadingGuisDisabled = false)
            return
        if (loadingGuisSelectedFunctions = true) OR (loadingGuisDisabledScriptLoad = true)
            return
        ; m(A_ThisFunc)
        Sleep, 50
        EnableGavebotGUI()
        ; restoreCursor()
        loadingGuisDisabled := false
    }
} ; class
