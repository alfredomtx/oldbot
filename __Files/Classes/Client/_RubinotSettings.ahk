

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\Helpers\_OtmlSettings.ahk

Class _RubinotSettings extends _OtmlSettings
{
    static INSTANCE

    static IDENTIFIER := "Rubinot"
    static OTML_PATH := A_AppData "\RTC\data\config.otml"


    __New()
    {
        if (_RubinotSettings.INSTANCE) {
            return _RubinotSettings.INSTANCE
        }

        base.__New(this.OTML_PATH, OldbotSettings.settingsJsonObj.tibiaClient.windowTitle, OldbotSettings.settingsJsonObj.tibiaClient.windowClassFilter)

        _RubinotSettings.INSTANCE := this
    }

    getSettings()
    {
        static settings
        if (settings) {
            return settings
        }

        settings := {}
        ; settings.Push({"hidingFilters": "true"})
        settings.Push({"antialiasing": "2"})
        settings.Push({"actionBarShowBottom1": "true"})
        settings.Push({"autoChaseOverride": "false"})
        settings.Push({"cooldownSecond": "false"})
        settings.Push({"colouriseLootColor": "3"})
        settings.Push({"customisableBars": "false"})
        settings.Push({"ctrlDragCheckBox": "false"})
        settings.Push({"displayHealth": "true"})
        settings.Push({"enableLights": "false"})
        settings.Push({"graphicalCooldown": "false"})
        settings.Push({"hidePlayerBars": "false"})
        settings.Push({"lootControl": "2"})
        settings.Push({"showOwnBars": "false"})
        settings.Push({"showCooldown": "true"})
        settings.Push({"storeAskBeforeBuyingProducts": "false"})
        ; settings.Push({"zoom": "0"})

        return settings
    }

    check(showMsg := false)
    {
        if (!isRubinot()) {
            return
        }

        try {
            changed := false
            if (this.checkAllSettings()) {
                changed := true
            }

            if (changed) {
                Msgbox, 64, % this.IDENTIFIER " Settings", % txt("Foram alteradas algumas configurações do " this.IDENTIFIER ", agora você já pode reabrir o cliente e checar checar as configurações novamente.", "Some settings of " this.IDENTIFIER " have been changed, now you can reopen the client and check the settings again.")
                return
            }
        } catch e {
            if (e.What = "ClientClosed") {
                Msgbox, 64, % this.IDENTIFIER " Settings", % txt("Antes de checar as configurações do cliente, há outras configurações que precisam ser alteradas com o cliente fechado primeiro.`n`nFeche o cliente do " this.IDENTIFIER " e clique no menu superior Editar -> ""Checar configurações do cliente"" para continuar.", "Before checking the client settings, there are other settings that need to be changed with the client closed first.`n`nClose the " this.IDENTIFIER " client and click on the top menu Edit -> ""Check client settings"" to continue.")
                return
            }

            Msgbox, 48, % this.IDENTIFIER " Settings", % e.Message 
            ; Msgbox, 52, % this.IDENTIFIER " Settings", % e.Message "`n`n" txt("Abrir aquivo de configurações do " this.IDENTIFIER "?", "Open " this.IDENTIFIER " settings file?")
            ; IfMsgBox, Yes
            ; {
            ;     Run, % this.OTML_PATH
            ; }
            return
        }

        if (showMsg) {
            Msgbox, 64, % this.IDENTIFIER " Settings", % txt("Todas as configurações do " this.IDENTIFIER " estão corretas.", "All " this.IDENTIFIER " settings are correct.")
        }

    }
}