#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Objects\_ProcessQueue.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

class _AbstractExe extends _BaseClass
{
    static TEMP_FOLDER := _Folders.EXECUTABLES "\temp"

    static INI_SECTION := "executables"
    static STATE_INI_SECTION := "state"

    static PID_SECTION := "pid"

    ; Common Windows executable names from popular applications
    static COMMON_EXE_NAMES := [ "chrome.exe"
            , "firefox.exe"
            , "msedge.exe"
            , "opera.exe"
            , "brave.exe"
            , "discord.exe"
            , "slack.exe"
            , "teams.exe"
            , "zoom.exe"
            , "skype.exe"
            , "spotify.exe"
            , "vlc.exe"
            , "winamp.exe"
            , "steam.exe"
            , "epicgameslauncher.exe"
            , "origin.exe"
            , "uplay.exe"
            , "battle.net.exe"
            , "notepad++.exe"
            , "vscode.exe"
            , "sublime_text.exe"
            , "atom.exe"
            , "gimp.exe"
            , "photoshop.exe"
            , "illustrator.exe"
            , "winrar.exe"
            , "7zFM.exe"
            , "winzip.exe"
            , "utorrent.exe"
            , "qbittorrent.exe"
            , "dropbox.exe"
            , "onedrive.exe"
            , "googledrive.exe"
            , "evernote.exe"
            , "notion.exe"
            , "obs64.exe"
            , "streamlabs.exe"
            , "audacity.exe"
            , "teamviewer.exe"
            , "anydesk.exe"
            , "putty.exe"
            , "filezilla.exe"
            , "thunderbird.exe"
            , "outlook.exe"
            , "word.exe"
            , "excel.exe"
            , "powerpoint.exe"
            , "acrobat.exe"
            , "ccleaner.exe"
            , "malwarebytes.exe" ]

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        guardAgainstInstantiation(this)
    }

    CLEANUP()
    {
        for _, exe in _Executables.getList() {
            exe.deleteCurrent()
        }

        this.deleteAllTemp()
    }

    deleteAllTemp()
    {
        this.closeAllTemp()

        loop, % _Folders.EXECUTABLES_TEMP "\*.exe" {
            try {
                FileDelete, % A_LoopFileFullPath
            } catch {
                Process, Close, % A_LoopFileName
                Sleep, 50

                try {
                    FileDelete, % A_LoopFileFullPath
                } catch {
                    throw Exception("Failed to delete temp exe: " A_LoopFileFullPath)
                }
            }
        }
    }

    closeAllTemp()
    {
        loop, % _Folders.EXECUTABLES_TEMP "\*.exe" {
            Process, Exist, % A_LoopFileName
            if (ErrorLevel) {
                Process, Close, % ErrorLevel
                Sleep, 100
            }
        }
    }

    /**
    * @return void
    */
    start()
    {
        _Logger.log(A_ThisFunc, this.NAME)
        this.ensureIsRandomExe()
        this.processExistOpen()
    }

    /**
    * @return void
    */
    processExistOpen()
    {
        classLoaded("_ProcessQueue", _ProcessQueue)
        _ProcessQueue.add(new _Process(this.getCurrentName(), this.getPID()))

        _ProcessQueue.setTimer()
    }

    /**
    * @return bool
    */
    usesRandomName()
    {
        return _Executables.RANDOMIZE_NAMES
    }

    /**
    * @return void
    */
    ensureIsRandomExe()
    {
        if (!this.usesRandomName()) {
            return
        }

        if (!this.shouldRenameRandom()) {
            return
        }

        this.renameRandom()

        _Ini.write(this.NAME, A_TickCount, "exeRename")
        ; Sleep, 200 ; commented on 17/07/2025
    }

    /**
    * @return this
    */
    renameRandom()
    {
        prefix := this.getPrefix()

        randomExeName := this.getRandomExeNameFromList()
        ; Remove .exe extension as rename() method adds it back
        randomExeName := StrReplace(randomExeName, ".exe", "")
        ; randomExeName .= random(1, 10)

        name := prefix "" randomExeName
        this.rename(name)

        ; this.rename(prefix "" _Str.random(random(6, 12)))

        return this
    }

    getPrefix()
    {
        return StrReplace(SubStr(this.__Class, 1, 2), "_", "")
    }

    getRandomExeNameFromList()
    {
        return  _AbstractExe.COMMON_EXE_NAMES[random(1, _AbstractExe.COMMON_EXE_NAMES.Count())]
    }

    /**
    * @return void
    */
    shouldRenameRandom()
    {
        if (this.getCurrentName() == this.getName()) {
            return true
        }

        lastRename := _Ini.read(this.NAME, "exeRename")
        if (empty(lastRename)) {
            return true
        }

        seconds := (A_TickCount - lastRename) / 1000
        minutes := seconds / 60
        if (minutes > 1) {
            return true
        }

        if (!this.currentExists()) {
            return true
        }

        return false
    }

    /**
    * @param string name
    * @return this
    * @throws
    */
    rename(name)
    {
        this.ensureExists()

        if (_Folders.EXECUTABLES_TEMP && !FileExist(_Folders.EXECUTABLES_TEMP)) {
            FileCreateDir, % _Folders.EXECUTABLES_TEMP
        }

        this.deleteCurrent()

        name := InStr(name, ".exe") ? name : name ".exe"
        src := this.getPath()
        dest := this.getRandomExePath(name)

        try {
            FileCopy, % src, % dest, 1
            this.setName(name)
        } catch e {
            throw Exception("Failed to copy exe """ this.getName() """.`nFrom:""" src """`nTo:""" dest """: " e.Message)
        }

        return this
    }

    /**
    * @return void
    * @throws
    */
    ensureExists()
    {
        executablesPath := this.getPath()
        if (!FileExist(executablesPath)) {
            throw Exception("Exe """ this.getName() """ does not exists on executables folder:`n""" executablesPath """")
        }
    }

    /**
    * @return void
    */
    currentExists()
    {
        if (!this.getCurrentName()) {
            return false
        }

        return FileExist(this.getCurrentPath())
    }

    /**
    * @return void
    */
    deleteCurrent()
    {
        if (!this.currentExists()){
            return
        }

        currentName := this.getCurrentName()
        if (currentName == this.getName()) {
            return
        }

        Process, Exist, % currentName
        if (ErrorLevel) {
            Process, Close, % ErrorLevel
            Sleep, 100
        }

        try {
            path := _Folders.EXECUTABLES_TEMP "\" currentName
            FileDelete, % path
        } catch {
        }

        _Ini.delete(this.NAME, this.INI_SECTION)
    }

    /**
    * @return void
    */
    stop()
    {
        ; _Logger.log(A_ThisFunc, this.NAME)
        PID := this.getPID()
        if (!PID) {
            return
        }

        this.deletePID()

        Process,Exist,% PID
        if (ErrorLevel != PID) {
            return
        }

        Process, Close, % PID
        Sleep, 100

        /**
        * fallback and close by exe name if it fails to close by PID
        */
        Process,Exist,% PID
        if (ErrorLevel != PID) {
            return
        }

        exeName := this.getCurrentName()
        if (!exeName) {
            return
        }

        Sleep, 100

        Process,Exist,% exeName
        if (ErrorLevel) {
            _Logger.log(A_ThisFunc, "PID: " ErrorLevel ", closing by exe: " exeName)
            Process,Close,% exeName
        }
    }

    /**
    * @param bool value
    * @return void
    */
    writePaused(value)
    {
        _Ini.write(this.NAME "Paused", value, this.STATE_INI_SECTION)
    }

    /**
    * @return string
    */
    getCurrentName()
    {
        return this.usesRandomName() ? this.readName() : this.getName()
    }

    /**
    * @return string
    */
    readName()
    {
        return _Ini.read(this.NAME, this.INI_SECTION, this.getName())
    }

    /**
    * @return string
    */
    getName()
    {
        return this.NAME ".exe"
    }

    /**
    * @return string
    */
    getExeIdentifier()
    {
        return this.NAME "ExeName"
    }

    /**
    * @return string
    */
    getCurrentPath()
    {
        return this.usesRandomName() ? _Folders.EXECUTABLES_TEMP "\" this.getCurrentName() : this.getPath()
    }

    /**
    * @return string
    */
    getRandomExePath(name)
    {
        return _Folders.EXECUTABLES_TEMP "\" name
    }

    /**
    * @return string
    */
    getPath()
    {
        return _Folders.EXECUTABLES "\" this.getName()
    }

    /**
    * @return ?int
    */
    getPID()
    {
        return _Ini.read(this.NAME, this.PID_SECTION)
    }

    /**
    * @return this
    */
    deletePID()
    {
        _Ini.delete(this.NAME, this.PID_SECTION)
    }

    /**
    * @return int
    * @throws
    */
    writePID()
    {
        PID := DllCall("GetCurrentProcessId")
        if (!PID) {
            message := "Failed to get PID for " _Str.quoted(this.getName())
            _Logger.msgboxExceptionOnLocal(message ": " e.Message " | " e.What)


            Process, Exist
            PID := ErrorLevel
            if (!PID) {
                throw Exception(message)
            }
        }

        this.setPID(PID)

        return PID
    }

    /**
    * @param string name
    * @return this
    */
    setName(name)
    {
        _Ini.write(this.NAME, name, this.INI_SECTION)

        return this
    }

    /**
    * @param int pid
    * @return this
    */
    setPID(pid)
    {
        _Validation.number("pid", pid)
        _Ini.write(this.NAME, pid, this.PID_SECTION)

        return this
    }

    /**
    * @return bool
    */
    isRunning()
    {
        PID := this.getPID()
        if (empty(PID)) {
            return false
        }

        Process,Exist,% PID

        return ErrorLevel ? true : false
    }

    /**
    * @return bool
    */
    isPaused()
    {
        return _Ini.readBoolean(this.NAME "Paused", this.STATE_INI_SECTION, false)
    }

    hide()
    {
        path := this.getCurrentPath()
        try {
            FileSetAttrib, +H, % this.getCurrentPath()
        } catch e {
            throw e
        }

        return this
    }
}