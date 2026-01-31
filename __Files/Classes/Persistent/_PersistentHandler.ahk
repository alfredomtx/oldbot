
Class _PersistentHandler
{
    __New()
    {
        global

        this.persistentScreenshotFolder := "Data\Screenshots\Persistent"


        if (!FileExist(this.persistentScreenshotFolder))
            FileCreateDir, % this.persistentScreenshotFolder


        this.persistentList := {}
        this.persistentList.Push("Action Script")
        this.persistentList.Push("Click on image")
        this.persistentList.Push("Click on position")
        this.persistentList.Push("Convert gold")
        this.persistentList.Push("Dance (anti-idle)")
        this.persistentList.Push("Go to label if itemcount")
        this.persistentList.Push("Press hotkey")
        this.persistentList.Push("Press hotkey if image")
        this.persistentList.Push("Run file")
        this.persistentList.Push("Save screenshot")
        this.persistentList.Push("Telegram message")
        this.persistentList.Push("Telegram screenshot")
        this.persistentList.Push("Use item")


        this.persistentOptions := {}
        this.persistentOptions.Push("action")
        this.persistentOptions.Push("enabled")
        this.persistentOptions.Push("interval")
        this.persistentOptions.Push("comment")

        this.defaultSearchArea := "sideBarsArea"

        this.loadPersistentSettings()

    }

    submitPersistentOption() {

    }

    loadPersistentSettings() {
        global

        this.checkDefaultPersistentSettings()

    }

    checkDefaultPersistentSettings() {

        /**
        Add by default all Persistents if there is none
        */
        if (persistentObj.Count() < 1)
            this.addDefaultPersistents()


        for persistentID, atributes in persistentObj
        {
            persistentObj[persistentID].enabled := (persistentObj[persistentID].enabled = "" && persistentObj[persistentID].enabled != false) ? false : persistentObj[persistentID].enabled
            persistentObj[persistentID].interval := (persistentObj[persistentID].interval = "") ? 10 : persistentObj[persistentID].interval
            persistentObj[persistentID].action := (persistentObj[persistentID].action = A_Space) ? "" : persistentObj[persistentID].action
        }
    }

    addDefaultPersistents() {
        for key, persistentName in this.persistentList
        {
            persistentObj[A_Index] := {}
            this.setDefaultActionValues(A_Index, persistentName, fromInitialCheck := true)
        }
    }

    savePersistent(saveCavebotScript := true) {
        scriptFile.persistent := persistentObj
        if (saveCavebotScript = true)
            CavebotScript.saveSettings(A_ThisFunc)
    }

    enablePersistent() {
        GuiControl, CavebotGUI:, persistentEnabled, % PersistentGUI.disableText
        GuiControl, CavebotGUI:, persistentEnabled, 1
    }

    disablePersistent() {
        GuiControl, CavebotGUI:, persistentEnabled, % PersistentGUI.enableText
        GuiControl, CavebotGUI:, persistentEnabled, 0
    }

    checkBeforeEnabling(persistentID) {
        if (persistentObj[persistentID].enabled = 0)
            return
        try TibiaClient.checkClientSelected()
        catch e {
            throw Exception(e.Message, 2)
        }
    }

    changePersistentEnabled(persistentID, save := false) {
        if (persistentID = "") {
            if (!A_IsCompiled) {
                Msgbox, 48, % A_ThisFunc, % "persistentID = " persistentID
            }
        }
        if (persistentObj[persistentID].enabled = 1) && (CheckClientMC() = false) {
            persistentObj[persistentID].enabled := 0
            save := true
        }
        if (persistentObj[persistentID].enabled = 1) {
            this.enablePersistent()
        } else {
            this.disablePersistent()
            if (this.hasPersistentEnabled() = false)
                ProcessExistClose(persistentExeName, "persistentExeName")
        }
        if (save = true)
            this.savePersistent(saveCavebotScript := true)

        PersistentGUI.updatePersistentRow(persistentID, A_ThisFunc)
        if (persistentObj[persistentID].enabled = 1) {
            _PersistentExe.start()
        }
    }

    hasPersistentEnabled() {
        for persistentID, persistent in persistentObj
        {
            if (persistentObj[persistentID].enabled = true)
                return true
        }
        return false
    }

    deletePersistent() {
        Gui, CavebotGUI:Default
        Gui, ListView, LV_PersistentList

        persistentID := _ListviewHandler.getSelectedItemOnLV("LV_PersistentList", column := 1, defaultGUI := "CavebotGUI", returnRow := false)
        if (persistentID = "" OR persistentID = "ID") {
            return
        }

        GetKeyState, CtrlPressed, Ctrl, D
        if (CtrlPressed != "D") {
            Msgbox, 52,, % "Delete persistent " persistentID " (" PersistentGUI.rowAction(persistentID) ")?"
            IfMsgBox, No
                return
        }
        ; persistentObj.Delete(persistentID)
        try persistentObj.RemoveAt(persistentID)
        catch {
        }

        ; this.checkEmptyPersistentList()
        PersistentGUI.loadPersistentListLV()
        ; this.checkSelectedPersistentExist()

        if (persistentObj.Count() > 1) {
            row := persistentID - 1
            _ListviewHandler.selectRow("LV_PersistentList", row, defaultGUI := "CavebotGUI")
        }
        if (persistentObj.Count() > 0)
            PersistentGUI.loadPersistentGuiElements(row)
        this.checkDeleteButton()


        this.savePersistent()
    }

    checkDeleteButton() {
        GuiControl, % "CavebotGUI:" (persistentObj.Count() > 0 ? "Enable" : "Disable"), deletePersistentButton
    }

    addNewPersistent() {

        persistentObj.Push({"action": "", "interval": 30})
        persistentID := persistentObj.Count()

        /**
        if the script is restricted and the User is adding this waypoint,
        add a flag to enable him to edit this Action Script
        */
        try ScriptRestriction.checkScriptRestriction(false)
        catch {
            if (ScriptRestriction.isScriptUser() = true)
                persistentObj[persistentID].actionAddedByUser := true
        }

        PersistentGUI.loadPersistentListLV()

        _ListviewHandler.selectRow("LV_PersistentList", persistentID, defaultGUI := "CavebotGUI")
        PersistentGUI.loadPersistentGuiElements(persistentID)
        this.checkDeleteButton()

        this.savePersistent()
    }

    savePersistentOptions() {
        Gui, CavebotGUI:Default
        Gui, CavebotGUI:Submit, NoHide
        GuiControlGet, persistentID

        if (persistentID = "")
            throw Exception("No persistent selected.")

        for key, control in PersistentGUI.controls
        {
            try GuiControlGet, %control%
            catch {
            }
        }

        try HealingHandler.validateHealingHotkey("persistentHotkey", persistentHotkey)
        catch e
            throw e

        if persistentinterval is not Number
            throw Exception("Interval must be a number.")

        /**
        if (persistentHealPercent < 5 OR persistentHealPercent > 99)
        throw Exception("Invalid percentage value for Player HP %, min: 5, max: 99.")
        */

        for key, option in this.persistentOptions
        {
            if (option = "userValue")
                continue
            value := persistent%option%
            if value is Number
                value += 0
            persistentObj[persistentID][option] := value
        }

        persistentObj[persistentID].action := (persistentObj[persistentID].action = A_Space) ? "" : persistentObj[persistentID].action

        if (InStr(persistentinterval, "."))
            persistentObj[persistentID].interval := persistentinterval
        else
            persistentObj[persistentID].interval := persistentinterval += 0

        switch persistentObj[persistentID].enabled {
            case 1:
            case 0:
        }

        PersistentGUI.updatePersistentRow(persistentID)
        PersistentGUI.resizeColumns()

        this.savePersistent(saveCavebotScript := true)
    }

    savePersistentUserValue() {

        Gui, EditPersistentUserValueGUI:Default
        Gui, EditPersistentUserValueGUI:Submit, NoHide
        Gui, EditPersistentUserValueGUI:Hide

        /**
        validation first
        */
        Loop, 10 {
            key := persistentUserKey%A_Index%
            value := persistentUserValue%A_Index%
            if (key = "")
                continue

            switch persistentObj[persistentID].action {
                case "Click on image":
                    if (key = "button") && (value != "Left" && value != "Right")
                        throw Exception("""button"" value must be ""Left"" or ""Right"".")
                case "Press hotkey if image":
                    if (key = "condition") && (value != "is found" && value != "is not found")
                        throw Exception("""condition"" value must be ""is found"" or ""is not found"".")

            }

            if (key = "image") {
                if (value = "")
                    throw Exception("Empty ""image"" value.", "Save User Value")

                images := StrSplit(value, "|")

                if (images.Count() < 1)
                    throw Exception("Empty ""image"" value.", "Save User Value")

                for key, imageName in images
                {
                    imageName := LTrim(RTrim(imageName))
                    if (!scriptImagesObj[imageName]) {
                        CavebotGUI.createScriptImagesGUI()
                        throw Exception("Image """ imageName """ doesn't exist in the Script Images list.", "Save User Value")
                    }
                }
            }

            if (key = "hotkey") {
                try HealingHandler.validateHealingHotkey("", value)
                catch e
                    throw e
            }
        }

        ; m(persistentActionScript)
        ; if (persistentActionScript != "") {

        ;     WaypointValidation.validateAction(atributeValue, tabName, waypointNumber)

        ; }

        persistentObj[persistentID]["userValue"] := {}
        Loop, 10 {
            if (persistentUserKey%A_Index% = "")
                continue

            key := removeSpecialCharacters(persistentUserKey%A_Index%, TelegramAPI.characterExceptions), value := removeSpecialCharacters(persistentUserValue%A_Index%, TelegramAPI.characterExceptions)
            if (key = "condition")
                value := persistentUserValue%A_Index%
            ; msgbox, % key " = " value

            persistentObj[persistentID]["userValue"].Push(Object(key, value))
        }
        persistentObj[persistentID]["userValue"].actionScript := persistentActionScript

        ; msgbox, % serialize(persistentObj[persistentID].userValue)
        ; persistentObj[persistentID].userValue := alertUserValue

        PersistentGUI.updatePersistentRow(persistentID)
        PersistentGUI.resizeColumns()

        PersistentHandler.savePersistent(saveCavebotScript := true)
    }

    countScreenshotsPersistentFolder() {
        count := 0
        loop, % this.persistentScreenshotFolder "\*.png"{
            count++
        }
        return count
    }

    editPersistentActionScript() {
        Gui, CavebotGUI:Default
        Gui, ListView, LV_PersistentList
        persistentID := _ListviewHandler.getSelectedItemOnLV("LV_PersistentList", column := 1, defaultGUI := "CavebotGUI", returnRow := false)
        if (persistentID = "" OR persistentID = "ID")
            return

            new _ActionScriptGUI("Persistent", persistentID, persistentObj[persistentID].actionScript).open()
    }


    setDefaultActionValues(persistentID, action, fromInitialCheck := false) {

        if (persistentID = "")
            return
        ; throw Exception("No persistent selected.")

        if (persistentObj[persistentID].action != "" && persistentObj[persistentID].action != "none")
            return

        ; msgbox, % persistentID "`n" action "`n" serialize(persistentObj[persistentID])
        persistentObj[persistentID].action := action
        persistentObj[persistentID].userValue := {}
        switch action {
            case "Action Script":
                persistentObj[persistentID].interval := 1
            case "Click on image":
                persistentObj[persistentID].interval := 10
                persistentObj[persistentID].userValue.Push({"button": "Right"})
                persistentObj[persistentID].userValue.Push({"image": ""})
                persistentObj[persistentID].userValue.Push({"holdCtrl": "false"})
                persistentObj[persistentID].userValue.Push({"delayAfterClick": 500})
                persistentObj[persistentID].userValue.Push({"searchArea": this.defaultSearchArea})
            case "Click on position":
                persistentObj[persistentID].interval := 10
                persistentObj[persistentID].userValue.Push({"button": "Right"})
                persistentObj[persistentID].userValue.Push({"x": "500"})
                persistentObj[persistentID].userValue.Push({"y": "500"})
                ; persistentObj[persistentID].userValue.Push({"clientID": ""})
                persistentObj[persistentID].userValue.Push({"holdCtrl": "false"})
            case "Convert gold":
                persistentObj[persistentID].interval := 1
                persistentObj[persistentID].userValue.Push({"hotkey": ""})
            case "Dance (anti-idle)":
                persistentObj[persistentID].interval := 180
                ; persistentObj[persistentID].userValue.Push({"clientID": ""})
            case "Go to label if itemcount":
                persistentObj[persistentID].interval := 10
                persistentObj[persistentID].userValue.Push({"label": "LeaveHunt"})
                persistentObj[persistentID].userValue.Push({"item": "mana potion"})
                persistentObj[persistentID].userValue.Push({"condition": "<"})
                persistentObj[persistentID].userValue.Push({"value": "50"})
            case "Press hotkey":
                persistentObj[persistentID].interval := 2
                persistentObj[persistentID].userValue.Push({"hotkey": "F1"})
                ; persistentObj[persistentID].userValue.Push({"clientID": ""})
            case "Press hotkey if image":
                persistentObj[persistentID].interval := 2
                persistentObj[persistentID].userValue.Push({"condition": "is found"})
                persistentObj[persistentID].userValue.Push({"hotkey": "F1"})
                persistentObj[persistentID].userValue.Push({"image": "image1 | image2"})
                persistentObj[persistentID].userValue.Push({"delayAfterKeyPress": 500})
                persistentObj[persistentID].userValue.Push({"searchArea": this.defaultSearchArea})
            case "Run file":
                persistentObj[persistentID].interval := 2
                persistentObj[persistentID].userValue.Push({"directory": "file_xxx.ahk"})
            case "Save screenshot":
                persistentObj[persistentID].interval := 60
            case "Telegram message":
                persistentObj[persistentID].interval := 60
                persistentObj[persistentID].userValue.Push({"message": "test message."})
            case "Telegram screenshot":
                persistentObj[persistentID].interval := 60
            case "Use item":
                persistentObj[persistentID].interval := 10
                persistentObj[persistentID].userValue.Push({"item": "fish"})
        }

        ; msgbox, % persistentID "`n" action "`n" serialize(persistentObj[persistentID])
        if (fromInitialCheck = true)
            return
        PersistentGUI.updatePersistentRow(persistentID)
        PersistentGUI.resizeColumns()

    }

}
