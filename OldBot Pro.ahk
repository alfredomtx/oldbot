/*
OldBot é desenvolvido por Alfredo Menezes, Brasil.
Copyright © 2017. Todos os direitos reservados.

OldBot is developed by Alfredo Menezes, Brazil.
Copyright © 2017. All rights reserved.
*/

#WarnContinuableException Off
#SingleInstance, Force
#MaxMem 2048
SetWorkingDir %A_WorkingDir% ; Ensur;es a consistent starting directory.
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#KeyHistory 0
#MaxHotkeysPerInterval 200
#HotkeyInterval 200
#MaxThreadsPerHotkey 1
;@Ahk2Exe-IgnoreBegin
#Warn, ClassOverwrite, MsgBox
;@Ahk2Exe-IgnoreEnd
#MaxThreads 100 ; changed on 28/07/202
ListLines Off
SetDefaultMouseSpeed, 0
SetBatchLines, -1
DetectHiddenWindows On ; Allows a script's hidden main window to be detected.
SetTitleMatchMode 2 ; Avoids the nesed to specify the fulls path of the file
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
CoordMode, Tooltip, Screen
SetFormat, Float, 0.0
SetWinDelay, -1 ; ADDED ON 17/06/2023
SetControlDelay, -1 ; ADDED ON 17/06/2023


#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\default_profile.ahk
IniRead, LANGUAGE, %DefaultProfile%, settings, LANGUAGE, PT-BR

global WORKING_ON_GUI := 0


if (!A_IsCompiled) {
    LANGUAGE := "EN-US"
    ; LANGUAGE := "PT-BR"
    global WORKING_ON_GUI := 0
    ; global LOAD_ONLY_GUI := "Cavebot"
}

OnExit("ElfGUIGuiClose")


Gui, Carregando:-Caption +Border +Toolwindow +AlwaysOnTop
Gui, Carregando:Add, Text,, % LANGUAGE = "PT-BR" ? "Iniciando OldBot..." : "Starting OldBot..."
Gui, Carregando:Show, NoActivate,

global MAIN_OLDBOT_EXE := true
global version := _Version.CURRENT
global version2 := version
global BETA
if (_Version.BETA_ENABLED)
    BETA := _Version.BETA, BETAtext := BETA

IniWrite, % version, % "Data/Files/version.ini", settings, version

/*
Project files - more includes(with glabels) at the end
*/
#Include __Files\default_global_variables.ahk
#Include __Files\mouse_keyboard_functions.ahk

/*
Includes folder
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\_Core.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Actions\ICavebot.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Alerts.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Cavebot\ICavebot.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Client.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Fishing.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\GUI Classes.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\GUI.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IHealing.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IActionScripts.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IClientJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IComponents.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IExecutables.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ILibraries.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ILooting.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IMainOldBotObjects.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IObjects.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IPolicies.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IRequests.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IRunemaker.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ISettingsGuis.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ISioComponents.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ISupport.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Item Refill.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Navigation.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Persistent.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Reconnect.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Script.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Sio.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Targeting.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Waypoint.ahk
/*
Classes
*/
#Include __Files\Classes\_OldBotInitializer.ahk ; first

#Include __Files\Classes\_CreaturesHandler.ahk
#Include __Files\Classes\_LinksHandler.ahk

#Include __Files\Classes\Hotkeys\_HotkeysHandler.ahk
#Include __Files\Classes\_ItemsHandler.ahk

#Include __Files\Classes\_OldBotSettings.ahk

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Thread\_ThreadManager.ahk

#Include __Files\Classes\_TibiaWikiAPI.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Executables\_LauncherExe.ahk


/*
Others Classes
*/
#Include __Files\Classes\Hotkeys\_HotkeyRegister.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Encryptor.ahk
#Include __Files\Classes\_ProcessHandler.ahk
#Include __Files\Classes\_Telegram.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Magnifier.ahk
#Include __Files\Classes\Config\_ImagesConfig.ahk ; depends on TibiaClient
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\API\_API.ahk

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\IMarket.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\IMarketGUI.ahk

DIR := A_WorkingDir
global DefaultProfile
global DefaultProfile_SemIni

    new _OldBotInitializer()
global TibiaClient := new _TibiaClient()

; [OPEN-SOURCE] Bypass removed
; try {
;     _NewBypass.injectOnOldBotStart()
; } catch e {
;     _Logger.exception(e)
;     Msgbox, 16, % "Anticheat Bypass", % txt("Falha ao ativar anticheat bypass, por favor contate o suporte.", "Failed to activate anticheat bypass, please contact support.") . "`n`nError: " . e.Message, 10
; }

Gui, Conectando:Destroy
Gui, Conectando:-Caption +Border +Toolwindow +AlwaysOnTop
Gui, Conectando:Add, Text,x10 y5 vConectandoText,% LANGUAGE = "PT-BR" ? "Conectando, por favor aguarde..." : "Connecting, please wait..."
Gui, Conectando:Add, Progress, % LANGUAGE = "PT-BR" ? "x10 y+5 w155 h20 cBlue vMyProgress" : "x10 y+5 w124 h20 cBlue vMyProgress", 0
Gui, Conectando:Show, y100 NoActivate

_OldbotInitializer.forceOpenedByLauncher()

Goto, CarregarSettings

Gui, Carregando:Destroy
; [OPEN-SOURCE] Login GUI removed - skip directly to client selection
; #Include __Files\GUIs\login_GUI.ahk

; [OPEN-SOURCE] Login process removed
; #Include __Files\login\login_process.ahk

jkkkjjjkjkjk:
    #Include __Files\read_settings.ahk

    Gui, Conectando:Destroy
    GuiControl, Conectando:, MyProgress, 100


