/*
OldBot � desenvolvido por Alfredo Menezes, Brasil.
Copyright � 2017. Todos os direitos reservados.

OldBot is developed by Alfredo Menezes, Brazil.
Copyright � 2017. All rights reserved.
*/

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\scripts_start_settings_section.ahk

/*
Includes folder
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IHealing.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ISupport.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ILooting.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Targeting.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Sio.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IActionScripts.ahk

MouseGetPos, x, y
Gui, Initializing:Destroy
Gui, Initializing:-Caption +Border +Toolwindow +AlwaysOnTop
Gui, Initializing:Color, Black
Gui, Initializing:Font, cWhite
Gui, Initializing:Add, Text, , % "Initializing hotkeys..."
Gui, Initializing:Show, % "x" x + 10 "y " y + 10 " NoActivate",

/*
others
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Script\_ScriptImages.ahk

/*
handler
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Hotkeys\_HotkeysHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_ItemsHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Waypoint\_WaypointHandler.ahk

/*
system
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Cavebot\_CavebotSystem.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Hotkeys\_HotkeysSystem.ahk

/*
others
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Cavebot\_CavebotWalker.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Waypoint\_WaypointValidation.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Item Refill.ahk

/*
module name
*/
global moduleName := "hotkeys"

/*
main Handler class initializing before hasFunctionEnabled()
*/
global HotkeysHandler := new _HotkeysHandler() ; to check hasFunctionEnabled

if (A_IsCompiled) {
    if (OldBotSettings.hasFunctionEnabled(moduleName) = false)
        ExitApp
}

PID := _ProcessHandler.writeModuleExePID(moduleName)

; reloads if client is closed
if (TibiaClient.getClientAreaFunctions(StrReplace(A_ScriptName, ".exe", "")) = false)
    return

; OutputDebug(moduleName, "Starting...")

Gui, Initializing:Destroy

/*
If client is disconnected, loop until it is connected again
or exitapp if tibia window doesn't exist anymore
*/
TibiaClient.isDisconnectedLoopWaitOrExit(moduleName)

MouseGetPos, x, y
Gui, Initializing:-Caption +Border +Toolwindow +AlwaysOnTop
Gui, Initializing:Color, Black
Gui, Initializing:Font, cWhite
Gui, Initializing:Add, Text, , % "Initializing hotkeys..."
Gui, Initializing:Show, % "x" x + 10 "y " y + 10 " NoActivate",

/*
initializing classes
*/
global MemoryManager := new _MemoryManager(injectOnStart := true)

global TargetingSystem := new _TargetingSystem() ; before TargetingHandler
/*
handler
*/
global LootingHandler := new _LootingHandler()
global TargetingHandler := new _TargetingHandler()

/*
system
*/
global ItemRefillSystem := new _ItemRefillSystem()
global HotkeysSystem := new _HotkeysSystem()
global LootingSystem := new _LootingSystem()
global ScriptImages := new _ScriptImages()
global SupportSystem := new _SupportSystem()

global ClientAreas := new _ClientAreas()

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

try global CavebotSystem := new _CavebotSystem()
catch e {
    Gui, Initializing:Destroy
    Gui, Carregando:Destroy
    if (A_IsCompiled)
        Msgbox, 16,, % e.Message, 10
    else
        Msgbox, 16,, % e.Message "`n" e.What "`n" e.Extra "`n" e.Line, 10
    Reload()
    return
}

try ClientAreas.readLootBackpackPosition()
catch {
}


try {
    _ClientAreas.setupCommonAreas()
} catch e {
    Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - setupCommonAreas()", % e.Message
    Reload
    return
}

global ItemsHandler := new _ItemsHandler(false, true)
global ActionScript := new _ActionScript()
global ActionScriptHandler := new _ActionScriptHandler()
global CavebotWalker := new _CavebotWalker(loadMinimapFiles := false)
global WaypointHandler := new _WaypointHandler()

/*
create item bitmaps
*/
createItemsBitmaps(itemsImageObj)

HotkeysSystem.createHotkeysActionScriptsVariablesObj()

/*
after all initial functions loadings
*/
Random, R, 0, 400
SetTimer, VerifyFunctionsFromExe, % 4000 + R
SetTimer, CheckClientClosedMinimized, % 2000 + R

; TibiaClient.isDisconnected(true, moduleName) ; check disconnected and reload if true

/*
start running module system & functions
*/

; msgbox, % serialize(hotkeysObj)
global t1hotkey

