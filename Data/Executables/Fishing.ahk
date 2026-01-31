/*
OldBot é desenvolvido por Alfredo Menezes, Brasil.
Copyright © 2017. Todos os direitos reservados.

OldBot is developed by Alfredo Menezes, Brazil.
Copyright © 2017. All rights reserved.
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\scripts_start_settings_section.ahk

/*
Includes folder
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Fishing.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ISupport.ahk
/*
handler
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_ItemsHandler.ahk

/*
system
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Cavebot\_CavebotSystem.ahk

/*
others
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Script\_ScriptImages.ahk

/*
module name
*/
global moduleName := "fishing"

/*
main Handler class initializing before hasFunctionEnabled()
*/
global FishingHandler := new _FishingHandler() ; to check hasFunctionEnabled

; msgbox,% OldBotSettings.hasFunctionEnabled(moduleName)
if (A_IsCompiled) {
    if (OldBotSettings.hasFunctionEnabled(moduleName) = false)
        ExitApp
}

PID := _ProcessHandler.writeModuleExePID(moduleName)

; reloads if client is closed
if (TibiaClient.getClientAreaFunctions(StrReplace(A_ScriptName, ".exe", "")) = false)
    return

; OutputDebug(moduleName, "Starting...")

/*
If client is disconnected, loop until it is connected again
or exitapp if tibia window doesn't exist anymore
*/
TibiaClient.isDisconnectedLoopWaitOrExit(moduleName)


/*
initializing classes
*/
global MemoryManager := new _MemoryManager(injectOnStart := true) ; before all other classes
/*
handler
*/
global ItemsHandler := new _ItemsHandler(false, true)

/*
system
*/
global SupportSystem := new _SupportSystem()
global FishingSystem := new _FishingSystem()
global ScriptImages := new _ScriptImages()

/*
others
*/
global ActionScript := new _ActionScript()


/*
initializing functions
*/

try {
    _ClientAreas.setupCommonAreas()
} catch e {
    Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - setupCommonAreas()", % e.Message
    Reload
    return
}

if (FishingPauseHotkey = "") {
    Msgbox, 48,, % "Empty fishing Pause hotkey.`nSet a hotkey and try again", 10
    Reload
    return
}


hotkeyFunc := Func("PauseFishing").bind("")
try Hotkey, %FishingPauseHotkey%, % hotkeyFunc, On
catch e {
    Msgbox, 48,, % "Failed to create fishing pause hotkey.`n- Hotkey: " FishingPauseHotkey, 10
    Reload
    return

}

hotkeyFunc := Func("UnpauseFishing").bind("")
try Hotkey, +%FishingPauseHotkey%, % hotkeyFunc, On
catch e {
    Msgbox, 48,, % "Failed to create fishing unpause hotkey.`n- Hotkey: +" FishingPauseHotkey, 10
    Reload

    return

}

try global CavebotSystem := new _CavebotSystem()
catch e {
    Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - Fishing Setup Init", % e.Message, 10
    Reload
    return
}

/*
loading sprites
*/
itemsArray := {}
itemsArray["fishing rod"] := {}
itemsArray["fish"] := {}
createItemsBitmaps(itemsArray)

/*
after all initial functions loadings
*/
Random, R, 0, 400
SetTimer, VerifyFunctionsFromExe, % 4000 + R
SetTimer, CheckClientClosedMinimized, % 2000 + R


/*
start running module system & functions
*/
Loop, {
    ; if (A_IsCompiled)
    ; && (fishingObj.fishingEnabled = false) {
    if (A_IsCompiled && !fishingObj.fishingEnabled) {
        Sleep, 1000
        continue
    }
    FishingSystem.createSqmPositionsArray()
    Sleep, 100

    FishingSystem.startFishing()
    ; Sleep, 1000
}



return



/*
default labels for all modules
*/
VerifyFunctionsFromExe:
    try CavebotScript.loadSpecificSettingFromExe(moduleName, currentScript, A_ScriptName)
    catch e {
        _Logger.exception(e, A_ThisLabel, currentScript)
    }
return
CheckClientClosedMinimized:
    TibiaClient.isClientClosed(false, moduleName) ; check if client is closed and reload if true
    TibiaClient.isClientMinimized(true)
return
Reload() {
    Reload
    return
}
writeCavebotLog(Status, Text, isError := false) {
    if (FishingSystem.fishingJsonObj.options.debugLog = true)
        OutputDebug(moduleName, Status . " | " . Text)
    return
}

/*
To include ClientAreas
*/
setGameAreas:
return

/*
To include CavebotSystem
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\default_cavebot_functions.ahk


#If (WinActive("ahk_id " . TibiaClientID) OR WinActive("ahk_class AutoHotkeyGUI"))
PauseFishing() {
    Tooltip, % "Fishing paused.`nUnpause: Shift+" . FishingPauseHotkey, WindowX + CHAR_POS_X - (SQM_SIZE / 3), WindowY + CHAR_POS_Y - (SQM_SIZE) - (SQM_SIZE / 4)

    if (WinActive("ahk_id " TibiaClientID))
        Send("Esc")

    Pause
    return
}

UnpauseFishing() {

    Critical, On
    if (A_IsPaused) {
        Pause, Off
        Tooltip
        if (backgroundMouseInput = false OR backgroundKeyboardInput = false)
            WinActivate, ahk_id %TibiaClientID%
    }
    Critical, Off
    return
}
