
alertsDelay:
    Gui, CavebotGUI:Submit, NoHide
    check_control := Func("CheckEditValue").bind("alertsDelay", AlertsHandler.minAlertDelay, AlertsHandler.maxAlertDelay, "CavebotGUI", "alertsDelay", triggerLabelOnChange := true)
    SetTimer, % check_control, Delete
    SetTimer, % check_control, -700
    _GuiHandler.submitSetting("alerts", "settings/delay", %A_GuiControl%)
return

submitAlertOptionHandler:
    Gui, CavebotGUI:Default
    Gui, CavebotGUI:Submit, NoHide

    GuiControlGet, alertName
    if (alertName = "") {
        Msgbox, 48,, % "No alert selected."
    return
}

OldBotSettings.disableGuisLoading()

value := %A_GuiControl%
param := lcfirst(StrReplace(A_GuiControl, "alert", ""))


; msgbox, % alertName  " / param = " param " / " " / value = " value " / A_GuiControl = " A_GuiControl
; msgbox, % serialize(alertsObj)
if value is Number
    value += 0
alertsObj[alertName][param] := value


switch param {
    case "goToLabel":
        GuiControl, % "CavebotGUI:" (alertsObj[alertName].goToLabel = true ? "Enable" : "Disable"), alertLabelName
}

; msgbox, % serialize(alertsObj)
if (param = "enabled" && alertsObj[alertName][param] = 1) {
    try {
        _AlertsHandler.checkBeforeEnabling(alertName)
    } catch e {
        alertsObj[alertName].enabled := 0
        _AlertsHandler.disableAlert(alertNanme)
        MsgBox, 64, % A_ThisFunc, % e.Message, % e.What
        return
    }
}

AlertsHandler.saveAlerts(saveCavebotScript := true)
AlertsGUI.updateAlertRow(alertName)

if (param = "enabled") {
    AlertsHandler.changeAlertEnabled(alertName, save := false)
    if (alertsObj[alertName][param] = 1)
        AlertsHandler.runAlertsExe()
}
OldBotSettings.enableGuisLoading()
return

editUserValue:

    Gui, CavebotGUI:Default
    GuiControlGet, alertName
    if (alertName = "") {
        Msgbox, 48,, % "No alert selected", 2
    return
}
Gui, EditUserValueGUI:Destroy
Gui, EditUserValueGUI:+AlwaysOnTop -MinimizeBox



; for key, value in alertsObj[alertName]["userValue"]
; {
;     if (A_Index > 10)   
;         Break
;     Gui, EditUserValueGUI:Add, Text, x10 y+5, % "key:"
;     Gui, EditUserValueGUI:Add, edit, x+3 yp-2 h18 w100 vuserKey%A_Index%, % key
;     Gui, EditUserValueGUI:Add, Text, x+10 yp+2, % "value:"
;     Gui, EditUserValueGUI:Add, edit, x+3 yp-2 h18 w150 vuserValue%A_Index%, % value
; }

keyW := 200
valueW := 250
Loop, % AlertsHandler.alertsUserValuesAmount {
    keyValue := "", valueValue := ""
    for key, value in alertsObj[alertName]["userValue"][A_Index]
    {
        keyValue := key, valueValue := value
        break
    }

    Disabled := ""
    switch keyValue {
        case "ignoreInProtectionZone":
            if (OldBotSettings.settingsJsonObj.clientFeatures.protectionZoneIndicator = false)
                Disabled := "Disabled", valueValue := "false"

    }
    Gui, EditUserValueGUI:Add, Text, x10 y+5, % LANGUAGE = "PT-BR" ? "chave:" : "key:"
    Gui, EditUserValueGUI:Add, edit, x+3 yp-2 h18 w%keyW% vuserKey%A_Index% %Disabled%, % keyValue
    Gui, EditUserValueGUI:Add, Text, x+10 yp+2, % LANGUAGE = "PT-BR" ? "valor:" : "value:"
    Gui, EditUserValueGUI:Add, edit, x+3 yp-2 h18 w%valueW% vuserValue%A_Index%  %Disabled%, % valueValue
}