INITIAL_TEST:
    Gui, Carregando:Destroy

    CarregandoGUI("Loading resources...")

    InfoCarregando("Loading items...")
    loadItems := 1
    if (!A_IsCompiled) {
        loadItems := 1
        if (GetKeyState("Ctrl") = true)
            loadItems := 1
    }

    global ItemsHandler := new _ItemsHandler(loadItems, loadItems, true)


    /**
    classes initialization
    */

    global ThreadManager := new _ThreadManager()
    global MinimapFiles := new _MinimapFiles() ; start before CavebotWalker

    ; first
    InfoCarregando("Loading Settings...")

    ; second
    global CavebotScript := new _CavebotScript(currentScript)
    ; third

    global TibiaClient := new _TibiaClient()

    global ImagesConfig := new _ImagesConfig()

    global ClientAreas := new _ClientAreas() ; keep together with Images

        new _ClientFinder()

    if (!WORKING_ON_GUI) {
        InfoCarregando("Loading creatures...")
        try {
            loadCreatures := OldBotSettings.settingsJsonObj.loadingOptions.loadCreatures
            if (!A_IsCompiled)
                loadCreatures := 1
            if (GetKeyState("Ctrl") = true)
                loadCreatures := 1

            global CreaturesHandler := new _CreaturesHandler(loadCreatures)
        } catch e {
            Msgbox, 16,, % e.Message, 30
            ExitApp
        }
    }

    InfoCarregando("Loading resources...")

    global MemoryManager := new _MemoryManager() ; MemoryManager must be af

    global CavebotHandler := new _CavebotHandler()
    global AlertsSystem := new _AlertsSystem()
    global CavebotSystem := new _CavebotSystem()
    if (new _OldBotIniSettings().get("showFishing")) {
        global FishingSystem := new _FishingSystem()
    }

    global HealingSystem := new _HealingSystem(false)
    global LootingSystem := new _LootingSystem() ; before LootingHandler (for json settings)
    global DistanceLooting := new _DistanceLooting()
    global ItemRefillSystem := new _ItemRefillSystem()
    global SupportSystem := new _SupportSystem()
    global TargetingSystem := new _TargetingSystem()

    try {
        global CavebotWalker := new _CavebotWalker(true)
    } catch e {
        Gui, Carregando:Destroy
        IniWrite, % AutoLogin := 0, %DefaultProfile%, accountsettings, AutoLogin
        if (A_IsCompiled)
            Msgbox, 16,, % e.Message, 10
        else
            Msgbox, 16,, % e.Message "`n" e.What "`n" e.Extra "`n" e.Line, 10
        Reload()
        return
    }

    global AlertsHandler := new _AlertsHandler()
    global ActionScript := new _ActionScript()
    global ActionScriptHandler := new _ActionScriptHandler()
    global ClientSettings := new _ClientSettings()
    global GuiHandler := new _GuiHandler()
    global FloorSpy := new _FloorSpy()
    if (new _OldBotIniSettings().get("showFishing")) {
        global FishingHandler := new _FishingHandler()
    }
    global FullLightHandler := new _FullLightHandler()
    global HealingHandler := new _HealingHandler()
    global HotkeysHandler := new _HotkeysHandler()
    global LootingHandler := new _LootingHandler()
    global ItemRefillHandler := new _ItemRefillHandler()
    global PersistentHandler := new _PersistentHandler()
    global ReconnectHandler := new _ReconnectHandler()
    global SupportHandler := new _SupportHandler()
    global TargetingHandler := new _TargetingHandler()
    global AttackSpell := new _AttackSpell() ; TargetingHandler

    /*
    GUI Classes
    */

    global AlertsGUI := new _AlertsGUI()
    global CavebotGUI := new _CavebotGUI()
    if (new _OldBotIniSettings().get("showFishing")) {
        global FishingGUI := new _FishingGUI()
    }
    global HealingGUI := new _HealingGUI()
    global HotkeysFunctionsGUI := new _HotkeysFunctionsGUI()
    global HotkeysGUI := new _HotkeysGUI()
    global ItemRefillGUI := new _ItemRefillGUI()
    global LootingGUI := new _LootingGUI()
    global MinimapGUI := new _MinimapGUI()
    global ReconnectGUI := new _ReconnectGUI()
    global PersistentGUI := new _PersistentGUI()
    global ShortcutGUI := new _ShortcutGUI()
    global ScriptImagesGUI := new _ScriptImagesGUI()
    global ScriptListGUI := new _ScriptListGUI()
    if (new _OldBotIniSettings().get("showSio")) {
        global SioGUI := new _SioGUI()
    }
    global SupportGUI := new _SupportGUI()
    global AutoSpellsGUI := new _AutoSpellsGUI()
    global TargetingGUI := new _TargetingGUI()

    /*
    Other Classes
    */
    InfoCarregando("Loading waypoints...")
    ; action script before waypoint handler
    global WaypointHandler := new _WaypointHandler()
    global WaypointValidation := new _WaypointValidation()

    InfoCarregando("Loading resources...")

    global ScriptImages := new _ScriptImages()
    global ScriptJson := new _ScriptJson()
    global ScriptJsonValidation := new _ScriptJsonValidation()

    global ScriptRestriction := new _ScriptRestriction()
    global LinksHandler := new _LinksHandler()
    global ListviewHandler := new _ListViewHandler()
    global TelegramAPI := new _Telegram()
    global WaypointImporter := new _WaypointImporter()
    global WaypointRecorder := new _WaypointRecorder()
    global CoordinateViewer := new _WaypointViewer()

    InfoCarregando("Creating GUIs...")

    global MenuHandler := new _Menu()

    Gosub, CreateMenus
    Gosub, CreateCavebotMenu
    Gosub, CreateItemListMenu

    MenuHandler.loadTutorialMenuFromJSON()
    MenuHandler.createTutorialMenuFromJSON()

    #Include __Files\GUIs\elfgui_GUI.ahk

    Gosub, ChangeMenus

    TempoAberto := A_TickCount, Segundos := 18000, Ms := Segundos * 1000
    SetTimer, ContagemTempoFechar, %Ms%

    CloseAllProcesses(true)

    global ICON_COUNTER = 0 ; variável que controla quantos itens foram criados com a função GuiButtonICon junto da interface, para ser usado no label DeleteIconsFromMemory e não dar memory leak sempre que abre a GUI

    global buttonFolder := "Data\Files\Images\GUI\Buttons"
    global checked_img := buttonFolder "\checkbox_checked.png"
    global unchecked_img := buttonFolder "\checkbox_unchecked.png"

    ; IniDelete, %DefaultProfile%, advanced, TibiaClientID

    InfoCarregando("Creating functions GUI...")
    gosub, readVisibleShortcuts
    if (ScriptsShortcut_minimized = 1)
        Gosub, EsconderShortcutGUI
    else
        Gosub, CreateShortcutGUI
    LoadingGUI = 0

    if (!WORKING_ON_GUI) {
        ClientSettings.checkSettingsRoutine()

        OldbotSettings.startFunctions("CavebotGUI","LoginHotkey1","LoginHotkey1_2", "", DefaultProfile)
        OldbotSettings.startFunctions("CavebotGUI","LoginHotkey2","LoginHotkey2_2", "", DefaultProfile)

        IniRead, TibiaClientID, %DefaultProfile%, advanced, TibiaClientID, %A_Space%


        ; [OPEN-SOURCE] Bypass check removed - always show startup GUI
        Gui, startOldBotGUI:Destroy
        Gui, startOldBotGUI:-Caption +Border +Toolwindow +AlwaysOnTop
        Gui, startOldBotGUI:Add, Text, x10 y5, % "Starting functions..."
        Gui, startOldBotGUI:Add, Progress, y+10 HwndpHwnd1 +0x8 w150
        PostMessage,0x40a,1,38,, ahk_id %pHwnd1%
        Gui, startOldBotGUI:-Caption +Border +Toolwindow +AlwaysOnTop
        Gui, startOldBotGUI:Show, y100 NoActivate,

        start_load := false

        global startingBot := true
        OldbotSettings.autoStartFunctions()
        startingBot := false

        InfoCarregando("Checking settings...")
        Gui, startOldBotGUI:Destroy

        /*
        if (news_oldbot != "" && LANGUAGE = "PT-BR") {
        Gui, Carregando:Destroy
        Msgbox, 64,Notícia OldBot!,  % news_oldbot
        }
        */
    }

    TibiaClient.updateSettingsFileMenu()

    Gosub, CavebotGUI

    try {
        if (lastSelectedTab := new _OldBotIniSettings().get("lastSelectedTab")) {
            GuiControl, CavebotGUI:Choose, MainTab, % lastSelectedTab
            Gosub, MainTab
        }
    } catch e {
        _Logger.exception(e, "lastSelectedTab")
    }


EndStartBot:
    OldBotSettings.afterOpenedLastActions()
    gosub, afterOpenedActions

    SetTimer, updateMenuTibiaClient, 30000, -99

return
return
return

NavigationLeaderTimer:
    _Navigation.run()
return

afterOpenedActions:
    if (!OldBotSettings.settingsJsonObj.others.ignoreCheckClientSettings && TibiaClient.isClientOpened() && (isTibia13Or14() || isRubinot())) {
        IniRead, firstSettingsCheck, %A_Temp%/oldbot.ini, settings, firstSettingsCheck, 0
        if (firstSettingsCheck = 0) && (new _InterfaceIniSettings().get("autoCheckClientSettings")) {
            Msgbox, 64,, % LANGUAGE = "PT-BR" ? "Esta é a primeira vez que o Cavebot está sendo executado, será realizado uma checagem de configurações do cliente primeiramente.`n`nClique em OK para prosseguir." : "This is the first that OldBot is running, now will be performed a check of the Client configuration.`n`nClick on OK to continue."
            Gosub, ChecarConfiguracoesCliente
            IniWrite, 1, %A_Temp%/oldbot.ini, settings, firstSettingsCheck
        }
    }
    ; seconds := 7200 ; 2 hours
    seconds := 14400 ; 4 hours
    ms := seconds "000"
    SetTimer, backupCurrentScript, % ms

    gosub, enableAllHotkeys

return

recordVideo:
    width := 1024
    height := 768

    offsetX := WindowX
    offsetY := WindowYc

    ffmpegDir := A_WorkingDir "\Data\Files\Third Part Programs\ffmpeg"

    videoFileName := StrReplace(TibiaClientTitle, "*", "") "_" A_Now

    ; ffmpeg -y -f gdigrab -framerate 30 -video_size 640x480 -offset_x 10 -offset_y 20 -show_region 1 -draw_mouse 1 -i desktop -c:v libx264 -r 30 -preset ultrafast -tune zerolatency -crf 25 -pix_fmt yuv420p video_comapre2.mp4
    try {
        Run, %ffmpegDir% -y -f gdigrab -framerate 30 -video_size %width%x%height% -offset_x %offsetX% -offset_y %offsetY% -show_region 1 -draw_mouse 1 -i desktop -c:v libx264 -r 30 -preset ultrafast -tune zerolatency -crf 25 -pix_fmt yuv420p video_comapre2.mp4
    } catch e {
        Msgbox, 48,, % "Failed to run recorder.`n`n" e.Message "`n" e.What

    }

