global tibiaItems := {}
global tibiaCreatures := {}

Class _TibiaWikIAPI  {




    updateItems(download := true)
    {
        if (download) {
            this.downloadJsonFile("items", false)
        }

        this.createNewItemsFile()
    }

    updateCreatures()
    {
        this.downloadJsonFile("creatures", false)
        this.createNewCreaturesFile()
    }

    downloadJsonFile(Entity, updateFunction := true)
    {
        ; https://github.com/benjaminkomen/TibiaWikiApi/
        if (Entity != "items") && (Entity != "creatures") {
            Msgbox, 48,, Entity must be "items" or "creatures.
            return
        }

        CarregandoGUI("Dowloading " Entity " ...", , , , , , , show_bar := false)


        fileDir := "Data\Files\JSON\" Entity "\" Entity "_downloaded.json"
        try FileDelete, % fileDir
        catch {
        }
        Sleep, 50

        downloadedInfoJsonFile := new JSONFile(fileDir)

        t1 := A_TickCount
        WinHTTP := ComObjCreate("WinHTTP.WinHttpRequest.5.1")
        URLAPI := "https://tibiawiki.dev/api/" Entity "?expand=true"
        WinHTTP.Open("GET", "" . URLAPI . "", 0)
        ; WinHTTP.SetCredentials("<api_key>", "x", 0)
        WinHTTP.SetRequestHeader("Content-Type", "application/json")
        WinHTTP.SetTimeouts(0, 1800000, 1200000, 1800000)
        Body := ""
        try {
            WinHTTP.Send(Body)
            Result := WinHTTP.ResponseText
            ; msgbox, % Result
        } catch { 
            Gui, Carregando:Destroy
            Msgbox, 16,, % Result " / " e.Message "`n" e.What "`n" e.Extra "`n" e.Line
            return
        }

        if (Result = "") {
            Gui, Carregando:Destroy
            Msgbox, 16,, Empty result downloading %Entity%.
            return
        }
        resultObj := JsonLib.Load(Result)
        downloadedInfoJsonFile.Fill(resultObj)
        downloadedInfoJsonFile.Save(true)
        if (updateFunction = true) {
            Gui, Carregando:Destroy
            msgbox,64,, % "Downloaded " Entity ". " A_TickCount - t1 " ms"
        }

        ; downloadedInfoJsonFile.
    }

    createNewCreaturesFile()
    {
        CarregandoGUI("Working on creatures...", , , , , , , show_bar := false)
        t1 := A_TickCount

        FileDelete, % OldbotSettings.JsonFolder "\Creatures\creatures.json"

        fileDir := OldbotSettings.JsonFolder "\Creatures\creatures_downloaded.json"
        downloadedJsonFile := new JSONFile(fileDir)
        downloadedCreaturesObj := downloadedJsonFile.Object()

        fieldsToGet := {}
        fieldsToGet.Push("exp")
        ; fieldsToGet.Push("armor")
        fieldsToGet.Push("creatureClass")
        fieldsToGet.Push("behaviour")
        fieldsToGet.Push("hp")
        fieldsToGet.Push("loot")
        fieldsToGet.Push("name")
        fieldsToGet.Push("runsat")
        fieldsToGet.Push("primarytype")
        fieldsToGet.Push("maxdmg")
        fieldsToGet.Push("senseinvis")
        ; fieldsToGet.Push("summon")
        fieldsToGet.Push("walksaround")
        fieldsToGet.Push("walksthrough")
        ; fieldsToGet.Push("strategy")

        newCreaturesObj := {}

        for key, atributes in downloadedCreaturesObj
        {
            ; msgbox, % key  " = " serialize(atributes)
            /**
            commented because of ugly monster
            */
            ; if (atributes.hp = "" OR atributes.hp = "?")
            ;     continue

            if (atributes.actualname = "") {
                if (atributes.name = "")
                    continue
                creatureName := RegExReplace(atributes.name,"[^\w]"," ")
            } else {
                creatureName := RegExReplace(atributes.actualname,"[^\w]"," ")
            }

            for key2, fieldName in fieldsToGet
            {
                if (!newCreaturesObj[creatureName])
                    newCreaturesObj[creatureName] := {}
                newCreaturesObj[creatureName][fieldName] := atributes[fieldName]
            }
        }

        Gosub,CarregandoCavebotGUI
        newCreaturesFile := new JSONFile(OldbotSettings.JsonFolder "\Creatures\creatures.json")
        newCreaturesFile.Fill(newCreaturesObj)
        newCreaturesFile.Save(true)
        Gui, CarregandoCavebot:Destroy




        Gui, Carregando:Destroy
        msgbox, % "Done. " A_TickCount - t1 " ms.`n" A_ThisFunc
    }

    createNewItemsFile() {
        CarregandoGUI("Working on items...", , , , , , , show_bar := false)
        t1 := A_TickCount


        fileDir := OldbotSettings.JsonFolder "\Items\items_downloaded.json"
        downloadedInfoJsonFile := new JSONFile(fileDir)
        downloadedItemsObj := downloadedInfoJsonFile.Object()


        atributesToSave := {}
        atributesToSave.Push("name")
        atributesToSave.Push("primarytype")
        atributesToSave.Push("secondarytype")
        ; atributesToSave.Push("itemclass")
        atributesToSave.Push("itemid")
        atributesToSave.Push("stackable")
        atributesToSave.Push("value")
        atributesToSave.Push("weight")
        atributesToSave.Push("marketable")
        atributesToSave.Push("volume")
        atributesToSave.Push("npcvalue")

        newItemsObj := {}

        for key, atributes in downloadedItemsObj
        {
            name := atributes.actualname 
            if (empty(name)) {
                continue
            }
            /**
            replace 2 spaces for 1
            */
            name := StrReplace(name, "  ", " ")

            /**
            replace " '" for ","
            */
            name := StrReplace(name, " '", "'")

            if (newItemsObj[name]) {
                Loop, 20 {
                    newName := name "_" A_Index + 1
                    if (newItemsObj[newName]) {
                        continue
                    }

                    newItemsObj[newName] := atributes
                    break
                }

                continue
            }

            newItemsObj[name] := atributes
        }
        itemsObj := {}

        for itemName, atributes in newItemsObj
        {
            ; msgbox, % itemName  " = " serialize(atributes)
            atributesObj := {}
            for key2, atributeName in atributesToSave
            {
                switch atributeName {
                    case "itemid":
                        atributesObj[atributeName] := atributes["itemid"][1]
                    default:
                        atributesObj[atributeName] := atributes[atributeName]
                }
            }
            ; msgbox, % serialize(atributesObj)
            itemsObj[itemName] := atributesObj
        }

        Gosub,CarregandoCavebotGUI
        newItemsFile := new JSONFile(OldbotSettings.JsonFolder "\Items\items.json")
        newItemsFile.Fill(itemsObj)
        newItemsFile.Save(true)
        Gui, CarregandoCavebot:Destroy


        Gui, Carregando:Destroy
        msgbox, % "Done. " A_TickCount - t1 " ms.`n" A_ThisFunc
    }

    cleanItemsImageObj() {
        atributesToDelete := {}
        t1 := A_TickCount

        CarregandoGUI("Working on items...", , , , , , , show_bar := false)

        for itemName, itemAtributes in itemsImageObj
        {
            itemsImageObj[itemName].Delete("category")
            itemsImageObj[itemName].Delete("id")
            itemsImageObj[itemName].animated_sprite := itemAtributes.animated_sprite += 0
            itemsImageObj[itemName].sprites := itemAtributes.sprites += 0 
        }


        ItemsHandler.saveItemsImage()

        Gui, Carregando:Destroy
        msgbox, % "Done. " A_TickCount - t1 " ms.`n" A_ThisFunc

    }







}
