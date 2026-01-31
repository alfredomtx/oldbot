
Class _API
{
    static SERVER_IP := "DISABLED"

    __New()
    {

        ; IniRead, SERVER_IP, server.ini, settings, SERVER_IP

        this.serverUrl := "http://" this.SERVER_IP "/"
        this.APIUrl := this.serverURL "/api/oldbotpro/v14"

        APIUrl := this.APIUrl
        serverUrl := this.serverUrl

        this.createHttpObject()
    }

    createHttpObject() {
        try  this.WinHTTP := ComObjCreate("WinHTTP.WinHttpRequest.5.1")
        catch e {
            Msgbox, 16, % A_ThisFunc, % "Error creating HTTP object, please contact support"
            Reload
            return
        }
    }

    call(method, paramsArray, timeout := true, returnObj := false, debug := false, longTimeout := false) {
        ; OutputDebug(A_ThisFunc, method " = "serialize(paramsArray))


        ; msgbox, % serialize(paramsArray)
        paramsToUrl := ""
        for key, value in paramsArray
        {
            if (value = "")
                continue
            paramsToUrl .= key "=" value "&"
        }


        if (!this.WinHTTP)
            this.createHttpObject()

        callUrl := this.APIUrl "/" method ".php?" paramsToUrl

        if (debug)
            clipboard := callUrl 
        ; msgbox, % A_ThisFunc "`n`n" callUrl

        try {
            this.WinHTTP.Open("GET", callUrl, 0)

            this.WinHTTP.SetCredentials("<api_key>", "x", 0)
            this.WinHTTP.SetRequestHeader("Content-Type", "application/json")
            if (timeout = true) {
                if (longTimeout = true)
                    API.WinHTTP.SetTimeouts(0, 12000, 8000, 12000)
                else
                    API.WinHTTP.SetTimeouts(0, 6000, 4000, 6000)
            }
        } catch e {
            Msgbox, 48, % A_ThisFunc, % serialize(e)
        }

        Body := ""
        this.Result := ""
        try {
            this.WinHTTP.Send(Body)
            this.Result := this.WinHTTP.ResponseText
        } catch e {
            OutputDebug(A_ThisFunc, e.Message " | " e.What)
            if (!A_IsCompiled OR debug = true)
                Msgbox, 16,, % e.Message "`n" e.What "`n" this.Result
        }
        if (debug)
            msgbox, % this.Result
        status := SubStr(this.Result, 1, 15)
        ; msgbox, % status
        statusFalse := false
        if (InStr(status, "false")) {
            statusFalse := true
        }

        if (debug)
            msgbox, % (statusFalse = true) ? 16 : "", % A_ThisFunc, % callUrl "`n`nresult:`n`n" this.Result

        if (returnObj = true) {
            try resultObj := this.checkResultObj(this.Result)
            catch e {
                if (e.What = "JsonError") {
                    if (!A_IsCompiled)
                        Msgbox, % Result
                }
                throw e 
            }

            return resultObj
        }

        return this.Result

    }

    downloadCreatures() {
        ; Cloud features disabled in open-source version
        Msgbox, 64, Cloud Feature Disabled, % "Cloud features are disabled in the open-source version."
        return

        ; msgbox, % this.call("", params*) {
        CarregandoGUI("Downloading from database...")

        t1 := A_TickCount


        category_primary := "monster"


        try Result := this.call("image_database"
            , {"action": "download_image", "category_primary": category_primary, "category_secondary": category_secondary, "category_secondary": category_secondary, "client": TibiaClient.getClientIdentifier()}
            , timeout := true
            , debug := false)
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 16,, % LANGUAGE = "PT-BR" ? "Erro na comunicação com o servidor, por favor tente novamente." (DebugMode = 1 OR !A_IsCompiled) ? "`n`n" Result : "Error with the communication with the server, please try again." (DebugMode = 1 OR !A_IsCompiled) ? "`n`n" Result
            return
        }


        ; msgbox, % Result

        try ResultMessage := JsonLib.Load(Result)
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 48,, % "Error dowloading creatures:`n" e.Message "`n" e.What
        }


        downloadedCreatures := ResultMessage.message

        downloadedCreaturesObj := JsonLib.Load(downloadedCreatures)
        ; msgbox, % creaturesObj "`n`n" serialize(creaturesObj)
        blackImage := "iVBORw0KGgoAAAANSUhEUgAAAHYAAAALCAYAAACqG3kOAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAEnQAABJ0Ad5mH3gAAAA4SURBVFhH7chBDQAwDIDA+jfdVQAGWCC5D3NtvoQzfjjjhzN+OOOHM34444czfjjjhzN+OKM2+wBnFQ06m5jPxwAAAABJRU5ErkJggg=="

        added := 0
        updated := 0
        for key, value in downloadedCreaturesObj
        {
            ; obj.Push(JsonLib.Load(Result))
            creatureName := StrReplace(value.image_name, "'", "")
            if (creatureName = "")
                continue
            value.image_base64 := StrReplace(value.image_base64, "'", "")
            value.image_client := StrReplace(value.image_client, "'", "")

            ; all black image
            if (value.image_base64 = blackImage)
                continue

            /**
            if creature doesn't exist yet, add to creaturesImageObj
            */
            timestamp := StrReplace(StrReplace(StrReplace(value.image_lastedit, "-", ""), ":", ""), " ", "") ; remove characters to make it like a 
            ; msgbox, % creatureName "`n" serialize(creaturesImageObj[creatureName])
            if (!creaturesImageObj[creatureName]) {
                creaturesImageObj[creatureName] := {}
                creaturesImageObj[creatureName].image := value.image_base64
                creaturesImageObj[creatureName].timestamp := timestamp
                creaturesImageObj[creatureName].client := value.image_client
                added++
                continue
                ; msgbox, % creaturesImageObj[creatureName].timestamp "`n" value.image_lastedit
            }

            /**
            if exists, check if the timestamp of last edit is newer than the creature timestamp
            */
            if (timestamp < creaturesImageObj[creatureName].timestamp)
                continue

            ; msgbox, % serialize(creaturesImageObj[creatureName]) "`n`n" value.image_client
            if (creaturesImageObj[creatureName].client = "" && value.image_client != "") {
                creaturesImageObj[creatureName].client := value.image_client
            }
            if (value.image_base64 = creaturesImageObj[creatureName].image)
                continue

            creaturesImageObj[creatureName] := {}
            creaturesImageObj[creatureName].image := value.image_base64
            creaturesImageObj[creatureName].timestamp := timestamp
            creaturesImageObj[creatureName].client := value.image_client
            updated++

        }

        ; msgbox, % "Final: " creaturesImageObj.count() "`n" serialize(creaturesImageObj)
        CreaturesHandler.saveCreatures()

        TargetingGUI.filterCreatureList()
        Gui, Carregando:Destroy

        msgbox, 64,, % "Done.`n`nAdded: " added "`nUpdated: " updated "`nElapsed: " A_TickCount - t1 "ms"
        ; Reload()


        ; msgbox, % serialize(downloadedCreatures)
        ; msgbox, %Result%
    }

    downloadItems() {
        ; Cloud features disabled in open-source version
        Msgbox, 64, Cloud Feature Disabled, % "Cloud features are disabled in the open-source version."
        return

        CarregandoGUI("Downloading from database...")

        t1 := A_TickCount

        category_primary := "item"

        try Result := this.call("image_database"
            , {"action": "download_image", "category_primary": category_primary, "category_secondary": category_secondary, "category_secondary": category_secondary, "client": TibiaClient.getClientIdentifier()}
            , timeout := true
            , debug := false)
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 16,, % LANGUAGE = "PT-BR" ? "Erro na comunicação com o servidor, por favor tente novamente." (DebugMode = 1 OR !A_IsCompiled) ? "`n`n" Result : "Error with the communication with the server, please try again." (DebugMode = 1 OR !A_IsCompiled) ? "`n`n" Result
            return
        }


        ; msgbox, % Result

        try ResultMessage := JsonLib.Load(Result)
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 48,, % "Error dowloading creatures:`n" e.Message "`n" e.What
        }


        downloadedItems := ResultMessage.message

        downloadedItemsObj := JsonLib.Load(downloadedItems)
        blackImage := "iVBORw0KGgoAAAANSUhEUgAAAHYAAAALCAYAAACqG3kOAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAEnQAABJ0Ad5mH3gAAAA4SURBVFhH7chBDQAwDIDA+jfdVQAGWCC5D3NtvoQzfjjjhzN+OOOHM34444czfjjjhzN+OKM2+wBnFQ06m5jPxwAAAABJRU5ErkJggg=="

        added := 0
        updated := 0
        for key, value in downloadedItemsObj
        {
            ; obj.Push(JsonLib.Load(Result))
            itemName := StrReplace(value.image_name, "'", "")
            if (itemName = "")
                continue
            value.image_base64 := StrReplace(value.image_base64, "'", "")
            value.image_base64_full := StrReplace(value.image_base64_full, "'", "")
            ; value.image_client := StrReplace(value.image_client, "'", "")

            ; all black image
            if (value.image_base64 = blackImage)
                continue

            /**
            if item doesn't exist yet, add to customItemsImageObj
            */
            timestamp := StrReplace(StrReplace(StrReplace(value.image_lastedit, "-", ""), ":", ""), " ", "") ; remove characters to make it like a 
            ; msgbox, % itemName "`n" serialize(creaturesImageObj[itemName])

            if (!customItemsImageObj[itemName]) {

                customItemsImageObj[itemName] := {}
                for itemAtribute, itemAtributeValue in itemsImageObj[itemName]
                    customItemsImageObj[itemName][itemAtribute] := itemAtributeValue

                customItemsImageObj[itemName].image := value.image_base64
                customItemsImageObj[itemName].image_full := value.image_base64_full
                customItemsImageObj[itemName].timestamp := timestamp
                added++
                continue
                ; msgbox, % customItemsImageObj[itemName].timestamp "`n" value.image_lastedit
            }

            /**
            if exists, check if the timestamp of last edit is newer than the creature timestamp
            */
            if (timestamp < customItemsImageObj[itemName].timestamp)
                continue

            ; msgbox, % serialize(customItemsImageObj[itemName]) "`n`n" value.image_client
            ; if (customItemsImageObj[itemName].client = "" && value.image_client != "") {
            ;     customItemsImageObj[itemName].client := value.image_client
            ; }

            customItemsImageObj[itemName] := {}
            for itemAtribute, itemAtributeValue in itemsImageObj[itemName]
                customItemsImageObj[itemName][itemAtribute] := itemAtributeValue

            customItemsImageObj[itemName].image := value.image_base64
            customItemsImageObj[itemName].image_full := value.image_base64_full
            customItemsImageObj[itemName].timestamp := timestamp
            updated++

        }

        ; msgbox, % "Final: " itemsImageObj.count() "`n" serialize(itemsImageObj)
        ItemsHandler.saveItemsImage()
        LootingGUI.filterItemList()

        Gui, Carregando:Destroy
        msgbox, 64,, % "Done.`n`nAdded: " added "`nUpdated: " updated "`nElapsed: " A_TickCount - t1 "ms"

    }

    listScriptsRequest(saveFileDir := "", debug := false) {
        ; Cloud features disabled in open-source version
        Msgbox, 64, Cloud Feature Disabled, % "Cloud features are disabled in the open-source version."
        return false

        if (saveFileDir = "")
            throw Exception("Empty script list file directory.")


        if (!JsonLib)   
            throw Exception("JsonLib not initialized")
        if (!JSONFile)   
            throw Exception("JSONFile not initialized")
        t1download := A_TickCount

        try Result := this.call("scriptCloud"
            , {"action": "list", "user": loginEmail, "token": token}
            , timeout := true
            , debug)
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 16,, % LANGUAGE = "PT-BR" ? "Erro na comunicação com o servidor, por favor tente novamente." (DebugMode = 1 OR !A_IsCompiled) ? "`n`n" Result : "Error with the communication with the server, please try again." (DebugMode = 1 OR !A_IsCompiled) ? "`n`n" Result
            return
        }
        ; msgbox, % Result

        if (debug)
            msgbox, % Result
        try resultObj := this.checkResultObj(Result)
        catch e {
            Msgbox, 48, % "Upload script", % e.Message, 10
            if (!A_IsCompiled)
                Msgbox, % Result
            return
        }

        if (saveFileDir = "") {
            msgbox, 48, % "List scripts", % "Empty save file dir.", 10
            return false
        }

        try this.saveResultToJsonFile(saveFileDir, Result, "List scripts from cloud")
        catch e {
            Msgbox, 48, % "List scripts from cloud", % e.Message "`n" e.What , 10
            return false
        }

        return true
    }

    uploadScriptRequest(scriptData) {
        ; Cloud features disabled in open-source version
        Msgbox, 64, Cloud Feature Disabled, % "Cloud features are disabled in the open-source version."
        return

        if (!this.WinHTTP)
            this.createHttpObject()

        URLAPI := this.APIUrl "/scriptCloud.php?action=upload&user=" loginEmail "&token=" TOKEN
        ; for key, value in scriptData
        ; {
        ;     ; if (InStr(value, "goblin"))
        ;     msgbox, % key " = " serialize(value) "`n" value
        ; }

        ; msgbox, % URLAPI

        ; obj := {}
        ; for key, value in scriptData
        ; {
        ;     msgbox, % key "`n" value
        ;     obj.push(scriptData[value])
        ; }


        /**
        this order must be the same as 
        ScriptCloudAPI.php -> validateScriptUpload()
        */
        obj := {}
        obj.push(scriptData.name)
        obj.push(scriptData.json)
        obj.push(scriptData.level)
        obj.push(scriptData.vocation)
        obj.push(scriptData.author)
        obj.push(scriptData.functioningMode)
        obj.push(scriptData.client)


        this.WinHTTP.Open("POST", URLAPI, false)

        ; body := scriptData
        ; hdr_ContentType := "text/*"
        CreateFormData(body, hdr_ContentType, obj)
        ; msgbox, % body
        ; msgbox, % serialize(body)
        this.WinHTTP.Open("POST", URLAPI)
        this.WinHTTP.SetRequestHeader("Content-Type", hdr_ContentType)
        try {
            this.WinHTTP.Send(body)
            this.WinHTTP.WaitForResponse()
            Result := this.WinHTTP.ResponseText
        } catch {
            Gui, Carregando:Destroy
            throw Exception(LANGUAGE = "PT-BR" ? "Erro na comunicação com o servidor, por favor tente novamente mais tarde ou contate o suporte." : "Error with the communication with the server, please try again later or contact the support.")
        }
        if (debug)
            msgbox, % "Status: " Status "`n`n" Result
        ; msgbox, % Result

        try resultObj := this.checkResultObj(Result)
        catch e {
            if (e.What = "JsonError") {
                if (!A_IsCompiled)
                    Msgbox, % Result
            }
            throw e
        }
    }

    downloadScriptRequest(scriptName) {
        ; Cloud features disabled in open-source version
        Msgbox, 64, Cloud Feature Disabled, % "Cloud features are disabled in the open-source version."
        return false

        ; CarregandoGUI("Downloading from database...")

        if (!JsonLib)
            throw Exception("JsonLib not initialized")
        if (!JSONFile)   
            throw Exception("JSONFile not initialized")
        t1download := A_TickCount


        try Result := this.call("scriptCloud"
            , {"action": "download", "user": loginEmail, "token": token, "scriptName": scriptName}
            , timeout := true
            , debug := false)
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 16,, % LANGUAGE = "PT-BR" ? "Erro na comunicação com o servidor, por favor tente novamente." (DebugMode = 1 OR !A_IsCompiled) ? "`n`n" Result : "Error with the communication with the server, please try again." (DebugMode = 1 OR !A_IsCompiled) ? "`n`n" Result
            return
        }

        ; msgbox, % clipboard := Result

        try resultObj := this.checkResultObj(Result)
        catch e {
            if (e.What = "JsonError") {
                if (!A_IsCompiled)
                    Msgbox, % Result
            }
            throw e 
        }

        try this.saveResultToJsonFile("Cavebot\" scriptName ".json", Result, "Download Script")
        catch e {
            throw e 
        }


        ; msgbox, 64, % "Script download", % "Success!" "`nElapsed: " A_TickCount - t1download "ms", 4
        return true
    }

    checkResultObj(Result := "") {

        if (Result = "1")
            throw Exception("Invalid response from server.")


        if (Result = "")
            throw Exception("No response from server.")

        try resultObj := Json.Load(Result)
        catch e {
            if (A_IsCompiled)
                throw Exception("Error loading JSON:`n" e.Message "`n`n" Result, "JsonError")
            else
                throw Exception("Error loading JSON:`n" e.Message "`n" e.What "`n`n" Result, "JsonError")
        }

        if (resultObj.status = false)
            throw Exception(resultObj.message)

        return resultObj
    }

    saveResultToJsonFile(fileDir, Result, funcOrigin)
    {
        try resultJsonObj := JsonLib.Load(Result)
        catch e {
            ; Gui, Carregando:Destroy
            throw Exception("Error loading JSON:`n" e.Message "`n" e.What)
        }

        if (resultJsonObj = "") {
            ; Gui, Carregando:Destroy
            throw Exception("Empty JSON.")
        }

        /*
        disable functions
        */

        for key, persistent in resultJsonObj.persistent {
            persistent.enabled := 0
        }

        for name, alert  in resultJsonObj.alert {
            alert.enabled := 0
        }

        for name, sio  in resultJsonObj.sioFriend {
            sio.enabled := 0
        }

        resultJsonObj.life.lifeHealingEnabled := 0
        resultJsonObj.mana.manaHealingEnabled := 0
        resultJsonObj.mana.manaTrainEnabled := 0

        resultJsonObj.itemRefill.amuletRefillEnabled := 0
        resultJsonObj.itemRefill.ringRefillEnabled := 0
        resultJsonObj.itemRefill.bootsRefillEnabled := 0
        resultJsonObj.itemRefill.distanceWeaponRefillEnabled := 0
        resultJsonObj.itemRefill.quiverRefillEnabled := 0

        resultJsonObj.reconnect.autoReconnect := 0

        /**
        deleting file before saving
        in a PC it failed to open file when it already existed
        */
        try FileDelete, % fileDir
        catch {
        }
        Sleep, 50

        resultJsonFile := new JSONFile(fileDir)
        resultJsonFile.Fill(resultJsonObj)
        resultJsonFile.Save()
        resultJsonFile := ""
        resultJsonObj := ""
    }

    uploadCreatures() {
        ; Cloud features disabled in open-source version
        Msgbox, 64, Cloud Feature Disabled, % "Cloud features are disabled in the open-source version."
        return

        CarregandoGUI("Uploading to database...")
        t1download := A_TickCount

        imagesObj := {}
        creaturesUploadObj := {}

        if (customCreaturesImageFile) && (customCreaturesImageObj) {
            for creatureName, atributes in customCreaturesImageObj
            {
                if (atributes.image = "")
                    continue
                if (atributes.timestamp = "")
                    continue
                ; if (creatureName = "rat")
                ; msgbox, % creatureName "`n" serialize(customCreaturesImageObj[creatureName])
                creaturesUploadObj[creatureName] := {}
                creaturesUploadObj[creatureName].image := atributes.image
                creaturesUploadObj[creatureName].timestamp := atributes.timestamp
                creaturesUploadObj[creatureName].client := TibiaClient.getClientIdentifier()
            }
        }

        for creatureName, atributes in creaturesImageObj
        {
            alreadyIn := false
            for key, value in creaturesUploadObj
            {
                if (key = creatureName) {
                    alreadyIn := true
                    break
                }
            }
            if (alreadyIn = true) {
                ; msgbox, creature already in array %creatureName%
                continue
            }
            if (atributes.image = "")
                continue
            if (atributes.timestamp = "")
                continue
            ; if (creatureName = "rat")
            ; msgbox, % creatureName "`n" serialize(creaturesImageObj[creatureName])
            creaturesUploadObj[creatureName] := {}
            creaturesUploadObj[creatureName].image := atributes.image
            creaturesUploadObj[creatureName].timestamp := atributes.timestamp
            creaturesUploadObj[creatureName].client := atributes.client
        }

        Loop, % "Cavebot/*.json" {
            try tempScript := new JSONFile(A_LoopFileFullPath)
            catch, e {
                ; msgbox,16,, % "Error loading script JSON file " """" A_LoopFileFullPath """" ".`nProbably there are syntax erros in the file, copy its contents into JSONLint to check.`n`nError details:`n" e.Message "`n`n" e.What "`n`n" e.Extra
                continue
            }

            tempScriptObj := tempScript.Object()

            for creatureName, atributes in tempScriptObj.targeting.targetList
            {
                alreadyIn := false
                for key, value in creaturesUploadObj
                {
                    if (key = creatureName) {
                        alreadyIn := true
                        break
                    }
                }
                if (alreadyIn = true) {
                    ; msgbox, creature already in array %creatureName%
                    continue
                }
                if (atributes.image = "")
                    continue
                if (TibiaClient.getClientIdentifier() != atributes.client)
                    continue

                ; if (creatureName = "goblin")
                ; msgbox, % A_LoopFileName "`n`n" creatureName "`n`n" serialize(atributes)

                creaturesUploadObj[creatureName] := {}
                creaturesUploadObj[creatureName].image := atributes.image
                creaturesUploadObj[creatureName].timestamp := atributes.timestamp = "" ? A_Now : atributes.timestamp
                creaturesUploadObj[creatureName].client := atributes.client

                ; msgbox, % serialize(creaturesUploadObj[creatureName])
            }
            tempScript := "", tempScriptObj := ""

        }

        for creatureName, creatureAtributes in creaturesUploadObj
        {

            image_base64 := creatureAtributes.image
            if (image_base64 = "")
                continue
            last_edit := creatureAtributes.timestamp
            if (last_edit = "")
                continue
            ; if (creatureName = "rat")
            ; msgbox, % creatureName "`n" serialize(creaturesUploadObj[creatureName])
            client := creatureAtributes.client
            if (client = "") {
                ; msgbox, % creatureName "`n" serialize(creaturesUploadObj[creatureName])
                continue
            }
            if (TibiaClient.getClientIdentifier() != client) {
                continue
            }

            image = {`"name`": `"%creatureName%`",`"image`": `"%image_base64%`", `"last_edit`": `"%last_edit%`", `"client`": `"%client%`"}

            ; if (InStr(creatureName, "goblin")) {
            ; msgbox, % image
            ; }
            imagesObj.Push(image)

        }

        try resultObj := this.UploadImages(ImagesObj, "monster", return_result := true, debug := false)
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 48, "Upload items", % e.Message, 10
            return
        }

        Gui, Carregando:Destroy
        msgbox, 64,, % "Done.`n`n" resultObj.message "`nElapsed: " A_TickCount - t1download "ms"
    }

    uploadItems() {
        ; Cloud features disabled in open-source version
        Msgbox, 64, Cloud Feature Disabled, % "Cloud features are disabled in the open-source version."
        return

        if (customItemsImageFile = "") {
            ; if (!A_IsCompiled)
            Msgbox, 48,, % "No upload for " TibiaClient.Tibia13Identifier " without custom items(rltibia).", 8
            return
        }

        CarregandoGUI("Uploading to database...")
        t1download := A_TickCount

        ImagesObj := {}
        itemsUploadObj := {}

        for itemName, atributes in customItemsImageObj
        {
            if (atributes.image = "")
                continue
            if (atributes.timestamp = "")
                continue

            itemsUploadObj[itemName] := {}
            itemsUploadObj[itemName].image := atributes.image
            itemsUploadObj[itemName].image_full := atributes.image_full
            itemsUploadObj[itemName].timestamp := atributes.timestamp
            itemsUploadObj[itemName].client := TibiaClient.getClientIdentifier()
        }

        ; msgbox, % serialize(itemsUploadObj)
        for itemName, atributes in itemsUploadObj
        {
            image_base64 := atributes.image
            image_base64_full := atributes.image_full
            if (image_base64 = "")
                continue

            last_edit := atributes.timestamp
            if (last_edit = "")
                continue
            ; if (itemName = "rat")
            ; msgbox, % itemName "`n" serialize(itemsUploadObj[itemName])
            client := atributes.client
            if (client = "") {
                ; msgbox, % itemName "`n" serialize(itemsUploadObj[itemName])
                continue
            }
            if (TibiaClient.getClientIdentifier() != client) {
                continue
            }

            image = {`"name`": `"%itemName%`",`"image`": `"%image_base64%`", `"image_full`": `"%image_base64_full%`", `"last_edit`": `"%last_edit%`", `"client`": `"%client%`"}

            ; if (InStr(creatureName, "goblin")) {
            ; msgbox, % image
            ; }
            ImagesObj.Push(image)
        }

        ; Msgbox, % serialize(ImagesObj)


        try resultObj := this.UploadImages(ImagesObj, "item", return_result := true, debug := false)
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 48, "Upload items", % e.Message, 10
            return
        }

        Gui, Carregando:Destroy
        msgbox, 64,, % "Done.`n`n" resultObj.message "`nElapsed: " A_TickCount - t1download "ms"

    }

    UploadImages(ByRef ImagesObj, category_primary, return_result := true, debug := false) {

        if (!A_IsCompiled)
            loginEmail := ""

        if (!this.WinHTTP)
            this.createHttpObject()

        URLAPI := this.APIUrl "/image_database.php?action=upload_image&user=" loginEmail "&category_primary=" category_primary "&client=" TibiaClient.getClientIdentifier()
        ; for key, value in ImagesObj
        ; {
        ;     ; if (InStr(value, "goblin"))
        ;     msgbox, % key " = " serialize(value) "`n" value
        ; }

        ; msgbox, % URLAPI


        this.WinHTTP.Open("POST", URLAPI, false)

        CreateFormData(body, hdr_ContentType, ImagesObj)
        ; msgbox, % serialize(body)
        this.WinHTTP.Open("POST", URLAPI)
        this.WinHTTP.SetRequestHeader("Content-Type", hdr_ContentType)
        try {
            this.WinHTTP.Send(body)
            this.WinHTTP.WaitForResponse()
            Result := this.WinHTTP.ResponseText
        } catch {
            Gui, Carregando:Destroy
            Msgbox, 16,, % LANGUAGE = "PT-BR" ? "Erro na comunicação com o servidor, por favor tente novamente mais tarde ou contate o suporte." : "Error with the communication with the server, please try again later or contact the support."
            return false
        }

        try resultObj := this.checkResultObj(Result)
        catch e {
            throw e
        }
        return resultObj
    }

    releaseLogin(acc_id) {
        if (acc_id = "") {
            Msgbox, 16,, % LANGUAGE = "PT-BR" ? "Problema ao liberar o login, por favor contate o suporte. (1)" : "Problem releasing login, please contact the support. (1)"
            return
        }
        Gui, Carregando:Destroy
        Gui, Carregando:-Caption +Border +Toolwindow +AlwaysOnTop
        Gui, Carregando:Add, Text,x10 y+5, % LANGUAGE = "PT-BR" ? "Carregando..." : "Loading..." 
        Gui, Carregando:Show, NoActivate,


        try Result := API.call("up", {"LIBERAR_LOGIN": "1", "acc_id": acc_id})
        catch e {
            CloseAllProcesses()
            Sleep, 1000
            Gui, ShortcutScripts:Destroy
            Gui, Carregando:Destroy
            Msgbox,16,,% LANGUAGE = "PT-BR" ? "Erro ao liberar o login, por favor contate o suporte para liberar manualmente." : "Error releasing the login, please contact the support to release manually."
        }
        IfInString, Result, COOLDOWN
        {
            FoundPos := InStr(Result, "###", 0, 1)
            StringTrimLeft, Cooldown, Result, FoundPos + 4
            ; msgbox, % Cooldown
            StringTrimRight, Cooldown, Cooldown, 2
            ; msgbox, % Cooldown
            Cooldown := 2 - Cooldown
            CloseAllProcesses()
            Sleep, 1000
            Gui, Carregando:Destroy
            Gui, ShortcutScripts:Destroy
            Msgbox,16,,% LANGUAGE = "PT-BR" ? "Sua conta está no cooldown de " Cooldown " hora(s) para liberar o login pelo bot novamente.`n`nPara liberar manualmente contate o suporte." : "Your account is on the " Cooldown " hour(s) of cooldown to release the login by the bot again.`n`nTo release manually contact the support."
        }

        IfInString, Result, SUCCESS
        {
            Gui, Carregando:Destroy
            Msgbox,64,,% LANGUAGE = "PT-BR" ? "Login liberado com sucesso." : "Login released with success."
        }
        Reload()
        return
    }


}