return

checkEmptyQueueTimer:
    _ProcessQueue.checkEmptyQueue()
return

writeCavebotLog(Status, Text, isError := false) {
}

SelectedFunctions:
    ToggleSelectedFunctions()
return

ToggleSelectedFunctions() {
    global SelectedFunctions
    OldBotSettings.disableGuisLoading(true)
    global loadingGuisSelectedFunctions := true
    global startingFunctionsFromSelectedFunctions := true

    if (SelectedFunctions = 1) {
        try TibiaClient.checkClientSelected()
        catch e {
            SelectedFunctions := 0
            checkbox_setvalue("SelectedFunctions", SelectedFunctions)
            global loadingGuisSelectedFunctions := false
            global startingFunctionsFromSelectedFunctions := false
            OldBotSettings.enableGuisLoading(true)
            MsgBox, 64,, % e.Message, 2
            return
        }
    }

    selectedFunctionsHandleModule("healing")
    selectedFunctionsHandleModule("itemRefill")
    selectedFunctionsHandleModule("reconnect")
    selectedFunctionsHandleModule("support")

    value :="persistentsToggleAll"
    if (SelectedFunctions = 1)
        startingModuleMessage("persistent")
    else
        stoppingModuleMessage("persistent")
    if (selectedFunctionsObj[value] = 1) {
        previousValue := %value%
        %value% := SelectedFunctions
        ; checkbox_setvalue(value, SelectedFunctions)
        if (previousValue != SelectedFunctions) {
            gosub, %value%
            Sleep, 200
        }
    }

    if (SelectedFunctions = 1)
        startingModuleMessage("cavebot")
    else
        stoppingModuleMessage("cavebot")

    if (selectedFunctionsObj.cavebotEnabled && selectedFunctionsObj.targetingEnabled) {
        CavebotEnabled := SelectedFunctions
        TargetingEnabled := SelectedFunctions
        GuiControl, CavebotGUI:, CavebotEnabled, % SelectedFunctions
        GuiControl, CavebotGUI:, TargetingEnabled, % SelectedFunctions
        gosub, CavebotEnabled
        Sleep, 200
    } else {
        for _, value in cavebotFunctions
        {
            if (selectedFunctionsObj[value] = 1) {
                previousValue := %value%
                %value% := SelectedFunctions
                GuiControl, CavebotGUI:, % value, % SelectedFunctions
                if (previousValue != SelectedFunctions) {
                    gosub, %value%
                    Sleep, 200
                }
            }
        }
    }

    global startingFunctionsFromSelectedFunctions := false
    global loadingGuisSelectedFunctions := false
    if (SelectedFunctions = 1)
        Sleep, 250
    else
        Sleep, 250
    Gui, Carregando:Destroy
    OldBotSettings.enableGuisLoading(true)
}

selectedFunctionsHandleModule(moduleName) {
    global
    if (SelectedFunctions = 1)
        startingModuleMessage(moduleName)
    else
        stoppingModuleMessage(moduleName)
    writeSettings := false
    for _, functionName in %moduleName%Functions
    {
        if (selectedFunctionsObj[functionName] = 1) {
            previousValue := %functionName%
            ; msgbox, % key ", " functionName ", new " SelectedFunctions ", previous " previousValue
            %functionName% := SelectedFunctions, %moduleName%Obj[functionName] := SelectedFunctions
            GuiControl, CavebotGUI:, % functionName, % SelectedFunctions
            checkbox_setvalue(functionName "_2", SelectedFunctions)
            if (previousValue != SelectedFunctions) {
                writeSettings := true
                ; gosub, %functionName%
                Sleep, 100
            }
        }
    }
    if (writeSettings = true) {
        switch moduleName {
            case "healing": HealingHandler.saveHealing()
            case "itemRefill": ItemRefillHandler.saveItemRefill()
            case "reconnect": ReconnectHandler.saveReconnect()
            case "support": SupportHandler.saveSupport()
            default:
                msgbox, 48,, % "Module not expected: " moduleName
        }
        Sleep, 100

        switch SelectedFunctions {
            case true:
                ProcessExistOpenOldBot(%moduleName%ExeName, moduleName "ExeName", closeProcess := true)
                ; Sleep, 1000
            default:
                OldBotSettings.stopFunction(moduleName, functionName, closeProcess := true, saveJson := false)
        }
    }
    Gui, Carregando:Destroy
    return
}

InfoValidacaConta:
    Gui, InfoValidacaContaGUI:Destroy
    Gui, InfoValidacaContaGUI:+AlwaysOnTop +Owner -MinimizeBox
    Gui, InfoValidacaContaGUI:Add, Text, x10 y+5 w300, % LANGUAGE = "PT-BR" ? "Internet doméstica tem IP dinâmico, costuma mudar de vez em quando, principalmente quando a internet cai e volta." : "Domestic internet has dynamic IP, it happens to change from time to time, mainly when the internet goes down and up again."
    Gui, InfoValidacaContaGUI:Add, Text, x10 y+9 w300, % LANGUAGE = "PT-BR" ? "Se o seu IP mudar mais de 1 vez num período de 2 horas com o bot aberto, irá bloquear o login." : "If your IP changes more than 1 time in a period of 2 hours with the bot opened, the login will be blocked."
    Gui, InfoValidacaContaGUI:Add, Text, x10 y+9 w300, % LANGUAGE = "PT-BR" ? "Se estiver com muito problema com mudança de IP mude a validação do bot para PC_ID. Clique no menu superior ""Editar"" do bot e em ""Validação por PC_ID"".`n`nVocê pode mudar a validação da sua conta quando quiser, não há restrição ou limite para isto." : "If you have much problems with IP changes, change the validation of the bot to PC_ID`n`nYou can change the validation of your account whenever you want, there is no restriction or limit for this."
    Gui, InfoValidacaContaGUI:Show, y200, % LANGUAGE = "PT-BR" ? "Sobre validação de conta" : "About account validation"
return

AboutGUI:

    Links:="
        (Ltrim join|
            @@@ About @@@
            Copyright © OldBot by Alfredo de Menezes Torres, Brazil.
            Open Source Release.
            Version: " version "
            ‏‏‎

            @@@ Links @@@
            Website: http://www.oldbot.com.br
            Forum: http://www.oldbot.com.br/forums
            Facebook: https://www.facebook.com/tibiaoldbot
            Facebook group: https://www.facebook.com/groups/oldbot
            Youtube: https://www.youtube.com/oldbot
            ‏‏‎

            [ Close ]

            "
        )

    Gui, AboutGUI:Destroy
    Gui, AboutGUI:+AlwaysOnTop +Owner -MinimizeBox -Caption
    GUI, AboutGUI:+AlwaysOnTop
    Gui, AboutGUI: Color, ControlColor, Black
    Gui, AboutGUI: Font, CDefault, FixedSys
    Gui, AboutGUI:Add, ListBox, x5 y5 w680 h275 cLime gRunAboutGUI vLB1a,%Links%
    Gui, AboutGUI:show, W690 H285, Sobre OldBot
return
AboutGUIGuiEscape:
AboutGUIGuiClose:
    Gui, AboutGUI:Destroy
return
RunAboutGUI:
    Gui,AboutGUI: Submit, Nohide
    if (lb1a = "")
        return
    IfInString, lb1a, Close
    {
        Gui, AboutGUI:Destroy
        return
    }
    IfNotInString, lb1a, http
        return

    FoundPos := InStr(lb1a, ":", 0)
    StringTrimLeft, link, lb1a, FoundPos
    StringReplace, link, link, %A_Space%,, All
    ; msgbox, % FoundPos "`n" lb1a "`n" link
    ; msgbox, % lb1;a
    try
        run,%link%
    catch {
        Msgbox, 16,, Error opening link: %link%
    }
return

