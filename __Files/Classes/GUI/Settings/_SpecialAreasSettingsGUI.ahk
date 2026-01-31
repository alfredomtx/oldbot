
Class _SpecialAreasSettingsGUI extends _GUI
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?string title
    */
    __New()
    {
        base.__New("Special Areas", "Special Areas - " lang("settings"))

        this.guiW := 250
        this.editW := 90

        this.onCreate(this.create.bind(this))
            .y(100).w(this.guiW)
            .withoutMinimizeButton()
        ; .alwaysOnTop()
        ; .withoutWindowButtons()
    }

    /**
    * @abstract
    * @return void
    */
    create()
    {
        _AbstractControl.SET_DEFAULT_GUI(this)
        _AbstractStatefulControl.SET_DEFAULT_STATE(_SpecialAreasIniSettings)

        this.createControls()

        _AbstractControl.RESET_DEFAULT_GUI()
        _AbstractStatefulControl.RESET_DEFAULT_STATE()
    }

    /**
    * @return void
    */
    createControls()
    {
        this.iniSettings()
    }

    iniSettings()
    {
            new _Button().title("Importar arquivo JSON", "Import JSON file")
            .xs().yadd(5)
            .event(_SpecialAreas.importFile.bind(_SpecialAreas))
            .disabled(A_IsCompiled)
            .add()
    }
}
