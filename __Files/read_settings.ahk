CarregarSettings:

    GuiControl,Conectando:, MyProgress, +2

    global ProblemasObterInfoServidor := 0
    global ProblemaAtualizarIP := 0

    global CarregarFromTargeting = 0
    IniRead, LoadScriptInfoGUI, %DefaultProfile%, settings, LoadScriptInfoGUI, 0
    IniRead, ScriptsGUITransparency, %DefaultProfile%, settings, ScriptsGUITransparency, 255
    ScriptsGUITransparency = 255
    IniRead, MostrarShortcut_Alerts, %DefaultProfile%, settings, MostrarShortcut_Alerts, 0
    IniRead, MostrarShortcut_Misc, %DefaultProfile%, settings, MostrarShortcut_Misc, 0
    IniRead, MostrarShortcut_Outros, %DefaultProfile%, settings, MostrarShortcut_Outros, 0
    IniRead, MostrarShortcut_Hotkeys, %DefaultProfile%, settings, MostrarShortcut_Hotkeys, 1
    IniRead, MostrarShortcut_Support, %DefaultProfile%, settings, MostrarShortcut_Support, 1
    IniRead, MostrarShortcut_Healer, %DefaultProfile%, settings, MostrarShortcut_Healer, 1
    IniRead, MostrarShortcut_Cavebot, %DefaultProfile%, settings, MostrarShortcut_Cavebot, 1
    IniRead, MostrarShortcut_ItemRefill, %DefaultProfile%, settings, MostrarShortcut_ItemRefill, 0
    IniRead, SmartExit, %DefaultProfile%, settings, SmartExit, 1
    IniRead, gameWindowScaleOnlyByEvenMultiples, %DefaultProfile%, client_settings, gameWindowScaleOnlyByEvenMultiples, 1

    IniRead, TransparentOldBot, %DefaultProfile%, settings, TransparentOldBot, 0
    global TransparentOldBot
    IniRead, MostrarShortcutGUI, %DefaultProfile%, settings, MostrarShortcutGUI, 1
    global MostrarShortcutGUI


    IniRead, CHAR_POS_X, %DefaultProfile%, settings, CHAR_POS_X, %A_Space%
    IniRead, CHAR_POS_Y, %DefaultProfile%, settings, CHAR_POS_Y, %A_Space%
    global CHAR_POS_X
    global CHAR_POS_Y


    IniRead, TargetingEnabled, %DefaultProfile%, cavebot_settings, TargetingEnabled, 0
    global TargetingEnabled
    IniRead, CavebotEnabled, %DefaultProfile%, cavebot_settings, CavebotEnabled, 0 
    global CavebotEnabled

    IniRead, cavebotLogsAlwaysOnTop, %DefaultProfile%, cavebot_settings, cavebotLogsAlwaysOnTop, 1
    global cavebotLogsAlwaysOnTop

    IniRead, NaoMostrarMensagem_DeletarWaypoint, %DefaultProfile%, cavebot_settings, NaoMostrarMensagem_DeletarWaypoint, 0

    IniRead, ShowOnlyErrorLogs, %DefaultProfile%, cavebot_settings, ShowOnlyErrorLogs, 0
    global ShowOnlyErrorLogs


    IniRead, creatureImageWidth, %DefaultProfile%, targeting, creatureImageWidth, Width: 118px
    global creatureImageWidth

    IniRead, waypointImageType, %DefaultProfile%, settings, waypointImageType, Marker
    global minimapWaypointWidth
    IniRead, minimapWaypointWidth, %DefaultProfile%, settings, minimapWaypointWidth, 16
    global minimapWaypointWidth
    IniRead, minimapWaypointHeight, %DefaultProfile%, settings, minimapWaypointHeight, 16
    global minimapWaypointHeight


    ; msgbox, %DefaultProfile%
    SetFormat, Float, 0.0
    ; IniRead, OldBotAlwaysOnTop, %DefaultProfile%, settings, OldBotAlwaysOnTop, 0
    IniRead, MainGUI_X, %DefaultProfile%, settings, MainGUI_X, %A_Space%
    IniRead, MainGUI_Y, %DefaultProfile%, settings, MainGUI_Y, %A_Space%
    IniRead,SioGUI_X, %DefaultProfile%, settings,SioGUI_X, %A_Space%
    IniRead,SioGUI_Y, %DefaultProfile%, settings,SioGUI_Y, %A_Space%
    IniRead, ScriptsShortcut_minimized, %DefaultProfile%, settings, ScriptsShortcut_minimized, 0
    global ScriptsShortcut_minimized
    IniRead, ScriptsShortcutGUI_X, %DefaultProfile%, settings, ScriptsShortcutGUI_X, 3
    IniRead, ScriptsShortcutGUI_Y, %DefaultProfile%, settings, ScriptsShortcutGUI_Y, 3

    if (MainGUI_X = "")
        MainGUI_X := A_ScreenWidth / 2
    if (MainGUI_Y = "")
        MainGUI_Y = 0
    if (MainGUI_X >= A_ScreenWidth && Monitores < 2)
        MainGUI_X := A_ScreenWidth / 2
    if (MainGUI_Y >= A_ScreenHeight && Monitores < 2)
        MainGUI_Y = 0
    if (MainGUI_X < 0 && Monitores < 2)
        MainGUI_X := A_ScreenWidth / 2
    if (MainGUI_Y < 0 && Monitores < 2)
        MainGUI_Y = 0

    if (SioGUI_X = "")
        SioGUI_X := A_ScreenWidth / 3
    if (SioGUI_Y = "")
        SioGUI_Y := A_ScreenHeight / 3
    if (SioGUI_X >= A_ScreenWidth && Monitores < 2)
        SioGUI_X := A_ScreenWidth / 3
    if (SioGUI_Y >= A_ScreenHeight && Monitores < 2)
        SioGUI_Y := A_ScreenHeight / 3
    if (SioGUI_X < 0 && Monitores < 2)
        SioGUI_X := A_ScreenWidth / 3
    if (SioGUI_Y < 0 && Monitores < 2)
        SioGUI_Y := A_ScreenHeight / 3

    if (ScriptsShortcutGUI_X = "")
        ScriptsShortcutGUI_X := 1
    if (ScriptsShortcutGUI_Y = "")
        ScriptsShortcutGUI_Y = 0
    if (ScriptsShortcutGUI_X >= A_ScreenWidth && Monitores < 2)
        ScriptsShortcutGUI_X := 1
    if (ScriptsShortcutGUI_Y >= A_ScreenHeight && Monitores < 2)
        ScriptsShortcutGUI_Y = 0
    if (ScriptsShortcutGUI_X < 0 && Monitores < 2)
        ScriptsShortcutGUI_X := 1
    if (ScriptsShortcutGUI_Y < 0 && Monitores < 2)
        ScriptsShortcutGUI_Y = 0



    IniRead, ignoreCheckClientSettings, %DefaultProfile%, advanced, ignoreCheckClientSettings, 0
    global ignoreCheckClientSettings
