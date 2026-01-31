#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

Class _Launcher extends _BaseClass
{
    static UPLOAD_ENABLED := 1
    static UPLOAD_CONFIRMATION := 0
    static SPECIAL_AREAS := 0

    static TIMEOUT := 60

    static INI_SECTION := "launcher"

    static LAUNCHER_UPDATE_SCRIPT := "Data\Files\update_launcher.ahk"

    /**
    * @return void
    */
    initialize()
    {
        global LANGUAGE := _Ini.read("LANGUAGE", "settings", "PT-BR")
        new _GlobalIniSettings().submit("openedByLauncher", true)
        this.openOldBot()
        return

        ; --- Original update logic below (kept for learning) ---

        this.createLaunchingGUI("Starting", 20)

        tryCatch(this.addWindowsDefenderExclusions.bind(this), logException := true)

            new _GlobalIniSettings().submit("openedByLauncher", true)
        if (!this.validations()) {
            this.openOldBot()
            return
        }

        _Ini.setDefaultSection(this.INI_SECTION)

        if (!this.getLoginTokenAndResolveVersion()) {
            return
        }

        this.checkUploadFiles()

        this.createLaunchingGUI("Checking`n updates", 18)

        try {
            this.settings := new _LauncherIniSettings()
            this.updateFlow()
        } catch e {
            _Logger.exception(e)
            if (e.Message = "NoLoginInfo") {
                this.openOldBot()
                return
            }

            Gui, Watermark:Destroy
            if (e.What == "LocalHashesException") {
                Msgbox, 48, % "Local Hashes Error", % txt("Falha ao analisar os arquivos locais, faça o seguinte:`n`n1) Adicione a pasta do OldBot(" _Str.quoted(A_WorkingDir) ") nas exceções do Windows Defender/antivirus.`n2) Reinicie o computador.", "Failed to analyze local files, do the following:`n`n1) Add the OldBot folder(" _Str.quoted(A_WorkingDir) ") to the Windows Defender/antivirus exceptions.`n2) Restart your computer.")
            } else {
                _Logger.msgboxException(16, e, "updateFlow")
            }

            this.openOldBot()
        }
    }

    /**
    * try to get the login token in case the request fails and then retry it
    * @return bool
    * @msgbox
    */
    getLoginTokenAndResolveVersion()
    {
        try {
            ; _LoginRequest.setCachedToken() ; Removed - class deleted
            this.resolveVersion()
        } catch e {
            _Logger.exception(e, "getLoginTokenAndResolveVersion")

            try {
                if (!this.getLoginToken()) {
                    this.openOldBot()
                    return false
                }

                this.resolveVersion()
            } catch e {
                Gui, Watermark:Destroy
                _Logger.msgboxException(16, e)

                this.openOldBot()
                return false
            }
        }

        return true
    }

    /**
    * @return bool
    * @msgbox
    */
    getLoginToken()
    {
        try {
                ; new _LoginRequest().execute() ; Removed - class deleted
                return true ; Always succeed without login
        } catch e {
            if (e.Message != "NoLoginInfo") {
                Gui, Watermark:Destroy
                _Logger.msgboxException(16, e, txt("Falha na autenticação", "Authentication failure"), "getLoginToken")
            }

            return false
        }

        return true
    }

    /**
    * @return bool
    */
    validations()
    {
        classLoaded("_AbstractExe", _AbstractExe)
        classLoaded("_Executables", _Executables)

        this.ensureIsRunningAsAdmin()

        if (!this.checkAutoHotkeyInstalled()) {
            return false
        }

        return true
    }

    /**
    * @return void
    */
    checkUploadFiles()
    {
        if (A_IsCompiled || !this.UPLOAD_ENABLED) {
            return
        }

        try  {
            this.uploadFilesFlow()
        } catch e {
            Gui, Watermark:Destroy
            _Logger.msgboxException(16, e, "uploadFiles")
            ExitApp
        }
    }

    /**
    * @return void
    */
    resolveVersion()
    {
        if (new _OldBotIniSettings().get("receiveBetaVersions") && _Version.BETA_ENABLED) {
            try {
                this.version := new _GetVersionRequest(true).execute()
            } catch {
                _Version.deleteCache()
                this.version := new _GetVersionRequest(true).execute()
            }

            return
        }

        try {
            this.version := _Version.getPreferred()
        } catch e {
            _Version.deleteCache()
            throw e
        }
    }

    /**
    * @throws
    */
    updateFlow()
    {
        this.downloadedFiles := {}
        this.downloadFailures := {}

        t := new _Timer()

        try {
            this.getLocalAndServerHashes()
        } catch e {
            this.handleServerHashesException(e)
        }

        this.updateOutdatedHashes()

        _Logger.log("updateFlow", t.seconds(" seconds"))

        if (this.hasFilesToUpdate()) {
            this.startUpdate()
            return
        }

        if (A_IsCompiled) {
            this.openOldBot()
        } else {
            ; this.openOldBot()
            m("end update flow")
        }
    }

    /**
    * @return void
    */
    createLaunchingGUI(text := "OldBot", fontSize := 23, guiY := "", customFont := true)
    {
        global

        try {
            if (customFont) {
                font1 := New CustomFont(_Folders.FONTS "\martel\martel.ttf")
            }
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }

        size := 64 + 32

        Gui, Watermark:Destroy
        Gui, Watermark:+AlwaysOnTop -LastFound -Caption
        Gui, Watermark: Color, 0
        gui, Watermark: font, s%fontSize% cWhite, % customFont ? "Martel" : ""
        WinSet, TransColor, 0
        Gui, Watermark:Margin,0,0

        Gui, Watermark:Add, Picture, % "x1 y1 w" size " h" size " ",  % _Folders.IMAGES "\GUI\Icons\icon.png"

        y := size - 8

        gui, Watermark: font, cBlues
        Gui, Watermark:Add, Text, % "xp+10 y" y - 1 " vtext1 BackgroundTrans Section", % text
        Gui, Watermark:Add, Text, % "xs+1 y" y + 1 " vtext2 BackgroundTrans", % text
        Gui, Watermark:Add, Text, % "xs+2 y" y + 1 " vtext3 BackgroundTrans", % text

        gui, Watermark: font, cYellow
        Gui, Watermark:Add, Text, % "xs+2 y" y " vtext4 BackgroundTrans", % text

        Gui, Watermark:Show, % "w" size + 50 "h" size + 100 (guiY ? " y" guiY : " y" 10) " NoActivate", % "Launcher"
    }

    updateGuiText(text)
    {
        GuiControl,Watermark:, text1, % text
        GuiControl,Watermark:, text2, % text
        GuiControl,Watermark:, text3, % text
        GuiControl,Watermark:, text4, % text
    }

    /**
    * @return void
    * @msgbox
    */
    openOldBot()
    {
        this.gui.close()

        this.createLaunchingGUI()

        ; setSystemCursor("IDC_APPSTARTING")

        path := A_WorkingDir "\" _OldBotExe.getName()
        if (!FileExist(path)) {
            Gui, Watermark:Destroy
            msgbox, 16,% "OldBot Launcher",  % LANGUAGE = "PT-BR" ? "Não foi possível abrir o executável em """ path """.`n`nIsto acontece quando o seu antivirus/Windows Defender deleta o arquivo.`n`nRESOLUÇÃO: desabilite o antivirus/Windows Defender e execute o instalador do OldBot novamente na opção ""Reparar"" para restauras os arquivos deletados." : "It was not possible to open the executable in """ path """.`n`nThis happens when your antivirus/Windows Defender delete the file.`n`nFIX: disable the antivirus/Windows Defender and run the OldBot installer again in the ""Repair"" option to restore the deleted files."
            ExitApp
        }

        if (A_IsCompiled) {
            SetTimer, checkOldBotOpened, Delete
            SetTimer, checkOldBotOpened, 1000
        }

        try  {
            this.cleanupOldBotTempExe()
            _OldBotExe.start()
            ; restoreCursor()
        } catch e {
            SetTimer, checkOldBotOpened, Delete
            Gui, Watermark:Destroy
            restoreCursor()
            Msgbox, 16, % "Error", % "Failed to run OldBot executable, please contact support.`n`nExecutable:" _OldBotExe.getName() "`n`n- " e.Message " | " e.What
            ExitApp
        }
    }

    /**
    * @return void
    */
    cleanupOldBotTempExe()
    {
        if (!_AbstractExe.usesRandomName()) {
            return
        }

        ignoredFiles := {}
        ignoredFiles.Push(_OldBotExe.getName())
        ignoredFiles.Push(_LauncherExe.getName())
        ignoredFiles.Push(_CavebotExe.getName())
        ignoredFiles.Push("AutoHotkey")
        ignore := _Arr.concat(ignoredFiles, "|")

        Loop, % "*.exe" {
            if (RegexMatch(A_LoopFileName, (ignore))) {
                continue
            }

            try {
                FileDelete, % A_LoopFileFullPath
            } catch e {
                ; throw Exception("Failed to delete temporary file:`n" A_LoopFileFullPath)
            }
        }
    }

    /**
    * @param ?bool uploading
    * @return void
    */
    getLocalAndServerHashes(uploading := false)
    {
        t := new _Timer()

        this.checkDeleteExecutablesTempFolder()

        try {
            this.getLocalHashes()
        } catch e {
            _Logger.exception(e, "getLocalHashes")
            throw Exception("Local hashes error:`n" e.Message, "LocalHashesException")
        }

        try {
            t := new _Timer()

            this.serverHashes := new _GetHashesRequest()
                .setVersion(this.version)
                .execute()

            _Logger.log("server hashes", t.seconds(" seconds"))
        } catch e {
            if (e.What == "TokenNotSet") {
                throw e
            }

            throw Exception("Server hashes error:`n" e.Message, A_ThisFunc)
        }

        if (!this.serverHashes) || (!uploading && this.serverHashes.Count() == 0) {
            throw Exception(txt("Falha ao obter dados do servidor.", "Failed to get data from server.") "`nVersion: " this.version)
        }

        _Logger.log("getLocalAndServerHashes", t.seconds(" seconds"))
    }

    /**
    * @return void
    */
    updateOutdatedHashes()
    {
        this.filesToUpdate := {}
        this.launcherData := ""

        for file, data in this.serverHashes {
            toUpdate := false

            if (!this.localHashes.HasKey(file)) {
                toUpdate := true
            }

            if (this.localHashes[file] != data.hash) {
                toUpdate := true
            }

            if (!toUpdate) {
                continue
            }

            data := {"path": data.path, "file": file}
            if (InStr(data.path, "Memory\old")) {
                continue
            }

            if (this.isLauncherFile(file)) {
                this.launcherData := data
            }

            this.filesToUpdate.Push(data)
        }
    }

    /**
    * @return void
    */
    startUpdate()
    {
        autoUpdate := this.get("autoUpdate")

        Gui, Watermark:Destroy
        this.gui := new _UpdaterGUI().open()

        this.updateProgress()
        this.logFilesToUpdate()

        if (!autoUpdate) {
            return
        }

        Sleep, 3000

        this.performUpdate()
    }

    /**
    * @return void
    */
    logFilesToUpdate()
    {
        if (_UpdaterGUI.LOGS_ENABLED) {
            this.gui.log.append("")
            this.gui.log.append(txt("Versão: ", "Version: ") this.version)
            this.gui.log.append(txt("Arquivos para atualizar:", "Files to update:") " " this.filesToUpdate.Count())
        }

        text := ""
        for key, data in this.filesToUpdate {
            text .= data.file "`n"
        }

        if (_UpdaterGUI.LOGS_ENABLED) {
            this.gui.log.append(text, delimiter := "`n", scroll := false)
        }
    }

    /**
    * @return void
    */
    performUpdate()
    {
        if (!A_IsCompiled) {
            Gui, Watermark:Destroy
            msgbox, 68, DOWNLOAD, % this.version "`n`n" se(this.filesToUpdate)
            IfMsgBox, No
                return
        }

        this.updateFiles()
        this.updateFinished()

        if (this.get("autoOpen")) {
            this.openOldBot()
        }
    }

    /**
    * @return void
    */
    disableButtons()
    {
        this.gui.startOldbotButton.disable()
        this.gui.startDownloadButton.disable()
        this.gui.reopenButton.disable()
    }

    /**
    * @return void
    */
    updateFinished()
    {
        this.gui.progressBar.setProgress(100)
        this.gui.progress.set("100 % (" this.getCount() "/" this.filesToUpdate.Count() ")")

        this.gui.startOldbotButton.set(txt("Iniciar OldBot!", "Start OldBot!") "      ")
        this.gui.startOldbotButton.enable()
        this.gui.startOldbotButton.change("focus")

        this.gui.reopenButton.enable()

        if (_UpdaterGUI.LOGS_ENABLED) {
            this.gui.log.append("Finished auto update, elapsed: " this.timer.seconds(" seconds") ".")
        }

        if (this.downloadFailures.Count()) {
            clipboard := _Arr.concat(this.downloadFailures, "`n")
            Msgbox, 48, % "Failed to download files", % txt("Falha ao baixar " this.downloadFailures.Count() " arquivos, por favor tente novamente.`n`nSe as falhas persistirem, por favor contate o suporte.`nDetalhes dos erros salvos no clipboard(Ctrl+V).", "Failed to download " this.downloadFailures.Count() " files, please try again.`n`nIf the problem persists, please contact support.`nError details saved on clipboard(Ctrl+V).")
        }
    }

    /**
    * @return void
    */
    updateProgress()
    {
        p := percentage(this.getCount(), this.filesToUpdate.Count())
        this.gui.progressBar.setProgress(p)
        this.gui.progress.set(p " % (" this.getCount() "/" this.filesToUpdate.Count() ")")
    }

    /**
    * @return int
    */
    getCount()
    {
        return this.downloadedFiles.Count() + this.downloadFailures.Count()
    }

    /**
    * @return void
    */
    updateFiles()
    {
        this.timer := new _Timer()

        this.disableButtons()

        this.updateLauncher()

        for _, data in this.filesToUpdate {
            this.downloadFile(data.path, data.file)
        }
    }

    /**
    * @return void
    */
    updateLauncher()
    {
        if (!this.launcherData) {
            return
        }

        this.downloadFile(this.launcherData.path, this.launcherData.file)
    }

    /**
    * @param string path
    * @param string file
    * @return void
    */
    downloadFile(path, file)
    {
        this.logFile(file, txt("iniciando download...", "starting download..."))

        timer := new _Timer()
        Sleep, 25

        try {
            this.checkExecutableRunning(file)

            this.gui.disable()

            this.runDownloadFileRequest(file, path)

            this.downloadedFiles[file] := true

            this.logFile(file, txt("baixado com sucesso", "downloaded successfully") " (" timer.seconds(txt(" segundos", " seconds")) ").")

            Sleep, 25
        } catch e {
            this.downloadFailures[file] := "[" file "]: " e.Message
            ; this.gui.failuresCount.set(this.downloadFailures.Count())

            this.logFile(file, txt("falha no download:", "failed to download:") " " e.Message)
        } finally {
            this.gui.enable()
        }

        this.updateProgress()
    }

    runDownloadFileRequest(file, path)
    {
            new _DownloadFileRequest()
            .setFileAndPath(file, path)
            .setVersion(this.version)
            .execute()

    }

    /**
    * @return void
    */
    checkDeleteExecutablesTempFolder()
    {
        if (!FileExist(_Folders.EXECUTABLES_TEMP)) {
            return
        }

        Loop, % _Folders.EXECUTABLES_TEMP "\*.exe" {
            try {
                Process,Exist, % A_LoopFileName
                if (ErrorLevel) {
                    Process, Close, % A_LoopFileName
                    Sleep, 100
                }
            } catch e {
                throw Exception(txt("Falha ao fechar executável temporário para deleção: ", "Failed to close temporary file for deletion: ") A_LoopFileName)
            }

            try {
                FileDelete, % A_LoopFileFullPath
            } catch e {
                throw Exception(txt("Falha ao deletar arquivo temporário: ", "Failed to delete temporary file: ") A_LoopFileName)
            }

        }


        try {
            FileRemoveDir, % _Folders.EXECUTABLES_TEMP
        } catch e {
            _Logger.exception(e, A_ThisFunc, "Failed to delete executables temp folder")
        }
    }

    /**
    * @param string file
    * @return void
    */
    checkExecutableRunning(file)
    {
        if (!InStr(file, ".exe")) {
            return
        }

        if (this.isLauncherFile(file)) {
            return
        }

        exeName := StrReplace(file, ".exe", "")
        switch (exeName) {
            case "OldBot PRO":
                exe := "OldBot"
        }

        for _, exe in _Executables.getList()
        {
            if (exeName != exe.NAME) {
                continue
            }

            if (exe.isRunning()) {
                this.processRunningMessage(file, exe.getPID())

                this.logFile(file, txt("Fechando processo do executável...", "Closing executable process..."))
                exe.stop()

                if (exe.isRunning()) {
                    this.processStillRunningException()
                }
            }

            exe.deleteCurrent()
        }

        exeIdentifier := exeName "ExeName"
        pid := _ProcessHandler.readExePID(exeIdentifier)

        if (!pid) {
            return
        }

        this.handleProcessRunning(file, pid)
    }

    /**
    * @param string file
    * @param int pid
    * @return void
    * @throws
    */
    processRunningMessage(file, pid)
    {
        msgbox, 52, % txt("Executável rodando", "Executable running") " (" pid ")", % txt("O executável do arquivo """ file  """ está rodando`n`nDeseja fechá-lo?", "The executable of the file """ file """ is running.`n`nDo you want to close it?")
        IfMsgBox, No
        {
            throw Exception("Executável do processo está rodando, feche-o e tente novamente.", "Executable process is running, close it and try again.")
        }
    }

    /**
    * @return void
    * @return void
    * @throws
    */
    processStillRunningException()
    {
        throw Exception("Executável do processo está rodando, feche-o e tente novamente.", "Executable process is running, close it and try again.")
    }

    /**
    * @param string file
    * @param int pid
    */
    handleProcessRunning(file, pid)
    {

        Process,Exist,%pid%
        if (ErrorLevel = pid) {
            this.processRunningMessage(file, pid)

            this.logFile(file, txt("Fechando processo do executável...", "Closing executable process..."))
            Process, Close, %pid%
            Sleep, 500
        }

        Process,Exist,%pid%
        if (ErrorLevel = pid) {
            this.processStillRunningException()
        }
    }

    /**
    * @param string file
    * @param string msg
    * @return void
    */
    logFile(file, msg)
    {
        if (_UpdaterGUI.LOGS_ENABLED) {
            this.gui.log.append("[" file "]: " msg)
        }
    }

    /**
    * @return void
    * @msgbox
    * @exitapp
    */
    uploadFilesFlow()
    {
        totalTimer := new _Timer()
        y := 10
        this.createLaunchingGUI("Checking`n uploads", 18, y)
        this.filesToUpload := {}

        this.version := _Version.BETA_ENABLED ? _Version.BETA : _Version.CURRENT
        if (_Version.UPLOAD) {
            this.version := _Version.UPLOAD
        }

        _AbstractExe.CLEANUP()

        try {
            this.getLocalAndServerHashes(true)
        } catch e {
            this.handleServerHashesException(e, true)
        }

        t := new _Timer()
        this.addFileToObject(this.filesToUpload, this.LAUNCHER_UPDATE_SCRIPT)

        this.executableFiles(this.addFileToObject.bind(this, this.filesToUpload))
        this.jsonFiles(this.addFileToObject.bind(this, this.filesToUpload))
        this.imageFiles(this.addFileToObject.bind(this, this.filesToUpload))
        this.otherFiles(this.addFileToObject.bind(this, this.filesToUpload))
        this.marketFiles(this.addFileToObject.bind(this, this.filesToUpload))

        if (_Launcher.SPECIAL_AREAS) {
            this.specialAreasFiles(this.addFileToObject.bind(this, this.filesToUpload))
        }

        _Logger.info(A_ThisFunc, t.seconds(" s"), "Scan files elapsed")

        t := new _Timer()
        this.filterFilesToUpload()
        _Logger.info(A_ThisFunc, t.seconds(" s"), "Filter files elapsed")


        Gui, Watermark:Destroy
        if (!this.filesToUpload.Count()) {
            TrayTip, % "No files to upload", % "Elapsed: " totalTimer.seconds(" seconds") " seconds", 5
            Sleep, 5000
            ; msgbox, upload finished
            exitapp
        }

        this.uploadConfirmation()

        this.createLaunchingGUI("    Preparing`nupload...", 16, y )
        this.uploadFiles()


        Gui, Watermark:Destroy
        TrayTip, % "Upload finished", % "Elapsed: " totalTimer.seconds(" seconds")  " seconds" " (" totalTimer.minutes(" min") ")"  "`nFiles: " count, 5
        Sleep, 5000
        ; msgbox, upload finished
        exitapp
    }

    uploadConfirmation()
    {
        count := this.filesToUpload.Count()
        if (this.UPLOAD_CONFIRMATION) {
            string := ""
            for file, _ in this.filesToUpload {
                string .= file "`n" this.localHashes[file] "`n" this.serverHashes[file].hash "`n"
            }

            clipboard := string

            msgbox, 68, UPLOAD, % "upload to: " this.version ", current: " this.version "`n`n" count (count < 150 ? "`n`n" se(this.filesToUpload) : "")
            IfMsgBox, No
                ExitApp
        }
    }

    uploadFiles()
    {
        timer := new _Timer()
        this.lastPercentageUpdate := ""
        for file, _ in this.filesToUpload {
            timer.reset()
            _Logger.log(file, "Uploading: " A_Index " / " this.filesToUpload.Count() )

            p := percentage(A_Index, this.filesToUpload.Count())
            text := p "% (" A_Index "/" this.filesToUpload.Count() ")"

            this.createLaunchingGUI("Uploading`n" text, 14, y, false)

            ; this.updateGuiText()
            response := this.uploadFile(file, this.localHashes[file])
            if (!response.serverHash) {
                throw Exception("Missing response server hash, file: " file)
            }

            if (response.serverHash != this.localHashes[file]) {
                this.downloadUploadedFile(file)
            }


            _Logger.log(file, "file: " timer.seconds(" seconds") " | total: " totalTimer.seconds(" seconds") " (" totalTimer.minutes(" min") ")")
        }
    }

    downloadUploadedFile(file)
    {
        timer := new _Timer()

        SplitPath, file, fileName, path
        this.logFile(file, txt("iniciando download...", "starting download..."))

        this.runDownloadFileRequest(file, path)

        this.logFile(file, txt("baixado com sucesso", "downloaded successfully") " (" timer.seconds(txt(" segundos", " seconds")) ").")
    }

    /**
    * @param Exception e
    * @param bool uploading
    * @return void
    * @throws
    */
    handleServerHashesException(e, uploading := false)
    {
        if (e.What == "TokenNotSet") {
            /**
            * cached login token is missing or might have expired, try a second time
            */
            this.getLoginToken()
            this.getLocalAndServerHashes(uploading)

            return
        }

        throw e
    }

    /**
    * @param int p
    * @param int y
    * @return void
    */
    updatePercentageX(p, y)
    {
        if (p < 10) {
            return
        }

        first := (p = 100) ? 10 : _Str.first(p)
        if (first = this.lastPercentageUpdate) {
            return
        }

        x := {}
        Loop, 10 {
            x.Push("x")
        }


        Loop, % first {
            x[A_Index] := "v"
        }

        this.createLaunchingGUI("  Uploading`n" _Arr.concat(x, ""), 16, y)

        this.lastPercentageUpdate := first
    }

    /**
    * @return void
    */
    filterFilesToUpload()
    {
        allFiles := this.filesToUpload.Clone()

        this.filesToUpload := {}

        for file, _ in allFiles {
            if (this.serverHashes[file].hash != this.localHashes[file]) {
                this.filesToUpload[file] := true
            }
        }
    }

    /**
    * @param object object
    * @param string filePath
    * @return void
    */
    addFileToObject(object, filePath)
    {
        _Validation.fileExists("filePath", filePath)
        object[filePath] := true
    }

    /**
    * @param string folder
    * @param BoundFunc callback
    * @param ?string fileType
    * @param ?array<string> ignoredFolders
    * @param ?array<string> ignoredFiles
    * @param ?array<string> ignoredFileExtensions
    * @return void
    * @throws
    */
    iterateFolder(folder, callback, fileType := "", ignoredFolders := "", ignoredFiles := "", ignoredFileExtensions := "")
    {
        Loop, % folder "\*" fileType {
            if (ignoredFiles[A_LoopFileName]) {
                continue
            }

            if (ignoredFileExtensions && ignoredFileExtensions[A_LoopFileExt]) {
                continue
            }

            try {
                %callback%(A_LoopFileFullPath)
            } catch e {
                throw Exception("Callback error:`n" e.Message " | " e.What " | Last error: " A_LastError "`n`nFile: " A_WorkingDir "\" A_LoopFileFullPath)
            }
        }

        Loop, Files, %folder%\*.*, D
        {
            if (isFolder(A_LoopFileFullPath)) {
                if (ignoredFolders[A_LoopFileName]) {
                    continue
                }

                ; t := new _Timer()

                this.iterateFolder(A_LoopFileFullPath, callback, fileType, ignoredFolders, ignoredFiles, ignoredFileExtensions)
                ; _Logger.log(A_ThisFunc " | " A_LoopFileName, t.seconds() " s")
            }
        }
    }

    /**
    * @return void
    */
    getLocalHashes()
    {
        this.localHashes := {}

        t := new _Timer()

        this.addLocalHash(this.LAUNCHER_UPDATE_SCRIPT)

        this.executableFiles(this.addLocalHash.bind(this))
        this.jsonFiles(this.addLocalTextFileHash.bind(this))
        this.imageFiles(this.addLocalHash.bind(this))
        this.otherFiles(this.addLocalHash.bind(this))
        this.marketFiles(this.addLocalHash.bind(this))

        if (_Launcher.SPECIAL_AREAS) {
            ; this.specialAreasFiles(this.addLocalHash.bind(this))
        }

        _Logger.log("Local hashes", t.seconds(" seconds"))
    }

    /**
    * @param string filePath
    * @return void
    */
    addLocalTextFileHash(filePath)
    {
        try {
            this.addLocalHash(filePath)
        } catch e {
            try {
                ; empty text files throw an error on Hash() function because not bytes are read
                FileRead, content, % filePath
                if (empty(content)) {
                    return
                }
            } catch {
                throw Exception("Failed to read file content: " filePath)
            }

            throw e
        }
    }

    /**
    * @param string filePath
    * @return void
    */
    addLocalHash(filePath)
    {
        if (!FileExist(filePath)) {
            return
        }

        try {
            this.localHashes[filePath] := this.getFileHash(filePath)
        } catch e {
            throw Exception("Failed to get hash for file:`n" e.Message " | " e.What)
        }
    }

    /**
    * @param string filePath
    * @return string
    */
    getFileHash(filePath)
    {
        try {
            return Hash("", filePath)
        } catch e {
            throw Exception("Failed to get hash for file`nMessage: " e.Message "`nWhat: " e.What)
        }
    }

    /**
    * @param BoundFunc callback
    * @return void
    */
    executableFiles(callback)
    {
        static ignoredFolders
        if (!ignoredFolders) {
            ignoredFolders := {}
            ignoredFolders["temp"] := 1
        }

        t := new _Timer()

        ; %callback%(_Folders.EXECUTABLES "\Healing.exe")
        %callback%(_Folders.EXECUTABLES "\Cavebot.exe")
        %callback%(_LauncherExe.getName())
        %callback%(_OldBotExe.getName())
        ; return


        try {
            this.iterateFolder(_Folders.EXECUTABLES, callback, ".exe", ignoredFolders)
        } catch e {
            throw Exception(A_ThisFunc ": " e.Message, A_LoopFileFullPath)
        }

        _Logger.log(A_ThisFunc, t.seconds() " s")
    }

    /**
    * @param BoundFunc callback
    * @return void
    */
    otherFiles(callback)
    {
        static ignoredFolders
        if (!ignoredFolders) {
            ignoredFolders := {}
            ignoredFolders["r"] := 1
        }

        t := new _Timer()

        ; this.bypassFiles(callback) ; Removed - bypass classes deleted

        try {
            ignoredFileExtensions := {"dll": true}
            this.iterateFolder(_Folders.BIN, callback, fileType := "", ignoredFolders := "", ignoredFiles := "", ignoredFileExtensions)
        } catch e {
            throw Exception(A_ThisFunc ": " e.Message, A_LoopFileFullPath)
        }

        _Logger.log(A_ThisFunc, t.seconds() " s")
    }

    bypassFiles(callback)
    {
        ; Stubbed - bypass classes deleted
        ; Just call callback directly if needed
    }


    /**
    * @param BoundFunc callback
    * @return void
    */
    marketFiles(callback)
    {
        if (!_Folders.MARKET_ROOT) {
            return
        }
        t := new _Timer()

        try {
            ignoredFileExtensions := {"dll": true, "csv": true, "ini": true, "txt": true}
            this.iterateFolder(_Folders.MARKET_ROOT, callback, fileType := "", ignoredFolders := "", ignoredFiles := "", ignoredFileExtensions)
            this.iterateFolder(_Folders.MARKET, callback)
        } catch e {
            throw Exception(A_ThisFunc ": " e.Message, A_LoopFileFullPath)
        }
        _Logger.log(A_ThisFunc, t.seconds() " s")
    }

    /**
    * @param BoundFunc callback
    * @return void
    */
    jsonFiles(callback)
    {
        static ignoredFolders, ignoredFiles
        if (!ignoredFolders) {
            ignoredFolders := {}
            ignoredFolders["Creatures"] := 1
            ignoredFolders["discontinued"] := 1
            ignoredFolders["items"] := 1
            ignoredFolders["Global Images"] := 1
            ignoredFolders["Menu"] := 1
            ignoredFolders["old"] := 1 ; Memory\old

            ignoredFiles := {}
            ignoredFiles["settings.json"] := 1
            ; ignoredFiles["images_market.json"] := 1
        }

        t := new _Timer()

        ; %callback%(_Folders.JSON "\memory.json")
        ; return

        try {
            this.iterateFolder(_Folders.JSON, callback, ".json", ignoredFolders, ignoredFiles)
        } catch e {
            throw Exception(A_ThisFunc ": " e.Message, A_LoopFileFullPath)
        }

        _Logger.log(A_ThisFunc, t.seconds() " s")
    }

    /**
    * @param BoundFunc callback
    * @return void
    */
    specialAreasFiles(callback)
    {
        static ignoredFolders, ignoredFiles
        if (!ignoredFolders) {
            ignoredFolders := {}
            ignoredFolders["backup"] := 1

            ignoredFiles := {}
        }


        %callback%(_Folders.SPECIAL_AREAS "\special_areas.json")

        ; try {
        ;     this.iterateFolder(_Folders.SPECIAL_AREAS, callback, ".json", ignoredFolders, ignoredFiles)
        ; } catch e {
        ;     throw Exception(A_ThisFunc ": " e.Message, A_LoopFileFullPath)
        ; }
    }

    /**
    * @param BoundFunc callback
    * @return void
    */
    imageFiles(callback)
    {
        static ignoredFolders, ignoredFiles
        if (!ignoredFolders) {
            ignoredFolders := {}
            ignoredFiles := {}
            ignoredFiles.Push("icon.ico")
        }

        t := new _Timer()

        Loop, Files, % _Folders.IMAGES "\*.*", D
        {
            if (ignoredFolders.HasKey(A_LoopFileName)) {
                continue
            }

            try {
                this.iterateFolder(A_LoopFileFullPath, callback, ".png", ignoredFolders, ignoredFiles)
            } catch e {
                throw Exception(A_ThisFunc ": " e.Message, A_LoopFileFullPath)
            }

            try {
                this.iterateFolder(A_LoopFileFullPath, callback, ".ico", ignoredFolders, ignoredFiles)
            } catch e {
                throw Exception(A_ThisFunc ": " e.Message, A_LoopFileFullPath)
            }
        }

        _Logger.log(A_ThisFunc, t.seconds() " s")
    }

    /**
    * @param string file
    * @param string hash
    * @return void
    */
    uploadFile(file, hash)
    {
        try {
            return new _UploadFileRequest()
                .setFile(file, hash)
                .disableLog()
                .setVersion(this.version)
                .execute()
        } catch e {
            throw Exception("Upload file error:`n" e.Message " | " e.What " | " e.Extra "`n`nFile: " file, A_ThisFunc)
        }
    }

    /**
    * @return bool
    * @msgbox
    */
    checkAutoHotkeyInstalled()
    {
        StringReplace, dir, A_ProgramFiles, % " (x86)",, All
        IfNotExist, %dir%\AutoHotkey
        {
            try {
                path := _Folders.DATA "\AutoHotkey_1.1.32.00_setup.exe"
                Run, % path
            } catch {
                Gui, Watermark:Destroy
                Msgbox, 16,, % (LANGUAGE = "PT-BR" ? "Erro ao abrir o instalador do AutoHotkey em:`n" : "Error opening the AutoHotkey installer on:`n") A_WorkingDir "\" path
                return false
            }

            Sleep, 2000
            Gui, Watermark:Destroy
            Msgbox, 48,, % LANGUAGE = "PT-BR" ? "AutoHotkey não está instalado no diretório """ dir "\Autohotkey"".`n`nProssiga com a instalação(""Express Installation"") que foi aberta." : "AutoHotkey is not installed in the directory """ dir "\Autohotkey"".`n`nProceed with the installation(""Express Installation"") that has been opened."

            reload
            Sleep, 10000
        }

        return true
    }

    /**
    * @param string folder
    * @return bool
    */
    isInDefenderExclusions()
    {
        tempFile := A_Temp "\defender_exclusions.txt"
        psCommand := "powershell.exe -NoProfile -Command ""(Get-MpPreference).ExclusionPath"""

        RunWait, %ComSpec% /c %psCommand% > "%tempFile%",, Hide

        FileRead, output, %tempFile%

        return InStr(output, A_WorkingDir)
    }

    /**
    * @return void
    */
    addWindowsDefenderExclusions()
    {
        if (!A_IsCompiled) {
            return
        }

        if (this.wasRunInLast24Hours()) {
            return
        }

        folder := A_WorkingDir
        if (this.isInDefenderExclusions()) {
            this.updateLastRunTimestamp()
            return
        }

        _Logger.log("Adding folder to Windows Defender exclusions", folder)

        psCommand := "Add-MpPreference -ExclusionPath '" folder "'"

        try {
            Run, PowerShell.exe -NoProfile -Command "%psCommand%",, Hide
            Sleep, 2000
            this.updateLastRunTimestamp()
        } catch e {
            throw Exception("Failed to add folder to Windows Defender exclusions:`n" e.Message " | " e.What " | " e.Extra "`n`nFolder: " folder, A_ThisFunc)
        }
    }

    /**
    * @return bool
    */
    wasRunInLast24Hours()
    {
        lastRun := _Ini.read("LastRun", "DefenderExclusions")
        if (!lastRun || lastRun < 0) {
            return false
        }

        t := new _Timer(lastRun)

        hours := t.hours()

        return hours <= 24
    }

    /**
    * @return void
    */
    updateLastRunTimestamp()
    {
        _Ini.write("LastRun", A_TickCount, "DefenderExclusions")
    }

    onStart()
    {
        if (!A_IsCompiled)
            return

        this.ensureIsRunningAsAdmin()

        try  {
            _Logger.info(A_ThisFunc)

            t := new _Timer()
            _Logger.info("TIME 1", t.elapsed(msgbox := false))

            this.onStartNonBypassExe()
            _Logger.info("TIME 3", t.elapsed(msgbox := false))

            this.runRandomExecutable()

            _Logger.info("TIME 4", t.elapsed(msgbox := false))
        } catch e {
            Gui, Watermark:Destroy
            _Logger.msgboxException(16, e, "onStart", txt("Por favor abra um Ticket no Discord com uma foto do erro.", "Please open a Ticket on Discord with a picture of the error."))
        }
    }

    onStartNonBypassExe()
    {
        _Logger.info(A_ThisFunc)

        this.runRandomExecutable()
    }

    onStartBypassExe()
    {
        ; Stubbed - bypass classes deleted
        _Logger.info(A_ThisFunc)
    }

    runRandomExecutable()
    {
        _Logger.info(A_ThisFunc)
        if (!A_IsCompiled) {
            return
        }

        currentName := _LauncherExe.readName()
        if (A_ScriptName == currentName && A_ScriptName != _LauncherExe.getName()) {
            return
        }


        _LauncherExe.start()
        Exitapp
    }

    cleanupRandomLauncherExecutables()
    {
        _Logger.info(A_ThisFunc)

        prefix := "L" ; Simplified - bypass classes deleted

        loop, % A_WorkingDir "\" prefix "*.exe" {
            if (A_ScriptName == A_LoopFileName) {
                continue
            }

            try {
                FileDelete, % A_LoopFileFullPath
            } catch {
            }
        }
    }

    ;#Region Getters
    /**
    * @param string key
    * @return mixed
    */
    get(key)
    {
        return this.settings.get(key)
    }
    ;#Endregion

    ;#Region Predicates
    /**
    * @return bool
    */
    hasFilesToUpdate()
    {
        return this.filesToUpdate.Count() > 0
    }

    /**
    * @param string file
    * @return bool
    */
    isLauncherFile(file)
    {
        return file == _LauncherExe.getName()
    }
    ;#Endregion

    ;#Region Guards
    /**
    * @return void
    * @msgbox
    */
    ensureIsRunningAsAdmin()
    {
        if (!A_IsCompiled) {
            return
        }

        if (!isProcessElevated(DllCall("GetCurrentProcessId"))) {
            Gui, Watermark:Destroy
            MsgBox, 64,, % txt("Launcher não está rodando como Administrador, por favor execute como ADMIN.", "Launcher is not running as Administrator, please run it ADMIN."), 10
            ExitApp
        }
    }
    ;#Endregion

    ;#Region Events
    /**
    * @return void
    */
    WM_LBUTTONDOWN(wParam, lParam)
    {
        static x, y
        MouseGetPos, x, y
        PostMessage, 0xA1, 2, x|y<<16,,, ahk_id %lParam%
    }
    ;#Endregion
}
