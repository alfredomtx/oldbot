
Class _AlertsHandler
{
    __New()
    {
        global

        this.alertsUserValuesAmount := 14

        this.alertsList := {}
        this.alertsList.Push("Battle list not empty")
        this.alertsList.Push("Disconnected")
        this.alertsList.Push("Image is found 1")
        this.alertsList.Push("Image is not found 1")
        this.alertsList.Push("Not listed target")
        this.alertsList.Push("Private message")
        this.alertsList.Push("Player on Battle List")
        this.alertsList.Push("PK on screen")

        ; this.alertsList.Push("Character stuck")
        ; this.alertsList.Push("Health below") := {}
        ; this.alertsList.Push("Mana below") := {}



        this.alertsParams := {}
        this.alertsParams.Push("enabled")
        this.alertsParams.Push("exitGame")
        this.alertsParams.Push("goToLabel")
        this.alertsParams.Push("labelName")
        this.alertsParams.Push("logout")
        this.alertsParams.Push("pauseCavebot")
        this.alertsParams.Push("playSound")
        this.alertsParams.Push("screenshot")
        this.alertsParams.Push("telegram")
        this.alertsParams.Push("userValue")


        this.loadAlertsSettings()
    }

    submitAlertOption() {


    }

    loadAlertsSettings() {
        global 

        ; msgbox, % serialize(alertsObj)
        this.checkDefaultAlertsSettings()

    }


    checkDefaultAlertsSettings() {
        if (!IsObject(alertsObj.settings))
            alertsObj.settings := {}

        this.minAlertDelay := 1
        this.maxAlertDelay := 2000

        alertsObj.settings.delay := alertsObj.settings.delay = "" ? this.minAlertDelay : alertsObj.settings.delay
        alertsObj.settings.delay := alertsObj.settings.delay < this.minAlertDelay ? this.minAlertDelay : alertsObj.settings.delay
        alertsObj.settings.delay := alertsObj.settings.delay > this.maxAlertDelay ? this.maxAlertDelay : alertsObj.settings.delay

        /**
        delete invalid alerts
        */
        Loop, {
            noneDeleted := true
            for alertName, alert in alertsObj
            {
                if (alertName = "settings") {
                    validAlert := true
                    continue
                }
                deleted := false
                if alertName is number
                {
                    alertsObj.Delete(alertName)
                    ; msgbox, % A_LineNumber " = " alertName
                    deleted := true
                    break
                }

                if (!InStr(alertName, " ")) && (alertName != "Disconnected") {
                    alertsObj.Delete(alertName)
                    ; msgbox, % A_LineNumber " = " alertName
                    deleted := true
                    break
                }

                /**
                alerts not in the list
                */
                validAlert := false
                for key, alertNameList in this.alertsList
                {
                    if (InStr(alertName, "Image is ")) {
                        validAlert := true
                        break
                    }
                    ; m(alertName  " != "  alertNameList)
                    if (alertName = alertNameList) {
                        validAlert := true
                        break
                    }
                }
                if (validAlert = false) {
                    alertsObj.Delete(alertName)
                    ; msgbox, % A_LineNumber " = " alertName
                    deleted := true
                    break
                }
            }
            if (deleted = true)
                noneDeleted := false

            if (noneDeleted = true)
                break
        } ; Loop

        this.addDefaultAlerts()

        for alertName, alert in alertsObj
        {
            if (!IsObject(alertsObj[alertName]))
                alertsObj[alertName] := {}

            this.setDefaultAlertActionValues(alertName, updateListview := false)
        }



    }

    addDefaultAlerts() {
        for key, alertName in this.alertsList
        {
            if (IsObject(alertsObj[alertName]))
                continue
            alertsObj[alertName] := {}
            this.setDefaultAlertActionValues(alertName, updateListview := false)
            ; m(serialize(alertsObj))
        }
    }

    saveAlertsUserValue(alertName) {
        static exceptionChars

        Gui, EditUserValueGUI:Default
        Gui, EditUserValueGUI:Submit, NoHide
        Gui, EditUserValueGUI:Hide

        /**
        validation first
        */
        Loop, % this.alertsUserValuesAmount {
            key := userKey%A_Index%
            value := userValue%A_Index%
            ; msgbox, % alertName "`n" key " = " value
            if (key = "")
                continue

            switch alertName {
                case "Disconnected":
                    if (key = "say")
                        throw Exception("""Disconnected"" alert cannot use the ""say"" function.", "Save User Value")
                default:
                    if (InStr(alertName, "Image is found")) OR (InStr(alertName, "Image is not found")) {
                        if (key = "image") {
                            if (value = "") {
                                continue
                                throw Exception("Empty ""image"" value.", "Save User Value")
                            }

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
                    }
            } ; switch
        }


        alertsObj[alertName]["userValue"] := {}
        Loop, % this.alertsUserValuesAmount {
            if (userKey%A_Index% = "")
                continue

            if (exceptionChars = "") {
                exceptionChars := {}
                exceptionChars.Push("!")
                exceptionChars.Push("?")
                exceptionChars.Push("\")
                for key, value in TelegramAPI.characterExceptions
                    exceptionChars.Push(value)
            }

            key := removeSpecialCharacters(userKey%A_Index%, exceptionChars), value := removeSpecialCharacters(userValue%A_Index%, exceptionChars)
            ; msgbox, % key " = " value

            alertsObj[alertName]["userValue"].Push(Object(key, value))
        }


        ; msgbox, % serialize(persistentObj[persistentID].userValue)
        ; persistentObj[persistentID].userValue := alertUserValue

        AlertsHandler.saveAlerts(saveCavebotScript := true)
        AlertsGUI.updateAlertRow(alertName)
    }

    saveAlerts(saveCavebotScript := true) {
        scriptFile.alerts := alertsObj
        if (saveCavebotScript = true)
            CavebotScript.saveSettings(A_ThisFunc)
    }

    enableAlert(alertName) {
        GuiControl, CavebotGUI:, alertEnabled, % AlertsGUI.disabledText
        GuiControl, CavebotGUI:, alertEnabled, 1
        checkbox_setvalue(this.getShortcutAlertName(alertName), 1)
    }

    disableAlert(alertName) {
        GuiControl, CavebotGUI:, alertEnabled, % AlertsGUI.enabledText
        GuiControl, CavebotGUI:, alertEnabled, 0
        checkbox_setvalue(this.getShortcutAlertName(alertName), 0)
    }

    getShortcutAlertName(alertName)
    {
        return "Alert" StrReplace(alertName, " ","")
    }

    changeAlertEnabled(alertName, save := false, run := false)
    {
        if (alertsObj[alertName].enabled = 1) {
            this.enableAlert(alertName) 
        } else {
            this.disableAlert(alertName) 
        }
        if (save = true) {
            this.saveAlerts(saveCavebotScript := true)
            AlertsGUI.updateAlertRow(alertName)
        }
        if (run = true)
            this.runAlertsExe()
    }

    hasAlertEnabled() {
        for alertName, alert in alertsObj
        {
            if (alertsObj[alertName].enabled = true)
                return true
        }
        return false

    }

    runAlertsExe() {
        _AlertsExe.start()
    }

    checkAlertUserValue(alertName, key, defaultValue := "") {
        hasUserValue := false
        for index, values in alertsObj[alertName]["userValue"]
        {
            for k, value in values
            {
                if (k = key) {
                    hasUserValue := true, alertsObj[alertName]["userValue"][index][key] := (alertsObj[alertName]["userValue"][index][key] = "") ? defaultValue : alertsObj[alertName]["userValue"][index][key]
                    break
                }
            }
        }
        if (hasUserValue = false)
            alertsObj[alertName].userValue.Push({(key): defaultValue})
    }

    setDefaultAlertActionValues(alertName, updateListview := false) {

        if (alertName = "settings")
            return
        if (alertName = "")
            return
        ; throw Exception("No alert selected.")


        if (alertsObj[alertName].alertName != "" && alertsObj[alertName].alertName != "none")
            return

        for key, param in this.alertsParams
        {
            switch param {
                case "enabled":      alertsObj[alertName][param] := (alertsObj[alertName][param] = "" && alertsObj[alertName][param] != false) ? 0 : alertsObj[alertName][param]
                case "exitGame":     alertsObj[alertName][param] := (alertsObj[alertName][param] = "" && alertsObj[alertName][param] != false) ? 0 : alertsObj[alertName][param]
                case "logout":       alertsObj[alertName][param] := (alertsObj[alertName][param] = "" && alertsObj[alertName][param] != false) ? 0 : alertsObj[alertName][param]
                case "pauseCavebot":     alertsObj[alertName][param] := (alertsObj[alertName][param] = "" && alertsObj[alertName][param] != false) ? 0 : alertsObj[alertName][param]
                case "goToLabel":     alertsObj[alertName][param] := (alertsObj[alertName][param] = "" && alertsObj[alertName][param] != false) ? 0 : alertsObj[alertName][param]
                case "playSound":    alertsObj[alertName][param] := (alertsObj[alertName][param] = "" && alertsObj[alertName][param] != false) ? 1 : alertsObj[alertName][param]
                case "screenshot":   alertsObj[alertName][param] := (alertsObj[alertName][param] = "" && alertsObj[alertName][param] != false) ? 0 : alertsObj[alertName][param]
                case "telegram":     alertsObj[alertName][param] := (alertsObj[alertName][param] = "" && alertsObj[alertName][param] != false) ? 0 : alertsObj[alertName][param]
                case "userValue":
                    alertsObj[alertName][param] := alertsObj[alertName][param]
                    if (!IsObject(alertsObj[alertName][param]))
                        alertsObj[alertName][param] := {}
            }

            ; alertsObj[alertName].enabled := 0

            ; msgbox, %  alertName " / " param " / " alertsObj[alertName][param]
        }

        if (!IsObject(alertsObj[alertName].userValue))
            alertsObj[alertName].userValue := {}

        switch alertName {
            case "Disconnected":
                alertsObj[alertName].logout := 0, alertsObj[alertName].exitGame := 0
            default:
                if (InStr(alertName, "Image is found")) OR (InStr(alertName, "Image is not found")) {
                    this.checkAlertUserValue(alertName, "image", "")
                    this.checkAlertUserValue(alertName, "searchArea", "window")
                }
        }

        /**
        Disconnected do not have other params
        */
        if (alertName = "Disconnected") {
            this.checkAlertUserValue(alertName, "ignoreIfCurrentWaypointTab", "")
            goto, skipAlertValueCheck
        }

        this.checkAlertUserValue(alertName, "say", "false")

        switch alertName {
            case "PK on screen":
                this.checkAlertUserValue(alertName, "messages", "hey | stop please")
            case "Not listed target":
                this.checkAlertUserValue(alertName, "messages", "hi | leaving soon")
            default:
                this.checkAlertUserValue(alertName, "messages", "")

        }

        this.checkAlertUserValue(alertName, "delay", 500)
        this.checkAlertUserValue(alertName, "cooldown", 60)

        this.checkAlertUserValue(alertName, "pressKey", "")
        this.checkAlertUserValue(alertName, "pressKeyDelay", "250")
        this.checkAlertUserValue(alertName, "pressKeyCooldown", "2")

        this.checkAlertUserValue(alertName, "ignoreIfCurrentWaypointTab", "")
        this.checkAlertUserValue(alertName, "ignoreInProtectionZone", "false")
        this.checkAlertUserValue(alertName, "unpauseBotAfter", 60)
        this.checkAlertUserValue(alertName, "runFile", "")
        this.checkAlertUserValue(alertName, "closeCavebot", "false")

        skipAlertValueCheck:

        if (updateListview = true)
            return
        ; msgbox, % alertName "`n" action "`n" serialize(alertsObj[alertName])
        AlertsGUI.updateAlertRow(alertName)
        AlertsGUI.resizeColumns()
    }

    deleteAlert() {
        alertName := AlertsGUI.getSelectedAlert()
        if (alertName = "")
            return


        if (alertName = "Image is found 1") OR (alertName = "Image is not found 1") {
            Msgbox, 64,, % "You cannot delete the Alert number 1.", 4
            return
        }

        GetKeyState, CtrlPressed, Ctrl, D
        if (CtrlPressed != "D") {
            Msgbox, 52,, % "Delete Alert """ alertName """?"
            IfMsgBox, No
                return
        }
        ; if (alertsObj.Count() > 1) {
        ;     alertRow := _ListviewHandler.findRowByContent(alertName, 1, "LV_AlertsList")
        ; }

        try alertsObj.Delete(alertName)
        catch {
        }

        AlertsGUI.loadAlertsListLV()

        GuiControl,, alertName, % ""

        ; _ListviewHandler.selectRow("LV_AlertsList", alertRow - 1)

        this.saveAlerts()
    }


    addNewAlert() {


        alertName := AlertsGUI.getSelectedAlert()
        ; m("alertName = " alertName)
        if (alertName = "")
            return

        if (!InStr(alertName, "Image is "))
            return

        alertRow := _ListviewHandler.findRowByContent(alertName, 1, "LV_AlertsList")

        lastAlertNumber := this.getLastImageAlertNumber(alertName)
        ; m("lastAlertNumber = " lastAlertNumber)
        nextAlertNumber := lastAlertNumber + 1

        ; m("nextAlertNumber = " nextAlertNumber)

        if (InStr(alertName, "Image is found")) {
            newAlertName := "Image is found "  nextAlertNumber
        } else {
            newAlertName := "Image is not found "  nextAlertNumber
        }

        ; m("newAlertName = " newAlertName)


        alertsObj[newAlertName] := {}
        this.setDefaultAlertActionValues(newAlertName, updateListview := true)

        AlertsGUI.loadAlertsListLV()


        _ListviewHandler.selectRow("LV_AlertsList", alertRow)

        this.saveAlerts()
    }

    getLastImageAlertNumber(alertName) {

        StringTrimRight, alertNameSearch, alertName, 3

        alertCounter := 1
        alertNumber := 0
        for alertName, atributes in alertsObj
        {
            if (InStr(alertName, alertNameSearch)) {
                if (InStr(alertName, "Image is found")) {
                    alertString := "Image is found "
                } else {
                    alertString := "Image is not found "
                }
                alertNumber := StrReplace(alertName, alertString, "")
                ; msgbox, % alertString "" alertCounter
                if (!IsObject(alertsObj[alertString "" alertCounter]))
                    return alertCounter - 1
                alertCounter++
            }
        }
        return alertNumber
    }


    checkBeforeEnabling(alertName)
    {
        if (alertsObj[alertName].enabled = 0)
            return

        try TibiaClient.checkClientSelected()
        catch e {
            throw Exception(e.Message, 2)
        }
    }


}
