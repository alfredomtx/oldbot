global scriptsListObj
global scriptsListFile
global scriptsList
global scriptsListByName

Class _ScriptCloud
{
    __New()
    {

        this.checkInitializeAPI()
    }

    checkInitializeAPI() {
        if (!IsObject(API)) 
            throw Exception("API instance not initialized.")
    }

    getScriptsList(downloadFromAPI := false, checkAutoUpdate := false) {
        this.scriptsListDir := "Data\Files\scriptsList.json"
        if (!FileExist(this.scriptsListDir))
            downloadFromAPI := true

        try this.checkAutoDownloadFile(downloadFromAPI, checkAutoUpdate)
        catch e {
            return false
        }

        try {
            scriptsListFile := new JSONFile(this.scriptsListDir)
        } catch, e {
            msgbox, 16, % "List scripts", % "Error loading scripts list JSON:`n" e.Message "`n" e.What, 10
            return false
        }


        if (downloadFromAPI = true) {
            scriptsListFile.date := A_Now
            ; scriptsListFile.save(true)
            scriptsListFile.save()
        }

        scriptsListObj := scriptsListFile.Object()

        if (!scriptsListObj.HasKey("message")) {
            if (!A_IsCompiled) {
            }
        }
        scriptsList := scriptsListObj.message

        scriptsListByName := {}
        for key, value in scriptsList
        {
            Base64decUTF8( decryptedScriptName, value.script_name )
            value.script_name := decryptedScriptName

            scriptsListByName[value.script_name] := {}

            Base64decUTF8( decryptedAuthor, value.script_author )
            value.script_author := decryptedAuthor

            if (value.script_date_added != "")
                value.script_date_added := this.formatDate(value.script_date_added, true)

            if (value.script_date_updated != "")
                value.script_date_updated := this.formatDate(value.script_date_updated)

            scriptsListByName[value.script_name] := value

            this.loadScriptVocation(value.script_name)

            ; msgbox, % key "`n" serialize(value)
        }

        ; msgbox, % key "`n" serialize(scriptsListByName)
        this.updateListDate()

        return true
    }

    checkAutoDownloadFile(downloadFromAPI, checkAutoUpdate := false) {

        if (downloadFromAPI = true) {
            try this.downloadNewScriptFileFromAPI()
            catch e {
                throw e
            }
        }

        if (checkAutoUpdate = false)
            return

        /**  
        auto update daily
        */
        if (!FileExist(this.scriptsListDir))
            return

        if (loginEmail = "")
            return

        try {
            scriptsListCheckFile := new JSONFile(this.scriptsListDir)
        } catch, e {
            msgbox, 16, % "List scripts", % "Error loading scripts list JSON:`n" e.Message "`n" e.What, 10
            return false
        }

        scriptsListCheckObj := scriptsListCheckFile.Object()


        today := A_MDay
        ; 20211013204502
        lastUpdateDay := SubStr(scriptsListCheckObj.date, 7, 2)

        if (lastUpdateDay = "")
            return

        if (today != lastUpdateDay) {
            try this.downloadNewScriptFileFromAPI()
            catch e {
                throw e
            }
        }


        scriptsListCheckFile.date := A_Now
        scriptsListCheckFile.save()

        scriptsListCheckFile := "", scriptsListCheckObj := ""
    }

    downloadNewScriptFileFromAPI() {
        scriptsListFile := ""
        scriptsListObj := ""
        scriptsList := ""
        scriptsListByName := ""
        try FileDelete, % this.scriptsListDir
        catch {
        }
        if (API.listScriptsRequest(this.scriptsListDir, debug := false) = false)
            throw Exception("Failed to download file")
        Sleep, 100
    }

    formatDate(date, cutTime := false) {
        year := SubStr(date, 1, 4)
            , day := SubStr(date, 9, 2)
            , month := SubStr(date, 6, 2)
            , time := SubStr(date, 12, StrLen(date) - 11)
        ; , string := day "/" month "/" year (cutTime = true ? "" : " " time)
            , string := year month day " (" day "/" month "/" year "" (cutTime = true ? "" : " " time) ")"
        ; msgbox, % date "`n" string

        return string
    }

    updateListDate() {

        if (scriptsListObj.date = "")
            return "No data"

        date := scriptsListObj.date
        ; 20210703120518
        year := SubStr(date, 1, 4)
        day := SubStr(date, 7, 2)
        month := SubStr(date, 5, 2)
        hour := SubStr(date, 9, 2)
        min := SubStr(date, 11, 2)
        sec := SubStr(date, 13, 2)

        dateString :=  day "/" month "/" year " " hour ":" min ":" sec

        GuiControl, ScriptListGUI:, lastUpdatedScriptListDate, % "Last update: " dateString
        return 

    }

    updateScriptList(downloadFromAPI := false, checkAutoUpdate := false) {
        this.getScriptsList(downloadFromAPI, checkAutoUpdate)

        ScriptListGUI.filterLV_Scripts("LV_ScriptsCloud")
        ScriptListGUI.filterLV_Scripts("LV_Scripts")
    }

    downloadScript()
    {
        this.checkInitializeAPI()

        selectedScript :=  _ListviewHandler.getSelectedItemOnLV("LV_ScriptsCloud", 2, "ScriptListGUI")
        if (selectedScript = "" OR selectedScript = "Name") {
            Msgbox, 64, % "Download Script", % txt("Selecione um script na lista.", "Select a script on the list."), 2
            return
        }

        t1download := A_TickCount
        try success := API.downloadScriptRequest(selectedScript)
        catch e {
            if (A_IsCompiled)
                Msgbox, 48, % "Download Script", % e.Message, 10
            else
                Msgbox, 48, % "Download Script", % e.Message "`n" e.What "`n" e.Extra, 10
            return
        }
        if (success = false)    
            return

        GuiControl, ScriptListGUI:Choose, ScriptsListTab, 1

        ScriptListGUI.filterLV_Scripts()

        row := _ListviewHandler.findRowByContent(selectedScript, 2, "LV_Scripts", defaultGUI := "ScriptListGUI")
        _ListviewHandler.selectRow("LV_Scripts", row, defaultGUI := "ScriptListGUI")

        ; msgbox, 64, % "Script download", % "Success!" "`nElapsed: " A_TickCount - t1download "ms", 4
        msgbox, 64, % "Script download", % "Script downloaded.", 4

    }

    uploadScriptWarningMessage(msg) {
        Gui, ScriptAtributesGUI:Hide
        Msgbox, 64, % "Upload Script", % msg, 6
        Gui, ScriptAtributesGUI:Show
    }

    uploadScript(downloadFromAPI := false) {
        this.checkInitializeAPI()

        if (this.uploadScriptName = "" OR this.uploadScriptName = "Name") {
            Msgbox, 64, % "Upload Script", % txt("Selecione um script na lista.", "Select a script on the list."), 2
            return
        }

        Gui, ScriptAtributesGUI:Default

        GuiControlGet, authorScript
        authorScript := LTrim(RTrim(authorScript))
        if (A_IsCompiled) {
            if (authorScript = "") {
                this.uploadScriptWarningMessage(LANGUAGE = "PT-BR" ? "Preencha o campo ""Autor"" com seu Username do Discord." : "Fill the ""Author"" field with your Discord Username.")
                return
            }
            if (StrLen(authorScript) < 5) {
                this.uploadScriptWarningMessage(LANGUAGE = "PT-BR" ? "O campo ""Autor"" está muito curto(mínimo 4 caractéres)." : """Author"" field is too short(min 4 characters).")
                return
            }
            if (!InStr(authorScript, "#")) {
                this.uploadScriptWarningMessage(LANGUAGE = "PT-BR" ? "O campo ""Autor"" deve ser o seu Username do Discord.`nExemplo: OldBotUser#1234" : """Author"" field must be your Discord Username.`nExample: OldBotUser#1234")
                return
            }
            discordUsernameStr := StrSplit(authorScript, "#")
            if (StrLen(discordUsernameStr.2) != 4) {
                this.uploadScriptWarningMessage(LANGUAGE = "PT-BR" ? "O campo ""Autor"" deve ser o seu Username do Discord no formato correto.`nExemplo: OldBotUser#1234" : """Author"" field must be your Discord Username in the correct format.`nExample: OldBotUser#1234")
                return
            }
        }
        GuiControlGet, levelScript
        levelScript := LTrim(RTrim(levelScript))
        if (levelScript = "") {
            this.uploadScriptWarningMessage(LANGUAGE = "PT-BR" ? "Preencha o campo ""Level""." : "Fill the ""Level"" field.")
            return
        }
        GuiControlGet, clientScript
        if (clientScript = "") OR (clientScript = A_Space) {
            this.uploadScriptWarningMessage(LANGUAGE = "PT-BR" ? "Selecione o campo ""Client""." : "Select the ""Client"" field.")
            return
        }
        GuiControlGet, functioningModeScript
        if (functioningModeScript = "") OR (functioningModeScript = A_Space) {
            this.uploadScriptWarningMessage(LANGUAGE = "PT-BR" ? "Selecione o campo ""Cavebot Functioning Mode""." : "Select the ""Cavebot Functioning Mode"" field.")
            return
        }
        if (StrLen(this.uploadScriptName) < 15) {
            this.uploadScriptWarningMessage(LANGUAGE = "PT-BR" ? "O nome do Script é muito curto(mínimo 15 caractéres).`nSalve o Script com um nome maior e tente novamente." : "The script name is too short(min 15 characters).`nSave the Script with a longer name and try again.")
            return
        }

        if (this.uploadScriptName = "")
            return

        this.uploadScriptName := StrReplace(this.uploadScriptName, "+", "")
        GuiControl, ScriptListGUI:Disable, uploadSelectedScript
        GuiControl, ScriptListGUI:, uploadSelectedScript, % "Uploading..."

        GuiControlGet, authorScript
        GuiControlGet, functioningModeScript
        GuiControlGet, clientScript

        vocationsString := ""
        for key, vocation in ScriptListGUI.vocationList
        {
            GuiControlGet, vocation%vocation%
            if (vocation = "All") && (vocation%vocation% = 1) {
                vocationsString := vocation ", "
                break
            }
            if (vocation%vocation% = 1)
                vocationsString .= vocation ", "
        }

        for key, module in ScriptListGUI.objectsList
        {
            GuiControlGet, module%module%
        }

        StringTrimRight, vocationsString, vocationsString, 2
        if (vocationsString = "") {
            this.uploadScriptWarningMessage(LANGUAGE = "PT-BR" ? "Selecione pelo menos uma opção do campo ""Vocação""." : "Select at least one option in the ""Vocation"" field.")
            return
        }

        Gui, ScriptAtributesGUI:Destroy


        CavebotScript.saveSettings(A_ThisFunc)


        fileDir := "Cavebot\" selectedScript ".json"
        FileRead, scriptJsonString, % fileDir

        if (scriptJsonString = "") {
            this.enableUploadButton()
            Msgbox, 48,, % "Empty script JSON.", 4
            return 
        }


        scriptUploadTempFile := A_Temp "\OldBot\" this.uploadScriptName ".json"
        scriptUploadObj := JsonLib.Load(scriptJsonString)

        try {
            scriptUploadFile := new JSONFile(scriptUploadTempFile)
        } catch, e {
            if (openInError = false)
                return false
            ; Gui, Carregando:Destroy
            msgbox,16,, % "Error loading script JSON file to upload " """" fileDir """" ".`nProbably there are syntax errors in the file, copy its contents into JSONLint to check.`n`nError details:`n" e.Message "`n`n" e.What "`n`n" e.Extra
            try Run, %fileDir%
            catch {
            }
        }

        ; msgbox, % serialize(scriptUploadObj)


        for key, module in ScriptListGUI.objectsList
        {
            if (module%module% = 0) {
                switch module {
                    case "attackSpells":
                        for creature, atributes in scriptUploadObj.targeting.targetList
                        {
                            scriptUploadObj.targeting.targetList[creature].attackSpells := {}
                        }
                    default:
                        scriptUploadObj[module] := {}

                }
            }
        }

        ; msgbox, % serialize(scriptUploadObj)
        scriptUploadFile.Fill(scriptUploadObj)
        scriptUploadFile.save(true)
        scriptUploadFile := ""
        scriptUploadObj := ""


        FileRead, scriptJsonString, % scriptUploadTempFile
        if (scriptJsonString = "") {
            this.enableUploadButton()
            Msgbox, 48,, % "Empty temporary script JSON for upload.", 4
            return 
        }

        scriptInfoObj := ""
        scriptInfoObj := {}
        scriptInfoObj.name := selectedScript
        scriptInfoObj.json := scriptJsonString
        scriptInfoObj.vocation := vocationsString
        scriptInfoObj.level := levelScript
        scriptInfoObj.author := authorScript
        scriptInfoObj.functioningMode := functioningModeScript
        scriptInfoObj.client := clientScript

        scriptJsonString := ""



        ; msgbox, % serialize(scriptInfoObj)


        ; if (scriptInfoObj.name = "")
        ;     throw Exception("Empty script name.")

        ; if (scriptInfoObj.json = "")
        ;     throw Exception("Empty script JSON.")


        try API.uploadScriptRequest(scriptInfoObj)
        catch e {
            this.enableUploadButton()
            if (A_IsCompiled)
                Msgbox, 48, % "Upload Script", % e.Message, 10
            else
                Msgbox, 48, % "Upload Script", % e.Message "`n" e.What "`n" e.Extra, 10
            return
        }

        this.updateScriptList(true)




        this.enableUploadButton()



        msgbox, 64, % "Upload script", % "Script uploaded with success.", 6
    }

    enableUploadButton() {
        enableButtonTimer := Func("enableButton").bind("ScriptListGUI", "uploadSelectedScript", "Upload script")
        SetTimer, % enableButtonTimer, Delete
        SetTimer, % enableButtonTimer, -100
    }


    loadScriptVocation(scriptName) {
        scriptsListByName[scriptName].vocations := {}

        vocationsScript := StrSplit(scriptsListByName[scriptName].script_vocation, ",")

        ; msgbox, % scriptsListByName[scriptName].script_vocation "`n" serialize(vocationsScript)

        for key, vocation in vocationsScript
            scriptsListByName[scriptName].vocations.push(StrReplace(vocation, " ", ""))

        ; msgbox, % serialize(scriptsListByName[scriptName].vocations)
    }



}