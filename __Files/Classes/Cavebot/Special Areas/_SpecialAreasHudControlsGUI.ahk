#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_GUI.ahk

Class _SpecialAreasHudControlsGUI extends _GUI
{
    static INSTANCE

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?string title
    */
    __New()
    {
        if (_SpecialAreasHudControlsGUI.INSTANCE) {
            return _SpecialAreasHudControlsGUI.INSTANCE
        }

        base.__New("specialAreasHudControls", "Special Areas Controls")

        this.guiW := 150
        this.onCreate(this.create.bind(this))
            .y(35)
            .alwaysOnTop()
            .noActivate()
            .toolWindow()
            .withoutWindowButtons()
        ; .withoutCaption()
        ; .border()

        _SpecialAreasHudControlsGUI.INSTANCE := this
    }

    open()
    {
        if (this.isCreated()) {
            return this
        }

        return base.open()
    }

    /**
    * @abstract
    * @return void
    */
    create()
    {
        _AbstractControl.SET_DEFAULT_GUI(this)
        this.createControls()
        _AbstractControl.RESET_DEFAULT_GUI()
    }

    /**
    * @return void
    */
    createControls()
    {
        mt := 3

            new _Text().title("Enter: " lang("save"))
            .xs().yadd(5)
            .add()

            new _Text().title("Esc: " lang("cancel"))
            .xs().yadd(mt)
            .add()
            new _Text().title(lang("space") ": Add/" lang("toggle"))
            .xs().yadd(mt)
            .add()

            new _Text().title("Shift + " lang("space") ": " lang("remove"))
            .xs().yadd(mt)
            .add()

            new _Text().title("Ctrl + " lang("space") ": " txt("Alterar tipo", "Change type"))
            .xs().yadd(mt)
            .add()
    }
}
