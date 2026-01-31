
class _SpecialAreas extends _BaseClass
{
    static INSTANCE

    static BACKUP_FOLDER := _Folders.SPECIAL_AREAS "\backup"

    static MAIN_FILE := "special_areas.json"
    static AUTO_DETECTED_FILE := "special_areas_auto.json"
    static USER_FILE := "special_areas_user.json"
    static IMAGES_FILE := "special_areas_images.json"

    static INI_TEMP_SECTION := "temp"
    static INI_NEW_AUTO_DETECTED_KEY := "new_auto_detected_added"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    ; __New()
    ; {
    ;     if (_SpecialAreas.INSTANCE) {
    ;         return _SpecialAreas.INSTANCE
    ;     }

    ;     _SpecialAreas.INSTANCE := this
    ; }

    getFilePath(file)
    {
        return _Folders.SPECIAL_AREAS "\" file
    }

    load(force := false)
    {
        if (!force && this.data) {
            return this.data
        }

        CarregandoGUI(txt("Carregando Special areas...", "Loading Special areas..."))

        try {
            this.createFiles()

            this.mainFile := new JSONFile(this.getFilePath(this.MAIN_FILE))
            this.userFile := new JSONFile(this.getFilePath(this.USER_FILE))
            this.imagesFile := new JSONFile(this.getFilePath(this.IMAGES_FILE))

            this.main := this.mainFile.object()
            this.user := this.userFile.object()
            this.images := this.imagesFile.object()

            this.data := {}

            this.loadAutoDetected()

            this.iterateData(this.main, this.mergeData.bind(this))
            this.iterateData(this.user, this.mergeData.bind(this)) ; merge last (to override)
        } finally {
            Gui, Carregando:Destroy
        }

        return this.data
    }

    loadAutoDetected()
    {
        this.autoDetectedFile := new JSONFile(this.getFilePath(this.AUTO_DETECTED_FILE))
        this.autoDetected := this.autoDetectedFile.object()

        this.autoDetectedDelete := {}

        this.iterateData(this.autoDetected, this.cleanAutoDetected.bind(this))

        this.iterateData(this.autoDetectedDelete, this.deleteAutoDetectedArea.bind(this))
        this.autoDetectedFile.save()

        this.iterateData(this.autoDetected, this.mergeAutoDetected.bind(this))
    }

    /**
    * @return strings
    * @throws
    */
    selectFileToMerge()
    {
        FileSelectFile, filePath, 3,, % txt("Importar Script - Selecione o arquivo .JSON", "Import Script - Select the .JSON file"), (*.json)
        if (!filePath) {
            return
        }

        _Validation.fileExists(filePath)

        return filePath
    }

    /**
    * @return void
    */
    importFile()
    {
        try {
            filePath := this.selectFileToMerge()
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc)
            return
        }

        if (!filePath) {
            return
        }

        this.load()

        file := new JSONFile(filePath)
        data := file.object()

        this.dataToMerge := {}
        this.imported := 0
        this.ignored := 0

        this.iterateData(data, this.addDataToMerge.bind(this))
        data := ""

        if (!this.dataToMerge.Count()) {
            if (this.ignored) {
                Msgbox, 64, % txt("Nada a ser importado", "Nothing to be imported"), % this.ignored " " txt("Special areas ignoradas(já existentes) do arquivo selecionado.", "Ignored(already existing) Special areas from the selected file.") "`n" "`n" filePath
            } else {
                Msgbox, 64,, % txt("Nenhum dado de special area para ser importado no arquivo selecionado.", "No special area data to be imported in the selected file.") "`n" filePath
            }

            return
        }

        this.backupFile()

        this.iterateData(this.dataToMerge, this.addFromImported.bind(this))

