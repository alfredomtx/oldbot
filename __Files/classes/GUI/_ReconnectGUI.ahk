
Class _ReconnectGUI  {


    PostCreate_ReconnectGUI() {
        if (OldbotSettings.uncompatibleModule("reconnect") = true)
            return

        GuiControl, CavebotGUI:, accountEmail1_uncrypted, % Encryptor.decrypt(accountEmail1)
        GuiControl, CavebotGUI:, accountPassword1_uncrypted, % Encryptor.decryptPassword(accountPassword1)
        GuiControl, CavebotGUI:, accountEmail2_uncrypted, % Encryptor.decrypt(accountEmail2)
        GuiControl, CavebotGUI:, accountPassword2_uncrypted, % Encryptor.decryptPassword(accountPassword2)
        GuiControl, CavebotGUI:, accountEmail3_uncrypted, % Encryptor.decrypt(accountEmail3)
        GuiControl, CavebotGUI:, accountPassword3_uncrypted, % Encryptor.decryptPassword(accountPassword3)
    }

    createReconnectGUI() {
        global

        main_tab := "Reconnect"
        child_tabs_%main_tab% := "Settings"

        Gui, CavebotGUI:Add, Tab2, x6 vTab_%main_tab% y%y_tab% w%tabsWidth% h%tabsHeight% hWndhTab_%main_tab% %TabStyle% +Theme, % child_tabs_%main_tab%
        if (load_order[1] != main_tab)
            GuiControl, Hide, Tab_%main_tab% ; esconder a tab antes de adicionar os elementos a ela

        if (OldbotSettings.uncompatibleModule("reconnect") = true) {
            _GuiHandler.uncompatibleModuleWarning()
            return
        }

        Loop, parse, child_tabs_%main_tab%, |
        {
            current_child_tab := A_LoopField
            ; msgbox, % child_tabs_%main_tab%
            Gui, CavebotGUI:Tab, %current_child_tab%
            switch current_child_tab
            {
                case "Settings":
                    this.ChildTab_ReconnectSettings()
            }
        }

    }

    ChildTab_ReconnectSettings() {
        global
        Gui, CavebotGUI:Add, Groupbox, x15 y+6 w330 h125 Section, 
        Gui, CavebotGUI:Add, CheckBox, xs+10 yp+0 vautoReconnect gautoReconnect hwndhautoReconnect Checked%autoReconnect%, Auto Reconnect
        TT.Add(hautoReconnect, txt("Reconecta na sua conta e personagem após desconectado.`nFunciona também no server save.", "Reconnects in your account and character after disconnected.`nIt works also on server save."))

        Gui, CavebotGUI:Add, Text, xs+10 yp+20, % txt("Reconectar em:", "Reconnect on:")
        Gui, CavebotGUI:Add, DDL, xs+10 y+3 w180 vautoReconnectAccount gautoReconnectAccount hwndhautoReconnectAccount AltSubmit Choose%autoReconnectAccount%, % "Account 1|Account 2|Account 3"

        Gui, CavebotGUI:Add, Checkbox, xs+10 y+12 vloginTwoFactor gloginTwoFactor hwndhloginTwoFactor Checked%loginTwoFactor%, % "Two-Factor Authenticator"
        TT.Add(hloginTwoFactor, txt("Se ativo, o auto reconnect irá esperar você preencher o token de login manualmente para prossguir com o login.", "If enabled, the auto reconnect will wait for you to fill the login token manually to proceed with the login."))

            new _Text().title("Delay até a próxima tentativa", "Delay until the next try", ":")
            .x("s+10").y("+10")
            .add()

            new _Edit().name("delay")
            .prefix("reconnect")
            .x("+5").y("p-3").w(40)
            .numeric()
            .tt("Delay em SEGUNDOS para esperar antes de realizar uma nova tentativa de reconnect.", "Delay in SECONDS to wait before attempting a new to connect again.")
            .state(_ReconnectSettings)
            .rule(new _ControlRule().min(_ReconnectSettings.DELAY_MIN).max(_ReconnectSettings.DELAY_MAX))
            .add()

        w_group := 265
        x := w_group + 10

        Gui, CavebotGUI:Add, Groupbox, x15 y+20 w%w_group% h250 Section, Account 1
        Gui, CavebotGUI:Add, Checkbox, xs+10 yp+20 vLoginHotkey1 gLoginHotkey1 hwndhLoginHotkey1 Checked%LoginHotkey1%, % txt("Logar pressionando a hotkey", "Login pressing hotkey") " Alt&&Home"
        TT.Add(hLoginHotkey1, txt("Quando pressionada a hotkey Alt+Home, preenche o email e password para você na tela de login.", "When pressing the hotkey Alt+Home, fill the account email and password for you in the login screen."))

        Gui, CavebotGUI:Add, Text, xs+10 ys+50, E-mail:  
        Gui, CavebotGUI:Add, edit, xs+10 y+3 w180 h18 vaccountEmail1_uncrypted hwndhaccountEmail1 Password,
        Gui, CavebotGUI:Add, Checkbox, x+3 yp+3 vshowEmail1 gshowEmail1 hwndhshowEmail1 Checked%0%, % txt("Mostrar", "Show")

        Gui, CavebotGUI:Add, Text, xs+10 y+7, Password:  
        Gui, CavebotGUI:Add, edit, xs+10 y+3 w180 h18 vaccountPassword1_uncrypted Password hwndhaccountPassword1,

        Gui, CavebotGUI:Add, Text, xs+10 y+7, % txt("Posição do char na lista:", "Char position on list:")
        Gui, CavebotGUI:Add, edit, xs+10 y+3 w180 h18 vcharacterListPosition1 gcharacterListPosition1,% characterListPosition1
        Gui, CavebotGUI:Add, UpDown, gcharacterListPosition1 Range1-40, % characterListPosition1

        Gui, CavebotGUI:Add, Button, xs+10 y+5 gsaveAccount1 h20 w180, % txt("Salvar", "Save") " account info"


        Gui, CavebotGUI:Add, Groupbox, xs+%x% ys+0 w%w_group% h250 Section, Account 2

        Gui, CavebotGUI:Add, Checkbox, xs+10 yp+20 vLoginHotkey2 gLoginHotkey2 hwndhLoginHotkey2 Checked%LoginHotkey2%, % txt("Logar pressionando a hotkey", "Login pressing hotkey") " Alt&&End"
        TT.Add(hLoginHotkey1, txt("Quando pressionada a hotkey Alt+End, preenche o email e password para você na tela de login.", "When pressing the hotkey Alt+End, fill the account email and password for you in the login screen."))
        Gui, CavebotGUI:Add, Text, xs+10 ys+50, E-mail:  
        Gui, CavebotGUI:Add, edit, xs+10 y+3 w180 h18 vaccountEmail2_uncrypted hwndhaccountEmail2 Password,
        Gui, CavebotGUI:Add, Checkbox, x+3 yp+3 vshowEmail2 gshowEmail2 hwndhshowEmail2 Checked%0%, % "Show"

        Gui, CavebotGUI:Add, Text, xs+10 y+7, Password:
        Gui, CavebotGUI:Add, edit, xs+10 y+3 w180 h18 Password vaccountPassword2_uncrypted hwndhaccountPassword2,

        Gui, CavebotGUI:Add, Text, xs+10 y+7, % txt("Posição do char na lista:", "Char position on list:")
        Gui, CavebotGUI:Add, edit, xs+10 y+3 w180 h18 vcharacterListPosition2 gcharacterListPosition2,% characterListPosition2
        Gui, CavebotGUI:Add, UpDown, gcharacterListPosition2 Range1-40, % characterListPosition2

        Gui, CavebotGUI:Add, Button, xs+10 y+5 gsaveAccount2 h20 w180, % txt("Salvar", "Save") " account info"


        Gui, CavebotGUI:Add, Groupbox, xs+%x% ys+0 w%w_group% h250 Section, Account 3

        Gui, CavebotGUI:Add, Text, xs+10 ys+50, E-mail:  
        Gui, CavebotGUI:Add, edit, xs+10 y+3 w180 h18 vaccountEmail3_uncrypted hwndhaccountEmail3 Password,
        Gui, CavebotGUI:Add, Checkbox, x+3 yp+3 vshowEmail3 gshowEmail3 hwndhshowEmail3 Checked%0%, % "Show"

        Gui, CavebotGUI:Add, Text, xs+10 y+7, Password:
        Gui, CavebotGUI:Add, edit, xs+10 y+3 w180 h18 Password vaccountPassword3_uncrypted hwndhaccountPassword3,

        Gui, CavebotGUI:Add, Text, xs+10 y+7, % txt("Posição do char na lista:", "Char position on list:")
        Gui, CavebotGUI:Add, edit, xs+10 y+3 w180 h18 vcharacterListPosition3 gcharacterListPosition3,% characterListPosition3
        Gui, CavebotGUI:Add, UpDown, gcharacterListPosition3 Range1-40, % characterListPosition3

        Gui, CavebotGUI:Add, Button, xp+0 y+5 gsaveAccount3 h20 w180, % txt("Salvar", "Save") " account info"

        Gui, CavebotGUI:Font, cGray
        Gui, CavebotGUI:Add, Text, x10 x170 ym+500 w515 Center +BackgroundTrans, % txt("Por segurança, as informações do Reconnect não são salvas no Script(arquivo .json), mas sim no arquivo do Perfil atual (arquivo ", "For security, the Reconnect information are not saved in the Script(.json file), but in the file of the current profile Profile (file ") """" DefaultProfile """)."
        Gui, CavebotGUI:Font, Norm
        Gui, CavebotGUI:Font,

        SetEditCueBanner(haccountEmail1, "email1@example.com")
        SetEditCueBanner(haccountPassword1, "password1")
        SetEditCueBanner(haccountEmail2, "email2@example.com")
        SetEditCueBanner(haccountPassword2, "password2")
        SetEditCueBanner(haccountEmail3, "email3@example.com")
        SetEditCueBanner(haccountPassword3, "password3")

    }
}