for hotkeyID, atributes in hotkeysObj
{
    if (atributes.action = "" OR atributes.action = "none")
        continue

    if (HotkeysHandler.isValidHotkey(atributes.hotkey) = false)
        continue

    if (atributes.enabled = 0)
        continue

    atributes.hotkey := HotkeysHandler.getRealHotkey(atributes.hotkey)

    switch atributes.action {
        case "Action Script":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyActionScript", atributes.action)
        case "Click on item":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyClickOnItem", atributes.action)
        case "Click on image":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyClickOnImage", atributes.action)
        case "Drag character position to mouse":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyDragCharacterPositionToMouse", atributes.action)
        case "Drag mouse to image":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyDragMouseToImage", atributes.action)
        case "Drag item to mouse":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyDragItemToMouse", atributes.action)
        case "Drag image to mouse":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyDragImageToMouse", atributes.action)
        case "Drag item to position":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyDragItemToPosition", atributes.action)
        case "Drag item to character position":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyDragItemToCharacterPosition", atributes.action)
        case "Drag mouse to backpack position":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyDragMouseToBackpackPosition", atributes.action)
        case "Drag mouse to character position":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyDragMouseToCharacterPosition", atributes.action)
        case "Drag mouse to position":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyDragMouseToPosition", atributes.action)
        case "Drag position to character position":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyDragPositionToCharacterPosition", atributes.action)
        case "Drag position to item":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyDragPositionToItem", atributes.action)
        case "Drag position to mouse":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyDragPositionToMouse", atributes.action)
        case "Drag position to position":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyDragPositionToPosition", atributes.action)
        case "Drag image to position":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyDragImageToPosition", atributes.action)
        case "Drag image to character position":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyDragImageToCharacterPosition", atributes.action)
        case "Loot around (quick looting)":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyLootAroundQuickLooting", atributes.action)
        case "Loot around (opening corpses)":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyLootAround", atributes.action)
        case "Loot items (manual looting)":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyLootItem", atributes.action)
        case "Shoot rune on current target", case "Shoot rune on target", case "Shoot rune on target (battle list)":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyShootRuneOnTarget", atributes.action)
        case "Use healing Life Potion":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyHealingHealthPotion", atributes.action)
        case "Use healing Mana Potion":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyHealingManaPotion", atributes.action)
        case "Use item on character":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyUseItemOnCharacter", atributes.action)
        case "Use item on follow target":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyUseItemOnTarget", atributes.action)
        case "Use item on mouse position":
            createHotkey(hotkeyID, atributes.hotkey, "hotkeyUseItemOnMousePosition", atributes.action)

    }
    Sleep, 10

}

Sleep, 200
Gui, Initializing:Destroy

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

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\default_cavebot_functions.ahk

Reload() {
    Reload
    return
}

writeCavebotLog(Status, Text, isError := false) {
    if (NO_LOGS = true)
        return
    string := A_Hour ":" A_Min ":" A_Sec, Text := "[" Status "] " Text
    OutputDebug(moduleName "->Log", string " | " Text ".")
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
/*
To include WaypointValidation
*/
minimapViewer:
return

#If (WinActive("ahk_id " TibiaClientID))

createHotkey(hotkeyFunctionID, hotkeyTrigger, hotkeyFunctionName, action) {
    ; msgbox, % hotkeyFunctionID "," hoteyTrigger "," hotkeyFunctionName "," action
    hotkeyFunc := Func(hotkeyFunctionName).bind(hotkeyFunctionID)
    try Hotkey, % hotkeyTrigger, % hotkeyFunc, On
    catch e {
        Msgbox, 48,, % "Failed to create hotkey.`n- ID: " hotkeyFunctionID "`nAction: " action "`n- Hotkey: " hotkeyTrigger, 20
    }
}

hotkeyActionScript(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.actionScriptHotkey(ID)
}
/**
click
*/
hotkeyClickOnImage(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.clickOnImageHotkey(ID)
}
hotkeyClickOnItem(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.clickOnItemHotkey(ID)
}

/**
mouse drag
*/
hotkeyDragCharacterPositionToMouse(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragCharacterPositionToMouse(ID)
}
hotkeyDragMouseToItem(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragMouseToItemHotkey(ID)
}
hotkeyDragMouseToImage(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragMouseToImageHotkey(ID)
}
hotkeyDragItemToMouse(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragItemToMouseHotkey(ID)
}
hotkeyDragImageToMouse(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragImageToMouseHotkey(ID)
}
hotkeyDragMouseToPosition(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragMouseToPositionHotkey(ID)
}
hotkeyDragPositionToCharacterPosition(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragPositionToCharacterPosition(ID)
}
hotkeyDragPositionToItem(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragPositionToItemHotkey(ID)
}
hotkeyDragPositionToMouse(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragPositionToMouse(ID)
}
hotkeyDragPositionToPosition(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragPositionToPositionHotkey(ID)
}
hotkeyDragImageToPosition(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragImageToPositionHotkey(ID)
}
hotkeyDragImageToCharacterPosition(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragImageToCharacterPositionHotkey(ID)
}
hotkeyDragItemToPosition(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragItemToPositionHotkey(ID)
}
hotkeyDragItemToCharacterPosition(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragItemToCharacterPositionHotkey(ID)
}
hotkeyDragMouseToBackpackPosition(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragMouseToBackpackPositionHotkey(ID)
}
hotkeyDragMouseToCharacterPosition(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.dragMouseToCharacterPositionHotkey(ID)
}

hotkeyHealingHealthPotion(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.healingPotion( "life")
}

hotkeyHealingManaPotion(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return

    HotkeysSystem.healingPotion("mana")
}

/**
loot
*/
hotkeyLootItem(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    ; t1hotkey := A_TickCount
    HotkeysSystem.lootItemsHotkey(ID)
}
hotkeyLootAround(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.lootAroundHotkey()
}
hotkeyLootAroundQuickLooting(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.lootAroundQuickLootingHotkey()
}

hotkeyShootRuneOnTarget(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.shootRuneOnTargetHotkey(ID)
}

hotkeyUseItemOnCharacter(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.hotkeyUseItemOnCharacterHotkey(ID)
}

hotkeyUseItemOnTarget(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.useItemOnTargetHotkey(ID)
}

hotkeyUseItemOnMousePosition(ID) {
    if (A_IsCompiled) && (hotkeysObj[ID].enabled = 0)
        return
    HotkeysSystem.useItemOnMousePositionHotkey(ID)
}
