/*_Files\Classes\Targeting\_Targeting
OldBot é desenvolvido por Alfredo Menezes, Brasil.
Copyright © 2017. Todos os direitos reservados.

OldBot is developed by Alfredo Menezes, Brazil.
Copyright © 2017. All rights reserved.
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\scripts_start_settings_section.ahk
/*
Includes folder
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IActionScripts.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Persistent.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IHealing.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ILooting.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Sio.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ISupport.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Targeting.ahk

/*
handler
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_ItemsHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Waypoint\_WaypointHandler.ahk

/*
system
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Cavebot\_CavebotSystem.ahk

/*
others
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Cavebot\_CavebotWalker.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Script\_ScriptImages.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Telegram.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Thread\_ThreadManager.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Waypoint\_WaypointValidation.ahk


/*
module name
*/
global moduleName := "persistent"

/*
main Handler class initializing before hasFunctionEnabled()
*/
global PersistentHandler := new _PersistentHandler() ; to check hasFunctionEnabled

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
global MemoryManager := new _MemoryManager(injectOnStart := true) ; before all other classes

/*
handler
*/
global ItemsHandler := new _ItemsHandler(true, true)

/*
system
*/
global CavebotSystem := new _CavebotSystem()
global LootingSystem := new _LootingSystem()
global PersistentSystem := new _PersistentSystem()
global SupportSystem := new _SupportSystem()
global TargetingSystem := new _TargetingSystem()

/*
others
*/
global ClientAreas := new _ClientAreas()
global ScriptImages := new _ScriptImages()
global TelegramAPI := new _Telegram()
global ThreadManager := new _ThreadManager()



global ActionScript := new _ActionScript()
global ActionScriptHandler := new _ActionScriptHandler()
global CavebotWalker := new _CavebotWalker(loadMinimapFiles := false)
global WaypointHandler := new _WaypointHandler()

/*
for closeCavebot
*/
IniRead, cavebotExeName, %DefaultProfile%, settings, cavebotExeName, Cavebot.exe

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

TargetingSystem.startTargetingCavebotSetup()

/*
loading sprites
*/
itemsArray := {}
for persistentID, atributes in persistentObj
{
    if (atributes.action = "" OR atributes.action = "none")
        continue

    itemName := PersistentSystem.getUserValuePersistent(persistentID, "item")
    if (empty(itemName)) {
        continue
    }

    itemsArray[itemName] := {}
}

createItemsBitmaps(itemsArray)

PersistentSystem.createPersistentActionScriptsVariablesObj()

IniDelete, %DefaultProfile%, others_cavebot, CavebotClickingOnMinimap


/*
after all initial functions loadings
*/
Random, R, 0, 400
SetTimer, VerifyFunctionsFromExe, % 4000 + R
SetTimer, CheckClientClosedMinimized, % 2000 + R


/*
start running module system & functions
*/
clientWindowID := ""
for persistentID, atributes in persistentObj
{
    if (atributes.enabled = 0)
        continue
    if (atributes.action = "" OR atributes.action = "none")
        continue
    if (atributes.interval < 1) && (!InStr(atributes.interval, "0."))
        continue

    ; msgbox, % serialize(atributes)
    ; clientWindowID := PersistentSystem.getUserValuePersistent(persistentID, "clientID")


    switch atributes.action {
        case "Action Script", case "Action Script (BETA)":
            persistentTimer := Func("actionScriptTimer").bind(persistentID, clientWindowID)
        case "Click on position":
            button := PersistentSystem.getUserValuePersistent(persistentID, "button")
            control := PersistentSystem.getUserValuePersistent(persistentID, "holdCtrl")
            persistentTimer := Func("clickOnPositionTimer").bind(persistentID, button, control, clientWindowID)
        case "Click on image":
            image := PersistentSystem.getUserValuePersistent(persistentID, "image")
            button := PersistentSystem.getUserValuePersistent(persistentID, "button")
            variation := PersistentSystem.getUserValuePersistent(persistentID, "variation")
            control := PersistentSystem.getUserValuePersistent(persistentID, "holdCtrl")
            persistentTimer := Func("clickOnImageTimer").bind(persistentID, image, button, control, variation)
        case "Convert gold":
            persistentTimer := Func("convertGoldTimer").bind(persistentID)
        case "Dance (anti-idle)":
            persistentTimer := Func("antiIdleTimer").bind(persistentID, clientWindowID)
        case "Go to label if itemcount":
            label := PersistentSystem.getUserValuePersistent(persistentID, "label")
            item := PersistentSystem.getUserValuePersistent(persistentID, "item")
            condition := PersistentSystem.getUserValuePersistent(persistentID, "condition")
            value := PersistentSystem.getUserValuePersistent(persistentID, "value")
            persistentTimer := Func("goToLabelItemCountTimer").bind(persistentID, label, item, condition, value)
        case "Press hotkey":
            hotkey := PersistentSystem.getUserValuePersistent(persistentID, "hotkey")
            persistentTimer := Func("pressHotkeyTimer").bind(persistentID, hotkey, clientWindowID)
        case "Press hotkey if image is found":
            hotkey := PersistentSystem.getUserValuePersistent(persistentID, "hotkey")
            image := PersistentSystem.getUserValuePersistent(persistentID, "image")
            variation := PersistentSystem.getUserValuePersistent(persistentID, "variation")
            persistentTimer := Func("pressHotkeyIfImageIsFoundTimer").bind(persistentID, hotkey, image, variation)
        case "Press hotkey if image":
            condition := PersistentSystem.getUserValuePersistent(persistentID, "condition")
            hotkey := PersistentSystem.getUserValuePersistent(persistentID, "hotkey")
            image := PersistentSystem.getUserValuePersistent(persistentID, "image")
            variation := PersistentSystem.getUserValuePersistent(persistentID, "variation")
            persistentTimer := Func("pressHotkeyIfImageTimer").bind(persistentID, condition, hotkey, image, variation)
        case "Run file":
            directory := PersistentSystem.getUserValuePersistent(persistentID, "directory")
            persistentTimer := Func("runFileTimer").bind(persistentID, directory)
        case "Save screenshot":
            persistentTimer := Func("saveScreenshotTimer").bind(persistentID)
        case "Telegram message":
            persistentTimer := Func("telegramMessageTimer").bind(persistentID)
        case "Telegram screenshot":
            persistentTimer := Func("saveScreenshotTimer").bind(persistentID, true)
        case "Use item":
            item := PersistentSystem.getUserValuePersistent(persistentID, "item")
            persistentTimer := Func("useItemTimer").bind(persistentID, item)
            ; case "aaaaaa":
        default:
            continue
    }

    SetTimer, % persistentTimer, Delete
    Random, R, 0, 100

    /*
    intervals lower than 1 second
    */
    if (InStr(atributes.interval, "0.")) {
        interval := StrReplace(atributes.interval, "0.", "")
        if (interval < 25)
            interval := 25
        SetTimer, % persistentTimer, % interval + R
    } else {
        SetTimer, % persistentTimer, % (atributes.interval * 1000) + R
    }
    Sleep, 25
}


