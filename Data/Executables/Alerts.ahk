/*_Files\Classes\Targeting\_Targeting_Files\Classes\Targeting\_Targeting
OldBot é desenvolvido por Alfredo Menezes, Brasil.
Copyright © 2017. Todos os direitos reservados.

OldBot is developed by Alfredo Menezes, Brazil.
Copyright © 2017. All rights reserved.
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\scripts_start_settings_section.ahk


/*
Includes folder
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Alerts.ahk

/*
module's specific classes
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Telegram.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Thread\_ThreadManager.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Support\_SupportHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Targeting\_TargetingHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Script\_ScriptImages.ahk

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Cavebot\_CavebotSystem.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Support\_SupportSystem.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Targeting\_TargetingSystem.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Executables\_CavebotExe.ahk

/*
module name
*/
global moduleName := "alerts"

/*
main Handler class initializing before hasFunctionEnabled()
*/
global AlertsHandler := new _AlertsHandler() ; to check hasFunctionEnabled

; if (A_IsCompiled) {
if (OldBotSettings.hasFunctionEnabled(moduleName) = false)
    ExitApp
; }

PID := _ProcessHandler.writeModuleExePID(moduleName)

; reloads if client is closed
if (TibiaClient.getClientAreaFunctions(StrReplace(A_ScriptName, ".exe", "")) = false)
    return

; OutputDebug(moduleName, "Starting (delay " alertsObj.settings.delay ")...")

/*
If client is disconnected, loop until it is connected again
or exitapp if tibia window doesn't exist anymore
*/
TibiaClient.isDisconnectedLoopWaitOrExit(moduleName)

global MemoryManager := new _MemoryManager(injectOnStart := true) ; before all other classes

global SupportSystem := new _SupportSystem()
global TargetingSystem := new _TargetingSystem() ; before TargetingHandler

global AlertsSystem := new _AlertsSystem()
global SupportHandler := new _SupportHandler()
global TargetingHandler := new _TargetingHandler()
global TelegramAPI := new _Telegram()
global ThreadManager := new _ThreadManager()
global ScriptImages := new _ScriptImages()

try global CavebotSystem := new _CavebotSystem()
catch e {
    Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - Alerts Setup Init", % e.Message, 10
    Reload
    return
}

try {
    _ClientAreas.setupCommonAreas()
} catch e {
    Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - setupCommonAreas()", % e.Message
    Reload
    return
}

Random, R, 0, 400
SetTimer, VerifyFunctionsFromExe, % 4000 + R
SetTimer, CheckClientClosedMinimized, % 2000 + R

TargetingSystem.startTargetingCavebotSetup()

IniDelete, %DefaultProfile%, cavebot, CurrentWaypointTab

; msgbox, % serialize(alertsObj)

Loop, {
    Sleep, 200
    for alertName, alertAtributes in alertsObj
    {
        Sleep, % alertsObj.settings.delay
        switch (alertName) {
            case "settings":
                continue

            case "Disconnected":
                if (!OldBotSettings.settingsJsonObj.disconnectedCheck.enabled) {
                    continue
                }

            case "Player on Battle List":
                if (isNotTibia13()) {
                    continue
                }
        }

        if (!alertsObj[alertName].enabled) {
            alertsSystemObj[alertName].labelTriggered := false
            Sleep, 25
            continue
        }

        try {
            if (InStr(alertName, "Image is found")) {
                AlertsSystem.alertImageIsFound(alertName)
                Sleep, % alertsObj.settings.delay
                AlertsSystem.checkUnpauseCavebot(alertName)
                continue
            } else if (InStr(alertName, "Image is not found")) {
                AlertsSystem.alertImageIsNotFound(alertName)
                Sleep, % alertsObj.settings.delay
                AlertsSystem.checkUnpauseCavebot(alertName)
                continue
            }

            switch alertName {
                case "Battle list not empty":
                    AlertsSystem.alertBattleListNotEmpty(alertName)
                case "Character stuck":
                    AlertsSystem.alertCharacterStuck(alertName)
                case "Disconnected":
                    AlertsSystem.alertDisconnected(alertName)
                case "Not listed target":
                    AlertsSystem.alertNotListedTarget(alertName)
                case "PK on screen":
                    AlertsSystem.alertPkOnScreen(alertName)
                case "Player on Battle List":
                    AlertsSystem.alertPlayerOnBattleList(alertName)
                case "Private message":
                    AlertsSystem.alertPrivateMessage(alertName)
            }
        } catch e {
            _Logger.exception(e, alertName)
        }

        Sleep, % alertsObj.settings.delay

        AlertsSystem.checkUnpauseCavebot(alertName)
    }
}

return

messageTimer:
    AlertsSystem.incrementMessageTime()
return

screenshotTimer:
    AlertsSystem.incrementScreenshotTime()
return


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

/*
to include CavebotSystem
*/
Reload() {
    Reload
    return
}

writeCavebotLog(Status, Text, isError := false) {
    return
}


/*
To include TargetingSystem
*/
setGameAreas:
countCreatureNotReachedTimer:
countIgnoredTargetingTimer:
countAttackingCreatureTimer:
getMonsterPosition:
CooldownExeta:
return


#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\default_cavebot_functions.ahk