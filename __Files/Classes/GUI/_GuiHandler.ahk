
Class _GuiHandler {


    submitCheckbox(setting, control, value) {
        value += 0
        this.submitSetting(setting, control, value)
    }

    submitSetting(setting, control, value) {

        /**
        item refill controls that have a array for options
        itemRefillObj.ring.xxx := value
        */

        if value is Number
            value += 0

        ; msgbox, % setting "`n" control "`n" value
        if (InStr(control, "/")) {

            params := StrSplit(control, "/")

            if (params.Count() > 2) {
                OldBotSettings.enableGuisLoading()
                Msgbox, 16, % funcOrigin "." A_ThisFunc, "Too many params in control """ control """:`n" serialize(params)
            }

            ; msgbox, % setting "`n" serialize(params)
            %setting%Obj[params.1][params.2] := value
        } else {
            %setting%Obj[control] := value
        }

        MyBoundFunc := this.MyBoundFunc
        if (MyBoundFunc) {
            SetTimer, %MyBoundFunc%, Delete ; Remove the reference saved in the SetTimer command
        }

        this.MyBoundFunc := this.saveSettingHandler.Bind(this, setting, true)

        MyBoundFunc := this.MyBoundFunc
        SetTimer, %MyBoundFunc%, -500, 99
    }

    validateHotkey(control, htk) {
        vars := this._validateHotkey("CavebotGUI", control, htk)
        if (vars.erro > 0)
            throw Exception(vars.msg)
    }

    _validateHotkey(GUI := "", varname := "", hotkey_ := "") {
        result := []
        result["erro"] := 0
        result["msg"] := ""

        if (hotkey_ = "") {
            return %result%
        }

        try {
            _Validation.hotkey(hotkey_)

        } catch e {
            try {
                if (GUI != "")
                    GuiControl, %GUI%:, %varname%, % ""
                else
                    GuiControl,, %varname%, % ""
            } catch {
            }
            throw e
        }
    }

    saveSettingHandler(setting, saveCavebotScript) {
        ; OutputDebug(A_ThisFunc, setting)
        scriptFile[setting] := %setting%Obj
        if (!saveCavebotScript) {
            return
        }

        ; OldBotSettings.disableGuisLoading()
        CavebotScript.saveSettings(A_ThisFunc "." funcOrigin)
        Sleep, 25
        ; OldBotSettings.enableGuisLoading()
    }

    uncompatibleModuleWarning(y := "+10") {
        Gui CavebotGUI:Font, cRed
        Gui CavebotGUI:Add, Text, x20 y%y%, % txt("Módulo é incompatível com o cliente atual.", "Module is uncompatible with current client.")
        Gui CavebotGUI:Font,
    }

    checkUncompatibleModuleTab() {
        try this.isModuleUncompatible()
        catch e {
            lastTab := selectedTabs[selectedTabs.MaxIndex()]
            if (MainTab = "Cavebot") {
                GuiControl, CavebotGUI:Choose, MainTab, Healing
            } else {
                if (lastTab != "" && lastTab != MainTab)
                    GuiControl, CavebotGUI:Choose, MainTab, % lastTab
                else 
                    GuiControl, CavebotGUI:Choose, MainTab, Cavebot
            }
            Gosub, MainTab
            Msgbox, 64,, % e.Message, 6
            return false
        }
        return true
    }

    tutorialButtonModule(module) {
        Gui, CavebotGUI:Add, Button, % "xm690 y23 w115 h20 gtutorialButton" module " hwndhtutorial" module, % "Tutorial " module
        ; Gui, CavebotGUI:Add, Button, % "xm760 y25 w65 h18 gtutorialButton" module " hwndhtutorial" module, % "Tutorial"
        CavebotGUI.cavebotGUIButtonIcon(htutorial%module%, MenuHandler.youtubeIcon, 0, "a0 l2 b0 s14")
        TT.Add(htutorial%module%, "Tutorial " module)
    }

    toggleFunctionEnabledCheckbox(moduleName, functionName, value) {
        global
        %functionName% := value, %moduleName%Obj[functionName] := value, checkbox_setvalue(functionName "_2", value)
        try GuiControl, CavebotGUI:, % functionName, % value
        catch {
        }
    }
}