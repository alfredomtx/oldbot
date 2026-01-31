showEmail1:
    Gui, CavebotGUI:Submit, NoHide
    Gui, CavebotGUI:Default
    If showEmail1
        GuiControl, -Password, accountEmail1_uncrypted
    Else
        GuiControl, +Password, accountEmail1_uncrypted
return
showEmail2:
    Gui, CavebotGUI:Submit, NoHide
    Gui, CavebotGUI:Default
    If showEmail2
        GuiControl, -Password, accountEmail2_uncrypted
    Else
        GuiControl, +Password, accountEmail2_uncrypted
return
showEmail3:
    Gui, CavebotGUI:Submit, NoHide
    Gui, CavebotGUI:Default
    If showEmail3
        GuiControl, -Password, accountEmail3_uncrypted
    Else
        GuiControl, +Password, accountEmail3_uncrypted
return

saveAccount1:
    Gui, CavebotGUI:Submit, NoHide

    try ReconnectHandler.saveAccountInfo(1, accountEmail1_uncrypted, accountPassword1_uncrypted)
    catch e {
        Msgbox, 48,, % e.Message "`n" e.What
        return
    }
return

saveAccount2:
    Gui, CavebotGUI:Submit, NoHide

    try ReconnectHandler.saveAccountInfo(2, accountEmail2_uncrypted, accountPassword2_uncrypted)
    catch e {
        Msgbox, 48,, % e.Message "`n" e.What
        return
    }
return

saveAccount3:
    Gui, CavebotGUI:Submit, NoHide
    try ReconnectHandler.saveAccountInfo(3, accountEmail3_uncrypted, accountPassword3_uncrypted)
    catch e {
        Msgbox, 48,, % e.Message "`n" e.What
        return
    }
return

characterListPosition1:
    Gui, CavebotGUI:Submit, NoHide
    IniWrite, %characterListPosition1%, %DefaultProfile%, accountsettings, characterListPosition1
return
characterListPosition2:
    Gui, CavebotGUI:Submit, NoHide
    IniWrite, %characterListPosition2%, %DefaultProfile%, accountsettings, characterListPosition2
return
characterListPosition3:
    Gui, CavebotGUI:Submit, NoHide
    IniWrite, %characterListPosition3%, %DefaultProfile%, accountsettings, characterListPosition3
return

loginTwoFactor:
    Gui, CavebotGUI:Submit, NoHide
    IniWrite, %loginTwoFactor%, %DefaultProfile%, accountsettings, loginTwoFactor
return

autoReconnectAccount:
    Gui, CavebotGUI:Submit, NoHide
    IniWrite, %autoReconnectAccount%, %DefaultProfile%, accountsettings, autoReconnectAccount
return

LoginHotkey1:
    Gui, Submit, NoHide
    IniWrite, %LoginHotkey1%, %DefaultProfile%, settings, LoginHotkey1
    if (LoginHotkey1 = 0) {
        IniWrite, 0, %DefaultProfile%, settings, LoginHotkey1
        Hotkey, !Home, AltHome, off
        checkbox_setvalue("LoginHotkey1_2", 0)
        return
    }
    checkbox_setvalue("LoginHotkey1_2", 1)
    Hotkey, !Home,AltHome, On

return
; #If (WinActive("ahk_id " TibiaClientID))
AltHome:
    loginHotkey(1)
return
#If

LoginHotkey2:
    Gui, Submit, NoHide
    IniWrite, %LoginHotkey2%, %DefaultProfile%, settings, LoginHotkey2
    if (LoginHotkey2 = 0) {
        Hotkey, !End, AltEnd, off
        checkbox_setvalue("LoginHotkey2_2", 0)
        return
    }
    checkbox_setvalue("LoginHotkey2_2", 1)
    Hotkey,!End,AltEnd, on

return
#If (WinActive("ahk_id " TibiaClientID))
AltEnd:
    loginHotkey(2)
return
#If

