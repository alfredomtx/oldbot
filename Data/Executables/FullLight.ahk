/*__Files\Classes\Full Light\_FullLigh
OldBot é desenvolvido por Alfredo Menezes, Brasil.
Copyright © 2017. Todos os direitos reservados.

OldBot is developed by Alfredo Menezes, Brazil.
Copyright © 2017. All rights reserved.
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\scripts_start_settings_section.ahk

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_FullLight.ahk
/*
Includes folder
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ISupport.ahk

/*
module name
*/
global moduleName := "fullLight"

/*
main Handler class initializing before hasFunctionEnabled()
*/
global FullLightHandler := new _FullLightHandler() ; to check hasFunctionEnabled

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
If client is disconnected, loop until it is c,nnected again
or exitapp if tibia window doesn't exist anymore
*/
TibiaClient.isDisconnectedLoopWaitOrExit(moduleName)

/*
others
*/
global MemoryManager := new _MemoryManager(injectOnStart := true)


global tibiaClientIdentifier := TibiaClient.getClientIdentifier(memoryIdentifier := true)


/*
after all initial functions loadings
*/
Random, R, 0, 400
SetTimer, VerifyFunctionsFromExe, % 4000 + R
SetTimer, CheckClientClosedMinimized, % 2000 + R


global DEBUG := !A_IsCompiled


/*
start running module system & functions
*/
global lightSqms
Loop {
    if (A_IsCompiled) {
        if (fullLightObj.fullLightEnabled = 0)
            ExitApp
    }
    Sleep, % fullLightObj.fullLightDelay

    ; if (debug)
    ;     msgbox, % tibiaClientIdentifier

    if (checkClient() = false)
        return

    lightSqms := (fullLightObj.fullLightSqms < 1 OR fullLightObj.fullLightSqms > 11) ? 11 : fullLightObj.fullLightSqms
    value := getLightSqmsValue()
    ; if (debug)
    ; msgbox,% "value = " value
    if (value = "")
        return

    currentLight := _FullLight.getCurrentLightValue()


    if (currentLight = value)
        continue

    _FullLight.writeMemory(value)
}

checkClient() {
    WinGet, TibiaProcess, PID, ahk_id %TibiaClientID%
    if (TibiaProcess = """" OR TibiaProcess = 0)
        return false
    if (TibiaClient.isClientClosed() = true)
        return false
    return true
}

getLightSqmsValue() {
    value := ""
    switch (tibiaClientIdentifier) {
        case "medivia":
            value := getLightValueMedivia(lightSqms)
        case "imperianic":
            value := getLightValueImperianic(lightSqms)
        case "fossil":
            value := "52751"
        case "odenia":
        case "Project Fibula":
            value := MemoryManager.LightPointerValues.value
        case "ShadeCores", case "retrocores", case "rivalia", case "Hardgaard":
            value  := 15
        default:
            ; msgbox, % tibiaClientIdentifier
            value := getLightValueNostalrius(lightSqms)
    }
    return value

}

getLightValueNostalrius(lightSqms) {

    switch fullLightObj.fullLightEffect {
        case "Spell": lightEffect := 727
        case "Torch": lightEffect := 717
        case "Red": lightEffect := 707
        default: lightEffect := 727
    }

    value := lightEffect + (256 * lightSqms - 1)

    return value

}

getLightValueImperianic(lightSqms) {
    return 4056
}

getLightValueMedivia(lightSqms) {
    lightSqms := 11

    value := 52740 + (1 * lightSqms) - 1
    ; msgbox,% "lightSqms = " lightSqms ", value = " value
    return value

}





/*
default labels/functions for all modules
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
    return
}
