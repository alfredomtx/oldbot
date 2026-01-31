Class _ScriptImages extends _BaseClass
{
    static DEFAULT_VARIATION := 40
    static MAX_WIDTH := 800
    static MAX_HEIGHT := 800
    static TEMP_IMAGE := A_Temp "\__scriptimage.png"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        this.checkScriptImages()
    }

    checkScriptImages() {
        if (scriptImagesObj.HasKey("WhereToStart") && !scriptImagesObj.HasKey("WhereToStart1")) {
            scriptImagesObj["WhereToStart1"] := scriptImagesObj["WhereToStart"]
            scriptImagesObj.Delete("WhereToStart")
        }
    }

    /**
    * @return _UniqueBase64ImageSearch
    */
    search(name, variation := "", searchArea := "", firstResult := true, debug := false)
    {
        scriptImage := new _ScriptImage(name)

        try {
            return new _UniqueBase64ImageSearch()
                .setImage(scriptImage)
                .setVariation(variation ? variation : _ScriptImages.DEFAULT_VARIATION)
                .setArea(new _ClientAreaFactory(searchArea ? searchArea : _WindowArea.NAME))
                .setTransColor("0")
                .setAllResults(!firstResult)
                .setResultOffsetX(scriptImage.getW() / 2)
                .setResultOffsetY(scriptImage.getH() / 2)
                .setDebug(debug)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, name, searchArea)
            throw e
        }
    }

    hasScriptImage(imageName) {
        return (scriptImagesObj.HasKey(imageName))
    }

    editImageCategory(imageName, category := "") {
        scriptImagesObj[imageName].category := category

        row := _ListviewHandler.findRowByContent(imageName, 2, "LV_ScriptImages", defaultGUI := "ScriptImagesGUI")
        LV_Modify(row, "", "", imageName, category)
        this.saveScriptImages()
    }

    editImageName(imageName, newName) {
        newName := "" newName "" ; in case is a number
        scriptImagesObj[newName] := scriptImagesObj[imageName]
        scriptImagesObj.Delete(imageName)
        row := _ListviewHandler.findRowByContent(imageName, 2, "LV_ScriptImages", defaultGUI := "ScriptImagesGUI")
        LV_Modify(row, "", "", newName)

        Gui, ListView, LV_ScriptImages
        Loop, 4
            LV_ModifyCol(A_Index, "autohdr")

        this.saveScriptImages()
    }

    deleteImage(imageName) {
        scriptImagesObj.Delete(imageName)
        this.saveScriptImages()
    }

    selectScriptImageRow(imageName) {
        row := _ListviewHandler.findRowByContent(imageName, 2, "LV_ScriptImages", "ScriptImagesGUI")
        _ListviewHandler.selectRow("LV_ScriptImages", row, "ScriptImagesGUI")

        try ScriptImagesGUI.LV_ScriptImages()
        catch {
        }
    }

    createTempScriptImageFromClipboard(imageName := "") {
        image := new _BitmapImage(_BitmapImage.SOURCE_CLIPBOARD)

        try this.validateScriptImageSize(imageName, image)
        catch e {
            image.dispose()
            throw e
        }

        image.save(_ScriptImages.TEMP_IMAGE)
    }

    addImageFromClipboard(imageName := "") {
        clipboardCount := 0
        for scriptImageName, _ in scriptImagesObj
        {
            clipboardString := SubStr(scriptImageName, 1, 9)
            if (clipboardString = "clipboard")
                clipboardCount := StrReplace(scriptImageName, "clipboard", "")
        }
        clipboardCount++

        imageName := imageName = "" ? "clipboard" clipboardCount : imageName

        try this.createTempScriptImageFromClipboard(imageName)
        catch e 
            throw e

        scriptImagesObj[imageName] := {}
        scriptImagesObj[imageName].image := FileToBase64(_ScriptImages.TEMP_IMAGE)

        ScriptImagesGUI.LoadScriptImagesLV()

        this.selectScriptImageRow(imageName)

        this.saveScriptImages()
    }

    changeImageFromClipboard() {
        selectedImage :=  _ListviewHandler.getSelectedItemOnLV("LV_ScriptImages", 2, "ScriptImagesGUI")
        if (selectedImage = "" OR selectedImage = "Name") {
            Msgbox, 64,, % "Select an image in the list.", 1
            return
        }

        try this.createTempScriptImageFromClipboard()
        catch e 
            throw e

        GetKeyState, CtrlPressed, Ctrl, D
        if (CtrlPressed != "D") {
            Msgbox, 68,, % "Current image will be changed.`n`nAre you sure?"
            IfMsgBox, No
                return
        }

        scriptImagesObj[selectedImage] := {}
        scriptImagesObj[selectedImage].image := FileToBase64(_ScriptImages.TEMP_IMAGE)

        ScriptImagesGUI.LoadScriptImagesLV()

        this.selectScriptImageRow(selectedImage)

        this.saveScriptImages()
    }

    /**
    * @param imageName string
    * @param _BitmapImage image
    * @return void
    * @throws
    */
    validateScriptImageSize(imageName, image) {
        whereToStartString := SubStr(imageName, 1, StrLen("WhereToStart"))

        w := image.getW()
        h := image.getH()
        switch whereToStartString {
            case "WhereToStart":
                if (w > 800) {
                    throw Exception("Image width(" w "px) is higher than 800px.")
                }
                if (h > 600) {
                    throw Exception("Image height(" h "px) is higher than 600px.")
                }
            default:
                if (w > _ScriptImages.MAX_WIDTH) {
                    throw Exception("Image width(" w "px) is higher than " _ScriptImages.MAX_WIDTH "px.")
                }
                if (h > _ScriptImages.MAX_HEIGHT) {
                    throw Exception("Image height(" h "px) is higher than " _ScriptImages.MAX_HEIGHT "px.")
                }
        }
    }

    addImageFromPath(path, imageName) {
        image := new _BitmapImage(path)
        try this.validateScriptImageSize(imageName, image)
        catch e {
            throw e
        } finally {
            image.dispose()
        }

        scriptImagesObj[imageName] := {}
        scriptImagesObj[imageName].image := FileToBase64(path)

        this.saveScriptImages()
    }

    saveScriptImages() {
        scriptFile.scriptImages := scriptImagesObj
        CavebotScript.saveSettings(A_ThisFunc)
    }

    getNextWhereToStartImageName() {
        Loop, 6 {
            if (!scriptImagesObj.hasKey("WhereToStart" A_Index))
                return "WhereToStart" A_Index
        }
        return 6
    }

    getLastWhereToStartImageName() {
        Loop, 6 {
            if (scriptImagesObj.hasKey("WhereToStart" A_Index)) {
                if (A_Index = 6)
                    return "WhereToStart" A_Index
                continue
            }
            return "WhereToStart" A_Index - 1
        }
        return 0
    }

    getLastWhereToStartImageNumber() {
        Loop, 6 {
            if (scriptImagesObj.hasKey("WhereToStart" A_Index)) {
                if (A_Index = 6)
                    return A_Index
                continue
            }
            return 1
        }
        return 0
    }

    testScriptImage() {
        selectedImage :=  _ListviewHandler.getSelectedItemOnLV("LV_ScriptImages", 2, "ScriptImagesGUI")
        if (selectedImage = "" OR selectedImage = "Name") {
            Msgbox, 64,, % "Select an image in the list.", 4
            return
        }

        if (TibiaClient.getClientArea() = false)
            return

        Gui, ScriptImagesGUI:Submit, NoHide
        Gui, ScriptImagesGUI:Hide
        WinActivate()

        switch (scriptImagesObj[selectedImage].category) {
            case "Corpse": 
                variation := (TargetingSystem.targetingJsonObj.useItemOnCorpse.corpseImageVariation > 0 ? TargetingSystem.targetingJsonObj.useItemOnCorpse.corpseImageVariation : 30)
            default: 
                variation := _ScriptImages.DEFAULT_VARIATION
        }

        debug := GetKeyState("Alt") && GetKeyState("Shift")
        GuiControlGet, scriptImageSearchArea
        try {
            _search := this.search(selectedImage, variation, scriptImageSearchArea, true, debug)
        } catch e {
            _Logger.msgboxException(e, A_ThisFunc, selectedImage)
            Gui, ScriptImagesGUI:Show
            return
        } finally {
            /*
            dispose because the image has transparent pixels after the search
            */
            _ := new _ScriptImage(selectedImage).dispose()
        }

        if (_search.notFound()) {
            msgbox,48,, % txt("Imagem não encontrada.`nÁrea de busca: ", "Image not found.`nSearch area:") scriptImageSearchArea,, 4
            Gui, ScriptImagesGUI:Show
            return
        }

        _search.moveMouse()

        GetKeyState, CtrlPressed, Ctrl, D
        if (CtrlPressed = "D") {
            _search.click("Left")
        }

        GetKeyState, ShiftPressed, Shift, D
        if (ShiftPressed = "D") {
            _search.click("Right")
        }

        msgbox, 64,, % "Found!", 2
        Gui, ScriptImagesGUI:Show
    }

}