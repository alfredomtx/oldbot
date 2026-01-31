
Class _OldBotSettingsGUI extends _AbstractSettingsGUI
{
    static INSTANCE

    ; __Call(method, args*)
    ; {
    ;     if (this[method]) {
    ;         methodParams(this[method], method, args)
    ;         return this[method].Call(this, args*)
    ;     }

    ;     methodParams(this.instance[method], method, args)
    ;     return this.instance[method].Call(this.instance, args*)
    ; }

    /**
    * @singleton
    */
    __New()
    {
        if (_OldBotSettingsGUI.INSTANCE) {
            return _OldBotSettingsGUI.INSTANCE
        }

        base.__New(_OldBotIniSettings.FILE_PATH)

        this.guiHeight := 405

        this.instance := new _GUI("oldbotSettings", txt("Configurações do OldBot", "OldBot Settings") ": " _OldBotIniSettings.FILE_PATH)

        this.instance.onCreate(this.create.bind(this, this.instance))
            .w(this.guiWidth).h(this.guiHeight)
            .scrollable()
            .withoutMinimizeButton()
        ; .withoutWindowButtons()
            .afterCreate(this.afterCreate.bind(this))

        this.modules := {}
        this.modules.Push({"name": "Alerts", "disabled": uncompatibleModule("Alerts")})
        this.modules.Push({"name": "AutoSpells", "disabled": uncompatibleModule("AutoSpells")})
        this.modules.Push({"name": "Fishing", "disabled": uncompatibleModule("Fishing")})
        this.modules.Push({"name": "Healing", "disabled": uncompatibleModule("Healing")})
        this.modules.Push({"name": "Hotkeys", "disabled": uncompatibleModule("Hotkeys")})
        this.modules.Push({"name": "ItemRefill", "disabled": uncompatibleModule("ItemRefill")})
        this.modules.Push({"name": "Navigation", "disabled": uncompatibleModule("Navigation")})
        this.modules.Push({"name": "Persistent", "disabled": uncompatibleModule("Persistent")})
        this.modules.Push({"name": "Reconnect", "disabled": uncompatibleModule("Reconnect")})
        this.modules.Push({"name": "Sio", "disabled": uncompatibleModule("SioFriend")})
        this.modules.Push({"name": "Support", "disabled": uncompatibleModule("Support")})
        this.modules.Push({"name": "Targeting", "disabled": false})
        this.modules.Push({"name": "Looting", "disabled": false})

        _OldBotSettingsGUI.INSTANCE := this
    }

    open()
    {
        this.defaultX := this.calculateDefaultX(new _ProfileSettingsGUI().getX(), new _ProfileSettingsGUI().getW(), new _ProfileSettingsGUI().getW() + 20)
        this.defaultY := this.calculateDefaultY(new _ProfileSettingsGUI().getY(), new _ProfileSettingsGUI().getH())

        this.instance
            .defaultX(this.defaultX)
            .defaultY(this.defaultY)
            .open()
    }

    createControls()
    {
        this.showModules()

        this.oldbot()


        _AbstractStatefulControl.RESET_DEFAULT_STATE()
    }

    afterCreate()
    {
        ; this.updateVersionsList()
    }

    updateVersionsList(ignoreCache := false)
    {
        this.preferredVersion.list(this.getAvailableVersions(ignoreCache))
    }

    oldbot()
    {
        _AbstractStatefulControl.SET_DEFAULT_STATE(_OldBotIniSettings)

        this.title(txt("Atualizações", "Updates"), this.firstTitlePaddingTop)

        receiveBetaText := txt("Receber novas versões BETA", "Receive new BETA versions")

            new _Checkbox().title(receiveBetaText)
            .name("receiveBetaVersions")
            .xs().y()
            .tt("Caso marcado, o Auto Updater irá sempre baixar a versão BETA mais recente.`n`nCaso você queira usar somente versões estáveis(não ""BETA"") ou definir qual versão quer usar, mantenha essa opção desmarcada e selecione a versão desejada abaixo.", "If checked, the Auto Updater will always download the most recent BETA version.`n`nIf you want to use only stable versions(non ""BETA"") or set which version you want to use, keep this option unchecked and set the preferred version below.")
            .event(this.receiveBetaVersions.bind(this))
            .add()

        return

            new _Text().title("Versão preferida", "Preferred version", ":")
            .xs().yadd(12)
            .tt("Nessa opção é possível definir alguma versão específica para o Auto Updater checar atualizações e baixar(ou reverter para uma versão anterior).`n`nCaso a opção """ receiveBetaText """ esteja marcada, o bot irá sempre baixar a versão BETA mais recente, e essa opção será ignorada.", "In this option you can define some specific version for Auto Updater to check for updates and download(or rollback to a previous version).`n`nIf the option """ receiveBetaText """ is checked, the bot will always download the latest BETA version, and this option will be ignored.")
            .add()


        this.preferredVersion := new _Listbox().title("Carregando versões, aguarde...", "Loading versions, wait...", "||")
            .name("preferredVersion")
            .x().w(180).r(5)
            .parent()
            .disabled(new _OldBotIniSettings().get("receiveBetaVersions"))
            .loadAfterAdd(false)
            .add()

        this.getVersions := new _Button()
            .xadd(3).yp().w(22).h(22)
            .name("updateList")
            .tt("Atualizar lista de versões", "Update version list")
            .icon(_Icon.get(_Icon.RELOAD), "a0 l0 b0 s16")
        ; .disabled(new _OldBotIniSettings().get("receiveBetaVersions"))
            .event(this.updateVersionsList.bind(this, true))
            .add()
    }

    receiveBetaVersions(control, value)
    {
        (value) ? this.preferredVersion.disable() : this.preferredVersion.enable()
    }

    /**
    * @return string
    */
    getAvailableVersions(ignoreCache := false)
    {
        static availableVersions := ""
        if (!ignoreCache && availableVersions) {
            return availableVersions
        }

        versions := _Version.getAvailableVersions(ignoreCache)
        try {
            _Validation.stringOrNumber("_Arr.first(versions)", _Arr.first(versions))
        } catch {
            throw Exception(txt("Falha ao obter versões disponíveis, por favor contate o suporte.", "Failed to get available versions, please contact support."))
        }

        preferredVersion := _Version.getPreferred()
        availableVersions := {}
        for _, availableVersion in versions {
            if (InStr(availableVersion, "BETA")) {
                continue
            }

            availableVersions.Push(new _ListOption(string(availableVersion), string(availableVersion) == string(preferredVersion)))
        }

        return availableVersions
    }

    showModules()
    {
        _AbstractStatefulControl.SET_DEFAULT_STATE(_OldBotIniSettings)

        this.title(txt("Módulos", "Modules"))

        this.reloadButton := new _Button().title("Reabrir OldBot", "Reopen OldBot")
            .xs().y().w(100).h(20)
            .event(Func("Reload"))
            .disabled()
            .tt("É necessário reabrir o para aplicar as mudanças nos módulos", "It is necessary to reopen the bot to apply the changes in the modules")
            .add()

            new _Checkbox().title("Ativar/desativar todos", "Enable/disable all")
            .name("toggleAllModules")
            .xs().y()
            .afterSubmit(this.toggleAll.bind(this))
            .add()

        for _, module in this.modules {
            this.showModule(module)
        }
    }


    showModule(module)
    {
        name := module.name

            new _Checkbox().title("Mostrar aba " _Str.quoted(name), "Show " _Str.quoted(name) " tab")
            .name("show" name)
            .xs().y()
            .tt("Mostra ou esconde o módulo de " _Str.quoted(name) " no bot", "Show or hide the " _Str.quoted(name) " module in the bot")
            .afterSubmit(this.reloadButton.enable.bind(this.reloadButton))
            .disabled(module.disabled)
            .add()

        if (module.disabled) {
                new _Text().title("(" txt("Incompatível com o cliente atual", "Incompatible with the current client") ")")
                .xadd(1).yp()
                .color("red")
                .add()
        }
    }

    toggleAll()
    {
        value := new _OldBotIniSettings().get("toggleAllModules")

        for _, module in this.modules {
            if (module.disabled) {
                continue
            }

                new _OldBotIniSettings().submit("show" module.name, value)
        }

        Reload()
    }
}
