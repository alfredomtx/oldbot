global pBitmapQuiverRefill

Class _ItemRefillSystem
{
    __New()
    {
        global

        classLoaded("MemoryManager", MemoryManager)

        this.itemRefillSystemObj := {}

        this.startItemRefillSetup()


        this.animationRings := {}
        this.animationRings.Push("energy ring")
        this.animationRings.Push("life ring")
        this.animationRings.Push("ring of healing")
        this.animationRings.Push("power ring")
        this.animationRings.Push("axe ring")
        this.animationRings.Push("sword ring")
        this.animationRings.Push("club ring")
        this.animationRings.Push("dwarven ring")
        this.animationRings.Push("stealth ring")
        this.animationRings.Push("time ring")


    }

    startItemRefillSetup() {
        this.loadItemRefillJsonSettings()

        try this.validateitemRefillJsonSettings()
        catch e {
            Msgbox, 16, % e.What, % e.Message, 10
            ExitApp
        }


        this.areas := {}
        this.areas.ring := {}
        this.areas.amulet := {}
        this.areas.boots := {}
        this.areas.distanceWeapon := {}

    }


    loadItemRefillJsonSettings() {
        try this.itemRefillJsonObj := OldBotSettings.loadModuleJsonSettingsFile("itemRefill")
        catch e {
            Msgbox, 16, % e.What, % e.Message, 30
            ExitApp
        }
    }

    checkDefaultJsonCategories() {

        this.categories := {}
        this.categories.Push("distanceWeapon")
        this.categories.Push("ring")
        this.categories.Push("amulet")
        this.categories.Push("boots")
        this.categories.Push("options")

        for key, category in this.categories
        {
            if (!IsObject(this.itemRefillJsonObj[category]))
                this.itemRefillJsonObj[category] := {}

            if (IsObject(category)) {
                for subcategory, subcategories in category
                {
                    if (!IsObject(this.itemRefillJsonObj[subcategory]))
                        this.itemRefillJsonObj[subcategory] := {}
                    for key3, subcategoryName in subcategories
                    {
                        if (!IsObject(this.itemRefillJsonObj[subcategory][subcategoryName]))
                            this.itemRefillJsonObj[subcategory][subcategoryName] := {}
                    }
                }
            }
        }
        ; msgbox, % serialize(this.itemRefillJsonObj["minimap"])
    }

    validateitemRefillJsonSettings() {

        if (this.itemRefillJsonObj = "")
            throw Exception("Empty itemRefill.json settings", A_ThisFunc)

        this.checkDefaultJsonCategories()


        this.itemRefillJsonObj.ring.ringSlotImage := this.itemRefillJsonObj.ring.ringSlotImage = "" ? "ring.png" : this.itemRefillJsonObj.ring.ringSlotImage
        this.itemRefillJsonObj.ring.variation := this.itemRefillJsonObj.ring.variation = "" ? 30 : this.itemRefillJsonObj.ring.variation
        this.itemRefillJsonObj.ring.timerIntervalMs := this.itemRefillJsonObj.ring.timerIntervalMs = "" ? 600 : this.itemRefillJsonObj.ring.timerIntervalMs
        this.itemRefillJsonObj.ring.timerIntervalMs := this.itemRefillJsonObj.ring.timerIntervalMs < 400 ? 400 : this.itemRefillJsonObj.ring.timerIntervalMs

        this.itemRefillJsonObj.amulet.amuletSlotImage := this.itemRefillJsonObj.amulet.amuletSlotImage = "" ? "amulet.png" : this.itemRefillJsonObj.amulet.amuletSlotImage
        this.itemRefillJsonObj.amulet.variation := this.itemRefillJsonObj.amulet.variation = "" ? 30 : this.itemRefillJsonObj.amulet.variation
        this.itemRefillJsonObj.amulet.timerIntervalMs := this.itemRefillJsonObj.amulet.timerIntervalMs = "" ? 600 : this.itemRefillJsonObj.amulet.timerIntervalMs
        this.itemRefillJsonObj.amulet.timerIntervalMs := this.itemRefillJsonObj.amulet.timerIntervalMs < 400 ? 400 : this.itemRefillJsonObj.amulet.timerIntervalMs

        this.itemRefillJsonObj.boots.bootsSlotImage := this.itemRefillJsonObj.boots.bootsSlotImage = "" ? "boots.png" : this.itemRefillJsonObj.boots.bootsSlotImage
        this.itemRefillJsonObj.boots.variation := this.itemRefillJsonObj.boots.variation = "" ? 30 : this.itemRefillJsonObj.boots.variation
        this.itemRefillJsonObj.boots.timerIntervalMs := this.itemRefillJsonObj.boots.timerIntervalMs = "" ? 2000 : this.itemRefillJsonObj.boots.timerIntervalMs
        this.itemRefillJsonObj.boots.timerIntervalMs := this.itemRefillJsonObj.boots.timerIntervalMs < 400 ? 400 : this.itemRefillJsonObj.boots.timerIntervalMs


        this.itemRefillJsonObj.distanceWeapon.handImage := this.itemRefillJsonObj.distanceWeapon.handImage = "" ? "hand.png" : this.itemRefillJsonObj.distanceWeapon.handImage
        this.itemRefillJsonObj.distanceWeapon.arrowImage := this.itemRefillJsonObj.distanceWeapon.arrowImage = "" ? "arrow.png" : this.itemRefillJsonObj.distanceWeapon.arrowImage
        this.itemRefillJsonObj.distanceWeapon.variation := this.itemRefillJsonObj.distanceWeapon.variation = "" ? 30 : this.itemRefillJsonObj.distanceWeapon.variation
        this.itemRefillJsonObj.distanceWeapon.timerIntervalMs := this.itemRefillJsonObj.distanceWeapon.timerIntervalMs = "" ? 1000 : this.itemRefillJsonObj.distanceWeapon.timerIntervalMs
        this.itemRefillJsonObj.distanceWeapon.timerIntervalMs := this.itemRefillJsonObj.distanceWeapon.timerIntervalMs < 400 ? 400 : this.itemRefillJsonObj.distanceWeapon.timerIntervalMs

        this.itemRefillJsonObj.quiver.timerIntervalMs := this.itemRefillJsonObj.quiver.timerIntervalMs = "" ? 800 : this.itemRefillJsonObj.quiver.timerIntervalMs
        this.itemRefillJsonObj.quiver.timerIntervalMs := this.itemRefillJsonObj.quiver.timerIntervalMs < 400 ? 400 : this.itemRefillJsonObj.quiver.timerIntervalMs




        if (!FileExist(ImagesConfig.itemRefillFolder "\" this.itemRefillJsonObj.ring.primaryImage))
            throw Exception("ring.primaryImage doesn't exist: " ImagesConfig.itemRefillFolder "\" this.itemRefillJsonObj.ring.primaryImage, A_ThisFunc)

        if (!FileExist(ImagesConfig.itemRefillFolder "\" this.itemRefillJsonObj.amulet.primaryImage))
            throw Exception("amulet.primaryImage doesn't exist: " ImagesConfig.itemRefillFolder "\" this.itemRefillJsonObj.amulet.primaryImage, A_ThisFunc)

        if (!FileExist(ImagesConfig.itemRefillFolder "\" this.itemRefillJsonObj.boots.primaryImage))
            throw Exception("boots.primaryImage doesn't exist: " ImagesConfig.itemRefillFolder "\" this.itemRefillJsonObj.boots.primaryImage, A_ThisFunc)

        this.itemRefillJsonObj.options.equipItemMode := this.itemRefillJsonObj.options.equipItemMode = "" ? "hotkey" : this.itemRefillJsonObj.options.equipItemMode

        this.itemRefillJsonObj.options.loopCountAnimation := this.itemRefillJsonObj.options.loopCountAnimation = "" ? 10 : this.itemRefillJsonObj.options.loopCountAnimation
        this.itemRefillJsonObj.options.loopCountAnimation := this.itemRefillJsonObj.options.loopCountAnimation < 10 ? 10 : this.itemRefillJsonObj.options.loopCountAnimation
        this.itemRefillJsonObj.options.loopCountAnimation := this.itemRefillJsonObj.options.loopCountAnimation > 20 ? 20 : this.itemRefillJsonObj.options.loopCountAnimation


        this.itemRefillJsonObj.options.delayCountAnimation := this.itemRefillJsonObj.options.delayCountAnimation = "" ? 85 : this.itemRefillJsonObj.options.delayCountAnimation
        this.itemRefillJsonObj.options.delayCountAnimation := this.itemRefillJsonObj.options.delayCountAnimation < 50 ? 50 : this.itemRefillJsonObj.options.delayCountAnimation
        this.itemRefillJsonObj.options.delayCountAnimation := this.itemRefillJsonObj.options.delayCountAnimation > 100 ? 100 : this.itemRefillJsonObj.options.delayCountAnimation

        this.itemRefillJsonObj.options.equipItemDelay := this.itemRefillJsonObj.options.equipItemDelay = "" ? 700 : this.itemRefillJsonObj.options.equipItemDelay
        this.itemRefillJsonObj.options.equipItemDelay := this.itemRefillJsonObj.options.equipItemDelay < 100 ? 100 : this.itemRefillJsonObj.options.equipItemDelay
        this.itemRefillJsonObj.options.equipItemDelay := this.itemRefillJsonObj.options.equipItemDelay > 1500 ? 1500 : this.itemRefillJsonObj.options.equipItemDelay


        if (this.itemRefillJsonObj.options.debug = true)
            msgbox, % serialize(this.itemRefillJsonObj)


    }

    checkRefillItem(item) {
        if (!IsObject(this.itemRefillSystemObj[item])) {
            this.itemRefillSystemObj[item] := {}
            this.itemRefillSystemObj[item].equippedOther := false
            this.itemRefillSystemObj[item].mainEquipped := false
        }

        if (this.itemRefillJsonObj.options.equipItemMode = "mouse" && !itemRefillObj[item].itemToEquip) {
            return
        }

        this.itemRefillSystemObj[item].hasToEquipMainItemCondition := this.hasToEquipMainItemCondition(item)
        this.itemRefillSystemObj[item].hasToEquipOtherItemCondition := this.hasToEquipOtherItemCondition(item)

        /**
        * if both conditions are false, do nothing
        */
        if (!this.itemRefillSystemObj[item].hasToEquipOtherItemCondition && !this.itemRefillSystemObj[item].hasToEquipMainItemCondition) {
            return
        }

        /**
        * if main item is equipped and condition to equip other is true, unequip main item first
        */
        if (this.itemRefillSystemObj[item].hasToEquipOtherItemCondition && this.itemRefillSystemObj[item].mainEquipped) {
            this.unequipItemRefill(item, itemRefillObj[item].hotkey)
        }

        if (this.searchEmptySlotItemRefill(item).found()) {
            this.itemRefillSystemObj[item].equippedOther := false
            this.itemRefillSystemObj[item].mainEquipped := false
        }

        /**
        * equip main item
        */
        if (!this.itemRefillSystemObj[item].hasToEquipOtherItemCondition) {
            if (this.itemRefillSystemObj[item].mainEquipped) {
                return
            }

            this.equipItemRefill(item, itemRefillObj[item].hotkey)
            this.itemRefillSystemObj[item].mainEquipped := true
            this.itemRefillSystemObj[item].equippedOther := false
            return
        }

        /**
        * equip other item
        */
        if (!itemRefillObj[item].unequipEquipOther) {
            return
        }

        if (this.itemRefillSystemObj[item].equippedOther) {
            return
        }

        this.equipItemRefill(item, itemRefillObj[item].unequipEquipOtherHotkey)
        this.itemRefillSystemObj[item].equippedOther := true
        this.itemRefillSystemObj[item].mainEquipped := false
    }

    distanceWeaponRefill() {
        static slotImage
        if (!slotImage) {
            slotImage := itemRefillObj.distanceWeapon.slot = "hand" ? this.itemRefillJsonObj.distanceWeapon.leftHandImage : this.itemRefillJsonObj.distanceWeapon.torchImage
        }

        if (!itemRefillObj.distanceWeaponRefillEnabled) {
            return
        }

        try {
            if (this.searchUsedTorch()) {
                return
            }
        } catch e {
            if (e.What = "RefillTorchException") {
                this.equiptemRefill("distanceWeapon", itemRefillObj.distanceWeapon.hotkey, slotImage)
            }

            return
        }


        _search := this.searchEmptySlotItemRefill("distanceWeapon",slotImage )
        if (_search.notFound()) {
            return
        }

        this.equipItemRefill("distanceWeapon", itemRefillObj.distanceWeapon.hotkey, slotImage)
    }

    searchUsedTorch()
    {
        static searchCache

        if (itemRefillObj.distanceWeapon.itemToEquip != "torch") {
            return false
        }

        if (this.useTorchOnSlot()) {
            return true
        }

        if (!searchCache) {
            searchCache := new _ItemSearch()
                .setName("torch used")
                .setArea(new _TorchArea())
                .setDebug(this.itemRefillJsonObj.options.debug)
        }

        try {
            if (searchCache.search().found()) {
                throw Exception("", "RefillTorchException")
            }
        } catch e {
            _Logger.exception(e, A_ThisFunc, "torch")
            throw Exception("", "RefillTorchException")
        }
    }

    useTorchOnSlot()
    {
        static searchCache

        if (!searchCache) {
            searchCache := new _ItemSearch()
                .setName("torch")
                .setArea(new _TorchArea())
                .setDebug(this.itemRefillJsonObj.options.debug)
        }

        _search := searchCache

        if (_search.search().notFound()) {
            return false
        }

        Loop, 2 {
            if (this.itemRefillJsonObj.options.debug) {
                msgbox, using torch
            }

            _search.getResult().click("Right")

            Sleep, % this.itemRefillJsonObj.options.useTorchDelay ? this.itemRefillJsonObj.options.useTorchDelay : 200
            if (_search.search().notFound()) {
                return true
            }
        }

        return false
    }

    quiverRefill()
    {
        static searchCache

        if (!itemRefillObj.quiverRefillEnabled) {
            return
        }

        if (!searchCache) {
            searchCache := new _UniqueImageSearch()
                .setFile(itemRefillObj.quiver.quiver)
                .setFolder(ImagesConfig.itemRefillFolder "\" "quiver")
                .setVariation(50)
                .setArea(new _EquipmentArea())
        }

        try {
            quiverPos := searchCache
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return
        }

        if (quiverPos.notFound()) {
            return
        }

        if (itemRefillObj.quiver.equipMode = "hotkey") {
            Send(itemRefillObj.quiver.ammoHotkey)
            Sleep, 250
            return
        }

        try {
            _search := new _ItemSearch()
                .setName(itemRefillObj.quiver.ammunition)
                .setArea(new _SideBarsArea())
                .setInvertOrder()
                .setOnlyOneSprite()
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }

        if (_search.notFound()) {
            return
        }

        Loop, 4 {
            _search.getResult()
                .drag(quiverPos.getResult())
            Sleep, 250
        }
    }

    /**
    * @return _ImageSearch
    */
    searchEmptySlotItemRefill(item, image := "") {
        try {
            area := new _ClientAreaFactory(this.resolveAreaName(item))
            _search := new _UniqueImageSearch()
                .setFile(image ? image : this.itemRefillJsonObj[item][item "SlotImage"])
                .setFolder(ImagesConfig.itemRefillFolder "\" area.resolveImageFolder())
                .setVariation(this.itemRefillJsonObj[item].variation)
                .setArea(area)
            ; .setDebug(true)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, item)
            return false
        }

        return _search
    }

    /**
    * @param string item
    * @return string
    */
    resolveAreaName(item)
    {
        areaName := item "Area"
        if (item = "distanceWeapon") {
            return itemRefillObj.distanceWeapon.slot = "hand" ? "leftHandArea" : "torchArea"
        }

        return areaName
    }

    equipItemRefill(item, hotkey := "", slotImage := "") {
        if (this.itemRefillJsonObj.options.equipItemMode = "mouse") {
            try {
                _search := new _ItemSearch()
                    .setName(itemRefillObj[item].itemToEquip )
                    .setArea(new _SideBarsArea())
                    .setInvertOrder()
                    .setOnlyOneSprite()
                ; .setDebug(true)

                ; .setLoopCountAnimation(this.itemRefillJsonObj.options.loopCountAnimation)
                    .search()
            } catch e {
                _Logger.exception(e, A_ThisFunc, item)
                return
            }

            if (_search.notFound()) {
                return
            }

            clientArea := new _ClientAreaFactory(this.resolveAreaName(item))

            _search.getResult().drag(new _Coordinate(clientArea.getX1() + 12, clientArea.getY1() + 12), debug := false)

            if (item = "distanceWeapon"
                && !this.itemRefillJsonObj.options.dontPressEnterAfterEquipingDistanceWeapon) {
                Sleep, 25

                Send("Enter")
            }

            return
        }

        this.unequipItemRefill(item, hotkey, slotImage)

        Loop, 2 {
            if (A_Index > 1) {
                if (this.searchEmptySlotItemRefill(item, slotImage).notFound()) {
                    return
                }
            }

            Send(hotkey)
            Sleep, 200

            Loop, 3 {
                if (this.searchEmptySlotItemRefill(item, slotImage).notFound()) {
                    break
                }
                Sleep, 100
            }
        }
    }

    unequipItemRefill(item, hotkey := "", image := "") {
        if (this.itemRefillJsonObj.options.equipItemMode = "mouse") {
            return
        }

        Loop, 2 {
            if (this.searchEmptySlotItemRefill(item, image).found()) {
                return
            }

            Send(hotkey)
            Sleep, 200

            Loop, 3 {
                if (this.searchEmptySlotItemRefill(item, image).found()) {
                    break
                }
                Sleep, 100
            }
        }
    }

    hasToEquipMainItemCondition(item) {
        if (itemRefillObj[item].ignoreInPz) {
            if (isInProtectionZone()) {
                return false
            }
        }

        if (!itemRefillObj[item].lifeCondition && !itemRefillObj[item].manaCondition) {
            return true
        }

        lifeCondition := true
        if (itemRefillObj[item].lifeCondition = true) {
            lifeCondition := !HealingSystem.hasLifePercent(itemRefillObj[item].life)
        }

        manaCondition := true
        if (itemRefillObj[item].manaCondition = true) {
            manaCondition := !HealingSystem.hasManaPercent(itemRefillObj[item].mana)
        }

        return (lifeCondition && manaCondition) ? true : false
    }

    hasToEquipOtherItemCondition(item) {
        if (this.itemRefillJsonObj.options.disableUnequipItem) {
            return false
        }

        if (!itemRefillObj[item].unequip) {
            return false
        }


        if (!itemRefillObj[item].lifeConditionUnequip && !itemRefillObj[item].manaConditionUnequip) {
            return true
        }

        lifeCondition := true
        if (itemRefillObj[item].lifeConditionUnequip) {
            lifeCondition := HealingSystem.hasLifePercent(itemRefillObj[item].lifeUnequip)
        }

        manaCondition := true
        if (itemRefillObj[item].manaConditionUnequip) {
            manaCondition := HealingSystem.hasManaPercent(itemRefillObj[item].manaUnequip)
        }

        return (lifeCondition && manaCondition) ? true : false
    }
} ; Class