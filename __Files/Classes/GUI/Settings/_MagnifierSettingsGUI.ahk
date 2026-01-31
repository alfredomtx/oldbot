#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_GUI.ahk

Class _MagnifierSettingsGUI extends _GUI
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?string title
    */
    __New()
    {
        base.__New("magnifier", "Magnifier - " lang("settings"))

        this.guiW := 250
        this.textW := 100
        this.editW := 70

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

        this.createControls()

        _AbstractControl.RESET_DEFAULT_GUI()
    }

    /**
    * @return void
    */
    createControls()
    {
        this.textW := 60

            new _Button().title("Tutorial")
            .tt("Tutorial sobre o Magnifier", "Tutorial about the Magnifier")
            .xs().y().h(18)
            .event(Func("openUrl").bind("https://youtu.be/Lk0YQar9aWM"))
            .add()

            new _Text().title("Transparência", "Transparency", ":")
            .xs().y("+8").w(this.textW)
            .option("Right")
            .add()

            new _Slider().name("transparency")
            .x("+5").y("p-3").h(20).w(150)
            .option("Range" _Magnifier.TRANSPARENCY_MIN "-" _Magnifier.TRANSPARENCY_MAX)
            .afterSubmit(_Magnifier.applySetting.bind(_Magnifier))
            .nested("magnifier")
            .prefix("magnifier")
            .state(_SupportSettings)
            .add()

            new _Text().title("Largura", "Width", ":")
            .xs().yadd(10).w(this.textW)
            .option("Right")
            .add()

            new _Slider().name("width")
            .x("+5").y("p-3").h(20).w(150)
            .option("Range" _Magnifier.WIDTH_MIN "-" _Magnifier.WIDTH_MAX)
            .afterSubmit(_Magnifier.applySetting.bind(_Magnifier))
            .nested("magnifier")
            .prefix("magnifier")
            .state(_SupportSettings)
            .add()


            new _Text().title("Altura", "Height", ":")
            .xs().yadd(10).w(this.textW)
            .option("Right")
            .add()

            new _Slider().name("height")
            .x("+5").y("p-3").h(20).w(150)
            .option("Range" _Magnifier.HEIGHT_MIN "-" _Magnifier.HEIGHT_MAX)
            .afterSubmit(_Magnifier.applySetting.bind(_Magnifier))
            .nested("magnifier")
            .prefix("magnifier")
            .state(_SupportSettings)
            .add()

            new _Text().title("Zoom:")
            .xs().yadd(15).w(this.textW)
            .option("Right")
            .add()

        this.zoom := new _Listbox().name("zoom")
            .x("+5").y("p-3").w(150)
            .afterSubmit(_Magnifier.applySetting.bind(_Magnifier))
            .nested("magnifier")
            .prefix("magnifier")
            .state(_SupportSettings)
            .list(this.getZoomList())
            .add()

    }

    /**
    * @return array<_ListOption>
    */
    getZoomList()
    {
        static list
        if (list) {
            return list
        }

        list := {}
        list.Push(new _ListOption(0.5))
        list.Push(new _ListOption(0.6))
        list.Push(new _ListOption(0.7))
        list.Push(new _ListOption(0.8))
        list.Push(new _ListOption(0.9))
        list.Push(new _ListOption(1, true))

        return list
    }
}
