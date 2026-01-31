
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Action Script\Actions\_AbstractActionScript.ahk

class _SetSettingAction extends _AbstractActionScript
{
    static IDENTIFIER := "setsetting"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return bool
    */
    runAction()
    {
        functionValues := this.values
        writeCavebotLog("Action", ActionScript.string_log)

        if (!InStr(functionValues.1, "/")) {
            this.error("Wrong setting path format")
            return false
        }

        settingPath := StrSplit(functionValues.1, "/")
            , mainSetting := settingPath.1
            , lastChildNumber := settingPath.Count() - 1
            , childSettings := _ActionScriptValidation.createChildSettings(settingPath, tab, Waypoint)

        params := {}
            , params.value := functionValues.2
            , params := this.checkParamsVariables(params)

        info := mainSetting " | value: " params.value " | " lastChildNumber
        this.info(mainSetting " | value: " params.value " | " lastChildNumber)
        try {
            Loop, 2 {
                success := this.setChildSettingValue(params.value, lastChildNumber, mainSetting, childSettings.1, childSettings.2, childSettings.3, childSettings.4, childSettings.5)
                if (success) {
                    break
                }

                Sleep, 1000
            }
        } catch e {
            this.error(e.Message " | info: " info " | params: " se(params))
            return false
        }

        if (!success) {
            this.error("Error setting value to setting, status: " success " | params: " se(params))
            return false
        }

        if (InStr(functionValues.1, "targeting/") && InStr(functionValues.1, "/danger")) {
            TargetingSystem.createCreaturesDangerObj(loadImages := false)
        }

        return true
        if (params.value == 1 || params.value = 0) {
            exe := this.getExecutable(mainSetting)
            if (exe) {
                params.value = 1 ? exe.start() : exe.stop()
                return true
            }

            for key, oldbotModule in OldBotSettings.modulesList
            {
                if (!InStr(mainSetting, oldbotModule)) {
                    continue
                }

                exe := new _ExeFactory(oldbotModule)
                params.value = 1 ? exe.start() : exe.stop()
                return true
            }
        }

        return true
    }

    setChildSettingValue(value, childNumber, mainSetting, childSetting1 := "", childSetting2 := "", childSetting3 := "", childSetting4 := "", childSetting5 := "")
    {
        /*
        write in the JSON the new object if is not one of the Cavebot objects(that will have new new variable value read from memory)
        */

        writeJson := false
        if (InArray(this.settingsWriteJson, mainSetting) != 0 || this.getExecutable(mainSetting))
            writeJson := true
        ; msgbox, % writeJson
        switch mainSetting {
            case "reconnect":
                if (childSetting1 = "autoReconnect")
                    IniWrite, % value, %DefaultProfile%, settings, autoReconnect
        }
        ; msgbox, % A_ThisFunc " " serialize(%mainSetting%Obj)
        switch childNumber {
            case 1:
                %mainSetting%Obj[childSetting1] := value
                ; msgbox, % %mainSetting%Obj[childSetting1]
                if (writeJson = true)
                    return this.writeJsonObject(mainSetting, mainSetting "/" childSetting1, value)
                return true
            case 2:
                %mainSetting%Obj[childSetting1][childSetting2] := value
                if (writeJson = true)
                    return this.writeJsonObject(mainSetting, mainSetting "/" childSetting1 "/" childSetting2, value)
                return true
            case 3:
                %mainSetting%Obj[childSetting1][childSetting2][childSetting3] := value
                if (writeJson = true)
                    return this.writeJsonObject(mainSetting, mainSetting "/" childSetting1 "/" childSetting2 "/" childSetting3, value)
                return true
            case 4:
                %mainSetting%Obj[childSetting1][childSetting2][childSetting3][childSetting4] := value
                if (writeJson = true)
                    return this.writeJsonObject(mainSetting, mainSetting "/" childSetting1 "/" childSetting2 "/" childSetting3 "/" childSetting4, value)
                return true
            case 5:
                %mainSetting%Obj[childSetting1][childSetting2][childSetting3][childSetting4][childSetting5] := value
                if (writeJson = true)
                    return this.writeJsonObject(mainSetting, mainSetting "/" childSetting1 "/" childSetting2 "/" childSetting3 "/" childSetting4 "/" childSetting5, value)
                return true
        }

        this.error("Invalid child number: " childNumber)
        return false
    }

    writeJsonObject(setting, settingPath, value)
    {
        scriptFile[setting] := %setting%Obj
        ; CavebotScript.saveSettings(A_ThisFunc)
        Sleep, 1000
        /*
        return false from Send_WM_COPYDATA if OldBot.exe returns false in the message
        */
        ; msgbox, % A_ThisFunc "`n " setting " = " settingPath " = " value
        return Send_WM_COPYDATA("setsetting" "|" setting "|" settingPath "|" value, SendMessageTargetWindowTitle, 2000)
    }

    getExecutable(setting)
    {
        try {
            return new _ExeFactory(setting)
        } catch {
        }
    }

}