lvW := keyW + valueW + 65
Gui, EditUserValueGUI:Add, Listview, x10 y+10 w%lvW% vLV_UserValueInfoAlerts r12, Param|Description

; Gui, EditUserValueGUI:Add, Button, x10 y+5 w150 gsaveUserValue %Disabled%,% "Add new"

Gui, EditUserValueGUI:Add, Button, x10 y+10 w150 h25 gsaveUserValue 0x1, % LANGUAGE = "PT-BR" ? "Salvar User Values" : "Save User Values"
Gui, EditUserValueGUI:Show,, % LANGUAGE = "PT-BR" ? "Editar User Values" : "Edit User Values"

try {
    _ListviewHandler.loadingLV("LV_UserValueInfoAlerts", defaultGUI := "EditUserValueGUI")
} catch {
}

if (InStr(alertName, "Image is") && InStr(alertName, "found")) {
    msg := (LANGUAGE = "PT-BR" ? "Nome da imagem adicionada em ""Script Images"" para procurar na tela. Uma ou mais imagems separadas por ""|""." : "Name of the image added in ""Script Images"" to search on screen. One or more images separated by ""|"".")
    LV_Add("", "image", msg)
}

msg := (LANGUAGE = "PT-BR" ? "Se ""true"", irá enviar as mensagens do parâmtro ""messages"" quando o Alert for disparado." : "If true, it will send the messages of the ""messages"" param when the Alert is triggered.")
LV_Add("", "say", msg)
msg := (LANGUAGE = "PT-BR" ? "Mensagens para enviar no chat do jogo, separadas por ""|"", por exemplo ""hi | trade | yes""." : "Messages to send in the game chat, separated by ""|"", for example ""hi | trade | yes"".")
LV_Add("", "messages", msg)
msg := (LANGUAGE = "PT-BR" ? "Delay em milisegundos após enviar cada mensagem." : "Delay in miliseconds after sending each message.")
LV_Add("", "delay", msg)
msg := (LANGUAGE = "PT-BR" ? "Delay em segundos antes de enviar as mensagem novamente caso o Alert seja disparado." : "Delay in seconds before sending the messages again if the Alert is triggered.")
LV_Add("", "cooldown", msg)

msg := (LANGUAGE = "PT-BR" ? "Hotkey para pressionar quando o Alert for disparado. Uma ou mais hotkeys separadas por ""|""." : "Hotkey to press when the Alert is triggered. One or more keys separated by ""|"".")
LV_Add("", "pressKey", msg)
msg := (LANGUAGE = "PT-BR" ? "Delay em milisegundos após pressionar cada tecla." : "Delay in miliseconds after pressing each key.")
LV_Add("", "pressKeyDelay", msg)
msg := (LANGUAGE = "PT-BR" ? "Delay em segundos antes de pressionar as hotkeys novamente caso o Alert seja disparado." : "Delay in seconds before pressing the hotkeys again if the Alert is triggered.")
LV_Add("", "pressKeyCooldown", msg)

msg := (LANGUAGE = "PT-BR" ? "Ignora o Alert se a Waypoint Tab atual do Cavebot for uma dessas definidas. Um ou mais nome de Abas separados por ""|""." : "Ignore the Alert if the Cavebot current Waypoint Tab is one of these set. One or more Tab names separated by ""|"".")
LV_Add("", "ignoreIfCurrentWaypointTab", msg)
msg := (LANGUAGE = "PT-BR" ? "Ignora o Alert se estiver em uma Protection Zone." : "Ignore the Alert if is in a Protection Zone.")
LV_Add("", "ignoreInProtectionZone", msg)

msg := (LANGUAGE = "PT-BR" ? "Mensagem customizada para enviar pelo Telegram quando o Alert for disparado(altera a mensagem padrão)." : "Custom message to send via Telegram when the Alert is triggered(change the default message).")
LV_Add("", "telegramMessage", msg)

if (InStr(alertName, "Image is") && InStr(alertName, "found")) {
    msg := (LANGUAGE = "PT-BR" ? "Tolerância de variação da imagem na busca, quanto menor a tolerância mais ""precisa"" é a busca." : "Variation tolerancy of the image in the search, the lower the tolerancy the more ""accurate"" is the search.") " [default: 30, min: 1, max: 100]"
    LV_Add("", "variation", msg)
}

