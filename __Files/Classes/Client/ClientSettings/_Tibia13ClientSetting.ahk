#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\_ClientSettings.ahk

class _Tibia13ClientSetting extends _ClientSettings
{
    static INI_SECTION := "client_settings_check"

    handledAutomaticCheck()
    {
        try {
            this.withProgress()
                .automaticCheck()
        } catch e {
            Msgbox, 16, % this.NAME " - " txt("Erro ao verificar as configurações do cliente", "Error checking client settings"), % e.Message, 20
        }
    }

    withProgress()
    {
        this._withProgress := true

        return this
    }

    automaticCheck()
    {
        if (OldBotSettings.settingsJsonObj.others.ignoreCheckClientSettings) {
            return
        }

        if (this.wasCheckedInTheLast24Hours()) {
            return
        }

        this.check()
    }

    check(apply := true)
    {
        if (this._withProgress) {
            this.createProgressGui(this.progressText())
        }

        try {
            if (isRubinot()) {
                throw Exception("Rubinot RTC not supported.")
            }

            if (!isTibia13Or14()) {
                throw Exception("Client not supported.")
            }

            this.clientStateValidations()

            this.openSettingsWithHoktey()

            if (this._withProgress) {
                this.updateProgress(1, 2)
            }

            this.selectShowAdvancedOptions()

            this.settingCheck()

            _Ini.write(this.NAME, A_TickCount, this.INI_SECTION)

            if (this._withProgress) {
                this.updateProgress(2, 2)
            }

            if (apply) {
                this.applySettings()
            }
        } catch e {
            throw e
        } finally {
            this.closeProgressGui()
        }
    }

    wasCheckedInTheLast24Hours()
    {
        timestamp := _Ini.read(this.NAME, this.INI_SECTION)
        if (!timestamp || timestamp < 0) {
            return false
        }

        t := new _Timer(timestamp)

        minutes := t.minutes()
        hours := t.hours()

        return hours <= 24
    }

    clientStateValidations()
    {
        if (TibiaClient.isClientClosed() = true) {
            throw Exception(txt("O cliente do Tibia está fechado.", "Tibia client is closed."), "ClientStateException")
        }

        if (isDisconnected()) {
            throw Exception(txt("O char está desconectado.", "Character is disconnected."), "ClientStateException")
        }

        TibiaClient.checkClientSelected()

        if (WindowWidth = "" OR WindowHeight = "") {
            TibiaClient.getClientArea()
            if (TibiaClient.isClientClosed(false) = true)
                return false
        }


        if (backgroundMouseInput = false OR backgroundKeyboardInput = false) {
            WinActivate()
        }
    }

    settingCheck()
    {
        abstractMethod()
    }

    progressText()
    {
        abstractMethod()
    }
}