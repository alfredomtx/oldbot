class _DownloadFileRequest extends _AbstractUpdaterRequest
{
    static RETRIES := 3
    static RETRY_DELAY := 3000
    static RECEIVE_TIMEOUT := 120000

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        base.__New()

        this.disableLog()
        this.returnRaw()
    }

    setFileAndPath(file, path)
    {
        _Validation.string("file", file)
        if (path) {
            if (!FileExist(path)) {
                FileCreateDir, % path
            }

            _Validation.folderExists("path", path)
        }

        this.file := file
        this.path := path

        return this
    }

    getBody()
    {
        return {"file": this.file}
    }

    getRoute()
    {
        return "/api/updater/download"
    }

    /**
    * @throws
    */
    handleResponseBody()
    {
        fileName := this.getFileNameFromRequest()

        if (_Launcher.isLauncherFile(fileName)) {
            this.handleLauncherFile()
            return
        }

        this.saveFileWithRetry(fileName)
    }

    handleLauncherFile()
    {
        this.saveFileWithRetry(StrReplace(_LauncherExe.getName(), ".exe", ".temp.exe"))

        _Validation.fileExists("_LAUNCHER.LAUNCHER_UPDATE_SCRIPT ", _LAUNCHER.LAUNCHER_UPDATE_SCRIPT)

        try {
            Run, % _Str.quoted(A_AhkPath) " " _Str.quoted(_LAUNCHER.LAUNCHER_UPDATE_SCRIPT)
            ExitApp
        } catch e {
            throw Exception("Failed to update launcher, please contact support.`n`nError: " e.Message)
        }
    }

    saveFileWithRetry(fileName)
    {
        try {
            retry(this.saveFile.bind(this, fileName), _DownloadFileRequest.RETRIES, _DownloadFileRequest.RETRY_DELAY, fileName)
        } catch e {
            throw e
        }
    }

    saveFile(fileName)
    {
        try {
            file := ComObjCreate("ADODB.Stream")
            file.Type := 1
        } catch e {
            _Logger.exception(e, A_ThisFunc, "ComObjCreate(""ADODB.Stream"")")
            throw Exception("[File: """ fileName """] Failed to create object: " e.Message " | " e.What " | LastError: " A_LastError)
        }

        try {
            file.Open()
        } catch e {
            _Logger.exception(e, A_ThisFunc, "file.Open")
            throw Exception("[File: """ fileName """] Failed to open file: " e.Message " | " e.What " | LastError: " A_LastError)
        }

        try {
            file.Write(this.ResponseBody)
        } catch e {
            _Logger.exception(e, A_ThisFunc, "file.Write")
            file.Close()
            throw Exception("[File: """ fileName """] Failed to write file: " e.Message " | " e.What " | LastError: " A_LastError)
        }

        try {
            path := (this.path ? this.path "\" : "")
            file.SaveToFile(path fileName, 2)
        } catch e {
            _Logger.exception(e, A_ThisFunc, "file.SaveToFile")
            throw Exception("[File path: """ path fileName """] Failed to save file: " e.Message " | " e.What " | LastError: " A_LastError)
        } finally {
            file.Close()
        }
    }

    getFileNameFromRequest()
    {
        try {
            contentDisposition := this.CLIENT.GetResponseHeader("Content-Disposition")
        } catch e {
            throw exception("Missing Content-Disposition header in response.")
        }

        str := StrSplit(contentDisposition, "filename=")
        filename := StrReplace(str.2, """", "")
        if (empty(filename)) {
            this.throwValidationException("Empty ""filename"" in Content-Disposition header.")
        }

        return filename
    }

    validateResponseText()
    {
        if (this.responseText = "1") {
            throw Exception("Invalid response from server.")
        }
    }
}
