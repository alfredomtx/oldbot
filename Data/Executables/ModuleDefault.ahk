/*__Files\Classes\Hotkeys\_Hotkeys__Files\Classes\Hotkeys\_Hotkeys
OldBot é desenvolvido por Alfredo Menezes, Brasil.
Copyright © 2017. Todos os direitos reservados.

OldBot is developed by Alfredo Menezes, Brazil.
Copyright © 2017. All rights reserved.
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\scripts_start_settings_section.ahk

/*
handler
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_HotkeysHandler.ahk

/*
system
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_HotkeysSystem.ahk

/*
others
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Script\_ScriptImages.ahk

/*
libs
*/

/*
module name
*/
global moduleName := "hotkeys"

/*
main Handler class initializing before hasFunctionEnabled()
*/
global HotkeysHandler := new _HotkeysHandler() ; to check hasFunctionEnabled

; if (A_IsCompiled) {
if (OldBotSettings.hasFunctionEnabled(moduleName) = false)
    ExitApp
; }

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
/*
handler
*/
global LootingHandler := new _LootingHandler()

/*
system
*/
global HotkeysSystem := new _HotkeysSystem()
global ScriptImages := new _ScriptImages()

/*
others
*/


/*
initializing functions
*/












/*
after all initial functions loadings
*/
Random, R, 0, 400
SetTimer, VerifyFunctionsFromExe, % 4000 + R
SetTimer, CheckClientClosedMinimized, % 2000 + R


/*
start running module system & functions
*/


return









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






















