/**
* @property string otmlPath
*/
class _OtmlSettings extends _BaseClass
{
    static INSTANCES := {}

    /**
    * @singleton
    */
    __New(otmlPath, clientTitle, clientClass)
    {
        _Validation.fileExists("otmlPath", otmlPath)

        hash := Hash("", otmlPath)
        if (_OtmlSettings.INSTANCES[hash]) {
            return _OtmlSettings.INSTANCES[hash]
        }

        this.otmlPath := otmlPath
        this.clientTitle := clientTitle
        this.clientClass := clientClass

        _OtmlSettings.INSTANCES[hash] := this
    }

    /**
    * @return array<string, string>
    */
    getSettings()
    {
        abstractMethod()
    }

    /**
    * @param bool showMsgbox
    * @return void
    * @throws
    */
    checkSettingsAndWarnIfRequired(showMsgbox := true)
    {
        try {
            this.checkSettings()
        } catch e {
            text := txt("Há configurações que precisam ser alteradas com o cliente fechado primeiro.`n`nFeche o cliente do jogo e clique no menu superior Editar -> ""Checar configurações do cliente"" para continuar.", "There are settings that need to be changed with the client closed first.`n`nClose the game client and click on the top menu Edit -> ""Check client settings"" to continue.")
            if (showMsgbox) {
                Msgbox, 64, % "Client OTML Settings", % text
            }

            throw e
        }
    }

    /**
    * @return bool
    */
    checkAllSettings()
    {
        try {
            return this.writeSettings()
        } catch e {
            throw e
        }
    }

    /**
    * @return bool
    */
    writeSettings()
    {
        changed := false
        for _, setting in this.getSettings()
        {
            for, key, value in setting
            {
                if (this.checkSetting(key, value)) {
                    changed := true
                }
            }
        }

        return changed
    }

    /**
    * @param string key
    * @param string value
    * @return bool
    * @throws
    */
    checkSetting(key, value)
    {
        current := this.readConfig(key)
        if (current = value) {
            return false
        }

        try {
            this.writeConfig(key, value)
        } catch e {
            if (e.What = "FileError") {
                throw e
            }

            throw Exception(e.Message "`n`n-----`n`nSetting: " key "`nCurrent: " current "`nExpected: " value)
        }

        return true
    }

    /**
    * @return void
    * @throws
    */
    ensureClientIsClosed()
    {
        if (this.isClientOpened()) {
            throw Exception(txt("O cliente do jogo precisa estar fechado para alterar algumas configurações.`n`nFeche o cliente do jogo e clique no menu superior Editar -> ""Checar configurações do cliente"".", "The game client needs to be closed to change some settings.`n`nClose the game client and, click on the top menu Edit -> ""Check client setitngs""."), "ClientOpened")
        }
    }

    /**
    * @return bool
    */
    isClientOpened()
    {
        winGet, winList, list, % this.clientTitle
        Loop, %winList% {
            if (winList%A_Index% = "") {
                return false
            }

            WinGetTitle, tibia_title%A_Index%, % "ahk_id " winList%A_Index%
            windowTitle := tibia_title%A_Index%
            WinGetClass, windowClass,  % "ahk_id " winList%A_Index%
            if (!InStr(windowClass, this.clientClass)) {
                continue
            }

            return true
        }

        return false
    }

    /**
    * @param string key
    * @param string value
    * @return void
    * @throws
    */
    writeConfig(key, value)
    {
        this.ensureClientIsClosed()

        _Validation.empty("value", value)

        data := this.readFile()

        line := this.extractConfigLine(key, data)
        if (empty(line)) {
            data .= "`n" key ": " value
        } else {
            data := StrReplace(data, line, key ": " value)
        }

        try {
            file := FileOpen(this.otmlPath, "w")
            file.Write(data)
            file.Close()
        } catch e {
            throw Exception(txt("Falha ao escrever no arquivo de configuração.", "Failed to write on config file."), "FileError")
        }
    }

    /**
    * @param string key
    * @return ?string
    */
    readConfig(key)
    {
        data := this.readFile()

        return this.extractValueFromLine(key, this.extractConfigLine(key, data))
    }

    /**
    * @return string
    * @throws
    */
    readFile()
    {
        try {
            _Validation.fileExists("this.otmlPath", this.otmlPath)

            FileRead, data, % this.otmlPath
            if (ErrorLevel) {
                throw Exception(txt("Falha ao ler o arquivo de configuração.", "Failed to read config file."))
            }
        } catch e {
            throw Exception(e.Message, "FileError")
        }

        return data
    }

    /**
    * @param string key
    * @param string data
    * @return ?string
    */
    extractConfigLine(key, data)
    {
        key .= ":"
        pos := InStr(data, key)
        if (!pos) {
            return
        }

        d := SubStr(data, pos, StrLen(data) - pos)
        p := InStr(d, "`n")
        line := SubStr(d, 1, p - 1)

        return line
    }

    /**
    * @param string key
    * @param string line
    * @return ?string
    */
    extractValueFromLine(key, line)
    {
        value := StrReplace(line, key, "")
        value := Trim(StrReplace(value, ":", ""))

        return value
    }
}

