#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_GUI.ahk

class _CavebotHUD extends _GUI
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?string title
    */
    __New()
    {
        base.__New("cavebotLogs", "Cavebot Logs")

        this.guiW := 180
        this.textW := 100
        this.editW := 70

        this.onCreate(this.create.bind(this))
            .y(10).w(this.guiW)
        ; .withoutMinimizeButton()
            .alwaysOnTop()
            .noActivate()
        ; .withoutWindowButtons(

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

        this.setTimers()
    }

    timer()
    {
    }

    /**
    * @return void
    */
    createControls()
    {
    }


    ;#region Getters
    getWindowTitle()
    {
        static title
        if (title) {
            return title
        }

        return title := "Cavebot Logs (" _Version.getDisplayVersion() ")"
    }
    ;#endregion

    ;#region Setters
    setTimers()
    {
        this.timers := {}

        fn := this.timer.bind(this)
        this.timers.Push(fn)

        SetTimer, % fn, Delete
        SetTimer, % fn, 1000
    }
    ;#endregion

    ;#region Predicates
    ;#endregion
}