autoReconnect:
    Gui, CavebotGUI:Submit, NoHide
    Gui, CavebotGUI:Default
    IniRead, accountEmail%autoReconnectAccount%, %DefaultProfile%, accountsettings, accountEmail%autoReconnectAccount%, %A_Space%
    IniRead, accountPassword%autoReconnectAccount%, %DefaultProfile%, accountsettings, accountPassword%autoReconnectAccount%, %A_Space%

    switch autoReconnect {
        case true:
            Error := 0
            if (accountEmail%autoReconnectAccount% = "") {
                Error++
                msgbox,48,, % "There is no email written for account " autoReconnectAccount "."
            }
            if (accountPassword%autoReconnectAccount% = "") {
                Error++
                msgbox,48,, % "There is no password written for account " autoReconnectAccount "."
            }

            if (CheckClientMC() = false)
                Error++

            OldBotSettings.disableGuisLoading()
            if (Error > 0) {

                autoReconnect := 0
                checkbox_setvalue("autoReconnect_2", 0)
                GuiControl,CavebotGUI:, autoReconnect, 0
                IniWrite, 0, %DefaultProfile%, settings, autoReconnect
                ReconnectHandler.setAutoReconnect(autoReconnect)
                return
            }
            ; msgbox, % Module3ExeName
            _ReconnectExe.start()

        case false:
            _ReconnectExe.stop()
    }

    checkbox_setvalue("autoReconnect_2", autoReconnect)
    ReconnectHandler.setAutoReconnect(autoReconnect)
    IniWrite, %autoReconnect%, %DefaultProfile%, settings, autoReconnect
return

loginHotkey(accountNumber) {
    global

    if (isNotTibia13()) {
        msgbox, 48,, % txt("A função de Login Hotkey é compatível somente com clientes versão " , "The Login Hotkey function is compatible only with clients version ") TibiaClient.Tibia13Identifier
        return
    }

    try TibiaClient.checkClientSelected()
    catch e {
        msgbox, 64,, % e.message, 2
        return
    }

    IniRead, accountEmail%accountNumber%, %DefaultProfile%, accountsettings, accountEmail%accountNumber%, %A_Space%
    IniRead, accountPassword%accountNumber%, %DefaultProfile%, accountsettings, accountPassword%accountNumber%, %A_Space%
    acc := Encryptor.decrypt(accountEmail%accountNumber%)
    try pass := Encryptor.decryptPassword(accountPassword%accountNumber%)
    catch {
    }

    if (acc = "") {
        checkbox_setvalue("LoginHotkey" accountNumber "_2", 0)
        GuiControl,ReconnectGUI:, LoginHotkey%accountNumber%, 0
        IniWrite, 0, %DefaultProfile%, settings, LoginHotkey%accountNumber%
        IniWrite, 0, %DefaultProfile%, settings, LoginHotkey%accountNumber%_2
        Gui, Carregando:Destroy
        msgbox,48,, % "There is no email written for account " accountNumber "."
        return

    }
    if (pass = "") {
        checkbox_setvalue("LoginHotkey" accountNumber "_2", 0)
        GuiControl,ReconnectGUI:, LoginHotkey%accountNumber%, 0
        IniWrite, 0, %DefaultProfile%, settings, LoginHotkey%accountNumber%
        IniWrite, 0, %DefaultProfile%, settings, LoginHotkey%accountNumber%_2
        Gui, Carregando:Destroy
        msgbox,48,, % "There is no password written for account " accountNumber "."
        return
    }

    ; Clipboard := pass
    ; msgbox, % acc "`n" pass

    WinGetTitle, TibiaWindow, ahk_id %TibiaClientID%
    if (RegExMatch(TibiaWindow,"(Tibia - )")) {
        MsgBox,64,, % LANGUAGE = "PT-BR" ? "Conta já logada." : "Account already logged in."
        return
    }

    KeyWait, Alt
    Sleep, 50

    try {
        searchResult := new _ImageSearch()
            .setPath(ImagesConfig.reconnect.email)
        ; .setDebug()
            .search()
    } catch e {
        msgbox, 16, % A_ThisFunc, % e.Message
        return
    }

    if (!searchResult.found()) {
        Msgbox, 48,, % "Email login form not found, ensure that it is visible."
        return
    }

    if (searchResult.found()) {
        Loop, 3
            MouseClick("Left", searchResult.getX() + 150, searchResult.getY() +8)
    }


    ClipboardOld := Clipboard
    Sleep, 25
    copyToClipboard(acc)
    Sleep, 25
    SendModifier("Ctrl", "v")
    Sleep, 50
    Send("Tab")
    Sleep, 50
    copyToClipboard(pass)
    Sleep, 25
    SendModifier("Ctrl", "v")

    Send("Enter")
    ; Sleep, 25
    copyToClipboard(ClipboardOld)
    TrayTip, Login Hotkey, % "Now select the char manually.", 3, 1

}