LicenseGUI:
    ; [OPEN-SOURCE] License GUI simplified
    Gui, LicenseGUI:Destroy
    Gui, LicenseGUI:+AlwaysOnTop +Owner -MinimizeBox
    Gui, LicenseGUI:Add, Text, x10 y+5, % LANGUAGE = "PT-BR" ? "Versão Open Source" : "Open Source Version"
    Gui, LicenseGUI:Show,, % LANGUAGE = "PT-BR" ? "Licença OldBot" : "OldBot License"
return
LicenseGUIGuiEscape:
LicenseGUIGuiClose:
    Gui, LicenseGUI:Destroy
return

SmartExit:
    if (SmartExit = 1)
        checkbox_setvalue("SmartExit", 1)
    else
        checkbox_setvalue("SmartExit", 0)

    IniWrite, %SmartExit%, %DefaultProfile%, settings, SmartExit
return

checkbox_handle:
    StringReplace, var, A_GuiControl, _text,, All
    value := % %var%

    switch (var) {
        case "navigationFollower":
            _Follower.CHECKBOX.toggle()
            return
        case "navigationLeader":
            _Navigation.CHECKBOX.toggle()
            return
    }

    checkbox_change(var)
    IfInString, var, _2
    {
        StringReplace, var_2, var, _2,, All
        %var_2% := %var%
        var_value := % %var_2%
        ; msgbox, %var_2% = %var_value%
        GuiControl, CavebotGUI:, %var_2%, %var_value%

        Goto, %var_2%
    }
    ; msgbox, % var
    ; msgbox, %var% = %value%
    Goto, %var%

    Checkbox2ShortcutScripts(GUIName, Checkbox2Name, Checkbox1Name, filename, section) {
        ; IniRead, Checkbox1Value, %filename%, %section%, %Checkbox1Name%, 0
        ; IniRead, Checkbox2Value, %filename%, %section%, %Checkbox2Name%, 0
        ; msgbox, %Checkbox1Name% = %Checkbox1Value%, %Checkbox2Name% = %Checkbox2Value%
        if (Checkbox2Value = 1) {
            ; msgbox, a 1
            %Checkbox1Name% := 1
            GuiControl,%GUIName%:, %Checkbox1Name%, 1
            Gosub, %Checkbox1Name%
        }
        if (Checkbox2Value = 0) {
            ; msgbox, a 0
            %Checkbox1Name% := 0
            GuiControl,%GUIName%:, %Checkbox1Name%, 0
            GuiControl,%GUIName%:, %Checkbox2Name%, 0
            Gosub, %Checkbox1Name%
        }
        return
    }

OldBotDocsLink:
    openURL("https://oldbot-tibia-bot.github.io/docs/#/")
return
OldBotDocs_ScriptSetup:
    openURL("https://oldbot-tibia-bot.github.io/docs/#/cavebot/script_setup")
return

OpenSite:
return
OpenSite_CriarConta:
return
AbrirYoutube:
    openURL("https://www.youtube.com/oldbot")
return

; [OPEN-SOURCE] Documentation links removed - original Google Docs no longer available
; See README.md for current documentation
LinkDocumentacaoOficial:
LinkDocumentacaoRequisitos:
LinkDocumentacaoRequisitosEN:
LinkDocumentacaoOficialEN:
return

AbrirPaginaLogin:
return

AbrirPaginaDoacao:
return

OpenVideo_playersbattlewindow:
    video := "targeting_extra_player_battle_window"
    title := txt("Como configurar o Battle List para players", "How to set up the Battle List for players")
    Goto, OpenVideo

OpenVideo:
    file := "Data\Files\Videos\" video ".mp4"
    try
        Run, %file%
    catch {
        Msgbox, 48,, % "Failed to open video file: " file
    }
return
Gui, VideoGUI:Destroy
Gui, VideoGUI:-MinimizeBox
Gui, VideoGUI: +LastFound
file := "Data\Files\Videos\" video ".mp4"
Gui VideoGUI: Add, ActiveX, w1280 h720 vWmp, WMPLayer.OCX
Wmp.Url := file
Gui VideoGUI: Show, , %title%
return
VideoGUIGuiEscape:
VideoGUIGuiClose:
    Gui, VideoGUI:Destroy
return

tutorialButtonNavigation:
    openURL(LinksHandler.Navigation.tutorial)
return

ListaVariaveisAutoHotkey:
    openURL("https://www.autohotkey.com/docs/Variables.htm#BuiltIn")
return

ContagemTempoFechar:
    SetFormat, float, 0.0
    FormatTime currentYear,, yyyy
    FormatTime currentMonth,, MM
    FormatTime Day,, dd
    Data = %Day%-%currentMonth%-%currentYear%
    IniWrite, %Data%, oldbot_profile.ini, settings, CheckEx
    TempoMs := A_TickCount - TempoAberto
    TempoSeg := TempoMs / 1000
    TempoMin := TempoSeg / 60
    TempoHor := TempoMin / 60
    if (TempoHor > 72) {
        if (Cavebot != 1) {
            Data = %Day%-%currentMonth%-%currentYear%
            FileAppend, %A_Hour%%A_Min%:%A_Sec% %A_WDay%/%A_MDay% close bot 72 `n`n, Data\Files\abrupt_close_log.txt
            IniWrite, %Data%, oldbot_profile.ini, settings, LastEx
            CloseAllProcesses(true)
            Goto, ElfGUIGuiClose

        }
    }
return

ProcessExist(Name) {
    Process,Exist,%Name%
    return Errorlevel
}

OldBotExeName:
    Gui, CustomExeNames:Submit, NoHide
    IniWrite, %OldBotExeName%, %DefaultProfile%, settings, OldBotExeName
return
cavebotExeName:
    Gui, CustomExeNames:Submit, NoHide
    IniWrite, %cavebotExeName%, %DefaultProfile%, settings, cavebotExeName
return

healingExeName:
    Gui, CustomExeNames:Submit, NoHide
    IniWrite, %healingExeName%, %DefaultProfile%, settings, healingExeName
return

ProfileGUI:
        new _ProfileGUI()
return
ProfileGUIGuiEscape:
ProfileGUIGuiClose:
    Gui, ProfileGUI:Destroy
return

CarregandoCavebotGUI:
    Gui, CarregandoCavebot:Destroy
    Gui, CarregandoCavebot:-Caption +Border +Toolwindow +AlwaysOnTop
    Gui, CarregandoCavebot:Add, Progress, y+8 HwndpHwnd1 +0x8 w120
    Gui, CarregandoCavebot:Show, NoActivate,
    PostMessage,0x40a,1,38,, ahk_id %pHwnd1%
return

MainTab:
    Gui, CavebotGUI:Default
    Gui, Submit, NoHide


    MainTab := StrReplace(MainTab, " ", "")

    /**
    the first tab to open is Cavebot
    if there is no LastTab active that means Cavebot is the one
    */
    if (lastTab = "")
        lastTab := "Cavebot"


    if (MainTab == "+") {
            new _OldBotSettingsGUI().open()
        GuiControl, CavebotGUI:Choose, MainTab, % lastTab
        return
    }

    ; OutputDebug("TAB", "Main: " MainTab " | Last: " lastTab)
    ; msgbox, % "Main: " MainTab "`nLast: " lastTab

    if (lastTab != MainTab) {
        try {
            GuiControl, Hide, Tab_%lastTab%
        } catch e {
        }

        try {
            loop, parse, child_tabs_%lastTab%, |
                GuiControl, Hide, % A_LoopField
        } catch e {
        }

        try {
            if (lastTab = "Cavebot")
                GuiControl, Hide, Tab_Script_Cavebot
        } catch e {
        }
    }

    lastTab := MainTab
        , MainTab := StrReplace(MainTab, " ", "")
    GuiControl, Show, Tab_%MainTab%

    if (MainTab = "Cavebot") {
        /**
        exibir a tab dos Waypoints(scripts ) somente se a tab do Cavebot selecionada for a de Waypoints, se for Configurações não exibir
        */
        GuiControl, Show, Tab_Script_Cavebot
    }

        new _OldBotIniSettings().submit("lastSelectedTab", MainTab)

    /**
    exibir as child_tabs
    */
    MainTab := StrReplace(MainTab, " ", "")
    if (child_tabs_%MainTab% != "") {
        try {
            loop, parse, child_tabs_%MainTab%, |
                GuiControl, Show, % A_LoopField
        } catch e {
        }
    }
    try {
        switch MainTab {
            case "Targeting":
                /**
                por algum motivo tem algo dando hide no dropdown ao mudar de tab
                */
                if (targetingControlsHidden2 = 0)
                    GuiControl, Show, creatureignoreDistance
            case "Healing":
                GuiControl, Show, % "Tab_Mana"
            case "Support":
                GuiControl, Show, % "SupportSpecialCondsTab"
        }
    } catch e {
    }

