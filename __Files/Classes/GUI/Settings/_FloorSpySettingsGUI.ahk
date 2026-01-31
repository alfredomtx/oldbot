#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_GUI.ahk

Class _FloorSpySettingsGUI extends _GUI
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
        if (_FloorSpySettingsGUI.INSTANCE) {
            return _FloorSpySettingsGUI.INSTANCE
        }

        base.__New("floorSpy", "Floor Spy (X-Ray)")

        this.guiW := 300

        this.onCreate(this.create.bind(this))
            .y(100).w(this.guiW)
            ; .onClose(this.onCloseEvent.bind(this))
        ; .withoutMinimizeButton()
        ; .alwaysOnTop()
        ; .noActivate()
        ; .withoutWindowButtons()
        _FloorSpySettingsGUI.INSTANCE := this
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
        global
        y := h_groupspell + 90

        ; Gui, Add, Button, xs+400 ys+25 h25 gShowFloorSpyHotkeysGUI, % "Hotkeys"


        ; if (A_IsCompiled)
        Disabled := (OldBotSettings.uncompatibleModule("floorSpy") = true) ? "Disabled" : ""
        Hidden := (OldBotSettings.uncompatibleModule("floorSpy") = true) ? "Hidden" : ""

            new _ControlFactory(_ControlFactory.HOTKEYS_BUTTON)
            .x().y()
            .event("ShowFloorSpyHotkeysGUI")
            .add()

            new _Text().title("Character floor:")
            .xs(10).yadd(7).w(120)
            .add()
        ; Gui, Add, Text, xs+10 y+7 w120 %Disabled% %Hidden%, % "Character floor:" 
        this.charX := new _Edit().name("charX")
            .xp(0).yadd(5).w(50)
            .readOnly()
            .add()

        this.charY := new _Edit().name("charY")
            .xadd(3).yp().w(50)
            .readOnly()
            .add()

        this.charZ := new _Edit().name("charZ")
            .xadd(3).yp().w(25)
            .readOnly()
            .add()

        Gui, Add, Text, xs+10 y+7 w120 %Disabled% %Hidden%, % "Current spy floor:"

        this.spyX := new _Edit().name("spyX")
            .xp(0).yadd(5).w(50)
            .readOnly()
            .add()

        this.spyY := new _Edit().name("spyY")
            .xadd(3).yp().w(50)
            .readOnly()
            .add()

        this.spyZ := new _Edit().name("spyZ")
            .xadd(3).yp().w(25)
            .readOnly()
            .add()

        xs := 180
        xs2 := xs - 30


        Gui, Add, Button, xs+%xs% ys+30 w65 vspyDirectionFloorUp gspyDirection hwndhspyFloorUp Disabled, % "Floor Up"
        Gui, Add, Button, xs+%xs% y+5 w65 vspyDirectionUp gspyDirection hwndhspyUp Disabled, % "Up"
        Gui, Add, Button, xs+%xs2% y+5 w65 vspyDirectionLeft gspyDirection hwndhspyFloorLeft Disabled, % "Left"
        Gui, Add, Button, x+5 yp+0 w65 vspyDirectionRight gspyDirection hwndhspyFloorRight Disabled, % "Right"
        Gui, Add, Button, xs+%xs% y+5 w65 vspyDirectionDown gspyDirection hwndhspyDown Disabled, % "Down"
        Gui, Add, Button, xp+0 y+5 w65 vspyDirectionFloorDown gspyDirection hwndhspyFloorDown Disabled, % "Floor Down"

        TT.Add(hspyFloorDown, txt("Só é possivel visualizar os andares do subsolo(8 ou menos) estando no 8 ou menos, não é possível ver o 8 ou menos estando no andar 7 ou maior.", "(It is only possible to see the underground floors(8 or less) by in 8 or less, it is not possible to see the 8 or less being on floor 7 or higher.") )
    }
}
