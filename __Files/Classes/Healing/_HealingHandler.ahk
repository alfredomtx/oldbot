
global manaMin ; for some reason, submitHealingOption is unable to get the value from this variable if don't set as global here
global manaMax


global highestComment

Class _HealingHandler
{
    __New()
    {
        global

        this.loadHealingSettings()

    }

    loadHealingSettings() {
        global

        if (!IsObject(healingObj["life"]))
            healingObj["life"] := {}
        if (!IsObject(healingObj["mana"]))
            healingObj["mana"] := {}

        this.checkHealingDefaultSettings()

        lifeHealingEnabled := healingObj.lifeHealingEnabled
        manaHealingEnabled := healingObj.manaHealingEnabled
        manaTrainEnabled := healingObj.manaTrainEnabled
        manaTrainChatOn := healingObj.mana.manaTrainChatOn
        manaTrainPZ := healingObj.mana.manaTrainPZ

        highestLife := healingObj.life.highestLife
        highestMana := healingObj.life.highestMana
        highLife := healingObj.life.highLife
        highMana := healingObj.life.highMana
        lowLife := healingObj.life.lowLife
        lowMana := healingObj.life.lowMana
        midLife := healingObj.life.midLife
        midMana := healingObj.life.midMana

        highestHotkey := healingObj.life.highestHotkey
        highHotkey := healingObj.life.highHotkey
        midHotkey := healingObj.life.midHotkey
        lowHotkey := healingObj.life.lowHotkey

        lowPotionHotkey := healingObj.life.lowPotionHotkey
        midPotionHotkey := healingObj.life.midPotionHotkey

        highestComment := healingObj.life.highestComment
        highComment := healingObj.life.highComment
        midComment := healingObj.life.midComment
        lowComment := healingObj.life.lowComment

        manaHotkey := healingObj.mana.manaHotkey
        manaMax := healingObj.mana.manaMax
        manaMin := healingObj.mana.manaMin
        manaTrain := healingObj.mana.manaTrain
        manaTrainHotkey := healingObj.mana.manaTrainHotkey

    }

    checkHealingDefaultSettings() {
        global

        healingObj.lifeHealingEnabled := (healingObj.lifeHealingEnabled = "" && healingObj.lifeHealingEnabled != false) ? false : healingObj.lifeHealingEnabled
        healingObj.manaHealingEnabled := (healingObj.manaHealingEnabled = "" && healingObj.manaHealingEnabled != false) ? false : healingObj.manaHealingEnabled
        healingObj.manaTrainEnabled := (healingObj.manaTrainEnabled = "" && healingObj.manaTrainEnabled != false) ? false : healingObj.manaTrainEnabled
        healingObj.mana.manaTrainChatOn := (healingObj.mana.manaTrainChatOn = "" && healingObj.mana.manaTrainChatOn != false) ? false : healingObj.mana.manaTrainChatOn
        healingObj.mana.manaTrainPZ := (healingObj.mana.manaTrainPZ = "" && healingObj.mana.manaTrainPZ != false) ? false : healingObj.mana.manaTrainPZ

        healingObj.life.highLife := healingObj.life.highLife < 5 ? 5 : healingObj.life.highLife
        healingObj.life.highMana := healingObj.life.highMana = "" ? 15 : healingObj.life.highMana
        healingObj.life.highMana := healingObj.life.highMana < 0 ? 0 : healingObj.life.highMana

        healingObj.life.lowLife := healingObj.life.lowLife = "" ? 40 : healingObj.life.lowLife
        healingObj.life.lowLife := healingObj.life.lowLife < 5 ? 5 : healingObj.life.lowLife
        healingObj.life.lowMana := healingObj.life.lowMana = "" ? 15 : healingObj.life.lowMana
        healingObj.life.lowMana := healingObj.life.lowMana < 0 ? 0 : healingObj.life.lowMana

        healingObj.life.midLife := healingObj.life.midLife = "" ? 65 : healingObj.life.midLife
        healingObj.life.midLife := healingObj.life.midLife < 5 ? 5 : healingObj.life.midLife
        healingObj.life.midMana := healingObj.life.midMana = "" ? 15 : healingObj.life.midMana
        healingObj.life.midMana := healingObj.life.midMana < 0 ? 0 : healingObj.life.midMana


        healingObj.mana.manaMin := healingObj.mana.manaMin = "" ? 40 : healingObj.mana.manaMin
        healingObj.mana.manaMax := healingObj.mana.manaMax = "" ? 60 : healingObj.mana.manaMax
        healingObj.mana.manaTrain := healingObj.mana.manaTrain = "" ? 97 : healingObj.mana.manaTrain
        healingObj.mana.manaMin := healingObj.mana.manaMin < 1 ? 1 : healingObj.mana.manaMin
        healingObj.mana.manaMax := healingObj.mana.manaMax < 2 ? 2 : healingObj.mana.manaMax
        healingObj.mana.manaTrain := healingObj.mana.manaTrain < 1 ? 1 : healingObj.mana.manaTrain

        healingObj.mana.manaItemName := healingObj.mana.manaItemName = "" ? "mana potion" : healingObj.mana.manaItemName

    }

    startAllHealing() {
        global
        OldBotSettings.startFunction("healing", "lifeHealingEnabled", startProcess := false, throwE := false, saveJson := false, loadingGui := false)
        OldBotSettings.startFunction("healing", "manaHealingEnabled", startProcess := false, throwE := false, saveJson := false, loadingGui := false)
        OldBotSettings.startFunction("healing", "manaTrainEnabled", startProcess := false, throwE := false, saveJson := true, loadingGui := false)
        _HealingExe.start()
    }

    stopAllHealing() {
        global
        OldBotSettings.stopFunction("healing", "lifeHealingEnabled", closeProcess := false, saveJson := false, loadingGui := false)
        OldBotSettings.stopFunction("healing", "manaHealingEnabled", closeProcess := false, saveJson := false, loadingGui := false)
        OldBotSettings.stopFunction("healing", "manaTrainEnabled", closeProcess := false, saveJson := true, loadingGui := false)
        _HealingExe.stop()
    }

    /**
    state: true or false
    */
    setLifeHealingEnabled(state) {
        global

        IniWrite, 0, %DefaultProfile%, healing_system, UsingItemOnCharacter

        lifeHealingEnabled := state
        if (state = true) {
            OldBotSettings.startFunction("healing", "lifeHealingEnabled", startProcess := false, throwE := false, saveJson := true)
            _HealingExe.start()
            return
        }

        OldBotSettings.stopFunction("healing", "lifeHealingEnabled", closeProcess := false, saveJson := true)
        _HealingExe.stop()
    }

    setManaHealingEnabled(state) {
        global
        manaHealingEnabled := state
        if (state = true) {
            OldBotSettings.startFunction("healing", "manaHealingEnabled", startProcess := false, throwE := false, saveJson := true)
            _HealingExe.start()
            return
        }

        OldBotSettings.stopFunction("healing", "manaHealingEnabled", closeProcess := false, saveJson := true)
        _HealingExe.stop()
    }

    setManaTrainEnabled(state) {
        global
        manaTrainEnabled := state
        if (state = true) {
            OldBotSettings.startFunction("healing", "manaTrainEnabled", startProcess := false, throwE := false, saveJson := true)
            _HealingExe.start()
            return
        }

        OldBotSettings.stopFunction("healing", "manaTrainEnabled", closeProcess := false, saveJson := true)
    }

    submitHealingOption(Control := "", validate := true) {
        Gui, CavebotGUI:Default
        Gui, CavebotGUI:Submit, NoHide

        Control := Control = "" ? A_GuiControl : Control

        try value := %Control%
        catch
            throw Exception("Error submiting for healing option value.`n" e.Message "`n" e.What)

        ; msgbox, %  A_ThisFunc "`n" Control " / " A_GuiControl " / " value " / " validate
        if (InStr(Control, "ItemName")) {
            this.assignHealingControlValue(Control, value)
            return
        }

        if (!InStr(Control, "hotkey")) {
            if value is number
                value += 0
        }

        this.assignHealingControlValue(Control, value)

        _GuiHandler.submitSetting("healing", Control, value)
    }

    assignHealingControlValue(Control, value) {

        switch Control {
            case "manaHotkey", case "manaMin", case "manaMax", case "manaHotkey", case "manaTrainHotkey", case "manaTrain", case "manaTrainChatOn", case "manaTrainPZ", case "manaItemName":
                healingObj["mana"][Control] := value
            default:
                healingObj["life"][Control] := value
        }

    }

    validateManaHealingPercentages()
    {
        if (healingObj.mana.manaMin > healingObj.mana.manaMax) {
            throw Exception(txt("A porcentagem de ""Mana abaixo"" não pode ser maior do que a porcentagem de ""Mana acima"".", "The ""Mana below"" percentage can't be higher than the ""Mana above"" percentage."))
        }
    }

    validateLifeHealingPercentages()
    {
        if (healingObj.life.lowLife > healingObj.life.midLife) {
            throw Exception(txt("A porcentagem de ""Vida abaixo"" do LowHP precisa ser menor do que a porcentagem do MidHP.", "The LowHP ""Life below"" percentage needs to be lower than MidHP percentage."))
        }

        if (healingObj.life.midLife > healingObj.life.highLife) {
            throw Exception(txt("A porcentagem de ""Vida abaixo"" do MidHP precisa ser menor do que a porcentagem do HighHP.", "The MidHP ""Life below"" percentage needs to be lower than HighHP percentage."))
        }

        if (healingObj.life.highLife > healingObj.life.highestLife) {
            throw Exception(txt("A porcentagem de ""Vida abaixo"" do HighHP precisa ser menor do que a porcentagem do HighestHP.", "The HighHP ""Life below"" percentage needs to be lower than HighestHP percentage."))
        }
    }

    validateHealingRules()
    {
        switch OldbotSettings.settingsJsonObj.clientFeatures.useItemWithHotkey {
            case false:
                if (healingObj.life.lowItemName = "" OR healingObj.life.lowItemName = A_Space) && (healingObj.mana.manaMin < healingObj.life.lowMana)
                    throw Exception((LANGUAGE = "PT-BR" ? "Cuidado!`n`nA porcentagem do Mana healing ""Mana min %"" não pode ser menor do que a regra do LowHP ""Min mana %"", a não ser que haja também uma Potion setada para a regra de LowHP"   : "Caution!`n`nMana healing ""Mana min %"" percent can't be lower than the LowHP ""Min mana %"" rule, unless there is also a Potion set for LowHP rule."))
            default:
                /**
                if is not using potion on LowHP - only spell
                the Mana min % of Mana Healing can't be lower than the Low hp mana
                otherwise it will stop healing for not having enough mana
                and mana will not heal because won't reach the percentage
                */
                if (healingObj.life.lowPotionHotkey = "") && (healingObj.mana.manaMin < healingObj.life.lowMana)
                    throw Exception((LANGUAGE = "PT-BR" ? "Cuidado!`n`nA porcentagem do Mana healing ""Mana min %"" não pode ser menor do que a regra do LowHP ""Min mana %"", a não ser que haja também uma Potion setada para a regra de LowHP"   : "Caution!`n`nMana healing ""Mana min %"" percent can't be lower than the LowHP ""Min mana"" rule, unless there is also a Potion set for LowHP rule."))
        }
    }

    validateHealingHotkey(control := "", htk := "") {
        vars := ValidateHotkey("CavebotGUI", control, htk)
        if (vars.erro > 0) {
            throw Exception(vars.msg)
        }

    }

    validateHealingPotionHotkey(control, htk, isPotion := true) {
        if (!clientHasFeature("useItemWithHotkey"))
            return

        if (htk = "")
            return
        Loop, 8 {
            switch A_Index {
                case 1: rule := "Low"
                case 2: rule := "Mid"
                case 3: rule := "High"
                case 4: rule := "Highest"
            }
            Gui, CavebotGUI:Default
            if (isPotion = true) {
                try GuiControlGet, %rule%Hotkey
                catch
                    return
                if (htk = %rule%Hotkey)
                    throw Exception((LANGUAGE = "PT-BR" ? "Potion Hotkey (" htk ") não pode ser igual a ""Spell Hotkey""`n- Regra: " rule "`n- Spell Hotkey: " %rule%Hotkey "." : "Potion Hotkey (" htk ") can't be the same as a ""Spell Hotkey""`n- Rule: " rule "`n- Spell Hotkey: " %rule%Hotkey "."))
            } else {
                try GuiControlGet, %rule%PotionHotkey
                catch
                    return
                if (htk = %rule%PotionHotkey)
                    throw Exception((LANGUAGE = "PT-BR" ? "Spell Hotkey (" htk ") não pode ser igual a ""Potion Hotkey""`n- Regra: " rule "`n- Potion Hotkey: " %rule%Hotkey "." : "Spell Hotkey (" htk ") can't be the same as a ""Potion Hotkey""`n- Rule: " rule "`n- Potion Hotkey: " %rule%Hotkey "."))
            }
        }
    }

    checkLifeHotkeys(hideMessage := false) {
        return
        Loop, 8 {
            switch A_Index {
                case 1:
                    ; if (!clientHasFeature("useItemWithHotkey"))
                    ; continue
                    rule := "Low"
                case 2:
                    ; if (!clientHasFeature("useItemWithHotkey"))
                    ; continue
                    rule := "Mid"
                case 3:
                    rule := "High"
                    continue ; allow empty hotkey
                case 4:
                    rule := "Highest"
                    continue ; allow empty hotkey
            }
            Gui, CavebotGUI:Default
            GuiControlGet, %rule%Hotkey
            if (%rule%Hotkey = "") && (healingObj.life[rule "Hotkey"] = "") {
                /**
                allow empty spell hotkey if potion hotkey or potion is set
                */
                switch rule {
                    case "Low", case "Mid":
                        GuiControlGet, %rule%PotionHotkey
                        if (%rule%PotionHotkey != "")
                            continue
                        if (%rule%ItemName != "") && (%rule%ItemName != A_Space)
                            continue
                        /**
                        allow empty spell hotkey for high and highest
                        */
                    case "High", case "Highest":
                        continue

                }
                this.setLifeHealingEnabled(0, true)
                if (hideMessage = false) {
                    switch rule {
                        case "Low", case "Mid":
                            if (!clientHasFeature("useItemWithHotkey"))
                                Msgbox, 64,, % rule (LANGUAGE = "PT-BR" ? " HP ""Spell Hotkey"" e ""Potion/item"" não setadas, pelo menos uma deve ser setada." : " HP ""Spell Hotkey"" and ""Potion/item"" not set, at least one must be set."), 8
                            else
                                Msgbox, 64,, % rule (LANGUAGE = "PT-BR" ? " HP ""Spell Hotkey"" e ""Potion"" não setadas, pelo menos uma deve ser setada." : " HP ""Spell Hotkey"" and ""Potion Hotkey"" not set, at least one must be set."), 8
                        default:
                            Msgbox, 64,, % rule " HP ""Spell Hotkey"" not set.", 2
                    }
                }

                return false
            }

        }

        return true
    }

    checkManaHotkey(hideMessage := false) {
        if (!clientHasFeature("useItemWithHotkey")) {
            msg := ""
            if (healingObj.mana.manaItemName = "")
                msg := "Mana potion is not selected."
            ; else if (_ScriptImages.hasScriptImage(healingObj.mana.manaItemName) = false)
            ; msg := "Mana rule item image name """ healingObj.mana.manaItemName """ doesn't exist in the Script Images."

            if (msg != "")
                this.setManaHealingEnabled(0, true)

            if (hideMessage = false) && (msg != "")
                Msgbox, 64,, % msg, 8

            if (msg != "")
                return false

            return true
        }

        Gui, CavebotGUI:Default
        GuiControlGet, manaHotkey
        if (manaHotkey = "") && (healingObj.mana.manaHotkey = "") {
            this.setManaHealingEnabled(0, true)
            if (hideMessage = false)
                Msgbox, 64,, % (LANGUAGE = "PT-BR" ? "Hotkey do Mana healing não setada." : "Mana healing hotkey not set."), 8
            return false
        }
        return true
    }

    checkManaTrainHotkey(hideMessage := false) {
        Gui, CavebotGUI:Default
        GuiControlGet, manaTrainHotkey
        if (manaTrainHotkey = "") && (healingObj.mana.manaTrainHotkey = "") {
            this.setManaTrainEnabled(0, true)
            if (hideMessage = false)
                Msgbox, 64,, % (LANGUAGE = "PT-BR" ? "Hotkey do Mana Train não setada." : "Mana Train hotkey not set."), 8
            return false
        }
        return true
    }

    saveHealing(saveCavebotScript := true, origin := "") {
        if (healingObj = "") {
            Msgbox, 16,, % "Empty healing settings to save, origin: " origin, 8
            return
        }
        scriptFile.healing := healingObj
        if (saveCavebotScript = true) {
            CavebotScript.saveSettings(A_ThisFunc)
        }
    }
}