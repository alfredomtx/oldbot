Class _TargetingHandler  {

    static TEMP_IMAGE_PATH := A_Temp "\__monster.png"


    __New()
    {
        global

        if (!IsObject(TargetingSystem))
            throw Exception("TargetingSystem not initialized.", A_ThisFunc)


        this.creatureSettings := {}

        /**
        checkboxes
        */
        this.creatureSettings.Push("onlyIftrapped")
        this.creatureSettings.Push("mustAttackMe")
        this.creatureSettings.Push("useItemOnCorpse")
        this.creatureSettings.Push("dontLoot")
        this.creatureSettings.Push("playAlarm")
        ; this.creatureSettings.Push("ignoreUnreachable")
        this.creatureSettings.Push("ignoreAttacking")
        this.creatureSettings.Push("ignoreIfNotReached")
        this.creatureSettings.Push("openBagInsideCorpse")

        /**
        hotkeys
        */
        this.creatureSettings.Push("ringHotkey")
        this.creatureSettings.Push("amuletHotkey")
        this.creatureSettings.Push("utitoTempoHotkey")
        this.creatureSettings.Push("corpseItemHotkey")
        this.creatureSettings.Push("exetaResHotkey")

        /**
        time
        */
        this.creatureSettings.Push("ignoreAfter")
        this.creatureSettings.Push("ignoreAfterTime")
        this.creatureSettings.Push("ignoreIfNotReachedTime")
        this.creatureSettings.Push("ignoreIfNotReachedDuration")
        this.creatureSettings.Push("ignoreDistanceTime")
        this.creatureSettings.Push("ignoreUnreachableTime")
        this.creatureSettings.Push("exetaResCooldown")

        /**
        life
        */
        this.creatureSettings.Push("lifeStopAttack")
        this.creatureSettings.Push("lifeToExetaRes")

        this.creatureSettings.Push("danger")
        this.creatureSettings.Push("stance")
        this.creatureSettings.Push("distance")
        this.creatureSettings.Push("ignoreDistance")
        this.creatureSettings.Push("attackMode")


        /**
        others
        */
        this.creatureSettings.Push("image")
        this.creatureSettings.Push("client")
        this.creatureSettings.Push("timestamp")


        this.loadTargetingSettings()
    }

    loadTargetingSettings() {
        global
        if (!IsObject(targetingObj.settings))
            targetingObj.settings := {}

        if (!IsObject(targetingObj.targetList))
            targetingObj.targetList := {}

        ; msgbox, % clipboard := serialize(targetingObj.targetList)
        this.checkDefaultCreaturesSettings()
        this.checkDefaultTargetingSettings()

        if (this.saveTargetingHandler = true)
            this.saveTargeting()


        ; this.loadCreaturesSettings()
    }

    loadCreaturesSettings(creatureName) {
        global
        CreatureDanger := targetingObj.targetList[creatureName]["danger"]
    }

    checkDefaultCreaturesSettings() {

        this.saveTargetingHandler := false

        if (!targetingObj.targetList.HasKey(TargetingSystem.defaultCreature)) {
            targetingObj.targetList[TargetingSystem.defaultCreature] := {}
        }

        this.checkDefaultMonsterSetting()

        for creatureName, creatureObj in targetingObj.targetList
        {
            /**
            in case the creature name is actually a target setting
            like utitotempohotkey, bug in encrypted scripts don't know why
            */

            invalidCreature := false
            for key, value in this.creatureSettings
            {
                if (value = creatureName) {
                    invalidCreature := true
                    break
                }
            }
            if (invalidCreature = true) {
                targetingObj.targetList.Delete(creatureName)
                ; msgbox, % creatureName "`n`n" serialize(targetingObj.targetList)
                this.saveTargetingHandler := true
                continue
            }

            if (!IsObject(targetingObj.targetList[creatureName])) {
                targetingObj.targetList[creatureName] := {}
            }
            /**
            checkboxes
            */
            targetingObj.targetList[creatureName]["onlyIftrapped"] := this.getCheckboxFalseDefault(targetingObj.targetList[creatureName]["onlyIftrapped"])
            targetingObj.targetList[creatureName]["mustAttackMe"] := this.getCheckboxFalseDefault(targetingObj.targetList[creatureName]["mustAttackMe"])
            targetingObj.targetList[creatureName]["useItemOnCorpse"] := this.getCheckboxFalseDefault(targetingObj.targetList[creatureName]["useItemOnCorpse"])
            targetingObj.targetList[creatureName]["dontLoot"] := this.getCheckboxFalseDefault(targetingObj.targetList[creatureName]["dontLoot"])
            targetingObj.targetList[creatureName]["playAlarm"] := this.getCheckboxFalseDefault(targetingObj.targetList[creatureName]["playAlarm"])
            targetingObj.targetList[creatureName]["creatureopenBagInsideCorpse"] := this.getCheckboxFalseDefault(targetingObj.targetList[creatureName]["creatureopenBagInsideCorpse"])
            ; targetingObj.targetList[creatureName]["ignoreUnreachable"] := this.getCheckboxTrueDefault(targetingObj.targetList[creatureName]["ignoreUnreachable"])
            targetingObj.targetList[creatureName]["ignoreAttacking"] := this.getCheckboxTrueDefault(targetingObj.targetList[creatureName]["ignoreAttacking"])
            targetingObj.targetList[creatureName]["ignoreIfNotReached"] := this.getCheckboxFalseDefault(targetingObj.targetList[creatureName]["ignoreIfNotReached"])

            /**
            hotkeys
            */
            targetingObj.targetList[creatureName]["ringHotkey"] := this.getRingHotkey(targetingObj.targetList[creatureName]["ringHotkey"])
            targetingObj.targetList[creatureName]["amuletHotkey"] := this.getAmuletHotkey(targetingObj.targetList[creatureName]["amuletHotkey"])
            targetingObj.targetList[creatureName]["utitoTempoHotkey"] := this.getUtitoTempoHotkey(targetingObj.targetList[creatureName]["utitoTempoHotkey"])
            targetingObj.targetList[creatureName]["corpseItemHotkey"] := this.getcorpseItemHotkey(targetingObj.targetList[creatureName]["corpseItemHotkey"])
            targetingObj.targetList[creatureName]["itemUseOnCorpse"] := this.getitemUseOnCorpse(targetingObj.targetList[creatureName]["itemUseOnCorpse"])
            targetingObj.targetList[creatureName]["exetaResHotkey"] := this.getExetaResHotkey(targetingObj.targetList[creatureName]["exetaResHotkey"])

            /**
            time
            */
            targetingObj.targetList[creatureName]["exetaResCooldown"] := this.getExetaResCooldown(targetingObj.targetList[creatureName]["exetaResCooldown"])
            targetingObj.targetList[creatureName]["ignoreUnreachableTime"] := this.getIgnoreUnreachableDuration(targetingObj.targetList[creatureName]["ignoreUnreachableTime"])

            targetingObj.targetList[creatureName]["ignoreAfter"]                  := this.getTimeString(targetingObj.targetList[creatureName]["ignoreAfter"]             , 60, minValue := 1, maxValue := 120, debug := false)
            ; msgbox, % creatureName " = " targetingObj.targetList[creatureName]["ignoreIfNotReachedTime"]
            targetingObj.targetList[creatureName]["ignoreIfNotReachedTime"]       := this.getTimeString(targetingObj.targetList[creatureName]["ignoreIfNotReachedTime"]  , 4, minValue := 1, maxValue := 120, debug := false)
            ; msgbox, % creatureName " = " targetingObj.targetList[creatureName]["ignoreIfNotReachedTime"]

            targetingObj.targetList[creatureName]["ignoreDistanceTime"]           := this.getDurationTimeString(targetingObj.targetList[creatureName]["ignoreDistanceTime"]          , 3, minValue := 1, maxValue := 120, debug := false)
            targetingObj.targetList[creatureName]["ignoreAfterTime"]              := this.getDurationTimeString(targetingObj.targetList[creatureName]["ignoreAfterTime"]             , 3, minValue := 1, maxValue := 120, debug := false)
            targetingObj.targetList[creatureName]["ignoreIfNotReachedDuration"]   := this.getDurationTimeString(targetingObj.targetList[creatureName]["ignoreIfNotReachedDuration"]  , 2, minValue := 1, maxValue := 120, debug := false)

            /**
            life
            */
            targetingObj.targetList[creatureName]["lifeStopAttack"] := this.getLifeStopAttack(targetingObj.targetList[creatureName]["lifeStopAttack"])
            targetingObj.targetList[creatureName]["lifeToExetaRes"] := this.getLifeToExetaRes(targetingObj.targetList[creatureName]["lifeToExetaRes"])

            targetingObj.targetList[creatureName]["danger"] := this.getDanger(targetingObj.targetList[creatureName]["danger"])
            targetingObj.targetList[creatureName]["stance"] := this.getStance(targetingObj.targetList[creatureName]["stance"])
            targetingObj.targetList[creatureName]["distance"] := this.getDistance(targetingObj.targetList[creatureName]["distance"])
            targetingObj.targetList[creatureName]["ignoreDistance"] := this.getIgnoreDistance(targetingObj.targetList[creatureName]["ignoreDistance"])
            targetingObj.targetList[creatureName]["attackMode"] := this.getAttackMode(targetingObj.targetList[creatureName]["attackMode"])

            if (!targetingObj.targetList[creatureName]["attackSpells"])
                targetingObj.targetList[creatureName]["attackSpells"] := {}

        }

    }

    checkDefaultMonsterSetting() {
        targetingObj.targetList[TargetingSystem.defaultCreature]["onlyIftrapped"] := false
        targetingObj.targetList[TargetingSystem.defaultCreature]["lifeStopAttack"] := "----"
    }

    checkDefaultTargetingSettings() {
        /**
        if there is no battle list button validation image to check the proper functioning of the attack all mode
        set the default value as false(old tibia ots)
        */
        defaultAttackAllModeValue := true
        if (TargetingSystem.targetingJsonObj.battleListImages.battleListButtonsVisible = ""
            OR !FileExist(ImagesConfig.battleListButtonsFolder "/" TargetingSystem.targetingJsonObj.battleListImages.battleListButtonsVisible)) {

            defaultAttackAllModeValue := false
        }

        targetingObj.settings.attackAllMode := (!targetingObj.settings.attackAllMode && targetingObj.settings.attackAllMode != false) ? defaultAttackAllModeValue : targetingObj.settings.attackAllMode
    }


    submitTargetingSetting(control, value, event := "", ErrLevel := "") {
        ; msgbox, % control " / " value
        _GuiHandler.submitSetting("targeting", "settings/" control, value)
    }

    submitCheckboxTargeting(control, value, event := "", ErrLevel := "") {
        value += 0
        ; msgbox, % control " / " value
        _GuiHandler.submitSetting("targeting", "settings/" control, value)
    }

    submitTargetingSettingOption() {
        Gui, CavebotGUI:Default
        Gui, CavebotGUI:Submit, NoHide

        ; msgbox, %  A_ThisFunc "`n" Control " / " A_GuiControl " / " validate

        try value := %A_GuiControl%
        catch
            throw Exception("Error submiting for Support option value.")

        if (InStr(A_GuiControl, "Hotkey")) {
            try HealingHandler.validateHealingHotkey(A_GuiControl, value)
            catch e {
                throw e
            }
        }

        targetingObj.settings[A_GuiControl] := value
        this.saveTargetingSettings(A_ThisFunc)
    }

    submitTargetOption() {
        Gui, CavebotGUI:Default
        Gui, CavebotGUI:Submit, NoHide

        GuiControlGet, creatureName

        if (creatureName = "")
            throw Exception("No creature selected.`n`n" A_GuiControl)

        option := StrReplace(A_GuiControl, "creature", "")

        if (option = "")
            throw Exception("Empty option.")

        try
            value := %A_GuiControl%
        catch
            throw Exception("Error submiting value.")

        ; msgbox, % creatureName ": " option " = " value

        this.setCreatureOption(creatureName, option, value)

        switch option {
            case "Danger":
                check_control := Func("CheckEditValue").bind("creatureDanger", 1, 9, "CavebotGUI")
                SetTimer, % check_control, Delete
                SetTimer, % check_control, -700
                TargetingGUI.loadTargetListLV()

            case "ignoreAttacking":
                if (value = 1) {
                    GuiControl, CavebotGUI:Enable, creatureIgnoreAfter
                    GuiControl, CavebotGUI:Enable, creatureIgnoreAfterTime
                }
                else{
                    GuiControl, CavebotGUI:Disable, creatureIgnoreAfter
                    GuiControl, CavebotGUI:Disable, creatureIgnoreAfterTime
                }
            case "ignoreUnreachable":
                if (value = 1)
                    GuiControl, CavebotGUI:Enable, creatureIgnoreUnreachableTime
                else
                    GuiControl, CavebotGUI:Disable, creatureIgnoreUnreachableTime
            case "useItemOnCorpse":
                if (value = 1) {
                    if (OldBotSettings.settingsJsonObj.clientFeatures.useItemWithHotkey = true) {
                        msgbox, 64,, % txt("ATENÇÃO: É necessário configurar a imagem do corpo dos monstros em Script Images com a categoria ""corpse"" para funcionar.`n`nAssista o tutorial de como configurar a imagem no menu superior Tutoriais -> Targeting -> User item no corpo", "ATTENTION: It is needed to setup the image of the monster corpses on Script Images with the ""corpse"" category for it to work.`n`nWatch the tutorial about how to set up the image on the top menu Tutoriais -> Targeting -> User item no corpo (Portuguese tutorial)"), 20
                    }
                    try GuiControl, CavebotGUI:Enable, creatureCorpseItemHotkey
                    catch {
                    }
                    try GuiControl, CavebotGUI:Enable, creatureitemUseOnCorpse
                    catch {
                    }
                }
                else {
                    try GuiControl, CavebotGUI:Disable, creatureCorpseItemHotkey
                    catch {
                    }
                    try GuiControl, CavebotGUI:Disable, creatureitemUseOnCorpse
                    catch {
                    }
                }
            case "onlyIftrapped":
                TargetingGUI.loadTargetListLV()
        }

    }

    setCreatureOption(creatureName, option, value := "") {

        for key, setting in TargetingGUI.checkboxList
        {
            if (value = "")
                break
            if (option = setting) {
                value += 0
                break
            }
        }

        targetingObj.targetList[creatureName][option] := value
        this.saveTargetList(A_ThisFunc)
    }

    setAntiKS() {
        Gui, CavebotGUI:Default
        GuiControlGet, antiKS
        targetingObj.settings.antiKS := antiKS += 0
        this.saveTargetingSettings(A_ThisFunc)
    }

    validateDanger(danger) {

    }

    getCheckboxFalseDefault(value) {
        if (value = "" && value != false)
            value := 0
        return value += 0
    }

    getCheckboxTrueDefault(value) {
        if (value = "" && value != false)
            value := 1
        return value += 0
    }

    getStance(stance) {
        if (stance = "")
            return "No change"
        return stance
    }

    getIgnoreDistance(ignoreDistance) {
        if (ignoreDistance = "")
            return "None"
        ; return "6+ sqms"
        return ignoreDistance
    }

    getTimeString(timeString, defaultValue := 3, minValue := 1, maxValue := 120, debug := false) {
        ; msgbox, % A_ThisFunc "`n" timeString "`n" duration "`n" seconds

        seconds := this.getTimeSecondsValue(timeString, 1, minValue, maxValue, defaultValue)
        duration := seconds (seconds = 1 ? " second" : " seconds")
        ; msgbox, % A_ThisFunc "`n" timeString "`n" duration "`n" seconds

        if (seconds < minValue)
            duration := minValue " " (minValue = 1 ? "second" : "seconds")
        if (seconds > maxValue)
            duration := maxValue " seconds"
        ; msgbox, % A_ThisFunc "`n" timeString "`n" duration "`n" seconds
        return duration
    }

    getDurationTimeString(timeString, defaultValue := 3, minValue := 1, maxValue := 120, debug := false) {
        ; if (debug)
        ; msgbox, % A_ThisFunc "`n" timeString "`ndefaultValue = " defaultValue

        seconds := this.getTimeSecondsValue(timeString, 2, minValue, maxValue, defaultValue, debug)
        duration := "for " seconds " " (seconds = 1 ? "second" : "seconds")
        if (debug)
            msgbox, % A_ThisFunc "`n#1#" "`n" timeString "`n" seconds "`n" duration

        if (seconds < minValue)
            duration := "for " minValue " " (minValue = 1 ? "second" : "seconds")
        if (seconds > maxValue)
            duration := "for " maxValue " seconds"
        if (debug)
            msgbox, % A_ThisFunc "`n#2#" "`n" timeString "`n" seconds "`n" duration
        return duration
    }

    getTimeSecondsValue(timeString, position, minValue := 1, maxValue := 120, defaultValue := 3, debug := false) {
        string := StrSplit(timeString, " ")
            , seconds := string[position]

        if (seconds = "")
            seconds := defaultValue
        if seconds is not number
            seconds := defaultValue
        if (seconds < minValue)
            seconds := minValue
        if (seconds > maxValue)
            seconds := maxValue
        if (debug)
            msgbox, % A_ThisFunc "`n" timeString "`n" serialize(string) "`nposition = " position "`ndefaultValue = " defaultValue "`nminValue = " minValue "`nmaxValue = " maxValue "`nseconds = " seconds
        return seconds
    }

    getIgnoreUnreachableDurationSeconds(ignoreUnreachableTime) {
        string := StrSplit(ignoreUnreachableTime, " ")
        return string.3
    }

    getIgnoreUnreachableDuration(ignoreUnreachableTime) {

        string := StrSplit(ignoreUnreachableTime, " ")

        seconds := this.getTimeSecondsValue(ignoreUnreachableTime, 3, minValue := 1, maxValue := 120)
        if (seconds = "" OR seconds < 1)
            return "ignore for 5 seconds"
        if (seconds > 120)
            return "ignore for 60 seconds"
        return ignoreUnreachableTime
    }

    getExetaResCooldown(exetaResCooldown) {
        string := StrSplit(exetaResCooldown, " ")
        exetaResCooldownSeconds := string.1
        if (exetaResCooldownSeconds = "" OR exetaResCooldownSeconds < 1)
            return "6 seconds"
        if (exetaResCooldownSeconds > 8)
            return "8 seconds"
        return exetaResCooldown
    }

    getDistance(distance) {
        if (distance = "")
            return "3 sqms"
        ; return distance
        return "----"
    }

    getAttackMode(attackMode) {
        if (attackMode = "")
            return "No change"
        return attackMode
    }

    getLifeStopAttack(lifeStopAttack) {
        if (!InStr(lifeStopAttack, "%"))
            return "----"
        return lifeStopAttack
    }

    getLifeToExetaRes(lifeToExetaRes) {
        if (!InStr(lifeToExetaRes, "%"))
            return "----"
        return lifeToExetaRes
    }

    getRingHotkey(ringHotkey) {
        return this.getHotkey(ringHotkey)
    }

    getAmuletHotkey(amuletHotkey) {
        return this.getHotkey(amuletHotkey)
    }

    getUtitoTempoHotkey(utitoTempoHotkey) {
        return this.getHotkey(utitoTempoHotkey)
    }

    getCorpseItemHotkey(corpseItemHotkey) {
        return this.getHotkey(corpseItemHotkey)
    }

    getItemUseOnCorpse(itemUseOnCorpse) {
        return this.getHotkey(itemUseOnCorpse)
    }

    getExetaResHotkey(exetaResHotkey) {
        return this.getHotkey(exetaResHotkey)
    }

    getHotkey(hotkey) {
        if (hotkey = "") ; must return if empty, otherwise is throwing error "Compile error 9 at offset 3: nothing to repeat."
            return
        try {
            if (RegExMatch(hotkey,"(^|+|!|#)")) ; remove hotkeys with modifiers
                return
        } catch {
        }
        return hotkey

    }


    getDanger(danger) {
        if (danger < 1)
            return 1
        if (danger > 9)
            return 9
        return danger += 0
    }


    getIgnoreAfter(ignoreAfter) {
        ignoreAfter := LTrim(RTrim(ignoreAfter))
        if (InStr(ignoreAfter, "seconds")) {
            string := StrSplit(ignoreAfter, "seconds")
            ignoreAfter := LTrim(RTrim(string.1))
        }
        if (InStr(ignoreAfter, " ")) {
            string := StrSplit(ignoreAfter, " ")
            ignoreAfter := LTrim(RTrim(string.1))
        }
        if ignoreAfter is not number
            ignoreAfter := 60
        if (ignoreAfter < 1 OR ignoreAfter > 999)
            ignoreAfter := 60
        return ignoreAfter " seconds"
    }

    removeFromTargetList()
    {
        try
            selectedCreatures := _ListviewHandler.getSelectedRowsLV("LV_Creatures", 1)
        catch
            throw Exception("Select at least one creature in the list.")

        if (_A.first(selectedCreatures) == TargetingSystem.defaultCreature) {
                new _TargetingSettingsGUI().open()
            msgbox, 64,, % txt("Não é possível remover a criatura ""all"" da lista, para desativar o ataque a todas as criaturas, desmarque a opção ""Modo de ataque All(todos)"" nas Configurações do Targeting.", "It is not possible to remove the ""all"" creature from the list, to disable the attack of all creatures, uncheck the ""Attack all mode"" option in the Targeting settings.")
            return
        }


        OldBotSettings.disableGuisLoading()

        for row, name in selectedCreatures
            targetingObj.targetList.Delete(name)


        if (targetingObj.targetList.Count() < 1)
            TargetingGUI.changeAllControls("Disable")

        this.saveTargetList(A_ThisFunc)
        TargetingGUI.loadTargetListLV()
        TargetingGUI.loadTargetListLV(true)
        OldBotSettings.enableGuisLoading()
    }

    addToTargetList(selectedCreatures := "")
    {
        if (!selectedCreatures) {
            try {
                selectedCreatures := _ListviewHandler.getSelectedRowsLV("LV_CreatureList", 2, "AddCreatureGUI")
            } catch {
                throw Exception("Select at least one creature in the list.")
            }
        }

        /**
        - atributes
        name
        category: gold | stackable | nonstackable
        */
        OldBotSettings.disableGuisLoading()

        currentClient := TibiaClient.getClientIdentifier()
        creaturesCounter := 0
        for row, name in selectedCreatures
        {
            if (creaturesCounter > 20)
                break

            creatureObj := {}
            creatureObj.danger := 1
                , creatureObj.image := ""


            if (customCreaturesImageFile) && (customCreaturesImageObj[creatureName].image != "") {
                creatureObj.client := currentClient
                creatureObj.image := customCreaturesImageObj[name].image

            } else if (creaturesImageObj[name].image != "") {
                ; if (creaturesImageObj[name].client = currentClient)
                creatureObj.image := creaturesImageObj[name].image
            }


            targetingObj.targetList[name] := creatureObj
                , creaturesCounter++
        }

        this.checkDefaultCreaturesSettings()


        this.saveTargetList(A_ThisFunc)
        TargetingGUI.loadTargetListLV()
        TargetingGUI.loadTargetListLV(true)

        OldBotSettings.enableGuisLoading()



        if (targetingObj.targetList.Count() > 20) {
            Msgbox, 48,,% LANGUAGE = "PT-BR" ? "ATENÇÃO! Não é recomendado adicionar mais do que 20 criaturas no Targeting, a contagem de criaturas no Battle List procurará somente as 20 PRIMEIRAS criaturas da lista, adicionar mais do que 20 pode fazer com que criaturas não sejam contadas.`nIsso afeta funções como Lure Mode e contagem de criaturas para condições de magias.`nCaso precise ter mais de 20 criaturas, marque a opção ""Atacar somente se trapado"" nas criaturas que não precisam ser contadas(como criaturas que não estão na hunt). " : "WARNING! It's not recommended to add more than 20 criatures in the Targeting, the creatures count in the Battle List will search only for the FIRST 20 creatures in the list, adding more than 20 may cause creatures to not be counted.`nThis affects functions like Lure Mode and the creature count for spells conditions.`nIn case you need to have more than 20 creatures, check the option ""Attack only if trapped"" in the creatures that do not need to be counted(like creature that are not in the hunt).", 60

        }

    }

    testCreatureImage() {
        Gui, CavebotGUI:Default
        GuiControlGet, creatureName
        if (targetingObj.targetList[creatureName]["image"] = "") {
            Msgbox, 48,, % "Creature """ creatureName """ has no image.", 2
            return
        }


        this.deleteTempImage()

        Sleep, 25
        try
            Base64ToFile(targetingObj.targetList[creatureName]["image"], this.TEMP_IMAGE_PATH)
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 48,, % e.Message
            return
        }
        Sleep, 25
        if (!FileExist(this.TEMP_IMAGE_PATH)) {
            Gui, Carregando:Destroy
            Msgbox, 16,, Failed to create monster image.
            return
        }
        if (TibiaClient.getClientArea() = false)
            return

        _search := this.searchTempImage()

        if (_search.notFound()) {
            Gui, Carregando:Destroy
            msgbox,48,, % "Creature image not found.`n`nMake sure it's visible on the screen, and if it is, try to get its image again.`n`nPS: creatures turn darker when they are attacking your character.", 5
            return
        }

        OldBotSettings.disableGuisLoading()

        targetingObj.targetList[creatureName].timestamp := A_Now

        CreaturesHandler.addCreatureImage(creatureName, targetingObj.targetList[creatureName]["image"])
        targetingObj.targetList[creatureName].client := TibiaClient.getClientIdentifier()

        TargetingGUI.loadTargetListLV()
        this.saveTargetList(A_ThisFunc)

        MouseMove, WindowX + _search.getX(), WindowY + _search.getY()
        Gui, Carregando:Destroy
        OldBotSettings.enableGuisLoading()
        msgbox, 64,, % "Seems alright!", 2
        return
    }

    /**
    * @return _ImageSearch
    */
    searchTempImage() {
        return new _ImageSearch()
            .setPath(this.TEMP_IMAGE_PATH)
            .setVariation(TargetingSystem.targetingJsonObj.options.searchCreatureVariation)
            .search()
            .disposeImageBitmap()
    }

    getCreatureImageAttacking()
    {
        Gui, CavebotGUI:Default
        GuiControlGet, creatureName

        if (!IsObject(TargetingSystem.targetingJsonObj))
            throw Exception("TargetingSystem.targetingJsonObj object not created.")
        if (creatureName = "") {
            Msgbox, 64,, Select a creature., 2
            return
        }

        if (TibiaClient.getClientArea() = false) {
            return
        }

        if (targetingObj.targetList[creatureName]["image"] != "") {
            if (A_IsCompiled) {
                Msgbox,36,, % LANGUAGE = "PT-BR" ? "Essa ação irá sobrescrever a imagem atual do monstro """ creatureName """.`n`nDeseja continuar?" : "This action will overwrite the image of current monster """ creatureName """.`n`nContinue?"
                IfMsgBox, No
                    return
            }
        }

        if (A_IsCompiled) {
            OldBotSettings.disableGuisLoading()
            WinActivate()
        }

            new _BattleListArea().checkBattleListButtons(this.getCoordinates(), "Players Battle List")

        _search := new _IsAttacking()

        if (_search.notFound()) {
            OldBotSettings.enableGuisLoading()
            msgbox, 64,, % txt("Ataque a criatura """ creatureName """ para capturar o seu nome no Battle List.`n`nVocê pode atacar usando Fist Fight ou equipar um ""bow"" para não causar dano a criatura caso a mate muito rápido.", "Attack the creature(target) """ creatureName """ to get its name in the Battle List.`n`nYou can attack using Fist Fight or equip a ""bow"" to deal no damage to the creature in case you kill it too fast."), 10
            return
        }

        if (backgroundKeyboardInput = false) {
            WinActivate()
            Sleep, 50
        }

        ; if (A_IsCompiled) {
        Loop, 3 {
            Send("Esc")
            Sleep, 100
        }

        ; }
        c1 := new _Coordinate(_search.getX(), _search.getY())
            .addX(new _TargetingJson().get("redPixelArea.getCreatureImage.offsetX", 2))
            .addY(new _TargetingJson().get("redPixelArea.getCreatureImage.offsetY", 3))

        height := 11
        c2 := new _Coordinate(c1.getX(), c1.getY())
            .addX(this.getCreatureImageWidth())
            .addY(height)

        coordinates := new _Coordinates(c1, c2)
        screenImage := _BitmapEngine.getClientBitmap()

        creatureBitmap := new _BitmapImage(screenImage.cropFromArea(new _WindowArea().getCoordinates(), coordinates))

        creatureBitmap
            .save(this.TEMP_IMAGE_PATH)
            .dispose()
        creatureBitmap := ""

        _search := new _ImageSearch()
            .setPath(this.TEMP_IMAGE_PATH)
            .setVariation(TargetingSystem.targetingJsonObj.options.searchCreatureVariation)
            .search()
            .disposeImageBitmap()

        if (_search.notFound() && A_IsCompiled) {
            OldBotSettings.enableGuisLoading()
            msgbox,48,, % txt("Imagem da criatura não localizada, tente capturar o nome no Battle List novamente.", "Creature image not found, try to get its name on Battle List again."), 10
            Gui, CavebotGUI:Show
            return
        }

        try GuiControl, CavebotGUI:, creatureImage, % this.TEMP_IMAGE_PATH
        catch {
        }

        targetingObj.targetList[creatureName].image := FileToBase64(this.TEMP_IMAGE_PATH)
        targetingObj.targetList[creatureName].timestamp := A_Now
        targetingObj.targetList[creatureName].client := TibiaClient.getClientIdentifier()

        CreaturesHandler.addCreatureImage(creatureName, targetingObj.targetList[creatureName]["image"])
        CreaturesHandler.saveCreatures()

        try FileDelete, % this.TEMP_IMAGE_PATH
        catch {
        }

        Gui, CavebotGUI:Show
        TargetingGUI.loadTargetListLV()
        this.saveTargetList(A_ThisFunc)

        OldBotSettings.enableGuisLoading()
    }

    getCreatureImageWidth() {
        GuiControlGet, creatureImageWidth
        width := TargetingSystem.creatureImageWidths[creatureImageWidth]
        if (width < 10)
            width := 118
        return width
    }


    getCreatureImage() {
        Gui, CavebotGUI:Default
        GuiControlGet, creatureName
        ; tirar_screenshot("CavebotGUI","" . selectedMonster . "", 92, 11,"Monstros")
        ; GuiControl, CavebotGUI:, MonstroImg, Cavebot\%currentScript%\Monstros\%selectedMonster%.png
        ; return
        if (creatureName = "") {
            Msgbox, 64,, Select a creature.
            return
        }

        GetKeyState, CtrlPressed, Ctrl, D
        if (CtrlPressed != "D") {
            if (targetingObj.targetList[creatureName]["image"] != "") {
                Msgbox,36,, % LANGUAGE = "PT-BR" ? "Essa ação irá sobrescrever a imagem atual do monstro """ creatureName """.`n`nDeseja continuar?" : "This action will overwrite the image of current monster """ creatureName """.`n`nContinue?"
                IfMsgBox, No
                    return
            }
        }

        this.deleteTempImage()

        if (TibiaClient.getClientArea() = false)
            return

        width := this.getCreatureImageWidth()
        height := jsonConfig("targeting", "options", "creatureImageHeight")

        tirar_screenshot("CavebotGUI", creatureName, width, height ? height : 11,  "TempMonster", "Red", 120, true)
        if (A_IsCompiled) {
            Send("Esc")
            Sleep, 200
        }

        _search := this.searchTempImage()
        if (_search.notFound() && A_IsCompiled) {
            msgbox,48,, % LANGUAGE = "PT-BR" ? "Imagem da criatura não localizada, tente capturar o nome no Battle List novamente." : "Creature image not found, try to get its name on Battle List again."
            Gui, CavebotGUI:Show
            return
        }

        this.paintCreatureBitmap()

        try {
            GuiControl, CavebotGUI:, creatureImage, % this.TEMP_IMAGE_PATH
        } catch {
        }

        targetingObj.targetList[creatureName].image := FileToBase64(this.TEMP_IMAGE_PATH)
        targetingObj.targetList[creatureName].timestamp := A_Now
        targetingObj.targetList[creatureName].client := TibiaClient.getClientIdentifier()
        CreaturesHandler.addCreatureImage(creatureName, targetingObj.targetList[creatureName]["image"])

        this.deleteTempImage()

        Gui, CavebotGUI:Show
        TargetingGUI.loadTargetListLV()
        TargetingGUI.loadCreatureImage(creatureName)
        this.saveTargetList(A_ThisFunc)
    }

    paintCreatureBitmap()
    {
        return

        pixelsToReplace := jsonConfig("targeting", "creatureImageReplacePixels")
        if (!pixelsToReplace) {
            return
        }
        bitmap := new _BitmapImage(this.TEMP_IMAGE_PATH)
        w := bitmap.getW()
        h := bitmap.getH()

        x := 0
        loop, % w {
            y := 0
            if (x > w) {
                break
            }

            loop, % h {
                pixel := bitmap.getPixel(new _Coordinate(x, y))
                if (_Arr.search(pixelsToReplace, pixel)) {
                    ; bitmap.setPixel(new _Coordinate(x, y), "0x000000FF")
                    bitmap.setPixel(new _Coordinate(x, y), ImagesConfig.pinkColor)
                }
                if (y < h) {
                    y++
                }
            }

            x++
        }



        ; OCR(bitmap.get())

        bitmap.debug()
        m(base64 := Gdip_EncodeBitmapTo64string(bitmap.get(), "png"))
        bitmap.save(this.TEMP_IMAGE_PATH)
        bitmap.dispose()
    }

    deleteTempImage() {
        try FileDelete, % this.TEMP_IMAGE_PATH
        catch {
        }
    }

    addCreature() {
        if (!creaturesObj[creatureName])
            throw Exception("Creature """ creatureName """ doesn't exist on Creature list.")
    }

    saveTargetingSettings(origin := "") {
        targetingObj.settings := targetingObj.settings
        this.saveTargeting(true, origin)
    }

    saveTargetList(origin := "") {
        targetingObj.targetList := targetingObj.targetList
        this.saveTargeting(true, origin)
    }

    saveTargeting(saveCavebotScript := true, origin := "", loadingGuis := true) {
        if (targetingObj = "") {
            Msgbox, 16,, % "Empty targeting settings to save, origin: " origin
            return
        }
        if (loadingGuis = true) {
            OldBotSettings.disableGuisLoading()
        }

        scriptFile.targeting := targetingObj
        if (saveCavebotScript = true) {
            CavebotScript.saveSettings(A_ThisFunc)
        }

        if (loadingGuis = true) {
            OldBotSettings.enableGuisLoading()
        }
    }

}