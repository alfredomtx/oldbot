global healingSystemObj

Class _HealingSystem
{
    __New(startSetup := true) {
        global

        this.iniSettings := new _HealingIniSettings()
        this.settings := new _HealingSettings()

        classLoaded("MemoryManager", MemoryManager)

        healingSystemObj := {}

        healingSystemObj["positions"] := {}
        healingSystemObj["positions"]["life"] := {}
        healingSystemObj["positions"]["mana"] := {}
        healingSystemObj["status"] := {}

        this.outPutDebugLife := true
        this.outPutDebugLife2 := true
        this.outPutDebugMana := true
        this.outPutDebugMana2 := true
        this.outPutDebugCompare := true

        this.lastDisconnectedCheck := new _Timer()

        this.manaHealingDisabled := false
        if (uncompatibleFunction("healing", "manaHealing") = true)
            this.manaHealingDisabled := true
        if (this.healingJsonObj.options.disableMana = true)
            this.manaHealingDisabled := true

        this.loadHealingJsonSettings()

        try this.validateHealingJsonSettings()
        catch e {
            Msgbox, 16, % e.What, % e.Message, 10
            return false
        }

        if (startSetup) {
            this.startHealingSetup()
        }
    }

    /**
    * @param string key
    * @param ?bool ini
    * @return string
    */
    get(key, ini := false)
    {
        if (ini) {
            return this.iniSettings.get(key)
        }

        return this.settings.get(key)
    }

    startHealingSetup()
    {
        if (OldBotSettings.uncompatibleModule("healing") = true) {
            return
        }

        if (MemoryManager.healingMemory() = true) {
            try {
                this.startMemoryHealingSetup()
                return
            } catch e {
                if (this.healingJsonObj.options.debug = true) {
                    throw e
                }

                ; if failed reading from memory, work with normal healer by image
                IniWrite, % disableHealingMemory := 1, %DefaultProfile%, other_settings, disableHealingMemory
                this.loadHealingJsonSettings()
            }
        }

        if (this.checkBarsVisible() = false)
            throw Exception("")

        try this.findBars(timerCheck := false, A_ThisFunc)
        catch e
            throw e


        this.lifePixelSearch := new _UniqueImageSearch()
            .setFile(this.healingJsonObj.life.pixelImageName)
            .setFolder(ImagesConfig.healingLifePixelFolder)
            .setVariation(new _HealingJson().get("life.pixelVariation", 60))

        this.manaPixelSearch := new _UniqueImageSearch()
            .setFile(this.healingJsonObj.mana.pixelImageName)
            .setFolder(ImagesConfig.healingManaPixelFolder)
            .setVariation(new _HealingJson().get("mana.pixelVariation", 60))
    }

    startMemoryHealingSetup()
    {
        current := MemoryManager.readHealth("life", true, this.healingJsonObj.options.debug)
        ; msgbox, % "life " current
        if (current < 1)
            throw Exception(txt("Falha ao ler a vida atual da memória: ", "Failed to read current life from memory: ") current "`n`nName: " TibiaClient.getClientIdentifier(memoryIdentifier := true) "`nExe name: " TibiaClientExeName "`nWindow: " TibiaClientTitle)

        total := MemoryManager.readHealth("life", false, this.healingJsonObj.options.debug)
        ; msgbox, % "life " total
        if (total < 1)
            throw Exception(txt("Falha ao ler a vida total da memória: ", "Failed to read total life from memory: ") total "`n`nName: " TibiaClient.getClientIdentifier(memoryIdentifier := true) "`nExe name: " TibiaClientExeName "`nWindow: " TibiaClientTitle)

        if (this.manaHealingDisabled = true)
            return

        current := MemoryManager.readHealth("mana", true, this.healingJsonObj.options.debug)
        ; msgbox, % "mana " current
        if (current < 1)
            throw Exception(txt("Falha ao ler a mana atual da memória: ", "Failed to read current mana from memory: ") current "`n`nName: " TibiaClient.getClientIdentifier(memoryIdentifier := true) "`nExe name: " TibiaClientExeName "`nWindow: " TibiaClientTitle)

        total := MemoryManager.readHealth("mana", false, this.healingJsonObj.options.debug)
        ; msgbox, % "mana " total
        if (total < 1)
            throw Exception(txt("Falha ao ler a mana total da memória: ", "Failed to read total mana from memory: ") total "`n`nName: " TibiaClient.getClientIdentifier(memoryIdentifier := true) "`nExe name: " TibiaClientExeName "`nWindow: " TibiaClientTitle)

    }

    loadHealingJsonSettings() {

        healingFile := OldBotSettings.JsonFolder "\healing\" OldBotSettings.settingsJsonObj.files.healing
        switch MemoryManager.healingMemory() {
            case true:
                if (isTibia13())
                    healingFile := OldBotSettings.JsonFolder "\" "healing_memory.json"
        }

        if (!FileExist(healingFile)) {
            Msgbox, 16, % A_ThisFunc, % "Missing file: """ A_WorkingDir "\" healingFile """.", 10
            ExitApp
        }

        try {
            healingJson := new JSONFile(healingFile)
        } catch e {
            Msgbox, 16, % A_ThisFunc, % "Failed to load life.json file:`n" e.Message "`n" e.What, 10
            ExitApp
        }
        this.healingJsonObj := healingJson.Object()
    }


    checkDefaultJsonCategories() {

        this.categories := {}
        this.categories.Push("life")
        this.categories.Push("mana")
        this.categories.Push("options")

        for key, category in this.categories
        {
            if (!IsObject(this.healingJsonObj[category]))
                this.healingJsonObj[category] := {}

            if (IsObject(category)) {
                for subcategory, subcategories in category
                {
                    if (!IsObject(this.healingJsonObj[subcategory]))
                        this.healingJsonObj[subcategory] := {}
                    for key3, subcategoryName in subcategories
                    {
                        if (!IsObject(this.healingJsonObj[subcategory][subcategoryName]))
                            this.healingJsonObj[subcategory][subcategoryName] := {}
                    }
                }
            }
        }
        ; msgbox, % serialize(this.supportJsonObj["minimap"])
    }

    validateHealingJsonSettings() {

        if (this.healingJsonObj = "")
            throw Exception("Empty healing.json settings", A_ThisFunc)

        this.checkDefaultJsonCategories()

        /**
        images to set position as x1 and y1 for lifebar
        Data\Files\Images\Healing
        */
        this.healingJsonObj.options.baseImageVariation := this.healingJsonObj.options.baseImageVariation = "" ? 60 : this.healingJsonObj.options.baseImageVariation

        /**
        life/mana pixel colors
        */
        this.healingJsonObj.life.pixelImageName := this.healingJsonObj.life.pixelImageName = "" ? "life_pixel" : this.healingJsonObj.life.pixelImageName
        this.healingJsonObj.mana.pixelImageName := this.healingJsonObj.mana.pixelImageName = "" ? "mana_pixel" : this.healingJsonObj.mana.pixelImageName
        this.healingJsonObj.life.pixelColor := this.healingJsonObj.life.pixelColor = "" ? "0xF16161" : this.healingJsonObj.life.pixelColor
        this.healingJsonObj.mana.pixelColor := this.healingJsonObj.mana.pixelColor = "" ? "0x7471FF" : this.healingJsonObj.mana.pixelColor


        /**
        options
        */

        this.healingJsonObj.options.checkHealingIntervalDelay := this.healingJsonObj.options.checkHealingIntervalDelay = "" ? 150 : this.healingJsonObj.options.checkHealingIntervalDelay
        this.healingJsonObj.options.checkHealingIntervalDelay := this.healingJsonObj.options.checkHealingIntervalDelay < 75 ? 75 : this.healingJsonObj.options.checkHealingIntervalDelay

        this.healingJsonObj.options.baseImage := this.healingJsonObj.options.baseImage = "" ? "life_bar.png" : this.healingJsonObj.options.baseImage

        this.healingJsonObj.options.blockDistance := this.healingJsonObj.options.blockDistance = "" ? 2 : this.healingJsonObj.options.blockDistance


        if (MemoryManager.healingMemory()) {
            return
        }


        for key, value in this.healingJsonObj.life
        {
            if (value = "")
                throw Exception("Empty JSON ""life"" setting: " key, A_ThisFunc)
        }
        for key, value in this.healingJsonObj.mana
        {
            if (value = "")
                throw Exception("Empty JSON ""mana"" setting: " key, A_ThisFunc)
        }
        for key, value in this.healingJsonObj.options
        {
            if (key = "debug")
                continue
            if (value = "")
                throw Exception("Empty JSON ""options"" setting: " key, A_ThisFunc)
        }

        this.lifeBarImagePath :=  ImagesConfig.healingLifeBarFolder "\" new _HealingJson().get("options.baseImage")
        if (!FileExist(this.lifeBarImagePath))
            throw Exception("baseImage doesn't exist: " this.lifeBarImagePath, A_ThisFunc)

        ; if (this.healingJsonObj.options.debug = true)
        ; msgbox, % "healingJsonObj:`n" serialize(this.healingJsonObj)

        type := "life"
        file := ImagesConfig.healingLifePixelFolder "\" this.healingJsonObj[type].pixelImageName
        if (this.needToCreatePixelImage(type) = true) {
            try this.createPixelImage(type, file)
            catch e
                throw Exception("Failed to create " type " pixel images.`nError: " e.Message " | " e.What, A_ThisFunc)
        }

        type := "mana"
        file := ImagesConfig.healingManaPixelFolder "\" this.healingJsonObj[type].pixelImageName
        if (this.needToCreatePixelImage(type) = true) {
            try this.createPixelImage(type, file)
            catch e
                throw Exception("Failed to create " type " pixel images.`nError: " e.Message " | " e.What, A_ThisFunc)
        }

    }

    needToCreatePixelImage(type) {
        ; if (this.healingJsonObj.options.debug = true) {
        ;     msgbox, % "healing " type " pixelColor maxIndex:" this.healingJsonObj[type].pixelColor.MaxIndex()
        ; }
        if (this.healingJsonObj[type].pixelColor.MaxIndex() > 0) {
            Loop, % this.healingJsonObj[type].pixelColor.MaxIndex() {
                file := ImagesConfig["healing" type "PixelFolder"] "\" StrReplace(this.healingJsonObj[type].pixelImageName, ".png", "") "_" A_Index ".png"
                if (this.healingJsonObj.options.debug = true) {
                    try FileDelete, % file
                    catch {
                    }
                }
                if (!FileExist(file))
                    return true
            }
            return false
        }

        pixColor := "0xFF" StrReplace(this.healingJsonObj[type].pixelColor[A_Index], "0x", "")
        file := ImagesConfig["healing" type "PixelFolder"] "\" this.healingJsonObj[type].pixelImageName

        if (this.healingJsonObj.options.debug = true) {
            try FileDelete, % file
            catch {
            }
        }

        if (!FileExist(file))
            return true
        else
            return false
    }

    /**
    * @return bool
    * @msgbox
    */
    checkBarsVisible() {
        if (MemoryManager.healingMemory())
            return
        msgboxOnError := (!A_IsCompiled) ? true : false

        Loop, 4 {
            vars := this.searchLifeBar()
            if (vars.x)
                break
            Sleep, 250
        }
        if (!vars.x) {
            msgbox_image(LANGUAGE = "PT-BR" ? "Não foi localizada as barras de vida/mana padrões do Tibia na tela, certifique-se de que estão visiveis(configuração do cliente do Tibia)" : "It was not found the default life/mana bars of Tibia on screen, ensure that they are visible(Tibia client setting)." , "Data\Files\Images\GUI\Others\bars_visible.png", 4)
            return false
        }

        if (this.healingJsonObj.options.debug = true) {
            ; mouseMove, windowX + vars.x, WindowY + vars.y
            ; msgbox, % this.healingJsonObj.life.baseImage " position x: " vars.x ", y: " vars.y
        }

        return true

    }

    findBars(timerCheck := false, funcOrigin := "")
    {
        this.configureHealer(timerCheck, funcOrigin)
    }

    configureHealer(timerCheck, funcOrigin := "")
    {
        if (healingObj.life.highestLife = "") {
            _Logger.error("Empty highestLife", funcOrigin "." A_ThisFunc)
        }

        if (healingObj.life.highLife = "") {
            _Logger.error("Empty highLife", funcOrigin "." A_ThisFunc)
        }

        if (healingObj.life.midLife = "") {
            _Logger.error("Empty midLife", funcOrigin "." A_ThisFunc)
        }

        if (healingObj.life.lowLife = "") {
            _Logger.error("Empty lowLife", funcOrigin "." A_ThisFunc)
        }

        healingSystemObj.life := {}
        healingSystemObj.life.highest := {}
        healingSystemObj.life.high := {}
        healingSystemObj.life.mid := {}
        healingSystemObj.life.low := {}

        coordinates := new _LifeBarArea().getCoordinates()

        this.distance := coordinates.getWidth()

        healingSystemObj.lifeBar := {}
        healingSystemObj.manaBar := {}

        healingSystemObj.lifeBar.x1 := coordinates.getX1()
        healingSystemObj.lifeBar.y1 := coordinates.getY1()
        healingSystemObj.lifeBar.x2 := coordinates.getX2()
        healingSystemObj.lifeBar.y2 := coordinates.getY2()



        healingSystemObj.life.highest.x1 := new _Coordinate(this.calculateX1("life", healingObj.life.highestLife), coordinates.getY1())
        healingSystemObj.life.high.x1 := new _Coordinate(this.calculateX1("life", healingObj.life.highLife), coordinates.getY1())
        healingSystemObj.life.mid.x1 := new _Coordinate(this.calculateX1("life", healingObj.life.midLife), coordinates.getY1())
        healingSystemObj.life.low.x1 := new _Coordinate(this.calculateX1("life", healingObj.life.lowLife), coordinates.getY1())

        ; healingSystemObj.life.highest.x2 := new _Coordinate(this.calculateX2("life", healingObj.life.highestLife), coordinates.getY2())
        ; healingSystemObj.life.high.x2 := new _Coordinate(this.calculateX2("life", healingObj.life.highLife), coordinates.getY2())
        ; healingSystemObj.life.mid.x2 := new _Coordinate(this.calculateX2("life", healingObj.life.midLife), coordinates.getY2())
        ; healingSystemObj.life.low.x2 := new _Coordinate(this.calculateX2("life", healingObj.life.lowLife), coordinates.getY2())


        healingSystemObj.life.highest := new _Coordinates(healingSystemObj.life.highest.x1, coordinates.getC2())
        healingSystemObj.life.high := new _Coordinates(healingSystemObj.life.high.x1, coordinates.getC2())
        healingSystemObj.life.mid := new _Coordinates(healingSystemObj.life.mid.x1, coordinates.getC2())
        healingSystemObj.life.low := new _Coordinates(healingSystemObj.life.low.x1, coordinates.getC2())

        if (timerCheck = false) && (this.healingJsonObj.options.debug = true) {
            healingSystemObj.life.highest.debug()
            healingSystemObj.life.high.debug()
            healingSystemObj.life.mid.debug()
            healingSystemObj.life.low.debug()
        }


        healingSystemObj.mana := {}
        healingSystemObj.mana.manaMin := {}
        healingSystemObj.mana.manaMax := {}
        healingSystemObj.mana.manaTrain := {}

        coordinates := new _ManaBarArea().getCoordinates()

        healingSystemObj.manaBar.x1 := coordinates.getX1()
        healingSystemObj.manaBar.y1 := coordinates.getY1()
        healingSystemObj.manaBar.x2 := coordinates.getX2()
        healingSystemObj.manaBar.y2 := coordinates.getY2()


        healingSystemObj.mana.manaMin.x1 := new _Coordinate(this.calculateX1("mana", healingObj.mana.manaMin), coordinates.getY1())
        healingSystemObj.mana.manaMax.x1 := new _Coordinate(this.calculateX1("mana", healingObj.mana.manaMax), coordinates.getY1())
        healingSystemObj.mana.manaTrain.x1 := new _Coordinate(this.calculateX1("mana", healingObj.mana.manaTrain), coordinates.getY1())

        ; healingSystemObj.mana.manaMin.x2 := new _Coordinate(this.calculateX2("mana", healingObj.mana.manaMin), coordinates.getY2())
        ; healingSystemObj.mana.manaMax.x2 := new _Coordinate(this.calculateX2("mana", healingObj.mana.manaMax), coordinates.getY2())
        ; healingSystemObj.mana.manaTrain.x2 := new _Coordinate(this.calculateX2("mana", healingObj.mana.manaTrain), coordinates.getY2()).addX(1)

        healingSystemObj.mana.manaMin := new _Coordinates(healingSystemObj.mana.manaMin.x1, coordinates.getC2())
        healingSystemObj.mana.manaMax := new _Coordinates(healingSystemObj.mana.manaMax.x1, coordinates.getC2())
        healingSystemObj.mana.manaTrain := new _Coordinates(healingSystemObj.mana.manaTrain.x1, coordinates.getC2())

        if (timerCheck = false) && (this.healingJsonObj.options.debug = true) {
            healingSystemObj.mana.manaMin.debug()
            healingSystemObj.mana.manaMax.debug()
            healingSystemObj.mana.manaTrain.debug()
        }
    }

    calculateX1(type, percentage)
    {
        if (this.distance = "")
            throw Exception("Empty distance, type: " type ", percentage: " percentage)

        return healingSystemObj[type "Bar"].x1 + ((percentage * this.distance) / 100) - this.healingJsonObj.options.blockDistance
    }

    calculateX2(type, percentage) {
        if (this.distance = "")
            throw Exception("Empty distance")

        return healingSystemObj[type "Bar"].x1 + ((percentage * this.distance) / 100) + this.healingJsonObj.options.blockDistance
    }

    /**
    * @return _Coordinate
    */
    searchLifeBar()
    {
        _search := new _ImageSearch()
            .setFolder(ImagesConfig.healingLifeBarFolder)
            .setVariation(new _HealingJson().get("options.baseImageVariation"))
            .setArea(new _SideBarsArea())
        ; .setDebug()

        baseImage := new _HealingJson().get("options.baseImage")
        if (!IsObject(baseImage)) {
            _search.setFile(baseImage)
                .search()
            return _search.getResult()
        }

        for _, image in baseImage {
            _search.setFile(image)
                .search()

            if (_search.found()) {
                break
            }
        }

        if (_search.notFound()) {
            _search.setArea(new _WindowArea())

            for _, image in baseImage {
                _search.setFile(image)
                    .search()

                if (_search.found()) {
                    break
                }
            }
        }

        return _search.getResult()
    }

    /**
    * @param string type
    * @param _Coordinates coordinates
    * @return _UniqueImageSearch
    */
    searchManaPixel(coordinates)
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _UniqueImageSearch()
                .setFile(this.healingJsonObj.mana.pixelImageName)
                .setFolder(ImagesConfig.healingManaPixelFolder)
                .setVariation(new _HealingJson().get("mana.pixelVariation", 60))
        }

        _search := searchCache
            .setCoordinates(coordinates)

        return this.resolveSearchPixelResult("mana", _search)
    }

    /**
    * @param string type
    * @param _Coordinates coordinates
    * @return _UniqueImageSearch
    */
    searchLifePixel(coordinates)
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _UniqueImageSearch()
                .setFile(this.healingJsonObj.life.pixelImageName)
                .setFolder(ImagesConfig.healingLifePixelFolder)
                .setVariation(new _HealingJson().get("life.pixelVariation", 60))
        }

        _search := searchCache
            .setCoordinates(coordinates)

        return this.resolveSearchPixelResult("life", _search)
    }

    /**
    * @param string type
    * @param _UniqueImageSearch _search
    * @return _UniqueImageSearch
    */
    resolveSearchPixelResult(type, _search) {

        if (!this.healingJsonObj[type].pixelColor.MaxIndex()) {
            return _search.search(true)
        }

        Loop, % this.healingJsonObj[type].pixelColor.MaxIndex() {
            _search
                .setFile(this.healingJsonObj[type].pixelImageName "_" A_Index)
                .search(true)

            if (_search.found()) {
                break
            }
        }

        return _search
    }

    /**
    * @param string rule
    * @return bool
    */
    hasLifeRule(rule)
    {
        if (MemoryManager.healingMemory()) {
            return this.hasHealthPercentMemory("life", healingObj.life[rule "Life"], rule)
        }

        if (healingSystemObj.life[rule].x1 = "") {
            return false
        }

        try {
            _search := this.searchLifePixel(healingSystemObj.life[rule])
        } catch e {
            _Logger.exception(e, A_ThisFunc, rule)
            return false
        }

        if (!this.outPutDebugLife) {
            OutputDebug(A_ThisFunc, "life " rule ": " serialize(vars)), this.outPutDebugLife := true
        }

        if (this.healingJsonObj.options.debug) {
            msgbox, % A_ThisFunc "`n" rule "`n" serialize(vars)
        }

        return _search.found()
    }

    /**
    * @param string rule - "Min" or "Max"
    * @return bool
    */
    hasManaRule(rule)
    {
        if (this.manaHealingDisabled) {
            return true
        }

        if (MemoryManager.healingMemory()) {
            return this.hasHealthPercentMemory("mana", healingObj.mana[rule], rule)
        }

        if (!healingSystemObj.mana[rule].x1) {
            return false
        }

        try {
            _search := this.searchManaPixel(healingSystemObj.mana[rule])
        } catch e {
            _Logger.exception(e, A_ThisFunc, rule)
            return false
        }

        if (!this.outPutDebugMana) {
            OutputDebug(A_ThisFunc, "mana " rule ": " serialize(vars)), this.outPutDebugMana := true
        }

        if (this.healingJsonObj.options.debug) {
            msgbox, % A_ThisFunc "`n" rule "`n" serialize(vars)
        }

        return _search.found()
    }

    /**
    * @param string type
    * @param int percent
    * @return bool
    */
    hasHealthPercent(type, percent)
    {
        if (this[type "HealingDisabled"]) {
            return true
        }

        if (percent < 1) {
            return true
        }

        if (percent > 99) {
            percent := 99
        }

        if (MemoryManager.healingMemory()) {
            return this.hasHealthPercentMemory(type, percent)
        }

        try {
            coordinates := type = "life" ? new _LifeBarArea().getCoordinates() : new _ManaBarArea().getCoordinates()

            c1 := new _Coordinate(this.calculateX1(type, percent), coordinates.getY1())
            coordinates := new _Coordinates(c1, coordinates.getC2())

            _search := type = "life" ? this.searchLifePixel(coordinates) : this.searchManaPixel(coordinates)
        } catch e {
            _Logger.exception(e, A_ThisFunc, "type: " type ", rule: " rule)
            return false
        }

        if (this.healingJsonObj.options.debug) {
            msgbox, % A_ThisFunc "`ntype: " type ", percent: " percent "`nfound:" _search.getResult()
        }

        return _search.found()
    }

    /**
    * @param int mana
    * @return bool
    */
    hasManaPercent(percent)
    {
        return this.hasHealthPercent("mana", percent)
    }

    /**
    * @param int mana
    * @return bool
    */
    hasLifePercent(percent)
    {
        return this.hasHealthPercent("life", percent)
    }

    hasHealthPercentMemory(type, percent := "", funcOrigin := "")
    {
        current := MemoryManager.readHealth(type)
        if (current < 1) {
            _Logger.error( "Failed to read current life from memory: " current, A_ThisFunc)
            return false
        }
        total := MemoryManager.readHealth(type, false)
        if (total < 1) {
            _Logger.error( "Failed to read total life from memory: " total, A_ThisFunc)
            return false
        }

        currentPercentage := (current * 100) / total
        if (this.healingJsonObj.options.debug = true)
            msgbox, % type "`ntotal = " total " / current " current " / currentPercentage = " currentPercentage " / percent " percent "`n" (currentPercentage < percent) "`n" funcOrigin

        return (currentPercentage >= percent)
    }

    createPixelImage(type, filePath) {
        if (this.healingJsonObj[type].pixelColor.MaxIndex() > 0) {
            Loop, % this.healingJsonObj[type].pixelColor.MaxIndex() {

                pixColor := "0xFF" StrReplace(this.healingJsonObj[type].pixelColor[A_Index], "0x", "")

                this.createPixelColorImage(pixColor, ImagesConfig["healing" type "PixelFolder"] "\" StrReplace(this.healingJsonObj[type].pixelImageName, ".png", "") "_" A_Index ".png")
            }
            return
        }

        pixColor := "0xFF" StrReplace(this.healingJsonObj[type].pixelColor, "0x", "")
        this.createPixelColorImage(pixColor, filePath)
    }

    createPixelColorImage(pixColor, filePath) {
        pBitmap := Gdip_CreateBitmap(1,1)

        Gdip_SetPixel(pBitmap, 0, 0, pixColor)

        Gdip_SaveBitmapToFile(pBitmap, filePath)
        Gdip_DisposeImage(pBitmap), pBitmap := ""
    }

    lowAndMidPotion(rule) {
        if (!clientHasFeature("useItemWithHotkey")) {
            if (healingObj.life[rule "ItemName"] = "" OR healingObj.life[rule "ItemName"] = A_Space)
                return

            this.useItemOnChar(healingObj.life[rule "ItemName"])
            return
        }

        if (healingObj.life[rule "PotionHotkey"] != "") {
            Loop, 2 {
                Send(healingObj.life[rule "PotionHotkey"], "", false, waitModifierKeys := false)
            }

            Sleep, % this.get("delayAfterUseItem", true)
        }
    }

    hasHotkeyOrItem(rule)
    {
        switch rule {
            case "high", case "highest":
                return !empty(healingObj.life[rule "Hotkey"])
            case "low", case "mid":
                if (!clientHasFeature("useItemWithHotkey")) {
                    return !empty(healingObj.life[rule "ItemName"])
                }

                return !empty(healingObj.life[rule "PotionHotkey"]) || !empty(healingObj.life[rule "Hotkey"])
        }

    }

    useManaPotion() {
        if (!clientHasFeature("useItemWithHotkey")) {
            if (healingObj.mana.manaItemName = "" OR healingObj.mana.manaItemName = A_Space)
                return
            this.useItemOnChar(healingObj.mana.manaItemName)
            return
        }

        Loop, 2 {
            Send(healingObj.mana.manaHotkey, "", false, waitModifierKeys := false)
        }

        Sleep, % this.get("delayAfterUseItem", true)
    }

    useItemOnChar(itemName)
    {
        try {
            _search := new _ItemSearch()
                .setName(itemName)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, itemName)
            return false
        }

        if (_search.notFound()) {
            return
        }

        try {
            IniWrite, 1, %DefaultProfile%, healing_system, UsingItemOnCharacter
            _search.use()
            Sleep, 35


            ; BlockInput, MouseMove
            ; Sleep, 25
                new _CharPosition().getPosition().click()
            Sleep, % this.get("delayAfterUseItem", true)
        } finally {
            ; Sleep, 25
            ; BlockInput, MouseMoveOff
            IniWrite, 0, %DefaultProfile%, healing_system, UsingItemOnCharacter
        }
    }

    lifeHealing()
    {
        if (!healingObj.lifeHealingEnabled) {
            return
        }

        ruleNumber := 1
        Loop, {
            Sleep, 100

            if (this.isDisconnected()) {
                return
            }

            switch ruleNumber {
                case 1: rule := "low"
                case 2: rule := "mid"
                case 3: rule := "high"
                case 4: rule := "highest"
            }

            if (this.hasLifeRule(rule) || !this.hasHotkeyOrItem(rule)) {
                if (ruleNumber = 4) {
                    break
                }

                ruleNumber++
                continue
            }

            ruleNumber := 1

            /**
            use potion hotkey in low and mid
            */
            switch rule {
                case "low", case "mid":
                    this.lowAndMidPotion(rule)
            }

            /**
            check if have enough mana to cast the spell
            */
            if (!empty(healingObj.life[rule "Hotkey"]) && this.hasManaPercent(healingObj.life[rule "Mana"])) {
                if (!new _HasCooldown("healing")) {
                    Loop, 2 {
                        Send(healingObj.life[rule "Hotkey"], "", false, waitModifierKeys := false)
                    }
                }
            }

            /**
            if life is on low and potion hotkey is set, doesn't heal mana
            to not get cooldown to heal life
            */
            switch rule {
                case "low", case "mid":
                    if (this.checkItemNameOrHotkey(rule)) {
                        continue
                    }
            }

            break
        }
    }

    /**
    * @param string rule
    * @return bool
    */
    checkItemNameOrHotkey(rule) {
        if (!clientHasFeature("useItemWithHotkey")) {
            if (empty(healingObj.life[rule "ItemName"])) {
                return false
            }
        } else {
            if (!healingObj.life[rule "PotionHotkey"]) {
                return false
            }
        }

        return true
    }

    manaHealing() {
        global healToMaxMana

        if (this.hasManaRule("manaMax") = false) {
            this.useManaPotion()
            return
        }

        /**
        mana reached or is above Max, so set to false the control variable
        */
        healToMaxMana := false
    }

    manaTrain() {
        if (!healingObj.manaTrainEnabled) {
            return
        }

        Sleep, 50
        if (healingObj.mana.manaTrainChatOn && !this.healingJsonObj.options.disableChatCondition) {
            if (new _SearchChatOnButton().found()) {
                return
            }
        }

        if (healingObj.mana.manaTrainPZ) {
            if (isInProtectionZone()) {
                return
            }
        }

        if (this.hasManaPercent(healingObj.mana.manaTrain)) {
            Send(healingObj.mana.manaTrainHotkey)
            Sleep, 900
        }
    }

    /**
    * @return bool
    */
    isDisconnected()
    {
        elapsed := this.lastDisconnectedCheck.elapsed()
        if (this.lastDisconnectedCheck.elapsed() < 3000) {
            return false
        }

        this.lastDisconnectedCheck.reset()
        if (isDisconnected()) {
            ToolTip, % txt("Desconectado [Healer]", "Disconnected [Healer]")
            Sleep, 2000
            Tooltip
            return true
        }

        return false
    }
}