return

DeleteIconsFromMemory:
    /**
    Delear todos os icones da memória criados pela função GuiButtonIcon antes de criar
    */
    ; msgbox, % ICON_COUNTER
    if (ICON_COUNTER > 0) {

        Loop, %ICON_COUNTER% {
            IL_Destroy(normal_il%A_Index%)
            normal_il%A_Index% := ""
        }
        ICON_COUNTER := 0
    }
return

MainGUI:
    lastTab := ""

    ; msgbox, % ICON_COUNTER
    Gosub, DeleteIconsFromMemory

    ; msgbox, destroyed
    selectedTabs := {}
    load_order := []
    GUIs_to_create := {}

    GUIs_to_create.Push("Cavebot")

    if (new _OldBotIniSettings().get("showTargeting")) {
        GUIs_to_create.Push("Targeting")
    }
    if (new _OldBotIniSettings().get("showLooting")) {
        GUIs_to_create.Push("Looting")
    }

    if (!uncompatibleModule("healing") && new _OldBotIniSettings().get("showHealing")) {
        GUIs_to_create.Push("Healing")
    }

    if (new _OldBotIniSettings().get("showSupport")) {
        GUIs_to_create.Push("Support")
    }
    if (!uncompatibleModule("autoSpells") && new _OldBotIniSettings().get("showAutoSpells")) {
        GUIs_to_create.Push("Auto Spells")
    }
    if (!uncompatibleModule("itemRefill") && new _OldBotIniSettings().get("showItemRefill")) {
        GUIs_to_create.Push("Item Refill")
    }
    if (!uncompatibleModule("sioFriend") && new _OldBotIniSettings().get("showSio")) {
        GUIs_to_create.Push("Sio")
    }
    if (!uncompatibleModule("persistent") && new _OldBotIniSettings().get("showPersistent")) {
        GUIs_to_create.Push("Persistent")
    }
    if (!uncompatibleModule("alerts") && new _OldBotIniSettings().get("showAlerts")) {
        GUIs_to_create.Push("Alerts")
    }
    if (!uncompatibleModule("reconnect") && new _OldBotIniSettings().get("showReconnect")) {
        GUIs_to_create.Push("Reconnect")
    }
    if (!uncompatibleModule("hotkeys") && new _OldBotIniSettings().get("showHotkeys")) {
        GUIs_to_create.Push("Hotkeys")
    }
    if (!uncompatibleModule("navigation") && new _OldBotIniSettings().get("showNavigation")) {
        GUIs_to_create.Push("Navigation")
    }
    if (!uncompatibleModule("fishing") && new _OldBotIniSettings().get("showFishing")) {
        GUIs_to_create.Push("Fishing")
    }
    ; GUIs_to_create.Push("Others")
    ; GUIs_to_create.Push("Alarm")

    load_order.Push(selected_GUI)

    for key, value in GUIs_to_create
    {
        if (value = load_order[1])
            continue
        load_order.Push(value)
    }
    global MainTab := _Arr.first(load_order)

    /**
    fluxo de criação de tabs:
    1 - criar as "childs"
    2 - criar as mains
    3 - esconder todas as childs
    4 - esconder todas as main
    5 - mostrar a primeira main(selecionada)
    7 - mostrar a primeira child(selecionada)
    */

    botoes_desabilitados := false

    Gui, CavebotGUI:Destroy
    CavebotHandler.stopShowWaypointTimer(destroyGUI := true)

    ; Gosub, Destroy_ILs
    Gui, CavebotGUI:Default
    ; Gui, CavebotGUI:+E0x02000000 +E0x00080000 ; WS_EX_COMPOSITED & WS_EX_LAYERED => Double Buffer

    y_tab := 24
    width_tab := 833

    TabStyle :=TCS_TOOLTIPS ;|TCS_BUTTONS ;|TCS_FORCELABELLEFT|TCS_FIXEDWIDTH   ;|TCS_FORCEICONLEFT|TCS_FIXEDWIDTH

    ; criar primeiro os elementos da primeira GUI (load_order[1])
    first_selected_GUI := load_order[1]
    first_selected_GUI := StrReplace(first_selected_GUI, " ", "")
    Gosub, Create_%first_selected_GUI%GUI

    width_main_tab := width_tab + 14
    width := width_main_tab - 2

    ; exibir a gui somente com os primeiros elementos criados
    Gui, CavebotGUI:Menu, MyMenuBar ; Attach MyMenuBar to the GUI
    ; Gui, CavebotGUI:Menu, CavebotMenuBar ; Attach MyMenuBar to the GUI

    ; elementos/ações da GUI que podem ser executados/criados após exibir a GUI
    Gosub, PostCreate_%first_selected_GUI%GUI

    ; carregar as GUIs restantes(que não são a primeira)
    CarregandoGUI("Creating GUIs...")
    for key, GUI in load_order
    {
        timer := new _Timer()

        InfoCarregando("Creating " GUI "...")

        if (A_Index = 1)
            continue ; pular a primeira GUI visto que ela ja foi criada primeiro
        GUI := StrReplace(GUI, " ", "")

        if (!A_IsCompiled && LOAD_ONLY_GUI && GUI != LOAD_ONLY_GUI) {
            continue
        }
        Gosub, Create_%GUI%GUI
        _Logger.info(GUI, timer.elapsed())
    }

    main_tabs := ""
    for key, GUI in GUIs_to_create
    {
        ; if (GUI = "Settings" && LANGUAGE = "PT-BR")
        ; GUI := "Configurações"
        ; GUI := "Configurações", selected_GUI := GUI ; selected_GUI pra selecionar a aba no Choose, MainTab abaixo
        main_tabs .= GUI "|"
    }

    height := 570

    fallbackX := A_ScreenWidth / 2 - (width / 2)
    fallbackY := A_ScreenHeight / 2 - (height / 2)

    MainGUI_X := (MainGUI_X > A_ScreenWidth - 100) ? fallbackX : MainGUI_X
        , MainGUI_Y := (MainGUI_Y > A_ScreenHeight - 100) ? fallbackY : MainGUI_Y

    if (MainGUI_X < -3000)
        MainGUI_X := fallbackX
    if (MainGUI_Y < -3000)
        MainGUI_Y := fallbackY

    try Gui, CavebotGUI:Show, w%width% h%height% x%MainGUI_X% y%MainGUI_Y%, % MAIN_GUI_TITLE
    catch e {
        error := "Failed to show main GUI"
        if (!A_IsCompiled) {
            Msgbox, 48,, % error
            reload
        }
        else
            OutputDebug("MainGUI", error)
    }

    WinGet, CavebotGUIHwnd, ID, % MAIN_GUI_TITLE
    WinGet, OldBotHWND, ID, A

    global OldBotHWND

    Gui, CarregandoCavebot:Destroy

    Gui, CavebotGUI:Add, Tab2, x0 y0 h1000 w%width_main_tab% vMainTab gMainTab +Theme, % main_tabs "|+"

    if (selected_GUI = "Cavebot")
        CavebotGUI.loadLVsWaypoints(true)
    ; Gosub, CreateButtonsCavebot ; removido os botões do cavebot
    CavebotGUI.WaypointButtons()

    GuiControl, CavebotGUI:Choose, MainTab, %selected_GUI%
    ; if (selected_GUI != "Cavebot") ; se não for o cavebot não da o "Gosub" para não realizar o efeito de Redraw na janela 2 vezes, comentado 22/11 não sei se é realmente necessário
    ; gosub, MainTab

    ; percorrer somente os PostCreate agora
    for key, GUI in load_order
    {
        if (A_Index = 1)
            continue ; pular a primeira GUI visto que ela ja foi criada primeiro
        GUI := StrReplace(GUI, " ", "")
        Gosub, PostCreate_%GUI%GUI
    }

    /*
    todos os elementos criados até aqui são exibidos na Main Tab do Cavebot
    */
    Gui, CavebotGUI:Tab
    /*
    a partir dessa linha fazem parte da GUI princial, não percentencem a nenhuma TAB, ficam visivel "acima" de todas as tabs
    */
    x := 753
    y := 1

    client := "Tibia"

    ; new _Button()
    ; .x(x).y(y).h(20).w(25)
    ; .tt("Abrir cliente do " client, "Open " client " client")
    ; .icon(_Icon.get(_Icon.TIBIA), "a0 l2 b1 s16")
    ; .event("openSelectedTibiaClient")
    ; .disabled(TibiaClient.clientExePath = "")
    ; .add()

        new _Button().title("Select Client")
    ; .xadd(1).yp().h(20).w(87)
        .x(x + 2).y(y).h(20).w(87)
        .tt(txt("Selecione qual Tibia Client o bot irá funcionar.`n`nClique segurando ""Alt"" para ABRIR o cliente do Tibia(se configurado o diretório) ", "Select which Tibia Client the bot will work on.`n`nClick holding ""Alt"" to OPEN Tibia client(if the directory is configured)") "`n`n[ Ctrl + Shift + S ]")
        .icon(_Icon.get(_Icon.TIBIA), "a0 l0 b1 r2 s16")
        .event("selectTibiaClientLabel")
        .add()

    Gui, CavebotGUI:Font, Bold

    x := width_main_tab - 27
    y := 23
    ; if (A_IsCompiled)
    Gui, CavebotGUI:Add, Button, x%x% y%y% h20 w20 hwndhReloadGUIButton gReload, R
    Gui, CavebotGUI:Font


    ; [OPEN-SOURCE] Bypass UI section removed

    TT.Add(hReloadGUIButton, "Reload OldBot`n[ Alt + Shift + R ]")
    Gui, CavebotGUI:Font, Norm
    Gui, CavebotGUI:Font,

    if (selected_GUI != "Cavebot") ; se for a tela do Cavebot, carrega o listview de waypoints por ultimo
        CavebotGUI.loadLVsWaypoints(true)

