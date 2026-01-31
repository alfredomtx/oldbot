/*
OldBot é desenvolvido por Alfredo Menezes, Brasil.
Copyright © 2017. Todos os direitos reservados.

OldBot is developed by Alfredo Menezes, Brazil.
Copyright © 2017. All rights reserved.
*/
;;;;;;;;;;;;;;; EXPERIMENTAL 13/05/22
#WarnContinuableException Off

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\scripts_start_settings_section.ahk
/*
Includes folder
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IHealing.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Item Refill.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ISupport.ahk

/*
handler
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_ItemsHandler.ahk

/*
others
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Core\_MemoryManager.ahk


/*
module name
*/
global moduleName := "itemRefill"

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
global SupportHandler := new _SupportHandler()

/*
system
*/
global ItemRefillSystem := new _ItemRefillSystem()
global SupportSystem := new _SupportSystem()

/*
others
*/

/*
initializing functions
*/
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

itemsArray := {}

/*
functions
*/

if (ItemRefillSystem.itemRefillJsonObj.options.equipItemMode = "mouse") OR (itemRefillObj.quiverRefillEnabled = 1 OR itemRefillObj.distanceWeaponRefillEnabled = 1) {
    /**
    create item bitmaps
    */
    itemsArray[itemRefillObj.ring.itemToEquip] := {}
    itemsArray[itemRefillObj.amulet.itemToEquip] := {}
    itemsArray[itemRefillObj.boots.itemToEquip] := {}
    itemsArray[itemRefillObj.distanceWeapon.itemToEquip] := {}
    itemsArray[itemRefillObj.quiver.ammunition] := {}

}

global ItemsHandler := new _ItemsHandler(false, true)
createItemsBitmaps(itemsArray)

if (itemRefillObj.quiverRefillEnabled = 1) {
    errorQuiver := false
    if (itemRefillObj.quiver.quiver = "") {
        errorQuiver := true
        Msgbox, 48,, % "No quiver selected."
    }
    if (itemRefillObj.quiver.equipMode = "hotkey") && (itemRefillObj.quiver.ammoHotkey = "") {
        errorQuiver := true
        Msgbox, 48,, % "No quiver ammo hotkey selected."
    }
    if (itemRefillObj.quiver.equipMode = "mouse") && (itemRefillObj.quiver.ammunition = "") {
        errorQuiver := true
        Msgbox, 48,, % "No quiver ammunition selected."
    }
}

if (itemRefillObj.distanceWeaponRefillEnabled = 1) {
    errorDistanceWeapon := false
    switch ItemRefillSystem.itemRefillJsonObj.options.equipItemMode {
        case "mouse":
            if (itemRefillObj.distanceWeapon.itemToEquip = "") {
                errorDistanceWeapon := true
                Msgbox, 48,, % "No distance weapon ammunition selected."
            }
        default:
            if (itemRefillObj.distanceWeapon.hotkey = "") {
                errorDistanceWeapon := true
                Msgbox, 48,, % "No quiver distance weapon hotkey selected."
            }
    }
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

SetTimer, quiverRefillTimer, % ItemRefillSystem.itemRefillJsonObj.quiver.timerIntervalMs
Sleep, 200
; msgbox, % serialize(ItemRefillSystem.itemRefillJsonObj.distanceWeapon)

SetTimer, distanceWeaponRefillTimer, % ItemRefillSystem.itemRefillJsonObj.distanceWeapon.timerIntervalMs
Sleep, 200

SetTimer, ringRefillTimer, % ItemRefillSystem.itemRefillJsonObj.ring.timerIntervalMs
Sleep, 200

SetTimer, amuletRefillTimer, % ItemRefillSystem.itemRefillJsonObj.amulet.timerIntervalMs
Sleep, 200

SetTimer, bootsRefillTimer, % ItemRefillSystem.itemRefillJsonObj.boots.timerIntervalMs

return

/*
timer functions secion
*/
quiverRefillTimer:
    ItemRefillSystem.quiverRefill()
return

distanceWeaponRefillTimer:
    ItemRefillSystem.distanceWeaponRefill()
return

ringRefillTimer:
    if (!itemRefillObj.ringRefillEnabled) {
        return
    }

    ItemRefillSystem.checkRefillItem("ring")
return

amuletRefillTimer:
    if (!itemRefillObj.amuletRefillEnabled) {
        return
    }

    ItemRefillSystem.checkRefillItem("amulet")
return

bootsRefillTimer:
    if (!itemRefillObj.bootsRefillEnabled) {
        return
    }

    ItemRefillSystem.checkRefillItem("boots")
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


#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\default_cavebot_functions.ahk
