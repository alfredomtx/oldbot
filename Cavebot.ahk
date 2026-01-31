/*
OldBot ? desenvolvido por Alfredo Menezes, Brasil.
Copyright ? 2017. Todos os direitos reservados.

OldBot is developed by Alfredo Menezes, Brazil.
Copyright ? 2017 All rights reserved.
*/
LOAD_ITEMS := 1

#WarnContinuableException Off
#SingleInstance, Force
#MaxMem 2048
SetWorkingDir %A_WorkingDir% ; Ensur;es a consistent starting directory.
; Process, Priority, %PID%, High
#NoTrayIcon
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#KeyHistory 0
#MaxHotkeysPerInterval 200
#HotkeyInterval 200
#MaxThreadsPerHotkey 1

;@Ahk2Exe-IgnoreBegin
#Warn, ClassOverwrite, MsgBox
;@Ahk2Exe-IgnoreEnd
#MaxThreads 100 ; changed on 28/07/2020

; SetWorkingDir %A_WorkingDir%  ; Ensures a consistent starting directory.
SendMode Input
SetDefaultMouseSpeed, 0
SetBatchLines, -1
; FileEncoding, UTF-8
DetectHiddenWindows On ; Allows a script's hidden main window to be detected.
SetTitleMatchMode 2
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
CoordMode, Tooltip, Screen
SetFormat, Float, 0.0
SetWinDelay, -1 ; ADDED ON 17/06/2023
SetControlDelay, -1 ; ADDED ON 17/06/2023
if (A_IsCompiled) {
    ListLines Off
}

OnExit("ExitCavebot")

global SHOW_WAYPOINT_SCREEN := false
if (!A_IsCompiled)
    SHOW_WAYPOINT_SCREEN := false

/*
Project files
*/
#Include __Files\default_global_variables.ahk
#Include __Files\mouse_keyboard_functions.ahk

/*
Includes folder
*/
#Include __Files\Includes\_Core.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IExecutables.ahk

#Include __Files\Includes\Cavebot\ICavebot.ahk
#Include __Files\Includes\Client.ahk
#Include __Files\Includes\IHealing.ahk
#Include __Files\Includes\ISupport.ahk
#Include __Files\Includes\Item Refill.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ILooting.ahk
#Include __Files\Includes\Script.ahk
#Include __Files\Includes\Sio.ahk
#Include __Files\Includes\Targeting.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IActionScripts.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IEvents.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ILibraries.ahk

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Actions\ICavebot.ahk
/*
Classes
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_CreaturesHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_ItemsHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_ProcessHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Thread\_ThreadManager.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_ImagesConfig.ahk ; depends on TibiaClient
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_OldBotSettings.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Waypoint\_WaypointHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Waypoint\_WaypointValidation.ahk
/*
GUI Classes
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\GUI\Cavebot\_MinimapGUI.ahk
/*
Others Classes
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Telegram.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Encryptor.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Hotkeys\_HotkeyRegister.ahk


#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Objects\_Magick.ahk
version := _Version.BETA_ENABLED ? _Version.BETA : _Version.CURRENT
/*
for AlertsSystem cavebot window title
*/
IniWrite, % version, % "Data/Files/version.ini", settings, cavebotVersion

global DefaultProfile
IniRead, DefaultProfile, oldbot_profile.ini, profile, DefaultProfile, settings.ini
IfNotInString, DefaultProfile, settings.ini
{
    FoundPos := InStr(DefaultProfile, "\settings")
    StringReplace, DefaultProfile_SemIni, DefaultProfile, .ini,, All
    ; msgbox, %FoundPos%
    StringTrimLeft, DefaultProfile, DefaultProfile, FoundPos + 9
    StringTrimLeft, DefaultProfile_SemIni, DefaultProfile_SemIni, FoundPos + 9
    DefaultProfile := "settings_" DefaultProfile

} else {
    DefaultProfile := "settings.ini"
    DefaultProfile_SemIni := "default"
}

global Encryptor := new _Encryptor()
global TibiaClient := new _TibiaClient()

IniRead, LANGUAGE, %DefaultProfile%, settings, LANGUAGE, PT-BR
global LANGUAGE

CarregandoGUI(LANGUAGE = "PT-BR" ? "Iniciando Cavebot..." : "Starting Cavebot...", 230, 230)

IniRead, last_loading_line, %DefaultProfile%, others_cavebot, last_loading_line, 2400
global last_loading_line

IniRead, TargetingEnabled, %DefaultProfile%, cavebot_settings, TargetingEnabled, 0
IniRead, CavebotEnabled, %DefaultProfile%, cavebot_settings, CavebotEnabled, 0

global TargetingEnabled
global CavebotEnabled

carregando_status := LANGUAGE = "PT-BR" ? "Iniciando Cavebot..." : "Starting Cavebot..."
InfoCarregandoPercent(carregando_status, A_LineNumber)

global MyProgress

; global sessionString := LANGUAGE = "PT-BR" ? "Sess?o" : "Session"
global sessionString := "[" tab "]"
global pausado_string := LANGUAGE = "PT-BR" ? "Pausado" : "Paused"

; Msgbox, aaaaaaaaa %CavebotEnabled%, %TargetingEnabled%DefaultProfile%
if (A_IsCompiled) {
    if (CavebotEnabled = 0) && (TargetingEnabled = 0) {
        ; Msgbox, 48,, Cavebot and Targeting disabled.
        ExitApp
    }
}
carregando_status := LANGUAGE = "PT-BR" ? "Iniciando Cavebot..." : "Starting Cavebot..."
InfoCarregandoPercent(carregando_status, A_LineNumber)
; SetTimer, VerificarOldBotAberto, 15000
; if (A_IsCompiled) {
VerificarOldBotAberto(true)
; }

PID := _CavebotExe.writePID()

OnMessage(0x201, "WM_LBUTTONDOWN") ; add this line in the auto-execute section

IniWrite, 0, %DefaultProfile%, others_cavebot, CavebotPaused

IniRead, TibiaClientID, %DefaultProfile%, advanced, TibiaClientID, %A_Space%
IniRead, DebugMode, %DefaultProfile%, advanced, DebugMode, 0

if (TibiaClientID = "")
{
    Gui, Carregando:Destroy
    Msgbox, 48, % StrReplace(A_ScriptName, ".exe", ""), % "There is no Tibia client selected."
    ExitApp
}

if (TibiaClient.getClientAreaFunctions(StrReplace(A_ScriptName, ".exe", "")) = false)
    return

carregando_status := LANGUAGE = "PT-BR" ? "Iniciando Cavebot..." : "Starting Cavebot..."
InfoCarregandoPercent(carregando_status, A_LineNumber)

carregando_status := LANGUAGE = "PT-BR" ? "Lendo configurações..." : "Reading settings..."
InfoCarregandoPercent(carregando_status, A_LineNumber)

/*
classes initialization
*/
carregando_status := "Loading resources..."
InfoCarregandoPercent(carregando_status, A_LineNumber)

global cavebotIniSettings := new _CavebotIniSettings()
global targetingIniSettings := new _TargetingIniSettings()


global JsonLib := new JSON()

global ThreadManager := new _ThreadManager()


; start first
carregando_status := "Loading settings..."
InfoCarregandoPercent(carregando_status, A_LineNumber)
try {
    global OldBotSettings := new _OldBotSettings()
} catch e {
    startupException(e)
}

; start second
global CavebotScript := new _CavebotScript(currentScript, loadDefaultOnFail := true)
global ImagesConfig := new _ImagesConfig()

global ClientAreas := new _ClientAreas() ; keep together with Images

global MemoryManager := new _MemoryManager(injectOnStart := true)

global loginEmail
IniRead, loginEmail, %DefaultProfile%, accountsettings, loginEmail, %A_Space%

if (A_IsCompiled) {
    if (currentScriptRestricted = true) && (loginEmail = "") {
        Gui, Carregando:Destroy
        Msgbox, 48,, % (LANGUAGE = "PT-BR" ? "Falha ao carregar e-mail de login, por favor inicie o Cavebot novamente." : "Failed to load login e-mail, please start the Cavebot again.")
        ExitApp ; reload does not work well
    }

    if (currentScriptRestricted = true) {
        InfoCarregando("Checking script restriction...")
        Sleep, 250
    }

    global ScriptRestriction := new _ScriptRestriction()
    try ScriptRestriction.checkAllowedToUse()
    catch {
        ExitApp
    }
}

carregando_status := "Loading creatures..."
InfoCarregandoPercent(carregando_status, A_LineNumber)
global CreaturesHandler := new _CreaturesHandler(false)

carregando_status := "Loading items..."
InfoCarregandoPercent(carregando_status, A_LineNumber)

; if (A_IsCompiled)
if (A_IsCompiled || LOAD_ITEMS) {
    global ItemsHandler := new _ItemsHandler(false, true)
}
InfoCarregandoPercent(carregando_status, A_LineNumber)


; creating bitmap of items from deposit and trash list
carregando_status := "Loading resources..."
InfoCarregandoPercent(carregando_status, A_LineNumber)

global ItemRefillSystem := new _ItemRefillSystem()
global LootingSystem := new _LootingSystem() ; before LootingHandler (for json settings)
global LootingHandler := new _LootingHandler()
global DistanceLooting := new _DistanceLooting() ; after LootingSystem
global SupportSystem := new _SupportSystem()
global TargetingSystem := new _TargetingSystem()
global TargetingHandler := new _TargetingHandler()

classLoaded("_BitmapEngine", _BitmapEngine)

; new _SearchChatOnButton()
; _ := new _FightControlsArea()


