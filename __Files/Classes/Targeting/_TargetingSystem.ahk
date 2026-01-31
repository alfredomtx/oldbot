global currentCreature
global targetingSystemObj

/*
ini settings
*/
class _TargetingSystem
{
    __New()
    {
        global

        targetingSystemObj := {}
        this.defaultCreature := "all"

        this.targetingJsonSetup()
        ; this.startTargetingTimer()

        this.readIniTargetingGlobalSettings()

        this.creaturePositionFolder := ImagesConfig.targetingFolder "\pos"
        if (this.targetingJsonObj.options.creaturePositionFolder != "")
            this.creaturePositionFolder .= "\" this.targetingJsonObj.options.creaturePositionFolder


        this.creatureImageWidths := {}
        this.creatureImageWidths.Push(25)
        this.creatureImageWidths.Push(40)
        this.creatureImageWidths.Push(60)
        this.creatureImageWidths.Push(80)
        this.creatureImageWidths.Push(100)
        this.creatureImageWidths.Push(118)

        this.creatureImageWidthsDropdown := ""
        for key, value in this.creatureImageWidths
            this.creatureImageWidthsDropdown .= txt("Largura: ", "Width: ") value "px|"


        this.creaturesLimitToCount := 20

        this.delayAfterAttack := 100

        this.resetAttackSpellsTargeting()
    }

    createCorpseImagesArray() {
        this.corpseScriptImages := {}
        if (!IsObject(scriptImagesObj))
            throw Exception("scriptImagesObj not initialized.")
        for imageName, atributes in scriptImagesObj
        {
            ; msgbox, % imageName "`n" atributes.category "`n" serialize(atributes)
            if (atributes.category != "Corpse")
                continue
            this.corpseScriptImages.Push(imageName)
        }
    }

    targetingJsonSetup() {

        try this.targetingJsonObj := OldBotSettings.loadModuleJsonSettingsFile("targeting")
        catch e {
            Msgbox, 16, % e.What, % e.Message, 30
            ExitApp
        }

        try this.validateTargetingJsonSettings()
        catch e {
            Msgbox, 16, % e.What, % e.Message, 30
            ExitApp
        }
    }

    checkDefaultJsonCategories() {

        this.categories := {}
        this.categories.Push("battleListImages")
        this.categories.Push({"battleListSetup": ["lifeBar", "lifeBarPixelColors"]})
        this.categories.Push({"redPixelArea": ["getCreatureImage"]})
        this.categories.Push("useItemOnCorpse")
        this.categories.Push("options")

        for key, category in this.categories
        {
            if (!IsObject(this.targetingJsonObj[category]))
                this.targetingJsonObj[category] := {}

            if (IsObject(category)) {
                for subcategory, subcategories in category
                {
                    if (!IsObject(this.targetingJsonObj[subcategory]))
                        this.targetingJsonObj[subcategory] := {}
                    for key3, subcategoryName in subcategories
                    {
                        if (!IsObject(this.targetingJsonObj[subcategory][subcategoryName]))
                            this.targetingJsonObj[subcategory][subcategoryName] := {}
                    }
                }
            }
        }
        ; msgbox, % serialize(this.targetingJsonObj["minimap"])
    }

