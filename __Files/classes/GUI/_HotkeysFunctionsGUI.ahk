
Class _HotkeysFunctionsGUI  {

    __New()
    {
        this.functionsList := {}

        this.functionsList.Push("selectedFunctions")
        this.functionsList.Push("fullLightEnabled")
        this.functionsList.Push("cavebotTargeting")


        for key, value in cavebotFunctions
            this.functionsList.Push(value)

        if (!uncompatibleModule("healing")) {
            for key, value in healingFunctions
                this.functionsList.Push(value)
        }

        if (!uncompatibleModule("itemRefill")) {
            for key, value in itemRefillFunctions
                this.functionsList.Push(value)
        }

        if (!uncompatibleModule("reconnect")) {
            for key, value in reconnectFunctions
                this.functionsList.Push(value)
        }

        for key, value in supportFunctions
            this.functionsList.Push(value)

        if (!uncompatibleModule("floorSpy")) {
            this.functionsList.Push("floorSpyEnabled")
            this.functionsList.Push("magnifierEnabled")
        }

        if (!uncompatibleModule("fishing")) {
            this.functionsList.Push("fishingEnabled")
        }

        if (!uncompatibleModule("navigation")) {
            this.functionsList.Push("navigationLeader")
            this.functionsList.Push("navigationFollower")
        }

    }

    createHotkeysFunctionsGUI() {
        global

        gosub, readHotkeys

        Gui, HotkeysFunctionsGUI:Destroy

        Gui, HotkeysFunctionsGUI:+Toolwindow +AlwaysOnTop -Caption +Border

        Gui, HotkeysFunctionsGUI:Add, Pic, xm+310 y3 w20 h20 vHotkeysFunctionsCloseButton gHotkeysFunctionsGUIGuiClose, % ImagesConfig.folder "\GUI\Buttons\close_button.png"


        Gui, HotkeysFunctionsGUI:Add, Pic, x0 y0 0x4000000, Data\Files\Images\GUI\GrayBackground.png
        Gui, HotkeysFunctionsGUI:Font,, Tahoma




        Gui, HotkeysFunctionsGUI:Font, cc0c0c0 Norm
        Gui, HotkeysFunctionsGUI:Add, Text, x10 y5 BackgroundTrans, % txt("Setar hotkeys para ativar/desativar funções.", "Set hotkeys to enable/disable functions.")
        Gui, HotkeysFunctionsGUI:Add, Text, x10 y+7 BackgroundTrans, % "Function"
        Gui, HotkeysFunctionsGUI:Add, Text, x150 yp+0 h18 BackgroundTrans, % "Hotkey"

        Gui, HotkeysFunctionsGUI:Font, cc0c0c0 Bold


        for key, function in this.functionsList
        {
            this.createHotkeyControl(function, A_Index = 1 ? true : false)
        }



        Gui, HotkeysFunctionsGUI:Show, h615 w342, % "Functions Hotkeys"


    }

    createHotkeyControl(function, first := false) {
        global

        functionText := function
        if (function = "CavebotTargeting")
            functionText := "Cavebot+Targeting"


        firstLetter := SubStr(function, 1, 1)
        StringUpper, firstLetter, firstLetter
        StringTrimLeft, functionText, functionText, 1
        functionText := firstLetter "" functionText
        functionText := StrReplace(functionText, "Enabled", "")

        if (first = true)
            Gui, HotkeysFunctionsGUI:Add, Text, x10 y+0 vselectedFunctions_%function% BackgroundTrans, % functionText
        else
            Gui, HotkeysFunctionsGUI:Add, Text, x10 y+5 vselectedFunctions_%function% BackgroundTrans, % functionText
        Gui, HotkeysFunctionsGUI:Add, Hotkey, x150 yp-2 h18 w120 gfunctionHotkeyControl v%function%Hotkey, % %function%Hotkey

        checked := %function%ShortcutCheckbox

        Gui, HotkeysFunctionsGUI:Add, Checkbox, x+5 yp+2 w12 h12 gfunctionCheckboxControl v%function%ShortcutCheckbox Checked%checked%
        Gui, HotkeysFunctionsGUI:Add, Text, x+3 yp+0 h16 +BackgroundTrans, % txt("Mostrar", "Show")

    }


}
