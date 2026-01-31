
Class _SupportHandler
{
    __New()
    {
        global


        this.loadSupportSettings()

    }

    /**
    TO DO: validate hotkeys and percentages on start
    */
    loadSupportSettings() {
        global

        this.checkDefaultSupportSettings()

        autoEatFood := supportObj.autoEatFood
        autoShoot := supportObj.autoShoot

        autoHaste := supportObj.autoHaste
        autoUtamoVita := supportObj.autoUtamoVita
        autoBuffSpell := supportObj.autoBuffSpell

        cureParalyze := supportObj.cureParalyze
        curePoison := supportObj.curePoison
        cureFire := supportObj.cureFire
        cureCurse := supportObj.cureCurse

        autoBuffSpellChatOn := supportObj.autoBuffSpellChatOn
        autoBuffSpellPZ := supportObj.autoBuffSpellPZ


        autoHasteChatOn := supportObj.autoHasteChatOn
        autoHastePZ := supportObj.autoHastePZ

        autoUtamoVitaChatOn := supportObj.autoUtamoVitaChatOn
        autoUtamoVitaPZ := supportObj.autoUtamoVitaPZ

        autoHasteHotkey := supportObj.autoHasteHotkey
        autoBuffSpellHotkey := supportObj.autoBuffSpellHotkey
        cureFireHotkey := supportObj.cureFireHotkey
        cureCurseHotkey := supportObj.cureCurseHotkey
        cureParalyzeHotkey := supportObj.cureParalyzeHotkey
        curePoisonHotkey := supportObj.curePoisonHotkey
        eatFoodHotkey := supportObj.eatFoodHotkey
        hasteSpellHotkey := supportObj.hasteSpellHotkey
        utamoVitaHotkey := supportObj.utamoVitaHotkey
        exanaVitaHotkey := supportObj.exanaVitaHotkey

        autoHasteTargetingRunning := supportObj.autoHasteTargetingRunning
        autoBuffSpellTargetingRunning := supportObj.autoBuffSpellTargetingRunning
        cureFireTargetingRunning := supportObj.cureFireTargetingRunning
        cureCurseTargetingRunning := supportObj.cureCurseTargetingRunning
        cureParalyzeTargetingRunning := supportObj.cureParalyzeTargetingRunning
        curePoisonTargetingRunning := supportObj.curePoisonTargetingRunning
        eatFoodTargetingRunning := supportObj.eatFoodTargetingRunning
        hasteSpellTargetingRunning := supportObj.hasteSpellTargetingRunning
        utamoVitaTargetingRunning := supportObj.utamoVitaTargetingRunning
        exanaVitaTargetingRunning := supportObj.exanaVitaTargetingRunning

    }

    checkDefaultSupportSettings() {
        global
        supportObj.autoEatFood := (supportObj.autoEatFood = "" && supportObj.autoEatFood != false) ? false : supportObj.autoEatFood
        supportObj.autoShoot := (supportObj.autoShoot = "" && supportObj.autoShoot != false) ? false : supportObj.autoShoot
        supportObj.autoShootWhenAttacking := (supportObj.autoShootWhenAttacking = "" && supportObj.autoShootWhenAttacking != false) ? true : supportObj.autoShootWhenAttacking

        supportObj.autoHaste := (supportObj.autoHaste = "" && supportObj.autoHaste != false) ? false : supportObj.autoHaste
        supportObj.hasteMinMana := supportObj.hasteMinMana = "" ? 20 : supportObj.hasteMinMana
        supportObj.hasteMinMana := supportObj.hasteMinMana < 0 ? 0 : supportObj.hasteMinMana

        supportObj.autoUtamoVita := (supportObj.autoUtamoVita = "" && supportObj.autoUtamoVita != false) ? false : supportObj.autoUtamoVita
        supportObj.utamoVitaMinMana := supportObj.utamoVitaMinMana = "" ? 20 : supportObj.utamoVitaMinMana
        supportObj.utamoVitaMinMana := supportObj.utamoVitaMinMana < 0 ? 0 : supportObj.utamoVitaMinMana
        supportObj.utamoVitaLife := supportObj.utamoVitaLife = "" ? 100 : supportObj.utamoVitaLife
        supportObj.exanaVitaEnabled := (supportObj.exanaVitaEnabled = "" && supportObj.exanaVitaEnabled != false) ? false : supportObj.exanaVitaEnabled
        supportObj.exanaVitaLife := supportObj.exanaVitaLife = "" ? 80 : supportObj.exanaVitaLife
        ; if (utamoVitaLife > exanaVitaLife) {
        ;     GuiControl, CavebotGUI:, utamoVitaLife, % exanaVitaLife - 1
        ; if (exanaVitaLife < utamoVitaLife) {
        ;     GuiControl, CavebotGUI:, exanaVitaLife, % utamoVitaLife + 1

        supportObj.autoBuffSpell := (supportObj.autoBuffSpell = "" && supportObj.autoBuffSpell != false) ? false : supportObj.autoBuffSpell
        supportObj.autoBuffSpellMinMana := supportObj.autoBuffSpellMinMana = "" ? 20 : supportObj.autoBuffSpellMinMana
        supportObj.autoBuffSpellMinMana := supportObj.autoBuffSpellMinMana < 0 ? 0 : supportObj.autoBuffSpellMinMana

        supportObj.cureParalyze := (supportObj.cureParalyze = "" && supportObj.cureParalyze != false) ? false : supportObj.cureParalyze
        supportObj.curePoison := (supportObj.curePoison = "" && supportObj.curePoison != false) ? false : supportObj.curePoison
        supportObj.cureFire := (supportObj.cureFire = "" && supportObj.cureFire != false) ? false : supportObj.cureFire
        supportObj.cureCurse := (supportObj.cureCurse = "" && supportObj.cureCurse != false) ? false : supportObj.cureCurse

        supportObj.autoBuffSpellChatOn := (supportObj.autoBuffSpellChatOn = "" && supportObj.autoBuffSpellChatOn != false) ? false : supportObj.autoBuffSpellChatOn
        supportObj.autoBuffSpellPZ := (supportObj.autoBuffSpellPZ = "" && supportObj.autoBuffSpellPZ != false) ? false : supportObj.autoBuffSpellPZ


        supportObj.autoHasteChatOn := (supportObj.autoHasteChatOn = "" && supportObj.autoHasteChatOn != false) ? false : supportObj.autoHasteChatOn
        supportObj.autoHastePZ := (supportObj.autoHastePZ = "" && supportObj.autoHastePZ != false) ? false : supportObj.autoHastePZ

        supportObj.autoUtamoVitaChatOn := (supportObj.autoUtamoVitaChatOn = "" && supportObj.autoUtamoVitaChatOn != false) ? false : supportObj.autoUtamoVitaChatOn
        supportObj.autoUtamoVitaPZ := (supportObj.autoUtamoVitaPZ = "" && supportObj.autoUtamoVitaPZ != false) ? false : supportObj.autoUtamoVitaPZ

        functionsWithTargetingOption := {}
        functionsWithTargetingOption.Push("autoHaste")
        functionsWithTargetingOption.Push("autoBuffSpell")
        functionsWithTargetingOption.Push("autoEatFood")
        functionsWithTargetingOption.Push("autoUtamoVita")
        functionsWithTargetingOption.Push("cureParalyze")
        functionsWithTargetingOption.Push("curePoison")
        functionsWithTargetingOption.Push("cureFire")
        functionsWithTargetingOption.Push("cureCurse")
        for key, function in functionsWithTargetingOption
        {
            supportObj[function "TargetingRunning"] := (supportObj[function "TargetingRunning"] = "" && supportObj[function "TargetingRunning"] != false) ? false : supportObj[function "TargetingRunning"]
            ; msgbox, % function " " supportObj[function "TargetingRunning"] " " function "TargetingRunning"

        }
    }

    submitCheckboxSupport(control, value, event := "", ErrLevel := "") {
        if (value = true) {
            OldBotSettings.startFunction("support", control, startProcess := false, throwE := false, saveJson := true)
            _SupportExe.start()
            return
        }

        OldBotSettings.stopFunction("support", control, closeProcess := false, saveJson := true)
        _SupportExe.stop()
    }

    submitSupportOption() {
        Gui, CavebotGUI:Default
        Gui, CavebotGUI:Submit, NoHide

        ; msgbox, %  A_ThisFunc "`n" A_GuiControl " / " %A_GuiControl%

        try value := %A_GuiControl%
        catch 
            throw Exception("Error submiting for Support option value.")

        if (InStr(A_GuiControl, "Hotkey")) {
            _Validation.hotkey(value)
        } else {
            if value is number
                value += 0
        }

        _GuiHandler.submitSetting("support", A_GuiControl, value)
    }


    saveSupport(saveCavebotScript := true) {
        OldBotSettings.disableGuisLoading()

        scriptFile.support := supportObj
        if (saveCavebotScript = true)
            CavebotScript.saveSettings(A_ThisFunc)
        OldBotSettings.enableGuisLoading()

    }

}