return


actionScriptTimer(persistentID, clientWindowID := "") {
    if (persistentObj[persistentID].enabled = 0)
        return

    PersistentSystem.actionScriptPersistent(persistentID, clientWindowID)
    return
}

antiIdleTimer(persistentID, clientWindowID := "") {
    if (persistentObj[persistentID].enabled = 0)
        return

    PersistentSystem.antiIdle(clientWindowID)
    return
}

goToLabelItemCountTimer(persistentID, label := "", item := "", condition := "", value := "") {
    if (persistentObj[persistentID].enabled = 0) {
        persistentSystemObj[persistentID].labelTriggered := false
        return
    }
    PersistentSystem.goToLabelItemCount(persistentID, label, item, condition, value)
    return
}

clickOnImageTimer(persistentID, image := "", button := "", control := "false", variation := 40) {
    if (persistentObj[persistentID].enabled = 0)
        return

    PersistentSystem.clickOnImagePersistent(persistentID, image, button, control, variation)
    return
}

useItemTimer(persistentID, itemName := "") {
    if (persistentObj[persistentID].enabled = 0)
        return

    PersistentSystem.useItemPersistent(persistentID, itemName)
    return
}

clickOnPositionTimer(persistentID, button := "", control := "false", clientWindowID := "") {
    if (persistentObj[persistentID].enabled = 0)
        return

    PersistentSystem.clickOnPosition(persistentID, button, control)
    return
}

convertGoldTimer(persistentID) {
    if (persistentObj[persistentID].enabled = 0)
        return

    PersistentSystem.convertGold(persistentID)
    return
}

telegramMessageTimer(persistentID) {
    if (persistentObj[persistentID].enabled = 0)
        return

    PersistentSystem.telegramMessage(persistentID)
}

runFileTimer(persistentID, directory := "") {
    if (persistentObj[persistentID].enabled = 0)
        return

    PersistentSystem.runFile(directory)
    return
}

pressHotkeyTimer(persistentID, key := "", clientWindowID := "") {
    if (persistentObj[persistentID].enabled = 0)
        return

    PersistentSystem.pressHotkey(key, clientWindowID)
    return
}

pressHotkeyIfImageIsFoundTimer(persistentID, key := "", image := "", variation := 40) {
    if (persistentObj[persistentID].enabled = 0)
        return

    PersistentSystem.pressHotkeyIfImageIsFoundPersistent(key, image, variation)
    return
}

pressHotkeyIfImageTimer(persistentID, condition := "", key := "", image := "", variation := 40) {
    if (persistentObj[persistentID].enabled = 0)
        return

    PersistentSystem.pressHotkeyIfImagePersistent(persistentID, condition, key, image, variation)
    return
}

saveScreenshotTimer(persistentID, sendTelegram := false) {
    if (persistentObj[persistentID].enabled = 0)
        return

    PersistentSystem.saveScreenshot(persistentID, sendTelegram)
}



messageTimer:
    PersistentSystem.incrementMessageTime()
return


screenshotTimer:
    PersistentSystem.incrementScreenshotTime()
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

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\default_cavebot_functions.ahk



/*
to include TargetingSystem
*/
countIgnoredTargetingTimer:
countAttackingCreatureTimer:
countCreatureNotReachedTimer:
getMonsterPosition:
CooldownExeta:
return
/*
To include WaypointValidation
*/
minimapViewer:
return



Reload() {
    Reload
    return
}

writeCavebotLog(Status, Text, isError := false) {
    string := A_Hour ":" A_Min ":" A_Sec, Text := "[" Status "] " Text
    OutputDebug(moduleName "->Log", string " | " Text ".")
    return
}
