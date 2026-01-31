
Class _AbstractSettingsGUI extends _BaseClass
{
    __New(settingsFilePath)
    {
        ; _Validation.fileExists("settingsFilePath", settingsFilePath)

        this.settingsFilePath := settingsFilePath

        this.guiWidth := 300
        this.guiHeight := 300

        this.firstTitlePaddingTop := 10
        this.titlePaddingDown := 15
        this.buttonSize := 35
    }

    /**
    * @abstract
    * @param _GUI gui
    * @return void
    */
    create(gui)
    {
        this.gui := gui

        _AbstractControl.SET_DEFAULT_GUI(this.gui)

        ; this.addFilter()
        this.createControls()

        _AbstractControl.RESET_DEFAULT_GUI()
    }

    createControls()
    {
        abstractMethod()
    }

    addFilter()
    {
            new _Button()
            .name("openFile")
            .x(10).yp(-1).w(this.buttonSize).h(this.buttonSize)
            .tt("Abrir o arquivo de configurações", "Open the settings file", ":`n`n" A_WorkingDir "\" this.settingsFilePath)
            .icon(_Icon.get(_Icon.OPEN_FILE), icon := "a0 l3 b0 s22")
            .event(this.openSettingsFile.bind(this))
            .add()

            new _Button()
            .name("closeAllWindows")
            .xadd(3).yp().w(this.buttonSize).h(this.buttonSize)
            .tt("Fechar todas as janelas de configurações", "Close all settings windows")
            .icon(_Icon.get(_Icon.DELETE_ROUND), icon)
            .event(this.closeAllWindows.bind(this))
            .add()

            new _Button()
            .name("closeWindow")
            .xadd(3).yp().w(this.buttonSize).h(this.buttonSize)
            .tt("Fechar janela atual", "Close current window", "`n[ Esc ]")
            .icon(_Icon.get(_Icon.DELETE), icon)
            .event(this.gui.close.bind(this.gui))
            .add()
    }

    closeAllWindows()
    {
            new _OldBotSettingsGUI().gui.close()
            new _ProfileSettingsGUI().gui.close()
    }

    openSettingsFile()
    {
        try {
            Run, % this.settingsFilePath
        } catch e {
            _Logger.msgboxException(48, txt("Falha ao abrir o arquivo", "Failed to open file") ":`n`n" this.settingsFilePath, A_ThisFunc)
        }
    }

    title(title, y := 20)
    {
            new _Text().title(title)
            .x(10).yadd(y)
            .section()
            .font("bold")
            .font("s13")
        ; .color("gray")
            .add()
    }

    calculateDefaultY(y, h, offsetY := 0)
    {
        return y ? y + offsetY : (A_ScreenHeight / 2) - (h / 2)
    }

    calculateDefaultX(x, w, offsetX := 0)
    {
        return x ? x + offsetX : (A_ScreenWidth / 2) + (w / 2)
    }
}