        file := ""
        this.save()
        Msgbox, 64,, % this.imported " " txt("Special areas importadas.", "Special areas imported successfully.")
    }

    /**
    * @param Object area
    * @return void
    */
    addFromImported(area)
    {
        this.mergeData(area)
        this.add(_SpecialArea.fromArray(area), save := false, addToMain := true)
        this.imported++
    }

    /**
    * @return void
    */
    backupFile()
    {
        ; FIXME: not working, filecopy is failing
        return
        if (!FileExist(this.BACKUP_FOLDER)) {
            FileCreateDir, % this.BACKUP_FOLDER
        }   

        timestamp :=  "D" A_Year "-" A_Mon "-" A_MDay "_" A_Hour ":" A_Min ":" A_Sec "." A_MSec
        clipboard := timestamp
        dest := this.BACKUP_FOLDER "\" StrReplace(this.USER_FILE "_" timestamp, ".json", "") ".json"
        src := this.getFilePath(this.USER_FILE)

        try {
            _Validation.fileExists(src)

            FileCopy, % src, % dest, 1
        } catch e {
            _Logger.msgboxException(16, e, A_ThisFunc)
            error := ErrorLevel
        }
    }

    /**
    * @param Object area
    * @return void
    */
    addDataToMerge(area)
    {
        if (!this.data[area.z, area.x, area.y]) {
            this.dataToMerge[area.z, area.x, area.y] := area
            return
        }

        this.ignored++
        ; override it?    
    }

    /**
    * @param array area
    * @return void
    */
    cleanAutoDetected(area)
    {
        difference := A_NowUTC - area.firstTryAt
        if (!difference) {
            this.autoDetectedDelete[area.z, area.x, area.y] := area
            return
        }

        minutes := Format("{:0.2f}", difference / 60000) ; 1 minute = 60000 milliseconds
        hours := Format("{:0.2f}", difference / 3600000) ; 1 hour = 3600000 milliseconds

        if (area.tries == 1 && hours >= 24) {
            this.autoDetectedDelete[area.z, area.x, area.y] := area
        }
    }

    /**
    * @param array area
    * @return void
    */
    mergeAutoDetected(area, override := true)
    {
        if (!area.tries || area.tries <= 1) {
            return
        }

        this.mergeData(area, override)
    }

    /**
    * @param array area
    * @return void
    */
    mergeData(area, override := true)
    {
        if (override || !this.data[area.z, area.x, area.y]) {
            this.data[area.z, area.x, area.y] := _Arr.filter(area)
        }
    }

    /**
    * @param Object area
    * @return void
    */
    mergeDataByKey(area, keys)
    {
        for key, value in area {
            if (!keys[key]) {
                continue
            }

            if (!this.data[area.z, area.x, area.y] || !this.data[area.z, area.x, area.y].key) {
                this.data[area.z, area.x, area.y][key] := value
            }
        }
    }

    /**
    * @param array data
    * @param function callback
    * @return void
    */
    iterateData(data, callback, params := "")
    {
        for _, z in data {
            for _, x in z {
                for _, specialArea in x {
                    (params) ? callback.Call(specialArea, params) : callback.Call(specialArea)
                }
            }
        }
    }

    /**
    * @return void
    */
    createFiles()
    {
        static files
        if (!files) {
            files := {}
            files.Push(this.getFilePath(this.MAIN_FILE))
            files.Push(this.getFilePath(this.USER_FILE))
            files.Push(this.getFilePath(this.IMAGES_FILE))
            files.Push(this.getFilePath(this.AUTO_DETECTED_FILE))
        }

        if (!FileExist(_Folders.SPECIAL_AREAS)) {
            FileCreateDir, % _Folders.SPECIAL_AREAS
        }

        for _, filePath in files {
            if (FileExist(filePath)) {
                continue
            }

            file := new JSONFile(filePath)
            file.save()
            file := ""
        }
    }

    /**
    * @param _SpecialArea area
    * @param ?bool save
    * @return void
    */
    addAutoDetected(area, save := true, writeIni := false)
    {
        x := area.getX(), y := area.getY(), z := area.getZ()

        this.setArea(area)

        if (!this.autoDetected[z, x, y]) {
            this.autoDetected[z, x, y] := this.data[z, x, y]
        }

        tries := this.autoDetected[z, x, y].tries
        if (this.autoDetected[z, x, y].tries) {
            this.autoDetected[z, x, y].tries++
        } else {
            this.autoDetected[z, x, y].tries := 1
            this.autoDetected[z, x, y].firstTryAt := A_NowUTC
        }

        if (save) {
            this.autoDetectedFile.save()
            this.imagesFile.save()

            if (writeIni && this.autoDetected[z, x, y].tries > 1) {
                _Ini.write(this.INI_NEW_AUTO_DETECTED_KEY, 1, this.INI_TEMP_SECTION)
            }
        }
    }

    /**
    * @param _SpecialArea area
    * @param ?bool save
    * @return void
    */
    setArea(area)
    {
        this.load()

        _Validation.instanceOf("area", area, _SpecialArea)
        _Validation.number("area.getX()", x := area.getX())
        _Validation.number("area.getY()", y := area.getY())
        _Validation.number("area.getZ()", z := area.getZ())

        image := area.image
        data := area.toArray()
        data.delete("image")

        this.data[z, x, y] := data

        this.setAreaImage(area, image)
    }

    /**
    * @param _SpecialArea area
    * @param ?bool save
    * @param ?bool addToMain
    * @return void
    */
    add(area, save := true, addToMain := false)
    {
        this.setArea(area)

        x := area.getX(), y := area.getY(), z := area.getZ()

        if (!A_IsCompiled && addToMain) {
            this.main[z, x, y] := this.data[z, x, y]
        }

        this.user[z, x, y] := this.data[z, x, y]

        this.deleteAutoDetected(x, y, z, save)

        if (save) {
            this.save()
        }
    }

    /**
    * @param int x
    * @param int y
    * @param int z
    * @param ?bool save
    * @return void
    */
    deleteImage(x, y, z, save := true)
    {
        if (this.images[z, x , y]) {
            this.deleteCoordinate(this.images, x, y, z)

            if (save) {
                this.imagesFile.save()
            }
        }
    }

    /**
    * @param int x
    * @param int y
    * @param int z
    * @param ?bool save
    * @return void
    */
    deleteMainArea(x, y, z, save := true)
    {
        if (this.main[z, x , y]) {
            this.deleteCoordinate(this.main, x, y, z)

            if (save) {
                this.mainFile.save()
            }
        }
    }

    /**
    * @param int x
    * @param int y
    * @param int z
    * @param ?bool save
    * @return void
    */
    deleteUserArea(x, y, z, save := true)
    {
        if (this.user[z, x , y]) {
            this.deleteCoordinate(this.user, x, y, z)

            if (save) {
                this.userFile.save()
            }
        }
    }

    /**
    * @param int x
    * @param int y
    * @param int z
    * @param ?bool save
    * @return void
    */
    deleteAutoDetected(x, y, z, save := true)
    {
        if (this.autoDetected[z, x, y]) {
            this.deleteCoordinate(this.autoDetected, x, y, z)

            if (save) {
                this.autoDetectedFile.save()
            }
        }
    }

    /**
    * @param Object area
    * @param ?bool save
    * @return void
    */
    deleteAutoDetectedArea(area, save := true)
    {
        this.deleteAutoDetected(area.x, area.y, area.z, save)
    }

    /**
    * @param Object object
    * @param int x
    * @param int y
    * @param int z
    * @return void
    */
    deleteCoordinate(ByRef object, x, y, z)
    {
        object[z][x].Delete(y)
        if (!object[z][x].Count()) {
            object[z].Delete(x)
        }

        if (!object[z].Count()) {
            object.Delete(z)
        }
    }

    /**
    * @param Object area
    * @param ?bool save
    * @return void
    */
    softDeleteArea(area, save := true)
    {
        this.load()

        _Validation.number("area.getX()", x := area.getX())
        _Validation.number("area.getY()", y := area.getY())
        _Validation.number("area.getZ()", z := area.getZ())


        /*
        if is in both main and user special areas, the user is removing a area from the main file
        in this case a soft delete is done(area is set in the user file as deleted) and main is kept as is
        */
        userOrAutoDetected := this.user[z, x , y] || this.autoDetected[z, x , y]

        area.softDelete()

        if (this.main[z, x , y] && userOrAutoDetected) {
            if (area.isDeleted()) {
                if (!A_IsCompiled) {
                    this.deleteCoordinate(this.data, x, y, z)
                    this.deleteMainArea(x, y, z, save)
                    this.deleteUserArea(x, y, z, save)
                    this.deleteAutoDetected(x, y, z, save)
                }

                return
            }

            this.user[z, x , y] := area
            this.data[z, x , y] := area

            if (save) {
                this.userFile.save() 
            }
        }

        /*
        if it's not in main and is in user, then it's a real delete from the user special area
        */
        if (!this.main[z, x , y] && userOrAutoDetected) {
            this.deleteCoordinate(this.data, x, y, z)
            this.deleteUserArea(x, y, z, save)
            this.deleteAutoDetected(x, y, z, save)
        }

        /*
        if it's in the main and not in the user areas, it's a delete from main(and all files)
        */
        if (this.main[z, x , y] && !userOrAutoDetected) {
            if (A_IsCompiled) {
                return
            }

            this.deleteCoordinate(this.data, x, y, z)

            this.deleteMainArea(x, y, z, save)
            this.deleteImage(x, y, z, save)

            if (save) {
                this.mainFile.save() 
            }
        }
    }

    /**
    * @param _SpecialArea area
    * @param ?bool save
    * @return void
    */
    deleteArea(area, save := true)
    {
        this.load()

        _Validation.number("area.getX()", x := area.getX())
        _Validation.number("area.getY()", y := area.getY())
        _Validation.number("area.getZ()", z := area.getZ())

        if (this.main[z, x , y] || this.user[z, x , y] || this.data[z, x , y]) {
            this.deleteCoordinate(this.data, x, y, z)

            if (!A_IsCompiled) {
                this.deleteMainArea(x, y, z, save)
            }

            this.deleteUserArea(x, y, z, save)
        }

        this.deleteAutoDetected(x, y, z, save)
        this.deleteImage(x, y, z, save)
    }

    /**
    * @param ?bool save
    * @return void
    */
    save(saveImages := true)
    {
        if (!A_IsCompiled) {
            this.mainFile.save()
        }

        this.userFile.save() 

        if (saveImages) {
            this.imagesFile.save()
        }
    }

    /**
    * @return void
    */
    saveAll()
    {
        if (!A_IsCompiled) {
            this.mainFile.save()
        }

        this.userFile.save() 
        this.imagesFile.save()
        this.autoDetectedFile.save()
    }

    ;#Region Getters
    /**
    * @param int x
    * @param int y
    * @param int z
    * @param ?bool instance
    * @return null|object|_SpecialArea
    */
    get(x, y, z, instance := true)
    {
        this.load()

        data := this.data[z, x , y]
        if (!data) {
            return
        }

        return instance ? _SpecialArea.fromArray(data) : data
    }

    /**
    * @param int x
    * @param int y
    * @param int z
    * @return array
    */
    getAreaImage(x, y, z)
    {
        this.load()

        data := this.images[z, x , y]
        if (!data) {
            return
        }

        return data.image
    }
    ;#Endregion

    ;#Region Setters
    /**
    * @param _SpecialArea area
    * @param string image
    */
    setAreaImage(area, image, save := false)
    {
        if (!image) {
            return
        }   

        this.load()

        x := area.getX(), y := area.getY(), z := area.getZ()

        if (!this.images[z, x, y]) {
            this.images[z, x, y] := {}
        }

        this.images[z, x, y].x := x
        this.images[z, x, y].y := y
        this.images[z, x, y].z := z
        this.images[z, x, y].image := image

        if (area.getType() == _SpecialArea.TYPE_BLOCKED_AUTO_DETECTED) {
            this.images[z, x, y].type := _SpecialArea.TYPE_BLOCKED_AUTO_DETECTED
        }

        if (save) {
            this.imagesFile.save()
        }
    }
    ;#Endregion
}
