/*__Files\Classes\Reconnect\_Reconnect__Files\Classes\Reconnect\_Reconnect
OldBot é desenvolvido por Alfredo Menezes, Brasil.
Copyright © 2017. Todos os direitos reservados.

OldBot is developed by Alfredo Menezes, Brazil.
Copyright © 2017. All rights reserved.
*/

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\scripts_start_settings_section.ahk
/*
Includes folder
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Reconnect.ahk

/*
module's specific classes
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\libraries\Gdip_All_2.ahk


/*
module name
*/
global moduleName := "reconnect"

if (OldBotSettings.hasFunctionEnabled(moduleName) = false)
    ExitApp

PID := _ProcessHandler.writeModuleExePID(moduleName)

; reloads if client is closed
if (TibiaClient.getClientAreaFunctions(StrReplace(A_ScriptName, ".exe", "")) = false)
    return

; OutputDebug(moduleName, "Starting...")

global ReconnectHandler := new _ReconnectHandler()


; Process, Priority, %PID%, Normal


Random, R, 0, 400
SetTimer, VerifyFunctionsFromExe, % 4000 + R
SetTimer, CheckClientClosedMinimized, % 2000 + R

/*
functions
*/

try {
    _Reconnect.decryptAccountData()
} catch e {
    Msgbox, 48, % "Auto Reconnect", e.Message
    reload
}


baseSearch := new _ImageSearch()
    .setFolder(ImagesConfig.reconnectFolder)

delay := 600

Loop, {
    ; msgbox, % serialize(reconnectObj)
    if (!reconnectObj.autoReconnect) {
        Sleep, 6000
        continue
    }

    if (isConnected()) {
        Sleep, 6000
        continue
    }

    /**
    don't press esc to avoid disappearing login form
    */
    ; Loop, 3 {
    ;     Send("Esc")
    ;     Sleep, 50
    ; }
    Loop, {
        _search := baseSearch
            .setFile("please_wait")
            .setVariation(50)
            .search()
        if (_search.notFound()) {
            break
        }

        Sleep, 5000
    }
    _search := baseSearch
        .setFile("cancel_button")
        .setClickOffsets(2)
        .search()
        .click()

    if (_search.found()) {
        Sleep, % delay
        _search
            .search()
            .click()

        if (_search.found()) {
            Sleep, % delay
        }

    }

    _search := new _SearchOkButton()
        .click()
    if (_search.found()) {
        Sleep, % delay
    }

    /**
    case where the login form disappears when pressing esc
    */
    if (!_Reconnect.isFormVisible()) {
        Send("a")
        Sleep, % delay
        Send("Enter")
        Sleep, % delay
        Loop, 3 {
            Send("Esc")
            Sleep, 50
        }
    }


    if (!_Reconnect.isFormVisible()) {
        Menu, Tray, Icon
        TrayTip, % "Auto Reconnect", % "Login form not visible", 3, 2
        Menu, Tray, NoIcon

        SetTimer, HideTrayTipFunctions, Delete
        SetTimer, HideTrayTipFunctions, -3000
        Sleep, 1000
        continue
    }

    Loop, {
        if (loginTwoFactor = 0) ; not really needed
            break
        if (!_Reconnect.tokenWindowVisible())
            break
        Menu, Tray, Icon
        TrayTip, % "Auto Reconnect", % "Waiting login token fill", 3, 1
        Menu, Tray, NoIcon

        SetTimer, HideTrayTipFunctions, Delete
        SetTimer, HideTrayTipFunctions, -3000
        Sleep, 10000
    }

    _Reconnect.fillForm()

    charListVisible := _Reconnect.waitCharacterVisible()

    if (charListVisible = false) {
        Menu, Tray, Icon
        TrayTip, % "Auto Reconnect", % "Char list not visible", 3, 2
        Menu, Tray, NoIcon

        SetTimer, HideTrayTipFunctions, Delete
        SetTimer, HideTrayTipFunctions, -3000
        Sleep, 1000
        continue

    }

    _Reconnect.selectCharacter(characterListPosition%autoReconnectAccount%)

    Menu, Tray, Icon
    TrayTip, % "Auto Reconnect", % "Reconnect finished.", 3, 1
    Menu, Tray, NoIcon

    SetTimer, HideTrayTipFunctions, Delete
    SetTimer, HideTrayTipFunctions, -3000

    delay := new _ReconnectSettings().get("delay")
    Sleep, % delay * 1000
}


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


writeCavebotLog(Status, Text, isError := false) {
    return
}

Reload() {
    Reload
    return
}