try  {
    global CavebotSystem := new _CavebotSystem()
    global CavebotWalker := new _CavebotWalker()
} catch e {
    startupException(e)
}

_CavebotSystem.registerHotkeys()


global AttackSpell := new _AttackSpell()

global ActionScript := new _ActionScript()
global ActionScriptHandler := new _ActionScriptHandler()

InfoCarregando("Loading waypoints...")
global WaypointHandler := new _WaypointHandler()
global WaypointValidation := new _WaypointValidation()

global ScriptImages := new _ScriptImages()
global ScriptJson := new _ScriptJson()
global ScriptJsonValidation := new _ScriptJsonValidation()

global CoordinateViewer := new _WaypointViewer(fromCavebot := true)
global TelegramAPI := new _Telegram(false)
global MinimapGUI := new _MinimapGUI()

InfoCarregando("Loading resources...")

InfoCarregandoPercent(carregando_status, A_LineNumber)


#Include __Files\cavebot_read_settings.ahk

/*
Cavebot logs window elements
*/
IniRead, CavebotMinimized, %DefaultProfile%, others_cavebot, CavebotMinimized, 0
CavebotSystem.cavebotLogsWindowParams()
Gosub, CreateCavebotLogSGUI
gosub, SetTransparency_SpecialActions


writeCavebotLog("Cavebot", (LANGUAGE = "PT-BR" ? "Iniciando configurações automáticas.." : "Starting automatic configurations.."))
carregando_status := LANGUAGE = "PT-BR" ? "Iniciando configurações automáticas..." : "Starting automatic configurations..."
InfoCarregandoPercent(carregando_status, A_LineNumber)

try {
    TargetingSystem.startTargetingCavebotSetup()
    TargetingSystem.createCreaturesDangerObj()
    LootingSystem.getLootSearchArea()
} catch e {
    startupException(e)
}

try {
    Loop {
        if (isConnected()) {
            break
        }

        carregando_status := LANGUAGE = "PT-BR" ? "Char desconectado..." : "Character disconnected..."
        InfoCarregandoPercent(carregando_status, A_LineNumber)
        Sleep, 3000
    }
} catch e {
    startupException(e)
}


carregando_status := "Loading areas..."
InfoCarregandoPercent(carregando_status, A_LineNumber)
try {
    Loop, 2 {
        try {
            Send("Esc")
        } catch {
        }
        Sleep, 50
    }

        new _MinimapArea()
    _ClientAreas.setupCommonAreas()


    ; if (TargetingEnabled) {
    ;         new _BattleListArea()
    ;         new _BattleListPixelArea()
    ; }

    ; _TargetingSystem.testAvalanche()
} catch e {
    startupException(e)
}



if (!A_IsCompiled) {
    ; Gui, Carregando:Destroy

    ; Loop, {
    ;     DistanceLooting.addCoordsFromCreatureCorpse()
    ;     DistanceLooting.runLootingQueue()
    ; }

    ; Loop, {
    ;     msgbox, % TargetingSystem.countAllCreaturesBattle()
    ;     LootingSystem.lootCorpsesAround()
    ;     msgbox, LootingSystem.lootCorpsesAround()
    ;     Sleep, 2000
    ; }
}


if (OldbotSettings.uncompatibleModule("looting") = true)
    lootingObj.settings.lootingEnabled := false


InfoCarregandoPercent(carregando_status, A_LineNumber)


; msgbox, % serialize(scriptSettingsObj)

StartTab := scriptSettingsObj.startTab, StartWaypoint := scriptSettingsObj.startWaypoint

if (forceStartWaypoint = 1) {
    if (CavebotScript.checkStartWaypointSet() = true)
        StartTab := scriptSettingsObj.startTabSet, StartWaypoint := scriptSettingsObj.startWaypointSet
}

global CavebotDisabledNoWaypoint := false
if (CavebotEnabled = true) && (StartWaypoint = "") {
    if (IsObject(waypointsObj.Waypoints.1)) {
        StartTab := "Waypoints"
        StartWaypoint := 1
    } else {
        Menu, Tray, Icon
        TrayTip, % LANGUAGE = "PT-BR" ? "Cavebot desabilitado" : "Cavebot disabled", % LANGUAGE = "PT-BR" ? "Waypoint inicial n?o selecionado" : "Start waypoint not selected.", 2, 1
        ; msgbox, aas
        SetTimer, HideTrayTipFunctions, -2000
        CavebotEnabled := false
        CavebotDisabledNoWaypoint := true
    }
}

tab := StartTab, tab_prefix := tab "_"



if (CavebotEnabled) && (!scriptSettingsObj.charCoordsFromMemory && CavebotScript.isCoordinate()) {
    Gui, Carregando:Destroy
    msgbox, 48,, % txt("A opção de ""Coordenadas do char da memoria do cliente"" esta desmarcada. Selecione o cliente do OT Server que voce esta usando no botao ""Selecionar Client"".`n`nCaso voce nao encontre na lista, clique no botao ""Adicionar novo cliente"" em baixo da lista.", "The option ""Character coordinates from client memory"" is unchecked. Select the client of the OT server you are using in the ""Select Client"" button.`n`nIn case you don't find the client on the list, click on the ""Add new client"" button below the list."), 30
    ExitApp
}


InfoCarregandoPercent(carregando_status, A_LineNumber)

global StopAlarm = 0


; CheckTaskbarWidth()

InfoCarregandoPercent(carregando_status, A_LineNumber)


; CavebotSystem.checkLootFrames()
; InfoCarregandoPercent(carregando_status, A_LineNumber)

try ClientAreas.readLootBackpackPosition()
catch {
}

InfoCarregandoPercent(carregando_status, A_LineNumber)

CavebotSystem.setEquipmentPositions()
InfoCarregandoPercent(carregando_status, A_LineNumber)

; CheckWhiteArrowActionBar()

carregando_status := LANGUAGE = "PT-BR" ? "Realizando configurações automáticas..." : "Performing automatic configurations..."
InfoCarregandoPercent(carregando_status, A_LineNumber)

resetCavebotSession()

Loop, {
    if (isDisconnected()) {
        carregando_status := LANGUAGE = "PT-BR" ? "Desconectado" : "Disconnected"
        InfoCarregandoPercent(carregando_status, A_LineNumber)
        Sleep, 3000
    } else {
        break
    }
}

if (OldbotSettings.uncompatibleModule("targeting") != true) {
    carregando_status := LANGUAGE = "PT-BR" ? "Detectando Battle List..." : "Detecting Battle List..."
    writeCavebotLog("Targeting", carregando_status)
}

InfoCarregandoPercent(carregando_status, A_LineNumber)

/*
targeting settings checks and areas
*/
if (TargetingEnabled = 1) {
    TargetingSystem.createCorpseImagesArray()

    Gui, Carregando:Destroy

    /**
    check Players battle list
    */
    getPlayersBattleList := false
    for creatureName, creatureAtributes in targetingObj.targetList
    {
        for spellNumber, spellAtributes in creatureAtributes.attackSpells
        {
            if (spellAtributes.playerSafe = true) OR (spellAtributes.onlyWithPlayer) {
                getPlayersBattleList := true
                break
            }
        }
    }
    /**
    anti ks "Player on screen" mode
    */
    if (new _TargetingSettings().get("antiKs") = "Player on screen") {
        getPlayersBattleList := true
    }

    if (getPlayersBattleList = true) {
        carregando_status := LANGUAGE = "PT-BR" ? "Detectando Battle List de Players..." : "Detecting Players Battle List..."
        writeCavebotLog("Targeting", carregando_status)

        try {
                new _PlayersBattleListArea()
        } catch e {
            Gui, Carregando:Destroy
            Msgbox, 48, % (StrReplace(A_ScriptName, ".exe", "")), % e.Message
            Reload()
            return
        }
    }

    try {
        _ := new _BattleListArea().checkBattleListTooSmall()
    } catch e {
        Gui, Carregando:Destroy
        Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")), % e.Message
        Reload()
        return
    }

    InfoCarregandoPercent(carregando_status, A_LineNumber)

    InfoCarregandoPercent(carregando_status, A_LineNumber)
}

if (OldbotSettings.uncompatibleModule("healing") = false) {
    carregando_status := "Detecting life/mana bars.."
    InfoCarregandoPercent(carregando_status, A_LineNumber)

    try {
        global HealingSystem := new _HealingSystem()
    } catch e {
        if (e.Message) {
            Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - Healing Setup Init", % e.Message, 10
        }
        Reload()
        return
    }

    InfoCarregandoPercent(carregando_status, A_LineNumber)
}

if (backgroundMouseInput = false OR backgroundKeyboardInput = false)
    WinActivate, ahk_id %TibiaClientID%

InfoCarregandoPercent(carregando_status, A_LineNumber)

Sleep, 10

if (lootingObj.settings.lootCreaturesPosition = true) && (CavebotEnabled = false) {
    CavebotEnabled := 1, CavebotDisabledNoWaypoint := true
}

if (CavebotEnabled) || (LootingEnabled && lootingObj.settings.lootCreaturesPosition) {
    try CavebotWalker.getMinimapFloorPosition()
    catch e {
        writeCavebotLog("ERROR", e.Message)
    }
    InfoCarregandoPercent(carregando_status, A_LineNumber)
}

