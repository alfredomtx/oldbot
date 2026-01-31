
global FullLightModule ; shortcut script gui

Class _FullLightHandler
{
    __New()
    {
        global



        this.loadFullLightSettings()

    }

    loadFullLightSettings() {
        global 

        fullLightObj.fullLightEnabled := (fullLightObj.fullLightEnabled = "" && fullLightObj.fullLightEnabled != false) ? false : fullLightObj.fullLightEnabled

        fullLightObj.fullLightSqms := (fullLightObj.fullLightSqms = "" && fullLightObj.fullLightSqms != false) ? 11 : fullLightObj.fullLightSqms
        fullLightObj.fullLightSqms := (fullLightObj.fullLightSqms < 1 OR fullLightObj.fullLightSqms > 11) ? 11 : fullLightObj.fullLightSqms


        fullLightObj.fullLightDelay := (fullLightObj.fullLightDelay = "" && fullLightObj.fullLightDelay != false) ? 50 : fullLightObj.fullLightDelay
        fullLightObj.fullLightDelay := (fullLightObj.fullLightDelay < 1 OR fullLightObj.fullLightDelay > 150) ? 50 : fullLightObj.fullLightDelay

        fullLightObj.fullLightEffect := (fullLightObj.fullLightEffect = "" && fullLightObj.fullLightEffect != false) ? "Spell" : fullLightObj.fullLightEffect

        ; fullLightObj.fullLightSqms := (fullLightObj.fullLightSqms < 11) ? 11 : fullLightObj.fullLightSqms
        return
    }

    saveFullLight(saveCavebotScript := true) {
        scriptFile.fullLight := fullLightObj
        if (saveCavebotScript = true)
            CavebotScript.saveSettings(A_ThisFunc)
    }

    checkBeforeEnablingFullLight() {

        if (OldBotSettings.uncompatibleModule("fullLight") = true) {
            throw Exception("Full Light is not compatible with the current client: " TibiaClient.getClientIdentifier() ".")
        }

        try TibiaClient.checkClientSelected()
        catch e {
            throw Exception(e.Message, 64)
        }
    }

    enableFullLight() {
        global ; if not global is not starting the function

        OldBotSettings.startFunction("fullLight", "fullLightEnabled", startProcess := false, throwE := false, saveJson := true)
        _FullLightExe.start()
    }

    disableFullLight() {
        global

        OldBotSettings.stopFunction("fullLight", "fullLightEnabled", closeProcess := false, saveJson := true)
        _FullLightExe.stop()
    }

    saveFullLightOptions() {
        return
        Gui, CavebotGUI:Default
        Gui, CavebotGUI:Submit, NoHide
        GuiControlGet, fullLightID

        if (fullLightID = "")
            throw Exception("No fullLight selected.")

        for key, control in FullLightGUI.controls
        {
            try GuiControlGet, %control%
            catch {
            }
        }


        if (this.isValidFullLight(fullLightFullLight) = false)
            throw Exception("Invalid fullLight: " fullLightFullLight)

        /**
        if (fullLightHealPercent < 5 OR fullLightHealPercent > 99)
        throw Exception("Invalid percentage value for Player HP %, min: 5, max: 99.")
        */

        ; msgbox, % "before " serialize(fullLightObj)

        for key, option in this.fullLightOptions
        {
            if (option = "userValue")
                continue
            value := fullLight%option%
            ; if value is Number
            ; value += 0
            fullLightObj[fullLightID][option] := value
        }

        fullLightObj[fullLightID].action := (fullLightObj[fullLightID].action = A_Space) ? "" : fullLightObj[fullLightID].action

        fullLightObj[fullLightID].interval := fullLightinterval += 0

        switch fullLightObj[fullLightID].enabled {
            case 1:
            case 0:
        }

        FullLightGUI.updateFullLightRow(fullLightID)
        FullLightGUI.resizeColumns()

        this.saveFullLight(saveCavebotScript := true)
    }



}



