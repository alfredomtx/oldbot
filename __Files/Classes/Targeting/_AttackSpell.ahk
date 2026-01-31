global spellTimerTrigger

Class _AttackSpell
{

    __New()
    {

        if (!IsObject(TargetingSystem))
            throw Exception("TargetingSystem not initialized.", A_ThisFunc)

        this.cooldownAllSpells.attack := {}
        this.cooldownAllSpells.attack.Push("Default")
        this.cooldownAllSpells.support := {}

        this.triesLimit := 3

        this.spellsTimerCooldown := 0

        this.spells := {}
        /**
        knight
        */
        this.spells.knight := {}
        this.spells.knight.attack := {}
        this.spells.knight.support := {}
        this.spells.knight.attack.Push("Default")
        this.spells.knight.attack.Push("Exori hur")
        this.spells.knight.attack.Push("Exori ico")
        this.spells.knight.attack.Push("Exori gran ico")

        this.spells.knight.attack.Push("Exori")
        this.spells.knight.attack.Push("Exori amp kor")
        this.spells.knight.attack.Push("Exori gran")
        this.spells.knight.attack.Push("Exori mas")
        this.spells.knight.attack.Push("Exori min")
        this.spells.knight.attack.Push("Utori kor")

        this.spells.knight.support.Push("Exeta res")
        this.spells.knight.support.Push("Exeta amp res")
        this.spells.knight.support.Push("Exori kor")
        this.spells.knight.support.Push("Utito tempo")
        this.spells.knight.support.Push("Utamo tempo")
        this.spells.knight.support.Push("Utani tempo hur")


        /**
        paladin
        */
        this.spells.paladin := {}
        this.spells.paladin.attack := {}
        this.spells.paladin.support := {}
        this.spells.paladin.attack.Push("Default")
        this.spells.paladin.attack.Push("Exori san")
        this.spells.paladin.attack.Push("Exori con")
        this.spells.paladin.attack.Push("Exori gran con")
        this.spells.paladin.attack.Push("Exevo mas san")
        this.spells.paladin.attack.Push("Exevo tempo mas san")
        this.spells.paladin.attack.Push("Utori san")

        this.spells.paladin.support.Push("Exevo con")
        this.spells.paladin.support.Push("Exana ina")
        this.spells.paladin.support.Push("Exana amp res")
        this.spells.paladin.support.Push("Utamo tempo san")
        this.spells.paladin.support.Push("Utevo grav san")
        this.spells.paladin.support.Push("Utevo grav san")
        this.spells.paladin.support.Push("Utito tempo san")


        mageCommon := {}
        mageCommon.push("Exori flam")
        mageCommon.push("Exori frigo")
        mageCommon.push("Exori mort")
        mageCommon.push("Exori tera")
        mageCommon.push("Exori vis")
        mageCommon.push("Exori min flam")
        mageCommon.push("Exori infir vis")
        /**
        druid
        */
        this.spells.druid := {}
        this.spells.druid.attack := {}
        this.spells.druid.support := {}
        this.spells.druid.attack.Push("Default")
        this.spells.druid.attack.Push("Exori gran frigo")
        this.spells.druid.attack.Push("Exori gran frigo")
        this.spells.druid.attack.Push("Exori gran tera")
        this.spells.druid.attack.Push("Exori max tera")
        this.spells.druid.attack.Push("Exori max frigo")
        this.spells.druid.attack.Push("Exevo frigo hur")
        this.spells.druid.attack.Push("Exevo infir frigo hur")
        this.spells.druid.attack.Push("Exevo gran frigo hur")
        this.spells.druid.attack.Push("Exevo gran mas frigo")
        this.spells.druid.attack.Push("Exevo gran mas tera")
        this.spells.druid.attack.Push("Exevo ulus tera")
        this.spells.druid.attack.Push("Exevo ulus frigo")

        this.spells.druid.support.Push("Uteta res dru")
        this.spells.druid.support.Push("Utura mas sio")

        for _, spell in mageCommon {
            this.spells.druid.attack.Push(spell)
        }

        /**
        sorcerer
        */
        this.spells.sorcerer := {}
        this.spells.sorcerer.attack := {}
        this.spells.sorcerer.support := {}
        this.spells.sorcerer.attack.Push("Default")
        this.spells.sorcerer.attack.Push("Exori amp vis")
        this.spells.sorcerer.attack.Push("Exori gran vis")
        this.spells.sorcerer.attack.Push("Exori gran flam")
        this.spells.sorcerer.attack.Push("Exori max vis")
        this.spells.sorcerer.attack.Push("Exori max flam")
        this.spells.sorcerer.attack.Push("Exevo flam hur")
        this.spells.sorcerer.attack.Push("Exevo vis lux")
        this.spells.sorcerer.attack.Push("Exevo vis hur")
        this.spells.sorcerer.attack.Push("Exevo gran flam hur")
        this.spells.sorcerer.attack.Push("Exevo gran mas flam")
        this.spells.sorcerer.attack.Push("Exevo gran mas vis")
        this.spells.sorcerer.attack.Push("Utori flam")
        this.spells.sorcerer.attack.Push("Utori mort")
        this.spells.sorcerer.attack.Push("Utori vis")

        this.spells.sorcerer.support.Push("Exori moe")

        for _, spell in mageCommon {
            this.spells.sorcerer.attack.Push(spell)
        }

        this.spellsDropdown := {}
        this.spellsDropdown.all := {}
        this.spellsDropdown.all.attack := "Default||"
        this.spellsDropdown.all.support := ""
        this.spellsDropdown.knight := {}
        this.spellsDropdown.knight.attack := ""
        this.spellsDropdown.knight.support := ""
        this.spellsDropdown.paladin := {}
        this.spellsDropdown.paladin.attack := ""
        this.spellsDropdown.paladin.support := ""
        this.spellsDropdown.druid := {}
        this.spellsDropdown.druid.attack := ""
        this.spellsDropdown.druid.support := ""
        this.spellsDropdown.sorcerer := {}
        this.spellsDropdown.sorcerer.attack := ""
        this.spellsDropdown.sorcerer.support := ""

        for vocation, groups in this.spells
        {
            for group, spells in groups
            {
                for index, spell in spells
                {
                    this.spellsDropdown[vocation][group] .= spell "|" (spell = "Default" ? "|" : "")
                    if (spell = "Default")
                        continue
                    this.spellsDropdown.all[group] .= spell "|"
                }
            }
        }


        ; m(this.spellsDropdown.all.attack)

        this.checkAttackSpells()
    }

    checkAttackSpells() {
        if (!IsObject(targetingObj.targetList))
            throw Exception("targetingObj.targetList not initialized.", A_ThisFunc)

        for creatureName, creatureAtributes in targetingObj.targetList
        {
            for spellNumber, at in creatureAtributes.attackSpells
            {
                ; msgbox, % spellNumber " = " serialize(at)
                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].enabled := empty(at.enabled) ? true : at.enabled
                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].mana := (at.mana < 0 OR at.mana > 99) ? 0 : at.mana
                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].targetLife := (at.targetLife < 0 OR at.targetLife > 100) ? 0 : at.targetLife
                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].cooldown := at.cooldown < 100 ? 100 : at.cooldown
                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].type := at.type = "" ? "Attack" : at.type
                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].supportSpell := at.supportSpell = "" ? "Exeta res" : at.supportSpell
                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].cooldownSpell := at.cooldownSpell = "" ? "Default" : at.cooldownSpell
                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].mode := at.mode < 1 ? 1 : at.mode
                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].turnToDirection := at.turnToDirection = "" ? false : at.turnToDirection
                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].playerSafe := at.playerSafe = "" ? false : at.playerSafe
                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].onlyWithPlayer := at.onlyWithPlayer = "" ? false : at.onlyWithPlayer
                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].countMethod := at.countMethod = "" ? "Battle list" : at.countMethod

                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].countPolicy := at.countPolicy = "" ? "All creatures" : at.countPolicy
                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].countPolicy := (at.countMethod = "Around character") ? "All creatures" : at.countPolicy

                if (creatureName = TargetingSystem.defaultCreature)
                    targetingObj.targetList[creatureName]["attackSpells"][spellNumber].countPolicy := "All creatures"



                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].creatureCount := at.creatureCount = "" ? "Any" : at.creatureCount
                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].mode := (at.mode < 1 OR at.mode > 2) ? 1 : at.mode

                /**
                condition of creature around can only be used with count method "Around character"
                */
                targetingObj.targetList[creatureName]["attackSpells"][spellNumber].mode := (at.countMethod = "Battle list") ? 1 : at.mode
            }

        }

    }

    getSpellAttributes(spellName) {
        if (spellName = "Default" OR spellName = "Attack")
            return {type: "attack", vocation: "none"}

        for _, value in this.spells.knight.attack
        {
            if (spellName = value)
                return {type: "attack", vocation: "knight"}
        }

        for _, value in this.spells.paladin.attack
        {
            if (spellName = value)
                return {type: "attack", vocation: "paladin"}
        }

        for _, value in this.spells.druid.attack
        {
            if (spellName = value)
                return {type: "attack", vocation: "druid"}
        }

        for _, value in this.spells.sorcerer.attack
        {
            if (spellName = value)
                return {type: "attack", vocation: "sorcerer"}
        }

        for _, value in this.spells.knight.support
        {
            if (spellName = value)
                return {type: "support", vocation: "knight"}
        }

        for _, value in this.spells.paladin.support
        {
            if (spellName = value)
                return {type: "support", vocation: "paladin"}
        }

        for _, value in this.spells.druid.support
        {
            if (spellName = value)
                return {type: "support", vocation: "druid"}
        }

        for _, value in this.spells.sorcerer.support
        {
            if (spellName = value)
                return {type: "support", vocation: "sorcerer"}
        }
        return false
    }

    updateSpellListByFilter() {
        Gui, AdvancedSpellGUI:Default
        GuiControlGet, spellFilter
        GuiControlGet, spellType

        vocationFilter := StrReplace(spellFilter, "Filter: ", "")
        if (vocationFilter = "none")
            vocationFilter := "all"

        switch spellType {
            case "Attack":
                GuiControl, AdvancedSpellGUI:, spellCooldownSpell, % "|"
                GuiControl, AdvancedSpellGUI:, spellCooldownSpell, % this.spellsDropdown[vocationFilter].attack
            case "Support":
                GuiControl, AdvancedSpellGUI:, spellSupportSpell, % "|"
                GuiControl, AdvancedSpellGUI:, spellSupportSpell, % this.spellsDropdown[vocationFilter].support
        }
    }

    getSelectedSpell()
    {
        Gui, ListView, LV_Spells

        selectedSpell := LV_GetNext()
        if (selectedSpell = 0)
            return

        selectedSpellName :=  _ListviewHandler.getSelectedItemOnLV("LV_Spells", 3)
        if (selectedSpellName = "" OR selectedSpellName = "Type") {
            Msgbox, 64,, % "Select a spell on the list.", 4
            return
        }

        return selectedSpell
    }

    editAttackSpell() {
        try {
            selectedSpell := this.getSelectedSpell()
        } catch e {
            Msgbox, 64,, % e.Message, 4
            return
        }


        _AttackSpellsGUI.createAdvancedSpellGUI()

        Gui, CavebotGUI:Default
        GuiControlGet, creatureNameSpell

        spell := targetingObj.targetList[creatureNameSpell]["attackSpells"][selectedSpell]

        GuiControlEdit("AdvancedSpellGUI", "spellHotkey", spell.hotkey)
        GuiControlEdit("AdvancedSpellGUI", "spellRune", spell.scriptImage)
        GuiControl, AdvancedSpellGUI:, spellCooldown, % spell.cooldown
        GuiControl, AdvancedSpellGUI:, spellMana, % spell.mana
        GuiControl, AdvancedSpellGUI:, spellTargetLife, % spell.targetLife
        GuiControl, AdvancedSpellGUI:ChooseString, spellType, % spell.type
        GuiControl, AdvancedSpellGUI:ChooseString, spellSupportSpell, % spell.supportSpell
        GuiControl, AdvancedSpellGUI:ChooseString, spellCooldownSpell, % spell.cooldownSpell
        GuiControl, AdvancedSpellGUI:ChooseString, spellCreatureCount, % spell.creatureCount
        _AttackSpellsGUI.sqmDistanceControl.chooseString(spell.sqmDistance = "" ? "Any" : spell.sqmDistance)
        GuiControl, AdvancedSpellGUI:ChooseString, spellCreatureCountMethod, % spell.countMethod
        GuiControl, AdvancedSpellGUI:ChooseString, spellCreatureCountPolicy, % spell.countPolicy
        GuiControl, AdvancedSpellGUI:Choose, spellMode, % spell.mode
        GuiControl, AdvancedSpellGUI:, spellTurnToDirection, % bool(spell.turnToDirection)
        GuiControl, AdvancedSpellGUI:, spellPlayerSafe, % bool(spell.playerSafe)
        GuiControl, AdvancedSpellGUI:, spellOnlyWithPlayer, % bool(spell.onlyWithPlayer)
        GuiControl, AdvancedSpellGUI:, spellAreaRune, % bool(spell.areaRune)
        GuiControl, AdvancedSpellGUI:, spellEnabled, % bool(spell.enabled)

        if (targetingObj.targetList[creatureNameSpell]["attackSpells"][selectedSpell].creatureCount = "Any") {
            GuiControl, AdvancedSpellGUI:Disable, spellCreatureCountMethod
            GuiControl, AdvancedSpellGUI:Disable, spellCreatureCountPolicy
        } else {
            GuiControl, AdvancedSpellGUI:Enable, spellCreatureCountMethod
            GuiControl, AdvancedSpellGUI:Enable, spellCreatureCountPolicy
        }

        if (creatureNameSpell = TargetingSystem.defaultCreature)
            GuiControl, AdvancedSpellGUI:Disable, spellCreatureCountPolicy

        if (targetingObj.targetList[creatureNameSpell]["attackSpells"][selectedSpell].countMethod = "Around character")
            GuiControl, AdvancedSpellGUI:Disable, spellCreatureCountPolicy

        if (targetingObj.targetList[creatureNameSpell]["attackSpells"][selectedSpell].countMethod = "Around character")
            GuiControl, AdvancedSpellGUI:Enable, spellMode

        if (targetingObj.targetList[creatureNameSpell]["attackSpells"][selectedSpell].type = "Attack") {
            GuiControl, AdvancedSpellGUI:Hide, supportSpellText
            GuiControl, AdvancedSpellGUI:Hide, spellSupportSpell
            GuiControl, AdvancedSpellGUI:Show, cooldownSpellText
            GuiControl, AdvancedSpellGUI:Show, spellCooldownSpell
        } else {
            GuiControl, AdvancedSpellGUI:Show, supportSpellText
            GuiControl, AdvancedSpellGUI:Show, spellSupportSpell
            GuiControl, AdvancedSpellGUI:Hide, cooldownSpellText
            GuiControl, AdvancedSpellGUI:Hide, spellCooldownSpell
        }

        this.getSpellDropdownPosition(creatureNameSpell, selectedSpell)
    }

    getSpellDropdownPosition(creatureNameSpell, selectedSpell) {
        Gui, AdvancedSpellGUI:Default
        switch (targetingObj.targetList[creatureNameSpell]["attackSpells"][selectedSpell].type) {
            case "Support":
                spellName := targetingObj.targetList[creatureNameSpell]["attackSpells"][selectedSpell].supportSpell
            default:
                spellName := targetingObj.targetList[creatureNameSpell]["attackSpells"][selectedSpell].cooldownSpell
        }

        spellAttributes := this.getSpellAttributes(spellName)
        if (spellAttributes != false) {
            GuiControl, AdvancedSpellGUI:ChooseString, spellFilter, % "Filter: " spellAttributes.vocation
            GuiControl, AdvancedSpellGUI:ChooseString, spellType, % "Filter: " spellAttributes.type
            this.updateSpellListByFilter()
        }

        ; msgbox, % serialize(spellAttributes) " / " spellName
        switch spellAttributes.vocation {
            case "none":
                for key, value in this.spells.all.attack
                {
                    if (spellName = value) {
                        ; msgbox, % "allSpells / " spellName " / " key
                        GuiControl, AdvancedSpellGUI:Choose, (spellAttributes.type = "Support" ? "spellSupportSpell" : "spellCooldownSpell") , % key
                        return
                    }
                }
            case "knight":
                for key, value in this.spells.knight[spellAttributes.type]
                {
                    if (spellName = value) {
                        GuiControl, AdvancedSpellGUI:Choose, % (spellAttributes.type = "Support" ? "spellSupportSpell" : "spellCooldownSpell") , % key
                        return
                    }
                }
            case "paladin":
                for key, value in this.spells.paladin[spellAttributes.type]
                {
                    if (spellName = value) {
                        ; msgbox, % "paladinSpells / " spellName " / " key
                        GuiControl, AdvancedSpellGUI:Choose, % (spellAttributes.type = "Support" ? "spellSupportSpell" : "spellCooldownSpell") , % key
                        return
                    }
                }
            case "druid":
                for key, value in this.spells.druid[spellAttributes.type]
                {
                    if (spellName = value) {
                        ; msgbox, % "druidSpells / " spellName " / " key
                        GuiControl, AdvancedSpellGUI:Choose, % (spellAttributes.type = "Support" ? "spellSupportSpell" : "spellCooldownSpell") , % key
                        return
                    }
                }
            case "sorcerer":
                for key, value in this.spells.sorcerer[spellAttributes.type]
                {
                    if (spellName = value) {
                        ; msgbox, % "sorcererSpells / " spellName " / " key
                        GuiControl, AdvancedSpellGUI:Choose, % (spellAttributes.type = "Support" ? "spellSupportSpell" : "spellCooldownSpell") , % key
                        return
                    }
                }
        }

    }

    saveSpell(spellNumber := "")
    {
        Gui, CavebotGUI:Default
        Gui, CavebotGUI:Submit, NoHide
        try GuiControlGet, creatureNameSpell
        catch {
        }
        Gui, AdvancedSpellGUI:Default
        Gui, AdvancedSpellGUI:Submit, NoHide
        try GuiControlGet, spellHotkey
        catch {}
            try GuiControlGet, spellCooldown
        catch {}
            try GuiControlGet, spellType
        catch {}
            try GuiControlGet, spellRune
        catch {}
            try GuiControlGet, spellCooldownSpell
        catch {}
            try GuiControlGet, spellSupportSpell
        catch {}
            try GuiControlGet, spellMana
        catch {}
            try GuiControlGet, spellTargetLife
        catch {}
            try GuiControlGet, spellCreatureCount
        catch {}
            try GuiControlGet, spellSqmDistance
        catch {}
            try GuiControlGet, spellCreatureCountMethod
        catch {}
            try GuiControlGet, spellCreatureCountPolicy
        catch {}
            try GuiControlGet, spellMode
        catch {}
            try GuiControlGet, spellTurnToDirection
        catch {}
            try GuiControlGet, spellPlayerSafe
        catch {}
            try GuiControlGet, spellOnlyWithPlayer
        catch {}
            try GuiControlGet, spellAreaRune
        catch {}
            try GuiControlGet, spellEnabled
        catch {}

            if (creatureNameSpell = "")
                throw Exception(LANGUAGE = "PT-BR" ? "Nenhum monstro selecionado." : "No monster selected.")
        switch TargetingSystem.targetingJsonObj.attackSpells.useScriptImageForRunes {
            case true:
                if (spellHotkey = "") && (spellRune = "" OR spellRune = A_Space)
                    throw Exception("You must set the ""Hotkey"" OR the ""Rune"" field.")
            default:
                if (spellHotkey = "")
                    throw Exception(LANGUAGE = "PT-BR" ? "Selecione a hotkey da magia/runa." : "Select the hotkey of the spell/rune.")
        }
        if (spellRune != "") && (spellRune != A_Space) && (!itemsImageObj[spellRune]) {
            ; CavebotGUI.createScriptImagesGUI()
            throw Exception("Rune """ spellRune """ doesn't exist in the ItemList.", "Save Attack Spell")
        }

        vars := ValidateHotkey("AdvancedSpellGUI", "spellHotkey", spellHotkey)
        if (vars["erro"] > 0) {
            spellHotkey := ""
            throw Exception(vars["msg"])
        }
        if (spellType = "Support") && (spellSupportSpell = "") {
            throw Exception(txt("Selecione a magia de Support.", "Select the Support Spell."))
        }

        spellObj := {}
            , spellObj.hotkey := spellHotkey
            , spellObj.type := spellType
            , spellObj.rune := spellRune
            , spellObj.cooldown := spellCooldown += 0
            , spellObj.cooldownSpell := spellCooldownSpell
            , spellObj.supportSpell := spellSupportSpell
            , spellObj.mana := spellMana += 0
            , spellObj.targetLife := spellTargetLife += 0
            , spellObj.creatureCount := spellCreatureCount
            , spellObj.sqmDistance := spellSqmDistance
            , spellObj.countMethod := spellCreatureCountMethod
            , spellObj.countPolicy := spellCreatureCountPolicy
            , spellObj.mode := spellMode  += 0
            , spellObj.turnToDirection := spellTurnToDirection += 0
            , spellObj.playerSafe := spellPlayerSafe += 0
            , spellObj.onlyWithPlayer := spellOnlyWithPlayer += 0
            , spellObj.areaRune := spellAreaRune += 0
            , spellObj.enabled := spellEnabled += 0

        this.addNewSpell(creatureNameSpell, spellObj, spellNumber)
        /**
        if is editing
        */
        if (spellNumber > 0)
            Gui, AdvancedSpellGUI:Destroy
        try TargetingGUI.LoadSpellsLV()
        catch {
        }
    }

    addNewSpell(creatureName, spellObj, spellNumber := "") {
        if (!IsObject(targetingObj.targetList[creatureName]["attackSpells"]))
            targetingObj.targetList[creatureName]["attackSpells"] := {}

        if (spellNumber > 0)
            targetingObj.targetList[creatureName]["attackSpells"][spellNumber] := spellObj
        else
            targetingObj.targetList[creatureName]["attackSpells"].Push(spellObj)

        TargetingHandler.saveTargetList()
    }

    moveSpell(direction) {
        selectedSpell :=  _ListviewHandler.getSelectedItemOnLV("LV_Spells", 1)
        if (selectedSpell = "" OR selectedSpell = "Order") {
            Msgbox, 64,, % "Select a spell on the list.", 4
            return
        }

        GuiControlGet, creatureNameSpell

        spellObjMove := ""
        switch direction {
            case "up":
                if (!targetingObj.targetList[creatureNameSpell].attackSpells.HasKey(selectedSpell - 1))
                    return
                spellObjMove := targetingObj.targetList[creatureNameSpell].attackSpells[selectedSpell]

                targetingObj.targetList[creatureNameSpell].attackSpells[selectedSpell] := targetingObj.targetList[creatureNameSpell].attackSpells[selectedSpell - 1]
                targetingObj.targetList[creatureNameSpell].attackSpells[selectedSpell - 1] := spellObjMove
            default:
                if (!targetingObj.targetList[creatureNameSpell].attackSpells.HasKey(selectedSpell + 1))
                    return
                spellObjMove := targetingObj.targetList[creatureNameSpell].attackSpells[selectedSpell]

                targetingObj.targetList[creatureNameSpell].attackSpells[selectedSpell] := targetingObj.targetList[creatureNameSpell].attackSpells[selectedSpell + 1]
                targetingObj.targetList[creatureNameSpell].attackSpells[selectedSpell + 1] := spellObjMove
        }
        spellObjMove := ""


        TargetingGUI.LoadSpellsLV()
        switch direction {
            case "up":
                _ListviewHandler.selectRow("LV_Spells", selectedSpell - 1)
            default:
                _ListviewHandler.selectRow("LV_Spells", selectedSpell + 1)
        }

        TargetingHandler.saveTargetList()
    }

    deleteSpell() {
        selectedSpell :=  _ListviewHandler.getSelectedItemOnLV("LV_Spells", 1)
        if (selectedSpell = "" OR selectedSpell = "Order") {
            Msgbox, 64,, % "Select a spell on the list.", 4
            return
        }
        GuiControlGet, creatureNameSpell

        targetingObj.targetList[creatureNameSpell]["attackSpells"].RemoveAt(selectedSpell)

        row := _ListviewHAndler.findRowByContent(creatureNameSpell, 1, "LV_CreaturesSpells")
        _ListviewHandler.selectRow("LV_CreaturesSpells", row)

        TargetingGUI.LoadSpellsLV()

        if (selectedSpell = 1)
            _ListviewHandler.selectRow("LV_Spells", selectedSpell)
        else if (selectedSpell > 1)
            _ListviewHandler.selectRow("LV_Spells", selectedSpell - 1)

        TargetingHandler.saveTargetList()
    }

    /**
    loop through spells to find one with condition true
    */
    selectSpellToCast() {
        targetingSystemObj.attackSpell.spellNumber := targetingSystemObj.attackSpell.spellNumber < 1 ? 1 : targetingSystemObj.attackSpell.spellNumber

        /**
        check if targetingSystemObj.attackSpell.spellnumber is higher than the last monster spell
        */
        targetingSystemObj.attackSpell.spellNumber := (targetingSystemObj.attackSpell.spellNumber > targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"].Count()) ? 1 : targetingSystemObj.attackSpell.spellNumber

        /**
        check if the cooldown
        */
        if (!clientHasFeature("cooldownBar")) {
            spellNumber := targetingSystemObj.attackSpell.spellNumber
            spell := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber]
            if (!spell.enabled) {
                return false
            }

            if (this.spellsTimerCooldown >= 1)
                return false
            if (this.spellsTimerCooldown != 0) && (this.spellsTimerCooldown < targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].cooldown)
                return false

            if (jsonConfig("targeting", "options", "disableCreatureLifeCheck")) {
                return true
            }
        }


        if (!TargetingSystem.targetingJsonObj.options.disableCreatureLifeCheck) {
            this.creaturesAround := _TargetingSystem.searchLifeBars()
        }

        for key, _ in targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"]
        {
            if (key < targetingSystemObj.attackSpell.spellNumber) {
                continue
            }

            spell := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][key]
            if (spell.enabled) {
                if (!clientHasFeature("cooldownBar")) {
                    return true
                }
                hasCooldown := this.hasCooldown(key, spell.type, true, log := false)

                /**
                if the spell has only group cooldown, cant skip to next spell
                so break instead of continue
                */
                if (hasCooldown = "groupCooldown") {
                    ; _Logger.out("Spell " key, "Group cooldown not met to cast")
                    break
                }

                if (!hasCooldown) {
                    try {
                        if (this.checkSpellConditions(key)) {
                            targetingSystemObj.attackSpell.spellNumber := key
                            return true
                        }
                    } catch e {
                        _Logger.exception(e, A_ThisFunc)
                        return false
                    }
                }
            }

            /**
            didn't find any spell to cast, in this case reset to number 1
            */
            if (key = targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"].Count()) {
                targetingSystemObj.attackSpell.spellNumber := 1
                ; _Logger.out("Spell " key, "No spell to cast")
                return false
            }

        }

        return false
    }

    checkSpellConditions(spellNumber)
    {
        static sqmsStraight, sqmsUp, sqmsDown, sqmsRight, sqmsLeft
        if (!sqmsStraight || !sqmsUp) {
            sqmsStraight := {1: 2, 2: 4, 3: 6, 4: 8}
            sqmsUp := {1: 7, 2: 8, 3: 9}
            sqmsDown := {1: 1, 2: 2, 3: 3}
            sqmsRight := {1: 9, 2: 6, 3: 3}
            sqmsLeft := {1: 1, 2: 4, 3: 7}
        }

        /**
        commented to not use timer anymore
        */
        spellMode := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].mode

        /**
        check creatures around the char SQM
        */
        if (!this.checkCastSpellSQM(spellMode)) {
            ; _Logger.out("Spell " spellNumber, "No creatures around the character to cast")
            return false
        }

        castSpell := TargetingSystem.checkAttackingCreatureLifePercent(targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].targetLife)
        if (!castSpell) {
            ; _Logger.out("Spell " spellNumber, "Creature life percent condition not met to cast")
            return false
        }

        /**
        checking creature count condition
        */
        if (targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].creatureCount != "Any") {
            castSpell := false

            countMethod := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].countMethod

            switch countMethod {
                case "Battle list":
                    /**
                    if count method is "All creatures", search for all creatures on battle list to count,
                    if is "This creature", search for only the current creature
                    */
                    switch targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].countPolicy {
                        case "All creatures":
                            this.creaturesCount := TargetingSystem.countAllCreaturesBattle()

                        case "This creature":
                            try {
                                creatureSearch := new _SearchCreature(TargetingSystem.currentCreature, false)
                            } catch e {
                                _Logger.exception(e, A_ThisFunc)
                            }

                            this.creaturesCount := creatureSearch.getResultsCount()
                    }

                case "Around character":
                    this.creaturesCount := this.creaturesAround.Count()
            }

            switch targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].creatureCount {
                case "Only 1":
                    if (this.creaturesCount = 1)
                        castSpell := true
                case "1+":
                    if (this.creaturesCount >= 1)
                        castSpell := true
                case "2+":
                    if (this.creaturesCount >= 2)
                        castSpell := true
                case "3+":
                    if (this.creaturesCount >= 3)
                        castSpell := true
                case "4+":
                    if (this.creaturesCount >= 4)
                        castSpell := true
                case "5+":
                    if (this.creaturesCount >= 5)
                        castSpell := true
                case "6+":
                    if (this.creaturesCount >= 6)
                        castSpell := true
                case "7+":
                    if (this.creaturesCount >= 7)
                        castSpell := true
                case "8+":
                    if (this.creaturesCount >= 8)
                        castSpell := true
            }

            if (!castSpell) {
                ; _Logger.out("Spell " spellNumber, "Creature count condition not met to cast: " this.creaturesCount "/" targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].creatureCount)
                return false
            }
        }


        /**
        mana condition
        */
        if (!HealingSystem.hasManaPercent(targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].mana)) {
            ; _Logger.out("Spell " spellNumber, "Mana percent condition not met to cast")
            return false
        }

        if (targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].playerSafe
            OR targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].onlyWithPlayer)
        {
            if (new _SearchPlayersBattleList().found()) {
                if (targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].onlyWithPlayer) {
                    ; _Logger.out("Spell " spellNumber, "Only with player condition not met to cast")
                    return false
                }
            } else {
                if (targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].playerSafe) {
                    ; _Logger.out("Spell " spellNumber, "Player safe condition not met to cast")
                    return false
                }
            }
        }


        /**
        creature count option
        check if there is some monster in the SQMs around
        */
        if (targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].mode = 2) {
            if (this.getCreaturesCountOnSqms(sqmsStraight) < 1) {
                ; _Logger.out("Spell " spellNumber, "No creatures in the straight direction to cast")
                return false
            }
        }

        if (!castSpell) {
            ; _Logger.out("Spell " spellNumber, "No conditions met to cast")
            return false
        }

        /**
        turn to the direction where there are more monsters
        */
        if (targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].turnToDirection = true) {
            directions := {}
                , directions["Up"] := this.getCreaturesCountOnSqms(sqmsUp)
                , directions["Down"] := this.getCreaturesCountOnSqms(sqmsDown)
                , directions["Right"] := this.getCreaturesCountOnSqms(sqmsRight)
                , directions["Left"] := this.getCreaturesCountOnSqms(sqmsLeft)

            /**
            arranging directions order
            */
            Priorities := ""
            for key, value in directions {
                Priorities .= value "_" key ","
            }

            Sort Priorities, N D,  ; Sort numerically, use comma as delimiter.
            PrioritiesArray := StrSplit(Priorities, ",")

            /**
            arrange the directions in descending order
            */
            directions := {}
            Loop, % PrioritiesArray.MaxIndex() {
                directions.Push(PrioritiesArray[PrioritiesArray.MaxIndex()])
                PrioritiesArray.RemoveAt(PrioritiesArray.MaxIndex())
            }

            /**
            get the directions with most creatures, and exclude the others
            */
            topDirections := {}
            index := 0
            for _, value in directions
            {
                if (!value) {
                    continue
                }

                StringTrimLeft, direction, value, 2
                creatures := SubStr(value, 1, 1)

                if (index > 1 && creatures < lastCreatures) {
                    break
                }

                lastCreatures := creatures
                topDirections.Push(direction)
                index++
            }

            /**
            if there is more than 1 sqm to choose, check if some of them is the sqm where the current monster is being attacked
            to give preference to turn towards the current monster
            */
            turnDirection := topDirections[1]
            if (topDirections.Count() > 1) {
                targetSqm := TargetingSystem.getAttackingCreatureSqm()
                for _, value in topDirections {
                    if (this.isSqmAtSpellDirection(targetSqm, value)) {
                        turnDirection := value
                        break
                    }
                }
            }

            SendModifier("Ctrl", turnDirection)
        }


        if (!this.checkCreatureDistance(spellNumber)) {
            ; _Logger.out("Spell " spellNumber, "Creature distance condition not met to cast")
            return false
        }

        return true
    }

    /**
    * @return bool
    */
    checkCreatureDistance(spellNumber)
    {
        distanceCondition := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].sqmDistance

        if (distanceCondition = "Any" || distanceCondition < 1) {
            return true
        }

        distance := TargetingSystem.getSqmDistanceFromTarget()
        if (distance > distanceCondition) {
            return false
        }

        return true
    }

    /**
    * @param array<int> sqms
    * @return int
    */
    getCreaturesCountOnSqms(sqms) {
        count := 0
        for _, SQM in this.creaturesAround
        {
            for _, value in sqms
            {
                if (SQM = value) {
                    count++
                }
            }
        }

        return count
    }

    /**
    * @param int spellMode
    * @return bool
    */
    checkCastSpellSQM(spellMode) {
        static sqmsForSpell
        if (!sqmsForSpell) {
            sqmsForSpell := {1: 2, 2: 4, 3: 6, 4: 8}
        }

        if (spellMode < 2) {
            return true
        }

        if (spellMode != 2) {
            return false
        }

        for _, SQM in this.creaturesAround
        {
            for _, value in sqmsForSpell
            {
                if (SQM = value) {
                    return true
                }
            }
        }

        return false
    }

    /**
    * returns true if the sqm is in the direction
    * @param int sqm
    * @param string direction
    * @return bool
    */
    isSqmAtSpellDirection(SQM, direction) {
        static sqmsUp, sqmsDown, sqmsRight, sqmsLeft
        if (!sqmsUp) {
            sqmsUp := {1: 7, 2: 8, 3: 9}
            sqmsDown := {1: 1, 2: 2, 3: 3}
            sqmsRight := {1: 9, 2: 6, 3: 3}
            sqmsLeft := {1: 1, 2: 4, 3: 7}
        }

        switch direction {
            case "Up":
                for _, value in sqmsUp {
                    if (SQM = value) {
                        return true
                    }
                }
            case "Down":
                for _, value in sqmsDown {
                    if (SQM = value) {
                        return true
                    }
                }
            case "Right":
                for _, value in sqmsRight {
                    if (SQM = value) {
                        return true
                    }
                }
            case "Left":
                for _, value in sqmsLeft {
                    if (SQM = value) {
                        return true
                    }
                }
        }

        return false
    }

    /**
    * @param string image
    * @return bool
    */
    searchCooldownImage(image) {
        static searchCache
        if (!searchCache) {
            searchCache := new _UniqueImageSearch()
                .setFolder(ImagesConfig.cooldownBarFolder)
                .setVariation(50)
                .setArea(new _CooldownBarArea())
        }

        try {
            _search := searchCache
                .setFile(image)
                .search()
        } catch e {
            writeCavebotLog("ERROR", (functionName ": ") e.Message " | " e.What)
        }

        return _search.found()
    }

    hasCooldown(spellNumber, type, returnGroupCooldown := false, log := false, params := "") {
        if (!clientHasFeature("cooldownBar")) {
            return false
        }

        StringLower, type, type

        if (params.type != "")
            type := params.type

        switch type {
            case "Attack", case "Support", case "Healing":
                cooldownSpell := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].cooldownSpell
                if (type = "Support") {
                    cooldownSpell := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].supportSpell
                }

                if (params.spell) {
                    cooldownSpell := params.spell
                }

                /**
                if is an attack spell with the default 2 secs cooldown(no individual higher cooldown)
                example: exori frigo, avalanche rune
                */
                if (type = "Attack" && cooldownSpell = "Default") {
                    return !this.searchCooldownImage(type)
                }

                /**
                search for the spell icon first
                */
                if (this.searchCooldownImage(cooldownSpell)) {
                    return true
                }

                /**
                if didnt find the spell icon, search for the group cooldown
                */
                return this.hasCooldownGroup(type, returnGroupCooldown)

            default:
                writeCavebotLog("ERROR", "Invalid spell type: " type " | " serialize(targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber]))
        }
    }

    hasCooldownGroup(type, returnGroupCooldown := false) {
        hasCooldownGroup := !this.searchCooldownImage(type)
        if (hasCooldownGroup && returnGroupCooldown) {
            hasCooldownGroup := "groupCooldown"
        }

        return hasCooldownGroup
    }

    /**
    * @return void
    */
    pressHotkeyOrThrow(spellNumber, htk)
    {
        if (targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].areaRune) {
            _TargetingSystem.throwAreaRune(htk)
        } else {
            Send(htk)
        }
    }

    castSpell(currentCreature, t1Spell) {
        if (!clientHasFeature("cooldownBar")) {
            this.castTimerSpell(t1Spell)
            return
        }

        if (new _IsAttacking().notFound()) {
            return
        }

        spellNumber := targetingSystemObj.attackSpell.spellNumber
        hotkey := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].hotkey

        this.pressHotkeyOrThrow(spellNumber, hotkey)

        spellType := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].type
        Loop, % this.triesLimit {
            Sleep, 100
            this.castSpellTries := A_Index
            if (this.hasCooldown(spellNumber, spellType)) {
                break
            }

            if (A_Index = this.triesLimit / 2) {
                if (new _IsAttacking().notFound()) {
                    break
                }
            }

            this.pressHotkeyOrThrow(spellNumber, hotkey)
        }

        failed := false
        if (this.castSpellTries = this.triesLimit && !this.hasCooldown(spellNumber, spellType)) {
            failed := true
        }

        switch spellType {
            case "Attack":
                spellTypeLog := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].cooldownSpell = "Default" ? "Attack" : targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].cooldownSpell
            case "Support":
                spellTypeLog := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].supportSpell
        }

        spellHotkey := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].hotkey
            , spellMana := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].mana
            , spellTargetLife := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].targetLife
            , spellTurn := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].turnToDirection
            , spellPlayerSafe := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].onlyWithPlayer
            , spellOnlyWithPlayer := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].playerSafe
            , spellCreatureCount := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].creatureCount
            , spellMethod := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].countMethod
            , spellPolicy := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].countPolicy
            , spellMode := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].mode
            , spellTurn := spellTurn = true ? "true" : "false"
            , spellPlayerSafe := spellPlayerSafe = true ? "true" : "false"
            , spellOnlyWithPlayer := spellOnlyWithPlayer = true ? "true" : "false"

            , elapsedSpell := A_TickCount - t1Spell
            , failedString := failed = false ? "" : "FAILED "

            , stringLog := failedString "Casting spell: " spellNumber "/" targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"].count() " | Hotkey: """ spellHotkey """ | MP: " spellMana  " | HP: " spellTargetLife " | Type: " spellTypeLog " | Creatures: " spellCreatureCount " (" this.creaturesCount ") | Method: " spellMethod " | Policy: " spellPolicy " | Mode: " spellMode " | Turn: " spellTurn " | Player safe: " spellPlayerSafe  " | Only with player: " spellOnlyWithPlayer " | Tries: " AttackSpell.castSpellTries " (" elapsedSpell "ms)"

        writeCavebotLog("Attack Spell", stringLog)
    }

    castTimerSpell(t1Spell)
    {
        spellNumber := targetingSystemObj.attackSpell.spellNumber
        if (!empty(targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].rune)) {
            this.useRuneWithoutHotkey(spellNumber)
        } else {
            ; on 7.4 attack spells cause cooldown on healing items
            if (isTibia74()) {
                this.waitHealingUsingItem()
            }


            Send(targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].hotkey)
        }

        spellTimerTrigger := Func("spellCooldownTimerCounter").bind(targetingSystemObj.attackSpell.spellNumber)
        this.spellsTimerCooldown := 2 ; set a cooldown so it is not zero or empty anymore
        SetTimer, % spellTimerTrigger, Delete
        SetTimer, % spellTimerTrigger, 100

        spellRune := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].rune
            , spellCooldown := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].cooldown
            , spellHotkey := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].hotkey
            , spellCreatureCount := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].creatureCount
            , spellMethod := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].countMethod
            , spellPolicy := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].countPolicy
            , spellMode := targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].mode
            , spellTurn := boolToString(targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].turnToDirection)
        ; , spellPlayerSafe := boolToString(targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].playerSafe)
        ; , spellOnlyWithPlayer := boolToString(targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].onlyWithPlayer)

            , elapsedSpell := A_TickCount - t1Spell

            , stringSpell := (spellRune != "") ? "Rune: """ spellRune """" : "Hotkey: """ spellHotkey """"

            , stringLog := "Casting spell: " spellNumber "/" targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"].count() " | " stringSpell " | Cooldown: " spellCooldown  " | Creatures: " spellCreatureCount " (" this.creaturesCount ") | Method: " spellMethod " | Policy: " spellPolicy " | Mode: " spellMode " | Turn: " spellTurn " | (" elapsedSpell "ms)"

        writeCavebotLog("Attack Spell", stringLog)
    }

    useRuneWithoutHotkey(spellNumber)
    {
        try {
            _search := new _ItemSearch()
                .setName(targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].rune)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].rune)
            return false
        }

        if (_search.notFound()) {
            writeCavebotLog("Attack Spell", "Item """ targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].rune """ not found")
            return
        }

        this.waitHealingUsingItem()

        IniRead, value, %DefaultProfile%, healing_system, UsingItemOnCharacter, 0
        if (value) {
            writeCavebotLog("Attack Spell", "Healing is using item on character, skipping attack rune.")

            return
        }

        _search.use()
        Sleep, 50

        _ := new _IsAttacking()
            .setClickOffsetY(6)
            .click()

        Sleep, 50
        MouseMove(CHAR_POS_X, CHAR_POS_Y)
        Sleep, 50
    }

    waitHealingUsingItem()
    {
        Loop, 3 {
            IniRead, value, %DefaultProfile%, healing_system, UsingItemOnCharacter, 0
            if (!value) {
                break
            }

            writeCavebotLog("Attack Spell", "Waiting healing to finish using item on character..")
            Sleep, 100
        }
    }

    toggleSpell()
    {
        try {
            selectedSpell := this.getSelectedSpell()
        } catch e {
            Msgbox, 64,, % e.Message, 4
            return
        }

        GuiControlGet, creatureNameSpell
        targetingObj.targetList[creatureNameSpell]["attackSpells"][selectedSpell].enabled := !targetingObj.targetList[creatureNameSpell]["attackSpells"][selectedSpell].enabled

        TargetingHandler.saveTargetList()

        try TargetingGUI.LoadSpellsLV()
        catch {
        }
    }
}