
Class _ItemRefillHandler
{
    __New()
    {
        global


        this.loadItemRefillSettings()

    }

    /**
    TO DO: validate hotkeys and percentages on start
    */
    loadItemRefillSettings() {
        global

        this.checkItemRefillDefaultSettings()

    }

    checkItemRefillDefaultSettings() {
        global 

        itemRefillObj.ringRefillEnabled := (itemRefillObj.ringRefillEnabled = "" && itemRefillObj.ringRefillEnabled != false) ? false : itemRefillObj.ringRefillEnabled
        this.checkDefaultItemSettings("ring")


        itemRefillObj.amuletRefillEnabled := (itemRefillObj.amuletRefillEnabled = "" && itemRefillObj.amuletRefillEnabled != false) ? false : itemRefillObj.amuletRefillEnabled
        this.checkDefaultItemSettings("amulet")


        itemRefillObj.bootsRefillEnabled := (itemRefillObj.bootsRefillEnabled = "" && itemRefillObj.bootsRefillEnabled != false) ? false : itemRefillObj.bootsRefillEnabled
        this.checkDefaultItemSettings("boots")

        if (!IsObject(itemRefillObj.quiver))
            itemRefillObj.quiver := {}
        itemRefillObj.quiverRefillEnabled := (itemRefillObj.quiverRefillEnabled = "" && itemRefillObj.quiverRefillEnabled != false) ? false : itemRefillObj.quiverRefillEnabled
        itemRefillObj.quiver.equipMode := (itemRefillObj.quiver.equipMode = "") ? "hotkey" : itemRefillObj.quiver.equipMode
        itemRefillObj.quiver.quiver := (itemRefillObj.quiver.quiver = "") ? "quiver" : itemRefillObj.quiver.quiver

        if (!IsObject(itemRefillObj.distanceWeapon))
            itemRefillObj.distanceWeapon := {}
        itemRefillObj.distanceWeaponRefillEnabled := (itemRefillObj.distanceWeaponRefillEnabled = "" && itemRefillObj.distanceWeaponRefillEnabled != false) ? false : itemRefillObj.distanceWeaponRefillEnabled
        itemRefillObj.distanceWeapon.slot := (itemRefillObj.distanceWeapon.slot = "") ? "hand" : itemRefillObj.distanceWeapon.slot

    }

    checkDefaultItemSettings(item) {

        if (!IsObject(itemRefillObj[item]))
            itemRefillObj[item] := {}


        itemRefillObj[item].emptySlot := (itemRefillObj[item].emptySlot = "" && itemRefillObj[item].emptySlot != false) ? true : itemRefillObj[item].emptySlot
        itemRefillObj[item].unequip := (itemRefillObj[item].unequip = "" && itemRefillObj[item].unequip != false) ? false : itemRefillObj[item].unequip
        itemRefillObj[item].unequipEquipOther := (itemRefillObj[item].unequipEquipOther = "" && itemRefillObj[item].unequipEquipOther != false) ? false : itemRefillObj[item].unequipEquipOther
        itemRefillObj[item].ignoreInPZ := (itemRefillObj[item].ignoreInPZ = "" && itemRefillObj[item].ignoreInPZ != false) ? false : itemRefillObj[item].ignoreInPZ


        itemRefillObj[item].lifeCondition := (itemRefillObj[item].lifeCondition = "" && itemRefillObj[item].lifeCondition != false) ? false : itemRefillObj[item].lifeCondition
        itemRefillObj[item].life := (itemRefillObj[item].life = "") ? 30 : itemRefillObj[item].life
        itemRefillObj[item].life := (itemRefillObj[item].life < 5) ? 5 : itemRefillObj[item].life
        itemRefillObj[item].life := (itemRefillObj[item].life > 99) ? 99 : itemRefillObj[item].life

        itemRefillObj[item].manaCondition := (itemRefillObj[item].manaCondition = "" && itemRefillObj[item].manaCondition != false) ? false : itemRefillObj[item].manaCondition
        itemRefillObj[item].mana := (itemRefillObj[item].mana = "") ? 20 : itemRefillObj[item].mana
        itemRefillObj[item].mana := (itemRefillObj[item].mana < 5) ? 5 : itemRefillObj[item].mana
        itemRefillObj[item].mana := (itemRefillObj[item].mana > 99) ? 99 : itemRefillObj[item].mana

        itemRefillObj[item].lifeConditionUnequip := (itemRefillObj[item].lifeConditionUnequip = "" && itemRefillObj[item].lifeConditionUnequip != false) ? false : itemRefillObj[item].lifeConditionUnequip
        itemRefillObj[item].lifeUnequip := (itemRefillObj[item].lifeUnequip = "") ? 80 : itemRefillObj[item].lifeUnequip
        itemRefillObj[item].lifeUnequip := (itemRefillObj[item].lifeUnequip < 5) ? 5 : itemRefillObj[item].lifeUnequip
        itemRefillObj[item].lifeUnequip := (itemRefillObj[item].lifeUnequip > 99) ? 99 : itemRefillObj[item].lifeUnequip

        itemRefillObj[item].manaConditionUnequip := (itemRefillObj[item].manaConditionUnequip = "" && itemRefillObj[item].manaConditionUnequip != false) ? false : itemRefillObj[item].manaConditionUnequip
        itemRefillObj[item].manaUnequip := (itemRefillObj[item].manaUnequip = "") ? 90 : itemRefillObj[item].manaUnequip
        itemRefillObj[item].manaUnequip := (itemRefillObj[item].manaUnequip < 5) ? 5 : itemRefillObj[item].manaUnequip
        itemRefillObj[item].manaUnequip := (itemRefillObj[item].manaUnequip > 99) ? 99 : itemRefillObj[item].manaUnequip
    }

    submitCheckboxItemRefill(control, value, event := "", ErrLevel := "") {
        if (value = true) {
            OldBotSettings.startFunction("itemRefill", control, startProcess := false, throwE := false, saveJson := true)
            _ItemRefillExe.start()
            return
        }

        OldBotSettings.stopFunction("itemRefill", control, closeProcess := false, saveJson := true)
        _ItemRefillExe.stop()
    }

    saveItemRefill(saveCavebotScript := true) {
        scriptFile.itemRefill := itemRefillObj
        if (saveCavebotScript = true)
            CavebotScript.saveSettings(A_ThisFunc)
    }


}