msg := (LANGUAGE = "PT-BR" ? "Tempo em segundos para despausar automaticamente o Cavebot/Targeting após ser pausado." : "Time in seconds to unpause automatically the Caveobt/Targeting after being paused.")
LV_Add("", "unpauseBotAfter", msg)
msg := (LANGUAGE = "PT-BR" ? "Diretório completo de um arquivo para ser executado quando o Alert for disparado." : "Complete directory of a file to be run when the Alert is triggered.")
LV_Add("", "runFile", msg)
msg := (LANGUAGE = "PT-BR" ? "Se ""true"", irá fechar o executável do Cavebot, forçando pará-lo." : "If true, it will close the Cavebot executable, forcing it to stop.")
LV_Add("", "closeCavebot", msg)
msg := txt("Área de busca da imagem, pode ser uma das seguintes opções: ", "Area of the image search, can be one of the following options: ") (_ClientAreaFactory.getString()  " [default: " AlertsSystem.alertsDefaultSearchArea "]")
LV_Add("", "searchArea", msg)


LV_ModifyCol(1, 120)
LV_ModifyCol(2, "autohdr")
return

EditUserValueGUIGuiEscape:
EditUserValueGUIGuiClose:
    Gui, EditUserValueGUI:Destroy
return

saveUserValue:
    ; Gui, CavebotGUI:Default
    ; Gui, CavebotGUI:Submit, NoHide

    if (alertName = "") {
        Msgbox, 48,, % "No alert selected."
    return
}

OldBotSettings.disableGuisLoading()
try AlertsHandler.saveAlertsUserValue(alertName)
catch e {
    OldBotSettings.enableGuisLoading()
    Msgbox, 48, % e.What, % e.Message, 4
    Gui, EditUserValueGUI:Hide
    ; Goto, editUserValue
    return
}
Gui, EditUserValueGUI:Destroy
OldBotSettings.enableGuisLoading()
return

LV_AlertsList:
    switch A_GuiEvent {
        Case "Normal", case "DoubleClick", case "RightClick":
            AlertsGUI.LV_AlertsList()   
    }
return

saveAlert:
    AlertsGUI.loadAlertsListLV()
return

openAlertsImagesFolder:
    dir := ImagesConfig.alertsFolder
    try Run, % dir
    catch e {
        Msgbox, 48, % A_ThisLabel, % "Failed to open folder directory:`n" dir, 4
    }
return

getTelegramChatID:
    TelegramAPI.telegramConfigGUI()
return

sentTelegramCodeMessage:
    try TelegramAPI.Telegram_FirstCFG()
    catch e {
        Gui, Carregando:Destroy
        Msgbox, 48,, % e.Message, 2
        Goto, getTelegramChatID
    }
    Goto, setupTelegramGUI
return

sendMessageTelegram:
    TelegramAPI.sendMessageTelegram()
return

sendTelegramTestMessage:
    ; Gui, setupTelegramGUI:+Disabled
    GuiControl, setupTelegramGUI:Disable, telegramTestMessageButton
    GuiControlGet, buttonText,, %A_GuiControl%
    GuiControl, setupTelegramGUI:, telegramTestMessageButton, % "Sending message, wait..."

    try TelegramAPI.sendMessageTelegram("This is a test message from OldBot :)", icon := 64, waitThreadFinish := true)
    catch e {
        Msgbox, 48,, % e.Message
    } finally {
        GuiControl, setupTelegramGUI:Enable, telegramTestMessageButton
        GuiControl, setupTelegramGUI:, telegramTestMessageButton, % buttonText

    }
    ; Gui, setupTelegramGUI:-Disabled
return

sendTelegramTestScreenshot:
    if (TibiaClientID = "") {
        Msgbox, 64,, % "Tibia client is not selected.", 2
    return
}
GuiControl, setupTelegramGUI:Disable, telegramTestScreenshotButton
GuiControlGet, buttonText,, %A_GuiControl%
GuiControl, setupTelegramGUI:, telegramTestScreenshotButton, % "Sending screenshot, wait..."