    validateTargetingJsonSettings() {
        if (this.targetingJsonObj = "")
            throw Exception("Empty targeting.json settings", A_ThisFunc)
        if (!IsObject(TibiaClient))
            throw Exception("TibiaClient not initialized.")

        this.checkDefaultJsonCategories()

        /**
        targetingJsonObj.battleListImages
        */
        this.targetingJsonObj.battleListImages.baseImage := this.targetingJsonObj.battleListImages.baseImage = "" ? "battle_list.png" : this.targetingJsonObj.battleListImages.baseImage
        this.targetingJsonObj.battleListImages.baseImageVariation := this.targetingJsonObj.battleListImages.baseImageVariation = "" ? 50 : this.targetingJsonObj.battleListImages.baseImageVariation
        this.targetingJsonObj.battleListImages.battleListButtonsVisibleVariation := this.targetingJsonObj.battleListImages.battleListButtonsVisibleVariation = "" ? 60 : this.targetingJsonObj.battleListImages.battleListButtonsVisibleVariation

        if (this.targetingJsonObj.battleListImages.battleListButtonsVisible = "") {
            if (isTibia13())
                this.targetingJsonObj.battleListImages.battleListButtonsVisible := "battlelist_buttons.png"
            else
                this.targetingJsonObj.battleListImages.battleListButtonsVisible := this.targetingJsonObj.battleListImages.battleListButtonsVisible

        }


        this.targetingJsonObj.battleListSetup.lifeBar.offsetFromBaseImagePositionX := this.targetingJsonObj.battleListSetup.lifeBar.offsetFromBaseImagePositionX = "" ? 22 : this.targetingJsonObj.battleListSetup.lifeBar.offsetFromBaseImagePositionX
        this.targetingJsonObj.battleListSetup.lifeBar.offsetFromBaseImagePositionY := this.targetingJsonObj.battleListSetup.lifeBar.offsetFromBaseImagePositionY = "" ? 31 : this.targetingJsonObj.battleListSetup.lifeBar.offsetFromBaseImagePositionY

        if (this.targetingJsonObj.battleListSetup.lifeBar.width = "") {
            this.targetingJsonObj.battleListSetup.lifeBar.width := isTibia13() ? 132 : 139
        }

        this.targetingJsonObj.battleListSetup.lifeBar.spaceBetweenBars := this.targetingJsonObj.battleListSetup.lifeBar.spaceBetweenBars = "" ? 22 : this.targetingJsonObj.battleListSetup.lifeBar.spaceBetweenBars

        if (this.targetingJsonObj.battleListSetup.lifeBarPixelColors.Count() < 1) {
            if (isTibia13()) {
                this.targetingJsonObj.battleListSetup.lifeBarPixelColors.Push({"greenFull": "0xC000"})
                this.targetingJsonObj.battleListSetup.lifeBarPixelColors.Push({"green": "0x60C060"})
                this.targetingJsonObj.battleListSetup.lifeBarPixelColors.Push({"yellow": "0xC0C000"})
                this.targetingJsonObj.battleListSetup.lifeBarPixelColors.Push({"orange": "0xC00000"})
                this.targetingJsonObj.battleListSetup.lifeBarPixelColors.Push({"red": "0xC03030"})
                this.targetingJsonObj.battleListSetup.lifeBarPixelColors.Push({"black": "0x600000"})
            } else {
                this.targetingJsonObj.battleListSetup.lifeBarPixelColors.Push({"greenFull": "0x00BC00"})
                this.targetingJsonObj.battleListSetup.lifeBarPixelColors.Push({"green": "0x50A150"})
                this.targetingJsonObj.battleListSetup.lifeBarPixelColors.Push({"yellow": "0xA1A100"})
                this.targetingJsonObj.battleListSetup.lifeBarPixelColors.Push({"red": "0xBF0A0A"})
                this.targetingJsonObj.battleListSetup.lifeBarPixelColors.Push({"black": "0x910F0F"})
            }
        }


        /**
        targetingJsonObj.redPixelArea
        */
        if (!IsObject(this.targetingJsonObj.redPixelArea))
            this.targetingJsonObj.redPixelArea := {}

        this.targetingJsonObj.redPixelArea.pixelImage := this.targetingJsonObj.redPixelArea.pixelImage = "" ? "red_pixel.png" : this.targetingJsonObj.redPixelArea.pixelImage

        if (!FileExist(ImagesConfig.targetingFolder . "\" . this.targetingJsonObj.redPixelArea.pixelImage))
            throw Exception("pixelImage doesn't exist on directory:`n" ImagesConfig.targetingFolder . "\" . this.targetingJsonObj.redPixelArea.pixelImage, A_ThisFunc)

        this.targetingJsonObj.redPixelArea.pixelImageVariation := this.targetingJsonObj.redPixelArea.pixelImageVariation = "" ? 20 : this.targetingJsonObj.redPixelArea.pixelImageVariation

        /**
        targetingJsonObj.redPixelArea.getCreatureImage
        */
        if (!IsObject(this.targetingJsonObj.redPixelArea.getCreatureImage))
            this.targetingJsonObj.redPixelArea.getCreatureImage := {}

        /**
        targetingJsonObj.useItemOnCorpse
        */
        this.targetingJsonObj.useItemOnCorpse.corpseImageVariation := this.targetingJsonObj.useItemOnCorpse.corpseImageVariation = "" ? 40 : this.targetingJsonObj.useItemOnCorpse.corpseImageVariation

        /**
        targetingJsonObj.options
        */
        this.targetingJsonObj.options.searchCreatureVariation := this.targetingJsonObj.options.searchCreatureVariation = "" ? 40 : this.targetingJsonObj.options.searchCreatureVariation
        this.targetingJsonObj.options.lifeBarsSearchVariation := this.targetingJsonObj.options.lifeBarsSearchVariation = "" ? 40 : this.targetingJsonObj.options.lifeBarsSearchVariation


        ; if (this.targetingJsonObj.options.debug = true) {
        ;     ClipBoard := serialize(this.targetingJsonObj)
        ;     msgbox, % ClipBoard
        ; }

    }

    startTargetingCavebotSetup() {
        global


        /**
        obj that have all the information of targeting, such as:
        - monsters: targetingSystemObj[creatureNames]
        - ignored state: targetingSystemObj["targetingIgnored"]
        - .reason: reason of being ignored, such as unreachable creature, time attacking creature
        - .details: additional info of reason, such as ignored creature name
        - .startTimer: A_TickCount of where the countdown started
        - .elapsed: current time in seconds since the timer started

        */
        targetingSystemObj.creatures := {}
        targetingSystemObj.attackSpell := {}
        targetingSystemObj.targetingIgnored := {}
        targetingSystemObj.creaturesDanger := {}
        targetingSystemObj.items := {}
        targetingSystemObj.combat := {}

        targetingSystemObj.luremode := {}
        targetingSystemObj.luremode.timerAttack := {}
        targetingSystemObj.luremode.timerAttack.spells := {}
        targetingSystemObj.luremode.timerAttack.spells.1 := {}
        targetingSystemObj.luremode.timerAttack.spells.2 := {}

        targetingSystemObj.luremode.enabled := false
        targetingSystemObj.luremode.timerAttack.enabled := false
        targetingSystemObj.luremode.timerAttack.running := false

        targetingSystemObj.positions := {}
        targetingSystemObj.position.blackPix := {}

        targetingSystemObj.antiks := {}
        targetingSystemObj.timers := {}
        targetingSystemObj.timers.creatureNotReached := {}

        targetingSystemObj.isTrapped := false


        this.lifePixelsBattle := {}
        this.lifePixelsBattle["greenFull"] := "0xC000"
        this.lifePixelsBattle["green"] := "0x60C060"
        this.lifePixelsBattle["yellow"] := "0xC0C000"
        this.lifePixelsBattle["orange"] := "0xC00000"
        this.lifePixelsBattle["red"] := "0xC03030"
        this.lifePixelsBattle["black"] := "0x600000"


        Random, R, 0, 1
        this.creatureSearchOrder := R

        targetingSystemObj.antiKsDetectedAttacks := 0

        ClientAreas.battleList := {}

        this.TargetingTimer := new _TargetingSettings().get("huntAssistMode") ? 200 : new _TargetingIniSettings().get("targetingIntervalTime")
        if (_AntiKS.shouldRun()) {
            this.TargetingTimer := 350
        }

        for creatureName, _ in targetingObj.targetList
        {
            if (!targetingSystemObj.creatures[creatureName])
                targetingSystemObj.creatures[creatureName] := {}
        }

    }

    startLureModeTimerAttack() {
        targetingSystemObj.luremode.timerAttack.running := true
        SetTimer, LureModeTimerAttackTimer, Delete
        SetTimer, LureModeTimerAttackTimer, 1000
    }

    stopLureModeTimerAttack() {
        targetingSystemObj.luremode.timerAttack.running := false
        SetTimer, LureModeTimerAttackTimer, Delete
    }

    lureModeTimerAttack() {
        if (targetingSystemObj.targetingDisabled) {
            return
        }

        isAttacking := new _IsAttacking().found()
        writeCavebotLog("Lure mode attack", "Is attacking: " boolToString(isAttacking))

        if (!isAttacking) {
            if (!targetingSystemObj.luremode.timerAttack.stand) {
                _search := this.isInCombatMode("chase", change := false)
                if (_search.found()) {
                    targetingSystemObj.luremode.timerAttack.restoreChase := true
                    _search.click()
                    Sleep, 50
                }

                targetingSystemObj.luremode.timerAttack.stand := true
            }

            Send("Space")
            Sleep, % this.delayAfterAttack
        }

        if (new _IsAttacking().notFound()) {
            return
        }

        spellCasted := false
        loop, % targetingSystemObj.luremode.timerAttack.spells.MaxIndex() {
            spellHotkey := targetingSystemObj.luremode.timerAttack.spells[A_Index].hotkey

            if (empty(spellHotkey)) {
                continue
            }

            spell := targetingSystemObj.luremode.timerAttack.spells[A_Index].spell

            writeCavebotLog("LureModeTimer", "Casting attack spell with hotkey: " spellHotkey ", spell cooldown: " (spell ? spell : "default"))
            if (empty(spell)) {
                hasCooldown := AttackSpell.hasCooldown(0, false, false, false, {"type": "Attack", "spell": "Default"})
            } else {
                hasCooldown := AttackSpell.hasCooldown(0, false, false, false, {"type": "Attack", "spell": spell})
            }


            if (!hasCooldown) {
                spellCasted := true
                Send(spellHotkey)
                ; if (A_Index = 1) {
                Sleep, 100
                ; }
            }
        }

        if (!spellCasted) {
            Sleep, 75
        }

        CavebotWalker.waypointClick()
    }

    createCreaturesDangerObj(loadImages := true) {
        if (!IsObject(targetingObj.targetList))
            throw Exception("Target list object doesn't exist")

        targetingSystemObj.creaturesDanger := {}

        ; msgbox, % serialize(targetingObj.targetList)

        for creatureName, atributes in targetingObj.targetList
        {
            if (!IsObject(targetingSystemObj.creaturesDanger[atributes.danger]))
                targetingSystemObj.creaturesDanger[atributes.danger] := {}

            targetingSystemObj.creaturesDanger[atributes.danger].Push(creatureName)
        }
        ; msgbox, % serialize(targetingSystemObj.creaturesDanger)
    }

    deleteIgnoredTargetingTimer() {
        SetTimer, countIgnoredTargetingTimer, Delete
        targetingSystemObj.targetingIgnored.active := false
            , restoreTargetingIcon()
    }

    ignoredTargetingTimer() {
        targetingSystemObj.targetingIgnored.elapsed := (A_TickCount - targetingSystemObj.targetingIgnored.startTimer) / 1000
            , writeCavebotLog("Targeting", "[" targetingSystemObj.targetingIgnored.elapsed "/" targetingSystemObj.targetingIgnored.endTime "s]" txt("Targeting ignorado temporariamente, motivo: ", " Targeting ignored temporarily, reason: ") targetingSystemObj.targetingIgnored.reason " | details: " targetingSystemObj.targetingIgnored.details)

        if (targetingSystemObj.targetingIgnored.elapsed >= targetingSystemObj.targetingIgnored.endTime)
            this.deleteIgnoredTargetingTimer()
    }

    startIgnoredTargetingTimer(reason, details, startTimer, endTime, funcOrigin := "") {
        this.resetTargetPosition()
        ; msgbox, % A_ThisFunc
        ; this.pauseTargetingTimer()
        this.deleteCreatureAttackingTimer()
            , targetingSystemObj.targetingIgnored.active := true
            , targetingSystemObj.targetingIgnored.reason := reason
            , targetingSystemObj.targetingIgnored.details := details
            , targetingSystemObj.targetingIgnored.startTimer := startTimer
            , targetingSystemObj.targetingIgnored.endTime := endTime

        ; msgbox, % serialize(targetingSystemObj.targetingIgnored) " `n`n" funcOrigin

        SetTimer, countIgnoredTargetingTimer, 1000
    }

    deleteCreatureAttackingTimer() {
        ; msgbox, % A_ThisFunc
        SetTimer, countAttackingCreatureTimer, Delete
        targetingSystemObj.creatures[this.currentCreature].startTimer := 0
            , targetingSystemObj.creatures[this.currentCreature].active := false
            , targetingSystemObj.creatures[this.currentCreature].found := false

        this.deleteCreatureNotReachedTimer()

    }

    attackingCreatureTimer() {
        ; string_target := (AttackAllMonstersMode = 1) ? "" : "[" %currentCreature%_prioridade "] "
        string_target := ""
        targetingSystemObj.creatures[this.currentCreature].elapsed := (A_TickCount - targetingSystemObj.creatures[this.currentCreature].startTimer) / 1000
            , timeAttacking := targetingSystemObj.creatures[this.currentCreature].elapsed
            , timeAttackLimit := Ltrim(RTrim(StrReplace(targetingObj.targetList[this.currentCreature].ignoreAfter, "seconds", "")))
            , creatureDistance := (this.creatureDistanceSQM != "" ? ", Distance: " this.creatureDistanceSQM " sqm" : "")

        TargetingStatus := string_target "Target: " this.currentCreature txt(", Tempo atacando: ", "Time attacking: ") (targetingObj.targetList[this.currentCreature].ignoreAttacking = 1 ? timeAttacking "/" timeAttackLimit : timeAttacking) "s" creatureDistance
        writeCavebotLog("Targeting", TargetingStatus)

        if (targetingObj.targetList[this.currentCreature].ignoreAttacking = 0)
            return

        if (timeAttacking >= timeAttackLimit) {
            ignoreAfterTime := Ltrim(RTrim(StrReplace(targetingObj.targetList[this.currentCreature].ignoreAfterTime, "seconds", "")))
            ignoreAfterTime := Ltrim(RTrim(StrReplace(ignoreAfterTime, "for", "")))

            this.startIgnoredTargetingTimer("timeAttacking", this.currentCreature, A_TickCount, ignoreAfterTime, A_ThisFunc)

            Loop, 2
                Send("Esc")
        }

    }

    startCreatureAttackingTimer()
    {
        targetingSystemObj.creatures[this.currentCreature].active := true
            , targetingSystemObj.creatures[this.currentCreature].startTimer := A_TickCount
        SetTimer, countAttackingCreatureTimer, 1000
    }

    /**
    * @return int
    */
    countAllCreaturesBattle()
    {
        if (targetingObj.settings.attackAllMode) {
            return this.searchLifeBarsBattleList()
        }

        count := 0
        for creatureName, _ in targetingObj.targetList
        {
            if (creatureName = "all") {
                continue
            }

            try {
                creatureSearch := new _SearchCreature(creatureName, false)
            } catch e {
                _Logger.exception(e, A_ThisFunc)
                return count
            }

            count += creatureSearch.getResultsCount()
            if (count >= 8) {
                break
            }
        }

        return count
    }

    /**
    * @param string creatureName
    * @param bool firstResult
    * @param ?bool debug
    * @return _Base64ImageSearch
    */
    searchCreature(creatureName, firstResult := true, debug := false)
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _TargetingBase64ImageSearch()
                .setArea(new _BattleListArea())
                .setVariation(this.targetingJsonObj.options.searchCreatureVariation)
                .setDebug(debug)
        }

        if (creatureName = "all") {
            return
        }

        return searchCache
            .setImage(new _CreatureImage(creatureName))
            .setAllResults(!firstResult)
            .search()
    }

    /**
    * count how many life bars there are on screen
    * @return int
    */
    searchLifeBarsBattleList() {
        static searchCache
        if (!searchCache) {
            coords := new _BattleListArea().getCoordinates()

            c1 := new _Coordinate(coords.getX1(), coords.getY1())
            c2 := new _Coordinate(coords.getX2(), coords.getY2())
                .addY(10)

            searchCache := new _UniqueImageSearch()
                .setFolder(ImagesConfig.battleListLifeBarsFolder)
                .setVariation(this.targetingJsonObj.options.lifeBarsSearchVariation)
                .setAllResults(true)
                .setCoordinates(new _Coordinates(c1, c2))
        }

        count := 0
        loop, % ImagesConfig.battleListLifeBarsFolder "\*.png" {
            _search := searchCache
                .setFile(A_LoopFileName)
                .search()

            count += _search.getResultsCount()
            if (count >= this.creaturesLimitToCount) {
                break
            }
        }

        return count
    }

    /**
    * @return void
    */
    throwAreaRune(htk)
    {
        t := this.searchLifeBarsOnScreen()
        first := _Arr.first(t)
        if (!first) {
            return false
        }

        x1 := x2 := first.getX()
        y1 := y2 := first.getY()
        for _, c in t {
            x := c.getX()
            y := c.getY()
            if (x < x1) {
                x1 := x
            }
            if (y < y1) {
                y1 := y
            }
            if (x > x2) {
                x2 := x
            }
            if (y > y2) {
                y2 := y
            }
        }

        x := abs(x2 - x1)
        y := abs(y2 - y1)

        center := new _Coordinate(x1, y1)
            .addX(abs(x2 - x1) / 2)
            .addY(abs(y2 - y1) / 2)
            .add(SQM_SIZE / 2)
            .addY(SQM_SIZE / 4)
        ; .debug()

        Loop, 2 {
            Send(htk)
        }

        Sleep, 50

        center.click()

        return true
    }

    /**
    * count how many life bars there are on screen
    * @return array<_Coordinate>
    */
    searchLifeBarsOnScreen()
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _UniqueImageSearch()
                .setFolder(ImagesConfig.lifeBarsFolder)
                .setVariation(0)
                .setAllResults(true)
                .setArea(new _GameWindowArea())
        }

