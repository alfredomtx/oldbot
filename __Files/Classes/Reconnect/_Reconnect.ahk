
class _Reconnect extends _BaseClass
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        ; guardAgainstAbstractInstantiation(this)
    }

    /**
    * @param string name
    * @return mixed
    */
    get(name)
    {
        static settings
        if (!settings) {
            settings := new _ReconnectIniSettings()
        }

        return settings.get(name, this.sioName)
    }

    autoLoginSelectClient()
    {
        return this.get("autoLoginSelectClient")
    }

    /**
    * @return void
    * @throws
    */
    decryptAccountData(account := 1)
    {
        this.acc := Encryptor.decrypt(accountEmail%account%)
        this.pass := Encryptor.decryptPassword(accountPassword%account%)
    }

    /**
    * @return bool
    */
    autoLogin(fromStartup := false)
    {
        if (!this.autoLoginSelectClient() || OldbotSettings.uncompatibleModule("reconnect")) {
            return false
        }

        if (isConnected()) {
            return true
        }

        try {
            this.decryptAccountData()
        } catch e {
            this.warnNotification(e.Message)
            return false
        }

        if (!fromStartup && empty(this.acc)) {
            this.missingFieldNotification("E-mail")
            return false
        }

        if (!fromStartup && empty(this.pass)) {
            this.missingFieldNotification("Password")
            return false
        }

        if (this.connectionLost()) {
            return true
        }

        if (this.charSelectionVisible()) {
            return true
        }

        ; TrayTipMessage("Auto Login", txt("Iniciando", "Starting") " Auto Login...", 2)
        visible := false
        loop, 20 {
            if (this.isFormVisible()) {
                visible := true
                break
            }

            Sleep, 500
        }

        if (!visible) {
            this.warnNotification(txt("Formulário de login não encontrado.", "Login form not found."))
            return false
        }

        this.fillForm()

        this.autoLoginCharacterLogin()

        return true
    }

    autoLoginCharacterLogin()
    {
        if (!this.get("autoLoginCharacterLogin")) {
            return
        }

        charListVisible := _Reconnect.waitCharacterVisible()
        if (!charListVisible) {
            return
        }

        _Reconnect.selectCharacter(characterListPosition1)
    }

    missingFieldNotification(field)
    {
        this.warnNotification(txt("A ""Account 1"" na aba Reconnect não possui o campo """ field """ preenchido.", "The ""Account 1"" on the Reconnect tab does not have the """ field """ field filled."))
    }

    warnNotification(msg)
    {
        TrayTipMessage("Auto Login", msg, 4, true)
    }

    /**
    * @return bool
    */
    isFormVisible()
    {
        this.emailFormPosition := {}
        try {
            _search := new _ImageSearch()
                .setFile("email")
                .setFolder(ImagesConfig.reconnectFolder)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }
        ; msgbox, % A_ThisFunc "`n" serialize(vars)
        if (_search.notFound()) {
            return false
        }

        this.emailFormPosition := new _Coordinate(_search.getX(), _search.getY())
            .addX(120)
            .addY(5)

        return true
    }

    fillForm()
    {
        Loop, 3 {
            this.emailFormPosition
                .click()
        }

        ; SetKeyDelay, 20, 40

        ClipboardOld := Clipboard
        Sleep, 25
        copyToClipboard(_Reconnect.acc)
        Sleep, 25
        Send("Backspace")
        Sleep, 50
        SendModifier("Ctrl", "v")
        Sleep, 50
        Send("Tab")
        Sleep, 50
        copyToClipboard(_Reconnect.pass)
        SendModifier("Ctrl", "v")

        Sleep, 50
        Send("Enter")
        copyToClipboard(ClipboardOld)
        Sleep, 100

        ; SetKeyDelay, -1, 40
        ; SetKeyDelay, -1, -1
    }

    /**
    * @return bool
    */
    charSelectionVisible()
    {
        try {
            _search := new _ImageSearch()
                .setFile("select_character")
                .setFolder(ImagesConfig.reconnectFolder)
                .setVariation(50)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }

        return _search.found()
    }

    /**
    * @return bool
    */
    connectionLost()
    {
        try {
            _search := new _ImageSearch()
                .setFile("connection_lost")
                .setFolder(ImagesConfig.reconnectFolder)
                .setVariation(50)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }

        return _search.found()
    }

    /**
    * @return bool
    */
    waitCharacterVisible()
    {
        Loop, 100 { 
            Sleep, 100
            if (this.charSelectionVisible()) {
                Sleep, 200
                return true
            }
        }

        return false
    }

    selectCharacter(position)
    {
        position := position - 1

        Loop, % position {
            Send("Down")
            Sleep, 125
        }

        Send("Enter")
    }

    /**
    * @return bool
    */
    wrongAccountWindowVisible() {
        try {
            _search := new _ImageSearch()
                .setFile("sorry")
                .setFolder(ImagesConfig.reconnectFolder)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }
    }
    /**
    * @return bool
    */
    tokenWindowVisible() {
        try {
            _search := new _ImageSearch()
                .setFile("token_window")
                .setFolder(ImagesConfig.reconnectFolder)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }

        return _search.found()
    }

    /**
    * @return bool
    */
    waitPleaseWait()
    {
        Loop, 100 { 
            Sleep, 100
            if (this.pleaseWaitVisible()) {
                Sleep, 200
                return true
            }
        }

        return false
    }

    /**
    * @return bool
    */
    pleaseWaitVisible()
    {
        try {
            _search := new _ImageSearch()
                .setFile("please_wait")
                .setFolder(ImagesConfig.reconnectFolder)
                .setVariation(50)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }

        return _search.found()
    }
}