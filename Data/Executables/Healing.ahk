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
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IHealing.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ISupport.ahk
/*
module's specific classes
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Script\_ScriptImages.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_ItemsHandler.ahk

/*
system
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Cavebot\_CavebotSystem.ahk

/*
others
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Core\_MemoryManager.ahk


/*
module name
*/
global moduleName := "healing"

if (A_IsCompiled) {
    if (OldBotSettings.hasFunctionEnabled(moduleName) = false)
        ExitApp
}

PID := _ProcessHandler.writeModuleExePID(moduleName)
; Process, Priority, %PID%, AboveNormal

; reloads if client is closed
if (TibiaClient.getClientAreaFunctions(StrReplace(A_ScriptName, ".exe", "")) = false)
    return

; OutputDebug(moduleName, "Starting...")

/*
If client is disconnected, loop until it is connected again
or exitapp if tibia window doesn't exist anymore
*/
TibiaClient.isDisconnectedLoopWaitOrExit(moduleName)

global MemoryManager := new _MemoryManager(injectOnStart := true) ; before all other classes
global ClientAreas := new _ClientAreas()
global HealingHandler := new _HealingHandler()
global SupportSystem := new _SupportSystem()


; msgbox, % "healer " serialize(healingObj)
Random, R, 0, 400
SetTimer, VerifyFunctionsFromExe, % 4000 + R
SetTimer, CheckClientClosedMinimized, % 2000 + R

try {
    global HealingSystem := new _HealingSystem()
} catch e {
    Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - Healing Setup Init", % e.Message, 10
    Reload()
    return
}

try {
    _ClientAreas.setupCommonAreas()
} catch e {
    Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - setupCommonAreas()", % e.Message
    Reload
    return
}

if (!clientHasFeature("useItemWithHotkey")) {
    try global CavebotSystem := new _CavebotSystem()
    catch e {
        Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - Healing Setup Init", % e.Message, 10
        Reload
        return
    }

    if (!clientHasFeature("useItemWithHotkey")) {
        global ItemsHandler := new _ItemsHandler(false, true)
    }
}

/*
DISABLED ON 10/06/2023
*/
; SetTimer, SearchLifeBar, 6000

/*
FLOW:
- check life healer
- if life healer doesn't need heal in any rune then check mana heal
- if mana heal doesn't need any heal then check mana train
*/
global healToMaxMana := false

Loop, {
    Sleep, % !HealingSystem.healingJsonObj.options.checkHealingIntervalDelay ? 150 : HealingSystem.healingJsonObj.options.checkHealingIntervalDelay

    if (HealingSystem.isDisconnected()) {
        continue
    }

    try {
        HealingSystem.lifeHealing()
    } catch e {
        _Logger.exception(e, "HealingSystem.lifeHealing()")
    }

    if (healingObj.manaHealingEnabled) {
        Sleep, 50
        /**
        check if mana is below min, if is, must heal until reach max
        */
        if (!HealingSystem.hasManaRule("manaMin")) {
            healToMaxMana := true
        }

        if (healToMaxMana) {
            try {
                HealingSystem.manaHealing()
            } catch e {
                _Logger.exception(e, "HealingSystem.manaHealing()")
            }

            continue ; go back to the beggining to check life healing
        }
    }

    try {
        HealingSystem.manaTrain()
    } catch e {
        _Logger.exception(e, "HealingSystem.manaTrain()")
    }
}

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

SearchLifeBar:
    HealingSystem.findBars(true, A_ThisLabel)
return




#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\default_cavebot_functions.ahk