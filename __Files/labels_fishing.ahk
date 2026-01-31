


FishingEnabled:
    Gui, CavebotGUI:Submit, NoHide
    Gui, CavebotGUI:Default

    switch fishingEnabled {
        case true:
            FishingHandler.enableFishing()
        case false:
            FishingHandler.disableFishing()
    }

return

SetFishingSqms:
    FishingGUI.selectFishingSqms()
return

ResetFishingSQMs:
    FishingHandler.resetFishingSqms()
return

SubmitFishingOption:
    Sleep, 200
    Gui, CavebotGUI:Submit, NoHide

    switch A_GuiControl {
        case "fishingRodHotkey":
            vars := ValidateHotkey("CavebotGUI", A_GuiControl, %A_GuiControl%)
            if (vars.erro > 0) {
                msgbox, 48,, % vars.msg
                return
            }
    }

    _GuiHandler.submitSetting("fishing", A_GuiControl, %A_GuiControl%)

    switch A_GuiControl {
        case "fishingDelay":
            validateInput%A_GuiControl% := Func("validateFishingInput").bind(A_GuiControl, 200, 99999, "SubmitFishingOption")
            SetTimer, % validateInput%A_GuiControl%, Delete
            SetTimer, % validateInput%A_GuiControl%, -800
    }

return

validateFishingInput(EditControl, MinValue, MaxValue, gLabel := "") {
    CheckEditValue(EditControl, MinValue, MaxValue, "CavebotGUI", gLabel)
    return
}

ClickOnFishingSQM:
    FishingGUI.toggleFishingSqms()
return

FinishSelectedFishingSqms:
    FishingHandler.saveSelectedFishingSqms()
return

CancelSelectFishingSqms:
    FishingGUI.toggleAllHotkeysOff()
return

fishingPauseHotkey:
    GuiControlGet, fishingPauseHotkey
    IniWrite, %fishingPauseHotkey%, %DefaultProfile%, fishing_settings, fishingPauseHotkey
return

#if (clickHotkeyOn = true) && (WinActive("ahk_class AutoHotkeyGUI") || WinActive("ahk_class " _App.GUI_CLASS) OR WinActive("ahk_id " TibiaClientID))
~LButton::
    FishingGUI.toggleFishingSqms()
return
#if

#if (escHotkeyOn = true)
Esc::
    FishingGUI.finishSelectedFishingSqms()
return
#if

#if (enterHotkeyOn = true)
Enter::
    FishingGUI.saveSelectedFishingSqms()
return
#if

tutorialButtonFishing:
    openURL(LinksHandler.Fishing.tutorial)
return