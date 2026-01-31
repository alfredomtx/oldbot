
Class _SioSystem
{
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    static PLAYER_IMAGE_HEIGHT := 11

    __New()
    {
        if (_SioSystem.INSTANCE) {
            return _SioSystem.INSTANCE
        }

        this.sioBattleList := {}

        this.lifeBarLength := 130

        this.startSioFriendSetup()

        _SioSystem.INSTANCE := this
    }

    startSioFriendSetup()
    {
        try this.sioFriendJsonObj := OldBotSettings.loadModuleJsonSettingsFile("sioFriend")
        catch e {
            Msgbox, 16, % e.What, % e.Message, 30
            ExitApp
        }


        try this.validateSioFriendJsonSettings()
        catch e {
            Msgbox, 16, % e.What, % e.Message, 30
            ExitApp
        }
    }

    checkDefaultJsonCategories()
    {
        this.categories := {}
        this.categories.Push("battleListSetup")
        this.categories.Push("followOptions")
        this.categories.Push("options")

        for key, category in this.categories
        {
            if (!IsObject(this.sioFriendJsonObj[category]))
                this.sioFriendJsonObj[category] := {}

            if (IsObject(category)) {
                for subcategory, subcategories in category
                {
                    if (!IsObject(this.sioFriendJsonObj[subcategory]))
                        this.sioFriendJsonObj[subcategory] := {}
                    for key3, subcategoryName in subcategories
                    {
                        if (!IsObject(this.sioFriendJsonObj[subcategory][subcategoryName]))
                            this.sioFriendJsonObj[subcategory][subcategoryName] := {}
                    }
                }
            }
        }
        ; msgbox, % serialize(this.sioFriendJsonObj["minimap"])
    }

    validateSioFriendJsonSettings()
    {
        if (this.sioFriendJsonObj = "")
            throw Exception("Empty sioFriend.json settings", A_ThisFunc)

        this.checkDefaultJsonCategories()

        this.sioFriendJsonObj.options.playerImageWidth := this.sioFriendJsonObj.options.playerImageWidth = "" ? 80 : this.sioFriendJsonObj.options.playerImageWidth


        this.sioFriendJsonObj.options.enableFollowOption := (this.sioFriendJsonObj.options.enableFollowOption = "" && this.sioFriendJsonObj.options.enableFollowOption != false) ? false : this.sioFriendJsonObj.options.dedicatedSioBattleList
        this.sioFriendJsonObj.options.dedicatedSioBattleList := (this.sioFriendJsonObj.options.dedicatedSioBattleList = "" && this.sioFriendJsonObj.options.dedicatedSioBattleList != false) ? true : this.sioFriendJsonObj.options.dedicatedSioBattleList
        this.sioFriendJsonObj.options.enableAttackRune := (this.sioFriendJsonObj.options.enableAttackRune = "" && this.sioFriendJsonObj.options.enableAttackRune != false) ? true : this.sioFriendJsonObj.options.enableAttackRune


        this.sioFriendJsonObj.battleListSetup.baseImage := this.sioFriendJsonObj.battleListSetup.baseImage = "" ? "battle_list.png" : this.sioFriendJsonObj.battleListSetup.baseImage
        this.sioFriendJsonObj.battleListSetup.baseImageVariation := this.sioFriendJsonObj.battleListSetup.baseImageVariation = "" ? 50 : this.sioFriendJsonObj.battleListSetup.baseImageVariation


        this.sioFriendJsonObj.followOptions.variation := this.sioFriendJsonObj.followOptions.variation = "" ? 40 : this.sioFriendJsonObj.followOptions.variation
        this.sioFriendJsonObj.followOptions.pixelImage := this.sioFriendJsonObj.followOptions.pixelImage = "" ? "following.png" : this.sioFriendJsonObj.followOptions.pixelImage
        this.sioFriendJsonObj.followOptions.pixelImageVariation := this.sioFriendJsonObj.followOptions.pixelImageVariation = "" ? 50 : this.sioFriendJsonObj.followOptions.pixelImageVariation

        this.sioFriendJsonObj.battleListSetup.offsetFromBaseImagePositionX := this.sioFriendJsonObj.battleListSetup.offsetFromBaseImagePositionX = "" ? 0 : this.sioFriendJsonObj.battleListSetup.offsetFromBaseImagePositionX
        this.sioFriendJsonObj.battleListSetup.offsetFromBaseImagePositionY := this.sioFriendJsonObj.battleListSetup.offsetFromBaseImagePositionY = "" ? 0 : this.sioFriendJsonObj.battleListSetup.offsetFromBaseImagePositionY
        this.sioFriendJsonObj.battleListSetup.width := this.sioFriendJsonObj.battleListSetup.width = "" ? 190 : this.sioFriendJsonObj.battleListSetup.width
        this.sioFriendJsonObj.battleListSetup.height := this.sioFriendJsonObj.battleListSetup.height = "" ? 300 : this.sioFriendJsonObj.battleListSetup.height


        this.sioFriendJsonObj.options.playerImageVariation := this.sioFriendJsonObj.options.playerImageVariation = "" ? 50 : this.sioFriendJsonObj.options.playerImageVariation
        if (playerImageLifeBarOffsetX = "") {
            this.sioFriendJsonObj.options.playerImageLifeBarOffsetX := (isTibia13()) ? 1 : 4
        }

        if (this.sioFriendJsonObj.options.debug = true)
            msgbox, % serialize(this.sioFriendJsonObj)

    }

    run() {
        charPosition := new _CharPosition()
        this.settings := new _SioSettings()

        Loop, {
            Sleep, 50

            for sioName, atributes in sioFriendObj
            {
                if (!atributes.enabled) {
                    continue
                }

                this.sioName := sioName

                if (!this.findPlayer()) {
                    if (this.get("followPlayer") && this.isHovering()) {
                        charPosition.getPosition().moveMouse()
                    }

                    Sleep, 50
                    continue
                }

                if (this.get("followPlayer")) {
                    if (this.followPlayer()) {
                        ; Sleep, 50
                        Sleep, 100
                    }
                }

                if (!this.findPlayer()) {
                    Sleep, 50
                    continue
                }

                this.healPlayer()
                this.shootRune()

                Sleep, 100
            }
        }

    }

    /**
    * @return bool
    */
    findPlayer()
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _Base64ImageSearch()
                .setArea(new _SioBattleListArea())
                .setVariation(this.sioFriendJsonObj.options.playerImageVariation)
        }

        this.playerPos := "", this.playerSearch := ""
        try {
            this.playerSearch := searchCache
                .setImage(new _SioImage(this.sioName))
                .search()

            this.playerPos := this.playerSearch.getResult()
        } catch e {
            _Logger.exception(e, A_ThisFunc, this.sioName)
            return false
        }

        return this.playerSearch.found()
    }

    /**
    * @param string name
    * @return mixed
    */
    get(name) {
        return this.settings.get(name, this.sioName)
    }

    /**
    * @param ?bool ignoreCache
    * @return _ImageSearch
    */
    isFollowing(ignoreCache := false)
    {
        static searchCache
        if (!searchCache || ignoreCache) {
            searchCache := new _ImageSearch()
                .setFile(this.sioFriendJsonObj.followOptions.pixelImage)
                .setFolder(ImagesConfig.sioFolder)
                .setVariation(this.sioFriendJsonObj.followOptions.pixelImageVariation)
                .setCoordinates(new _SioBattleListArea().getPixelArea())

            if (ignoreCache && searchCache.search().notFound()) {
                try {
                    return searchCache.setFile("following.png")
                        .search()
                } finally {
                    searchCache.setFile(this.sioFriendJsonObj.followOptions.pixelImage)
                }
            }
        }

        return searchCache.search()
    }
    /**
    * @return _ImageSearch
    */
    isHovering() {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFile("hover")
                .setFolder(ImagesConfig.battleListFolder)
                .setVariation(10)
                .setCoordinates(new _SioBattleListArea().getPixelArea())
        }

        return searchCache
            .search()
            .found()
    }

    /**
    * follow is not working on background because when get bitpmap from hwnd
    * the window with follow options is a different hwnd
    * @return bool
    */
    followPlayer() {
        static charPosition
        if (!charPosition) {
            charPosition := new _CharPosition()
        }

        if (!this.sioFriendJsonObj.options.enableFollowOption) {
            return false
        }

        if (this.isFollowing().found()) {
            return false
        }

        MouseClick("Right", this.playerPos.x + 5, this.playerPos.y + 3)
        Sleep, 50
        charPosition.getPosition().moveMouse()

        Loop 3 {
            Sleep, 100
            try {
                _search := new _ClickOnMenu(_ClickOnMenu.FOLLOW).run()
            } catch e {
                _Logger.exception(e, A_ThisFunc)
                Send("Esc")
                return false
            }

            if (_search.found()) {
                break
            }

            if (_search.notFound() && A_Index = 3) {
                _Logger.error("Follow option not found after " A_Index " tries.", A_ThisFunc, this.sioName)
                Send("Esc")
                return true
            }
        }

        Sleep, 50
        return true
    }

    clickOnPlayer(leftOrRight) {
        MouseClick(leftOrRight, this.playerPos.x + 5, this.playerPos.y + 3)
        Sleep, 35
        MouseMove(this.playerPos.x - 150, this.playerPos.y)
    }

    /**
    * @param int percent
    * @return bool
    */
    playerHasLife(percent)
    {
        static battleListArea
        if (!battleListArea) {
            battleListArea := new _SioBattleListArea()
        }

        try {
            return this.creatureHasLife(percent, battleListArea)
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }

        return false
    }

    /**
    * check if the creature's life is below the specified percent
    * if pixel of position is not one of the life pixels ones
    * @param _Coordinate creatureBattlePosition
    * @param int percent
    * @param _BattleListArea battleListArea
    * @return bool
    */
    creatureHasLife(percent, battleListArea)
    {
        if (empty(percent)) {
            return true
        }

        if (this.targetingJsonObj.options.disableCreatureLifeCheck) {
            return true
        }

        c1 := this.playerPos.CLONE()
            .addX(this.sioFriendJsonObj.options.playerImageLifeBarOffsetX)
            .addY(_SioSystem.PLAYER_IMAGE_HEIGHT)
            .addY(1)
        ; .debug()

        c2 := c1.CLONE()
            .addX(TargetingSystem.targetingJsonObj.battleListSetup.lifeBar.width)
            .addY(5)
        ; .debug()

        position := new _Coordinates(c1, c2)
        ; .debug()

        Distance := position.getX2() - position.getX1()
            , positionBitmap := _BitmapEngine.getClientBitmap(position)


        coord := new _Coordinate(position.getX1(), position.getY1())
            .addX((percent * Distance) / 100)
            .addY(3)
        ; .debug()
            .subX(position.getX1())
            .subY(position.getY1())

        pixColor := positionBitmap.getPixel(coord)
        for _, pixel in TargetingSystem.targetingJsonObj.battleListSetup.lifeBarPixelColors
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

    /**
    * @return bool
    */
    healConditions() {
        if (!HealingSystem.hasLifePercent(this.get("minHealth"))) {
            return false
        }

        if (!HealingSystem.hasManaPercent(this.get("minMana"))) {
            return false
        }

        return !this.hasHealingCooldown()
    }

    /**
    * @return void
    */
    healPlayer() {
        if (!this.healConditions()) {
            return
        }

        if (this.healWithGranSio()) {
            return
        }

        if (this.playerHasLife(this.get("sioLife"))) {
            return false
        }

        if (clientHasFeature("useItemWithHotkey")) {
            this.pressSioFriendHotkey()

            if (!this.get("healWithRune")) {
                return
            }
        } else {
            this.healWithoutHotkey()
        }

        this.clickOnPlayer("Left")
        Sleep, 50

        if (!clientHasFeature("cooldownBar"))
            Sleep, 250
    }

    healWithGranSio() {
        if (this.playerHasLife(this.get("granSioLife"))) {
            return false
        }

        granSioHotkey := this.get("granSioHotkey")
        if (empty(granSioHotkey)) {
            return false
        }

        if (this.hasHealingCooldown()) {
            return false
        }

        hasCooldown := AttackSpell.hasCooldown(0, "", false, false, {"type": "healing", "spell": "exura gran sio"})
        if (hasCooldown) {
            return false
        }

        Send(granSioHotkey)
        Sleep, 35

        return true
    }

    hasHealingCooldown() {
        if (!clientHasFeature("cooldownBar")) {
            return false
        }

        return new _HasCooldown("healing")
    }

    healWithoutHotkey() {
        if (!this.get("healWithRune")) {
            this.pressSioFriendHotkey()
            return
        }


        runeName := this.get("sioRuneName")
        if (empty(runeName)) {
            return
        }

        try {
            _search := new _ItemSearch()
                .setName(runeName)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, runeName)
            return false
        }

        if (_search.notFound()) {
            return
        }

        _search.use()
        Sleep, 35
    }

    pressSioFriendHotkey() {
        Send(this.get("sioHotkey"))

        if (!clientHasFeature("cooldownBar")) {
            Sleep, 250
        }
    }

    /**
    * @return bool
    */
    shootRuneConditions() {
        if (!this.sioFriendJsonObj.options.enableAttackRune) {
            return false
        }

        if (!this.get("useAttackRune")) {
            return false
        }

        if (empty(this.get("attackRuneHotkey"))) {
            return false
        }

        if (new _HasCooldown("attack")) {
            return false
        }

        if (!this.creatureCondition()) {
            return false
        }

        return true
    }

    creatureCondition() {
        if (!this.get("creatureCondition")) {
            return true
        }

        try {
            TargetingSystem.countCreaturesBattleList()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }

        if (targetingSystemObj.creaturesCount < this.get("creatures")) {
            return false
        }

        return true
    }

    shootRune() {
        if (!this.shootRuneConditions()) {
            return
        }

        Send(this.get("attackRuneHotkey"))

        this.clickOnPlayer("Left")
    }
}