return

; [OPEN-SOURCE] Bypass check label removed
checkBypassFromUI:
return

openSettingsGuis:
        new _ProfileSettingsGUI().open()
        new _OldBotSettingsGUI().open()
return

Destroy_ILs:
    IL_Destroy(ImageListID_LV_ItemList)
    IL_Destroy(ImageListID) ; Required for image lists used by tab controls.
    IL_Destroy(TabCavebot_IL) ; Required for image lists used by tab controls.
    IL_Destroy(TabTargeting_IL) ; Required for image lists used by tab controls.
    ; IL_Destroy(Tab_Script_Cavebot_IL)  ; Required for image lists used by tab controls.
return

/*
elementos/ações da GUI que podem ser executados/criados após exibir a GUI
*/
PostCreate_SupportGUI:
return
PostCreate_AutoSpellsGUI:
return
PostCreate_SioGUI:
    SioGUI.PostCreate_SioGUI()
return
PostCreate_ReconnectGUI:
    ReconnectGUI.PostCreate_ReconnectGUI()
return
PostCreate_ItemRefillGUI:
return
PostCreate_AlertsGUI:
    AlertsGUI.PostCreate_AlertsGUI()
return
PostCreate_HotkeysGUI:
    HotkeysGUI.PostCreate_HotkeysGUI()
return
PostCreate_FishingGUI:
    FishingGUI.PostCreate_FishingGUI()
return
PostCreate_NavigationGUI:
        new _NavigationGUI().postCreate()
return
PostCreate_PersistentGUI:
    PersistentGUI.PostCreate_PersistentGUI()
return
PostCreate_AHK_ScriptsGUI:
return

PostCreate_HealingGUI:
    HealingGUI.PostCreate_HealingGUI()
return
PostCreate_LootingGUI:
    LootingGUI.PostCreateLootingGUI()
return
PostCreate_TargetingGUI:
    TargetingGUI.PostCreateTargetingGUI()
return
PostCreate_CavebotGUI:
    CavebotGUI.PostCreateCavebotGUI()
return

Create_SupportGUI:
    SupportGUI.createSupportGUI()
return
Create_AutoSpellsGUI:
    AutoSpellsGUI.createAutoSpellsGUI()
return
Create_SioGUI:
        new _SioGUI().createSioGUI()
return
Create_ReconnectGUI:
    ReconnectGUI.createReconnectGUI()
return
Create_ItemRefillGUI:
    ItemRefillGUI.createRefillGUI()
return
Create_AlertsGUI:
    AlertsGUI.createAlertsGUI()
return
Create_FishingGUI:
    FishingGUI.createFishingGUI()
return
Create_NavigationGUI:
        new _NavigationGUI().createNavigationGUI()
    ; new _NavigationGUI().create()
    ; _NavigationGUI.createNavigationGUI()
return
Create_HotkeysGUI:
    HotkeysGUI.createHotkeysGUI()
return
Create_PersistentGUI:
    PersistentGUI.createPersistentGUI()
return
Create_AHK_ScriptsGUI:
return
Create_HealingGUI:
    HealingGUI.createHealingGUI()
return
Create_LootingGUI:
    LootingGUI.createLootingGUI()
return
Create_TargetingGUI:
    TargetingGUI.createTargetingTabs()
return

SpellsGUI:
    gosub, CarregandoCavebotGUI
    selected_GUI := "Support"
    Goto, MainGUI

HealingGUI:
    gosub, CarregandoCavebotGUI
    selected_GUI := "Healing"
    Goto, MainGUI
SioGUI:
    gosub, CarregandoCavebotGUI
    selected_GUI := "SioFriend"
    Goto, MainGUI
ReconnectGUI:
    gosub, CarregandoCavebotGUI
    selected_GUI := "Reconnect"
    Goto, MainGUI
ItemRefillGUI:
    gosub, CarregandoCavebotGUI
    selected_GUI := "ItemRefill"
    Goto, MainGUI

ChecarConfiguracoesCliente:
    ClientSettings.checkSettings()
return

ElfGUIGuiClose:
    ElfGUIGuiClose()
return

ElfGUIGuiClose() {
    CarregandoGUI(txt("Encerrando processos...", "Closing processes..."), 180, 180)
        new _ReleaseModifierKeys()

    ; setSystemCursor("IDC_WAIT")
    _OldBotExe.deletePID()
    IniDelete, %DefaultProfile%, settings, OldBotExeName_Process
    IniWrite, 0, %DefaultProfile%, targeting_system, TargetingRunning
    IniWrite, 0, %DefaultProfile%, healing_system, UsingItemOnCharacter

    gosub, handleMagnifierExit

    GetWindowsPos()
    CloseAllProcesses(true)
    ; restoreCursor()
    _OldBotExe.stop()

    ExitApp
    return
}

TransparentOldBot:
    WinSet, Transparent, % TransparentOldBot = 1 ? 120 : 255, ahk_id %OldBotHWND%
return

GetShortcutWindowPos(minimized := false) {
    if (minimized = false) {
        WinGetPos, x, y,,, ahk_id %ShortcutScriptsHWND%
    } else {
        WinGetPos, x, y,,, ahk_id %ShortcutScripts_MinimizedHWND%
    }
    if (x < -3000 OR y < -3000)
        return
    if (x != "") {
        global ScriptsShortcutGUI_X := x
        global ScriptsShortcutGUI_Y := y
        IniWrite, %ScriptsShortcutGUI_X%, %DefaultProfile%, settings, ScriptsShortcutGUI_X
        IniWrite, %ScriptsShortcutGUI_Y%, %DefaultProfile%, settings, ScriptsShortcutGUI_Y
    }
}

GetWindowsPos(getShortcut := true) {
    WinGetPos, x, y,,, ahk_id %OldBotHWND%
    if (x < -3000 OR y < -3000)
        return
    if (x != "" && y != "") {
        global MainGUI_X := x
        global MainGUI_Y := y
        IniWrite, %x%, %DefaultProfile%, settings, MainGUI_X
        IniWrite, %y%, %DefaultProfile%, settings, MainGUI_Y
    }
    if (getShortcut = true)
        GetShortcutWindowPos((ScriptsShortcut_minimized = 1) ? false : true)
    return
}

ReloadGUI:
    GetWindowsPos(false)
    Goto, CavebotGUI