try {
    ; if  (A_IsCompiled && !isRubinot()) {
    ; if  (!isRubinot()) {
    CavebotSystem.adjustMinimap()
    ; }
} catch e {
    if (!A_IsCompiled) {
        writeCavebotLog("ERROR", se(e))
    }
    writeCavebotLog("ERROR", e.Message)
}

IniWrite, %A_LineNumber%, %DefaultProfile%, others_cavebot, last_loading_line

Gui, Carregando:Destroy

if (TargetingEnabled = 1) {
    carregando_status := LANGUAGE = "PT-BR" ? "Iniciando Targeting..." : "Starting Targeting..."

    SetTimer, RunTargeting, % TargetingSystem.TargetingTimer
}

if (A_IsCompiled) {
    SetTimer, SessionCounter, 1000
}

IniWrite, 0, %DefaultProfile%, others_cavebot, CharDied

/*
Thread that checks if tibia is minimized and restore it if true
*/
threadName := "checkTibiaMinimized"
; checkTibiaMinimized := ThreadManager.createThreadCriticalObj(threadName, script)
global checkTibiaMinimizedObj := CriticalObject({"TibiaClientID": TibiaClientID, "minimized": false, "maximize": true})

%threadName% := AhkThread("
    (

        ; ListVars
        #NoTrayIcon
        #Persistent
        MyObj := CriticalObject(A_Args[1])
        TibiaClientID := MyObj.TibiaClientID
        maximize := MyObj.maximize

        Loop
        {
            Sleep, 1000
            WinGet, MMX, MinMax, ahk_id %TibiaClientID%
            if (MMX = ""-1"") {
                if (maximize = true)
                    WinActivate, ahk_id %TibiaClientID% ; restore client if minimized
                MyObj.minimized := true
                Sleep, 1000
            } else {
                MyObj.minimized := false

            }
        }

    )", &%threadName%Obj "")
; While %threadName%.ahkReady()
; {
;       ToolTip % "running thread.`n" threadName " = " serialize(%threadName%Obj)
;       Sleep, 50
; }
if (A_IsCompiled) {
    SetTimer, LogClientMinimized, 1000
}

/*
use to check if is trapped and receive other data from cavebotextension and antritap.exe
*/
OnMessage(0x4a, "Receive_WM_COPYDATA") ; 0x4a is WM_COPYDATA
if (CavebotDisabledNoWaypoint = true) {
    writeCavebotLog("Cavebot", txt("Cavebot desativado - n?o h? nenhum Waypoint Inicial selecionado. Clique com o bot?o direito em um waypoint -> """ SET_START_MENU """.", "Cavebot disabled - there is no Start Waypoint selected. Right click on a waypoint -> """ SET_START_MENU """."))
    return
}
if (CavebotEnabled = false)
    return

if (TargetingEnabled = 1)
    SetTimer, RunTargeting, Off
CavebotSystem.initialCharacterPosition()
if (TargetingEnabled = 1)
    SetTimer, RunTargeting, On
; Sleep, 300

Start:

    global Waypoint := StartWaypoint - 1

    switch scriptSettingsObj.cavebotFunctioningMode {
        case "markers":
            Loop {
                if (isDisconnected()) {
                    writeCavebotLog("Cavebot", LANGUAGE = "PT-BR" ? "desconectado.." : "disconnected..")
                    Sleep, 3000
                    continue
                }
                if (Waypoint < 1)
                    Waypoint := 0
                Waypoint++
                ; msgbox, %  "Waypoint = " Waypoint "`n" %tab_prefix%ActionWP%Waypoint%

                if (checkCharDied() = true)
                    return

                if (Waypoint > waypointsObj[tab].Count())
                    Waypoint := 1, writeCavebotLog("Cavebot", (LANGUAGE = "PT-BR" ? "Fim dos waypoints, voltando ao waypoint 1" : "End of waypoints, going back to waypoint 1"))

                waypointAtributes := waypointsObj[tab][Waypoint]
                Send_WM_COPYDATA(Waypoint "|" tab, SendMessageTargetWindowTitle)
                mapX := waypointAtributes.coordinates.x, mapY := waypointAtributes.coordinates.y, mapZ := waypointAtributes.coordinates.z
                CavebotSystem.initializeSystemWaypointAtributes(waypointAtributes)

                if (waypointAtributes.image = "")
                    global stringCoords := "{marker: " waypointsObj[tab][Waypoint].marker "}"
                else
                    global stringCoords := "{image...}"
                if (CavebotSystemObj.forceWalkReason != "forcewalkarrow") ; if is not forced by action
                    CavebotSystemObj.forceWalk := false, CavebotSystemObj.forceWalkReason := ""

                IniWrite, % tab, %DefaultProfile%, cavebot, CurrentWaypointTab
                IniWrite, % Waypoint, %DefaultProfile%, cavebot, CurrentWaypoint

                try {
                    RunCavebotMarkers()
                } catch e {
                    _Logger.exception(e, "RunCavebotMarkers")
                }
            }
        default:
            Loop {
                if (isDisconnected()) {
                    writeCavebotLog("Cavebot", LANGUAGE = "PT-BR" ? "desconectado.." : "disconnected..")
                    Sleep, 3000
                    continue
                }
                if (Waypoint < 1)
                    Waypoint := 0
                Waypoint++
                ; msgbox, %  "Waypoint = " Waypoint "`n" %tab_prefix%ActionWP%Waypoint%

                if (checkCharDied() = true)
                    return

                if (Waypoint > waypointsObj[tab].Count(r))
                    Waypoint := 1, writeCavebotLog("Cavebot", (LANGUAGE = "PT-BR" ? "Fim dos waypoints, voltando ao waypoint 1" : "End of waypoints, going back to waypoint 1"))

                waypointAtributes := waypointsObj[tab][Waypoint]
                Send_WM_COPYDATA(Waypoint "|" tab, SendMessageTargetWindowTitle)
                mapX := waypointAtributes.coordinates.x, mapY := waypointAtributes.coordinates.y, mapZ := waypointAtributes.coordinates.z
                CavebotSystem.initializeSystemWaypointAtributes(waypointAtributes)

                if (CavebotSystemObj.forceWalkReason != "forcewalkarrow") ; if is not forced by action
                    CavebotSystemObj.forceWalk := false, CavebotSystemObj.forceWalkReason := ""

                IniWrite, % tab, %DefaultProfile%, cavebot, CurrentWaypointTab
                IniWrite, % Waypoint, %DefaultProfile%, cavebot, CurrentWaypoint
                RunCavebot()
            }
    }

return

RunCavebotMarkers() {
    /**
    check arrived
    compare minimap from 1 second ago, if image doesn't change means character arrived
    */
    cavebotSystemObj.clicksOnWaypoint := 1

    _CavebotWalker.runBeforeWaypointAction()
    ; if is action waypoint, don't need to walk to the waypoint
    if (WaypointHandler.getAtribute("type", Waypoint, Tab) = "Action") {
        ActionScript.ActionScriptWaypoint(Waypoint)
        _CavebotWalker.runAfterWaypointAction()
        return
    }

    if (!waypointsObj[tab][Waypoint].marker && !waypointsObj[tab][Waypoint].image)
        return

    if (backgroundMouseInput) {
        MouseMove(CHAR_POS_X, CHAR_POS_Y) ; move to the char position in case the mouse is somewhere that triggers a tooltip and cover the minimap
    }

    /**
    check if is starting too far away from any waypoint that is not action
    */
    Sleep, 15

    sessionString := "[" tab "]"
    gosub, UpdateSession
    CavebotWalker.markerStatusBarIcon()


    try {
        if (_CavebotByImage.checkArrivedOnMarker() = true)
            goto, arrivedAtWaypointMarker
    } catch e {
        _Logger.exception(e, A_ThisFunc, "_CavebotByImage.checkArrivedOnMarker()")
    }


    if (walkToWaypoint() = false) { ; if fail to walk to the waypoint, skip to next
        return
    }

    arrivedAtWaypointMarker:
    writeCavebotLog("Cavebot", (LANGUAGE = "PT-BR" ? "WP" Waypoint ": alcançado" : "WP" Waypoint ": reached") " " stringCoords)
    CavebotWalker.arrivedAtWaypointActionMarker()

    _CavebotWalker.runAfterWaypointAction()

    restoreTargetingIcon()
    targetingSystemObj.targetingDisabledAction := false
        , targetingSystemObj.targetingDisabledActionReason := ""
    ; gosub, waypointEndActions

}

RunCavebot()
{
    cavebotSystemObj.clicksOnWaypoint := 1

    _CavebotWalker.runBeforeWaypointAction()
    ; if is action waypoint, don't need to walk to the waypoint
    if (WaypointHandler.getAtribute("type", Waypoint, Tab) = "Action") {
        ActionScript.ActionScriptWaypoint(Waypoint)
        _CavebotWalker.runAfterWaypointAction()
        return
    }

    MouseMove(CHAR_POS_X, CHAR_POS_Y) ; move to the char position in case the mouse is somewhere that triggers a tooltip and cover the minimap
    /**
    check if is starting too far away from any waypoint that is not action
    */
    Sleep, 15
    getCharPos()
    try CavebotWalker.isWaypointTooFar(mapX, mapY, mapZ, posx, posy, posz, false)
    catch e {
        writeCavebotLog("Cavebot Path ERROR", e.Message " " stringCoords, true)
        return
    }

    sessionString := "[" tab "]"
    gosub, UpdateSession

    if (checkArrivedOnCoord(mapX, mapY, mapZ, false) = true)
        goto, arrivedAtWaypoint

    if (SHOW_WAYPOINT_SCREEN = true)
        CoordinateViewer.createFromListOfWaypointsNumbers(tab, {"1": Waypoint}, getCharCoords := false, startTimer := true)
    if (walkToWaypoint() = false) { ; if fail to walk to the waypoint, skip to next
        if (SHOW_WAYPOINT_SCREEN = true)
            CoordinateViewer.destroyAllElements(false)
        return
    }

    arrivedAtWaypoint:
    if (SHOW_WAYPOINT_SCREEN = true)
        CoordinateViewer.destroyAllElements(false)
    writeCavebotLog("Cavebot", (LANGUAGE = "PT-BR" ? "WP" Waypoint ": alcançado" : "WP" Waypoint ": reached") " " stringCoords)
    try {
        _CavebotWalker.arrivedAtWaypointAction()
    } catch e {
        _Logger.exception(e, waypoint, tab)
    }

    _CavebotWalker.runAfterWaypointAction()

    restoreTargetingIcon()
    targetingSystemObj.targetingDisabledAction := false
        , targetingSystemObj.targetingDisabledActionReason := ""
    ; gosub, waypointEndActions

    return
}

Receive_WM_COPYDATA(wParam, lParam)
{
    StringAddress := NumGet(lParam + 2*A_PtrSize) ; Retrieves the CopyDataStruct's lpData member.
    CopyOfData := StrGet(StringAddress) ; Copy the string out of the structure.

    if (InStr(CopyOfData, "/")) {
        commandObj := StrSplit(CopyOfData, "/")
        command := commandObj.1
    } else {
        command := CopyOfData
    }

    data := CopyOfData
    CopyOfData := "", StringAddress := ""

    switch command {
        case "Unpause":
            gosub, Unpause
            writeCavebotLog("WARNING", "Cavebot UNPAUSED by external script")
        case "Pause":
            Critical, On
            try {
                writeCavebotLog("WARNING", "Cavebot PAUSED by external script")
                    new _StopWalking()
            } catch e {
                Critical, Off
            }
            ; Loop, 2
            ;     Send("Esc")
            Gosub, Pausar

        default:
            return _CavebotExeMessage.handle(data)
    }

    return true
}

checkCharDied() {
    IniRead, CharDied, %DefaultProfile%, others_cavebot, CharDied, 0
    if (pauseOnDeath = 1 && CharDied = 1) {
        writeCavebotLog("Cavebot", LANGUAGE = "PT-BR" ? "Char foi morto! Cavebot parado" : "Char has died! Cavebot stopped")
        return true
    }
    return false
}

^+y::
    ListVars
return

checkEmptyQueueTimer:
    _ProcessQueue.checkEmptyQueue()
return

deleteTimerCountSpellCooldown:
    targetingSystemObj.attackSpell.cooldownTime := 0
    global timerCountSpellCooldown := false
    SetTimer, CooldownSpell, Delete
return

countIgnoredTargetingTimer:
    TargetingSystem.ignoredTargetingTimer()
return

countCreatureNotReachedTimer:
    TargetingSystem.creatureNotReachedTimer()
return

countAttackingCreatureTimer:
    TargetingSystem.attackingCreatureTimer()
return

RunTargeting()
{
    static battleListArea
    if (!battleListArea) {
        battleListArea := new _BattleListArea()
    }

    if (cavebotSystemObj.criticalCharPosSearch) {
        writeCavebotLog("Targeting", "Waiting Cavebot thread..", 1)
        return
    }

    targetingSystemObj.threadReleaseTargeting := true
    try {
        targetingRelease := TargetingSystem.releaseTargeting()
    } catch e {
        _Logger.exception(e, A_ThisFunc ".TargetingSystem.releaseTargeting()")
    } finally {
        targetingSystemObj.threadReleaseTargeting := false
    }

    if (!targetingRelease) {
        return
    }

    /**
    if lure mude is enabled, press Esc to stop walking
    */
    if (targetingSystemObj.luremode.enabled) {
        /**
        if was attacking by the LureModeTimerAttack, cancel the attack first
        */
        if (new _IsAttacking().found()) {
            Send("Esc")
            Sleep, 50
        }

        Send("Esc")
        /**
        small delay after pressing ESC otherwise will bug the click attack
        */
        sleep, 150

        /**
        if was in chase attack and the luremode timer attack changed it to stand
        */
        if (targetingSystemObj.luremode.timerAttack.restoreChase) {
            TargetingSystem.isInCombatMode("stand", true)
            targetingSystemObj.luremode.timerAttack.restoreChase := false
            targetingSystemObj.luremode.timerAttack.stand := false
        }
    }

    /**
    targeting is released, reset the detected attacks var
    */
    targetingSystemObj.antiKsDetectedAttacks := 0

    if (CavebotEnabled = 1) {
        CURRENT_WALK_TO_COORDINATE.pausedByTargetingEvent()
    }

    targetingSystemObj.firstStopAttack := true
    targetingSystemObj.totalCreaturesAttackLooting := 0
        , targetingSystemObj.releaseLootingAfterKillAll := false
    startSearchCreatures:

        new _WaitDisconnected(2000) ; when is disconnected while attacking monsters, it gets stuck attacking the first on battle list without this
    /**
    if antiks is enabled and there is no creature attaking
    */
    if (!TargetingSystem.haveEnoughCreaturesLureMode(true) && !targetingSystemObj.isTrapped) {
        goto, _endTargeting
    }

    ; when does not have enough creatuers for lure more, is trapped and battle list is empty, then should skip
    if (new _IsBattleListEmpty()) {
        targetingSystemObj.isTrapped := false
        goto, _endTargeting
    }

    TargetingSystem.currentCreature := "", currentCreature := "", spellNumber := 1
        , TargetingSystem.creatureSearchOrder := !TargetingSystem.creatureSearchOrder
        , indexCreaturesDanger := 0

    if (new _TargetingSettings().get("huntAssistMode")) {
        /**
        use the "all" creature as attacking
        */
        TargetingSystem.currentCreature := "all", currentCreature := "all"
        goto, _skipCreatureSearchTargeting
    }

    Loop, % targetingSystemObj.creaturesDanger.MaxIndex() {
        index := targetingSystemObj.creaturesDanger.MaxIndex() - indexCreaturesDanger

        if (!targetingSystemObj.creaturesDanger[index]) {
            indexCreaturesDanger++
            continue
        }

        creaturesDangerArray := targetingSystemObj.creaturesDanger[index]
            , indexCreatureSearch := 1
        Loop, % creaturesDangerArray.MaxIndex() {
            switch TargetingSystem.creatureSearchOrder {
                    /**
                    ascending order
                    */
                case 1:
                    creatureName := creaturesDangerArray[indexCreatureSearch]
                    /**
                    descending order
                    */
                case 0:
                    creatureName := creaturesDangerArray[creaturesDangerArray.MaxIndex() + 1 - indexCreatureSearch]
            }

            if (!TargetingSystem.checkCreatureSearchConditions(creatureName)) {
                indexCreatureSearch++
                continue
            }

            /**
            if antiks and luring mode are enable, it's causing problems to find monsters after the y1 of blackpix (ignoring targeting timer by NoCreatureFound)
            in this case, with antiks+lure, must not use the blackPixY
            */
            creatureSearchY1 := battleListArea.getY1()
            /**
            if antiks is enabled, lure mode is not enabled and black pix is found, use blackPixY as Y1
            */
            if (new _TargetingSettings().get("antiKs") != "Disabled" && !targetingSystemObj.luremode.enabled && targetingSystemObj.positions.blackPix.y) {
                creatureSearchY1 := targetingSystemObj.positions.blackPix.y
            }

            coordinates := battleListArea.getCoordinates()
            coordinates.setY1(creatureSearchY1)

            try {
                creatureSearch := new _SearchCreature(creatureName, false, coordinates)
            } catch e {
                indexCreatureSearch++
                _Logger.exception(e, A_ThisFunc, creatureName)
                continue
            }

            creatureResult := creatureSearch.getResults()

            targetIndex := 1
            if (targetingIniSettings.get("randomizeSameCreatureAttack")) {
                Random, targetIndex, 1, % creatureSearch.getResultsCount()
            }

            targetingSystemObj.creatures[creatureName].found := creatureSearch.found()
                , targetingSystemObj.creatures[creatureName].x := creatureResult[targetIndex].x, targetingSystemObj.creatures[creatureName].y := creatureResult[targetIndex].y
                , targetingSystemObj.creatures[creatureName].battlePosition := creatureResult[targetIndex]

            /**
            this function is supposed to check the information of creatures found from the multithread that stores
            data in the "targetingSystemObj", if some monster is found, it releases the targeting here to attack
            */
            if (targetingSystemObj.creatures[creatureName].found) {
                TargetingSystem.currentCreature := creatureName, currentCreature := creatureName
                    , targetingSystemObj.attackingCreatures := true
                break
            }

            indexCreatureSearch++
        } ; for

        if (targetingSystemObj.creatures[creatureName].found) {
            break
        }

        indexCreaturesDanger++
    } ; loop

    TargetingSystem.setCurrentCreatureIfNoneFound()

    /**
    if didn't find any creature, return
    */
    TargetingSystem.noneFound := false
    if (!TargetingSystem.currentCreature) {
        TargetingSystem.noneFound := true
        goto, _endTargeting
    }
    /**
    press esc and wait a bit before attacking the creature, only when the cavebot is enabled(to stop walking)
    */
    ; if (TargetingSystem.checkCreatureStopBeforeFirstAttack() = false)
    ;     goto startSearchCreatures

    /**
    check creature life before attacking
    */
    if (!TargetingSystem.checkStopCreatureAttackByLife()) {
        goto, _endTargeting
    }

    TargetingSystem.attackCreature()

    if (TargetingSystem.noneFoundAllMode) {
        goto, _endTargeting
    }

    if (!targetingObj.targetList[TargetingSystem.currentCreature].dontLoot) {
        targetingSystemObj.totalCreaturesAttackLooting++
    }

    _skipCreatureSearchTargeting:

    TargetingSystem.deleteCreatureAttackingTimer()

    targetingSystemObj.creatures[TargetingSystem.currentCreature].unreachable := false

    if (new _TargetingSettings().get("huntAssistMode")) {
        TargetingSystem.targetingAttackLog()
    }

    gosub, checkCreaturePlayAlarm

    _attackingCreature:
    if (targetingSystemObj.targetingIgnored.active) {
        goto, _endTargeting
    }

    IniWrite, 1, %DefaultProfile%, targeting_system, TargetingRunning

    ; Sleep, 25
    redPixFound := TargetingSystem.isAttacking()

    switch redPixFound
    {
        case true:
            if (new _TargetingSettings().get("huntAssistMode")) {
                targetingSystemObj.releaseLootingAfterKillAll := true
            }

            if (TargetingSystem.isCreatureUnreachable()) {
                Send("Esc")
            }

            if (targetingSystemObj.targetingIgnored.active) {
                goto, _endTargeting
            }

            if (!targetingSystemObj.creatures[TargetingSystem.currentCreature].active) {
                TargetingSystem.startCreatureAttackingTimer()
                TargetingSystem.startCreatureNotReachedTimer()
            }


            /**
            check creature health - to stop attack with
            it stops attack and go back to search a new creature, probably gonna need to change this in the future
            */
            if (!TargetingSystem.checkStopAttackingCurrentCreatureLife()) {
                goto, _endAttackingCreature
            }

            TargetingSystem.afterAttackCreatureActions()

            TargetingSystem.getCreaturePosition()
            ; Sleep, 25

            gosub, spellHandler
            goto, _attackingCreature

            /**
            creature has been killed, time to loot
            */
        case false:
            TargetingSystem.deleteCreatureAttackingTimer()

            if (targetingObj.targetList[TargetingSystem.currentCreature].dontLoot) {
                goto, _endAttackingCreature
            }

            switch lootingObj.settings.lootingEnabled
            {
                case 1:
                    try {
                        if (lootingObj.settings.lootCreaturesPosition) {
                            DistanceLooting.addCoordsFromDeadCreaturePos(targetingSystemObj.targetX, targetingSystemObj.targetY)
                        }

                        if (lootingObj.settings.searchCorpseImages) {
                            DistanceLooting.addCoordsFromCreatureCorpse(waitDelay := false)
                        }

                        if (!lootingObj.settings.lootAfterAllKill) {
                            LootingSystem.lootAroundFromTargeting()
                        }
                    } catch e {
                        _Logger.exception(e, A_ThisFunc ".Looting.1")
                    }

            } ; switch lootingEnabled
    } ; switch redPixFound

    _endAttackingCreature:
    try {
        TargetingSystem.afterCreatureWasKilledActions()
    } catch e {
        _Logger.exception(e, A_ThisFunc ".TargetingSystem.afterCreatureWasKilledActions()")
    }

    /**
    RunTargeting was paused to attack the current monster, now must unpause and go back to RunTargeting to search for the
    highest priority monsters first
    */
    switch (new _TargetingSettings().get("antiKs")) {
        case "Disabled":
            if (new _IsBattleListEmpty()) {
                Goto, _endTargeting
            }
            /**
            if antiks is enabled and there is no creature attaking
            */
        case "Enabled":
            if (!TargetingSystem.checkAntiKsBlackPix(false)) {
                Goto, _endTargeting
            }
            /**
            the same action as Enabled, but only if Player battle list is not empty
            */
        case "Player on screen":
            if (new _SearchPlayersBattleList().found() && !TargetingSystem.checkAntiKsBlackPix(false)) {
                Goto, _endTargeting
            }
    }

    if (new _TargetingSettings().get("huntAssistMode")) {
        Goto, _endTargeting
    }

    Goto, startSearchCreatures

    /**
    action to do before ending the targeting actions
    */
    _endTargeting:

    TargetingSystem.beforeEndingTargetingActions()
    if (CavebotEnabled && !CavebotDisabledNoWaypoint) {
        CURRENT_WALK_TO_COORDINATE.unpausedByTargetingEvent()
    }
    return
}


isDisconnectedAndStatus() {

    if (isDisconnected()) {
        writeCavebotLog("Targeting", LANGUAGE = "PT-BR" ? "Desconectado" : "Disconnected")
        return
    }
    return
}

checkCreaturePlayAlarm:
    if (!targetingObj.targetList[TargetingSystem.currentCreature].playAlarm) {
        return
    }

    Process, Exist, AlarmSingle.exe
    If (ErrorLevel = 0) {
        try {
            writeCavebotLog("ALARM",LANGUAGE = "PT-BR" ? currentCreature " localizado no Battle List" : currentCreature " found on Battle List")
            Run, Data\Executables\AlarmSingle.exe
        } catch {

            writeCavebotLog("ALARM",LANGUAGE = "PT-BR" ? "N?o foi poss?vel abrir o alarme, verifique se o arquivo em 'Data\Executables\AlarmSingle.exe' existe" : "It was not possible to open the alarm, check if the file in 'Data\Executables\AlarmSingle.exe' exists",true)
        }
    }
return

spellHandler:
    ; if monster has no spells
    if (targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"].Count() < 1) {
        return
    }

    t1Spell := A_TickCount
    try {
        if (AttackSpell.selectSpellToCast() = false) {
            return
        }

        ; Sleep, 25
    } catch e {
        _Logger.exception(e, "AttackSpell.selectSpellToCast()")
        return
    }

    /*
    conditions true, we can cast the spell
    */
    spellCasted := AttackSpell.castSpell(currentCreature, t1Spell)

    targetingSystemObj.attackSpell.spellNumber++
return


spellCooldownTimerCounter(spellNumber) {
    if (AttackSpell.spellsTimerCooldown < 1 OR AttackSpell.spellsTimerCooldown = 2)
        AttackSpell.spellsTimerCooldown := 0

    AttackSpell.spellsTimerCooldown += 100
    ; writeCavebotLog(A_ThisFunc, "Cooldown spell " spellNumber ": " AttackSpell.spellsTimerCooldown "/" targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].cooldown)

    if (AttackSpell.spellsTimerCooldown >= targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][spellNumber].cooldown) {
        SetTimer, % spellTimerTrigger, Delete
        AttackSpell.spellsTimerCooldown := 0
    }
}

CooldownSpell:
    if (targetingSystemObj.attackSpell.cooldownTime = 2)
        targetingSystemObj.attackSpell.cooldownTime := 0
    targetingSystemObj.attackSpell.cooldownTime += 100
    ; global targetingSystemObj.attackSpell.cooldownTime := targetingSystemObj.attackSpell.cooldownTime * 1000
    GuiControl, SpellGUI:, NumeroMagiaText, % LANGUAGE = "PT-BR" ? "Magia: " targetingSystemObj.attackSpell.spellNumberCast : "Spell: " targetingSystemObj.attackSpell.spellNumberCast
    GuiControl, SpellGUI:, spellHotkeyText, % "Hotkey: " targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][targetingSystemObj.attackSpell.spellNumberCast].hotkey
    GuiControl, SpellGUI:, spellCooldownText, % "Cooldown: " targetingSystemObj.attackSpell.cooldownTime "/" targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][targetingSystemObj.attackSpell.spellNumberCast].cooldown
    if (targetingSystemObj.attackSpell.cooldownTime >= targetingObj.targetList[TargetingSystem.currentCreature]["attackSpells"][targetingSystemObj.attackSpell.spellNumberCast].cooldown) {
        targetingSystemObj.attackSpell.spellNumber++
        Gui, SpellGUI:Destroy
        gosub, deleteTimerCountSpellCooldown
    }
return

CooldownExeta:
    if (targetingSystemObj.exetaCurrentCooldown < 1)
        targetingSystemObj.exetaCurrentCooldown := 0
    targetingSystemObj.exetaCurrentCooldown += 1
        , stringExeta := StrSplit(targetingObj.targetList[TargetingSystem.currentCreature].exetaResCooldown, " ")
        , exetaCooldown := stringExeta.1
    writeCavebotLog("Targeting", "[Exeta res] cooldown: " targetingSystemObj.exetaCurrentCooldown "/" exetaCooldown "s")
    if (targetingSystemObj.exetaCurrentCooldown >= exetaCooldown) {
        Gui, ExetaSpellGUI:Destroy
        SetTimer, CooldownExeta, Delete
        targetingSystemObj.releaseExeta := true, targetingSystemObj.exetaCurrentCooldown := 0
    }
return

isTargetOnSQM(number) {
    if (targetingSystemObj.targetX > SQM%number%X_X1 && targetingSystemObj.targetX < SQM%number%X_X2) && (targetingSystemObj.targetY > SQM%number%Y_Y1 && targetingSystemObj.targetY < SQM%number%Y_Y2)
        return true
    return false
}

LogClientMinimized:
    if (checkTibiaMinimizedObj.minimized = true)
        writeCavebotLog("ERROR", "TIBIA CLIENT MINIMIZED, WINDOW RESTORED!")
return

writeGuiLogs:
    if (CavebotLogsMinimized = false) {
        FileRead, logs, Cavebot\Logs\%currentScript%.txt
        try {
            AppendText(hCavebotLogsEdit, &logs)
            SendMessage, 0x0115, 7, 0,, ahk_id %hCavebotLogsEdit% ;WM_VSCROLLw
        } catch {
        }
        logs := ""
    }
return

writeCavebotLog(Status, Text, isError := false) {
    ; msgbox, % hSB ", " hCavebotLogsEdit ", " CavebotLogsHWND ", " CavebotLogsMinimized

    string := "`n" . A_Hour . ":" . A_Min . ":" . A_Sec, Text := "[" . Status . "] " . Text

    try {
        switch Status {
            case "":
                prefix := Waypoint != "" ? string . " | [" . tab . "] WP" . Waypoint . ": " Text " ." : string . " | " Text . "."
                FileAppend, % prefix, % "Cavebot\Logs\" . currentScript . ".txt"
            case "ERROR":
                isError := true
                prefix := Waypoint != "" ? string . " | [" . tab . "] WP" . Waypoint . ": " Text " ." : string . " | " Text "."
                FileAppend, % prefix . "`n", % "Cavebot\Logs\" . currentScript . ".txt"
            case "Targeting", case "Looting", case "Attack Spell":
                FileAppend, % string . " | " . Text . ".", Cavebot\Logs\%currentScript%.txt
            default:
                FileAppend, % Waypoint != "" ? string . " | [" . tab . "] WP" . Waypoint . ": " Text " ." : string . " | " Text ".", Cavebot\Logs\%currentScript%.txt
        }

    } catch e {
        OutputDebug(A_ThisFunc, e.Message . " | " . e.What)
    }

    if (isError = true) {
        Gui, CavebotLogs:Default
        ERRORS_COUNTER++
        if (ERRORS_COUNTER > 500) {
            global ERRORS_COUNTER := 1
            global ERRORS_LOG := ""
            global ERRORS_LOG := {}
        }

        ERRORS_LOG.Push(Waypoint != "" ? string . " | [" . tab . "] WP" . Waypoint . ": " Text "." : string . " | " Text . ".")
        SB_SetText(ERRORS_COUNTER, errorsCounterPart)
    }

    /**
    writing the logs outside the function is causing memory leak??
    */
    if (CavebotLogsMinimized = false) {
        FileRead, logsFile, Cavebot\Logs\%currentScript%.txt
        try {
            AppendText(hCavebotLogsEdit, &logsFile)
            SendMessage, 0x0115, 7, 0,, ahk_id %hCavebotLogsEdit% ;WM_VSCROLL
        } catch {
        }
    }

    StringReplace logsFile, logsFile, `n, `n, All UseErrorLevel
    if (ErrorLevel > 300) {
        try FileDelete, Cavebot\Logs\%currentScript%.txt
        catch {
        }

        fast_creation := true

        if (CavebotLogsMinimized = false) {
            Gui, CavebotLogs:Destroy
            Gosub, CreateCavebotLogSGUI ; if not destroy and recreate the GUI, for some reason is causing memory leak(increses constantly over time)
        }
        try  {
            FileAppend, % Waypoint != "" ? string . " | [" . tab . "] WP" . Waypoint . ": logs cleared." : string . " | logs cleared.", Cavebot\Logs\%currentScript%.txt
        } catch e {
            OutputDebug(A_ThisFunc, e.Message . " | " . e.What)
        }
    }

    return
}

AppendText(hEdit, ptrText) {
    SendMessage, 0x000E, 0, 0,, ahk_id %hEdit% ;WM_GETTEXTLENGTH
    SendMessage, 0x00B1, ErrorLevel, ErrorLevel,, ahk_id %hEdit% ;EM_SETSEL
    SendMessage, 0x00C2, False, ptrText,, ahk_id %hEdit% ;EM_REPLACESEL
    return
}

ClearLog:
    FileDelete, Cavebot\Logs\%currentScript%.txt
    GuiControl, , CavebotLogsEdit, % ""
    Gui, CavebotLogs:Default
    global ERRORS_COUNTER := 0
    SB_SetText(ERRORS_COUNTER, errorsCounterPart)
return

MinimizeLogsWindow:
    IniWrite, 1, %DefaultProfile%, others_cavebot, CavebotMinimized
    Gui, CavebotLogs:Minimize
return

CheckWhiteArrowActionBar() {
    vars := ""
    try {
        vars := ImageClick({"x1": 0, "y1": 0, "x2": 0, "y2": 0
                , "image": "actionbar_whitearrow"
                , "directory": ImagesConfig.cavebotFolder
                , "variation": 40
                , "funcOrigin": A_ThisFunc
                , "debug": false})
    } catch e {
        _Logger.exception(e, A_ThisFunc)
    }
    if (vars.x) {
        Gui, Carregando:Destroy
        msg := LANGUAGE = "PT-BR" ? "? necessário deixar as duas Action Bars na primeira posição, de forma que os dois botões fiquem cinzas(e não brancos)." : "It's needed to to let the two Action Bars on the first position, in a way where the two buttons get gray(and not white)."

        msgbox_image(msg, "Data\Files\Images\GUI\Others\actionbar_whitearrow.png", 3)
        Reload()
    }
    return

}

CheckTaskbarWidth() {
    WinGetPos,,,_w_, _h_, ahk_class Shell_TrayWnd
    ; msgbox, % _w_ ", " _h_
    if (_w_ = "")
        return
    if (_w_ < A_ScreenWidth - 100) {
        Gui, Carregando:Destroy
        Msgbox, 48,, % LANGUAGE = "PT-BR" ? "Detectado que a sua barra de tarefas est? na lateral da tela(" _w_ ").`n`n? necess?rio deixar a barra de tarefas no canto de baixo da tela para funcionar corretamente." : "Detected that your taskbar is on the side of the (" _w_ ").`n`nIt's needed to keep the taskbar in the bottom of the screen to work properly."
        Reload()
    }
    return

}


#if !WinActive("ahk_class " _App.GUI_CLASS)
!+r::
    Goto, Reload
return
#if

PauseBot_Info:
    gosub, InfoPauseBot

    Gosub, Pausar
return
; MButton::


Pause::
Pausar:
    PauseCavebot()
return

PauseCavebot() {
    Critical, On
        new _ReleaseModifierKeys()
    BlockInput, MouseMoveOff
    IniWrite, 1, %DefaultProfile%, others_cavebot, CavebotPaused
    _CavebotExe.writePaused(true)
    ToolTip
    Gui, CavebotLogs:Default
    string_pause := "[" pausado_string "] "
    SB_SetText(string_pause "" sessionString ": " sessionHour "h " sessionMinute "m " sessionSecond "s ", sessionCounterPart)
    Critical, Off
    Pause
}


DisableCloseButton(HWND = "", A = True) {

    ; SC_CLOSE = 0xF060, MF_BYCOMMAND = 0x0

    ; MF_ENABLED = 0x0, MF_GRAYED = 0x1, MF_DISABLED = 0x2

    HWND := ((HWND + 0) ? HWND : WinExist("A"))

    HMNU := DllCall("GetSystemMenu", "UInt", HWND, "UInt", A ? False : True)

    DllCall("EnableMenuItem", "UInt", HMNU, "UInt", 0xF060, "UInt", A ? 0x3 : 0x0)

    return DllCall("DrawMenuBar", "UInt", HWND)

}

InfoPauseBot:
    pause := new _CavebotIniSettings().get("pauseHotkey")
    unpause := new _CavebotIniSettings().get("unpauseHotkey")

    Gui, InfoPauseBot:Destroy
    Gui, InfoPauseBot:+AlwaysOnTop +Owner -MinimizeBox
    y_infowindow := A_ScreenHeight / 5
    Gui, InfoPauseBot:Add, Text, x10 y5 w250, % txt("Você pode pausar o Cavebot/Targeting usando hotkeys:","You can pause the Cavebot/Targeting using hotkeys:") "`n[ Pause ] " pause "`n[ Unpause ] " unpause "`n[ Reload ] Alt + Shift + R"
    Gui, InfoPauseBot:Add, Text, x10 y+15 w250,% txt("É possível alterar as hotkeys no menu superior ""Arquivo"" -> ""Configurações"".", "It's possible to change the hotkeys on top menu ""File"" -> ""Settings"".")
    Gui, InfoPauseBot:Show, NoActivate y%y_infowindow%, Hotkeys shortcut
return
InfoPauseBotGuiClose:
    Gui, InfoPauseBot:Destroy
return

; +MButton::


Unpause:
    UnpauseCavebot()
return

UnpauseCavebot()
{
    Critical, On
    if (A_IsPaused)
    {
        Pause, Off
        IniWrite, 0, %DefaultProfile%, others_cavebot, CavebotPaused
        _CavebotExe.writePaused(false)
        Gui, InfoPauseBot:Destroy
        string_pause := ""
        ; SetTimer, SessionCounter, On
        SB_SetText(string_pause "" sessionString ": " sessionHour "h " sessionMinute "m " sessionSecond "s ", sessionCounterPart)
        if (backgroundMouseInput = false OR backgroundKeyboardInput = false)
            WinActivate()
    }

    Critical, Off
}

DeleteIconsFromMemory:
    /**
    Delear todos os icones da mem?ria criados pela fun??o GuiButtonIcon antes de criar
    */
    if (ICON_COUNTER > 0) {

        Loop, %ICON_COUNTER% {
            IL_Destroy(normal_il%A_Index%)
            normal_il%A_Index% := ""
        }
        ICON_COUNTER := 0
    }
return

CreateCavebotLogSGUI:
    /**
    AlertsSystem uses the name to send pause commands
    if change the format of window title needs to change on AlertsSystem.ahk
    */
    name := StrReplace( _AbstractExe.getRandomExeNameFromList(), ".exe", "")

    prefix := clientIdentifier() = "Drakmora" ? name :  "Logs (v" version ")"
    suffix := clientIdentifier() = "Drakmora" ? "" : " - " currentScript

    cavebotLogsWindowTitle := prefix " - " suffix
    ; cavebotLogsWindowTitle := "Chrome Logs (v" version ") - " currentScript

    if (CavebotLogsMinimized = true) {
        if (fast_creation = true)
            return
        goto, MinimizeCavebotLogs
    }
    ; global COUNT_ICON := true
    ; gosub, DeleteIconsFromMemory

    Gui, CavebotLogs:Destroy
    ; Gui, CavebotLogs:+alwaysontop +Border -Caption +ToolWindow
    ; if (cavebotLogsAlwaysOnTop = 1)
    Gui, CavebotLogs:+alwaysontop +Border -Caption
    ; else
    ; Gui, CavebotLogs:+Border -Caption

    gosub, checkFileSizeDelete

    if (fast_creation = false) {
        FileRead, logsFile, Cavebot\Logs\%currentScript%.txt
        if (ErrorLevel = 1)
            logsFile := ""
    }

    CavebotLogsMinWidth := (scriptSettingsObj.charCoordsFromMemory = true) ? 500 : 550

    if (CavebotLogsWidth < CavebotLogsMinWidth)
        CavebotLogsWidth := CavebotLogsMinWidth
    if (CavebotLogs_lines < 5)
        CavebotLogs_lines := 5

    logs_width := CavebotLogsWidth - 38

    try Gui, CavebotLogs:Add, Edit, x8 y5 w%logs_width% r%CavebotLogs_lines% vCavebotLogsEdit hwndhCavebotLogsEdit ReadOnly +VScroll -HScroll
    catch e {
        Gui, CavebotLogs:Destroy
        _Logger.exception(e, A_ThisFunc)

        Goto, CreateCavebotLogSGUI
    }

    if (fast_creation = false) {
        GuiControl,, CavebotLogsEdit, %logs%

        FileRead File, Cavebot\Logs\%currentScript%.txt
        StringReplace File, File, `n, `n, All UseErrorLevel
        NumeroLinhas := ErrorLevel
        File := ""
        ; msgbox, % ErrorLevel
        if (NumeroLinhas > 299) {
            FileDelete, Cavebot\Logs\%currentScript%.txt
            if (ErrorLevel != 0) {
                try
                    Run, Cavebot\%currentScript%\
                catch
                    return
                Gui, Carregando:Destroy
                MSgbox, 16,, Erro ao apagar o arquivo de logs em "cavebotlog_%currentScript%.txt", apague o arquivo manualmente antes de continuar.`n`nError: %ErrorLevel%`nError Code: %A_LastError%
                Reload()
            }
            Gosub, ClearLog
        }
    }

    Gui, CavebotLogs:Add, Button,x7 y+1 w50 h21 gMinimizeCavebotLogs hwndMinimizarLog_Button, Minimize

    Gui, CavebotLogs:Add, Button, x+3 yp+0 w58 h21 gClearLog, Clear logs

    try Gui, CavebotLogs:Add, Checkbox, x+3 yp+0 w66 h21 gTransparentCavebotLogs vTransparentCavebotLogs Checked%TransparentCavebotLogs% 0x1000, Transparent
    catch e {
        Gui, CavebotLogs:Destroy
        OutputDebug(A_ThisLabel, "Failed to create logs GUI: " . e.Message . " | " . e.What)
        _Logger.exception(e, A_ThisFunc)

        Goto, CreateCavebotLogSGUI
    }

    width := CavebotLogsWidth - 215
        , x := logs_width + 10
        , heigth_slider := CavebotLogs_lines + 3
    try Gui, CavebotLogs:Add, Slider, xm+178 yp-1 h20 w%width% gApplyWidth vCavebotLogsWidth Range%CavebotLogsMinWidth%-1000 ToolTipBottom TickInterval20 Line20 , %CavebotLogsWidth%
    catch e {
        Gui, CavebotLogs:Destroy
        _Logger.exception(e, A_ThisFunc)

        Goto, CreateCavebotLogSGUI
    }

    try Gui, CavebotLogs:Add, Slider, x%X% y1 r%heigth_slider% w20 vCavebotLogs_lines gCavebotLogs_lines Range5-15 ToolTipBottom TickInterval1 Vertical, %CavebotLogs_lines%
    catch e {
        Gui, CavebotLogs:Destroy
        OutputDebug(A_ThisLabel, "Failed to create logs GUI: " . e.Message . " | " . e.What)
        _Logger.exception(e, A_ThisFunc)

        Goto, CreateCavebotLogSGUI
    }

    try Gui, CavebotLogs:Add, StatusBar, gStatusBarClick vStatusBarCavebot hwndhSB,
    catch e {
        Gui, CavebotLogs:Destroy
        _Logger.exception(e, A_ThisFunc)

        Goto, CreateCavebotLogSGUI
    }

    Gui, CavebotLogs:Default
    ; SB_SetParts(20, 20, 20, 61, 58, 42, 130)
    charPositionPartWidth := 155
    if (scriptSettingsObj.charCoordsFromMemory = true)
        charPositionPartWidth := 113

    SB_SetParts(20, 20, 20, 61, 58, 42, charPositionPartWidth)

    height := (heigth_slider * 13) + 20 ; statusbar

    gosub, CheckCavebotLogsPosition

    try Gui, CavebotLogs:Show, x%CavebotLogsWindowX% y%CavebotLogsWindowY% w%CavebotLogsWidth% h%height% NoActivate, % cavebotLogsWindowTitle
    catch e {
        OutputDebug(A_ThisLabel, "Failed to Show logs GUI: " . e.Message . " | " . e.What)
    }
    if (TransparentCavebotLogs = 1)
        WinSet, Transparent, %CavebotLogsTransparency%, % cavebotLogsWindowTitle

    ; global COUNT_ICON := false
    gosub, afterCreateLogsGUI

return

CheckCavebotLogsPosition:
    CavebotLogsWindowX := CavebotLogsWindowX = "" ? 10 : CavebotLogsWindowX
        , CavebotLogsWindowY := CavebotLogsWindowY = "" ? 550 : CavebotLogsWindowY
        , CavebotLogsWindowX := (CavebotLogsWindowX > A_ScreenWidth - 100) ? A_ScreenWidth / 2 : CavebotLogsWindowX
        , CavebotLogsWindowY := (CavebotLogsWindowY > A_ScreenHeight - 100) ? A_ScreenHeight / 2 : CavebotLogsWindowY
        , CavebotLogsWindowX := CavebotLogsWindowX < -3000 ? 10 : CavebotLogsWindowX
        , CavebotLogsWindowY := CavebotLogsWindowY < 0 ? 0 : CavebotLogsWindowY

    if (CavebotLogsMinimized && CavebotLogsWindowX < 0) {
        CavebotLogsWindowX := 10
    }

    if (CavebotLogsMinimized && CavebotLogsWindowY < 0) {
        CavebotLogsWindowY := 0
    }
return

checkFileSizeDelete:
    /**
    for some reason there are files getting with much more lines than 300, so need to keep track of the file size to delete
    if gets too big (higher than 100kb)
    */
    try FileGetSize, logsSize, Cavebot\Logs\%currentScript%.txt, K
    catch {
        return
    }
    if (logsSize > 150)
        FileDelete, Cavebot\Logs\%currentScript%.txt
return

afterCreateLogsGUI:
    WinGet, CavebotLogsHWND, ID, % cavebotLogsWindowTitle
    Gui, CavebotLogs:Default
    SB_SetText(" C", cavebotPart)
        , SB_SetText("T", targetingPart)
        , SB_SetText("L", lootingPart)

    if (!CavebotEnabled) {
        SB_SetIcon(disabledIconDll, disabledIconNumber, cavebotPart)
    }

    if (!targetingEnabled) {
        TargetingSystem.setStatusBarIcon(disabledIconDll, disabledIconNumber)
    }

    if (targetNotReleasedIcon) {
        TargetingSystem.setStatusBarIcon(disabledIconDll, 208)
    }

    if (!lootingObj.settings.lootingEnabled) {
        SB_SetIcon(disabledIconDll, disabledIconNumber, lootingPart)
    }

    SB_SetIcon("imageres.dll", isWin11() ? 230 : 229, reloadPart), SB_SetText("Reload", reloadPart)
    SB_SetIcon("shell32.dll", isWin11() ? 250 : 266 , sessionCounterPart)

    SB_SetIcon("mmcndmgr.dll", 35, pausePart)
        , SB_SetText("Pause", pausePart)
        , SB_SetIcon("shell32.dll", 234, errorsCounterPart)
        , SB_SetText(ERRORS_COUNTER, errorsCounterPart)
        , SB_SetIcon("Data\Files\Images\GUI\Icons\running2.ico",0, charPositionPart)
        , SB_SetText("Char position", charPositionPart)
        , SB_SetText(string_pause := (A_IsPaused) ? "[" pausado_string "]" : "" sessionString ": " sessionHour "h " sessionMinute "m " sessionSecond "s ", sessionCounterPart)

    if (!fast_creation) {
        SendMessage, 0x0115, 7, 0,, ahk_id %hCavebotLogsEdit% ;WM_VSCROLL
    }

return

MinimizeCavebotLogs:
    CavebotLogsMinimized := true
    IniWrite, 1, %DefaultProfile%, cavebot_settings, CavebotLogsMinimized

    w := 110

    GetWindowPos_CavebotLogs()
    Gui, CavebotLogs:Destroy
    ; Gui, CavebotLogs:+ToolWindow +AlwaysOnTop -Caption +Border
    Gui, CavebotLogs:+AlwaysOnTop -Caption +Border
    Gui, CavebotLogs:Add, Button, x7 y6 h33 w%w% gMaximizeCavebotLogs hwndMaximize_Button, % txt("Visualizar`nLogs", "Show`nLogs")
    Gui, CavebotLogs:Add, Button, x7 y+3 h23 w%w% gMinimizeLogsWindow, % ("Minimizar janela", "Minimize window")
    GuiButtonIcon(Maximize_Button, "compstui.dll", 7, "a0 l2 b0 t0 s20")
    Gui, CavebotLogs:Add, Pic, x0 y0 0x4000000, % "Data\Files\Images\GUI\GrayBackground.png"
    x := A_ScreenWidth / 2

    gosub, CheckCavebotLogsPosition

    Gui, CavebotLogs:Show, % "x" CavebotLogsWindowX " y" CavebotLogsWindowY " w" w + 15 " h71 NoActivate", % cavebotLogsWindowTitle
    WinGet, CavebotLogsHWND, ID, % cavebotLogsWindowTitle

    ; goto, MinimizeLogsWindow
return

MaximizeCavebotLogs:
    IniWrite, 0, %DefaultProfile%, others_cavebot, CavebotMinimized
    CavebotLogsMinimized := false
    IniWrite, 0, %DefaultProfile%, cavebot_settings, CavebotLogsMinimized
    GetWindowPos_CavebotLogs()
    Gosub, CreateCavebotLogSGUI
    Gosub,TransparentCavebotLogs
return

SetTransparency_SpecialActions:
    global CavebotLogsTransparency := 160
    if (TransparentCavebotLogs = 1)
        WinSet, Transparent, %CavebotLogsTransparency%, % cavebotLogsWindowTitle
    Else
        WinSet, Transparent, 255, % cavebotLogsWindowTitle
return

TransparentCavebotLogs:
    GuiControlGet, TransparentCavebotLogs
    IniWrite, %TransparentCavebotLogs%, %DefaultProfile%, cavebot_settings, TransparentCavebotLogs
    gosub, SetTransparency_SpecialActions
return
CavebotLogs_lines:
    GuiControlGet, CavebotLogs_lines
    if (CavebotLogs_lines_old = CavebotLogs_lines)
        return
    CavebotLogs_lines_old := CavebotLogs_lines
    IniWrite, %CavebotLogs_lines%, %DefaultProfile%, cavebot_settings, CavebotLogs_lines

    GetWindowPos_CavebotLogs()

    Gosub, CreateCavebotLogSGUI
    gosub, writeGuiLogs
return

ApplyWidth:
    GuiControlGet, CavebotLogsWidth
    if (CavebotLogsWidth_old = CavebotLogsWidth)
        return
    CavebotLogsWidth_old := CavebotLogsWidth
    IniWrite, %CavebotLogsWidth%, %DefaultProfile%, cavebot_settings, CavebotLogsWidth

    GetWindowPos_CavebotLogs()

    Gosub, CreateCavebotLogSGUI
    Gosub, writeGuiLogs
return

GetWindowPos_CavebotLogs() {
    WinGetPos, x, y, w, h, ahk_id %CavebotLogsHWND%
    if (x < -3000 OR y < -3000)
        return
    if (x != "") {
        CavebotLogsWindowX := x, CavebotLogsWindowY := y
        IniWrite, %x%, %DefaultProfile%, cavebot_settings, CavebotLogsWindowX
        IniWrite, %y%, %DefaultProfile%, cavebot_settings, CavebotLogsWindowY
    }
    return
}

Reload:
    Reload()
return

Reload() {
    Critical, On
    IniDelete, %DefaultProfile%, cavebot, CurrentWaypointTab
    IniDelete, %DefaultProfile%, cavebot, CurrentWaypoint
    Gui, Carregando:Destroy
    Gui, Carregando:-Caption +Border +Toolwindow +AlwaysOnTop
    Gui, Carregando:Add, Text,, % LANGUAGE = "PT-BR" ? "Recarregando, por favor aguarde..." : "Reloading, please wait..."
    Gui, Carregando:Add, Progress, x10 y+5 w170 h20 cRed vMyProgress, 0
    Gui, Carregando:Show, NoActivate,9
    GuiControl,Carregando:, MyProgress, 10
    SetTimer, RunCavebot, Delete
    SetTimer, RunTargeting, Delete
    GuiControl,Carregando:, MyProgress, 30
    GuiControl, 3:Disable, ReloadButton
    GuiControl,Carregando:, MyProgress, 50
    GuiControl,Carregando:, MyProgress, 60
    Process, Close, Alarm.exe
    GuiControl,Carregando:, MyProgress, 70
    Gdip_Shutdown(pToken)

    GuiControl,Carregando:, MyProgress, 80

    GuiControl,Carregando:, MyProgress, 90
    GetWindowPos_CavebotLogs()

    GuiControl,Carregando:, MyProgress, 100
    Reload
    Pause
    Pause
    return
}

ProgressBar(current, final) {
    percentage := 100 - (final - current)
    if (percentage > 100)
        percentage = 100
    return percentage
}

WM_LBUTTONDOWN() {
    if (A_GuiControl = "StatusBarCavebot")
        return
    try PostMessage, 0xA1, 2 ; 0xA1 = WM_NCLBUTTONDOWN
    catch {
    }
    SetTimer, GetWindowPos_CavebotLogsTimer, Delete
    SetTimer, GetWindowPos_CavebotLogsTimer, -1000
    SetTimer, GetWindowPos_CavebotLogsTimer, -3000
    return
}

GetWindowPos_CavebotLogsTimer:
    GetWindowPos_CavebotLogs()
return

StatusBarClick:
    Gui, CavebotLogs:Default
    ; global reloadPart := 4
    ; global pausePart := reloadPart + 1
    ; global errorsCounterPart := pausePart + 1
    ; global charPositionPart := errorsCounterPart + 1
    ; global sessionCounterPart := charPositionPart + 1
    if (A_EventInfo = errorsCounterPart) {
        string := ""
        for key, value in ERRORS_LOG
            string .= "[" key "] " StrReplace(value, "`n", "") "`n"

        Gui, ErrorsGUI:Destroy
        Gui, ErrorsGUI:+AlwaysOnTop -MinimizeBox
        Gui, ErrorsGUI:Add, Edit, vErrorsLog x10 y5 w500 h300 ReadOnly,
        Gui, ErrorsGUI:Show,, Errors log [%version%]
        GuiControl, ErrorsGUI:, ErrorsLog, % string
        return

    }
    if (A_EventInfo = targetingPart) {
        if (A_IsCompiled)
            return
        Gui, TargetingStatusGUI:Destroy
        Gui, TargetingStatusGUI:+AlwaysOnTop -MinimizeBox
        Gui, TargetingStatusGUI:Add, Edit, vTargetingObjStatus x10 y5 w500 h300 ReadOnly,
        Gui, TargetingStatusGUI:Show,, Targeting System Info [%version%]
        GuiControl, TargetingStatusGUI:, TargetingObjStatus, % serialize(targetingSystemObj)
        return

    }
    if (A_EventInfo = cavebotPart) {
        if (A_IsCompiled)
            return
        Gui, CavebotStatusGUI:Destroy
        Gui, CavebotStatusGUI:+AlwaysOnTop -MinimizeBox
        Gui, CavebotStatusGUI:Add, Edit, vCavebotObjStatus x10 y5 w500 h300 ReadOnly,
        Gui, CavebotStatusGUI:Show,, Cavebot System Info [%version%]
        GuiControl, CavebotStatusGUI:, CavebotObjStatus, % serialize(cavebotSystemObj)
        return

    }

    if (A_EventInfo = reloadPart)
        Goto, Reload

    if (A_EventInfo = pausePart)
        Goto, PauseBot_Info

    if (A_EventInfo = sessionCounterPart) {
        resetCavebotSession()
        return
    }
return
ErrorsGUIGuiEscape:
ErrorsGUIGuiClose:
    Gui, ErrorsGUI:Destroy
return

UpdateSession:
    SB_SetText(sessionString ": " sessionHour "h " sessionMinute "m " sessionSecond "s " string_pause " " string_multiclient, sessionCounterPart)
return

SessionCounter:
    sessionSecond++
    if (sessionSecond > 60) {
        sessionSecond := 1
        sessionMinute++
    }
    if (sessionMinute > 60) {
        sessionMinute := 0
        sessionHour++
    }
    Gui, CavebotLogs:Default
    string_pause := (A_IsPaused) ? "[" pausado_string "]" : ""

    ; SB_SetText(sessionString ": " sessionHour "h " sessionMinute "m " sessionSecond "s " string_pause " #" tibia_title "#", 2)
    ; SB_SetText(sessionString ": " sessionHour "h " sessionMinute "m " sessionSecond "s " string_pause " " string_multiclient, 2)
    SB_SetText(sessionString ": " sessionHour "h " sessionMinute "m " sessionSecond "s " string_pause " " string_multiclient, sessionCounterPart)
    IniWrite, 0, %DefaultProfile%, others_cavebot, CavebotPaused
    _CavebotExe.writePaused(false)
return

ExitCavebot()
{
        new _ReleaseModifierKeys()
    IniDelete, %DefaultProfile%, cavebot, CurrentWaypointTab
    IniDelete, %DefaultProfile%, cavebot, CurrentWaypoint
    ExitApp
}

autoShowWaypointsTimerLabel:
return

startupException(e)
{
    Gui, Carregando:Destroy
    Msgbox, 48, % (StrReplace(A_ScriptName, ".exe", "")) " " e.What, % e.Message
    Reload()
}


/*
to be able to open minimap viewer in main GUI
when failing to ad waypoint
*/
minimapViewer:
return

/*
to include minimapGUI
*/
minimapViewerMenuHandler:
return
/*
to include CavebotHandler
*/
DestroySQMGUIs:
ShowWaypointsTimer:
return

#Include __Files\default_functions.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\default_functions.ahk
#Include __Files\default_cavebot_functions.ahk
#Include __Files\labels_minimap_cavebot.ahk
