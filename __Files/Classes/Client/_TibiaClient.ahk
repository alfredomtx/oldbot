#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

global WindowX
global WindowY
global WindowWidth
global WindowHeight

global TibiaClientMenu
global TibiaClientID
global TibiaClientTitle
global TibiaClientExeName


global LV_ClientsList

global clientListFilterName

global TibiaClientGUI_ICON_COUNTER := 0
global TibiaClientGUI_ICONBUTTONS

class _TibiaClient
{
    static TIBIA_14_IDENTIFIER := "Tibia 14+"

    __New()
    {
        this.Tibia13Identifier := "Tibia 12/13+"
        this.Tibia7xIdentifier := "Tibia 7.x"

        IniRead, TibiaClientID, %DefaultProfile%, advanced, TibiaClientID, %A_Space%

        this.clientNotSelectedText := "[Not selected]"
        this.TitleTibiaClientMenu := this.clientNotSelectedText
        ; this.windowTitleSearch := "] - O"
        ; this.windowTitleSearch := "Windows 10 12 - VMware Workstation"
        this.windowTitleSearch := OldbotSettings.settingsJsonObj.tibiaClient.windowTitle
        this.windowClassFilter := OldbotSettings.settingsJsonObj.tibiaClient.windowClassFilter

        this.setClientPaths()

        minimapFolder := this.clientMinimapPath

        this.showOtherClients := false

        this.createClientsJsonList()

        this.readTibiaClientIniSettings()


        this.SET_CLIENT_DIR_BUTTON := (LANGUAGE = "PT-BR" ? "Definir pasta do Cliente" : "Set Client folder")
    }

    createClientsJsonList() {
        this.clientsJsonList := ""
        this.clientsJsonList := {}
        this.clientsJsonList.Push({"file": "settings.json","text": this.Tibia13Identifier, "tibia12": true})

        Loop, % OldBotSettings.JsonFolder "\settings*.json"
        {
            info := {}
            ignore := false
            for _, value in this.clientsJsonList
            {
                if (A_LoopFileName = value.file) {
                    ignore := true
                    break
                }
            }
            if (ignore = true)
                continue


            ; msgbox, % A_LoopFileName
            info.file := A_LoopFileName
                , info.text := this.clientIdentifierByJsonFileName(A_LoopFileName)
                , this.clientsJsonList.Push(info)
        }
        this.listSortedByName := {}

        for key, value in this.clientsJsonList
            this.listSortedByName[value.text] := value


        tibia12DefaultInfo := this.clientsJsonList.1

        this.clientsJsonList := {}
        this.clientsJsonList.Push(tibia12DefaultInfo)

        this.listSortedByName.Remove(this.Tibia13Identifier)
        ; clientsRead := {}
        for key, value in this.listSortedByName
        {
            info := {}
                , info.file := value.file
                , info.text := value.text
                , info.hide := value.hide

            if (value.HasKey("tibia12"))
                info.tibia12 := value.tibia12
            if (value.HasKey("tibia7x"))
                info.tibia7x := value.tibia7x

            /**
            if both are empty, need to read the json file to check the client
            */
            if (info.tibia12 = "" && info.tibia7x = "") && (value.text != this.Tibia13Identifier) {
                clientSettingsJsonFile := "", clientSettingsJsonFileObj := ""
                try {
                    clientSettingsJsonFile := new JSONFile(OldbotSettings.JsonFolder "/" value.file)
                } catch {
                    ; if (!A_IsCompiled) {
                    ;     msgbox, 16, % A_ThisFunc, % "Failed to read file:`n" value.file
                    ; }
                }
                if (clientSettingsJsonFile != "") {
                    clientSettingsJsonFileObj := clientSettingsJsonFile.Object()
                    if (clientSettingsJsonFileObj.tibiaClient.HasKey("tibia12"))
                        info.tibia12 := true
                    if (clientSettingsJsonFileObj.tibiaClient.HasKey("tibia7x"))
                        info.tibia7x := true
                    clientSettingsJsonFile := "", clientSettingsJsonFileObj := ""
                    ; clientsRead.push(value.text)
                }
            }

            this.clientsJsonList.Push(info)
        }
        ; m(serialize(clientsRead))

        this.listSortedByName := ""
        ; msgbox, % serialize(this.listSortedByName)
        ; msgbox, % serialize(this.clientsJsonList)
    }