return

Reload:
    Reload()
return
Reload(openLauncher := true) {
    global
    Critical, On
    restoreCursor()
        new _GlobalIniSettings().submit("reloading", true)
    Gui, Carregando:Destroy
    Gui, Carregando:-Caption +Border +Toolwindow +AlwaysOnTop
    Gui, Carregando:Add, Text,, % LANGUAGE = "PT-BR" ? "Recarregando, por favor aguarde..." : "Reloading, please wait..."
    Gui, Carregando:Add, Progress, x10 y+5 w170 h20 cRed vMyProgress, 0
    Gui, Carregando:Show, y100 NoActivate,
    GuiControl,Carregando:, MyProgress, 20
    CloseAllProcesses(true)
    GuiControl,Carregando:, MyProgress, 40
    GetWindowsPos()
    GuiControl,Carregando:, MyProgress, 70

    CavebotScript.deleteAllTempScriptFiles()

    ; IniWrite, 1, %DefaultProfile%, accountsettings, AutoLogin

    ; Gosub, ChangeTibiaIcon
    GuiControl,Carregando:, MyProgress, 99
    if (A_IsCompiled && openLauncher) {
        try {
            _LauncherExe.start()
            Sleep, 1000
            ExitApp
        } catch e {
            _Logger.msgboxException(16, e, "Open Launcher")
        }
    }
    Reload
    Pause
    Pause
    GuiControl,Carregando:, MyProgress, 100
    Sleep, 100
    return
}

minimizeShortcutGUI:
    buttonPress("ShortcutScripts", A_GuiControl, "minimize_button", press := true, sleep := 75)
    gosub, EsconderShortcutGUI
    buttonPress("ShortcutScripts", A_GuiControl, "minimize_button", press := false)
return

EsconderShortcutGUI:
    GetShortcutWindowPos(false)
    global ScriptsShortcut_minimized = 1
    IniWrite, %ScriptsShortcut_minimized%, %DefaultProfile%, settings, ScriptsShortcut_minimized

    WinHide, ahk_id %ShortcutScriptsHWND%

    Gui, ShortcutScripts:Hide

    if (ShortcutScripts_MinimizedHWND != "") {
        WinMove, ahk_id %ShortcutScripts_MinimizedHWND%,, ScriptsShortcutGUI_X, ScriptsShortcutGUI_Y
        WinShow, ahk_id %ShortcutScripts_MinimizedHWND%
        return
    }

    Gui, ShortcutScripts_Minimized:Destroy
    Gui, ShortcutScripts_Minimized:+ToolWindow +AlwaysOnTop -Caption +Border
    Gui, ShortcutScripts_Minimized:Add, Button, x7 y5 h20 w80 gMaximizeShortcutGUI hwndMaximize_Button, % LANGUAGE = "PT-BR" ? "Maximizar" : "Maximize"
    ; GuiButtonIcon(Maximize_Button, "compstui.dll", 7, "a0 l2 b0 t0 s16")
    Gui, ShortcutScripts_Minimized:Add, Pic, x0 y0 0x4000000, Data\Files\Images\GUI\GrayBackground.png
    Gui, ShortcutScripts_Minimized:Show, x%ScriptsShortcutGUI_X% y%ScriptsShortcutGUI_Y% w95 h30 NoActivate, Scripts shortcut
    WinGet, ShortcutScripts_MinimizedHWND, ID, Scripts shortcut

    global ShortcutScripts_MinimizedHWND

    ; WinSet, Transparent,%ScriptsGUITransparency%, ahk_id %ShortcutScripts_MinimizedHWND%
    ; GuiButtonIcon(Maximize_Button, "compstui.dll", 7, "a0 l2 b0 t0 s16") ; forçar novamente o botão pois por algum motivo está mudando o icone
return

MostrarShortcut_Alerts:
    GetShortcutWindowPos()
    IniWrite, %MostrarShortcut_Alerts%, %DefaultProfile%, settings, MostrarShortcut_Alerts
    Gui, ShortcutScripts:Destroy
    Goto, CreateShortcutGUI_Forced
return
MostrarShortcut_Misc:
    GetShortcutWindowPos()
    IniWrite, %MostrarShortcut_Misc%, %DefaultProfile%, settings, MostrarShortcut_Misc
    Gui, ShortcutScripts:Destroy
    Goto, CreateShortcutGUI_Forced
return
MostrarShortcut_Outros:
    GetShortcutWindowPos()
    IniWrite, %MostrarShortcut_Outros%, %DefaultProfile%, settings, MostrarShortcut_Outros
    Gui, ShortcutScripts:Destroy
    Goto, CreateShortcutGUI_Forced
return
MostrarShortcut_Hotkeys:
    GetShortcutWindowPos()
    IniWrite, %MostrarShortcut_Hotkeys%, %DefaultProfile%, settings, MostrarShortcut_Hotkeys
    Gui, ShortcutScripts:Destroy
    Goto, CreateShortcutGUI_Forced
return
MostrarShortcut_Support:
    GetShortcutWindowPos()
    IniWrite, %MostrarShortcut_Support%, %DefaultProfile%, settings, MostrarShortcut_Support
    Gui, ShortcutScripts:Destroy
    Goto, CreateShortcutGUI_Forced
return
MostrarShortcut_Cavebot:
    GetShortcutWindowPos()
    IniWrite, %MostrarShortcut_Cavebot%, %DefaultProfile%, settings, MostrarShortcut_Cavebot
    Gui, ShortcutScripts:Destroy
    Goto, CreateShortcutGUI_Forced
return
MostrarShortcut_Healer:
    GetShortcutWindowPos()
    IniWrite, %MostrarShortcut_Healer%, %DefaultProfile%, settings, MostrarShortcut_Healer
    Gui, ShortcutScripts:Destroy
    Goto, CreateShortcutGUI_Forced
return
MostrarShortcut_ItemRefill:
    GetShortcutWindowPos()
    IniWrite, %MostrarShortcut_ItemRefill%, %DefaultProfile%, settings, MostrarShortcut_ItemRefill
    Gui, ShortcutScripts:Destroy
    Goto, CreateShortcutGUI_Forced
return
MostrarShortcutGUI:
    ; GuiControlGet, MostrarShortcutGUI
    IniWrite, %MostrarShortcutGUI%, %DefaultProfile%, settings, MostrarShortcutGUI
    if (MostrarShortcutGUI = 0) {
        Gui, ShortcutScripts:Destroy
        ; WinMove, Cavebot Panel,,2, 5
    }
    if (MostrarShortcutGUI = 1) {
        ; Gui, ShortcutScripts:Show, x2 y2 w132 NoActivate, Scripts
        Gui, ShortcutScripts:Destroy
        Goto, CreateShortcutGUI
        ; WinMove, Cavebot Panel,,148, 5
    }
return

