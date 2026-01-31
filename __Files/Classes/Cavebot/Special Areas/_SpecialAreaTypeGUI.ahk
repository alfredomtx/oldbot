#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_GUI.ahk

Class _SpecialAreaTypeGUI extends _GUI
{
    static INSTANCE

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }


    __New()
    {
        if (_SpecialAreaTypeGUI.INSTANCE) {
            return _SpecialAreaTypeGUI.INSTANCE
        }

        this.coord := coord
        this.area := area

        base.__New("specialAreaType", "Special Area Type")

        this.guiW := 150
        this.guiH := 100
        this.onCreate(this.create.bind(this))
            .w(this.guiW)
            .alwaysOnTop()
        ; .noActivate()
            .toolWindow()
            .withoutMinimizeButton()
        ; .withoutCaption()
        ; .border()

        _SpecialAreaTypeGUI.INSTANCE := this
    }

    /**
    * @param _MapCoordinate coordinate
    * @param _SpecialArea specialArea
    */
    setData(coord, area)
    {
        _Validation.instanceOf("coord", coord, _MapCoordinate)
        _Validation.instanceOf("area", area, _SpecialArea)

        this.coord := coord
        this.area := area

        return this
    }

    open()
    {
        if (this.isCreated()) {
            this.close()
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
            new _Text().title("Tipo:", "Type:")
            .xs().yadd(5)
            .add()

        v := new _SpecialAreasIniSettings().getAttribute("type").getValues()
        r := new _SpecialAreasIniSettings().getAttribute("type").getValues().count()

        this.type := new _Listbox().title(_Arr.concat(new _SpecialAreasIniSettings().getAttribute("type").getValues(), "|"))
            .name("type")
            .xs().yadd(3).w(this.guiW - 20).r(new _SpecialAreasIniSettings().getAttribute("type").getValues().count())
            .add()
            .list(this.getTypeList.bind(this))

            new _Button().title(lang("save"))
            .xs().yadd(5).w(50).h(20)
            .event(this.submitType.bind(this))
            .focused()
            .add()

            new _Button().title(lang("close"))
            .x().yp().w(50).h(20)
            .event(this.close.bind(this))
            .add()
    }

    submitType()
    {
        type := this.type.get()

        _SpecialAreasHUD.DEFAULT_TYPE := type

        this.area.setType(type)

        this.close()
        _SpecialAreas.add(this.area, save := true, addToMain := true)
        this.coord.destroyOnScreen()
        this.coord.showOnScreen(this.area.resolveColor(), this.area.resolveHudText(this.area.getType()))
    }

    /**
    * @return array<_ListOption>
    */
    getTypeList()
    {
        list := {}
        for _, type in new _SpecialAreasIniSettings().getAttribute("type").getValues() {
            list.Push(new _ListOption(type, type = this.area.getType()))
        }

        return list
    }
}
