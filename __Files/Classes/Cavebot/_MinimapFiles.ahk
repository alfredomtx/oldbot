

global minimapFolder
Class _MinimapFiles
{
    __New()
    {
        ; minimapFolder := "C:\app_oldbot\rootfs\home\test\.local\share\CipSoft GmbH\Tibia\packages\Tibia\minimap"
        minimapFolder := TibiaClient.clientMinimapPath


        this.minimapImagesFolder := "__Files\__Minimap"

        this.customMinimapFolder := "Data\Custom Minimap" (OldBotSettings.settingsJsonObj.map.folders.mapFilesInternal = "" ? "" : "\" OldBotSettings.settingsJsonObj.map.folders.mapFilesInternal)

        this.othersFolderMinimap := "Data\Files\Others"
        this.minimapTXTFilesFolder := this.othersFolderMinimap "\mp" (OldBotSettings.settingsJsonObj.map.folders.mapFiles = "" ? "" : "\" OldBotSettings.settingsJsonObj.map.folders.mapFiles)

        this.hasPathFiles := OldBotSettings.settingsJsonObj.map.settings.pathFiles

        IfNotExist, % this.customMinimapFolder
            FileCreateDir, % this.customMinimapFolder

        this.pMinimapFloors := {}
        ; this.pMinimapFloorsPath := {}
        ; this.pMinimapFloorsGray := {}
        this.G := {}


        /**
        the .png files of this.minimapImagesFolder folder doesn't exist in the user's PC
        so must use the .txt files to create bitmap from map images
        */
        this.createBitmapFromTXT := true



        this.GrayMatrix := "0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1"


        if (OldBotSettings.settingsJsonObj.map.settings.mapWidth = "")
            throw Exception("Empty mapWidth")
        if (OldBotSettings.settingsJsonObj.map.settings.mapHeight = "")
            throw Exception("Empty mapHeight")

        this.mapWidth := OldBotSettings.settingsJsonObj.map.settings.mapWidth
        this.mapHeight := OldBotSettings.settingsJsonObj.map.settings.mapHeight


        ; msgbox, class initialized
    }

    updateMinimapFilesOTClient() {

        try this.minimapFolderExists()
        catch e
            throw e

        minimapOtmmFile := this.othersFolderMinimap "\minimap.otmm"

        if (!FileExist(minimapOtmmFile))
            throw Exception("""minimap.otmm"" file doesn't exist, please contact support.")

        if (TibiaClient.isClientOpened() = true)
            throw Exception((LANGUAGE = "PT-BR" ? "Cliente do Tibia deve estar FECHADO para atualizar o minimapa.`nFeche e tente novamente." : "Tibia client must be CLOSED to update the minimap.`nClose it and try again."))


        try FileCopy, % minimapOtmmFile, % TibiaClient.clientMinimapPath, 1
        catch e {
            throw Exception("Failed to copy ""minimap.otmm"" file to minimap directory.`nDir: " TibiaClient.clientMinimapPath "`nError: " e.What " | " e.Extra)
        }

    }

    updateMinimapFiles(downloadFiles := false, reloadBot := false) {
        try this.minimapFolderExists()
        catch e
            throw e

        if (TibiaClient.isClientOpened() = true) {
            Msgbox, 48,, % "Tibia client must be CLOSED to update the minimap.`nClose it and try again."
            return
        }

        CarregandoGUI("Updating minimap files...")

        t1 := A_TickCount
        if (downloadFiles = true) {
            this.downloadFiles(true)
            this.replaceFiles(true)
            Sleep, 100
            this.convertAllToGray(true)
            Sleep, 100
            this.createTXTs()
            Sleep, 100
        }

        ; try this.fixMinimapFilesPixels(true)
        ; catch e
        ;     throw e
        ; Sleep, 100
        try this.fixMinimapFiles(true, false)
        catch e
            throw e
        Sleep, 100
        try this.fixMinimapFiles(true, true)
        catch e
            throw e
        Sleep, 100
        try this.replaceTibiaMinimapFiles(true)
        catch e
            throw e
        Sleep, 100
        try this.doneMessage(t1, "")
        catch e
            throw e
        if (reloadBot = true) && (A_IsCompiled)
            Reload
    }

    minimapFolderExists() {
        minimapFolder := TibiaClient.clientMinimapPath
        if (minimapFolder = "" OR minimapFolder = A_Space)
            throw Exception("Minimap folder is not set, set the path of the folder on ""Select Client"" to continue.")

        ; if (!FileExist("C:\app_oldbot"))
        ; throw Exception(LANGUAGE = "PT-BR" ? "Pasta do ambiente do Tibia (C:\app_oldbot) não existe" : "Folder of the Tibia ambient (C:\app_oldbot) doesn't exist.")
        if (!FileExist(minimapFolder))
            throw Exception(LANGUAGE = "PT-BR" ? "Pasta do minimap do Tibia """ minimapFolder """ não existe." : "The minimap Tibia folder """ minimapFolder """ doesn't exist.")
    }

    createDownloadThread(amountOfThreads) {
        global
        script := "
            (Ltrim
                #Persistent
                #NoTrayIcon
                threadFinished := false
                while !releaseThread
                Sleep, 50
                ; msgbox, % ""inside thread "" URL ""   "" fileName
                UrlDownloadToFile, % URL, % fileName
                UrlDownloadToFile, % URL2, % fileName2
                ; msgbox, aaaa finished
                threadFinished := true
                return
            )"

        Loop %amountOfThreads% {
            try
                download%A_Index% := ThreadManager.createThread("download" A_Index, script)
            catch e {
                Msgbox, 16,, % e.Message "`n" e.What "`n" e.Extra "`n" e.Line
                return
            }

        }

    }

    downloadFiles(fromUpdateFunction := false) {
        if (fromUpdateFunction = false)
            t1 := A_TickCount

        CarregandoGUI("[0%] Downloading minimap files...", text_width := 200, progress_width := 200, , , , , show_bar := false)

        downloadThreads := 16
        this.createDownloadThread(downloadThreads)

        InfoCarregando("[1%] Downloading files...")

        ; msgbox, % serialize(threads)
        Loop, 16 {
            index := A_Index - 1
            floorString := (StrLen(index) = 1) ? "0" index : index

            threadName := "download" A_Index
            %threadName%.ahkassign("URL","https://github.com/tibiamaps/tibia-map-data/raw/main/data/floor-" floorString "-map.png")
            try FileDelete, % this.minimapImagesFolder "\floor-" floorString "-map_downloaded.png"
            catch {
            }
            try FileDelete, % this.minimapImagesFolder "\floor-" floorString "-path_downloaded.png"
            catch {
            }
        }
        Sleep, 50
        InfoCarregando("[2%] Downloading files...")
        ; msgbox, all files deleted


        indexPercent := 0
        /**
        normal images (colored)
        */
        Loop, 16 {
            index := A_Index - 1
            floorString := (StrLen(index) = 1) ? "0" index : index



            threadName := "download" A_Index
            %threadName%.ahkassign("URL","https://github.com/tibiamaps/tibia-map-data/raw/main/data/floor-" floorString "-map.png")
            %threadName%.ahkassign("URL2","https://github.com/tibiamaps/tibia-map-data/raw/main/data/floor-" floorString "-path.png")
            %threadName%.ahkassign("fileName", this.minimapImagesFolder "\floor-" floorString "-map_downloaded.png")
            %threadName%.ahkassign("fileName2", this.minimapImagesFolder "\floor-" floorString "-path_downloaded.png")
            ; msgbox, released thread %threadName%
            %threadName%.ahkassign("releaseThread","1")

            ; msgbox, released %threadName%
            ; sucess := this.downloadFromUrl("https://github.com/tibiamaps/tibia-map-data/raw/main/data/floor-" floorString "-map.png", this.minimapImagesFolder "\floor-" floorString "-map_downloaded.png")
            ; if (sucess = false)
            ;     break
            Sleep, 100
        }
        InfoCarregando("[5%] Downloading files...")

        indexPercent := 0
        Loop %downloadThreads% {
            indexPercent++
            Percent := (indexPercent * 100) / 16
            threadNumber := A_Index
            threadName := "download" A_Index
            Loop, {

                try
                    finished := ThreadManager.checkThreadFinished(threadName, false)
                catch e {
                    Msgbox, 16,, % e.Message "`n" e.What "`n" e.Extra "`n" e.Line
                    return
                }
                ; msgbox, % threadName ": " finished
                if (finished = true) {
                    InfoCarregando("[" Percent "%] Downloading files...")
                    ThreadManager.finishThread(threadName)
                    break
                }

            }
        }
        if (fromUpdateFunction = false)
            this.doneMessage(t1, A_ThisFunc)
        return
        /**
        path images (yellow)
        */
        Loop, 16 {
            indexPercent++
            Percent := (indexPercent * 100) / (14 * 2)
            InfoCarregando("[" Percent "%] Downloading files...")
            index := A_Index - 1
            floorString := (StrLen(index) = 1) ? "0" index : index
            sucess := this.downloadFromUrl("https://github.com/tibiamaps/tibia-map-data/raw/main/data/floor-" floorString "-path.png", this.minimapImagesFolder "\floor-" floorString "-path_downloaded.png")
            if (sucess = false)
                break
            Sleep, 10
        }

        if (fromUpdateFunction = false)
            this.doneMessage(t1, A_ThisFunc)

    }

    doneMessage(t1, func := "") {
        elapsed := A_TickCount - t1
        Gui, Carregando:Destroy
        msgbox, 64,, Done! %elapsed% ms`n%func%, 4
    }


    replaceFiles(fromUpdateFunction := false) {
        if (fromUpdateFunction = false)
            t1 := A_TickCount

        CarregandoGUI("[1%] Checking files...", , , , , , , show_bar := false)
        ; global CavebotWalker := ""

        ; Loop, 16 {
        ;     index := A_Index - 1
        ;     floorString := (StrLen(index) = 1) ? "0" index : index

        ;     Gdip_DisposeImage(pBitmapPathFloor%floorString%)
        ;     Gdip_DisposeImage(pBitmapColoredFloor%floorString%)
        ;     pBitmapPathFloor%floorString% := "", pBitmapColoredFloor%floorString% := ""

        ; }
        Sleep, 25



        Loop, 16 {
            Percent := (A_Index * 100) / 16
            InfoCarregando("[" Percent "%] Checking files...")
            /**
            normal images (colored)
            */
            index := A_Index - 1
            floorString := (StrLen(index) = 1) ? "0" index : index
            fileSrc := this.minimapImagesFolder "\floor-" floorString "-map_downloaded.png"
            if (!FileExist(fileSrc)) {
                continue
            }
            fileDest := this.minimapImagesFolder "\floor-" floorString "-map.png"
            if (!FileExist(fileDest)) {
                FileMove, %fileSrc%, %fileDest%, 1
                continue
            }
            try FileGetSize, downloadedFileSize, %fileSrc%, K
            catch e {
                Msgbox, 16,, % e.Message "`n" e.What "`n" e.Line "`n" e.File "`n`n" fileDest
            }
            try FileGetSize, originalFileSize, %fileDest%, K
            catch e {
                Msgbox, 16,, % e.Message "`n" e.What "`n" e.Line "`n" e.File "`n`n" fileDest
            }
            if (downloadedFileSize > originalFileSize / 2) { ; if the downloaded file is at least bigger than half the size of the original minimap file
                try
                    FileMove, %fileSrc%, %fileDest%, 1
                catch {
                    Gui, Carregando:Destroy
                    throw Exception("Failed to replace map file " floorString ".")
                    continue
                }
            }
            Sleep, 10
            /**
            path images (yellow)
            */
            fileSrc := this.minimapImagesFolder "\floor-" floorString "-path_downloaded.png"
            if (!FileExist(fileSrc))
                continue
            fileDest := this.minimapImagesFolder "\floor-" floorString "-path.png"
            if (!FileExist(fileDest)) {
                FileMove, %fileSrc%, %fileDest%, 1
                continue
            }
            try FileGetSize, downloadedFileSize, %fileSrc%, K
            catch e {
                Msgbox, 16,, % e.Message "`n" e.What "`n" e.Line "`n" e.File "`n`n" fileDest
            }
            try FileGetSize, originalFileSize, %fileDest%, K
            catch e {
                Msgbox, 16,, % e.Message "`n" e.What "`n" e.Line "`n" e.File "`n`n" fileDest
            }
            if (downloadedFileSize > originalFileSize / 2) { ; if the downloaded file is at least bigger than half the size of the original minimap file
                try
                    FileMove, %fileSrc%, %fileDest%, 1
                catch {
                    Gui, Carregando:Destroy
                    throw Exception("Failed to replace path file " floorString ".")
                    continue
                }
            }
            Sleep, 10
        }


        Sleep, 25
        ; try
        ;     global CavebotWalker := new _CavebotWalker()
        ; catch e {
        ;     Gui, Conectando:Destroy
        ;     Gui, Carregando:Destroy
        ;     throw e
        ; }

        if (fromUpdateFunction = false)
            this.doneMessage(t1, A_ThisFunc)
    }

    downloadFromUrl(URL, fileName) {
        UrlDownloadToFile, %URL%, %fileName%
        if (ErrorLevel != 0) {
            Msgbox, 16,, % "Error(" ErrorLevel ") downloading file;`n`nFile name: " fileName "`n`nURL: " URL
            return false
        }
        return true
    }

    createTXTs(createFromNewFiles := false) {

        InfoCarregando("Creating .o files...")

        Loop, 16 {
            index := A_Index - 1
            floorString := (StrLen(index) = 1) ? "0" index : index

            filePrefix := this.minimapTXTFilesFolder "\" floorString

            /**
            color
            */
            txtFileName := filePrefix "-m.o"
            file := this.minimapImagesFolder "\floor-" floorString "-map" (createFromNewFiles = true ? "-new" : "") ".png"
            try this.createBase64File(file, txtFileName)
            catch
                return
            ; Sleep, 10

            txtFileName := filePrefix "-m-wc.o"
            file := this.minimapImagesFolder "\floor-" floorString "-map-wc" (createFromNewFiles = true ? "-new" : "") ".png"
            if (FileExist(file)) {
                try this.createBase64File(file, txtFileName)
                catch
                    return
                ; Sleep, 10
            }

            /**
            gray
            */
            txtFileName := filePrefix "-m-g.o"
            file := this.minimapImagesFolder "\floor-" floorString "-map-gray" (createFromNewFiles = true ? "-new" : "") ".png"
            try this.createBase64File(file, txtFileName)
            catch
                return
            Sleep, 10

            txtFileName := filePrefix "-m-wc-g.o"
            file := this.minimapImagesFolder "\floor-" floorString "-map-wc-gray" (createFromNewFiles = true ? "-new" : "") ".png"
            if (FileExist(file)) {
                try this.createBase64File(file, txtFileName)
                catch
                    return
                Sleep, 10
            }

            /**
            path
            */
            if (this.hasPathFiles = true) {
                txtFileName := filePrefix "-p.o"
                file := this.minimapImagesFolder "\floor-" floorString "-path" (createFromNewFiles = true ? "-new" : "") ".png"
                ; Sleep, 10

                txtFileName := filePrefix "-p-wc.o"
                file := this.minimapImagesFolder "\floor-" floorString "-path-wc" (createFromNewFiles = true ? "-new" : "") ".png"
                if (FileExist(file)) {
                    try this.createBase64File(file, txtFileName)
                    catch
                        return
                    ; Sleep, 10
                }
            }



            ; if (floorString = "07") {
            ;     pBitmapFile := Gdip_CreateBitmapFromFile(file)
            ;     Gdip_SetBitmapToClipboard(pBitmapFile)
            ;     msgbox, a
            ; }
        }
    }



    createTXTsFromUserInterface(type, worldChangeFiles := false) {
        InfoCarregando("Creating .o files...")

        Loop, 16 {
            index := A_Index - 1
            floorString := (StrLen(index) = 1) ? "0" index : index

            this.createTXTFileFromMinimapImageFile(this.newMinimapFileName(floorString, type, worldChangeFiles), type, floorString)
            ; Sleep, 10
        }
    }

    createTXTFileFromMinimapImageFile(imageFile, type, floorString) {
        if (!pToken)
            throw Exception("Gdip not initialized")

        prefix := this.getFileTypePrefix(type)
        txtFileName := this.minimapTXTFilesFolder "\" floorString "-" prefix ".o"

        ; msgbox, % imageFile "`n" txtFileName "`n" floorString
        try this.createBase64File(imageFile, txtFileName, floorString)
        catch e {
            Msgbox, 16, % A_ThisFunc, % e.Message "`n" e.What
            return
        }

        try FileDelete, % imageFile
        catch {
        }
    }

    createBase64File(file, txtFileName, floorString := "") {
        if (!FileExist(file)) {
            if (InStr(file, "00"))
                return true
            Gui, Carregando:Destroy
            Msgbox, 16, % A_ThisFunc, % "File doesn't exist.`n`nFile name: " file
            throw Exception("")
        }

        base64 := FileToBase64(file)
        if (base64 = "" OR base64 = 0) {
            Gui, Carregando:Destroy
            Msgbox, 16, % A_ThisFunc, % "Empty file content: " file
            throw Exception("")
        }
        file := FileOpen(txtFileName, "w")
        file.Write(base64)
        file.Close()

    }

    convertAllToGray(fromUpdateFunction := false) {
        CarregandoGUI("[0%] Working on files...", , , , , , , show_bar := false)

        t1 := A_TickCount

        Loop, 16 {
            Percent := (A_Index * 100) / 16
            InfoCarregando("[" Percent "%] Working on files...")
            index := A_Index - 1
            floorString := (StrLen(index) = 1) ? "0" index : index
            this.convertToGray(this.minimapImagesFolder "\floor-" floorString "-map.png", this.minimapImagesFolder "\floor-" floorString "-map-gray.png")
            Sleep, 10
        }
        if (fromUpdateFunction = false)
            this.doneMessage(t1, "")
    }

    convertToGray(fileName, newFileName, checkNewFileExists := false) {
        if (!FileExist(fileName)) {
            if (InStr(fileName, "00"))
                return true
            Msgbox, 16,, % "File doesn't exist.`n`nFile name: " fileName
            return false
        }
        if (checkNewFileExists = true) && (!FileExist(newFileName)) {
            if (InStr(fileName, "00"))
                return true
            Msgbox, 16,, % "New file doesn't exist.`n`nFile name: " newFileName
            return false
        }
        if (!pToken)
            throw Exception("Gdip not initialized")

        pBitmapFile1 := Gdip_CreateBitmapFromFile(fileName)
        Width := Gdip_GetImageWidth(pBitmapFile1), Height := Gdip_GetImageHeight(pBitmapFile1)

        pBitmap := Gdip_CreateBitmap(Width,height)

        G := Gdip_GraphicsFromImage(pBitmap)

        Gdip_DrawImage(G, pBitmapfile1, 0, 0, Width, Height, 0, 0, Width, Height, this.GrayMatrix)

        Gdip_SaveBitmapToFile(pBitmap, newFileName)
        Gdip_DisposeImage(pBitmap), Gdip_DisposeImage(pBitmapFile1), Gdip_DeleteGraphics(G)
    }

    convertAllToGrayFromMinimapBitmapToTXT(fromUpdateFunction := false) {
        CarregandoGUI("[0%] Working on files...", , , , , , , show_bar := false)

        t1 := A_TickCount

        Loop, 16 {
            Percent := (A_Index * 100) / 16
            InfoCarregando("[" Percent "%] Working on files...")
            index := A_Index - 1
            floorString := (StrLen(index) = 1) ? "0" index : index

            this.convertToGrayFromMinimapBitmapToTXT(A_Temp "\OldBot\" floorString "-g.png" , floorString)
            ; Sleep, 10
        }
        if (fromUpdateFunction = false)
            this.doneMessage(t1, "")
    }



    convertToGrayFromMinimapBitmapToTXT(imageFile, floorString) {
        if (!pToken)
            throw Exception("Gdip not initialized")

        Width := Gdip_GetImageWidth(this.pMinimapFloors[floorString]), Height := Gdip_GetImageHeight(this.pMinimapFloors[floorString])

        pBitmap := Gdip_CreateBitmap(Width,height)

        G := Gdip_GraphicsFromImage(pBitmap)

        Gdip_DrawImage(G, this.pMinimapFloors[floorString], 0, 0, Width, Height, 0, 0, Width, Height, this.GrayMatrix)

        Gdip_SaveBitmapToFile(pBitmap, imageFile)
        Sleep, 25

        ; if (floorString = "07") {
        ;     Gdip_SetBitmapToClipboard(pBitmap)
        ;     msgbox, a
        ; }
        txtFileName := this.minimapTXTFilesFolder "\" floorString "-m-g.o"
        try this.createBase64File(imageFile, txtFileName, floorString)
        catch e {
            Msgbox, 16, % A_ThisFunc, % e.Message "`n" e.What
            return
        }

        Gdip_DisposeImage(pBitmap), Gdip_DeleteGraphics(G)
        try FileDelete, % imageFile
        catch {
        }
    }

    /**
    generates a full .png picture with the tibia map (2560x2048), like the map files of Tibiamaps.io:
    https://tibiamaps.github.io/tibia-map-data/floor-07-map.png
    */
    generateTibiaMapFile(floor := "", costFiles := false) {

        if (floor = "")
            throw Exception("Empty floor param.")

        ; those variables don't change, unless tibia's map gets bigger
        mapStartX := 31744
        mapStartY := 30976
        mapEndX := 34303
        mapEndY := 33023
        mapZ := floor

        if (!pToken)
            throw Exception("Gdip not initialized")


        ; filesCount := 0
        ; Path := minimapFolder "\*_" mapZ ".png"
        ; Loop, %Path% {
        ;   IfInString, A_LoopFileName, Cost ; se não for a imagem com pixels amarelos ignora
        ;     continue
        ;   ; msgbox, % A_LoopFileName
        ;   StringReplace, image_file, A_LoopFileName, Minimap_WaypointCost_,, All
        ;   StringSplit, coord, image_file, _
        ;   x1_image := coord1, y1_image := coord2, x2_image := x1_image + 256, y2_image := y1_image + 256
        ;   filesCount++
        ; }

        ; msgbox, % filesCount
        mapX := mapStartX
        mapY := mapStartY

        mapXFileCoord := 0
        mapYFileCoord := 0

        files := {}


        newImageWidth := 2560
        newImageHeight := 2048
        pBitmapNewImage := Gdip_CreateBitmap(newImageWidth, newImageHeight)
        G := Gdip_GraphicsFromImage(pBitmapNewImage), Gdip_SetSmoothingMode(G, 4), Gdip_SetInterpolationMode(G, 7)

        XIndex := 0, YIndex := 0
        Loop, {
            ; Sleep,

            Loop, {
                ; Sleep,
                if (mapX >= mapEndX) {
                    XIndex := 0, mapX := mapStartX, mapXFileCoord := 0
                    break
                    ; msgbox, % "end X " files.MaxIndex() " files.`nXIndex: " XIndex ", YIndex: " YIndex "`nmapX: " mapX " mapY: " mapY "`n`n" serialize(files)
                }
                string := costFiles = false ? "Color" : "WaypointCost"

                minimapPNG := "Minimap_" string "_" mapX  "_" mapY  "_" mapZ ".png"
                /**
                */
                minimapPNG1 := "Minimap_" string "_" mapX  "_" mapY  "_" mapZ ".png"
                minimapPNG2 := "Minimap_" string "_" mapX + 256 "_" mapY  "_" mapZ ".png"

                minimapFilePath1 := minimapFolder "\" minimapPNG1
                minimapFilePath2 := minimapFolder "\" minimapPNG2

                if (!FileExist(minimapFilePath1)) {
                    minimapFilePath1 := costFiles = false ? this.minimapImagesFolder "\black.png" : this.minimapImagesFolder "\white.png"
                    ; XIndex := 0, mapX := mapStartX, mapXFileCoord := 0
                    ; break
                    ; throw Exception("File doesn't exist 1: " minimapPNG1 "`n`n" minimapFilePath1)
                }
                ; if (!FileExist(minimapFilePath2))
                ; msgbox, doesn't exist 2 %minimapFilePath2%


                pMinimapFile1 := Gdip_CreateBitmapFromFile(minimapFilePath1)
                pMinimapFile2 := Gdip_CreateBitmapFromFile(minimapFilePath2)

                Gdip_DrawImage(G, pMinimapFile1, mapXFileCoord, mapYFileCoord, 256, 256, 0, 0, 256, 256)
                Gdip_DrawImage(G, pMinimapFile2, mapXFileCoord + 256, mapYFileCoord, 256, 256, 0, 0, 256, 256)

                ;

                ; try
                ;     Gdip_SetBitmapToClipboard(pBitmapNewImage)
                ; catch
                ;     msgbox, 16,, generateTibiaMapFile.Gdip_SetBitmapToClipboard
                ; run, C:\Windows\system32\mspaint.exe
                ; Sleep, 500
                ; Send, ^v


                Gdip_DisposeImage(pMinimapFile1), Gdip_DisposeImage(pMinimapFile2)
                files.Push(minimapPNG)

                fileName := minimapFolder "\" minimapPNG
                XIndex++
                mapX += 256
                mapXFileCoord += 256

            }


            YIndex++
            mapY += 256
            mapYFileCoord += 256
            if (mapY > mapEndY)
                break
        }

        ; try
        ;     Gdip_SetBitmapToClipboard(pBitmapNewImage)
        ; catch
        ;     msgbox, 16,, generateTibiaMapFile.Gdip_SetBitmapToClipboard
        ; run, C:\Windows\system32\mspaint.exe
        ; Sleep, 500
        ; Send, ^v


        floorString := (StrLen(floor) = 1) ? "0" floor : floor

        string := costFiles = false ? "map" : "path"

        Gdip_SaveBitmapToFile(pBitmapNewImage, this.minimapImagesFolder "\floor-" floorString "-" string "-new.png")
        ; msgbox, % this.minimapImagesFolder "\floor-" floorString "-map.png"

        if (costFiles = false)
            this.convertToGray(this.minimapImagesFolder "\floor-" floorString "-map.png", this.minimapImagesFolder "\floor-" floorString "-map-gray-new.png")
        ; msgbox, % minimapPNG "x: " mapXFileCoord ", y: " mapYFileCoord "`n`n" pMinimapFile1 "`n" pMinimapFile2

        Gdip_DisposeImage(pBitmapNewImage),
        Gdip_DeleteGraphics(G)

        ; msgbox, % "floor: " floor " (" floorString ") " elapsed "ms, " files.MaxIndex() " files.`n`n" serialize(files)
    }

    /**

    */
    generateAllMapFiles(costFiles := False) {
        CarregandoGUI("Generating map files...")


        this.createBitmapFromTXT := false

        t1 := A_TickCount
        Loop, 16 {
            index := A_Index - 1
            ; floorString := (StrLen(index) = 1) ? "0" index : index

            this.generateTibiaMapFile(index, costFiles)
        }


        try this.renameNewCreatedMinimapFiles(worldChangeFiles := false, costFiles)
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 48, % A_ThisFunc, e.Message
            return
        }

        try this.renameNewCreatedMinimapFiles(worldChangeFiles := true, costFiles)
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 48, % A_ThisFunc, e.Message
            return
        }


        this.doneMessage(t1, A_ThisFunc)
    }


    drawMinimapFilesFromClientMinimapFolder() {
        t1 := A_TickCount

        try this.drawMinimapFromUserInterface(minimapFolder, "Color")
        catch e {
            Msgbox, 48, % A_ThisFunc, % e.Message "`n" e.What
            return
        }

        try this.drawMinimapFromUserInterface(minimapFolder, "Cost")
        catch e {
            Msgbox, 48, % A_ThisFunc, % e.Message "`n" e.What
            return
        }

        Gui, Carregando:Destroy
        ; this.doneMessage(t1, this.minimapFilesCount " minimap file(s).")
    }

    drawMinimapFilesFromCustomMinimapFolder() {
        t1 := A_TickCount

        try this.drawMinimapFromUserInterface(this.customMinimapFolder, "Color")
        catch e {
            Msgbox, 48, % A_ThisFunc, % e.Message "`n" e.What
            return
        }

        try this.drawMinimapFromUserInterface(this.customMinimapFolder, "Cost")
        catch e {
            Msgbox, 48, % A_ThisFunc, % e.Message "`n" e.What
            return
        }

        Gui, Carregando:Destroy
        ; this.doneMessage(t1, this.minimapFilesCount " minimap file(s).")
    }

    resetMinimapFilesToDefault() {
        t1 := A_TickCount

        /**
        Data\Files\Others\minimap is in this directory
        */
        this.resettingMap := true
        try this.drawMinimapFromUserInterface("Data\Files\Others\minimap", "Color")
        catch e {
            this.resettingMap := false
            Msgbox, 48, % A_ThisFunc, % e.Message "`n" e.What
            return
        }

        ; this.resetCostFiles := false
        ; if (this.resetCostFiles = true) {
        try this.drawMinimapFromUserInterface("Data\Files\Others\minimap", "Cost")
        catch e {
            this.resettingMap := false
            Msgbox, 48, % A_ThisFunc, % e.Message "`n" e.What
            return
        }
        ; }

        this.resettingMap := false
        Gui, Carregando:Destroy
        ; this.doneMessage(t1, this.minimapFilesCount " minimap file(s).")
    }

    drawMinimapFromUserInterface(folder, type) {
        worldChangeFiles := false


        ; CarregandoGUI("Working on files, please wait...")
        CarregandoGUI("Working on files, please wait...", , , , , , , show_bar := false)


        try this.createAllBitmapFloorsGraphic(type)
        catch e
            throw e

        costFiles := type = "Color" ? false : true

        try this.drawMinimapFilesFromFolder(folder, costFiles)
        catch e {
            this.deleteAllBitmapFloorsGraphic()
            throw e
        }


        this.createNewMinimapFiles(type, worldChangeFiles)
        Sleep, 50

        if (type = "Color") {
            this.convertAllToGrayFromMinimapBitmapToTXT(fromUpdateFunction := true)
            Sleep, 50
        }

        this.createTXTsFromUserInterface(type)

        this.deleteAllBitmapFloorsGraphic()

    }




    /**
    draw all the minimap image files from the Replace folder in the big tibia map image from tibiamaps.io
    */
    fixMinimapFiles(fromUpdateFunction := false, costFiles := false, worldChangeFiles := false) {
        if (A_IsCompiled)
            return

        ; waypointFile := this.getWaypointFileName(coordX, coordY, coordZ, "Color")
        ; FileCopy, %waypointFile%, __Files\__Minimap\, 1

        if (fromUpdateFunction = false)
            t1 := A_TickCount

        CarregandoGUI("Fixing minimap files...")

        try this.drawMinimapFilesFromFolder(this.minimapImagesFolder "\Replace" (worldChangeFiles = false ? "" : "\_worldChange"), costFiles)
        catch e {
            this.deleteAllBitmapFloorsGraphic()
            throw e
        }

        Sleep, 100

        this.createNewMinimapFiles(costFiles = true ? "Cost" : "Color", worldChangeFiles)

        this.deleteAllBitmapFloorsGraphic()

        Sleep, 100

        try this.renameNewCreatedMinimapFiles(worldChangeFiles, costFiles)
        catch e
            throw e

        Sleep, 100
        ; msgbox, saved gray files

        this.copyReplaceFilesToMinimapFolder()

        Sleep, 100
        this.createTXTs()
        if (fromUpdateFunction = false)
            this.doneMessage(t1, A_ThisFunc)
    }

    fixMinimapFilesOld(fromUpdateFunction := false, costFiles := false, worldChangeFiles := false) {
        if (A_IsCompiled)
            return

        ; waypointFile := this.getWaypointFileName(coordX, coordY, coordZ, "Color")
        ; FileCopy, %waypointFile%, __Files\__Minimap\, 1

        if (fromUpdateFunction = false)
            t1 := A_TickCount

        CarregandoGUI("Fixing minimap files...")


        try this.createAllBitmapFloorsGraphic(type := costFiles = false ? "Color" : "Cost")
        catch e
            throw e

        try this.drawMinimapFilesFromFolder(this.minimapImagesFolder "\Replace" (worldChangeFiles = false ? "" : "\_worldChange"), costFiles)
        catch e {
            this.deleteAllBitmapFloorsGraphic()
            throw e
        }

        Sleep, 100

        this.createNewMinimapFiles(type, worldChangeFiles)

        this.deleteAllBitmapFloorsGraphic()

        Sleep, 100

        try this.renameNewCreatedMinimapFiles(worldChangeFiles, costFiles)
        catch e
            throw e

        Sleep, 100
        ; msgbox, saved gray files

        this.copyReplaceFilesToMinimapFolder()

        Sleep, 100
        this.createTXTs()
        if (fromUpdateFunction = false)
            this.doneMessage(t1, A_ThisFunc)
    }

    createNewMinimapFiles(type, worldChangeFiles) {

        Loop, 16 {
            index := A_Index - 1, floorString := (StrLen(index) = 1) ? "0" index : index
            if (!this.pMinimapFloors[floorString])
                continue

            ; msgbox, % "Saving minimap file, floor: " floorString

            Gdip_SaveBitmapToFile(this.pMinimapFloors[floorString], this.newMinimapFileName(floorString, type, worldChangeFiles) )
        }

    }

    newMinimapFileName(floorString, type, worldChangeFiles) {
        folder := this.createBitmapFromTXT = true ? A_Temp "\OldBot" : this.minimapImagesFolder

        prefix := this.getFileTypePrefixName(type)
        worldChangeString := worldChangeFiles = false ? "" : "-wc"

        return folder "\floor-" floorString "-" prefix "" worldChangeString "-new.png"
    }

    /**
    remove the "*-new" string of the file names
    */
    renameNewCreatedMinimapFiles(worldChangeFiles, costFiles) {

        this.deleteAllBitmapFloorsGraphic()

        worldChangeString := worldChangeFiles = false ? "" : "-wc"
        Path := costFiles = false ? this.minimapImagesFolder "\*-map" worldChangeString "-new.png" : this.minimapImagesFolder "\*-path" worldChangeString "-new.png"
        Loop, % Path {
            ; floor-
            StringTrimLeft, string, A_LoopFileName, 6
            floorString := SubStr(string, 1, 2)

            newFileName := StrReplace(A_LoopFileName, "-new", "")
            src := this.minimapImagesFolder "\" A_LoopFileName, dest := this.minimapImagesFolder "\" newFileName
            try FileMove, % src, % dest, 1
            catch e
                throw Exception("Failed to move file.`nFrom: " src "`nTo: " dest "`n`nError: " e.Message " | " e.What)
            Sleep, 25
        }



        /**
        gray files
        DONT NEEDED
        */
        return
        Path := costFiles = false ? this.minimapImagesFolder "\*-map" worldChangeString "-gray-new.png" : this.minimapImagesFolder "\*-path" worldChangeString "-gray-new.png"
        Loop, % Path {
            ; floor-
            StringTrimLeft, string, A_LoopFileName, 6
            floorString := SubStr(string, 1, 2)

            newFileName := StrReplace(A_LoopFileName, "-new", "")
            try FileMove, % this.minimapImagesFolder "\" A_LoopFileName, % this.minimapImagesFolder "\" newFileName, 1
            catch e
                throw e
            Sleep, 25
        }

    }

    createAllBitmapFloorsGraphic(type) {
        this.G := {}
        Loop, 16 {
            index := A_Index - 1
            try this.createSingleBitmapFloorsGraphic(index, type)
            catch e
                throw e
        }
    }


    getFileTypePrefix(type) {
        switch type {
            case "Color": prefix := "m"
            case "Cost": prefix := "p"
            case "Gray": prefix := "m-g"
            default:
                throw Exception("Invalid minimap file type: " type)

        }
        return prefix
    }

    getFileTypePrefixName(type) {
        switch type {
            case "Color": prefix := "map"
            case "Cost": prefix := "path"
            case "Gray": prefix := "gray"
            default:
                throw Exception("Invalid minimap file type: " type)

        }
        return prefix
    }

    createSingleBitmapFloorsGraphic(floor, type, deletePrevious := false) {
        if (deletePrevious = true)
            this.deleteSingleBitmapFloorsGraphic(floor)

        floorString := (StrLen(floor) = 1) ? "0" floor : floor

        type := MinimapGUI.showGrayFiles = true ? "Gray" : type




        if (this.createBitmapFromTXT = true) {
            prefix := this.getFileTypePrefix(type)
            file := this.minimapTXTFilesFolder "\" floorString "-" prefix ".o"
            try this.createBitmapFromBase64File(file, floorString)
            catch e
                throw e

        } else {
            prefix := this.getFileTypePrefixName(type)
            minimapFile := this.minimapImagesFolder "\floor-" floorString "-" prefix ".png"

            this.pMinimapFloors[floorString] := Gdip_CreateBitmapFromFile(minimapFile)

        }
        if (this.pMinimapFloors[floorString] = "" OR this.pMinimapFloors[floorString] = 0)
            throw Exception("Empty bitmap floor: " floorString "`nFile:" minimapFile)
        ; Gdip_SetBitmapToClipboard(this.pMinimapFloors[floorString])
        ; msgbox,64, % A_ThisFunc, % "floorString " this.pMinimapFloors[floorString]
        this.G[floorString] := Gdip_GraphicsFromImage(this.pMinimapFloors[floorString]), Gdip_SetSmoothingMode(G, 4), Gdip_SetInterpolationMode(G, 7)
        ; msgbox, % A_ThisFunc "`n" floorString ": " this.G[floorString]

    }

    createBitmapFromBase64File(file, floorString) {
        if (!FileExist(file))
            throw Exception(file " doesn't exist.`n`n" A_ThisFunc)
        FileRead, base64, % file
        this.pMinimapFloors[floorString] := GdipCreateFromBase64(base64)
    }


    deleteSingleBitmapFloorsGraphic(floor) {
        floorString := (StrLen(floor) = 1) ? "0" floor : floor

        Gdip_DeleteGraphics(this.G[floorString])
        Gdip_DisposeImage(this.pMinimapFloors[floorString])
        this.pMinimapFloors[floorString] := ""
        this.G[floorString] := ""

    }

    deleteAllBitmapFloorsGraphic() {
        Loop, 16 {
            index := A_Index - 1
            this.deleteSingleBitmapFloorsGraphic(index)
        }
    }

    drawMinimapFileOnFloorFile(minimapFileName, minimapFilePath, costFiles) {

        if (costFiles = false) && (!InStr(minimapFileName, "Color"))
            return
        if (costFiles = true) && (!InStr(minimapFileName, "Cost"))
            return

        x := this.getCoordFromFile("x", minimapFileName)
        y := this.getCoordFromFile("y", minimapFileName)
        z := this.getCoordFromFile("z", minimapFileName)
        floorString := (StrLen(z) = 1) ? "0" z : z


        type := costFiles = false ? "Color" : "Cost"



        if (this.G[floorString] = "") {
            ; msgbox, % "Creating graphic, floor: " floorString "`n`n" serialize(this.G)

            this.createSingleBitmapFloorsGraphic(z, type := costFiles = false ? "Color" : "Cost", deletePrevious := false, createFromTXT := true)
            ; Gdip_SetBitmapToClipboard(this.pMinimapFloors[floorString])
            ; msgbox,, % A_ThisFunc, % " aaaaa Gdip_DrawImage(this.G[floorString])`n" floorString
        }
        if (this.G[floorString] = "")
            throw Exception("Empty graphic, floor: " floorString)

        ; msgbox, a %A_LoopFileFullPath%
        pBitmapFile := Gdip_CreateBitmapFromFile(minimapFilePath)
        ; Gdip_SetBitmapToClipboard(pBitmapFile)
        ; msgbox,, % A_ThisFunc, % "Gdip_SetBitmapToClipboard(pBitmapFile)`n" minimapFilePath

        coords := this.getWaypointFilePosition(x, y)
        mapXFileCoord := coords.x, mapYFileCoord := coords.y

        ; msgbox, % serialize(coords)



        W := 256,  H := 256
        try Gdip_DrawImage(this.G[floorString], pBitmapFile, mapXFileCoord, mapYFileCoord, W, H, 0, 0, W, H)
        catch e {
            throw e
        }
        ; Gdip_SetBitmapToClipboard(this.pMinimapFloors[floorString])
        ; msgbox,, % A_ThisFunc, % "Gdip_DrawImage(this.G[floorString])`n" floorString

        Gdip_DisposeImage(pBitmapFile)
        ; Sleep, 10
    }

    drawMinimapFilesFromFolder(minimapFilesFolder, costFiles) {

        this.renameFilesWithLowerCoordinates(minimapFilesFolder, costFiles)

        this.minimapFilesCount := 0
        Loop, % minimapFilesFolder "\*", 2,1
        {
            folder := A_LoopFileFullPath

            Loop, % folder "\*.png"
            {
                try this.drawMinimapFileOnFloorFile(A_LoopFileName, A_LoopFileFullPath, costFiles)
                catch e
                    throw e
                this.minimapFilesCount++
            }
        }

        Loop, % minimapFilesFolder "\*.png"
        {
            try this.drawMinimapFileOnFloorFile(A_LoopFileName, A_LoopFileFullPath, costFiles)
            catch e
                throw e
            this.minimapFilesCount++
        }
        ; msgbox, % A_ThisFunc " DONE"
    }

    renameFilesWithLowerCoordinates(minimapFilesFolder, costFiles) {

        if (ignoreWrongCoordinateMinimapFiles = true)
            return

        if (this.resettingMap = true)
            return

        ; msgbox, % A_ThisFunc "`n" minimapFilesFolder "`n" costFiles

        Loop, % minimapFilesFolder "\*.png" {

            if (costFiles = false) && (!InStr(A_LoopFileName, "Color"))
                continue
            if (costFiles = true) && (!InStr(A_LoopFileName, "Cost"))
                continue

            minimapFileName := A_LoopFileName
            minimapFilePath := A_LoopFileFullPath
            x := this.getCoordFromFile("x", minimapFileName)
            y := this.getCoordFromFile("y", minimapFileName)
            z := this.getCoordFromFile("z", minimapFileName)
            floorString := (StrLen(z) = 1) ? "0" z : z

            if (x < tibiaMapX1) {
                x += tibiaMapX1
                ; msgbox, % x " > " newX "`n" A_LoopFileFullPath
            }
            if (y < tibiaMapY1)
                y += tibiaMapY1

            newFileName := "Minimap_" (costFiles = false ? "Color" : "WaypointCost") "_" x "_" y "_" z ".png"
            ; clipboard := newFileName
            dest := minimapFilesFolder "\" newFileName
            ; msgbox, % "src`n" A_LoopFileFullPath "`n`ndest`n" dest
            try FileCopy, % A_LoopFileFullPath, % dest, 1
            catch {
            }
        }

    }

    copyReplaceFilesToMinimapFolder() {

        InfoCarregando("Copying new minimap files...")
        /**
        copy new minimap replace files to the minimap files foder(to update later)
        */
        Loop, % this.minimapImagesFolder "\Replace\*", 2,1
        {
            folder := A_LoopFileFullPath

            Loop, % folder "\*.png" {
                try FileCopy, % A_LoopFileFullPath, % "Data\Files\Others\minimap", 1
                catch e
                    throw e
            }
        }
    }

    /**
    rename all the map files with "-new" in their names to the original name
    */
    replaceNewMapFiles() {
        Path := this.minimapImagesFolder "\*-new.png"
        Loop, % Path {
            ; floor-
            StringTrimLeft, string, A_LoopFileName, 6

            floorString := SubStr(string, 1, 2)

            newFileName := StrReplace(A_LoopFileName, "-new", "")
            try FileMove, % this.minimapImagesFolder "\" A_LoopFileName, % this.minimapImagesFolder "\" newFileName, 1
            catch e
                throw e
            Sleep, 25
        }

    }


    getWaypointFilePosition(x, y) {
        return {x: x - tibiaMapX1, y: y - tibiaMapY1}
    }

    getWaypointFileStartPosition(waypointFile) {

        mapStartX := 31744
        mapStartY := 30976
        mapEndX := 34303
        mapEndY := 33023

        mapZ := floor = "" ? 7 : floor

        if (!pToken) {
            throw Exception("Gdip not initialized")
        }

        mapX := mapStartX
        mapY := mapStartY

        mapXFileCoord := 0
        mapYFileCoord := 0

        files := {}

        XIndex := 0, YIndex := 0
        Loop, {
            ; Sleep,

            Loop, {
                ; Sleep,
                if (mapX >= mapEndX) {
                    XIndex := 0, mapX := mapStartX, mapXFileCoord := 0
                    break
                    ; msgbox, % "end X " files.MaxIndex() " files.`nXIndex: " XIndex ", YIndex: " YIndex "`nmapX: " mapX " mapY: " mapY "`n`n" serialize(files)
                }

                minimapPNG := "Minimap_Color_" mapX  "_" mapY  "_" mapZ ".png"
                minimapPNG1 := "Minimap_Color_" mapX  "_" mapY  "_" mapZ ".png"
                minimapPNG2 := "Minimap_Color_" mapX + 256 "_" mapY  "_" mapZ ".png"
                Gdip_DrawImage(G, pMinimapFile1, mapXFileCoord, mapYFileCoord, 256, 256, 0, 0, 256, 256)

                minimapFilePath1 := minimapFolder "\" minimapPNG1
                minimapFilePath2 := minimapFolder "\" minimapPNG2

                files.Push(minimapPNG)

                fileName := minimapFolder "\" minimapPNG
                XIndex++
                mapX += 256
                mapXFileCoord += 256

            }

            YIndex++
            mapY += 256
            mapYFileCoord += 256
            if (mapY > mapEndY)
                break
        }


    }

    getCoordFromFile(coord, waypointFile := "Minimap_Color_32768_32000_10.png") {
        waypointFile := StrReplace(waypointFile, ".png", "")
        string := StrSplit(waypointFile, "_")

        switch coord {
            case "x": return string.3
            case "y": return string.4
            case "z": return string.5
            default: Msgbox, 48,, % "Invalid coord: " coord "`n" A_ThisFunc
        }
    }

    getWaypointFileName(coordX, coordY, coordZ, type := "Color") {
        /**
        Coordenadas da posição real do minimapa que deseja verificar se é caminhável(walkable) ou não
        */



        x_map := coordX
        y_map := coordY
        z := coordZ

        Path := minimapFolder "\*_" z ".png"
        Loop, %Path% {
            IfNotInString, A_LoopFileName, %type% ; se não for a imagem com pixels amarelos ignora
                continue

            x1_image := this.getCoordFromFile("x", A_LoopFileName), y1_image := this.getCoordFromFile("y", A_LoopFileName), x2_image := x1_image + 256, y2_image := y1_image + 256

            if (x_map >= x1_image) && (y_map >= y1_image) && (x_map <= x2_image) && (y_map <= y2_image) {
                yellow_image := A_LoopFileFullPath, yellow_image_short := A_LoopFileName
                try Clipboard := A_LoopFileName
                catch {
                }
                return A_LoopFileFullPath
            }else
                continue
        }
        throw Exception("Couldn't find the minimap file for the coordinates.`nX: " x_map "`nY: " y_map "`nZ: " z)

    }

    openWaypointFile(coordsObj := "", type := "Color", copy := false, open := true, folder := "", worldChange := false) {

        If (type != "Cost" && type != "Color") {
            Msgbox, Wrong file type: %type%
            return
        }

        if (!coordsObj)
            return

        try this.minimapFolderExists()
        catch e {
            Msgbox, 48,, % e.Message
            return
        }

        for key, coords in coordsObj
        {
            string := StrSplit(coords, ",")
            coordX := string.1
            coordY := string.2
            coordZ := string.3
            if (InStr(coordZ, ":")) {
                string := StrSplit(coordZ, ":")
                coordZ := string.1
            }

            try waypointFile := this.getWaypointFileName(coordX, coordY, coordZ, type)
            catch e {
                Msgbox,64,, % e.Message, 6
                return
            }
            if (copy = true) {
                ; folderDir := "__Files\__Minimap\Replace\" (worldChange = false ? "" : "_worldChange\")
                ; if (folder != "") {
                ;     folderDir .= folder
                ;     if (!FileExist(folderDir))
                ;         FileCreateDir, % folderDir
                ; }
                ; ; msgbox, % folderDir
                ; FileCopy, %waypointFile%, % folderDir, 1
            }

            if (open = true)
                Run,  %waypointFile%
            Sleep, 25
        }
    }

    openCoordinateMinimapFile(coordsObj := "", type := "Cost", open := true) {

        If (type != "Cost" && type != "Color")
            throw Exception("Wrong file type: " type)

        if (!coordsObj)
            throw Exception("Empty coords.")

        try this.minimapFolderExists()
        catch e
            throw e

        for key, coords in coordsObj
        {
            string := StrSplit(coords, ",")
            coordX := string.1
            coordY := string.2
            coordZ := string.3
            if (InStr(coordZ, ":")) {
                string := StrSplit(coordZ, ":")
                coordZ := string.1
            }

            try waypointFile := this.getWaypointFileName(coordX, coordY, coordZ, type)
            catch e {
                Msgbox,64,, % e.Message, 6
                return
            }

            if (open = true) {
                ; try Run,  %waypointFile%
                try Run, C:\Windows\system32\mspaint.exe %waypointFile%
                catch e {
                    Msgbox, 48,, % "Failed to open file:`n" waypointFile
                }
            }
            Sleep, 25
        }
    }

    fixMinimapFilesPixels(fromUpdateFunction := false) {

        if (fromUpdateFunction = false)
            t1 := A_TickCount
        mapFilePixels := {}
        pathFilePixels := {}
        Loop, 16 {
            index := A_Index - 1
            mapFilePixels[index] := {}
            pathFilePixels[index] := {}
        }


        /**
        kazordoon bless fire fields non walkable path
        */
        Loop, 10 {
            pathFilePixels[11][32630,31883 + A_Index] := "0xFF969696"
            pathFilePixels[11][32631,31883 + A_Index] := "0xFF969696"
        }
        Loop, 15 {
            pathFilePixels[11][32631 + A_Index,31892] := "0xFF969696"
            pathFilePixels[11][32631 + A_Index,31893] := "0xFF969696"
        }

        /**
        mintwallin route ancient temple poison fields
        */
        pathFilePixels[12][32492,32215] := "0xFFC8C8C8"
        pathFilePixels[12][32502,32218] := "0xFFC8C8C8"
        Loop, 9 {
            pathFilePixels[12][32491 + A_Index,32216] := "0xFFC8C8C8"
            pathFilePixels[12][32491 + A_Index,32217] := "0xFFC8C8C8"
        }
        Loop, 8
            pathFilePixels[12][32492 + A_Index,32218] := "0xFFC8C8C8"
        Loop, 3
            pathFilePixels[12][32496 + A_Index,32219] := "0xFFC8C8C8"


        ; msgbox,% serialize(pathFilePixels)


        for floor, coords in pathFilePixels
        {
            if (coords.Count() < 1)
                continue

            ; msgbox, % floor " / " serialize(coords) " / " coords
            pixelsChanged := 0
            for x, coordsY in coords
            {
                ; msgbox, % x " / " serialize(coordsY) " / "  coordsY.Count()
                for key, value in coordsY
                {
                    y := key
                    pixcolor := value
                    ; msgbox, % x - tibiaMapX1 "," y - tibiaMapY1
                    try Gdip_SetPixel(pBitmapPathFloor%floorString%, x - tibiaMapX1, y - tibiaMapY1, pixcolor)
                    catch e {
                        msgbox, 16,, % e.Message " | " e.What
                    }

                }

                pixelsChanged++

            }
            if (pixelsChanged = 0)
                continue
            ; try
            ;     Gdip_SetBitmapToClipboard(pBitmapPathFloor%floorString%)
            ; catch
            ;     msgbox, 16,, generateTibiaMapFile.Gdip_SetBitmapToClipboard
            ; run, C:\Windows\system32\mspaint.exe
            ; Sleep, 500
            ; Send, ^v

            ; newMinimapFile := this.minimapImagesFolder "\floor-" floorString "-path-oldbot.png"
            newMinimapFile := this.minimapImagesFolder "\floor-" floorString "-path.png"
            Gdip_SaveBitmapToFile(pBitmapPathFloor%floorString%, newMinimapFile)
            Sleep, 25
            ; this.convertToGray(newMinimapFile, this.minimapImagesFolder "\floor-" floorString "-path-gray-oldbot.png")
        }

        if (fromUpdateFunction = false)
            this.doneMessage(t1, A_ThisFunc)

    }

    checkMinimapUpdate() {
        StringTrimRight, Now, A_Now, 6

        IniRead, LastMinimapUpdate, %A_Temp%\OldBot\oldbot.ini, settings, LastMinimapUpdate, %A_Space%

        DaysSinceLastMinimapUpdate := abs(LastMinimapUpdate - Now)
        ; DaysSinceLastMinimapUpdate := 1 ; dont do auto update for now

        if (DaysSinceLastMinimapUpdate > 5 OR LastMinimapUpdate = "") {
            ; if (DaysSinceLastMinimapUpdate = "") {
            try
                this.minimapFolderExists()
            catch
                return

            if (TibiaClient.isClientOpened() = true) {
                Gui, Carregando:Destroy
                Msgbox, 48,, Tibia client is OPENED, please close it to proceed with the auto Minimap Update.
                CarregandoGUI("Please close the Tibia Client...", 170, 170)
                While (TibiaClient.isClientOpened() = true) {
                    Sleep, 50
                }
            }


            CarregandoGUI("Updating minimap, please wait...", 170, 170)
            Sleep, 100
            try this.replaceTibiaMinimapFiles()
            catch {
                return
            }
        }

    }

    replaceTibiaMinimapFiles(fromUpdateFunction := false, closeClient := false) {
        this.minimapFolderExists()
        if (minimapFolder = "")
            return
        CarregandoGUI("Replacing minimap files...")
        t1 := A_TickCount
        Sleep, 100

        try FileDelete, % minimapFolder
        catch {
        }

        Sleep, 1000

        try FileCopyDir, % "Data\Files\Others\minimap", % minimapFolder, 1
        catch e {
            throw e
        }
        Sleep, 100
        StringTrimRight, Now, A_Now, 6
        IniWrite, %Now%, %A_Temp%\OldBot\oldbot.ini, settings, LastMinimapUpdate
        if (fromUpdateFunction = false)
            this.doneMessage(t1, "")
    }
}