    setClientPaths()
    {
        IniRead, tibiaClientDir, %DefaultProfile%, client_settings, tibiaClientDir, %A_Space%
        IniRead, tibiaClientExePath, %DefaultProfile%, client_settings, tibiaClientExePath, %A_Space%
        IniRead, tibiaClientMinimapFolderPath, %DefaultProfile%, client_settings, tibiaClientMinimapFolderPath, %A_Space%

        ; msgbox, % tibiaClientExePath "`n" tibiaClientMinimapFolderPath
        this.clientDir := tibiaClientDir
        this.clientExePath := tibiaClientExePath
        this.clientMinimapPath := tibiaClientMinimapFolderPath
        minimapFolder := this.clientMinimapPath

        if (this.clientMinimapPath = "")
            return
        ; \minimap
        StringTrimRight, clientPath, % this.clientMinimapPath, 8
        ; msgbox, % clientPath


        this.clientFolderPath := clientPath

        this.clientConfPath := this.clientFolderPath "\conf"


    }

    clientFolderExists() {
        if (this.clientExePath = "" OR this.clientExePath = A_Space)
            throw Exception(txt("Pasta do cliente do Tibia não setado.", "Tibia client folder not set."))

        if (!FileExist(this.clientExePath))
            throw Exception(txt("Pasta do cliente do Tibia não existe:", "Tibia client folder doesn't exist:") "n" this.clientExePath)
    }

    selectTibiaExePath() {
        FileSelectFile, tibiaExe, 3,, % "Select the Tibia client executable", (*.exe)
        if (tibiaExe = "")
            return

        SplitPath, tibiaExe,, tibiaDir, Extension
        ; msgbox, % Extension "`n" tibiaExe "`n" tibiaDir

        if (Extension != "exe")
            throw Exception("You must selected an executable file.")

        exeName := OldbotSettings.settingsJsonObj.tibiaClient.clientExeName
        if (exeName != "" && exeName != "*" && !InStr(tibiaExe, exeName)) {
            string1 := (LANGUAGE = "PT-BR" ? "Selecione o executável correto do cliente" : "Please select the correct client executable")
            throw Exception(string1 ": " exeName "`n`n" (LANGUAGE = "PT-BR" ? "Você selecionou: " : "You selected: ") "`n" tibiaExe)
        }

        if (this.clientIdentifierByJsonFileName(OldbotSettings.settingsJsonObj.configFile) = "pagodera") {
            tibiaExe := StrReplace(tibiaExe, "client.exe", "pagodera_client.exe")
        }

        this.checkIfIsOneDriveFolder(tibiaExe)

        tibiaClientExePath := tibiaExe
        tibiaClientDir := tibiaDir
        IniWrite, % tibiaClientDir, %DefaultProfile%, client_settings, tibiaClientDir
        IniWrite, % tibiaClientExePath, %DefaultProfile%, client_settings, tibiaClientExePath

        this.setMinimapFolder(tibiaClientDir)



        this.setClientPaths()
    }

    setMinimapFolder(tibiaClientDir) {


        ; C:\Users\Alfredo\Documents\OTs\TaleonClient\bin

        possibleMinimapDir := StrReplace(tibiaClientDir, "\bin", "\minimap")
        if (!FileExist(possibleMinimapDir)) {
            return
        }
        IniWrite, % possibleMinimapDir, %DefaultProfile%, client_settings, tibiaClientMinimapFolderPath
    }

