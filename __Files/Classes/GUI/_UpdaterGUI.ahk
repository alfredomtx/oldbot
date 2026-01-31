#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_GUI.ahk

Class _UpdaterGUI extends _GUI
{
    static LOGS_ENABLED := true

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?string title
    */
    __New()
    {
        base.__New("updater", "Updater")

        this.w := 300
        this.textW := 100
        this.editW := 70

        this.onCreate(this.create.bind(this))
            .w(this.w)
            .noActivate()
    }

    /**
    * @abstract
    * @return void
    */
    create()
    {
        this._gui := gui

        _AbstractControl.SET_DEFAULT_GUI(this)

        this.elements()

        _AbstractControl.RESET_DEFAULT_GUI()
    }

    elements()
    {
        autoUpdate := _Launcher.get("autoUpdate")

            new _Text().title("A interface pode ficar irresponsiva durante o update, apenas aguarde.", "The interface may be irresponsive during update, just wait.")
            .xs().y(10).w(this.w - 20)
            .center()
            .color("green")
            .add()

        ;     new _Text().title("Falhas:", "Failed:")
        ;     .xs().y("+10")
        ;     .add()

        ; this.failuresCount := new _Text().title(0)
        ;     .x().yp().w(50)
        ;     .font("bold")
        ;     .color("red")
        ;     .add()

        this.autoUpdate := new _Checkbox().title("Iniciar download automaticamente", "Start download automatically")
            .name("autoUpdate")
            .xs().y("+10")
            .tt("Com essa opção desmarcada, o Launcher não irá iniciar o download dos arquivos automaticamente, você precisará clicar no botão ""Iniciar download"" para iniciar o download dos arquivos sempre que houver atualizações.", "With this option unchecked, the Launcher will not start downloading files automatically, you will need to click the ""Start download"" button to start downloading the files whenever there are updates.")
            .state(_LauncherIniSettings)
            .add()

        this.autoOpen := new _Checkbox().title("Abrir OldBot ao finalizar", "Open OldBot when finished")
            .name("autoOpen")
            .xs()
            .tt("Abrir o OldBot automaticamente ao finalizar o update.", "Open OldBot automatically when finished the update.")
            .state(_LauncherIniSettings)
            .add()

        if (!autoUpdate) {
            this.startDownloadButton := new _Button().title("Iniciar download", "Start download", "   ")
                .name("startDownload")
                .xs().y().w(this.w - 20).h(35)
                .keepDisabled()
                .icon(_Icon.get(_Icon.CLOUD), "a0 l5 b0 s28")
                .event(this.startDownload.bind(this))
                .add()
        }


        if (this.LOGS_ENABLED) {
            this.log := new _Edit().name("log")
                .xs().y().w(this.w - 20).r(5)
                .value(autoUpdate ? txt("Iniciando auto updater...", "Starting auto updater...") : txt("Clique no botão ""Iniciar download"" para iniciar a atualização dos arquivos.", "Click the ""Start download"" button to start the file updates."))
                .option("ReadOnly")
                .option("0x100")
                .add()
        }

        this.progressBar := new _Progress().name("progressBar")
            .xs().y().w(this.w - 20).h(35)
            .add()

        this.progress := new _Text().title(0 "%")
            .xp((this.progressBar.getW() / 2) - 25).yp((this.progressBar.getH() / 2) - 6).w(100)
            .option("BackgroundTrans")
            .add()

        this.updatingText := txt("Atualizando, por favor aguarde...", "Updating, please wait...")

        this.startOldbotButton := new _Button().title(autoUpdate ? this.updatingText : txt("Aguardando inicio do update...", "Waiting to start update...") )
            .xs().y("+17").w(this.w - 20).h(35)
            .focused()
            .disabled()
            .icon(_Icon.get(_Icon.OLDBOT), "a0 l5 b0 s28")
            .event(this.startOldBot.bind(this))
            .add()

        this.reopenButton := new _Button().title("Reabrir Launcher", "Reopen Launcher", "    ")
            .xs().y().w(this.w - 20).h(35)
            .icon(_Icon.get(_Icon.RELOAD), "a0 l5 b0 s28")
            .event(this.reload.bind(this))
            .disabled(autoUpdate)
            .add()
    }

    reload()
    {
        reload
        Sleep, 10000
    }

    startOldBot()
    {
        try {
            _Launcher.openOldBot()
        } catch e {
            _Logger.msgboxException(16, e, "Open OldBot")
        }
    }

    startDownload()
    {
        this.startOldbotButton.set(this.updatingText)

        try {
            _Launcher.performUpdate()
        } catch e {
            _Logger.msgboxException(16, e, "Downloading files")
        }
    }
}
