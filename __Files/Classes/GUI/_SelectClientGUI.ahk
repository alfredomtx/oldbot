
Class _SelectClientGUI extends _AbstractGUI
{
    static INSTANCE

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New(getInstance := false)
    {
        if (getInstance && _SelectClientGUI.INSTANCE) {
            return _SelectClientGUI.INSTANCE
        }

        classLoaded("TibiaClient", TibiaClient)

        base.__New()

        _SelectClientGUI.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    */
    beforeCreate()
    {
        if (TibiaClient.settingsFileText = "")
            TibiaClient.selectClientSettingsJson()

        TibiaClient.tibiaClientGUI := {}
        TibiaClient.tibiaClientGUI.width := 300
    }

    /**
    * @abstract
    * @return void
    */
    create()
    {
        global

        ; Gui, SelectClientGUI:+AlwaysOnTop -MinimizeBox
        ; Gui, SelectClientGUI:-MinimizeBox

        this.openedClientsList()

        this.setFoldersDirectories()

        this.pagoderaFix()

        this.clientsFilters()

        this.clientsList()
    }

    /**
    * @abstract
    * @return void
    */
    afterCreate()
    {
        TibiaClient.selectClientSettingsJson()

        this.loadClientsListLV()
    }

    /**
    * @abstract
    * @return void
    */
    destroy()
    {
        global

        Gui, SelectClientGUI:Destroy
    }

    /**
    * @abstract
    * @return void
    */
    show()
    {
        global

        Gui, SelectClientGUI:Show, % "y" A_ScreenHeight / 4, % txt("Selecione o cliente do Tibia", "Select the Tibia client") " (" _Version.getDisplayVersion() ")"
    }

    /**
    * @return void
    */
    loadClientsListLV()
    {
        this.clientsListLV.list(this.getClientsList())
    }

    openedClientsList()
    {
        global

        Gui, SelectClientGUI:Add, Text, x10 y+5, % (LANGUAGE = "PT-BR" ? "Lista de janelas do Tibia abertas:" : "List of opened Tibia windows:")

        TibiaClient.getClientsList()

        if (TibiaClient.clientsList.MaxIndex() > 20)
            rows := 20
        else
            rows := TibiaClient.clientsList.MaxIndex() < 1 ? 1 : TibiaClient.clientsList.MaxIndex() + 1

        if (rows < 4)
            rows := 4

        Gui, SelectClientGUI:Add, Listbox, % "x10 y+3 w" TibiaClient.tibiaClientGUI.width - 20 " r" rows " vTibiaClientList AltSubmit Choose1", % TibiaClient.clientsListDropdown()
        Gui, SelectClientGUI:Add, Button, x10 y+5 w134 h28 gselectTibiaClientFromList hwndhselectTibiaClient_Button 0x1, % LANGUAGE = "PT-BR" ? "Selecionar cliente" : "Select client"
        Gui, SelectClientGUI:Add, Button, x+2 yp+0 w26 h28 vupdateClientList gselectTibiaClientLabel hwndhupdateClientList
        Disabled := TibiaClient.clientExePath = "" ? "Disabled" : ""
        TT.Add(hupdateClientList, txt("Atualizar lista de janelas", "Refresh windows list"))

        TibiaClient.TibiaClientGUIButtonIcon(hupdateClientList, "imageres.dll", (isWin11() = true) ? 230 : 229, "a0 l0 s20 t1")
        TibiaClient.TibiaClientGUIButtonIcon(hselectTibiaClient_Button, "Data\Files\Images\GUI\icons\icon_tibia_check.png",,"a0 l2 b0 s20")

        ; new _Button().title("Abrir cliente", "Open client")
        ; .name("openSelectedTibiaClient")
        ; .tt(TibiaClient.clientExePath = "" ? "Client directory not set" : "Open client:`n`n" TibiaClient.clientExePath)
        ; .xadd(2).yp().w(63).h(28)
        ; .event("openSelectedTibiaClient")
        ; .disabled(TibiaClient.clientExePath = "")
        ; .gui("SelectClientGUI")
        ; .add()


            new _Button().title("Copiar ID", "Copy ID")
            .name("copySelectedTibiaClientID")
            .xadd(2).yp().w(53).h(28)
            .event("copySelectedTibiaClientID")
            .gui("SelectClientGUI")
            .disabled(Disabled ? true : false)
            .add()

            new _Checkbox().title("Auto Login ao selecionar cliente", "Auto Login when select client")
            .name("autoLoginSelectClient")
            .x(10).y("+8")
            .tt("Loga automaticamente no cliente do Tibia ao selecionar o cliente do Tibia na lista acima.`n`nOBS: A ""Account 1"" deve estar configurada na aba Reconnect.", "Login automatically in the Tibia client after selecting the Tibia client on the list above.`n`nPS: The ""Account 1"" must be configured on the Reconnect tab.")
            .disabled(!isTibia13())
            .state(_ReconnectIniSettings)
            .gui("SelectClientGUI")
            .add()

            new _Checkbox().title("Logar no personagem no Auto Login", "Login in the character on Auto Login")
            .name("autoLoginCharacterLogin")
            .xp().y()
            .tt("Loga automaticamente no personagem ao realizar o Auto Login.`n`nOBS: A ""Account 1"" deve estar configurada na aba Reconnect.", "Login automatically in the character when performing the Auto Login.`n`nPS: The ""Account 1"" must be configured on the Reconnect tab.")
            .disabled(!isTibia13())
            .state(_ReconnectIniSettings)
            .gui("SelectClientGUI")
            .add()
    }

    setFoldersDirectories()
    {
        global

        Gui, SelectClientGUI:Add, GroupBox, % "x10 y+30 w" TibiaClient.tibiaClientGUI.width - 20 " h83 Section", % (LANGUAGE = "PT-BR" ? "Configurar diretórios/pastas" : "Configure directories/folders")

        directoryNotSetString := (LANGUAGE = "PT-BR" ? "Diretório não definido" : "Directory not set")

        string1 := TibiaClient.SET_CLIENT_DIR_BUTTON
        string2 := (LANGUAGE = "PT-BR" ? "Alterar diretório do Cliente" : "Change Client directory")

            new _Button().title(TibiaClient.clientExePath = "" ? string1 : string2)
            .tt(TibiaClient.clientExePath = "" ? directoryNotSetString : string2 "`n`n" TibiaClient.clientExePath)
            .xs(10).yp(20).w(220)
            .event("selectClientExePath")
            .icon(_Icon.get(_Icon.FOLDER), "a0 l5 b0 t1 s18")
            .gui("SelectClientGUI")
            .add()

            new _Button().title("Abrir", "Open")
            .tt(TibiaClient.clientExePath = "" ? directoryNotSetString : "Open folder:`n`n" TibiaClient.clientExePath)
            .xadd(3).yp().w(37)
            .event("openClientPath")
            .disabled(Disabled ? true : false)
            .gui("SelectClientGUI")
            .add()


        string1 := (LANGUAGE = "PT-BR" ? "Definir diretório do Minimap" : "Set Minimap directory")
        string2 := (LANGUAGE = "PT-BR" ? "Alterar diretório do Minimap" : "Change Minimap directory")

            new _Button().title(TibiaClient.clientMinimapPath = "" ? string1 : string2)
            .tt(TibiaClient.clientMinimapPath = "" ? string1 : string2 "`n`n" TibiaClient.clientMinimapPath)
            .xs(10).y().w(220)
            .event("changeMinimapFolder")
            .icon(_Icon.get(_Icon.FOLDER), "a0 l5 b0 t1 s18")
            .gui("SelectClientGUI")
            .add()

        Disabled := TibiaClient.clientMinimapPath = "" ? "Disabled" : ""
            new _Button().title("Abrir", "Open")
            .tt(TibiaClient.clientMinimapPath = "" ? directoryNotSetString : "Open folder:`n`n" TibiaClient.clientMinimapPath)
            .xadd(3).yp().w(37)
            .event("openMinimapPath")
            .disabled(Disabled ? true : false)
            .gui("SelectClientGUI")
            .add()
    }

    pagoderaFix()
    {
        global

        if (TibiaClient.clientIdentifierByJsonFileName(OldbotSettings.settingsJsonObj.configFile) = "pagodera") {
            Gui, SelectClientGUI:Font, Bold
            Gui, SelectClientGUI:Add, GroupBox, % "x10 y+20 w" TibiaClient.tibiaClientGUI.width - 20 " h83 Section", % "Pagodera OT Fix"
            Gui, SelectClientGUI:Font, Normal
            Gui, SelectClientGUI:Font

            Gui, SelectClientGUI:Add, Button, xp+10 yp+20 w260 h25 gfixPagoderaGraphicClient hwndhfixPagoderaGraphicClient, % txt("Corrigir visual " TibiaClient.Tibia13Identifier " no PAGODERA OT", "Fix " TibiaClient.Tibia13Identifier " visual on PAGODERA OT")
            TT.Add(hfixPagoderaGraphicClient, txt("Use essa opção para restaurar o visual padrão do " TibiaClient.Tibia13Identifier " no Pagodera OT.`nIsto é necessário para o bot funcionar corretamente, porém algumas sprites customizadas do OT como da Magic Wall colorida não funcionarão.`n`n- Como desfazer essa alteração?`nApague o arquivo ""Version.txt"" na pasta ""Pagodera"" e rode o ""GameLauncher.exe""(ou faça backup da pasta ""bin"" original manualmente).", "Use this option to restore the default visual of " TibiaClient.Tibia13Identifier " client on Pagodera OT.`nThis is needed for the bot to work correctly, but some custom sprites of the OT such as the coloured Magic Wall won't work.`n`n- How to undo this change?`nDelete the ""Version.txt"" file in the ""Pagodera"" folder and run the ""GameLauncher.exe""(or do a backup of the original ""bin"" folder manually)."))

            icon := _Icon.get(_Icon.CHECK_SETTINGS)
            TibiaClient.TibiaClientGUIButtonIcon(hfixPagoderaGraphicClient, icon.dllName, icon.number,"a0 l3 b0 s18")

            Gui, SelectClientGUI:Font, cGray
            w := TibiaClient.tibiaClientGUI.width - 40
            Gui, SelectClientGUI:Add, Text, xp+0 y+3 w%w%, % txt("O cliente do Tibia Global precisa estar instalado e atualizado para fazer essa correção.", "The Tibia Global client must be installed and updated to do this fix.")
            Gui, SelectClientGUI:Font, Normal
            Gui, SelectClientGUI:Font
        }
    }

    clientsFilters()
    {
        global

        list := ""
        for key, value in TibiaClient.clientsJsonList
        {
            if (value.hide)
                continue
            list .= value.text "|"
        }
        ; list .= value.text " (" value.file ")|"

        TibiaClient.clientSettingsElements := {}
        TibiaClient.clientSettingsElements.x := 310
        TibiaClient.clientSettingsElements.w := 300


        Gui, SelectClientGUI:Font, Bold cRed
        Gui, SelectClientGUI:Add, Text, % "x" TibiaClient.clientSettingsElements.x " w" TibiaClient.clientSettingsElements.w " y3 Section Center", % (LANGUAGE = "PT-BR" ? "Selecione na lista abaixo o OT Server onde o bot irá funcionar." : "Select in the list below OT Server where the bot will work.")
        Gui, SelectClientGUI:Font, Normal
        Gui, SelectClientGUI:Font

        Gui, SelectClientGUI:Add, Groupbox, % "x" TibiaClient.clientSettingsElements.x " y+5 w" TibiaClient.clientSettingsElements.w " h50 ", % (LANGUAGE = "PT-BR" ? "Pesquisar na lista" : "Search in the list")

        Gui, SelectClientGUI:Add, Edit, % "xs+10 yp+18 w" TibiaClient.clientSettingsElements.w - 20 " vclientListFilterName gclientListFiter hwndhclientListFilterName", % clientListFilterName

        TT.Add(hclientListFilterName, (LANGUAGE = "PT-BR" ? "Pesquisar por nome..." : "Search by name..."))
    }

    clientsList()
    {
        global

        this.clientsListLV := new _Listview().name("LV_ClientsList")
            .title(Array(txt("Nome", "Name")))
            .x("s+0").y("+15").w(TibiaClient.clientSettingsElements.w).r(10)
            .options("-HScroll", "Grid", "NoSort", "NoSortHdr")
            .checked()
            .event(this.selectClient.bind(this))
            .gui("SelectClientGUI")
            .add()

        ; Gui, SelectClientGUI:Add, ListView, % "xs+0 y+15 w" TibiaClient.clientSettingsElements.w " r10 vLV_ClientsList gLV_ClientsList AltSubmit Checked Grid -HScroll NoSort NoSortHdr ", % "Name|Injection|#"
        ; Gui, SelectClientGUI:Add, Button, x+3 yp+0 w98 h25 gRestoreTibiaClientTitle, % "Restore title"

        buttonTitle := txt("Adicionar novo cliente/OT", "Add new client/OT")
        SetEditCueBanner(hclientListFilterName, (LANGUAGE = "PT-BR" ? "Pesquisar por nome..." : "Search by name..."))
        TT.Add(hclientListFilterName, (LANGUAGE = "PT-BR" ? "O cliente do OT que você quer não está na lista?`n`nSe for cliente versão Tibia 12/13+, clique no botão """ buttonTitle """ abaixo para adicionar.`n`nCaso seja outra versão(7.4, 8.0, custom...), entre em contato com o Admin no Discord ou Facebook para verificar a possibilidade de adicionar :)" : "The client of the OT you want is not in the list?`n`nIf the client is version Tibia 12/13+, click on """ buttonTitle """ button below to add.`n`nIn case it is another version(7.4, 8.0, custom...), contact the Admin on Discord or Facebook for check the if is possible to be added :)"))

        Gui, SelectClientGUI:Add, Button, % "xs+0 y+5 w" TibiaClient.clientSettingsElements.w " h28 gaddNewClientMemory hwndhaddNewClientMemory", % buttonTitle
        TT.Add(haddNewClientMemory, txt("Adicionar um novo cliente " TibiaClient.Tibia13Identifier " na lista para usar a injeção de memória.", "Add a new " TibiaClient.Tibia13Identifier " client to use the memory injection."))
        TibiaClient.TibiaClientGUIButtonIcon(haddNewClientMemory, "Data\Files\Images\GUI\icons\icon_tibia.png",,"a0 l5 b0 s24")

    }

    /**
    * @return array<_Row>
    */
    getClientsList()
    {
        local list
        ; static list
        ; if (list) {
        ;     return list
        ; }

        list := {}
        rowNumber := 1
        for index, value in TibiaClient.clientsJsonList
        {
            if (value.hide) {
                continue
            }

            if (!empty(clientListFilterName)) && (!InStr(value.text, clientListFilterName)) {
                continue
            }

            row := new _Row()
                .add(value.text)
                .setNumber(rowNumber)
            rowNumber++

            if (value.file = OldBotSettings.settingsJsonObj.configFile) {
                row.setSelected(true)
            }

            list.Push(row)
        }

        return list
    }

    selectClient(control, value, CtrlHwnd, GuiEvent, EventInfo, ErrLevel)
    {
        ; _Logger.log(A_ThisFunc, CtrlHwnd " | " GuiEvent " | " EventInfo " | " ErrLevel)
        row := EventInfo
        event := ErrLevel

        if (!row || !event) {
            return
        }

        text := this.clientsListLV.getText(row, 1)
        if (!text) {
            return
        }

        if (event == "C") {
            selectedRows := this.clientsListLV.getSelectedRows()
            if (!selectedRows.Count()) {
                return
            }

            TibiaClient.clientSettingsJson(text)
            Reload()
        }


    }
}
