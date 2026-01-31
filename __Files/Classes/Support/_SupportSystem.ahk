global supportSystemObj

Class _SupportSystem
{
    __New()
    {
        global

        classLoaded("MemoryManager", MemoryManager)

        supportSystemObj := {}

        this.startSupportSetup()
    }

    startSupportSetup() {
        try this.supportJsonObj := OldBotSettings.loadModuleJsonSettingsFile("support")
        catch e {
            Msgbox, 16, % e.What, % e.Message, 30
            ExitApp
        }

        try this.validateSupportJsonSettings()
        catch e {
            Msgbox, 16, % e.What, % e.Message, 30
            ExitApp
        }


        this.areas := {}
        this.areas.ring := {}
        this.areas.amulet := {}
        this.areas.boots := {}
    }

    checkDefaultJsonCategories() {
        this.categories := {}
        this.categories.Push("autoEatFood")
        this.categories.Push("autoBuffSpell")
        this.categories.Push("autoHaste")
        this.categories.Push("autoUtamoVita")
        this.categories.Push("cureParalyze")
        this.categories.Push("cureCurse")
        this.categories.Push("cureFire")
        this.categories.Push("statusBarAreaSetup")
        this.categories.Push("options")

        for key, category in this.categories
        {
            if (!IsObject(this.supportJsonObj[category]))
                this.supportJsonObj[category] := {}

            if (IsObject(category)) {
                for subcategory, subcategories in category
                {
                    if (!IsObject(this.supportJsonObj[subcategory]))
                        this.supportJsonObj[subcategory] := {}
                    for key3, subcategoryName in subcategories
                    {
                        if (!IsObject(this.supportJsonObj[subcategory][subcategoryName]))
                            this.supportJsonObj[subcategory][subcategoryName] := {}
                    }
                }
            }
        }
        ; msgbox, % serialize(this.supportJsonObj["minimap"])
    }

    validateSupportJsonSettings() {
        if (this.supportJsonObj = "")
            throw Exception("Empty support.json settings", A_ThisFunc)

        this.checkDefaultJsonCategories()

        this.defaultSpellSettings("autoEatFood", 2000, "hungry.png")
        this.defaultSpellSettings("autoBuffSpell", 1200, "hungry.png")
        this.defaultSpellSettings("autoHaste", 500, "hungry.png")
        this.defaultSpellSettings("autoUtamoVita", 500, "")
        this.defaultSpellSettings("cureParalyze", 500, "paralyze.png")
        this.defaultSpellSettings("curePoison", 2000, "poison.png")
        this.defaultSpellSettings("cureFire", 2000, "fire.png")
        this.defaultSpellSettings("cureCurse", 2000, "curse.png")

        this.supportJsonObj.options.pzZoneStatusBarImage := this.supportJsonObj.options.pzZoneStatusBarImage = "" ? "pz_zone.png" : this.supportJsonObj.options.pzZoneStatusBarImage

        this.supportJsonObj.statusBarAreaSetup.baseImage := this.supportJsonObj.statusBarAreaSetup.baseImage = "" ? "base_image.png" : this.supportJsonObj.statusBarAreaSetup.baseImage
        this.supportJsonObj.statusBarAreaSetup.baseImageVariation := this.supportJsonObj.statusBarAreaSetup.baseImageVariation = "" ? 50 : this.supportJsonObj.statusBarAreaSetup.baseImageVariation

        if (!FileExist(ImagesConfig.supportFolder "\" this.supportJsonObj.statusBarAreaSetup.baseImage))
            throw Exception("""" ImagesConfig.supportFolder "\" this.supportJsonObj.statusBarAreaSetup.baseImage """ doesn't exist.")

        this.supportJsonObj.statusBarAreaSetup.offsetFromBaseImagePositionX := this.supportJsonObj.statusBarAreaSetup.offsetFromBaseImagePositionX = "" ? -125 : this.supportJsonObj.statusBarAreaSetup.offsetFromBaseImagePositionX
        this.supportJsonObj.statusBarAreaSetup.offsetFromBaseImagePositionY := this.supportJsonObj.statusBarAreaSetup.offsetFromBaseImagePositionY = "" ? -5 : this.supportJsonObj.statusBarAreaSetup.offsetFromBaseImagePositionY
        this.supportJsonObj.statusBarAreaSetup.width := this.supportJsonObj.statusBarAreaSetup.width = "" ? 93 : this.supportJsonObj.statusBarAreaSetup.width
        this.supportJsonObj.statusBarAreaSetup.height := this.supportJsonObj.statusBarAreaSetup.height = "" ? 20 : this.supportJsonObj.statusBarAreaSetup.height
    }

    defaultSpellSettings(spell, defaultInterval, imageName := "") {
        this.supportJsonObj[spell].statusBarImage := this.supportJsonObj[spell].statusBarImage = "" ? imageName : this.supportJsonObj[spell].statusBarImage
        this.supportJsonObj[spell].statusBarImage := this.supportJsonObj[spell].statusBarImage
        this.supportJsonObj[spell].variation := this.supportJsonObj[spell].variation = "" ? 30 : this.supportJsonObj[spell].variation
        this.supportJsonObj[spell].timerIntervalMs := this.supportJsonObj[spell].timerIntervalMs = "" ? defaultInterval : this.supportJsonObj[spell].timerIntervalMs
        this.supportJsonObj[spell].timerIntervalMs := this.supportJsonObj[spell].timerIntervalMs < 400 ? 400 : this.supportJsonObj[spell].timerIntervalMs
    }

    checkTargetingRunningCondition(spell) {
        if (supportObj[spell "TargetingRunning"] != true)
            return true

        IniRead, TargetingRunning, %DefaultProfile%, targeting_system, TargetingRunning, 0
        if (TargetingRunning = 1)
            return false
        return true
    }

    checkOnlyWithTargetingRunningCondition(spell) {
        if (!supportObj[spell "OnlyWithTargetingRunning"]) {
            return true
        }

        IniRead, TargetingRunning, %DefaultProfile%, targeting_system, TargetingRunning, 0
        if (TargetingRunning = 0)
            return false
        return true
    }

    autoSpell(spell, hotkey := "", pz := false, chatOn := false, hotkeyIfFound := false, hotkeyTwice := true) {
        if (supportObj[spell] = 0)
            return
        if (empty(hotkey))
            return
        if (this.checkTargetingRunningCondition(spell) = false)
            return
        if (this.checkOnlyWithTargetingRunningCondition(spell) = false)
            return

        if (pz = true) {
            Sleep, 50
            if (isInProtectionZone()) {
                return
            }
        }

        if (chatOn = true) && (this.supportJsonObj.options.disableChatCondition != true) {
            Sleep, 50
            if (new _SearchChatOnButton().found()) {
                return
            }
        }

        ; msgbox, % spell " / " hotkey
        switch spell {
            case "autoHaste":
                image := this.supportJsonObj[spell].statusBarImage
                if (this.checkManaSpell("haste") = false)
                    return
            case "autoUtamoVita":
                image := this.supportJsonObj[spell].statusBarImage
                if (this.checkManaSpell("utamoVita") = false)
                    return
                if (this.checkExanaVitaCondition() = true) {
                    ; msgbox, % "this.checkExanaVitaCondition() = true"
                    /**
                    if utamo vita icon is found, cast exana vita spell
                    */
                    if (this.imageSearchStatusBar(image, this.supportJsonObj[spell].variation) = true) {
                        ; msgbox, use exana vita
                        Send(supportObj.exanaVitaHotkey)
                        return
                    }
                    /**
                    otherwise continue?...
                    */
                }
                if (this.checkUtamoVitaCondition() = false) {
                    ; msgbox, % "this.checkUtamoVitaCondition() = false"
                    return
                }

                /**
                if exana vita is enabled and the "life above" is lower than the "life below" of utamo vita
                need to ignore and not cast utamo vita
                */
                if (supportObj.exanaVitaEnabled = true)
                        && (supportObj.exanaVitaLife < supportObj.utamoVitaLife)
                    return
                ; msgbox, % "this.checkUtamoVitaCondition() = true"

            case "autoBuffSpell":
                image := this.supportJsonObj[spell].statusBarImage
                if (this.checkManaSpell(spell) = false)
                    return
            case "cureParalyze": image := this.supportJsonObj[spell].statusBarImage
            case "curePoison": image := this.supportJsonObj[spell].statusBarImage
            case "cureFire": image := this.supportJsonObj[spell].statusBarImage
            case "cureCurse": image := this.supportJsonObj[spell].statusBarImage
            default: return
        }
        ; msgbox, % image
        if (hotkeyIfFound = false) {
            if (this.imageSearchStatusBar(image, this.supportJsonObj[spell].variation) = false) {
                Loop, % hotkeyTwice = true ? 2 : 1
                    Send(hotkey)
            }
            return
        }

        if (this.imageSearchStatusBar(image, this.supportJsonObj[spell].variation) = true) {
            Loop, % hotkeyTwice = true ? 2 : 1
                Send(hotkey)
        }
    }

    /**
    * @param string image
    * @param int variation
    * @return bool
    */
    imageSearchStatusBar(image, variation := 30) {
        static searchCache
        try {
            if (!searchCache) {
                searchCache := new _UniqueImageSearch()
                    .setFolder(ImagesConfig.statusBarFolder)
                    .setVariation(variation)
                    .setArea(new _StatusBarArea())
                    .setDebug(this.supportJsonObj.options.debug)
            }

            _search := searchCache
                .setFile(image)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, image)
            return false
        }

        return _search.found()
    }

    checkUtamoVitaCondition() {
        if (supportObj.utamoVitaLife < 1 OR supportObj.utamoVitaLife >= 99)
            return true

        if (HealingSystem.hasLifePercent(supportObj.utamoVitaLife) = false)
            return true

        return false
    }

    checkExanaVitaCondition() {
        if (supportObj.exanaVitaEnabled = false)
            return false
        if (supportObj.exanaVitaHotkey = "" OR supportObj.exanaVitaHotkey = A_Space)
            return false
        if (supportObj.exanaVitaLife < 1 OR supportObj.exanaVitaLife > 99)
            return false


        if (HealingSystem.hasLifePercent(supportObj.exanaVitaLife) = true)
            return true

        return false
    }

    checkManaSpell(spell) {
        if (supportObj[spell "MinMana"] < 1 OR supportObj[spell "MinMana"] > 99) {
            ; msgbox, a
            return true
        }

        try {
            hasMana := HealingSystem.hasManaPercent(supportObj[spell "MinMana"])
        } catch e {
            _Logger.exception(e)
        }
        return hasMana
    }

    throwSupportError(func, error) {
        FileAppend, % "`n" A_Hour ":" A_Min ":" A_Sec " " A_MDay "/" A_Mon " | " error, Data\Files\logs_errors_support.txt
        OutputDebug(func, error)
    }
}