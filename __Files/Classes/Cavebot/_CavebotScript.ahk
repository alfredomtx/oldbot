workingDir := A_WorkingDir
if (InStr(workingDir, "Data\Executables"))
    workingDir := StrReplace(workingDir, "Data\Executables", ""), workingDir := StrReplace(workingDir, "Data\Executables\", "")
SetWorkingDir, % workingDir

global currentScript
global currentScriptRestricted

global loadingGuisDisabledScriptLoad := false

global alertsObj
global fishingObj
global fullLightObj
global healingObj
global lootingObj
global itemRefillObj
global hotkeysObj
global persistentObj
global reconnectObj
global scriptFile
global scriptFileObj
global scriptImagesObj
global scriptVariablesObj
global scriptSettingsObj
global selectedFunctionsObj
global supportObj
global sioFriendObj
global targetingObj
global waypointsObj
global waypointsJSON

global ScriptTabsList := {}
global ScriptTabsListDropdown := ""

global userOptionVariablesObj := {}

; dont remove
global startWaypoint
global startTab

global selectedScript


Class _CavebotScript
{
    __New(scriptName := "Default", loadDefaultOnFail := true, fromCavebotInstance := false)
    {

        if (!IsObject(Encryptor)) {
            throw Exception("Encryptor not initialized")
        }
        /**
        initial state of the var, that means wasn't check if the script is or isn't encrypted
        */
        this.isEncrypted := -1

        this.objectsList := {}

        this.objectsList.Push("alerts")
        this.objectsList.Push("fishing")
        this.objectsList.Push("fullLight")
        this.objectsList.Push("healing")
        this.objectsList.Push("itemRefill")
        this.objectsList.Push("looting")
        this.objectsList.Push("hotkeys")
        this.objectsList.Push("persistent")
        this.objectsList.Push("reconnect")
        this.objectsList.Push("scriptImages")
        this.objectsList.Push("scriptSettings")
        this.objectsList.Push("scriptVariables")
        this.objectsList.Push("selectedFunctions")
        this.objectsList.Push("support")
        this.objectsList.Push("sioFriend")
        this.objectsList.Push("targeting")
        this.objectsList.Push("waypoints")

        if (!FileExist(A_Temp "\OldBot"))
            FileCreateDir, % A_Temp "\OldBot"
        if (!FileExist("Cavebot\default.json")) {
            file := FileOpen("Cavebot\default.json", "w")
            file.Write("{""waypoints"": {}}")
            file.Close()
        }

        this.tempScriptFolder := A_Temp "\wintemp"

        if (!FileExist(this.tempScriptFolder))
            FileCreateDir, % this.tempScriptFolder

        this.loadScript(scriptName, true, loadDefaultOnFail, fromCavebotInstance)
    }

    loadScript(scriptName, startLoad := false, loadDefaultOnFail := true, fromCavebotInstance := false) {
        OldBotSettings.disableGuisLoading()
        loadingGuisDisabledScriptLoad := true

        if (startLoad = false)
            CarregandoGUI(LANGUAGE = "PT-BR" ? "Carregando script, por favor aguarde..." : "Loading script, please wait...", 250, 250)

        currentScript := scriptName

        if (currentScript = "")
            currentScript := "Default"

        this.loadScriptFile(loadDefaultOnFail)

        if (fromCavebotInstance = false)
            OldbotSettings.setCurrentScript(currentScript)

        tab := "Waypoints"
        this.createObjects()
        this.createScriptTabsList()
        this.loadScriptSettings()
        this.checkDefaultScriptSettings()
        this.createUserOptionVariablesObj()

        /**
        check if is allowed to use script, if isn't, load default script instead
        */
        if (startLoad = false) && (A_IsCompiled) {
            try ScriptRestriction.checkAllowedToUse()
            catch {
                loadingGuisDisabledScriptLoad := false
                OldBotSettings.enableGuisLoading()
                Gui, Carregando:Destroy
                Msgbox, 64,, % txt("Carregando o script ""Default"" no lugar.", "Loading ""Default"" script instead.") , 20
                this.loadScript("Default")
            }
        }

        /**
        in case the script is blank and it's the start load
        need to save the script to create the file structure again

        way to simulate this: load "default" script, delete it's file and reload bot
        */
        if (startLoad = false OR this.blankScript = true) {
            AlertsHandler.loadAlertsSettings()
            FishingHandler.loadFishingSettings()
            FullLightHandler.loadFullLightSettings()
            HealingHandler.loadHealingSettings()
            ItemRefillHandler.loadItemRefillSettings()
            LootingHandler.loadLootingSettings()
            HotkeysHandler.loadHotkeysSettings()
            PersistentHandler.loadPersistentSettings()
            SupportHandler.loadSupportSettings()
            TargetingHandler.loadTargetingSettings()
            WaypointHandler.loadWaypointSettings()

            AlertsHandler.saveAlerts(false)
            FishingHandler.saveFishing(false)
            FullLightHandler.saveFullLight(false)
            HealingHandler.saveHealing(false)
            ItemRefillHandler.saveItemRefill(false)
            LootingHandler.saveLooting(false)
            HotkeysHandler.saveHotkeys(false)
            PersistentHandler.savePersistent(false)
            _Sio.saveSioFriend(false)
            SupportHandler.saveSupport(false)
            TargetingHandler.saveTargeting(false)
            WaypointHandler.saveWaypoints(false)
            this.saveScriptSettings(false, A_ThisFunc)

            ; msgbox, % serialize(scriptFileObj)


            this.saveSettings(A_ThisFunc)

            ; close all functions because of new settings
            if (this.blankScript = true)
                return
        }

        if (startLoad = false) {
            CloseAllProcesses(closeProcessMonitor := true)
            OldbotSettings.autoStartFunctions()
            OldBotSettings.openProcessMonitor()
        }

        loadingGuisDisabledScriptLoad := false
        OldBotSettings.enableGuisLoading()
    }

    Reload() {
        Random, 0, 2
        Sleep, %R%000
        OutputDebug(A_ThisFunc, A_ScriptName)
        Reload
        return
    }

    loadScriptFile(loadDefaultOnFail := true) {
        fileDir := A_WorkingDir "\Cavebot\" currentScript ".json"
        loadDefault := false

        ; msgbox, % currentScript "`n" fileDir
        try this.validateScriptName(currentScript)
        catch e {
            if (loadDefaultOnFail = true) {
                Gui, Carregando:Destroy
                Msgbox, 48,, % e.Message ".`n`nLoading ""Default"" script instead."
                loadDefault := true
            } else {
                this.Reload()
                return
            }
        }

        if (loadDefault = false) {
            if (!FileExist(fileDir) && (currentScript != "Default")) {
                if (loadDefaultOnFail = true) {
                    Gui, Carregando:Destroy
                    msgbox, 48, % A_ScriptName "." A_ThisFunc, % "Script JSON file doesn't exist: " fileDir ".`n`nLoading ""Default"" script instead."
                    loadDefault := true
                } else {
                    this.Reload()
                    return
                }
            }
        }

        if (loadDefault = false) {
            this.isEncrypted := -1
            try this.isEncryptedScript(currentScript, A_ThisFunc)
            catch e {
                ; Msgbox, 48, % A_ScriptName "." A_ThisFunc,  % e.Message "`n" e.What "`n" e.File "`n" e.Line
                Msgbox, 48, % A_ScriptName "." A_ThisFunc, % "Failed to check script encryption:`n`n" e.Message "`n" e.What
                this.Reload()
                return false
            }
        }

        if (this.isEncrypted = false && loadDefault = false) {
            scriptContent := this.fileReadScript(currentScript)

            this.blankScript := false
            if (scriptContent = "") {
                if (loadDefaultOnFail = true) {
                    try {
                        Run, Cavebot\Backups
                        Sleep, 2000
                    }
                    catch {
                    }
                    Gui, Carregando:Destroy
                    msgbox, 48, % A_ScriptName "." A_ThisFunc, % LANGUAGE = "PT-BR" ? "(" this.isEncrypted ") " "Arquivo JSON do Script está em branco(" filedir "), é possível que o arquivo possa ter sido corrompido por algum motivo.`nVocê pode pegar o backup do script na pasta Backups dentro da pasta Cavebot.`n`nAgora o bot irá carregar o script ""Default"" no lugar." : "(" this.isEncrypted ") " "Script JSON file is blank(" fileDir "), it's possible that it got corrupted for some reason.`nYou can get a backup of the script in the Backups folder inside the Cavebot folder.`n`nNow the bot will load ""Default"" script instead."
                    this.blankScript := true
                    loadDefault := true
                } else {
                    this.Reload()
                    return
                }
            }
            VarSetCapacity(scriptContent, 0), scriptContent := ""
        }

        if (loadDefault = true) {
            currentScript := "Default", fileDir := A_WorkingDir "\Cavebot\" currentScript ".json"
            OldbotSettings.setCurrentScript(currentScript)
        }

        try scriptFile := this.loadScriptJSON(currentScript, openJsonLint := true)
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 48, % A_ScriptName "." A_ThisFunc,  % "(" this.isEncrypted ") " txt("Falha ao carregar o script:`n", "Failed to load script:") "`n" e.Message "`n" e.What "`n" fileDir, 20
            reload
            return false
        }
        ; if (deleteTempFile = true)
        ; this.deleteTempScriptFile(currentScript, A_ThisFunc)
        if (scriptFile = false) {
            Gui, Carregando:Destroy
            msgbox, 48, % A_ScriptName "." A_ThisFunc, % "(" this.isEncrypted ") " "Failed to load script: " currentScript "`n`n" fileDir ".", 20
            Reload
            return false
        }
    }

    loadScriptJSON(scriptName, openJsonLint := true, returnObj := false, throwException := false) {
        fileDir := A_WorkingDir "\Cavebot\" scriptName ".json"

        if (!FileExist(fileDir) && (scriptName != "Default"))
            throw Exception("Script file doesn't exist: " fileDir)

        scriptContent := this.fileReadScript(scriptName)

        ; msgbox, % scriptContent
        if (scriptContent = "") && (scriptName != "Default")
            throw Exception("Empty scriptContent: " fileDir)
        VarSetCapacity(scriptContent, 0), scriptContent := ""

        currentScriptRestricted := false

        this.isEncrypted := -1
        try this.isEncryptedScript(currentScript, A_ThisFunc)
        catch e {
            ; Msgbox, 48, % A_ScriptName "." A_ThisFunc,  % e.Message "`n" e.What "`n" e.File "`n" e.Line
            if (throwException = true)
                throw Exception("Failed to check script encryption: " e.Message " | " e.What)
            Msgbox, 48, % A_ScriptName "." A_ThisFunc, % "Failed to check script encryption:`n`n" e.Message "`n" e.What
            this.Reload()
            return false
        }

        ; msgbox, % A_ThisFunc " = " this.isEncrypted
        switch this.isEncrypted {
            case true:
                ; msgbox, loading encrypted script
                currentScriptRestricted := true
                try scriptFileObj := this.decryptScript(scriptName, this.uncryptedFileDir, A_ThisFunc)
                catch e {
                    message := "(" this.isEncrypted ") " txt("Falha ao carregar o JSON do script atual, algo está errado com a sintaxe do código JSON no arquivo.", "Failed to load the JSON of the current script, something is wrong with the JSON code syntax in the file.")
                    if (throwException = true)
                        throw Exception(message " | " e.Message " | " e.What " | " fileDir)
                    Gui, Carregando:Destroy
                    if (A_IsCompiled)
                        Msgbox, 48, % A_ScriptName "." A_ThisFunc,  % message  "`n" e.Message "`n" e.What "`n" fileDir, 20
                    else
                        Msgbox, 48, % A_ScriptName "." A_ThisFunc,  % e.Message "`n" e.What "`n" e.File "`n" e.Line
                    return false
                }
                ; msgbox, % serialize(scriptFileObj)
                return scriptFileObj
        }



        try {
            scriptJsonFile := new JSONFile(fileDir)
        } catch, e {
            if (openJsonLint = false)
                throw Exception("Failed to load scriptJsonFile")

            Run, https://jsonlint.com/
            Sleep, 2000
            FileRead, fileContent, % fileDir
            try {
                ClipBoard := fileContent
                Send, ^v
            }
            catch {
            }
            OldbotSettings.setCurrentScript("Default")
            Gui, Carregando:Destroy
            msgbox,16,, % (LANGUAGE = "PT-BR" ? "Erro ao carregar o arquivo JSON do script(" this.isEncrypted ") " """" fileDir """" ".`nProvavelmente há erros de sintáxe no arquivo, copie o conteúdo do arquivo e cole no JSONLint para checar.`n`nDetalhes do erro:`n" : "Error loading script JSON file(" this.isEncrypted ") " """" fileDir """" ".`nProbably there are syntax errors in the file, copy its contents into JSONLint to check.`n`nError details:`n") e.Message "`n`n" e.What "`n`n" e.Extra
            try Run, %fileDir%
            catch {
            }
        }

        if (scriptJsonFile.File() = "")
            throw Exception("Empty scriptJsonFile.File()")
        ; msgbox, % serialize(scriptJsonFile.Object())

        if (returnObj = true)
            return scriptJsonFile.Object()

        return scriptJsonFile
    }

    fileReadScript(scriptName) {
        Loop, 5 {
            scriptContent := ""
            try FileRead, scriptContent, % "Cavebot\" scriptName ".json"
            catch {
            }
            if (scriptContent != "")
                break
            Sleep, 100
        }
        return scriptContent
    }

    /**
    function to read specific settings obj in a faster way to check periodically if
    some function is enabled/disabled
    */
    loadSpecificSetting(settingName := "", scriptName := "", exeName := "") {
        if (scriptName = "")
            scriptName := currentScript
        fileDir := A_WorkingDir "\Cavebot\" scriptName ".json"
        if (!FileExist(fileDir)) {
            error := A_Hour ":" A_Min ":" A_Sec " " A_MDay "/" A_Mon " | " exeName "." A_ThisFunc ": fileDir doesn't exist: " fileDir
            OutputDebug(exeName "." A_ThisFunc, error)
            FileAppend, % "`n" error,  % "Data\Files\logs_errors_read_settings.txt"
            return false
        }


        try this.isEncryptedScript(scriptName, "loadSpecificSetting")
        catch e {
            error := A_Hour ":" A_Min ":" A_Sec " " A_MDay "/" A_Mon " | " exeName "." A_ThisFunc ": (" this.isEncrypted ") Failed to load settings: " e.Message " | " e.What " | " e.File " | " e.Line
            OutputDebug(exeName "." A_ThisFunc, error)
            FileAppend, % "`n" error, % "Data\Files\logs_errors_read_settings.txt"
            return false
        }

        ; msgbox, % exeName "." A_ThisFunc "`n`nsettingName = " settingName "`nscriptName = " scriptName "`nfileDir = " fileDir
        VarSetCapacity(newScriptFileObj, 0), newScriptFileObj := "", newScriptFileObj := {}
        try {
            newScriptFileObj := this.loadScriptJSON(scriptName, openJsonLint := false, returnObj := true, throwException := true)
        } catch e {
            error := A_Hour ":" A_Min ":" A_Sec " " A_MDay "/" A_Mon " | " exeName "." A_ThisFunc ": (" this.isEncrypted ") Failed to load script: " e.Message " | " e.What " | fileDir: " fileDir
            OutputDebug(exeName "." A_ThisFunc, error)
            FileAppend, % "`n" error, % "Data\Files\logs_errors_read_settings.txt"
            return false
        }

        if (newScriptFileObj = "" OR !IsObject(newScriptFileObj)) {
            errorDetails := "Empty newScriptFileObj: encrypted: " this.isEncrypted ", name: " scriptName ", obj: " serialize(newScriptFileObj)
            error := A_Hour ":" A_Min ":" A_Sec " " A_MDay "/" A_Mon " | " exeName "." A_ThisFunc ": " errorDetails
            OutputDebug(exeName "." A_ThisFunc, error)
            FileAppend, % "`n" error,  % "Data\Files\logs_errors_read_settings.txt"
            return false
        }

        if (newScriptFileObj.Count() < 2) {
            error := A_Hour ":" A_Min ":" A_Sec " " A_MDay "/" A_Mon " | " exeName "." A_ThisFunc ": newScriptFileObj too short: " serialize(newScriptFileObj " / " SubStr(scriptDecrypted, 1, 100) "..." )
            OutputDebug(exeName "." A_ThisFunc, error)
            FileAppend, % "`n" error,  % "Data\Files\logs_errors_read_settings.txt"
            return false

        }
        ; OutputDebug(exeName "." A_ThisFunc, "Success")

        if (settingName = "")
            return newScriptFileObj
        %settingName%Obj := newScriptFileObj[settingName]

        ; msgbox, % %settingName%Obj " = " serialize(%settingName%Obj)
        VarSetCapacity(newScriptFileObj, 0), newScriptFileObj := "", newScriptFileObj := {}
        return %settingName%Obj
    }

    loadSpecificSettingFromExe(settingName := "", scriptName := "", exeName := "") {
        if (DefaultProfile = "")
            throw Exception(A_ThisFunc ": Empty profile")
        IniRead, TibiaClientID, %DefaultProfile%, advanced, TibiaClientID, %A_Space%
        ; global
        ; OutputDebug("loadSpecificSettingFromExe", moduleName " | " settingName " | " scriptName)
        ; if (exeName != "")
        ; exeName := StrReplace(exeName, ".exe")
        VarSetCapacity(settingsObj, 0), settingsObj := "", settingsObj := {}
        try settingsObj := this.loadSpecificSetting(moduleName, currentScript,  exeName)
        catch e {
            error := A_Hour ":" A_Min ":" A_Sec " " A_MDay "/" A_Mon " | " exeName ".loadSpecificSettingFromExe" ": Failed to load " moduleName " settings: " e.Message " | " e.What
            OutputDebug(exeName ".loadSpecificSettingFromExe", error)
            FileAppend, % "`n" error, Data\Files\logs_errors_read_settings.txt
            return false
        }
        if (settingsObj = false) {
            error := A_Hour ":" A_Min ":" A_Sec " " A_MDay "/" A_Mon " | " exeName ".loadSpecificSettingFromExe" ": " moduleName " settings false"
            OutputDebug(exeName ".loadSpecificSettingFromExe", error)
            FileAppend, % "`n" error, Data\Files\logs_errors_read_settings.txt
            return false
        }
        if (settingsObj = -1) {
            ; error := A_Hour ":" A_Min ":" A_Sec " " A_MDay "/" A_Mon " | " exeName ".loadSpecificSettingFromExe" ": " moduleName " settings -1"
            ; OutputDebug(exeName ".loadSpecificSettingFromExe", error)
            ; FileAppend, % "`n" error, Data\Files\logs_errors_read_settings.txt
            return false
        }
        ; OutputDebug("@", serialize(settings))
        if (settingsObj != false) {
            %moduleName%Obj := settingsObj
            return true
        }

    }

    deleteAllTempScriptFiles() {
        Loop, % this.tempScriptFolder "\*.temp"
        {
            FileDelete, % A_LoopFileFullPath
        }
        Loop, % this.tempScriptFolder "\*.json"
        {
            FileDelete, % A_LoopFileFullPath
        }
    }

    deleteTempScriptFile(origin := "") {
        if (this.isEncrypted = false)
            return
        try FileDelete, % this.uncryptedFileDir
        catch {
        }
        try FileDelete, % StrReplace(this.uncryptedFileDir, ".temp", ".json")
        catch {
        }

        if (this.tempScriptFolder != "") {
            try FileRemoveDir, this.tempScriptFolder, 1
            catch {
            }
        }

    }

    loadScriptSettings() {
        global
        startTab := scriptSettingsObj.startTab
        startWaypoint := scriptSettingsObj.startWaypoint

        if (scriptSettingsObj.charCoordsFromMemory = "" && scriptSettingsObj.charCoordsFromMemory != false) {
            scriptSettingsObj.charCoordsFromMemory := false

            if (OldBotSettings.settingsJsonObj.settings.cavebot.getCharCoordinatesFromMemory = true)
                scriptSettingsObj.charCoordsFromMemory := true
        }
        /**
        set to true to get char coords from memory if the current client supports
        and it is not checked in the scrip
        */
        if (OldBotSettings.settingsJsonObj.settings.cavebot.getCharCoordinatesFromMemory = true)
                && (scriptSettingsObj.charCoordsFromMemory = false)
                && (scriptSettingsObj.cavebotFunctioningMode != "markers")
            scriptSettingsObj.charCoordsFromMemory := true


        if (OldBotSettings.settingsJsonObj.settings.cavebot.getCharCoordinatesFromMemory != true)
            scriptSettingsObj.charCoordsFromMemory := false

        /**
        * Changed on 2024-08-22, force to true and remove option from GUI etc
        */
        scriptSettingsObj.charCoordsFromMemory := true


        scriptSettingsObj.tryToIdentifyFloorLevelOnStart := scriptSettingsObj.tryToIdentifyFloorLevelOnStart = "" ? false : scriptSettingsObj.tryToIdentifyFloorLevelOnStart
        /**
        forcing true
        */
        tryToIdentifyFloorLevelOnStart := true

        scriptSettingsObj.cavebotFunctioningMode := scriptSettingsObj.cavebotFunctioningMode = "" ? ((OldBotSettings.settingsJsonObj.settings.cavebot.coordinatesFunctioningMode = true) ? "Coordinates" : "Markers") : scriptSettingsObj.cavebotFunctioningMode

        if (OldBotSettings.settingsJsonObj.settings.cavebot.coordinatesFunctioningMode != true) && (scriptSettingsObj.cavebotFunctioningMode = "Coordinates")
            scriptSettingsObj.cavebotFunctioningMode := "Markers"

        forceStartWaypoint := (scriptSettingsObj.forceStartWaypoint = "" && scriptSettingsObj.forceStartWaypoint != false) ? false : scriptSettingsObj.forceStartWaypoint
        startTabSet := scriptSettingsObj.startTabSet
        startWaypointSet := scriptSettingsObj.startWaypointSet
        ; nodeRange := scriptSettingsObj.nodeRange
        pauseOnDeath := scriptSettingsObj.pauseOnDeath += 0

        /**
        Item hotkeys
        */
        ropeHotkey := scriptSettingsObj.itemHotkeys.ropeHotkey
        shovelHotkey := scriptSettingsObj.itemHotkeys.shovelHotkey
        macheteHotkey := scriptSettingsObj.itemHotkeys.macheteHotkey

    }

    createUserOptionVariablesObj() {
        userOptionVariablesObj := {}
        for key1, groupbox in scriptVariablesObj
        {
            for key2, children in groupbox
            {
                for key3, childrenElements in children
                    userOptionVariablesObj[childrenElements.name] := childrenElements.value
            }
        }
    }

    createNewScript(newScriptName) {
        if (newScriptName = "")
            throw Exception("Empty script name.")

        dest := "Cavebot\" newScriptName ".json"
        if (FileExist(dest))
            throw Exception(txt("Já existe um script com o nome""" newScriptName """.", "There is already a script named """ newScriptName """."))

        FileRead, defaultJson, % "Data\Files\Others\default script.json"

        file := FileOpen(dest, "w")
        file.Write(defaultJson)
        file.Close()
        Sleep, 50
        OldbotSettings.setCurrentScript(newScriptName)
        try this.loadScript(newScriptName)
        catch e
            throw e
        OldbotSettings.disableAllFunctions()
        ScriptListGUI.filterLV_Scripts()
    }

    saveScriptAs(selectedScriptName, newScriptName, throwException := false) {
        newScriptName := StrReplace(newScriptName, "+", "")
        if (selectedScriptName = currentScript) && (selectedScriptName = newScriptName) {
            msg := (txt("""" selectedScriptName """ é o script atual.`nVocê não precisa salvar o script atual, todas as alterações são salvas automaticamente.", """" selectedScriptName """ is the current script.`nYou don't need to save the current script, all the changes are  saved automatically."))
            if (throwException = true)
                throw Exception(msg)
            Msgbox, 64,, % msg
            return
        }
        if (selectedScriptName = newScriptName) {
            msg := txt("Escreva um nome diferente de """ selectedScriptName """ para salvar um novo script.", "Write a different name than """ selectedScriptName """ to save as a new script.")
            if (throwException = true)
                throw Exception(msg)
            Msgbox, 64,, % msg
            return
        }
        src := "Cavebot\" selectedScriptName ".json"
        dest := "Cavebot\" newScriptName ".json"
        ; msgbox, % src "`n" dest
        if (FileExist(dest)) {
            Msgbox, 52,, % txt("Já existe um script com o nome""" newScriptName """`n`nVocê deseja sobrescreve-lo?", "There is already a script named """ newScriptName """`n`nDo you want to overwrite it?")
            IfMsgBox, No
                return
        }
        FileCopy, % src, % dest, 1
        if (ErrorLevel != 0) {
            Msgbox, 48,, % "Error saving script file: " dest "`nError: " A_LastError
        }

        ScriptListGUI.filterLV_Scripts()
        ; Msgbox,64,, % "Success."
    }

    deleteScript() {
        scriptName :=  _ListviewHandler.getSelectedItemOnLV("LV_Scripts", 2, "ScriptListGUI")
        if (scriptName = "" OR scriptName = "Name") {
            Msgbox, 64,, % txt("Selecione um script na lista.", "Select a script on the list."), 2
            return false
        }
        msgbox, 52,, % "Do you want to delete the script """ scriptName """?"
        IfMsgBox, No
            return false

        dir := "Cavebot\" scriptName ".json"
        FileDelete, %  dir
        if (ErrorLevel != 0) {
            Msgbox, 48,, % "Error deleting script file: " dir
            return false
        }

        scriptsListByName[scriptName] := {}
        ScriptListGUI.filterLV_Scripts()

        if (scriptName = currentScript) {
            if (!FileExist(dir)) {
                FileAppend, % " ", % dir
            }
            this.loadScript("Default")
            Gui, Carregando:Destroy
            return true
        }

        return false
    }


    checkDefaultScriptSettings() {
        ; scriptSettingsObj["startTab"] := (!scriptSettingsObj["startTab"]) ? "Waypoints" : scriptSettingsObj["startTab"]

        ; scriptSettingsObj["startWaypoint"] := (!scriptSettingsObj["startWaypoint"]) ? 1 : scriptSettingsObj["startWaypoint"]
        ; if the start waypoint is not in the waypoint tab (delete the start waypoint)

        if (startTabSet != "") && (!waypointsObj[startTabSet][startWaypointSet])
            startWaypointSet := 1  += 0
        if (startTab != "") && (!waypointsObj[startTab][startWaypoint])
            startWaypoint := 1

        ; scriptSettingsObj["nodeRange"] := (!scriptSettingsObj["nodeRange"]) ? 4 : scriptSettingsObj["nodeRange"]

        scriptSettingsObj["pauseOnDeath"] := (!scriptSettingsObj["pauseOnDeath"] && scriptSettingsObj["pauseOnDeath"] != false) ? 1 : scriptSettingsObj["pauseOnDeath"] += 0

        scriptSettingsObj["forceStartWaypoint"] := (!scriptSettingsObj["forceStartWaypoint"] && scriptSettingsObj["forceStartWaypoint"] != false) ? 0 : scriptSettingsObj["forceStartWaypoint"] += 0
        ; msgbox, % scriptSettingsObj["pauseOnDeath"]

        if (!scriptSettingsObj["itemHotkeys"])
            scriptSettingsObj["itemHotkeys"] := {}
    }


    setItemHotkey(item) {
        global
        GuiControlGet, %item%Hotkey

        vars := ValidateHotkey("", item "Hotkey", %item%Hotkey)
        if (vars["erro"] > 0) {
            %item%Hotkey := A_Space
            msgbox, 64,, % vars["msg"]
            return
        }

        scriptSettingsObj["itemHotkeys"][item "Hotkey"] := %item%Hotkey
        this.saveScriptSettings(true, A_ThisFunc)

    }


    setNodeRange() {
        global
        GuiControlGet, nodeRange
        if (nodeRange < 1) {
            nodeRange := 1
            GuiControl,, nodeRange, % nodeRange
        }
        if (nodeRange > 4) {
            nodeRange := 4
            GuiControl,, nodeRange, % nodeRange
        }

        scriptSettingsObj.nodeRange := nodeRange
        this.saveSettings(A_ThisFunc)
    }

    setStartTab(value := "") {
        global
        startTab := value
        scriptSettingsObj.startTab := startTab
        this.saveScriptSettings(true, A_ThisFunc)
    }

    setStartTabSet(value := "") {
        global
        startTabSet := value
        scriptSettingsObj.startTabSet := startTabSet
        this.saveScriptSettings(true, A_ThisFunc)
    }

    setForceStartWaypoint(value := "") {
        global
        forceStartWaypoint := value
        scriptSettingsObj.forceStartWaypoint := forceStartWaypoint
        this.saveScriptSettings(true, A_ThisFunc)
    }

    validateStartWaypointSet(startWaypointSet, startTabSet) {
        if (startTabSet = "")
            throw Exception("No start Tab selected.")

        if (this.tabExists(startTabSet) = false)
            throw Exception("Tab """ startTabSet """ doesn't exist.")

        if (startWaypointSet = "")
            return
        if (this.waypointExists(startTabSet, startWaypointSet) = false)
            throw Exception("Waypoint """ startWaypointSet """ doesn't exist on tab " startTabSet ".")

    }
    setStartWaypointSet(value := "") {
        global
        startWaypointSet := value += 0
        scriptSettingsObj.startWaypointSet := startWaypointSet
        this.saveScriptSettings(true, A_ThisFunc)
    }

    setStartWaypoint(value := "", save := true) {
        global
        startWaypoint := value
        if (startWaypoint > 9999) {
            startWaypoint := 9999
            GuiControl,, startWaypoint, % startWaypoint
        }
        scriptSettingsObj.startWaypoint := startWaypoint
            , this.saveScriptSettings(save = true ? true : false, A_ThisFunc)
    }

    setPauseOnDeath() {
        global
        GuiControlGet, pauseOnDeath
        scriptSettingsObj.pauseOnDeath := pauseOnDeath
        this.saveScriptSettings(true, A_ThisFunc)
    }


    removeStartWaypoint() {
        startTabOld := startTab

        if (startWaypoint = "")
            return
        Gui, CavebotGUI:Default
        Gui, ListView, LV_Waypoints_%startTab%
        LV_Modify(startWaypoint, "Icon0")

        if (CavebotScript.isMarker()) && (startTab != "" && startWaypoint != "") {
            Gui, ListView, LV_Waypoints_%startTab%
            LV_Modify(startWaypoint, "Icon" CavebotGUI.setWaypointIcon(startWaypoint, startTab, waypointsObj[startTab][startWaypoint]))
        }

        this.setStartWaypoint(""), this.setStartTab("")

        ; for tabName, value in waypointsObj
        ; LV_Waypoints_%tabName%_Colors.Clear()

        ; msgbox, % startTabOld " / " tab
        if (startTabOld = tab) {
            ; GUIControl,,% "ahk_id" hLV_Waypoints_%tab%
            ; WinSet, Redraw, , % "ahk_id" hLV_Waypoints_%tab%
        }

        CavebotGUI.setTabIcons(99)

    }


    addScriptTabFromGui() {
        GuiControlGet, NewTabName
        Gui, NewTabGUI:Destroy

        this.addScriptTab(NewTabName)
    }


    addScriptTab(NewTabName) {
        if (this.tabExists(NewTabName) = true) {
            throw Exception("There is already a tab with the name: " NewTabName)
        }
        try
            this.validateTabName(NewTabName)
        catch e
            throw e

        this.addTab(NewTabName)
    }

    addTab(tabName) {
        waypointsObj[tabName] := {}

        this.saveSettings(A_ThisFunc)
        this.createScriptTabsList()
    }



    deleteScriptTab() {
        GuiControlGet, DeleteTabName
        Gui, DeleteTabGUI:Destroy
        if (DeleteTabName = "")
            throw Exception("Select a tab on the list to delete.")

        if (this.tabExists(DeleteTabName) = false)
            throw Exception("There is no tab with the name: " DeleteTabName)
        this.deleteTab(DeleteTabName)
    }


    updateCavebotTabs() {
        child_tabs := ("Script Settings|") ScriptTabsListDropdown "|+"
        try GuiControl, CavebotGUI:, Tab_Script_Cavebot, % "|"
        catch {
        }
        try GuiControl, CavebotGUI:, Tab_Script_Cavebot, % child_tabs
        catch {
        }

        Gui, CavebotGUI:Default

        if (startTab != "") {
            tabNumber := CavebotGUI.getTabNumber(startTab)
            CavebotGUI.setTabIcons(tabNumber + 1)
            GuiControl, CavebotGUI:ChooseString, Tab_Script_Cavebot, % startTab
        } else {
            CavebotGUI.setTabIcons(99)

        }

    }

    deleteTab(tabName) {
        waypointsObj.Delete(tabName)
        WaypointHandler.saveWaypoints(true, A_ThisFunc)
        this.createScriptTabsList()

        if (tabName = tab)
            tab := "Waypoints"

        this.saveSettings(A_ThisFunc)
        ; this.createScriptTabsList()
        ; this.updateCavebotTabs()

        ; change the start tab to "Waypoints"
        if (tabName = startTab) {
            ; if waypoints has no waypoint[1],  remove start tab
            if (!waypointsObj["Waypoints"][1])
                this.removeStartWaypoint()
            else
                CavebotGUI.selectStartWaypoint(1, "Waypoints")
        }

    }

    renameScriptTab() {
        GuiControlGet, RenameTabName
        GuiControlGet, RenameTabSelected
        Gui, RenameTabGUI:Destroy
        if (RenameTabSelected = "")
            throw Exception("Select the tab on the list to rename.")

        if (this.tabExists(RenameTabSelected) = false) {
            throw Exception("There is no tab with the name: " RenameTabSelected)
        }
        if (this.tabExists(RenameTabName) = true) {
            throw Exception("There is already a tab with the name: " RenameTabName)
        }
        try
            this.validateTabName(RenameTabName)
        catch e
            throw e

        this.renameTab(RenameTabSelected, RenameTabName)
    }


    renameTab(tabName, newTabName) {

        waypointsObj[newTabName] := waypointsObj[tabName]
        this.deleteTab(tabName)

        this.saveSettings(A_ThisFunc)
        ; this.createScriptTabsList()
        ; this.updateCavebotTabs()
    }

    checkStartWaypointSet() {
        if (this.tabExists(scriptSettingsObj.startTabSet) && this.waypointExists(scriptSettingsObj.startTabSet, scriptSettingsObj.startWaypointSet))
            return true
        return false
    }

    waypointExists(tabName := "", waypointNumber := "") {
        return waypointsObj[tabName].HasKey(waypointNumber)
    }

    tabExists(tabName := "") {
        return waypointsObj.HasKey(tabName)
    }

    validateTabName(tabName) {

        if (StrLen(tabName) < 1)
            throw Exception(LANGUAGE = "PT-BR" ? "O nome da aba deve ter no mínimo 1 caractére (" tabName ")." : "The name of the tab must have at least 1 character (" tabName ").")

        ; lastChar := SubStr(Name, 0, 1)
        ; if (lastChar = "2")
        ; throw Exception(LANGUAGE = "PT-BR" ? "Não é permitido que o último caractére da aba seja o número 2 (" tabName ")." : "It is not allowed the last character of the name be the number 2 (" tabName ").")

        if (IsBlacklistVar(tabName))
            throw Exception(LANGUAGE = "PT-BR" ? "O nome """ tabName """ não pode ser utilizado, utilize outro nome." : "The name """ tabName """ can not be used, use another name.")

        try var_value := %tabName%
        catch
            var_value := ""
        if (var_value != "") {
            throw Exception(LANGUAGE = "PT-BR" ? "O nome da aba não pode ser o mesmo nome de uma variável do Script, existe uma variável com o nome """ tabName """..`n`nUtilize outro nome para a aba." : "The name of the tab can't be the same name of a Script variable, there is a variable with the name """ tabName """.`n`nUe another name for the tab.")
        }

        if tabName in Configurações Script,Configurações,Script Settings,Settings,Cavebot,Targeting,Looter,Looting
            throw Exception(LANGUAGE = "PT-BR" ? "O nome """ tabName """ não pode ser utilizado, utilize outro nome." : "The name """ tabName """ can not be used, use another name.")
    }

    getFixedTabName(tabName) {
        tabName := StrReplace(tabName, " ", "_")
        ; remove any special characters
        return RegExReplace(tabName,"[^\w]","")

    }

    checkTabsName() {
        save := false
        for tabName, value in waypointsObj
        {
            if (containsSpecialCharacter(tabName)) {
                save := true
                newTabName := this.getFixedTabName(tabName)
                waypointsObj[newTabName] := waypointsObj[tabName]
                waypointsObj.Delete(tabName)
                ; msgbox, % tabName " / " newTabName
            }

        }
        if (save = true) {
            scriptFile.waypoints := waypointsObj
            this.saveSettings(A_ThisFunc)
        }

    }

    isEncryptedScript(scriptName, origin := "",  debug := false) {
        fileDir := A_WorkingDir "\Cavebot\" scriptName ".json"
        if (!FileExist(fileDir)) {
            error := A_Hour ":" A_Min ":" A_Sec " " A_MDay "/" A_Mon " | " origin "." A_ThisFunc ": fileDir doesn't exist: " fileDir
            OutputDebug(origin "." A_ThisFunc, error)
            FileAppend, % "`n" error,  % "Data\Files\logs_erros.txt"
            throw Exception("(1) Script file doesn't exist: " fileDir)
            ; if (!A_IsCompiled)
            ; msgbox, 16, % A_ThisFunc, % Error
            ; this.isEncrypted := -1
        }

        ; msgbox, % A_ThisFunc "`n" scriptName " = " this.isEncrypted
        ; if (this.isEncrypted != -1)
        ; return isEncrypted

        VarSetCapacity(scriptEncrypted, 0), scriptEncrypted := ""
        try FileRead, scriptEncrypted, % fileDir
        catch e {
            /**
            wait and try to read the file again before throwing exceptiong
            */
            Sleep, 1000
            try FileRead, scriptEncrypted, % fileDir
            catch e {
                throw Exception(origin "." A_ThisFunc ": Failed to read file: " fileDir "`n`nError: " e.Message " | " e.What)
            }
        }
        ; FileRead, scriptEncrypted, % "__testScript.json"
        if (debug)
            msgbox, % fileDir "`n`n" scriptEncrypted

        this.isEncrypted := this.isEncryptedData(scriptEncrypted)
        VarSetCapacity(scriptEncrypted, 0), scriptEncrypted := ""
    }

    isEncryptedData(scriptData) {
        if (scriptData = "")
            return false
        if (StrLen(scriptData) < 10)
            return false
        if (InStr(scriptData, "{") && InStr(scriptData, "}"))
            return false
        return true

    }


    validateScriptName(scriptName := "") {
        if (scriptName = "")
            scriptName := currentScript
        if (InStr(scriptName, "#") = true)
            throw Exception("Invalid character ""#""(hashtag) in the script name.")
        if (InStr(scriptName, "+") = true)
            throw Exception("Invalid character ""+""(plus) in the script name.")
    }

    createScriptTabsList() {

        this.checkTabsName()

        WaypointHandler.checkMainTabExists()
        ScriptTabsList := {}
        ScriptTabsList.push("Waypoints")
        ScriptTabsListDropdown := ""
        ScriptTabsListDropdown .= "Waypoints|"
        for key, tabName in waypointsObj
        {
            if (key = "Waypoints")
                continue
            ScriptTabsList.push(key)
            ScriptTabsListDropdown .= key "|"
        }
    }

    createObjects() {
        global
        local objectName
        /**
        making all objects empty before loading (when loading a new script)
        */

        ; msgbox, % serialize(scriptFileObj.siofriend) "`n`n" serialize(siofriendObj)
        /**
        if is encrypted, scriptFileObj is already filled from decryptScript()
        */
        ; msgbox, % currentScript ", " this.isEncrypted
        switch this.isEncrypted {
            case true:
                try scriptFileObj := this.decryptScript(currentScript, this.uncryptedFileDir, A_ThisFunc)
                catch e {
                    Gui, Carregando:Destroy
                    if (A_IsCompiled)
                        Msgbox, 48, % A_ScriptName "." A_ThisFunc,  % e.Message "`n" e.What
                    else
                        Msgbox, 48, % A_ScriptName "." A_ThisFunc,  % e.Message "`n" e.What "`n" e.File "`n" e.Line
                    return false
                }
                ; msgbox,16, % A_ThisFunc, % serialize(scriptFileObj.waypoints)

            case false:
                scriptFileObj := scriptFile.Object()
        }
        ; msgbox,, % A_ThisFunc, % serialize(scriptFileObj.waypoints)

        if (scriptFileObj = "") {
            try Gui, CarregandoGUI:Destroy
            catch {
            }
            Msgbox 48,, % "WARNING! Empty script file settings, is that right?`n`nFile:" scriptFile.File() "`n" currentScript
            Reload
            return
        }

        for key, objectName in this.objectsList {
            if (!IsObject(scriptFileObj[objectName])) {
                scriptFileObj[objectName] := {}
            }

            %objectName%Obj := scriptFileObj[objectName]
        }

        for _, class in _JsonSettings.getList() {
            objectName := class.getIdentifier()
            _Validation.empty("objectName", objectName)

            if (!IsObject(scriptFileObj[objectName])) {
                scriptFileObj[objectName] := {}
            }

            %objectName%Obj := scriptFileObj[objectName]
        }
        ; msgbox,, % A_ThisFunc, % serialize(scriptFileObj.waypoints) "`n`n" serialize(waypointsObj)
    }

    saveScriptSettings(saveCavebotScript := true, origin := "") {
        if (scriptSettingsObj = "") {
            Msgbox, 16,, % "Empty script settings to save, origin: " origin
            return
        }

        scriptFile.scriptSettings := scriptSettingsObj
        if (saveCavebotScript = true)
            this.saveSettings(A_ThisFunc)
    }

    saveSettingsTimer() {
        SetTimer, saveCavebotScriptTimer, Delete
        SetTimer, saveCavebotScriptTimer, -500
    }

    saveSettings(origin := "", debug := false) {
        if (this.blankScript = false && scriptFileObj = "") {
            Msgbox, 16,, % "Empty settings to save JSON, origin: " origin
            return
        }
        if (this.blankScript = false && scriptFile.waypoints = "") {
            Msgbox, 16,, % "Empty waypoint settings to save JSON, origin: " origin
            return
        }
        if (this.blankScript = false && scriptFile.healing = "") {
            Msgbox, 16,, % "Empty healing settings to save JSON, origin: " origin
            return
        }
        wasDisabledAuto := false
        if (waypointRecorderRunning = true)
            loadingGuisDisabled := true
        if (loadingGuisDisabled = false) {
            wasDisabledAuto := true
            ; if (!A_IsCompiled)
            ; msgbox,, % A_ThisFunc, % "Disable loading guis not handled: " origin
            OldBotSettings.disableGuisLoading()
        }

        this.saveScriptFile(origin, debug)
        if (wasDisabledAuto = true)
            OldBotSettings.enableGuisLoading()

        ; Gui, CarregandoCavebot:Destroy
    }

    decryptScript(scriptName, uncryptedFileDest, origin := "") {
        if (this.isEncrypted = false)
            return
        fileDir := A_WorkingDir "\Cavebot\" scriptName ".json"

        if (!IsObject(Encryptor))
            throw Exception("Encryptor not initialized, origin: " origin)


        if (!FileExist(fileDir))
            throw Exception("Encrypted Script file doesn't exist: " fileDir)

        scriptEncrypted := this.fileReadScript(scriptName)
        if (scriptEncrypted = "")
            throw Exception("Empty scriptEncrypted: " fileDir)
        scriptDecrypted := Encryptor.decrypt(scriptEncrypted)

        JsonLib := ""
        JsonLib := New JSON()
        scriptDecryptedObj := JsonLib.Load(scriptDecrypted)
        ; msgbox,,% A_ThisFunc, % serialize(scriptDecryptedObj.waypoints)
        if (scriptDecryptedObj = "" OR !IsObject(scriptDecryptedObj))
            throw Exception("Failed to decrypt script:`n" fileDir)
        /**
        new test, dont save the decrypted script anywhere
        only noad in memory
        */
        if (!A_IsCompiled) {
            try FileDelete, % "Cavebot/unencrypted_" scriptName ".json"
            catch {
            }
            scriptJsonDecrypted := new JSONFile("Cavebot/unencrypted_" scriptName ".json")
            scriptJsonDecrypted.Fill(scriptDecryptedObj)
            scriptJsonDecrypted.Save(true)
        }
        return scriptDecryptedObj


        ; msgbox, % "scriptDecryptedObj`n`n" serialize(scriptDecryptedObj)
        scriptJsonDecrypted := new JSONFile(uncryptedFileDest)

        scriptJsonDecrypted.Fill(scriptDecryptedObj)
        scriptJsonDecrypted.Save(true)

        if (!FileExist(uncryptedFileDest))
            throw Exception("Failed to save decrypted script file: " uncryptedFileDest)

        ; msgbox, % scriptName ", " uncryptedFileDest
        scriptDecryptedObj := ""
        scriptJsonDecrypted := ""
        ; msgbox, b
        Sleep, 25
    }

    encryptScript(scriptFileContent, encryptedFileDest) {
        encryptedScriptContent := Encryptor.encrypt(scriptFileContent)
        if (this.isEncryptedData(encryptedScriptContent) = false)
            throw Exception("Failed to encrypt script data: " encryptedFileDest)

        ; msgbox, % A_ThisFunc "`n" encryptedFileDest "`n`n" scriptFileContent
        try fileDelete, % encryptedFileDest
        catch {
        }

        file := ""
        try {
            file := FileOpen(encryptedFileDest, "w")
        } catch e {
            file.Close()
            throw Exception("Failed to open file dest: " encryptedFileDest "`n`nError: " e.Message "`n" e.What)
        }

        file.Write(encryptedScriptContent)
        file.Close()
        file := ""
    }

    saveScriptFile(origin := "", debug := false) {
        ; OutputDebug("SaveScriptFile", "Saving JSON file...")
        scriptFile.Save(true) ; save prettified JSON
        Sleep, 25 ; test to avoid script corruption, added on 26/10/22

        if (this.isEncrypted = false)
            return

        if (debug)
            msgbox, script saved

        /**
        if the script is encrypted, it actually does not have a file, so we need to create one
        */
        JsonLib := ""
        JsonLib := New JSON()
        ; msgbox,, % A_ThisFunc, % serialize(scriptFileObj.waypoints)
        unencryptedScriptJsonData := JsonLib.Dump(scriptFileObj)
        ; msgbox,, % A_ThisFunc, % clipboard := unencryptedScriptJsonData

        try this.encryptScript(unencryptedScriptJsonData, "Cavebot\" currentScript ".json")
        catch e {
            OutputDebug(A_ThisFunc, "Error saving encrypted script: " e.Message " | " e.What)
            if (!A_IsCompiled)
                Msgbox, 48, % A_ThisFunc, % "Error saving encrypted script: " e.Message "`n" e.What
        }
    }

    importScript() {
        FileSelectFile, jsonFilePath, 3,, % txt("Importar Script - Selecione o arquivo .JSON", "Import Script - Select the .JSON file"), (*.json)
        if (jsonFilePath = "") {
            throw Exception("", "aborted")
        }

        StringTrimLeft, selectedScript, jsonFilePath, % InStr(jsonFilePath, "\", 0, -1)

        if (selectedScript = "")
            throw Exception("Invalid script name: " jsonFilePath)

        if (InStr(selectedScript, "clientoptions")) {
            throw Exception("You must selected script JSON file, ""clientoptions.json"" is not a Cavebot Script file.")
        }

        ; CarregandoGUI("Importing clientoptions.json...")
        if (FileExist("Cavebot\" selectedScript)) {
            Msgbox, 52,, % txt("Já existe um script com o nome""" selectedScript """ na pasta do Cavebot.`n`nVocê deseja sobrescreve-lo?", "There is already a script named """ selectedScript """in the Cavebot folder.`n`nDo you want to overwrite it?")
            IfMsgBox, No
                throw Exception("", "aborted")
            try FileDelete, % "Cavebot\" selectedScript
            catch {
            }
            Sleep, 25
        }

        ; msgbox, % jsonFilePath "`n`n" "Cavebot\" jsonFile

        try FileCopy, % jsonFilePath, % "Cavebot\" selectedScript, 1
        catch e
            throw Exception("Failed to copy """ selectedScript """ file, please try again.`n`nError: " A_LastError " | " e.Message " | " e.What)
        Sleep, 50
    }

    scriptHasBackup() {
        Loop, % "Cavebot\Backups\" currentScript "*" {
            return true
        }
        return false
    }

    backupScript() {

        fileDir := A_WorkingDir "\Cavebot\" currentScript ".json"

        /**
        don't backup script file file size lower than 5KB
        in case it is corrupted(0 kb) or just a new script with default settings
        */
        try FileGetSize, scriptFileSize, % fileDir, K
        catch
            return
        if (scriptFileSize < 5)
            return

        dest := "Cavebot\Backups\" currentScript "_" A_Now ".json"
        ; msgbox, 64, % A_ThisFunc, % dest
        FileCopy, % fileDir, % dest, 1
    }

    checkScriptBackups() {

        /**
        keep the last 10 backups of the script
        */
        scriptsDelete := {}
        Loop, % "Cavebot\Backups\" currentScript "*" {
            scriptsDelete[StrReplace(StrReplace(A_LoopFileName, currentScript "_", ""), ".json", "")] := 1
        }
        if (scriptsDelete.Count() < 10)
            return

        scriptsDeleteAmount := scriptsDelete.Count() - 10
        for scriptTimestamp, value in scriptsDelete
        {
            if (A_Index > scriptsDeleteAmount)
                break
            FileDelete, % "Cavebot\Backups\" currentScript "_" scriptTimestamp ".json"
        }
    }

    /**
    * @return bool
    */
    isCoordinate() {
        return scriptSettingsObj.cavebotFunctioningMode = "Coordinates"
    }

    /**
    * @return bool
    */
    isMarker() {
        return scriptSettingsObj.cavebotFunctioningMode = "Markers"
    }

    /**
    * @return bool
    */
    isMemoryCoords() {
        return scriptSettingsObj.charCoordsFromMemory ? true : false
    }

}