    checkIfIsOneDriveFolder(dir) {
        if (InStr(dir, "\OneDrive\") OR InStr(dir, "/OneDrive/")) {
            throw Exception((LANGUAGE = "PT-BR" ? "A pasta selecionada está dentro da pasta do ""OneDrive"", isto pode causar problemas com o OneDrive restaurando arquivos antigos.`nMova para outra pasta fora do OneDrive e tente novamente." : "The selected folder is inside the ""OneDrive"" folder, this can cause problems with OneDrive restoring old files.`nMove to another folder outside of OneDrive and try again.") "`n`n" dir )
        }
    }

    selectMinimapFolderPath(selectedMinimapFolder := "") {
        if (selectedMinimapFolder = "")
            return
        if (StrLen(selectedMinimapFolder) < 8)
            throw Exception("The folder is too short (" selectedMinimapFolder ").")

        ; m(selectedMinimapFolder)

        /**
        remove the last \ from the end of the string
        */
        char := SubStr(selectedMinimapFolder, -0)
        if (char = "\" OR char = "/")
            StringTrimRight, selectedMinimapFolder, selectedMinimapFolder, 1

        if (!FileExist(selectedMinimapFolder))
            throw Exception("The folder in this folder doesn't exist: " selectedMinimapFolder)


        if (isTibia13()) && (!InStr(selectedMinimapFolder, "minimap"))
            throw Exception((LANGUAGE = "PT-BR" ? "Pasta errada selecionado, você deve selecionar a pasta da pasta ""minimap"".`n`n- Exemplo para " this.Tibia13Identifier "(global):`nC:\Users\XXXXX\AppData\Local\Tibia\packages\Tibia\minimap`n`n- Exemplo para " this.Tibia13Identifier "(Taleon OT Server):`nC:\Users\XXXXX\Documents\TaleonClient\minimap" : "Wrong folder selected, you must select the folder of the ""minimap"" folder.`n`n- Example for " this.Tibia13Identifier "(global):`nC:\Users\XXXXX\AppData\Local\Tibia\packages\Tibia\minimap`n`n- Example for " this.Tibia13Identifier "(Taleon OT Server):`nC:\Users\XXXXX\Documents\TaleonClient\minimap"))

        try {
            this.checkIfIsOneDriveFolder(selectedMinimapFolder)
        } catch e {
            _Logger.msgboxException(48, e)
        }

        ; FileSelectFolder, selectedMinimapFolder,, 0, % "Select the minimap folder path"
        ; if (selectedMinimapFolder = "")
        ; return

        tibiaClientMinimapFolderPath := selectedMinimapFolder
        IniWrite, % tibiaClientMinimapFolderPath, %DefaultProfile%, client_settings, tibiaClientMinimapFolderPath

        this.setClientPaths()
    }

    renameMenu(Title) {
        global

        try {
            Menu, MyMenuBar, Rename, % this.TitleTibiaClientMenu, % Title
            this.TitleTibiaClientMenu := Title
        } catch e {
            ; if (!A_IsCompiled)
            ; Msgbox, 48,, % e.Message "`n" e.What "`n" e.File "`n" e.Line
            try {
                Menu, MyMenuBar, Rename, % this.clientNotSelectedText, % Title
                this.TitleTibiaClientMenu := Title
            } catch {
            }
        }

    }

    isClientOpened() {
        state := this.isClientClosed()
        return !state
    }

    forceCloseClient(sleep := true) {
        return
        Run powershell -Command "Restart-Service LxssManager",, hide
        if (sleep)
            Sleep, 2000
    }

    exportClientOptions() {

        CarregandoGUI(LANGUAGE = "PT-BR" ? "Exportando..." : "Exporting...")
        folder := this.clientConfPath

        if (!FileExist(folder)) {
            Gui, Carregando:Destroy
            Msgbox, 16,, % LANGUAGE = "PT-BR" ? "Pasta de configurações do Tibia """ folder """ não existe." : "The config Tibia folder """ folder """ doesn't exist."
            return
        }
        json_file := this.clientConfPath "\clientoptions.json"
        if (!FileExist(json_file)) {
            Gui, Carregando:Destroy
            Msgbox, 16,, % "Tibia setting file doesn't exist: " json_file
            return
        }
        FileCopy, %json_file%, %A_Desktop%\clientoptions.json, 1
        if (ErrorLevel != 0) {
            Gui, Carregando:Destroy
            Msgbox, 16,, % "Failed to move clientoptions.json file to the Desktop.`n`nError: " A_LastError " | " e.Message " | " e.What " | " e.Extra
            return
        }
        Gui, Carregando:Destroy
        Msgbox, 64,, % "File ""clientoptions.json"" exported to your Desktop."
    }

    importClientOptions() {

        CarregandoGUI(LANGUAGE = "PT-BR" ? "Carregando..." : "Loading...")
        if (this.isClientOpened() = true)
            throw Exception("Close the Tibia client to continue.")

        FileSelectFile, json_file, 3,, % "Select the ""clientoptions.json"" file", (*.json)
        if (json_file = "")
            return

        if (!InStr(json_file, "clientoptions"))
            throw Exception("You must selected the ""clientoptions.json"" file.")

        CarregandoGUI("Importing clientoptions.json...")
        ; IfNotExist, C:\app_oldbot
        ; throw Exception(LANGUAGE = "PT-BR" ? "Pasta do ambiente do Tibia (C:\app_oldbot) não existe" : "Folder of the Tibia ambient (C:\app_oldbot) doesn't exist.")

        folder := this.clientConfPath
        if (!FileExist(folder))
            throw Exception(LANGUAGE = "PT-BR" ? "Pasta de configurações do Tibia """ folder """ não existe." : "The config Tibia folder """ folder """ doesn't exist.")
        if (!RegExMatch(json_file,".json")) {
            throw Exception(LANGUAGE = "PT-BR" ? "O arquivo selecionado não está no formato "".json""." : "The selected file is not in the "".json"" format.")
            return
        }

        this.forceCloseClient()

        dest := this.clientConfPath "\clientoptions.json"
        source := json_file
        try FileCopy, %source%, %dest%, 1
        catch e
            throw Exception("Failed to replace clientoptions.json file, please try again.`n`nError: " A_LastError " | " e.Message " | " e.What " | " e.Extra)
        ; FileMove, Source, Dest [, Flag (1 = overwrite)]
        Gui, Carregando:Destroy
        Msgbox, 64,, % LANGUAGE = "PT-BR" ? "Sucesso." : "Success."
    }

    updateMenuClient() {
        global
        WinGetTitle, TibiaClientTitle, ahk_id %TibiaClientID%
        /**
        client with the ID is not opened anymore
        */
        if (TibiaClientTitle = "") {
            this.renameMenu(this.clientNotSelectedText)
            return
        }

        if (!InStr(TibiaClientTitle, "*"))
            this.TibiaClientOldTitle := TibiaClientTitle

        TibiaClientTitle := StrReplace(TibiaClientTitle, OldbotSettings.settingsJsonObj.tibiaClient.removeStringFromTitle, "")

        Loop, parse, % OldbotSettings.settingsJsonObj.tibiaClient.removeStringFromTitle, % "|"
        {
            TibiaClientTitle := StrReplace(TibiaClientTitle, A_LoopField, "")
        }

        clientIdWindow := StrReplace(TibiaClientID, "0x", "")

        NewTibiaClientMenu := "[" TibiaClientTitle " | " SubStr(clientIdWindow, 3, StrLen(clientIdWindow)) "]"

        WinSetTitle, ahk_id %TibiaClientID%,, % TibiaClientTitle

        try {
            GuiControl, ShortcutScripts:, shortcutGuiClientTitle, % TibiaClientTitle
        } catch {
        }
        this.renameMenu(NewTibiaClientMenu)
    }


    getClientArea(reloadIfClosed := false, tooltipText := "", throwException := false) {
        global
        if (TibiaClientID = "") {
            Msgbox,64,, % (LANGUAGE = "PT-BR" ? "Cliente do Tibia não selecionado." : "Tibia client not selected."), 2
            return false
        }

        WinGetTitle, TibiaClientTitle, ahk_id %TibiaClientID%
        if (TibiaClientTitle = "") {
            Gui, Carregando:Destroy
            Gui, CarregandoGUI:Destroy
            if (this.autoSelectFirstClient() = false) {
                error := "Selected Tibia Client window doesn't exists anymore, select the client again or disable the """ tooltipText """ functions."
                if (throwException = true)
                    throw Exception(error)
                Msgbox, 48,, % error, 2
                return false
            }
            WinGetTitle, TibiaClientTitle, ahk_id %TibiaClientID%
        }


        this.isClientMinimized()
        if (reloadIfClosed = true) {
            ; OutputDebug(A_ThisFunc, A_ScriptName "|" tooltipText)
            if (this.isClientClosed(true, tooltipText) = true)
                return
        }

        WinGetPos, WindowX, WindowY, WindowWidth, WindowHeight, ahk_id %TibiaClientID%
        if (WindowWidth = 0 OR WindowWidth = "" OR WindowHeight = 0 OR WindowHeight = "") {
            error := "Invalid Tibia client window size.`nw: " WindowWidth "`nh: " WindowHeight
            if (throwException = true)
                throw Exception(error)
            Msgbox, 48,, % error, 2
            return false
        }
        return true
    }

    getClientAreaFunctions(exeName) {
        try this.getClientArea(true, exeName, throwException := true)
        catch e {
            Gui, Carregando:Destroy
            OutputDebug(A_ThisFunc "->" exeName, e.Message)
            ; msgbox, 48,, % e.Message, 60
            Random, R, 2, 5
            Sleep, % R
            Reload
            return false
        }
        return true
    }

    windowExists() {
        if (TibiaClientID = "")
            return false
        if (this.windowTitleSearch = "")
            return true
        WinGetTitle, TibiaWindow, % "ahk_id " TibiaClientID
        ; msgbox, % TibiaWindow

        if (empty(TibiaWindow)) {
            return false
        }

        if (this.windowTitleSearch == "*") {
            return true
        }

        if (InStr(TibiaWindow, this.windowTitleSearch))
            return true

        return false
    }

    tooltipAndReload(tooltipText := "") {
        /**
        don't show tooltips anymore
        */
        ; if (tooltipText != "")
        ; Tooltip, % tooltipText
        Random, R, 4, 8
        Sleep, %R%000
        Reload
        Sleep, 10000
    }

    isClientClosed(reload := false, tooltipText := "") {
        if (TibiaClientID = "") {
            if (reload = true)
                this.tooltipAndReload("Client closed [" tooltipText "]")
            return true
        }
        WinGetTitle, TibiaWindow, ahk_id %TibiaClientID%
        ; msgbox, % A_ThisFunc "`n" TibiaWindow
        if (TibiaWindow = "") {
            if (reload = true)
                this.tooltipAndReload("Client closed [" tooltipText "]")
            return true
        }

        return false
    }

    isClientMinimized(maximize := true) {
        if (TibiaClientID = "")
            return false
        WinGet, MMX, MinMax, ahk_id %TibiaClientID%
        if (MMX = "-1") {
            if (maximize = true)
                WinActivate, ahk_id %TibiaClientID% ; restore client if minimized
            return true
        }

        return false
    }

    isDisconnectedLoopWaitOrExit(moduleName) {
        if (OldBotSettings.settingsJsonObj.disconnectedCheck.enabled = false) {
            return false
        }

        sleepDelay := 3000
        disconnectedBefore := false
        Loop, {
            IniRead, TibiaClientID, %DefaultProfile%, advanced, TibiaClientID, %A_Space%
            if (this.windowExists() = false) {
                OutputDebug(moduleName, "[CLOSING] Client window doesn't exist, CLOSING module " moduleName ".")
                ExitApp
            }

            if (OldBotSettings.settingsJsonObj.disconnectedCheck.connectedWindowTitle == "*") {
                break
            }

            WinGetTitle, TibiaWindow, ahk_id %TibiaClientID%
            if (InStr(TibiaWindow, OldBotSettings.settingsJsonObj.disconnectedCheck.connectedWindowTitle)) {
                break
            }

            disconnectedBefore := true
            OutputDebug(moduleName, "[WAITING] Client disconnected...")
            Random, R, 500, 1000
            Sleep, % sleepDelay + R
        }

        if (disconnectedBefore = true) {
            OutputDebug(moduleName, "[STARTING] Client is now connected...")
        }
    }

    isDisconnected(reloadDisconnected := false, tooltipText := "") {
        if (OldBotSettings.settingsJsonObj.disconnectedCheck.enabled = false) {
            return false
        }

        if (this.windowExists() = false) {
            return true
        }

        if (false) {
            global Desconectado := _WaitDisconnected.searchImage().notFound()

            return Desconectado
        }

        WinGetTitle, TibiaWindow, ahk_id %TibiaClientID%

        if (!InStr(TibiaWindow, OldBotSettings.settingsJsonObj.disconnectedCheck.connectedWindowTitle)) {
            global Desconectado = 1
            if (reloadDisconnected = true)
                this.tooltipAndReload("Disconnected [" tooltipText "]")
            return true
        }

        global Desconectado = 0
        return false
    }

    getClientsList()
    {
        if (!this.windowTitleSearch || this.windowTitleSearch == "*") {
            winGet, winList, list, % "ahk_class " this.windowClassFilter
        } else {
            winGet, winList, list, % this.windowTitleSearch
        }

        this.clientsList := {}
        hasWindows := false
        Loop, %winList% {
            if (winList%A_Index% = "")
                break
            hasWindows := true
            WinGetTitle, tibia_title%A_Index%, % "ahk_id " winList%A_Index%
            title := tibia_title%A_Index%
            ; msgbox, % tibia_title%A_Index%
            ; if (!InStr(tibia_title%A_Index%, "Tibia"))
            ; continue

            /**
            Windows Tibia 11/12 Client (OT Server)
            */
            if (this.windowClassFilter) {
                WinGetClass, windowClass,  % "ahk_id " winList%A_Index%
                ; msgbox, % tibia_title%A_Index% "`n" windowClass
                ; msgbox, %
                ; msgbox, % windowClass

                valid := false
                for _, className in _Arr.wrap(this.windowClassFilter) {
                    if (InStr(windowClass, className)) {
                        valid := true
                        break
                    }
                }

                if (!valid) {
                    _Logger.log(A_ThisFunc, "Window not valid: " windowClass " | " this.windowClassFilter)
                    break
                }

                WinGetPos, _, _, W, H, % "ahk_id " winList%A_Index%
                /**
                Second "ghost" window in some Tibia 13 clients (calmera ot)
                */
                ; m(W " , " H)
                if (W < 10 && H < 10) {
                    _Logger.log(A_ThisFunc, "Window too small: " W " | " H)
                    continue
                }
            }

            client_info := Object("id", winList%A_Index%, "title", tibia_title%A_Index%)
            this.clientsList.Push(client_info)
        }

        if (hasWindows = false) {
            _Logger.log(A_ThisFunc, "No windows found: " this.windowTitleSearch " | " this.windowClassFilter)
        } else {
            _Logger.log(A_ThisFunc, "Windows found: " this.windowTitleSearch " | " this.windowClassFilter)
            _Logger.log(A_ThisFunc, serialize(this.clientsList))
        }

        if (this.clientsList.Count() < 1) {
            IniDelete, %DefaultProfile%, advanced, TibiaClientID
        }

        ; msgbox, % serialize(this.clientsList)
        /**
        SetTitleMatchMode, 2

        ChildWinTitle = Tibia

        DetectHiddenWindows On  ; Due to fast-mode, this setting will go into effect for the callback too.

        ; For performance and memory conservation, call RegisterCallback() only once for a given callback:
        if not EnumAddress  ; Fast-mode is okay because it will be called only from this thread:
        EnumAddress := RegisterCallback("EnumChildProc") ; , "Fast")

        WinGet, active_id, ID, %ParentWinTitle%
        active_id := this.clientsList[1]["id"]
        ; Msgbox "HWND=%active_id%"

        ; Pass control to EnumWindows(), which calls the callback repeatedly:
        SearchChildTitle = %ChildWinTitle%


        result:= DllCall("EnumChildWindows", UInt, active_id, UInt, EnumAddress, UInt, 0)

        msgbox, % EnumAddress
        MsgBox "ErrorLevel=%ErrorLevel%"
        MsgBox ""EnumChildWindows", UInt, %active_id%, UInt, %EnumAddress%, UInt, 0, UInt, 0)"
        MsgBox %Output%  ; Display the information accumulated by the callback.
        */


        return this.clientsList
    }

    clientsListDropdown()
    {
        clients_list := "", client := "", title := ""
        for key, value in this.clientsList
        {
            value["title"] := StrReplace(value["title"], "|", "-")
            id := value["id"], title := value["title"]
                , clients_list .= "[" key "] " title " (" id ")|"

        }

        _Logger.log(A_ThisFunc, serialize(this.clientsList))
        _Logger.log(A_ThisFunc, clientsList)
        return clients_list
    }


    selectFirstClient()
    {
        this.getClientsList()

        if (!this.clientsList.Count()) {
            return false
        }

        if (this.clientsList.Count() = 1) {
            this.selectTibiaClient(this.clientsList[1]["id"])
            return true
        }

        return false
    }

    autoSelectFirstClient(autoLogin := true)
    {
        this.getClientsList()

        if (this.selectFirstClient()) {
            Gui, SelectClientGUI:Destroy
            if (autoLogin) {
                _Reconnect.autoLogin(true)
            }
            return
        } else {
            if (TibiaClientID) {
                WinGet, name, ProcessName, ahk_id %TibiaClientID%
                if (name) {
                    this.selectTibiaClient(TibiaClientID)
                    if (autoLogin) {
                        _Reconnect.autoLogin(true)
                    }

                    return
                }
            }
        }

        return this.listTibiaClientsGUI()
    }

    listTibiaClientsGUI() {
        global

            new _SelectClientGUI()
    }

    getSettingFileNameByPosition(position) {
        for key, value in this.clientsJsonList
        {
            if (key = position) {
                return value
            }
        }

        throw Exception("File position not found: " OldBotSettings.settingsJsonObj.configFile)
    }

    getSettingFilePosition() {
        for key, value in this.clientsJsonList
        {
            if (OldBotSettings.settingsJsonObj.configFile = value.file) {
                return key
            }
        }
        throw Exception("File position not found: " OldBotSettings.settingsJsonObj.configFile)
    }

    clientSettingsJson(client) {
        for key, value in this.clientsJsonList {
            if (value.text = client) {
                this.setCurrentClientJson(value.file, client)
                return
            }
        }
    }

    setCurrentClientJson(fileName, client)
    {
        defaultSettingsJson := OldBotSettings.settingsFileJson()
        defaultSettingsJsonObj := defaultSettingsJson.Object()

        this.writeCurrentClientJson(fileName)

        defaultSettingsJsonObj.configFile := fileName
        defaultSettingsJson.save(true)
    }

    writeCurrentClientJson(fileName)
    {
        IniWrite, % fileName, %DefaultProfile%, client, DefaultClientJsonProfile
    }

    selectClientSettingsJson() {
        for key, value in this.clientsJsonList {
            if (value.file = OldBotSettings.settingsJsonObj.configFile) {
                try {
                    GuiControl, SelectClientGUI:Choose, TibiaClientSettingsJson, % value.text
                } catch {
                }
                this.settingsFileText := StrReplace(value.file, "settings_", "")
                return
            }
        }
    }

    updateSettingsFileMenu() {
        if (OldBotSettings.settingsJsonObj.configFile = "settings.json") {
            return
        }

        this.selectClientSettingsJson()
        ; msgbox, % settingsFileMenu "`n" this.settingsFileText
        try Menu, MyMenuBar, Rename, % settingsFileMenu, % "[" StrReplace(this.settingsFileText, ".json", "") "]"
        catch e {
            Msgbox, 48, % A_ThisFunc, % "Failed to rename Menu: `n" e.Message "`n" e.What, 6
        }
    }

    getClientIdentifier(memoryIdentifier := false)
    {
        settings := new _SettingsJson()

        if (memoryIdentifier = true) && (settings.get("tibiaClient.memoryIdentifier") != "")
            return settings.get("tibiaClient.memoryIdentifier")
        if (settings.get("tibiaClient.clientImagesCategoryIdentifier") = "")
            return this.clientIdentifierByJsonFileName(settings.get("configFile"))
        else
            return settings.get("tibiaClient.clientImagesCategoryIdentifier")
    }

    clientIdentifierByJsonFileName(jsonFileName) {
        fileName := StrReplace(jsonFileName, "settings_")
        return StrReplace(fileName, ".json", "")
    }

    restoreTibiaWindowTitle() {
        if (TibiaClientID = "") {
            Msgbox, 64,, % "No Tibia client selected."
            return
        }

        if (this.TibiaClientOldTitle = "") {
            Msgbox, 64,, % "No information about the original Tibia window title, you will need to login in the character and select the client again to restore."
            return
        }



        WinSetTitle, ahk_id %TibiaClientID%,, % this.TibiaClientOldTitle
        NewTibiaClientMenu := "[" this.TibiaClientOldTitle " | ID: " TibiaClientID "]"
        this.renameMenu(NewTibiaClientMenu)
    }

    changeWindowCaption(show := false)
    {
        if (show = false)
            WinSet, Style, -0xC00000, ahk_id %TibiaClientID%
        else
            WinSet, Style, +0xC00000, ahk_id %TibiaClientID%
        WinMinimize, ahk_id %TibiaClientID%
        Sleep, 200
        WinRestore, ahk_id %TibiaClientID%
    }

    selectTibiaClient(clientID)
    {
        if (this.clientIdentifierByJsonFileName(OldbotSettings.settingsJsonObj.configFile) = "pagodera") {
            IniRead, PagoderaGraphicsFileReplaced, %A_Temp%\OldBot\oldbot.ini, settings, PagoderaGraphicsFileReplaced, %A_Space%
            if (PagoderaGraphicsFileReplaced != 1) {
                Msgbox, 64, % "Fix client Pagodera OT", % txt("É necessário realizar o fix do visual do cliente para o Pagodera OT, clique no botão na tela de ""Selecionar Client"".", "It's needed to do the visual fix for the Pagodera OT client, click on the button in the ""Select Client"" screen."), 10
                return false
            }
        }

        this.setTibiaClientID(clientID)
        oldClient := TibiaClientID

        WinGet, TibiaClientExeName, ProcessName, % "ahk_id " clientID
        ; m(TibiaClientExeName)
        exeName := OldbotSettings.settingsJsonObj.tibiaClient.clientExeName
        if (exeName != "" && exeName != "*")
                && (TibiaClientExeName != "")
                && (!InStr(TibiaClientExeName, exeName))
                && (CLIENT_FINDER_CLIENT != true) {
                TibiaClientID := oldClient
            string1 := (LANGUAGE = "PT-BR" ? "Use o executável correto do cliente" : "Use the correct client executable")
            string2 := (LANGUAGE = "PT-BR" ? "Cliente selecionado é" : "Selected client is")
            Msgbox, 48, % txt("Selecionar cliente - ", "Select client - ") this.getClientIdentifier(true), % string1 ": """ exeName """`n`n" string2 ": """ TibiaClientExeName """", 10
            return false
        }

        try this.getClientArea()
        catch e {
            this.setTibiaClientID(oldClient)
            Msgbox, 48,,% e.Message, 10
            return false
        }

        ; _NewBypass.onClientSelected() ; Removed for open-source release

        this.updateMenuClient()

        IniWrite, %TibiaClientID%, %DefaultProfile%, advanced, TibiaClientID
        if (oldClient != "") && (oldClient != TibiaClientID) {
            OldbotSettings.disableAllFunctions()
        }

        MemoryManager.injectClientMemory(forceStart := true)


        return true
    }

    setTibiaClientID(clientID)
    {
        TibiaClientID := clientID
    }

    openTibiaClient() {
        try this.clientFolderExists()
        catch
            return

        try {
            Run, % this.clientExePath
            return
        } catch e {
            Msgbox, 48,, % "Failed to open Tibia client:`n" this.clientExePath
        }
    }

    readTibiaClientIniSettings()
    {
        IniRead, clientListFilterName, %DefaultProfile%, selectclient_filters, clientListFilterName, %A_Space%
    }

    destroyButtonIconsTibiaClientGUI() {
        ; m(A_ThisFunc)
        Loop, % TibiaClientGUI_ICON_COUNTER {
            ; msgbox, % "a " TibiaClientGUI_ICONBUTTONS%A_Index%
            IL_Destroy(TibiaClientGUI_ICONBUTTONS%A_Index%)
            TibiaClientGUI_ICONBUTTONS%A_Index% := ""
            ; msgbox, % "b " TibiaClientGUI_ICONBUTTONS%A_Index%
        }

        TibiaClientGUI_ICON_COUNTER := 0
    }

    TibiaClientGUIButtonIcon(Handle, File, Index := 1, Options := "") {
        global
        RegExMatch(Options, "i)w\K\d+", W), (W="") ? W := 16 :
        RegExMatch(Options, "i)h\K\d+", H), (H="") ? H := 16 :
        RegExMatch(Options, "i)s\K\d+", S), S ? W := H := S :
        RegExMatch(Options, "i)l\K\d+", L), (L="") ? L := 0 :
        RegExMatch(Options, "i)t\K\d+", T), (T="") ? T := 0 :
        RegExMatch(Options, "i)r\K\d+", R), (R="") ? R := 0 :
        RegExMatch(Options, "i)b\K\d+", B), (B="") ? B := 0 :
        RegExMatch(Options, "i)a\K\d+", A), (A="") ? A := 4 :
        Psz := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"
        VarSetCapacity( button_il, 20 + Psz, 0 )
        NumPut( TibiaClientGUI_ICONBUTTONS%TibiaClientGUI_ICON_COUNTER% := DllCall( "ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1 ), button_il, 0, Ptr )   ; Width & Height
        NumPut( L, button_il, 0 + Psz, DW )     ; Left Margin
        NumPut( T, button_il, 4 + Psz, DW )     ; Top Margin
        NumPut( R, button_il, 8 + Psz, DW )     ; Right Margin
        NumPut( B, button_il, 12 + Psz, DW )    ; Bottom Margin
        NumPut( A, button_il, 16 + Psz, DW )    ; Alignment
        SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %Handle%
        IL_Add( TibiaClientGUI_ICONBUTTONS%TibiaClientGUI_ICON_COUNTER%, File, Index )
        TibiaClientGUI_ICON_COUNTER++
        ; msgbox, % TibiaClientGUI_ICON_COUNTER
        ; return IL_Add( TibiaClientGUI_ICONBUTTONS, File, Index )
        return
    }

    checkClientSelected()
    {
        if (!TibiaClientID) {
            this.selectFirstClient()

            if (!TibiaClientID) {
                throw Exception(LANGUAGE = "PT-BR" ? "Não há nenhum cliente do Tibia selecionado.`n`nClique no botão ""Select Client"" para selecionar." : "There is no Tibia client selected.`n`nClick on ""Select Client"" button to select.")
            }
        }

        string := (LANGUAGE = "PT-BR" ? "`n`nClique no botão ""Select Client"" para selecionar um novo cliente do Tibia." : "`n`nClick on ""Select Client"" button to select a new Tibia client.")
        if (this.isClientClosed() = true) {
            this.selectFirstClient()

            if (this.isClientClosed() = true) {
                throw Exception(LANGUAGE = "PT-BR" ? "Cliente selecionado(ID: " TibiaClientID "), não está aberto." string : "Selected client(ID: " TibiaClientID "), is not opened.`n`nClick on ""Select Client"" button to select a new client." string)
            }
        }
    }


    sanitizeClientName(clientName)
    {
        ; this.clientName := StrReplace(clientName, " ", "_")
        this.clientName := RTrim(LTrim(clientName))
        this.clientName := removeSpecialCharacters(this.clientName, "", " ")
    }

    clientNameIdentifier(clientName)
    {
        this.sanitizeClientName(clientName)

        if (StrLen(this.clientName) < 4) {
            throw Exception(txt("O nome deve ter no mínimo 3 caractéres.", "The name must have at least 3 characters."))
        }

        if (FileExist(OldBotSettings.JsonFolder "\memory\" this.clientName ".json")) {
            ; throw Exception(txt("Já existe configuração de memória com o nome """ this.clientName """, use outro nome tente novamente.", "There is already memory configuration with the name """ this.clientName """, use another name and try again."))
            msgbox, 52,, % txt("Já existe configuração de memória com o nome """ this.clientName """.`n`nDeseja sobrescrever?", "There is already memory configuration with the name """ this.clientName """`n`nDo you want to overwrite?")
            IfMsgBox, No
                return false
        }
        ; }

        ; if (!this.findClientMemory(true, true)) {
        ; 	return false
        ; }

        return true
    }

    addNewTibiaClient()
    {
        try {
            GuiControlGet, clientName
            if (!this.clientNameIdentifier(clientName)) {
                return
            }

            file := FileOpen(_Folders.JSON_MEMORY "\" clientName ".json", "w")
            try {
                file.Write("{""a"": [""0x0"", ""0x0"", ""0x0"", ""0x0""]}")
            } finally {
                file.Close()
            }

            fileName := "settings_" clientName ".json"
                new _SettingsJson().addNew(clientName, fileName)

            this.writeCurrentClientJson(fileName)
            Reload()
        } catch e {
            Msgbox, 48, , % e.Message, 10
            return
        }
    }
}
