
Class _ProgressGUI extends _GUI
{
    static INSTANCE

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?string title
    */
    __New(title := "Progress")
    {
        base.__New("progress", title)

        this.onCreate(this.create.bind(this))
            .y(10).w(250)
            .onCreateValidations(this.validations.bind(this))
            .alwaysOnTop()
            .withoutWindowButtons()
            .noActivate()

        this.showSteps := true
    }

    hideSteps()
    {
        this.showSteps := false

        return this
    }

    /**
    * @param string text
    * @return this
    */
    text(text)
    {
        this._text := text
        return this
    }

    /**
    * @abstract
    ; * @return void
    */
    create()
    {
        _AbstractControl.SET_DEFAULT_GUI(this)

        this.createControls()

        _AbstractControl.RESET_DEFAULT_GUI()
    }

    /**
    * @throws
    */
    validations()
    {
        _Validation.number("this.getW()", this.getW())
    }

    createControls()
    {
        if (this._text) {
            this.text := new _Text().title(this._text)
                .x(10).y()
                .add()
        }

        this.progressBar := new _Progress().name("progressBar")
            .x(10).y().w(this.getW() - 20).h(35)
            .add()

        this.progress := new _Text().title(0 "%")
            .xp((this.progressBar.getW() / 2) - (this.showSteps ? 25 : 10)).yp((this.progressBar.getH() / 2) - 6).w(100)
            .option("BackgroundTrans")
            .add()
    }

    /**
    * @param string text
    * @return void
    */
    updateText(text)
    {
        this.text.set(text)
    }

    /**
    * @param int current
    * @param int total
    * @return void
    */
    updateProgress(current, total)
    {
        p := percentage(current, total)
        this.progressBar.setProgress(p)
        this.progress.set(p " % " (this.showSteps ? "(" current "/" total ")" : "") )
    }
}