outfile := A_Temp "\OldBot\telegramScreenshotTest.png"
pBitmap := _BitmapEngine.getClientBitmap().get()
Gdip_SaveBitmapToFile(pBitmap, outfile, 100)
pBitmap.dispose()

try TelegramAPI.sendFileTelegram("Test screenshot", outfile, photo := true, waitThreadFinish := true)
catch e {
    if (A_IsCompiled)
        Msgbox, 48,, % e.Message
    else
        Msgbox, 48,, % e.Message "`n" e.What "`n" e.File "`n" e.Line
} finally {
    GuiControl, setupTelegramGUI:Enable, telegramTestScreenshotButton
    GuiControl, setupTelegramGUI:, telegramTestScreenshotButton, % buttonText
    FileDelete, % outfile
}
return

setupTelegramGUI:
    Gui, setupTelegramGUI:Destroy
    Gui, setupTelegramGUI:-MinimizeBox
    Gui, setupTelegramGUI:Add, Text, x10 y+5, Chat ID:
    Gui, setupTelegramGUI:Add, Edit, x10 y+3 w150 h18 vtelegramChatID ReadOnly, % telegramChatID
    Gui, setupTelegramGUI:Add, Button, x10 y+5 w150 ggetTelegramChatID, % LANGUAGE = "PT-BR" ? "Configurar Telegram" : "Setup Telegram"

    Disabled := (telegramChatID = "") ? "Disabled" : ""
    Gui, setupTelegramGUI:Add, Text, x10 y+15, Test Telegram:
    Gui, setupTelegramGUI:Add, Button, x10 y+3 w150 vtelegramTestMessageButton gsendTelegramTestMessage %Disabled%, % "Send test message"
    Gui, setupTelegramGUI:Add, Button, x10 y+5 w150 vtelegramTestScreenshotButton gsendTelegramTestScreenshot %Disabled%, % "Send test screenshot"


    Gui, setupTelegramGUI:Show,, % "Setup Telegram"
return
setupTelegramGUIGuiEscape:
setupTelegramGUIGuiClose:
    Gui, setupTelegramGUI:Destroy
return
deleteAlert:
    AlertsHandler.deleteAlert()
return

addImageAlert:
    AlertsHandler.addNewAlert()
return


AlertBattlelistnotempty:
    alertName := "Battle list not empty", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return

AlertDisconnected:
    alertName := "Disconnected", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return

AlertNotlistedtarget:
    alertName := "Not listed target", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return

AlertPrivatemessage:
    alertName := "Private message", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return

AlertPlayeronBattleList:
    alertName := "Player on Battle List", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return

AlertPKonscreen:
    alertName := "PK on screen", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return

alertGmOnScreen:
    alertName := "GM on screen", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return

alertCreatureOnScreen:
    alertName := "Creature on screen", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return

AlertImageisfound1:
    alertName := "Image is found 1", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisfound2:
    alertName := "Image is found 2", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisfound3:
    alertName := "Image is found 3", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisfound4:
    alertName := "Image is found 4", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisfound5:
    alertName := "Image is found 5", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisfound6:
    alertName := "Image is found 6", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisfound7:
    alertName := "Image is found 7", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisfound8:
    alertName := "Image is found 8", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisfound9:
    alertName := "Image is found 9", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisfound10:
    alertName := "Image is found 10", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return

AlertImageisnotfound1:
    alertName := "Image is not found 1", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisnotfound2:
    alertName := "Image is not found 2", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisnotfound3:
    alertName := "Image is not found 3", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisnotfound4:
    alertName := "Image is not found 4", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisnotfound5:
    alertName := "Image is not found 5", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisnotfound6:
    alertName := "Image is not found 6", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisnotfound7:
    alertName := "Image is not found 7", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisnotfound8:
    alertName := "Image is not found 8", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisnotfound9:
    alertName := "Image is not found 9", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return
AlertImageisnotfound10:
    alertName := "Image is not found 10", alertsObj[alertName].enabled := !alertsObj[alertName].enabled
    AlertsHandler.changeAlertEnabled(alertName, save := true, run := true)
return


tutorialButtonAlerts:
    openURL(LinksHandler.Alerts.tutorial)
return