Receive_WM_COPYDATA(wParam, lParam) {
    ; static fn
    StringAddress := NumGet(lParam + 2*A_PtrSize) ; Retrieves the CopyDataStruct's lpData member.
        , CopyOfData := StrGet(StringAddress) ; Copy the string out of the structure.
        , messageString := StrSplit(CopyOfData, "|")

    ; m(serialize(messageString))

    switch messageString.1 {
        case _Follower.__Class:
            ; if (fn) {
            ;     out("Deleting timer")
            ;     SetTimer, % fn, Delete
            ; }

            ; fn := _Follower.receiveCoordinates.bind(_Follower, messageString.2)
            ; SetTimer, % fn, -1
            _Follower.receiveCoordinates(messageString.2, messageString.3, messageString.4)
        case "": return false

            /**
            setsetting function from cavebot.exe
            */
        case "setsetting":
            setting := messageString.2
            if (!setting)
                return false
            path := messageString.3
            if (!path)
                return false
            /**
            allow empty value
            */
            value := messageString.4
                , settingPath := StrSplit(path, "/")
                , childNumber := settingPath.Count() - 1
                , childSetting := _ActionScriptValidation.createChildSettings(settingPath)

            ; msgbox, % serialize(childSetting)
            ; msgbox, % "setting = " setting "`n childNumber = " childNumber "`nvalue = " value "`npath = " path

            if (value != "") && (value = 1 OR value = 0)
                value += 0

            writeJson := false
            switch childNumber {
                case 1:
                    if (InStr(path, "navigation/")) {
                        return handleNavigationMessage(childSetting.1, value)
                    }

                    %setting%Obj[childSetting.1] := value
                    writeJson := true
                    /**
                    change the checkbox in the interface
                    */
                    try GuiControl, CavebotGUI:, % childSetting.1, % value
                    catch {
                    }
                    try checkbox_setvalue(childSetting.1 "_2", value)
                    catch {
                    }
                case 2:
                    /**
                    save and change the alert
                    */
                    switch setting {
                        case "alerts":
                            alertName := childSetting.1
                            alertsObj[alertName].enabled := value
                            GuiControl, CavebotGUI:, alertEnabled, % alertsObj[alertName].enabled = true ? 1 : 0
                            AlertsHandler.changeAlertEnabled(alertName, save := true)
                            AlertsHandler.runAlertsExe()
                            return true
                        case "persistent":
                            persistentID := childSetting.1
                            persistentObj[persistentID].enabled := value
                            ; select row before changePersistentEnabled so it can update the row
                            row := _ListviewHandler.findRowByContent(persistentID, 1, "LV_PersistentList")
                            _ListviewHandler.selectRow("LV_PersistentList", row)
                            PersistentHandler.changePersistentEnabled(persistentID, save := true)
                            return true
                        default:
                            %setting%Obj[childSetting.1][childSetting.2] := value
                            writeJson := true
                    }
                case 3:
                    %setting%Obj[childSetting.1][childSetting.2][childSetting.3] := value
                    writeJson := true
                case 4:
                    %setting%Obj[childSetting.1][childSetting.2][childSetting.3][childSetting.4] := value
                    writeJson := true
                case 5:
                    ; msgbox, % %setting%Obj[childSetting.1][childSetting.2][childSetting.3][childSetting.4][childSetting.5]
                    %setting%Obj[childSetting.1][childSetting.2][childSetting.3][childSetting.4][childSetting.5] := value
                    writeJson := true
            }

            if (writeJson = true) {
                CavebotScript.saveSettings("setSettingCavebotMessage")
                return true
            }
            ; msgbox, % "setting = " setting "`n childNumber = " childNumber "`nvalue = " value "`npath = " path

            return false

            /**
            current waypoint and tab from cavebot.exe
            */
        default:
            loadingGuisDisabled := true ; set to true so it does not run the OldBotSettings.disableGuisLoading()
            CavebotGUI.selectStartWaypoint(messageString.1, messageString.2, true)
            if (messageString.2 != tab)
                CavebotGUI.chooseScriptTabByName(messageString.2)
            Gui, Listview, % "LV_Waypoints_" tab
            LV_Modify(messageString.1, "Vis")
            loadingGuisDisabled := false
    }
    return true ; Returning 1 (true) is the traditional way to acknowledge this message.
}

handleNavigationMessage(setting, value) {
    if (setting = "followerEnabled") {
        if (value = 0) {
            _Follower.abort()
        } else {
            _Follower.CHECKBOX.check()
            _Follower.turnOn()
        }

        return
    }

    if (setting = "leaderEnabled") {
        if (value = 0) {
            _Navigation.abort()
        } else {
            _Navigation.CHECKBOX.check()
            _Navigation.turnOn()
        }

        return
    }
}

TrayTipHotkey(message) {
    TrayTip, % "Hotkey", % message, 2, 1
    SetTimer, HideTrayTip, Delete
    SetTimer, HideTrayTip, -1500
    return
}

WM_RBUTTONDOWN() {
    switch A_GuiControl {
        case "minimapViewerImage":
            MinimapGUI.minimapViewerMenu()
    }
    return
}

WM_MOUSEMOVE()
{
    SetTimer, WM_LBUTTONDOWN, Delete
    SetTimer, WM_LBUTTONDOWN, -200
    tooltip, % A_Gui
    return
}

WM_LBUTTONDOWN() {
    if (RegExMatch(A_Gui,"(ScreenBoxID|screen_box|FishingSqmGUI)"))
        return
    PostMessage, 0xA1, 2 ; 0xA1 = WM_NCLBUTTONDOWN
    if (_GUI.INSTANCES.HasKey(A_Gui)) {
        instance := _GUI.INSTANCES[A_Gui]
        fn := instance.savePosition.bind(instance)
        SetTimer, % fn, Delete
        SetTimer, % fn, -100
        SetTimer, % fn, -300
        SetTimer, % fn, -500
        SetTimer, % fn, -1000
        return
    }

    switch A_Gui {
        case "ShortcutScripts":
            SetTimer, GetShortcutWindowPos, Delete
            SetTimer, GetShortcutWindowPos, -1000
            SetTimer, GetShortcutWindowPos, -3000
        case "ShortcutScripts_Minimized":
            SetTimer, GetShortcutWindowPosTimer, Delete
            SetTimer, GetShortcutWindowPosTimer, -1000
            SetTimer, GetShortcutWindowPosTimer, -3000
        case "CavebotGUI":
            SetTimer, GetWindowsPos, Delete
            SetTimer, GetWindowsPos, -1000
            SetTimer, GetWindowsPos, -3000
        case "minimapViewerGUI":
            SetTimer, saveMapViewerWindowPosition, Delete
            SetTimer, saveMapViewerWindowPosition, -1000
            ; Default:
            ; msgbox,, % A_ThisLabel, % A_Gui
    }
    return
}

GetShortcutWindowPosTimer:
    GetShortcutWindowPos(minimized := true)
return

/*
to include AlertsSystem
*/
messageTimer:
screenshotTimer:
return

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
Project files
*/
#Include __Files\libraries\TAB\TAB.ahk
#Include __Files\libraries\TAB\HSV.ahk
#Include __Files\libraries\TAB\Fnt.ahk
#Include __Files\libraries\TAB\Edit.ahk
#Include __Files\libraries\Class_LV_Rows.ahk

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\libraries\Gdip_All_2.ahk

#Include __Files\GUIs\shortcut_GUI.ahk

/*
labels
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\labels_action_script.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\labels_alerts.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Labels\Cavebot\labels_cavebot.ahk
; #Include __Files\labels_cavebot.ahk
#Include __Files\labels_fishing.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\labels_floorspy.ahk
#Include __Files\labels_healing.ahk
#Include __Files\labels_itemlist.ahk
#Include __Files\labels_looting.ahk
#Include __Files\labels_itemrefill.ahk
#Include __Files\labels_memorymanager.ahk
#Include __Files\labels_minimap.ahk
#Include __Files\labels_minimap_cavebot.ahk
#Include __Files\labels_menu.ahk
#Include __Files\labels_tibiaclient.ahk
#Include __Files\labels_reconnect.ahk
#Include __Files\labels_persistent.ahk
#Include __Files\labels_settings.ahk
#Include __Files\labels_scriptimages.ahk
#Include __Files\labels_scriptlist.ahk
#Include __Files\labels_siofriend.ahk
#Include __Files\labels_support.ahk
#Include __Files\labels_targeting.ahk
#Include __Files\labels_waypoint.ahk
#Include __Files\labels_waypoint_recorder.ahk
#Include __Files\labels_waypoint_importer.ahk

; [OPEN-SOURCE] PC ID verification removed
; #Include __Files\login\verify_PC_ID.ahk
#Include __Files\labels_hotkeys_shortcut.ahk

#Include __Files\default_functions.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\default_functions.ahk
#Include __Files\GUI Helpers.ahk
#Include __Files\default_cavebot_functions.ahk

#Include __Files\menus\main_menu.ahk
#Include __Files\menus\cavebot_menu.ahk
#Include __Files\menus\menu_labels.ahk
#Include __Files\menus\ItemListMenu.ahk

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\hotkeys\hotkeys_actionscript.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\hotkeys\hotkeys_floorspy.ahk
#Include __Files\hotkeys\hotkeys_main.ahk
#Include __Files\hotkeys\hotkeys_mapviewer.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\hotkeys\hotkeys_tibia.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\hotkeys\hotkeys_oldbot_window.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\hotkeys\hotkeys_waypoint.ahk

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\hotkeys\hotkeys_actionscript.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\hotkeys\hotkeys_floorspy.ahk

#Include __Files\labels_hotkeys.ahk ; after hotkeys.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\labels_magnifier.ahk

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Window Events\gui_close.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Window Events\gui_escape.ahk