        barsFound := {}
        loop, % ImagesConfig.lifeBarsFolder "\*.png" {
            try {
                _search := searchCache
                    .setPath(A_LoopFileFullPath)
                ; .setDebug(true)
                    .search()
            } catch e {
                _Logger.exception(e, A_ThisFunc)
            }

            if (_search.getResultsCount()) {
                for _, coordinate in _search.getResults() {
                    barsFound.Push(coordinate)
                }
            }
        }

        return barsFound
    }

    /**
    * @param bool log
    * @return array<int>
    */
    searchLifeBars(log := false) {
        if (log) {
            t1 := A_TickCount
            writeCavebotLog("Targeting", "Searching life bars...")
        }

        barsFound := this.searchLifeBarsOnScreen()

        sqmsCreatures := {}
        sqmsIndex := {}
        loop, % barsFound.Count() {
            sqm := this.getCreatureSqmByLifeBarPos(barsFound[A_Index])
            if (!sqm) {
                continue
            }

            if (sqmsIndex[sqm]) {
                continue
            }

            sqmsIndex[sqm] := true
                , sqmsCreatures.Push(sqm)
        }

        if (log = true)
            writeCavebotLog("Targeting", barsFound.Count() " creatures on screen | " A_TickCount - t1 " ms")

        return sqmsCreatures
    }

    /**
    * get the SQM of the creature based on the position of its life bar only the SQMs around the char
    * @return ?int
    */
    getCreatureSqmByLifeBarPos(lifeBar, aroundCharOnly := true) {
        ; lifeBar.debug()
        x := lifeBar.x + SQM_SIZE / 2
            , y := lifeBar.y + SQM_SIZE - (SQM_SIZE / 3)
        ; MouseMove(x, y, true)

        sqms := aroundCharOnly = true ? 9 : 29
        Loop, % sqms {
            /**
            skip character sqm
            */
            if (A_Index = 5) {
                continue
            }
            /**
            character life bar is being fount at sqm 8, to avoid this limit the area to consider life bar at sqm 8
            */
            mod := A_Index = 8 ? (SQM_SIZE / 2 - (SQM_SIZE / 6) )  : 0
            ; MouseMove(SQM%A_Index%X_X1, SQM%A_Index%Y_Y1, true)
            ; MouseMove(SQM%A_Index%X_X2, SQM%A_Index%Y_Y2 - mod, true)
            if (x > SQM%A_Index%X_X1 && x < SQM%A_Index%X_X2) && (y > SQM%A_Index%Y_Y1 && y < SQM%A_Index%Y_Y2 - mod) {
                return A_Index
            }
        }
    }

    checkAttackingCreatureLifePercent(percent := 0)
    {
        static searchCache, battleListArea
        if (!battleListArea) {
            battleListArea := new _BattleListArea()
        }

        if (!searchCache) {
            searchCache := new _UniqueImageSearch()
                .setFile("redline")
                .setFolder(ImagesConfig.targetingFolder)
                .setVariation(0)
                .setResultOffsetY(5)
                .setArea(new _BattleListArea())
        }

        if (percent <= 1 OR percent >= 99) {
            return true
        }

        if (this.targetingJsonObj.options.disableCreatureLifeCheck) {
            return true
        }

        try {
            _search := searchCache
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return true
        }

        if (_search.notFound()) {
            return false
        }

        return !this.creatureHasLife(_search.getResult(), percent, battleListArea)
    }

    /**
    * check if the creature's life is below the specified percent
    * if pixel of position is not one of the life pixels ones
    * @param _Coordinate creatureBattlePosition
    * @param int percent
    * @param _BattleListArea battleListArea
    * @return bool
    */
    creatureHasLife(creatureBattlePosition, percent, battleListArea)
    {
        if (empty(percent)) {
            return true
        }

        if (this.targetingJsonObj.options.disableCreatureLifeCheck) {
            return true
        }

        offsetFromPositionY := 17
            , index := battleListArea.getCreaturePositionIndex(creatureBattlePosition.getY())
            , position := battleListArea.getCreaturePosition(index)
            , Distance := position.getX2() - position.getX1()
            , positionBitmap := _BitmapEngine.getClientBitmap(position)


        coord := new _Coordinate(position.getX1(), position.getY1())
            .addX((percent * Distance) / 100)
            .addY(offsetFromPositionY)
        ; coord.debug()
            .subX(position.getX1())
            .subY(position.getY1())
        ; coord.debug()

        pixColor := positionBitmap.getPixel(coord)
        for _, pixel in this.targetingJsonObj.battleListSetup.lifeBarPixelColors
        {
            for _, color in pixel
            {
                if (pixColor = color) {
                    return true
                }
            }
        }

        return false
    }

    equipItem(itemType, action, htk, delay := 500)
    {
        if (action = "equip") {
            targetingSystemObj["items"][itemType "Equipped"] := false
        }

        writeCavebotLog("Targeting", action "ping " itemType " (" htk ")..")

        Send(htk)
        Sleep, % delay

        try {
            _search := new _SearchEmptyEquipmentSlot(itemType)
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }

        this.resolveItemEquiped(action, itemType, _search.found())

        triesLimit := 3
        Loop, % triesLimit + 1 {
            if (A_Index = triesLimit + 1) {
                writeCavebotLog("Targeting - WARNING", "Failed to " action " " itemType " after " triesLimit " tries")
                break
            }

            try {
                _search := new _SearchEmptyEquipmentSlot(itemType)
            } catch e {
                _Logger.exception(e, A_ThisFunc)
            }

            this.resolveItemEquiped(action, itemType, _search.found())

            if (action = "equip" && targetingSystemObj["items"][itemType "Equipped"]) {
                return
            }

            if (action = "unequip" && !targetingSystemObj["items"][itemType "Equipped"]) {
                return
            }

            Send(htk)
            Sleep, % delay
        }
    }

    /**
    * @param string action
    * @param string itemType
    * @param bool found
    * @return void
    */
    resolveItemEquiped(action, itemType, found) {
        if (action = "equip") {
            if (!found) {
                targetingSystemObj["items"][itemType "Equipped"] := true
            }
        } else {
            if (found) {
                targetingSystemObj["items"][itemType "Equipped"] := false
            }
        }
    }

    isInCombatMode(mode, change := false) {
        static searchCache
        if (!searchCache)  {
            searchCache := new _UniqueImageSearch()
                .setFolder(ImagesConfig.targetingFolder)
                .setVariation(50)
                .setArea(new _FightControlsArea())
                .setClickOffsets(4)
        }

        /**
        TODO: check if is in follow attack and set to stand if is, then restore if it was
        */
        modeChangeTo := (mode = "chase" ? "stand" : "chase")
        try {
            _search := searchCache
                .setFile("combatmode_" modeChangeTo)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }

        if (!change || _search.notFound()) {
            return _search
        }

        _search.click()

        return _search
    }

    changeAttackMode(mode)
    {
        static searchCache

        string := StrSplit(mode, "/")
            , combatMode := Ltrim(RTrim(string.1))
            , attackMode := Ltrim(RTrim(string.2))

        if (empty(combatMode)) {
            writeCavebotLog("ERROR", "Empty combat mode: " mode)
            return
        }

        if (empty(attackMode)) {
            writeCavebotLog("ERROR", "Empty attack mode: " mode)
            return
        }

        if (!searchCache)  {
            searchCache := new _UniqueImageSearch()
                .setFolder(ImagesConfig.targetingFolder)
                .setVariation(50)
                .setArea(new _FightControlsArea())
                .setClickOffsets(6)
        }

        try {
            _search := searchCache
                .setFile("attackmode_" attackMode)
                .search()
                .click()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }

        try {
            _search := searchCache
                .setFile("combatmode_" combatMode)
                .search()
                .click()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }

        targetingSystemObj["combat"].attackModeChanged := true
    }

    isCreatureUnreachable() {
        ; writeCavebotLog("Targeting", "Checking creature unreachable..")
        targetingSystemObj.blockThreadCavebot := true

        /**
        search there is no way only in the first 3 seconds attacking the creature
        */
        if (this.targetingJsonObj.options.disableCreatureUnreachableCheck != true) && (targetingSystemObj.creatures[this.currentCreature].elapsed < 3) {
            ; msgbox, % CavebotSystem.searchThereIsNoWay()
            if (CavebotSystem.searchThereIsNoWay() = true) {
                targetingSystemObj.creatures[this.currentCreature].unreachable := true
                seconds := TargetingHandler.getIgnoreUnreachableDurationSeconds(targetingObj.targetList[this.currentCreature].ignoreUnreachableTime)
                this.startIgnoredTargetingTimer("unreachableCreature", this.currentCreature ": no path to creature", A_TickCount, seconds, A_ThisFunc)
                if (helmetX != "") {
                    MouseClick("Right", helmetX, helmetY)
                    Sleep, 250
                }
                targetingSystemObj.blockThreadCavebot := false
                return true
            }
        }

        if (targetingObj.targetList[this.currentCreature].ignoreDistance = "None" OR targetingObj.targetList[this.currentCreature].ignoreDistance = "") {
            targetingSystemObj.blockThreadCavebot := false
            return false
        }

        if (this.targetingJsonObj.options.disableCreaturePositionCheck = true)
            return false


        this.getCreaturePosition()

        targetingSystemObj.blockThreadCavebot := false
        this.creatureDistanceSQM := ""
        if (targetingSystemObj.targetX = "")
            return false

        string := StrSplit(targetingObj.targetList[this.currentCreature].ignoreDistance, " ")
            , ignoreDistance := StrReplace(string.1, "+", "")
        if (ignoreDistance <= 1)
            return false

        this.creatureDistanceSQM := this.getSqmDistanceFromTarget()
        ; msgbox, % this.creatureDistanceSQM " / '" ignoreDistance "' / " ignoreTime

        if (this.creatureDistanceSQM > ignoreDistance) {
            seconds := TargetingHandler.getTimeSecondsValue(targetingObj.targetList[this.currentCreature].ignoreDistanceTime, 2, minValue := 1, maxValue := 120)
            targetingSystemObj.creatures[this.currentCreature].unreachable := true
            this.startIgnoredTargetingTimer("unreachableCreatureDistance", this.currentCreature ": " this.creatureDistanceSQM "/" ignoreDistance " sqms", A_TickCount, seconds, A_ThisFunc)
            return true
        }
        return false
    }

    /**
    * @param string hotkey
    * @param string lifePercent
    * @return void
    */
    useExetaRes(hotkey, lifePercent) {
        if (!targetingSystemObj.releaseExeta) {
            return
        }

        percent := this.getLifePercentString(lifePercent)
        if (percent = 100) {
            lifeBelow := true
        } else {
            lifeBelow := this.checkAttackingCreatureLifePercent(percent)
        }

        if (lifeBelow) {
            this.castExetaRes(hotkey)
        }
    }

    castExetaRes(hotkey) {
        writeCavebotLog("Targeting", "[Exeta res] Casting spell, hotkey: """ hotkey """")
        Loop, 2 {
            Send(hotkey)
        }
        SetTimer, CooldownExeta, Delete
        SetTimer, CooldownExeta, 1000
        targetingSystemObj.releaseExeta := false
        return
    }

    /**
    * @param string lifeString
    * @return string
    */
    getLifePercentString(lifeString) {
        string := StrSplit(lifeString, "%")
        return Ltrim(Rtrim(string.1))
    }

    useItemOnCorpse(creatureName := "", hotkeyOrItem := "", fromAction := false)
    {
        ; writeCavebotLog("ERROR", "Use item on corpse not working on this version")
        ; return false
        if (empty(hotkeyOrItem)) {
            writeCavebotLog("WARNING", "Use item on corpse: hotkey or item to use not set")
            return
        }

        itemUseOnCorpse := targetingObj.targetList[this.currentCreature].itemUseOnCorpse
        if (OldBotSettings.settingsJsonObj.clientFeatures.useItemWithHotkey = false) && (fromAction = true) {
            itemUseOnCorpse := hotkeyOrItem
        }

        hasCorpseImages := this.hasCorpseScriptImage()

        if (!hasCorpseImages && this.currentCreature != "all") {
            if (!this.currentCreature) {
                writeCavebotLog("Targeting", "No current creature on Targeting, aborting use item on corpse.")
                return
            }

            corpseImage := ImagesConfig.corpsesFolder "\Size" WINDOW_SIZE_LEVEL "\" this.currentCreature ".png"
            if (!FileExist(corpseImage)) {
                writeCavebotLog("WARNING", "Use item on corpse: creature corpse image doesn't exist: " corpseImage)
                writeCavebotLog("WARNING", "Use item on corpse: you can set custom Script Images with the ""Corpse"" category" )
                return
            }
        }

        if (fromAction = false) && (this.targetingJsonObj.useItemOnCorpse.delayBeforeSearchingForCorpses > 1) {
            Sleep, % this.targetingJsonObj.useItemOnCorpse.delayBeforeSearchingForCorpses
        }

        noCorpseFound := true
        tries := 10
        Loop, % tries {
            Loop, 5 { ; 1 sec
                Sleep, 200
                if (hasCorpseImages) {
                    _result := this.searchCorpseCustomImages()
                } else {
                    try {
                        _result := new _UniqueImageSearch()
                            .setFile(this.currentCreature)
                            .setFolder(ImagesConfig.corpsesFolder "\Size" WINDOW_SIZE_LEVEL)
                            .setArea(new _GameWindowArea())
                            .setVariation(5)
                            .search()
                            .getResult()
                    } catch e {
                        _Logger.exception(e, A_ThisFunc)
                    }

                    if (!_result.getX()) {
                        _result := this.searchCorpseCustomImages(true)
                    }
                }

                if (_result.getX()) {
                    break
                }
            }

            if (!_result.getX()) {
                break
            }

            if (OldBotSettings.settingsJsonObj.clientFeatures.useItemWithHotkey = true) {
                if (hotkeyOrItem = "Use") {
                    writeCavebotLog("Targeting", "Using corpse, tries: "  A_Index "/"  tries " (" _result.getX() "," _result.getY() ")" )
                } else {
                    writeCavebotLog("Targeting", "Using item on corpse, hotkey: """ hotkeyOrItem """, tries: "  A_Index "/"  tries " (" _result.getX() "," _result.getY() ")" )
                    Send(hotkeyOrItem)
                    Sleep, 100
                }

            } else {
                if (empty(itemUseOnCorpse)) {
                    writeCavebotLog("WARNING", "No item to use on corpse selected for creature: " this.currentCreature)
                    return false
                }

                writeCavebotLog("Targeting", "Using """ itemUseOnCorpse """ on corpse, tries: " A_Index "/" tries " (" _result.getX() "," _result.getY() ")" )

                try {
                    _search := new _ItemSearch()
                        .setName(itemUseOnCorpse)
                        .search()
                } catch e {
                    _Logger.exception(e, A_ThisFunc, itemUseOnCorpse)
                    return false
                }

                if (_search.notFound()) {
                    writeCavebotLog("WARNING", "Item """ itemUseOnCorpse """ to use on corpse not found on screen")
                    break
                }

                _search.use()
                Sleep, 100
            }

            MouseClick(hotkeyOrItem = "Use" ? "Right" : "Left", _result.getX() + 6, _result.getY() + 6, false)

            Sleep, 1000 ; delay to reach the corpse

            Send("Esc")
            Sleep, 100
            noCorpseFound := false
        } ; loop

        if (!noCorpseFound) {
            return
        }

        writeCavebotLog("Use item on corpse", (hasCorpseImages) ? "No corpse images found" : "No corpse of """ this.currentCreature """ found")
    }

    hasCorpseScriptImage() {
        if (!IsObject(this.corpseScriptImages))
            this.createCorpseImagesArray()
        return (this.corpseScriptImages.Count() > 0)
    }

    /**
    * @return ?_Coordinate
    */
    searchCorpseCustomImages(logFoundCorpse := false)
    {
        if (!IsObject(this.corpseScriptImages))
            this.createCorpseImagesArray()

        for key, imageName in this.corpseScriptImages
        {
            _search := this.searchCorpseScriptImage(imageName, true, debug := false)
            if (_search.notFound()) {
                continue
            }

            if (logFoundCorpse = true) {
                writeCavebotLog("Targeting", "Found corpse image: " imageName)
            }

            return _search.getResult()
        }
    }

    /**
    * @return _UniqueBase64ImageSearch
    */
    searchCorpseScriptImage(imageName, firstResult := true, debug := false)
    {
        try  {
            _search := _ScriptImages.search(imageName, this.targetingJsonObj.useItemOnCorpse.corpseImageVariation, "gameWindowArea", firstResult, debug)
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }

        return _search
    }

    countCreaturesBattleListByLifeBar() {
        t1count := A_TickCount
            , targetingSystemObj.creaturesCount := 0
            , targetingSystemObj.blockThreadCavebot := true

        count := this.searchLifeBarsBattleList()

        targetingSystemObj.creaturesCountElapsed := A_TickCount - t1count
            , targetingSystemObj.blockThreadCavebot := false
            , targetingSystemObj.creaturesCount := count
    }

    /**
    * @param string creatureName
    * @return bool
    */
    checkCreatureSearchConditions(creatureName) {
        if (creatureName = this.defaultCreature) {
            return false
        }

        if (empty(targetingObj.targetList[creatureName].image)) {
            return false
        }

        if (targetingObj.targetList[creatureName].onlyIfTrapped && !targetingSystemObj.isTrapped) {
            return false
        }

        return true
    }

    /**
    * @return void
    */
    countCreaturesBattleList() {
        if (!IsObject(targetingSystemObj.creaturesDanger)) {
            throw Exception("targetingSystemObj.creaturesDanger doesn't exist")
        }

        if (targetingObj.settings.attackAllMode) {
            this.countCreaturesBattleListByLifeBar()
            return
        }

        t1count := A_TickCount
            , this.creaturesLimitToCount := 20
            , this.creaturesCounted := 0
            , targetingSystemObj.creaturesCount := 0
            , indexCreaturesDanger := 0
            , targetingSystemObj.blockThreadCavebot := true

        this.creatureSearchOrder := 1
        Loop, % targetingSystemObj.creaturesDanger.MaxIndex() {
            index := targetingSystemObj.creaturesDanger.MaxIndex() - indexCreaturesDanger

            if (!targetingSystemObj.creaturesDanger[index]) {
                indexCreaturesDanger++
                continue
            }

            creaturesDangerArray := targetingSystemObj.creaturesDanger[index]
                , indexCreatureSearch := 1
            Loop, % creaturesDangerArray.MaxIndex() {
                creatureName := creaturesDangerArray[indexCreatureSearch]

                if (!this.checkCreatureSearchConditions(creatureName)) {
                    indexCreatureSearch++
                    continue
                }

                try {
                    creatureSearch := new _SearchCreature(creatureName, false)
                } catch e {
                    indexCreatureSearch++
                    writeCavebotLog("ERROR", e.Message . " | " . e.What . " | " . e.Line . " | " . A_ThisFunc)
                    continue
                }

                targetingSystemObj.creaturesCount += creatureSearch.getResultsCount()

                if (targetingSystemObj.creaturesCount >= 8) {
                    break
                }

                this.creaturesCounted++
                if (this.creaturesCounted > this.creaturesLimitToCount) {
                    break
                }

                indexCreatureSearch++
            } ; for

            if (this.creaturesCounted > this.creaturesLimitToCount) {
                break
            }

            if (targetingSystemObj.creaturesCount >= 8) {
                break
            }

            indexCreaturesDanger++
        } ; loop

        targetingSystemObj.creaturesCountElapsed := A_TickCount - t1count
            , targetingSystemObj.blockThreadCavebot := false
    }

    /**
    * @return _UniqueImageSearch
    */
    searchBlackPix() {
        static searchCache
        if (!searchCache) {
            searchCache := new _UniqueImageSearch()
                .setFile("black_pix")
                .setFolder(ImagesConfig.targetingFolder)
                .setArea(new _BattleListPixelArea())
                .setVariation(0)
        }

        targetingSystemObj.blockThreadCavebot := true

        targetingSystemObj.positions.blackPix.x := "", targetingSystemObj.positions.blackPix.y := ""
        try {
            searchCache
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return searchCache
        } finally {
            targetingSystemObj.blockThreadCavebot := false
        }

        targetingSystemObj.positions.blackPix.x := _search.getX()
            , targetingSystemObj.positions.blackPix.y := _search.getY() - 5

        return searchCache
    }

    /**
    * @param string fileName
    * @param int iconNumber
    * @return void
    */
    setStatusBarIcon(fileName, iconNumber) {
        Gui, CavebotLogs:Default
        SB_SetIcon(fileName, iconNumber, targetingPart)
    }

    releaseTargeting()
    {
        if (targetingSystemObj.targetingIgnored.active) {
            if (!CavebotLogsMinimized && !targetingSystemObj.targetingIgnoredIcon) {
                this.setStatusBarIcon(disabledIconDll, 208)
                targetingSystemObj.targetingIgnoredIcon := true
            }

            return false
        }

        if (targetingSystemObj.targetingDisabledAction) {
            if (!CavebotLogsMinimized && !targetingSystemObj.targetingDisabledActionIcon) {
                this.setStatusBarIcon("imageres.dll", 312)
                targetingSystemObj.targetingDisabledActionIcon := true
            }

            return false
        }

        battleListEmpty := new _IsBattleListEmpty()
        /**
        targeting disabled by Action Script
        */
        switch targetingSystemObj.targetingDisabled {
            case true:
                if (!battleListEmpty && targetingSystemObj.isTrapped) {
                    writeCavebotLog("Targeting", "Targeting disabled but trap situation detected, ignoring disabled")
                    return true
                }

                if (!CavebotLogsMinimized && !targetingSystemObj.targetingDisabledIcon) {
                    this.setStatusBarIcon(disabledIconDll, 208)
                    targetingSystemObj.targetingDisabledIcon := true
                }

                return false
        }

        if (cavebotSystemObj.criticalCharPosSearch) {
            writeCavebotLog("Targeting", "Waiting Cavebot thread..", 1)
            return false
        }

        if (new _TargetingSettings().get("huntAssistMode")) {
            redPixFound := new _IsAttacking().found()
            if (!redPixFound)  {
                writeCavebotLog("Targeting", "[Hunt assist mode] Not attacking any creature")
            }

            return redPixFound
        }

        if (targetingSystemObj.luremode.enabled) {
            if (targetingSystemObj.isTrapped) {
                writeCavebotLog("Targeting", "Trap situation detected, ignoring lure mode")
                this.stopLureModeTimerAttack()
                return true
            }

            if (cavebotSystemObj.criticalCharPosSearch) {
                writeCavebotLog("Targeting", "[Lure mode] Waiting Cavebot thread..", 1)
                return false
            }

            if (!this.haveEnoughCreaturesLureMode()) {
                return false
            }

            this.stopLureModeTimerAttack()
        }

        switch (new _TargetingSettings().get("antiKs")) {
            case "Disabled":
                if (battleListEmpty) {
                    writeCavebotLog("Targeting", txt("Battle List vazio", "Battle List empty"))
                    return false
                }
            case "Enabled":
                if (targetingSystemObj.isTrapped) {
                    writeCavebotLog("Targeting", "Trap situation detected, ignoring Anti-KS")
                    return true
                }

                if (!this.checkAntiKsAttacks()) {
                    return false
                }

                /**
                the same action as Enabled, but only if Player battle list is not empty
                */
            case "Player on screen":
                if (targetingSystemObj.isTrapped) {
                    writeCavebotLog("Targeting", "Trap situation detected, ignoring Anti-KS (player on screen mode)")
                    return true
                }
                if (new _SearchPlayersBattleList().notFound()) {
                    if (!this.checkAntiKsAttacks()) {
                        return false
                    }

                    /**
                    if Player battle list is empty, don't release targeting
                    */
                } else {
                    targetingSystemObj.antiKsDetectedAttacks := 0
                    if (new _IsBattleListEmpty()) {
                        writeCavebotLog("Targeting", "Battle list empty")
                        return false
                    }
                }
        } ; switch

        if (isDisconnected()) {
            Sleep, 2000
            writeCavebotLog("Targeting", "Disconnected..")
            return false
        }

        return true
    }

    /**
    * @return bool
    */
    checkAntiKsAttacks()
    {
        if (!this.checkAntiKsBlackPix(true, false, true)) {
            return false
        }

        attacksRelease := this.getAntiKsReleaseAttacks()
        writeCavebotLog("Targeting", "[Anti-KS] Creature attacking, attacks detected: " targetingSystemObj.antiKsDetectedAttacks "/" attacksRelease)
        if (targetingSystemObj.antiKsDetectedAttacks < attacksRelease) {
            return false
        }

        return true
    }

    /**
    * @return bool
    */
    haveEnoughCreaturesLureMode(minimumAmount := false) {
        creaturesCountCondition := targetingSystemObj.luremode.creatures
        if (minimumAmount) {
            if (targetingSystemObj.luremode.creaturesMinimum < 1) {
                return true
            }

            creaturesCountCondition := targetingSystemObj.luremode.creaturesMinimum
        }

        targetingSystemObj.threadLureMode := true
        try  {
            this.countCreaturesBattleList()
        } catch e  {
            writeCavebotLog("ERROR", A_ThisFunc " (1): " e.Message " | " e.What)
        }

        writeCavebotLog("Targeting", "[Lure mode] Creatures on Battle List: " targetingSystemObj.creaturesCount "/" creaturesCountCondition (minimumAmount = true ? " (minimum)" : "") " (" targetingSystemObj.creaturesCountElapsed "ms)")
        targetingSystemObj.threadLureMode := false
        switch minimumAmount {
            case true:
                if (targetingSystemObj.creaturesCount > creaturesCountCondition) {
                    return true
                }

            case false:
                if (targetingSystemObj.creaturesCount >= creaturesCountCondition) {
                    return true
                }
        }

        return false
    }

    antiKsNotBeingAttacked()
    {
        if (_AntiKS.shouldRun()) {
            return _AntiKS.run()
        }

        return this.searchBlackPix().notFound()
    }

    /**
    * @return bool
    */
    checkAntiKsBlackPix(log := true, doubleCheck := true, waitLongerNextCount := false) {
        v := this.antiKsNotBeingAttacked()
        if (v && !doubleCheck) {
            if (log = true) {
                writeCavebotLog("Targeting", "[Anti-KS] No creature attacking")
            }

            return false
        }

        Sleep, 150
        v := this.antiKsNotBeingAttacked()
        if (v) {
            Sleep, 150
            if (this.antiKsNotBeingAttacked()) {
                ; if (log = true)
                writeCavebotLog("Targeting", "[Anti-KS] No creature attacking")
                return false
            }
        }

        targetingSystemObj.antiKsDetectedAttacks++
        /**
        in case need to detect more than 1 attack, need to wait more to not count many attacks at one
        */
        if (waitLongerNextCount && this.getAntiKsReleaseAttacks() > 1) {
            Sleep, 600
        }

        return true
    }

    /**
    * @return int
    */
    distanceFromTarget() {
        return Sqrt(((targetingSystemObj.targetX -CHAR_POS_X)**2)+((targetingSystemObj.targetY-CHAR_POS_Y)**2))
    }

    getSqmDistanceFromTarget() {
        return this.distanceFromTarget() / SQM_SIZE
    }

    /**
    * @return bool
    */
    isAttacking() {
        targetingSystemObj.blockThreadCavebot := true

        try {
            _search := new _IsAttacking()
        } catch e {
            writeCavebotLog("ERROR", e.Message " | " e.What " | redPixel")
            return false
        } finally {
            targetingSystemObj.blockThreadCavebot := false
        }

        targetingSystemObj.redPixelX := _search.getX()
            , targetingSystemObj.redPixelY := _search.getY()

        return _search.found()
    }

    /**
    return the sqm where the creature being attacked is
    */
    getAttackingCreatureSqm()
    {
        if (targetingSystemObj.targetX = "")
            return
        sqmsFound := {}
        Loop, 9 {
            if (A_Index = 5)
                continue
            if (targetingSystemObj.targetX >= SQM%A_Index%X_X1 && targetingSystemObj.targetX <= SQM%A_Index%X_X2)
                    && (targetingSystemObj.targetY >= SQM%A_Index%Y_Y1 && targetingSystemObj.targetY <= SQM%A_Index%Y_Y2) {
                    return A_Index
            }
        }
    }


    getAntiKsReleaseAttacks()
    {
        string := StrSplit(this.iniSettings("antiKsAttacksRelease"), " ")
        return (string.1 < 1) ? 1 : string.1
    }

    iniSettings(key)
    {
        return new _TargetingIniSettings().get(key)
    }

    attackCreature()
    {
        this.runBeforeAttackAction()


        this.targetingAttackLog()

        switch (this.iniSettings("attackMethod")) {
            case _TargetingIniSettings.ATTACK_METHOD_HOTKEY:
                Send(this.iniSettings("attackHotkey"))
                Sleep, % this.delayAfterAttack

                /*
                try a second time if for some reason it failed due to a cooldown or something
                */
                if (new _IsAttacking().notFound()) {
                    Send(this.iniSettings("attackHotkey"))
                    Sleep, 50
                }
            default:
                /**
                in OTClient (Tibijka) need to wait around 200ms to click
                otherwise the click on target wouldn't stick to it
                */
                if (this.targetingJsonObj.options.delayBeforeAttackClick > 1) {
                    Sleep, % this.targetingJsonObj.options.delayBeforeAttackClick
                }


                this.attackWithClick()
                Sleep, % this.delayAfterAttack

                /*
                try a second time if for some reason it failed due to a cooldown or something
                */
                if (new _IsAttacking().notFound()) {
                    this.attackWithClick()
                }
        }

        targetingSystemObj.releaseLootingAfterKillAll := true

        /**
        if attackAll mode, if no creature was found and red pixel was not found after attacked
        it means the first battle position has a player/npc or something else that could not be attacked
        in this case consider the NoCreatureFound and ignore
        */
        this.checkRedPixelAfterAttackOnAttackAllMode()

        this.runAfterAttackAction()
    }

    /**
    * @return void
    */
    attackWithClick()
    {
        /**
        click on the first position of the battle list
        */
        if (jsonConfig("targeting", "options", "pressEscBeforeAttack")) {
            Send("Esc")
            sleep, 200
        }

        try {
            if (_AntiKS.attack()) {
                return
            }
        } catch e {
            if (e.What == "FailedToAttackException") {
                writeCavebotLog("Targeting", "[Anti-KS] " txt("Falha ao atacar criatura, atacando a primeira no Battle List", "Failed to attack creature, attacking the first on Battle List"))
            }
        }

        if (this.currentCreature = "all") {
            this.attackFirstCreature()
        } else {
            MouseClick("Left", targetingSystemObj.creatures[this.currentCreature].x + 5, targetingSystemObj.creatures[this.currentCreature].y + 3)
        }

        this.afterAttackCreatureByClick()

    }

    afterAttackCreatureByClick()
    {
        Sleep, 100
        if (delay := jsonConfig("targeting", "options", "delayAfterAttackClick")) {
            Sleep, % delay
        }

        if (TibiaClient.getClientIdentifier() = "pokexgames") {
            Sleep, 200
        }

        MouseMove(CHAR_POS_X, CHAR_POS_Y)

        Sleep, 50
        if (delay := jsonConfig("targeting", "options", "delayAfterAttackMouseMove")) {
            Sleep, % delay
        }
    }

    attackFirstCreature()
    {
        static battleListArea
        if (!battleListArea) {
            battleListArea := new _BattleListArea()
        }

        battleListArea.getAttackPosition()
        ; .click(button := "Left", repeat := 1, delay := "", debug := true)
            .click()
    }

    attackFirstBattleListCreatureArea()
    {
        static coordinateFirst, coordinateSecond
        if (!coordinateFirst || !coordinateSecond) {
            area := new _BattleListFirstCreatureArea()

            coordinateFirst := new _BattleListFirstCreatureArea().getCoordinates().getCenter()
            coordinateSecond := new _BattleListSecondCreatureArea().getCoordinates().getCenter()
            ; .debug()
        }

        coordinateFirst.click()
    }

    resetTargetPosition() {
        if (this.targetingJsonObj.options.disableCreaturePositionCheck = true)
            return
        targetingSystemObj.targetX := "", targetingSystemObj.targetY := ""
        if (lootingObj.settings.showCreaturePosition = true)
            Gui, TargetAim:Destroy

    }

    creatureNotReachedTimer() {

        this.creatureDistanceSQM := ""
        if (targetingSystemObj.targetX = "") {
            return false
        }

        targetingSystemObj.timers.creatureNotReached.elapsed := (A_TickCount - targetingSystemObj.timers.creatureNotReached.startTimer) / 1000

        ; writeCavebotLog("Targeting", targetingSystemObj.timers.creatureNotReached.elapsed " < " targetingSystemObj.timers.creatureNotReached.duration)

        if (targetingSystemObj.timers.creatureNotReached.elapsed < targetingSystemObj.timers.creatureNotReached.duration)
            return false

        this.creatureDistanceSQM := this.distanceFromTarget() / SQM_SIZE

        this.deleteCreatureNotReachedTimer()
        if (this.creatureDistanceSQM > 2) {
            Send("Esc")

            ; targetingSystemObj.creatures[this.currentCreature].unreachable := true
            seconds := TargetingHandler.getTimeSecondsValue(targetingObj.targetList[this.currentCreature].ignoreIfNotReachedDuration, 2, minValue := 1, maxValue := 120)
            stringIgnore := ""
            if (this.creatureDistanceSQM >= 6) {
                secondsIncrease := (seconds <= 2) ? 2 : 1
                seconds += secondsIncrease
                stringIgnore := ", increased " secondsIncrease " second(s) due to distance"
            }

            this.startIgnoredTargetingTimer("creatureNotReached", this.currentCreature ": " this.creatureDistanceSQM "/2 sqms away" stringIgnore, A_TickCount, seconds, A_ThisFunc)
            return true
        }

        writeCavebotLog("Targeting", "Reach check: """ this.currentCreature """ has been reached, distance: " this.creatureDistanceSQM " sqm(s), checked for: " TargetingHandler.getTimeString(targetingObj.targetList[this.currentCreature].ignoreIfNotReachedTime))
    }

    startCreatureNotReachedTimer() {
        if (targetingSystemObj.timers.creatureNotReached.active = true) OR (targetingObj.targetList[this.currentCreature].ignoreIfNotReached = false)
            return
        targetingSystemObj.timers.creatureNotReached.active := true
        targetingSystemObj.timers.creatureNotReached.startTimer := A_TickCount
        targetingSystemObj.timers.creatureNotReached.duration := TargetingHandler.getTimeSecondsValue(targetingObj.targetList[this.currentCreature].ignoreIfNotReachedTime, 1)
        SetTimer, countCreatureNotReachedTimer, 1000
    }

    deleteCreatureNotReachedTimer() {
        SetTimer, countCreatureNotReachedTimer, Delete
        targetingSystemObj.timers.creatureNotReached.active := false
    }


    getImagesCreaturePositionImages()
    {
        static images
        if (images) {
            return images
        }

        images := {}

        leftRight := A_LoopFileFullPath
        Loop, % this.creaturePositionFolder "\*.png" {
            if (InStr(A_LoopFileName, "_d")) {
                continue
            }
            if (InStr(A_LoopFileName, "5")) {
                continue
            }

            images.Push(A_LoopFileFullPath)
        }

        return images
    }

    creaturePositionImageSearch()
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _MultipleImageSearch(this.getImagesCreaturePositionImages())
                .setFolder(this.creaturePositionFolder)
                .setVariation(this.targetingJsonObj.options.creaturePositionVariation ? this.targetingJsonObj.options.creaturePositionVariation : 0)
                .setTransColor("0")
                .setArea(new _GameWindowArea())
            ; .setDebug()
        }

        return searchCache
    }


    searchCreatureImages()
    {
        t := new _Timer()
        _search := this.creaturePositionImageSearch()
            .search()

        if (!_search.getImageFound()) {
            ; m(t.elapsed(msgbox := false) " found: " _search.getImageFound().getFileName())
            return false
        }


        m(t.elapsed(msgbox := false) " found: " _search.getImageFound().getFileName())
        ; coordinates.moveMouse(false)

        return _search
    }



    getCreaturePosition(ignoreDisabled := false)
    {
        t := new _Timer()
        _search := this.creaturePositionImageSearch(this.getImagesCreaturePositionImages())
            .search()

        if (!_search.getImageFound()) {
            ; m(t.elapsed(msgbox := false) " found: " _search.getImageFound().getFileName())
            return
        }


        ; m(t.elapsed(msgbox := false) " found: " _search.getImageFound().getFileName())
        ; coordinates.moveMouse(false)

        targetX := _search.getX()
            , targetY := _search.getY()
        ; mousemove, windowX + targetX, WindowY + targetY
        ; msgbox, % A_Index
        switch (file := StrReplace(_search.getImageFound().getFileName(), ".png", "")) {
                ; |_
            case "1":
                targetingSystemObj.targetX := targetX + (SQM_SIZE / 2)
                    , targetingSystemObj.targetY := targetY - (SQM_SIZE / 2)
                ; _
                ;  |
            case "2":
                targetingSystemObj.targetX := targetX - (SQM_SIZE / 2)
                    , targetingSystemObj.targetY := targetY + (SQM_SIZE / 2)
                ; _
                ;|
            case "3":
                targetingSystemObj.targetX := targetX + (SQM_SIZE / 2)
                    , targetingSystemObj.targetY := targetY + (SQM_SIZE / 2)
                ; _|
            case "4":
                targetingSystemObj.targetX := targetX - (SQM_SIZE / 2)
                    , targetingSystemObj.targetY := targetY - (SQM_SIZE / 2)
                ; |
            case "5":
                targetingSystemObj.targetX := targetX + (SQM_SIZE / 2)
                    , targetingSystemObj.targetY := targetY
        }

        if ((!A_IsCompiled) || (lootingObj.settings.lootingEnabled = true && lootingObj.settings.showCreaturePosition = true)) && (targetingSystemObj.targetX != "") {
            this.targetAimGui(targetingSystemObj.targetX, targetingSystemObj.targetY)
            ; this.targetAimGui(targetingSystemObj.targetX, targetingSystemObj.targetY, 15, 20, file)
        }
    }

    getCreaturePositionOld(ignoreDisabled := false)
    {
        static searchCache

        if (this.targetingJsonObj.options.disableCreaturePositionCheck && !ignoreDisabled) {
            return
        }

        if (!searchCache) {
            t := this.targetingJsonObj.options.creaturePositionVariation
            ; searchCache := new _UniqueImageSearch() ; changed on 23/01/2025
            searchCache := new _ImageSearch()
                .setFolder(this.creaturePositionFolder)
                .setVariation(this.targetingJsonObj.options.creaturePositionVariation ? this.targetingJsonObj.options.creaturePositionVariation : 0)
                .setTransColor("0")
                .setArea(new _GameWindowArea())
                .setDebug()
        }

        Loop, 5
        {
            try {
                _search := searchCache
                    .setFile(A_Index)
                ; .setDebug()
                    .search()
            } catch e {
                _Logger.exception(e, A_ThisFunc)
                return
            }

            if (A_Index = 5 && _search.notFound()) {
                if (!OldBotSettings.settingsJsonObj.clientFeatures.fullLight) {
                    /**
                    check if is still attacking before searching for the black pixel
                    */
                    if (!this.isAttacking()) {
                        return
                    }

                    return this.searchDarkPixelCreaturePosition()
                }

                return
            }

            if (_search.notFound()) {
                continue
            }

            targetX := _search.getX()
                , targetY := _search.getY()
            ; mousemove, windowX + targetX, WindowY + targetY
            ; msgbox, % A_Index
            switch A_Index {
                    ; |_
                case "1":
                    targetingSystemObj.targetX := targetX + (SQM_SIZE / 2)
                        , targetingSystemObj.targetY := targetY - (SQM_SIZE / 2)
                    ; _
                    ;  |
                case "2":
                    targetingSystemObj.targetX := targetX - (SQM_SIZE / 2)
                        , targetingSystemObj.targetY := targetY + (SQM_SIZE / 2)
                    ; _
                    ;|
                case "3":
                    targetingSystemObj.targetX := targetX + (SQM_SIZE / 2)
                        , targetingSystemObj.targetY := targetY + (SQM_SIZE / 2)
                    ; _|
                case "4":
                    targetingSystemObj.targetX := targetX - (SQM_SIZE / 2)
                        , targetingSystemObj.targetY := targetY - (SQM_SIZE / 2)
                    ; |
                case "5":
                    targetingSystemObj.targetX := targetX + (SQM_SIZE / 2)
                        , targetingSystemObj.targetY := targetY
            }

            if (lootingObj.settings.lootingEnabled = true && lootingObj.settings.showCreaturePosition = true) && (targetingSystemObj.targetX != "") {
                this.targetAimGui(targetingSystemObj.targetX, targetingSystemObj.targetY)
            }

            break
        }
    }

    targetAimGui(x, y, w := 5, h := 5, text := "")
    {
        Gui, TargetAim:+alwaysontop -Caption +toolwindow
        Gui, TargetAim:Color, White
        Gui, TargetAim:Add, Text, x5 y5,% text
        try Gui, TargetAim:Show, % "x" WindowX + X " y" WindowY + y " w" w " h" h " NoActivate",% text
        catch {
        }
    }


    searchDarkPixelCreaturePosition() {
        if (OldBotSettings.settingsJsonObj.clientFeatures.fullLight) {
            return
        }

        /**
        Search darger pixel only in the sqms around character
        */
        Loop, 4
        {
            indexImage := A_Index
                , imageFileName := indexImage "_d"
                , _search := this.searchDarkPixelImage(imageFileName)

            /**
            Search for additional dark images like "3_d_3.png"
            %a%_d_%b%.png
            %a%: image of one of 4 corners
            %b%: sqm number of where the corner image was taken
            */
            if (_search.notFound()) {
                loop, 9 {
                    imgFile := imageFileName "_" A_Index
                    ; msgbox, % ImagesConfig.targetingFolder "\pos\" imgFile
                    if (FileExist(ImagesConfig.targetingFolder "\pos\" imgFile ".png")) {
                        _search := this.searchDarkPixelImage(imgFile)
                        if (_search.found()) {
                            break
                        }
                    }
                }
            }

            if (_search.notFound()) {
                continue
            }

            targetX := _search.getX(), targetY := _search.getY()
            switch indexImage {
                    ; |_
                case "1":
                    targetingSystemObj.targetX := targetX + (SQM_SIZE / 2)
                        , targetingSystemObj.targetY := targetY - (SQM_SIZE / 2)
                    ; _
                    ;  |
                case "2":
                    targetingSystemObj.targetX := targetX - (SQM_SIZE / 2)
                        , targetingSystemObj.targetY := targetY + (SQM_SIZE / 2)
                    ; _
                    ;|
                case "3":
                    targetingSystemObj.targetX := targetX + (SQM_SIZE / 2)
                        , targetingSystemObj.targetY := targetY + (SQM_SIZE / 2)
                    ; _|
                case "4":
                    targetingSystemObj.targetX := targetX - (SQM_SIZE / 2)
                        , targetingSystemObj.targetY := targetY - (SQM_SIZE / 2)
                    ; |
                case "5":
                    targetingSystemObj.targetX := targetX + (SQM_SIZE / 2)
                        , targetingSystemObj.targetY := targetY
            }

            if (lootingObj.settings.showCreaturePosition && targetingSystemObj.targetX) {
                Gui, TargetAim:+alwaysontop -Caption +toolwindow
                Gui, TargetAim:Color, White
                Gui, TargetAim:Add, Text, x5 y5,
                try Gui, TargetAim:Show, % "x" WindowX + targetingSystemObj.targetX " y" WindowY + targetingSystemObj.targetY " w5 h5 NoActivate",
                catch {
                }
            }

            break
        }
    }

    /**
    * @param string fileName
    * @return __UniqueImageSearch
    */
    searchDarkPixelImage(fileName) {
        static searchCache
        if (!searchCache) {
            _Validation.number("SQM_SIZE", SQM_SIZE)
            _Validation.number("SQM7X_X1", SQM7X_X1)
            _Validation.number("SQM3X_X2", SQM3X_X2)

            c1 := new _Coordinate(SQM7X_X1 - (SQM_SIZE / 2), SQM7Y_Y1 - (SQM_SIZE / 2))
            c2 := new _Coordinate(SQM3X_X2 + (SQM_SIZE / 2), SQM3Y_Y2 + (SQM_SIZE / 2))

            searchCache := new _UniqueImageSearch()
                .setFolder(ImagesConfig.targetingFolder "\pos")
                .setVariation(0)
                .setTransColor("0")
                .setCoordinates(new _Coordinates(c1, c2))
        }

        try {
            return searchCache
                .setFile(fileName)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }
    }

    checkRedPixelAfterAttackOnAttackAllMode()
    {
        if (!targetingObj.settings.attackAllMode) {
            return
        }

        if (this.isAttacking()) {
            this.noneFoundAllMode := false
            return
        }

        Sleep, 75
        if (this.isAttacking()) {
            this.noneFoundAllMode := false
        }
    }

    /**
    * @return bool
    */
    checkStopCreatureAttackByLife() {
        static battleListArea
        if (!battleListArea) {
            battleListArea := new _BattleListArea()
        }

        if (this.currentCreature = this.defaultCreature) {
            return true
        }

        if (targetingObj.targetList[this.currentCreature].lifeStopAttack = "----"
            || !targetingObj.targetList[this.currentCreature].lifeStopAttack) {
            return true
        }

        hasLife := this.creatureHasLife(targetingSystemObj.creatures[this.currentCreature].battlePosition, this.getLifePercentString(targetingObj.targetList[this.currentCreature].lifeStopAttack), battleListArea)

        if (!hasLife) {
            this.startIgnoredTargetingTimer("lifeTooLow", this.currentCreature ": life below " targetingObj.targetList[this.currentCreature].lifeStopAttack "%", A_TickCount, 2, "checkBeforeAttack")
            return false
        }

        return true
    }

    /**
    * TODO: refactor remove duplicate code of checkStopCreatureAttackByLife()
    * @return bool
    */
    checkStopAttackingCurrentCreatureLife() {
        static battleListArea
        if (!battleListArea) {
            battleListArea := new _BattleListArea()
        }

        if (this.currentCreature = this.defaultCreature) {
            return true
        }

        if (targetingObj.targetList[this.currentCreature].lifeStopAttack = "----"
            || !targetingObj.targetList[this.currentCreature].lifeStopAttack) {
            return true
        }

        hasLife := this.creatureHasLife(targetingSystemObj.creatures[this.currentCreature].battlePosition, this.getLifePercentString(targetingObj.targetList[this.currentCreature].lifeStopAttack), battleListArea)

        if (!hasLife) {
            Loop, 2 {
                Send("Esc")
            }
            Sleep, 50

            return false
        }

        return true
    }

    /**
    * @return void
    */
    afterCreatureWasKilledActions() {
        static searchCache
        if (!searchCache) {
            searchCache := new _TargetingBase64ImageSearch()
                .setVariation(this.targetingJsonObj.options.searchCreatureVariation)
                .setArea(new _BattleListArea())
        }

        this.resetTargetPosition()
        /**
        actions to do after the creature was killed
        */
        targetingSystemObj.combat.utitoTempoUsed := false
        targetingSystemObj.combat.attackModeChanged := false

        /**
        actions to do after the creature was killed
        AND is not visible on battle list anymore
        */
        unequipItems := false
        if (this.currentCreature = this.defaultCreature) {
            /**
            in attack all mode, consider battle list empty as creature not visible anymore
            */
            if (new _IsBattleListEmpty()) {
                unequipItems := true
            }
        } else {
            try {
                creatureSearch := new _SearchCreature(this.currentCreature)
            } catch e {
                _Logger.exception(e, A_ThisFunc)
            }
            /**
            unequip items if the current creature is not visible anymore
            */
            if (creatureSearch.notFound()) {
                unequipItems := true
            }
        }

        if (unequipItems) {
            this.unequipItemsAfterCreatureIsNotVisibleAnymore()
        }

        /**
        use item on corpse
        */
        if (targetingObj.targetList[this.currentCreature].useItemOnCorpse = 1) {
            hotkeyOrItem := targetingObj.targetList[this.currentCreature].corpseItemHotkey
            if (OldBotSettings.settingsJsonObj.clientFeatures.useItemWithHotkey = false) {
                hotkeyOrItem := targetingObj.targetList[this.currentCreature].itemUseOnCorpse
            }

            this.useItemOnCorpse(this.currentCreature, hotkeyOrItem)
        }

    }

    unequipItemsAfterCreatureIsNotVisibleAnymore() {
        if (targetingObj.targetList[this.currentCreature].ringHotkey != "") && (targetingSystemObj.items.ringEquipped = true)
            this.equipItem("ring", "unequip", targetingObj.targetList[this.currentCreature].ringHotkey)
        if (targetingObj.targetList[this.currentCreature].amuletHotkey != "") && (targetingSystemObj.items.amuletEquipped = true)
            this.equipItem("amulet", "unequip", targetingObj.targetList[this.currentCreature].amuletHotkey)
    }

    beforeEndingTargetingActions()
    {
        this.runAfterStopAttackAction()

        if (lootingObj.settings.lootingEnabled = true) {
            switch lootingObj.settings.lootAfterAllKill {
                case true:
                    if (targetingSystemObj.releaseLootingAfterKillAll = true) {
                        if (lootingObj.settings.lootCreaturesPosition = true) {
                            if (lootingObj.settings.searchCorpseImages = true) {
                                DistanceLooting.addCoordsFromCreatureCorpse()
                            }

                            DistanceLooting.runLootingQueue()
                        } else {
                            try {
                                LootingSystem.lootAroundFromTargeting()
                            } catch e {
                                _Logger.exception(e, A_ThisFunc)
                            }
                        }
                    }
                case false:
                    if (targetingSystemObj.totalCreaturesAttackLooting > 2)
                            && (LootingSystem.lootingJsonObj.options.openCorpsesAround != true)
                        LootingSystem.lootAroundFromTargeting(false)
            }
        }

        _TargetingSystem.resetAttackSpellsTargeting()

        if (this.noneFound = true) {
            this.startIgnoredTargetingTimer("NoCreatureFound", txt("Battle List vazio não encontrado", "Battle List empty not found"), A_TickCount, 2)
        }

        if (this.noneFoundAllMode = true) {
            this.startIgnoredTargetingTimer("NoCreatureFound", "[AllMode] " txt("Battle List vazio não encontrado e nenhuma criatura foi atacada", "Battle List empty not found and no creature was attacked") (" (" this.iniSettings("attackMethod") ")"), A_TickCount, 2)
        }

        if (targetingSystemObj.luremode.timerAttack.enabled = true && targetingSystemObj.luremode.timerAttack.running = false) {
            this.startLureModeTimerAttack()
        }

        IniWrite, 0, %DefaultProfile%, targeting_system, TargetingRunning
    }

    targetingAttackLog()
    {
        if (targetingSystemObj.creatures[this.currentCreature].attacks = "")
            targetingSystemObj.creatures[this.currentCreature].attacks := 0

        targetingSystemObj.creatures[this.currentCreature].attacks++

        dangerString := ", danger: " targetingObj.targetList[this.currentCreature].danger " (" targetingSystemObj.creatures[this.currentCreature].attacks " attacks)"

        switch (this.iniSettings("attackMethod")) {
            case _TargetingIniSettings.ATTACK_METHOD_HOTKEY:
                writeCavebotLog("Targeting", "Attacking """ this.currentCreature """ (hotkey: " this.iniSettings("attackHotkey") ")" dangerString)
            default:
                writeCavebotLog("Targeting", "Attacking """ this.currentCreature """" dangerString)
        }
    }

    /**
    * @return bool
    */
    checkCreatureStopBeforeFirstAttack() {
        static searchCache
        if (!searchCache) {
            searchCache := new _TargetingBase64ImageSearch()
                .setVariation(this.targetingJsonObj.options.searchCreatureVariation)
                .setArea(new _BattleListArea())
        }

        if (targetingObj.settings.attackAllMode = true) {
            return true
        }

        if (!cavebotEnabled && !targetingSystemObj.firstStopAttack) {
            return true
        }

        targetingSystemObj.firstStopAttack := false
        if (this.targetingJsonObj.options.dontPressEscBeforeAttackingFirstTime != true) {
            Send("Esc")
        }

        Sleep, 350

        /**
        search for the creature again, to avoid situations where the creature change position
        in the battle list and the bot missclicks it
        */
        try {
            creatureSearch := searchCache
                .setImage(new _CreatureImage(this.currentCreature))
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }

        if (_search.notFound()) {
            writeCavebotLog("Targeting", "Creature """ this.currentCreature """, not found to attack")
            return false
        }

        targetingSystemObj.creatures[this.currentCreature].x := _search.getX(), targetingSystemObj.creatures[this.currentCreature].y := _search.getY()
        return true
    }

    runBeforeAttackAction()
    {
        if (!waypointsObj.HasKey("Special"))
            return

        ActionScript.runactionwaypoint({1: "BeforeAttack", 2: "Special"}, log := false)
        Sleep, 50 ; little delay otherwise the attack was failing when I was using the `messagebox` action
    }

    runAfterAttackAction() {
        if (!waypointsObj.HasKey("Special"))
            return
        ActionScript.runactionwaypoint({1: "AfterAttack", 2: "Special"}, log := false)
    }

    runAfterStopAttackAction() {
        if (!waypointsObj.HasKey("Special"))
            return
        ActionScript.runactionwaypoint({1: "AfterStopAttack", 2: "Special"}, log := false)
    }

    /**
    * actions that to do after attacking the current monster
    * @return void
    */
    afterAttackCreatureActions() {
        /**
        equip ring / amulet
        */
        doSleep := false
        if (!empty(targetingObj.targetList[this.currentCreature].ringHotkey) && !targetingSystemObj.items.ringEquipped) {
            this.equipItem("ring", "equip", targetingObj.targetList[this.currentCreature].ringHotkey)
            doSleep := true
        }

        if (!empty(targetingObj.targetList[this.currentCreature].amuletHotkey) && targetingSystemObj.items.amuletEquipped) {
            this.equipItem("amulet", "equip", targetingObj.targetList[this.currentCreature].amuletHotkey)
            doSleep := true
        }

        /**
        check/change attack mode
        */
        if (targetingObj.targetList[this.currentCreature].attackMode != "No change" && !empty(targetingObj.targetList[this.currentCreature].attackMode) && !targetingSystemObj.combat.attackModeChanged) {
            this.changeAttackMode(targetingObj.targetList[this.currentCreature].attackMode)
            doSleep := true
        }

        ; /**
        ; check exeta res
        ; */
        if (!empty(targetingObj.targetList[this.currentCreature].exetaResHotkey)) {
            this.useExetaRes(targetingObj.targetList[this.currentCreature].exetaResHotkey, targetingObj.targetList[this.currentCreature].lifeToExetaRes)
            doSleep := true
        }

        if (doSleep) {
            Sleep, 25
        }
    }

    resetAttackSpellsTargeting() {
        targetingSystemObj.attackSpell.spellNumber := 1, targetingSystemObj.releaseExeta := true
    }

    setCurrentCreatureIfNoneFound()
    {
        /**
        if attackAllMode is enabled and no creature was found, set the default creature for "all" mode
        */
        if (!TargetingSystem.currentCreature) && (targetingObj.settings.attackAllMode) {
            if (targetingObj.settings.attackAllMode) {
                this.currentCreature := this.defaultCreature
            }

            if (!targetingSystemObj.creatures[this.currentCreature] && this.currentCreature) {
                targetingSystemObj.creatures[this.currentCreature] := {}
            }
        }
    }

} ; Class
