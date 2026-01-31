
class _ProfileGUI extends _BaseClass
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        this.gui := "ProfileGUI"

        this.create()
    }

    create() {
        Gui, ProfileGUI:Destroy
        Gui, ProfileGUI:-MinimizeBox +AlwaysOnTop

        ; this.playerName := new _Edit().name("name")
        ;     .prefix("sio")
        ;     .x("s+10").y("+3").w(w_controls).h(18)
        ;     .disabled(true)
        ;     .add()

            new _Edit().name("profilesFilter")
            .x(10).y(+5).w(200).h(18)
            .event(this.filterProfiles.bind(this))
            .placeholder("Pesquisar...", "Search...")
            .setDebounceInterval(10)
            .gui(this.gui)
            .section()
            .add()

        this.profilesList := new _Listview().name("profilesList")
            .title(Array(txt("Nome do perfil", "Profile name")))
            .x("p+0").y("+5").w(200).h(300)
            .event(this.selectProfile.bind(this))
            .checked()
            .gui(this.gui)
            .add()

            new _Button().name("newProfile")
            .title("&Criar novo perfil", "&Create new profile")
            .x("p+0").y("+5").w(120)
            .event(this.createProfile.bind(this))
            .gui(this.gui)
            .add()

            new _Button().name("deleteProfile")
            .title("&" lang("delete"))
            .x("+5").y("p+0").w(75)
            .event(this.deleteProfile.bind(this))
            .gui(this.gui)
            .add()

            new _Button().title("d&efault")
            .xs().y().w(60)
            .event(this.selectProfileButton.bind(this, "default"))
            .gui(this.gui)
            .add()

        if (!A_IsCompiled) {
                new _Button().title("&Taleon")
                .x().yp().w(60)
                .event(this.selectProfileButton.bind(this, "taleon"))
                .gui(this.gui)
                .add()

                new _Button().title("&Rubinot")
                .x().yp().w(60)
                .event(this.selectProfileButton.bind(this, "rubinot"))
                .gui(this.gui)
                .add()

        }


        ; msgbox, % DefaultProfile_SemIni
        ; GuiButtonIcon(CarregarPerfil_Button, "shell32.dll", 250, "a0 l2 s22 b4")
        Gui, ProfileGUI:Show,, % LANGUAGE = "PT-BR" ? "Carregar perfil" : "Load profile"

        this.loadProfilesList()
    }

    selectProfileButton(profileName)
    {
        this.profilesList.search(profileName)
        Sleep, 100
        this.profilesList.checkRow(1, false)
    }

    loadProfilesList() {
        rows := {}
        Loop, % "settings*.ini" {
            profile := StrReplace(A_LoopFileName, "settings_", "")
            profile := StrReplace(profile, ".ini", "")
            profile := StrReplace(profile, "_", " ")

            if (profile = "settings") {
                profile := "default"
            }

            row := new _Row((profile = DefaultProfile_SemIni))
                .add(profile)

            rows.Push(row)
        }

        this.profilesList.list(rows)
    }

    selectProfile(control, value, event := "", ErrLevel := "") {
        selectedRows := this.profilesList.getSelectedRows()
        if (!selectedRows.Count()) {
            return
        }

        withoutCurrentSelected := _Arr.remove(selectedRows, this.profilesList.selectedRow.getText())
        if (!withoutCurrentSelected.Count()) {
            return
        }

        text := _Arr.first(withoutCurrentSelected)
        if (text = DefaultProfile_SemIni) {
            return
        }

        this.loadProfile(text)
    }

    filterProfiles(control, value, event := "", ErrLevel := "") {
        this.profilesList.search(value)
    }

    loadProfile(profile)
    {
        if (profile = "") {
            Msgbox,64,, % LANGUAGE = "PT-BR" ? "Selecione um perfil para carregar." : "Select a profile to load."
            return
        }
        if (profile != "default")
            NovoSettingsIni := "settings_" profile ".ini"
        else
            NovoSettingsIni := "settings.ini"
        StringReplace, NovoSettingsIni, NovoSettingsIni, %A_Space%, _, All
        IniWrite, %NovoSettingsIni%, oldbot_profile.ini, profile, DefaultProfile
        IniWrite, 1, %NovoSettingsIni%, accountsettings, AutoLogin
        Reload(openLauncher := false)
        return
    }

    destroy() {
        Gui, % this.gui ":Destroy"
    }

    createProfile() {
        this.destroy()

        InputBox, NovoProfileNome, % LANGUAGE = "PT-BR" ? "Criar novo perfil" : "Create new profile", % LANGUAGE = "PT-BR" ? "O novo perfil estará com todas as configurações padrões do bot(resetadas).`n`nNome do perfil:" : "The new profile will be with all the default settings of the bot(reseted).`n`nProfile name:",,300,175
        if (ErrorLevel = 1) {
            this.create()
            return
        }

        if (empty(NovoProfileNome)) {
            Msgbox, 64,, % LANGUAGE = "PT-BR" ? "Escreva o nome para o perfil." : "Write a nome for the profile."
            return
        }

        if (FileExist("settings_" NovoProfileNome ".ini")) {
            Msgbox,48,, % LANGUAGE = "PT-BR" ? "Já existe um perfil com este nome." : "There is already a profile with this name."
            return
        }

        StringReplace, NovoProfileNome, NovoProfileNome, %A_Space%,_, All
        NovoProfileNome := RegExReplace(NovoProfileNome,"[^\w]","")
        IniWrite, 1, settings_%NovoProfileNome%.ini, accountsettings, AutoLogin
        IniWrite, %loginEmail%, settings_%NovoProfileNome%.ini, accountsettings, loginEmail

        IniRead, loginPassword, %DefaultProfile%, accountsettings, loginPassword, %A_Space%
        IniWrite, %loginPassword%, settings_%NovoProfileNome%.ini, accountsettings, loginPassword
        ; FileCopy, %DefaultProfile%, settings_%NovoProfileNome%.ini, 1
        IniWrite, settings_%NovoProfileNome%.ini, oldbot_profile.ini, profile, DefaultProfile
        Reload(false)
    }

    deleteProfile() {
        profile := this.profilesList.getSelectedText()
        Gui, ProfileGUI:Submit, Hide
        if (profile = "") {
            Gui, ProfileGUI:Show
            Msgbox,64,, % LANGUAGE = "PT-BR" ? "Selecione um perfil para deletar." : "Select a profile to delete."
            return
        }
        if (profile != "default")
            SettingsIni := "settings_" profile ".ini"
        else
            SettingsIni := "settings.ini"
        MsgBox,52,, % "The profile file """ SettingsIni """ will be deleted.`n`nContinue?"
        ifmsgbox, No
        {
            Gui, ProfileGUI:Show

            return
        }

        FileDelete, %SettingsIni%
        if (ErrorLevel != 0) {
            Msgbox, 16,, % "Error deleting file: " SettingsIni
            return
        }

        if (DefaultProfile_SemIni != profile) {
            this.create()
            return
        }

        DefaultProfile_SemIni := "settings"
        DefaultProfile := "settings.ini"
        NovoSettingsIni := "settings.ini"
        IniWrite, %NovoSettingsIni%, oldbot_profile.ini, profile, DefaultProfile
        IniWrite, 1, %NovoSettingsIni%, accountsettings, AutoLogin
        Reload(false)
    }
}