
global FishingModule ; shortcut script gui

Class _FishingHandler
{
    __New()
    {
        global



        this.loadFishingSettings()

    }

    loadFishingSettings() {
        global 

        fishingObj.fishingEnabled := (fishingObj.fishingEnabled = "" && fishingObj.fishingEnabled != false) ? false : fishingObj.fishingEnabled
        fishingObj.fishingDelay := (fishingObj.fishingDelay = "") ? 500 : fishingObj.fishingDelay
        fishingObj.fishingDelay := (fishingObj.fishingDelay < 200) ? 200 : fishingObj.fishingDelay

        /**
        conditions
        */
        fishingObj.fishingOnlyFreeSlot := (fishingObj.fishingOnlyFreeSlot = "" && fishingObj.fishingOnlyFreeSlot != false) ? false : fishingObj.fishingOnlyFreeSlot
        fishingObj.fishingIfNoFish := (fishingObj.fishingIfNoFish = "" && fishingObj.fishingIfNoFish != false) ? false : fishingObj.fishingIfNoFish
        fishingObj.fishingCapCondition := (fishingObj.fishingCapCondition = "" && fishingObj.fishingCapCondition != false) ? false : fishingObj.fishingCapCondition
        fishingObj.pressEscFishingRod := (fishingObj.pressEscFishingRod = "" && fishingObj.pressEscFishingRod != false) ? false : fishingObj.pressEscFishingRod
        fishingObj.fishingIgnoreIfWaypointTab := (fishingObj.fishingIgnoreIfWaypointTab = "" && fishingObj.fishingIgnoreIfWaypointTab != false) ? false : fishingObj.fishingIgnoreIfWaypointTab

    }

    saveFishing(saveCavebotScript := true) {
        scriptFile.fishing := fishingObj
        if (saveCavebotScript = true)
            CavebotScript.saveSettings(A_ThisFunc)
    }

    checkBeforeEnablingFishing() {
        if (FishingPauseHotkey = "")
            throw Exception("Empty fishing Pause hotkey.`nSet a hotkey and try again.", 48)

        try TibiaClient.checkClientSelected()
        catch e {
            throw Exception(e.Message, 64)
        }
    }

    enableFishing() {
        global ; if not global is not starting the function
        OldBotSettings.startFunction("fishing", "fishingEnabled", startProcess := false, throwE := false, saveJson := true)
        _FishingExe.start()
    }

    disableFishing() {
        global

        OldBotSettings.stopFunction("fishing", "fishingEnabled", closeProcess := true, saveJson := true)
        _FishingExe.stop()
    }

    saveFishingOptions() {
        Gui, CavebotGUI:Default
        Gui, CavebotGUI:Submit, NoHide
        GuiControlGet, fishingID

        if (fishingID = "")
            throw Exception("No fishing selected.")

        for key, control in FishingGUI.controls
        {
            try GuiControlGet, %control%
            catch {
            }
        }


        if (this.isValidFishing(fishingFishing) = false)
            throw Exception("Invalid fishing: " fishingFishing)

        OldBotSettings.disableGuisLoading()



        /**
        if (fishingHealPercent < 5 OR fishingHealPercent > 99)
        throw Exception("Invalid percentage value for Player HP %, min: 5, max: 99.")
        */

        ; msgbox, % "before " serialize(fishingObj)

        for key, option in this.fishingOptions
        {
            if (option = "userValue")
                continue
            value := fishing%option%
            ; if value is Number
            ; value += 0
            fishingObj[fishingID][option] := value
        }

        fishingObj[fishingID].action := (fishingObj[fishingID].action = A_Space) ? "" : fishingObj[fishingID].action

        fishingObj[fishingID].interval := fishinginterval += 0

        switch fishingObj[fishingID].enabled {
            case 1:
            case 0:
        }

        FishingGUI.updateFishingRow(fishingID)
        FishingGUI.resizeColumns()

        this.saveFishing(saveCavebotScript := true)

        OldBotSettings.enableGuisLoading()

    }

    resetFishingSqms() {
        msgbox, 52,, % "Reset all fishing SQMs?"
        IfMsgBox, No
            return

        fishingObj.sqms := {}

        this.saveFishing()

    }



}



