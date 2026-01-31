/*
OldBot é desenvolvido por Alfredo Menezes, Brasil.
Copyright © 2017. Todos os direitos reservados.

OldBot is developed by Alfredo Menezes, Brazil.
Copyright © 2017. All rights reserved.
*/
;;;;;;;;;;;;;;; EXPERIMENTAL 24/06/22
#WarnContinuableException Off
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\scripts_start_settings_section.ahk
/*
Includes folder
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ISupport.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IHealing.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Targeting.ahk


/*
module name
*/
global moduleName := "support"

/*
main Handler class initializing before hasFunctionEnabled()
*/
global SupportHandler := new _SupportHandler()
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

/*
system
*/
global SupportSystem := new _SupportSystem()
global TargetingSystem := new _TargetingSystem() ; before TargetingHandler
global TargetingHandler := new _TargetingHandler()

/*
others
*/
global AttackSpell := new _AttackSpell()
global ClientAreas := new _ClientAreas()

/*
initializing functions
*/
try {
    global HealingSystem := new _HealingSystem()
} catch e {
    if (e.Message != "") ; if life bars are not found, msgbox_image will already show msgbox and will throw no message
        Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - Healing Setup Init", % e.Message
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

/*
after all initial functions loadings
*/
Random, R, 0, 400
SetTimer, VerifyFunctionsFromExe, % 4000 + R
SetTimer, CheckClientClosedMinimized, % 2000 + R

/*
start running module system & functions
*/

if (supportObj.autoShoot = 1) {
    /**
    check battle list visible
    */
    startAutoShootTimer := true

    if (startAutoShootTimer = true)
        SetTimer, autoShootTimer, 300
}

Sleep, 50

SetTimer, autoEatFoodTimer, % SupportSystem.supportJsonObj.autoEatFood.timerIntervalMs

SetTimer, autoHasteTimer, % SupportSystem.supportJsonObj.autoHaste.timerIntervalMs

Sleep, 50

SetTimer, autoUtamoVitaTimer, % SupportSystem.supportJsonObj.autoHaste.timerIntervalMs

SetTimer, autoBuffSpellTimer, % SupportSystem.supportJsonObj.autoBuffSpell.timerIntervalMs

SetTimer, cureParalyzeTimer, % SupportSystem.supportJsonObj.cureParalyze.timerIntervalMs

SetTimer, curePoisonTimer, % SupportSystem.supportJsonObj.curePoison.timerIntervalMs

Sleep, 200

SetTimer, cureFireTimer, % SupportSystem.supportJsonObj.cureFire.timerIntervalMs

Sleep, 200

SetTimer, cureCurseTimer, % SupportSystem.supportJsonObj.cureCurse.timerIntervalMs

return

cureCurseTimer:
    try {
        SupportSystem.autoSpell("cureCurse", supportObj.cureCurseHotkey, "", "", hotkeyIfFound := true, hotkeyTwice := false)
    } catch e {
        _Logger.exception(e, A_ThisLabel)
    }
return

cureFireTimer:
    try {
        SupportSystem.autoSpell("cureFire", supportObj.cureFireHotkey, "", "", hotkeyIfFound := true, hotkeyTwice := false)
    } catch e {
        _Logger.exception(e, A_ThisLabel)
    }
return

curePoisonTimer:
    try {
        SupportSystem.autoSpell("curePoison", supportObj.curePoisonHotkey, "", "", hotkeyIfFound := true, hotkeyTwice := false)
    } catch e {
        _Logger.exception(e, A_ThisLabel)
    }
return

cureParalyzeTimer:
    try {
        SupportSystem.autoSpell("cureParalyze", supportObj.cureParalyzeHotkey, "", "", hotkeyIfFound := true, hotkeyTwice := false)
    } catch e {
        _Logger.exception(e, A_ThisLabel)
    }
return

autoBuffSpellTimer:
    if (supportObj.autoBuffSpell = 0)
        return
    if (isDisconnected()) {
        Sleep, 2000
        return
    }
    Sleep, 100
    try {
        SupportSystem.autoSpell("autoBuffSpell", supportObj.autoBuffSpellHotkey, supportObj.autoBuffSpellPZ, supportObj.autoBuffSpellChatOn, hotkeyIfFound := false, hotkeyTwice := false)
    } catch e {
        _Logger.exception(e, A_ThisLabel)
    }
return

autoUtamoVitaTimer:
    if (supportObj.autoUtamoVita = 0)
        return
    if (isDisconnected()) {
        Sleep, 2000
        return
    }
    try {
        SupportSystem.autoSpell("autoUtamoVita", supportObj.utamoVitaHotkey, supportObj.autoUtamoVitaPZ, supportObj.autoUtamoVitaChatOn, hotkeyIfFound := false, hotkeyTwice := true)
    } catch e {
        _Logger.exception(e, A_ThisLabel)
    }
return

autoHasteTimer:
    if (supportObj.autoHaste = 0)
        return
    if (isDisconnected()) {
        Sleep, 2000
        return
    }
    try {
        SupportSystem.autoSpell("autoHaste", supportObj.hasteSpellHotkey, supportObj.autoHastePZ, supportObj.autoHasteChatOn, hotkeyIfFound := false, hotkeyTwice := false)
    } catch e {
        _Logger.exception(e, A_ThisLabel)
    }
return

autoShootTimer:
    if (supportObj.autoShoot = 0)
        return
    if (supportObj.autoShootHotkey = "")
        return

    if (supportObj.autoShootWhenAttacking = 1) {
        try {
            if (new _IsAttacking().notFound())
                return
        } catch {
            SupportSystem.throwSupportError(A_ThisLabel, e.Message " | " e.What)
            return
        }
    }

    try {
        if (new _HasCooldown("attack")) {
            return
        }
    } catch {
        SupportSystem.throwSupportError(A_ThisLabel, e.Message " | " e.What)
        return
    }
    Send(supportObj.autoShootHotkey)
return

autoEatFoodTimer:
    ; msgbox, % supportObj.autoEatFood "`n" serialize(supportObj)
    if (supportObj.autoEatFood = 0)
        return

    eatFoodHotkey := new _SupportSettings().get("hotkey", "eatFood")
    if (eatFoodHotkey = "")
        return
    if (SupportSystem.checkTargetingRunningCondition("autoEatFood") = false)
        return
    if (SupportSystem.imageSearchStatusBar(SupportSystem.supportJsonObj.autoEatFood.statusBarImage, SupportSystem.supportJsonObj.autoEatFood.variation) = false)
        return

    Send(eatFoodHotkey)
    Send(eatFoodHotkey)
    Sleep, 1500
    /**
    if the image is still appearing after 1 press, it means there is no food to eat
    */
    if (SupportSystem.imageSearchStatusBar(SupportSystem.supportJsonObj.autoEatFood.statusBarImage,SupportSystem.supportJsonObj.autoEatFood.variation) = true) {
        Sleep, 10000
        return
    }
    Loop, 2 {
        Send(eatFoodHotkey)
        Random, R, 1000, 1200
        Sleep, % R
    }

return

/*
default labels/functions for all modules
*/
VerifyFunctionsFromExe:
    try CavebotScript.loadSpecificSettingFromExe(moduleName, currentScript, A_ScriptName)
    catch e {
        if (!A_IsCompiled) {
            _Logger.exception(e, A_ThisLabel, currentScript)
        }
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

/*
to include TargetingSystem
*/
countIgnoredTargetingTimer:
countCreatureNotReachedTimer:
countAttackingCreatureTimer:
getMonsterPosition:
CooldownExeta:
return

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\default_cavebot_functions.ahk
