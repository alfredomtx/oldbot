
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\ClientSettings\_Tibia13ClientSetting.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\ClientSettings\_GraphicEngineSetting.ahk

Class _ClientSettings extends _BaseClass
{
    static settingsFolderImagePath := "Data\Files\Images\Others\CheckSettings"
    static SELECT_CATEGORY_DELAY := 150
    static SELECT_OPTION_DELAY := 75

    __New()
    {
        this.settingsFolderImagePath := "Data\Files\Images\Others\CheckSettings"

    }

    checkSettings(showMsg := true)
    {
        if (OldBotSettings.settingsJsonObj.others.ignoreCheckClientSettings = true) {
            return
        }

        if (isRubinot()) {
            try {
                return new _RubinotSettings().check(showMsg)
            } catch e {
                    new _Notification()
                    .title("Rubinot Settings error")
                    .message(e.Message)
                    .error()
                    .show()

                return
            }
        }

        if (isNotTibia13()) {
            return
        }

        if (TibiaClient.isClientClosed() = true) {
            Msgbox, 64,, % txt("O cliente do Tibia está fechado.", "Tibia client is closed."), 2
            return
        }

        if (isDisconnected()) {
            Msgbox, 64,, % txt("O char está desconectado.", "Character is disconnected."), 2
            return
        }

        if (!this.beforeCheckSettings()) {
            return
        }


        timerCheck := A_TickCount


        try {
                new _GraphicEngineSetting()
                .withProgress()
                .check(apply := true)

            this.createProgressGui()
        } catch e {
                new _Notification().title("Check settings")
                .message(e.Message)
                .timeout(4)
                .error()
                .show()

            this.showGraphicEngineError()

            if (e.What != "ShowGraphicEngineError") {
                _Logger.exception(e, A_ThisFunc, "_ClientSettingsArea")
            }
            return
        }


        /**
        right click on customisable status bar to check if it is default style
        */
        ; MouseClick("Right", WindowWidth / 2, 36)

        ; sleep, 200

        ; try {
        ;     _search := new _ImageSearch()
        ;         .setFile("customisable_status_bar_default_style")
        ;         .setFolder(this.settingsFolderImagePath)
        ;         .setArea(new _WindowArea())
        ;         .setClickOffsetX(20)
        ;         .setClickOffsetY(10)
        ;         .search()
        ;         .click("Left")
        ; } catch e {
        ;     msgbox, 48,, % e.Message
        ;     return
        ; }
        ; sleep, 100
        ; Send("Esc")

        configsToCheck := {}
        /**
        checkbox:
        - name: prefix name of the checkbox images %name%_checked/%name%_unchecked,
        dropdown:
        - name: image of the dropdown with the correct image selected
        - imageOnList: image of the correct option on the dropdown list to select


        configsToCheck["Controls"] := {}
        configsToCheck["Controls"]["main"] := {}
        configsToCheck["Controls"]["main"].Push(name: "press_ctrl_drag_stacks", type: "checkbox", value: "unchecked")
        configsToCheck["Controls"]["main"].Push(name: "classic_control", type: "dropdown", value: "classic control")
        configsToCheck["Controls"]["main"].Push(name: "quick_loot_hotkey", type: "dropdown", value: "quick_loot_hotkey")

        configsToCheck["Controls"]["children"] := {}
        configsToCheck["Controls"]["children"] := {}
        */



        this.count := 0
        configsToCheck["Interface"] := {}
        configsToCheck["Interface"]["main"] := {}
        ; configsToCheck["Interface"]["main"].Push({name: "highlight_mouse_target", type: "checkbox", value: "unchecked"})
        configsToCheck["Interface"]["main"].Push({name: "show_cooldown_bar", type: "checkbox", value: "checked"})
        this.count++
        configsToCheck["Interface"]["main"].Push({name: "colourise_loot_value", type: "dropdown"})
        this.count++
        ; configsToCheck["Interface"]["main"].Push({name: "use_native_mouse_cursor", type: "checkbox", value: "checked"})
        ; configsToCheck["Interface"]["main"].Push({name: "show_animated_mouse_cursor", type: "checkbox", value: "unchecked"})

        configsToCheck["Interface"]["children"] := {}
        configsToCheck["Interface"]["children"]["HUD"] := {}
        ; configsToCheck["Interface"]["children"]["HUD"].Push({name: "show_name_character", type: "checkbox", value: "unchecked", offsetX: 70})
        ; configsToCheck["Interface"]["children"]["HUD"].Push({name: "show_name_creature", type: "checkbox", value: "unchecked", offsetX: 63})
        if (!isTibia14()) {
            configsToCheck["Interface"]["children"]["HUD"].Push({name: "show_health_creature", type: "checkbox", value: "checked", offsetX: 65})
            this.count++
        }


        ; configsToCheck["Interface"]["children"]["HUD"].Push({name: "hud_life", type: "dropdown"})
        configsToCheck["Interface"]["children"]["HUD"].Push({name: "show_status_bar", type: "checkbox", value: "checked"})
        this.count++
        configsToCheck["Interface"]["children"]["HUD"].Push({name: "show_bars", type: "checkbox", value: "unchecked"})
        this.count++
        configsToCheck["Interface"]["children"]["HUD"].Push({name: "show_arcs", type: "checkbox", value: "checked"})
        this.count++
        configsToCheck["Interface"]["children"]["HUD"].Push({name: "show_custom_status_bar", type: "checkbox", value: "unchecked"})
        this.count++

        configsToCheck["Interface"]["children"]["Game Window"] := {}
        configsToCheck["Interface"]["children"]["Game Window"] := {}
        ; configsToCheck["Interface"]["children"]["Game Window"].Push({name: "show_textual_effects", type: "checkbox", value: "unchecked"})
        configsToCheck["Interface"]["children"]["Game Window"].Push({name: "show_messages", type: "checkbox", value: "checked"})
        this.count++
        ; configsToCheck["Interface"]["children"]["Game Window"].Push({name: "show_potion_sound_effects", type: "checkbox", value: "unchecked"})
        ; configsToCheck["Interface"]["children"]["Game Window"].Push({name: "show_spells", type: "checkbox", value: "unchecked"})
        ; configsToCheck["Interface"]["children"]["Game Window"].Push({name: "show_spells_of_others", type: "checkbox", value: "unchecked"})
        ; configsToCheck["Interface"]["children"]["Game Window"].Push({name: "show_hotkey_usage_notification", type: "checkbox", value: "unchecked"})
        ; configsToCheck["Interface"]["children"]["Game Window"].Push({name: "show_loot_messages", type: "checkbox", value: "unchecked"})
        configsToCheck["Interface"]["children"]["Game Window"].Push({name: "show_combat_frames", type: "checkbox", value: "checked"})
        this.count++
        ; configsToCheck["Interface"]["children"]["Game Window"].Push({name: "scale_integral_multiples", type: "checkbox", value: "checked"})

        configsToCheck["Interface"]["children"]["Action Bars"] := {}
        configsToCheck["Interface"]["children"]["Action Bars"] := {}
        configsToCheck["Interface"]["children"]["Action Bars"].Push({name: "show_cooldown_seconds", type: "checkbox", value: "unchecked"})
        this.count++
        configsToCheck["Interface"]["children"]["Action Bars"].Push({name: "show_graphical_cooldown", type: "checkbox", value: "unchecked"})
        this.count++
        ; configsToCheck["Interface"]["children"]["Action Bars"].Push({name: "show_action_bar1", type: "checkbox", value: "checked"})
        ; configsToCheck["Interface"]["children"]["Action Bars"].Push({name: "show_action_bar2", type: "checkbox", value: "checked"})

        configsToCheck["XControls"] := {}
        configsToCheck["XControls"]["main"] := {}
        configsToCheck["XControls"]["main"].Push({name: "press_ctrl_drag", type: "checkbox", value: "unchecked"})
        this.count++
        configsToCheck["XControls"]["main"].Push({name: "classic_control", type: "dropdown"})
        this.count++
        configsToCheck["XControls"]["main"].Push({name: "quick_loot", type: "dropdown"})
        this.count++
        ; msgbox, % serialize(configsToCheck)

        configsToCheck["Graphics"] := {}
        configsToCheck["Graphics"]["main"] := {}
        ; configsToCheck["Graphics"]["main"].Push({name: "frameratelimit", type: "checkbox", value: "unchecked"})
        if (!isTibia14()) {
            configsToCheck["Graphics"]["main"].Push({name: "graphics_engine", type: "dropdown"})
            this.count++
        }
        configsToCheck["Graphics"]["main"].Push({name: "antialiasing", type: "dropdown"})
        this.count++
        configsToCheck["Graphics"]["children"] := {}
        configsToCheck["Graphics"]["children"]["Effects"] := {}
        configsToCheck["Graphics"]["children"]["Effects"].Push({name: "show_light_effects", type: "checkbox", value: "unchecked", offsetX: 4})
        this.count++

        configsToCheck["Misc"] := {}
        configsToCheck["Misc"]["main"] := {}
        configsToCheck["Misc"]["children"] := {}
        configsToCheck["Misc"]["children"]["Gameplay"] := {}
        configsToCheck["Misc"]["children"]["Gameplay"].Push({name: "auto_chaseoff", type: "checkbox", value: "unchecked"})
        this.count++
        ; configsToCheck["Misc"]["children"]["Gameplay"].Push({name: "quick_loot_all_corpses", type: "checkbox", value: "checked"})
        ; configsToCheck["Misc"]["children"]["Screenshots"] := {}
        ; configsToCheck["Misc"]["children"]["Screenshots"].Push({name: "only_capture_game_window", type: "checkbox", value: "unchecked"})
        this.currentCount := 0

        this.count++ ; for _ClientSettingsArea
        this.count++ ; for battle list adjust
        this.gui.updateProgress(this.currentCount, this.count)

        if (!this.openSettingsAndGetArea()) {
            this.gui.close()
            return
        }

        this.gui.updateProgress(this.currentCount++, this.count)

        Loop, 2 {
            Send("Esc")
            Sleep, 75
        }

        this.battleListOrderChange()
        this.gui.updateProgress(this.currentCount++, this.count)

        this.openSettingsWithHoktey()

        try {
            this.selectShowAdvancedOptions()
        } catch e {
            this.gui.close()
            this.showGraphicEngineError()

            if (e.What != "ShowGraphicEngineError") {
                _Logger.exception(e, A_ThisFunc, "_ClientSettingsArea")
            }

            return
        }

        this.gui.updateProgress(this.currentCount++, this.count)

        if (this.checkCategorySettings("Graphics", configsToCheck["Graphics"], debug := false) = false) {
            this.gui.close()
            msgbox_image("An error occured while checking the Graphics settings." defaultEngineText, ImagesConfig.GUIfolder "\Others\graphic_engine_opengl.png", rows := 4)
            return
        }

        try {
            for category, categoryOptions in configsToCheck
            {
                if (category = "Graphics") {
                    continue
                }
                this.checkCategorySettings(category, categoryOptions)
            }

            try {
                this.applySettings()
            } catch e {
                this.gui.close()
                Msgbox, 16,, % e.Message, 4
            }
        } catch e {
            msgbox, 16,, % e.Message "`n" e.What
            return
        }

        StringTrimRight, Now, A_Now, 6
        IniWrite, %Now%, %A_Temp%\OldBot\oldbot.ini, settings, LastSettingCheck

        this.gui.close()
        if (showMsg = true)
            msgbox, 64,, % "Done.`n`nElapsed: " (A_TickCount - timerCheck) / 1000 " seconds.", 2
    }

    selectShowAdvancedOptions()
    {
        try {
            c1 := new _ClientSettingsArea().getC1()
                .subX(5)
                .addY(455)
            c2 := c1.CLONE()
                .addX(200)
                .addY(35)
            coordinates := new _Coordinates(c1, c2)

            if (this.checkboxOption({name: "show_advanced_options", type: "checkbox", value: "checked"}, coordinates, debug := false) = false) {
                Sleep, 100
                if (this.checkboxOption({name: "show_advanced_options", type: "checkbox", value: "checked"}, coordinates) = false) {
                    if (clientIdentifier() != "Rubinot") {
                        throw Exception("Failed to select show_advanced_options")
                    }
                }
            }
        } catch e {
            throw Exception(e.Message, "ShowGraphicEngineError")
        }
    }

    updateProgress(current, total)
    {
        this.gui.updateProgress(current, total)
    }

    createProgressGui(text := "")
    {
        try {
            this.gui := new _ProgressGUI(txt("Configurações do cliente", "Client settings"))
                .text(text ? text : txt("Checando configurações... (Alt+R para abortar)", "Checking settings... (Alt+R to abort)"))
                .open()
        } catch e {
            this.gui.close()
            throw e
        }
    }

    closeProgressGui()
    {
        this.gui.close()
    }

    applySettings()
    {
        _search := new _ImageSearch()
            .setFile("apply_button")
            .setFolder(this.settingsFolderImagePath)
            .setVariation(50)
            .setArea(new _ClientSettingsArea())
            .setClickOffsets(4)
            .search()
            .click()

        if (_search.notFound()) {
            throw Exception(txt("Falha ao clicar no botão ""Aplicar"", clique manualmente e tente novamente.", "Failed to click on ""Apply"" button, click on it manually and try again."))
        }

        Sleep, 300
        _search := new _SearchOkButton()
            .click()
    }

    beforeCheckSettings()
    {
        if (isDisconnected()) {
            MsgBox, 64,, % "O personagem precisa estar logado no jogo para checar também algumas configurações ingame.", "The character needs to be logged in the game to also check some ingame settings."
            return false
        }

        try TibiaClient.checkClientSelected()
        catch e {
            MsgBox, 64,, % e.Message
            return false
        }

        if (WindowWidth = "" OR WindowHeight = "") {
            TibiaClient.getClientArea()
            if (TibiaClient.isClientClosed(false) = true)
                return false
        }

        OldBotSettings.enableGuisLoading()

        if (backgroundMouseInput = false OR backgroundKeyboardInput = false)
            WinActivate()

        OldBotSettings.disableAllFunctions()

        return true
    }

    openSettingsWithHoktey()
    {
        Loop, 2 {
            Send("Esc")
            Sleep, 50
        }

        Loop, 3 {
            SendModifier("Ctrl", "K")
            Sleep, 75
        }

        Sleep, 200
    }

    openSettingsAndGetArea()
    {
        this.openSettingsWithHoktey()

        try {
                new _ClientSettingsArea().getC1()
        } catch e {
            _Logger.exception(e, A_ThisFunc, "_ClientSettingsArea")
            this.showGraphicEngineError()
            return false
        }

        return true
    }

    battleListOrderChange()
    {
        try {
            ActionScript.battlelistchangeorder("", {1: 3}, false)
        } catch e {
            _Logger.msgboxException(48, e)
        }

        Sleep, 75
        Send("Esc")
        Sleep, 100
    }

    showGraphicEngineError()
    {
        defaultEngineText := txt("`n`nCertifique-de que a configuração em Graphics > Graphics Engine está em ""OpenGL"" e reabra o cliente do Tibia.", "`n`nCheck in Tibia settings if the Graphics > Graphics Engine is on ""OpenGL"" and reopen the Tibia Client.")

        this.gui.close()
        msgbox_image(txt("Não foi possível encontrar a opção ""Show advanced options"" nas configurações do cliente.", "Failed to find ""Show advanced options"" in Tibia Client Settings.") defaultEngineText, ImagesConfig.GUIfolder "\Others\graphic_engine_opengl.png", rows := 4)
    }

    checkCategorySettings(category, categoryOptions, debug := false)
    {
        if (this.selectCategory(category, debug) = false) {
            msgbox, 48,, % "Error selecting category: " category ".`n`nAborting check.", 4
            return false
        }

        for categoryType, categoryMainAndChildren in categoryOptions
        {
            ; msgbox, % category "`n`n" categoryType  "`n`n" serialize(categoryMainAndChildren)
            switch categoryType {
                case "main":

                    if (this.selectCategory(category) = false) {
                        msgbox, 48,, % txt("Falha ao selecionar o menu: " category ".", "Failed to select menu: " category ".")
                        return false
                        ; continue
                    }

                    for _, mainOption in categoryMainAndChildren
                    {
                        switch mainOption.type {
                            case "checkbox":
                                if (!this.checkboxOption(mainOption, "", debug := false) = true) {
                                    msgbox, 48,, % txt("Falha ao selecionar a opção: " mainOption.name ".`n`nSelecione manualmente e realize a checagem das configurações novamente.", "Failed to select option: " mainOption.name ".`n`nSelect it manually and check settings again.")
                                    ; return false
                                }
                            case "dropdown":
                                if (!this.dropdownOption(mainOption.name, mainOption.type)) {
                                    msgbox, 48,, % txt("Falha ao selecionar a opção: " mainOption.name ".`n`nSelecione manualmente e realize a checagem das configurações novamente.", "Failed to select option: " mainOption.name ".`n`nSelect it manually and check settings again.")
                                    ; return false
                                }
                        }
                        this.gui.updateProgress(this.currentCount++, this.count)
                    }
                case "children":
                    ; msgbox, % categoryType "`n`n" categoryChildren  "`n`n" serialize(categoryChildrenOption)
                    for categoryChildren, categoryChildrenOption in categoryMainAndChildren
                    {
                        ; msgbox, % categoryType "`n`n" categoryChildren "`n`n" serialize(categoryChildrenOption)
                        if (this.selectCategory(categoryChildren) = false) {
                            msgbox, 48,, % "Failed to select sub menu: " categoryChildren ".`n`nSelect it manually and check settings again.", 4
                            return false
                        }
                        for _, childrenOption in categoryChildrenOption
                        {
                            switch childrenOption.type {
                                case "checkbox":
                                    if (!this.checkboxOption(childrenOption, "", debug := false)) {
                                        this.checkboxOption(childrenOption, "", false)
                                        msgbox, 64,, % txt("Falha ao selecionar a opção: " childrenOption.name ".`n`nSelecione manualmente e realize a checagem das configurações novamente.", "Failed to select option: " childrenOption.name ".`n`nSelect it manually and check settings again."), 8
                                        ; return false
                                    }
                                case "dropdown":
                                    if (!this.dropdownOption(childrenOption.name, childrenOption.type)) {
                                        msgbox, 64,, % txt("Falha ao selecionar a opção: " childrenOption.name ".`n`nSelecione manualmente e realize a checagem das configurações novamente.", "Failed to select option: " childrenOption.name ".`n`nSelect it manually and check settings again."), 8
                                        ; return false
                                    }
                            }
                            this.gui.updateProgress(this.currentCount++, this.count)
                        }
                    }
            } ; switch
        }
        return true

    }

    selectCategory(category, debug := false)
    {
        static area
        if (!area) {
            area := new _ClientSettingsMenuArea()
        }

        Loop, % this.settingsFolderImagePath "\menu" "\" StrReplace(category, " ", "_") "*" {
            _search := new _ImageSearch()
                .setPath(A_LoopFileFullPath)
                .setVariation(75)
                .setArea(area)
                .setClickOffsetX(4)
                .setClickOffsetY(2)
                .setDebug(debug)
                .search()
                .click()

            if (_search.found()) {
                break
            }
        }

        if (_search.notFound()) {
            return false
        }

        Sleep, % this.SELECT_CATEGORY_DELAY

        return true
    }

    checkboxOption(mainOption, coordinates := "", debug := false)
    {
        static area
        if (!area) {
            area := new _ClientSettingsControlsArea()
        }

        /**
        search the image of the correct checkbox, if not found search for the opposite checkbox state image,
        if oposite is found, click and then search for the correct checkbox state again
        */

        folderPath :=  this.settingsFolderImagePath "\" mainOption.type
        Loop, % folderPath "\" mainOption.name "_" mainOption.value "*" {
            variation := 75
            _search := new _ImageSearch()
                .setPath(A_LoopFileFullPath)
                .setVariation(variation)
                .setDebug(debug)

            if (coordinates) {
                _search.setCoordinates(coordinates)
            }else {
                _search.setArea(area)
            }

            _search.search()

            if (_search.found()) {
                break
            }
        }

        wrongValue := mainOption.value = "checked" ? "unchecked" : "checked"
        Loop, % folderPath "\" mainOption.name "_" wrongValue  "*" {
            _search := new _ImageSearch()
                .setPath(A_LoopFileFullPath)
                .setVariation(variation)
                .setClickOffsetX(mainOption.offsetX ? mainOption.offsetX : 4)
                .setClickOffsetY(4)
                .setDebug(debug)

            if (coordinates) {
                _search.setCoordinates(coordinates)
            }else {
                _search.setArea(area)
            }

            _search.search()
                .click()
            if (_search.found()) {
                Sleep, 250
                break
            }
        }

        Sleep, % this.SELECT_OPTION_DELAY

        Loop, % folderPath "\" mainOption.name "_" mainOption.value "*" {
            _search := new _ImageSearch()
                .setPath(A_LoopFileFullPath)
                .setVariation(variation)
                .setDebug(debug)

            if (coordinates) {
                _search.setCoordinates(coordinates)
            }else {
                _search.setArea(area)
            }

            _search.search()

            if (_search.found()) {
                return true
            }
        }

        Sleep, % this.SELECT_OPTION_DELAY

        return false
    }

    dropdownOption(name, type)
    {
        static area
        if (!area) {
            area := new _ClientSettingsArea()
        }

        folderPath :=  this.settingsFolderImagePath "\" type

        mainImageSearch := new _ImageSearch()
            .setFile(name)
            .setFolder(folderPath)
            .setArea(area)
            .setVariation(70)
            .search()

        if (mainImageSearch.found()) {
            return true
        }

        Loop, % folderPath "\" name "_text" "*" {
            filePath := A_LoopFileFullPath
            _search := new _ImageSearch()
                .setPath(filePath)
                .setVariation(70)
                .setDebug(debug)
                .setArea(area)
                .search()

            if (_search.found()) {
                break
            }
        }

        if (_search.notFound()) {
            return true
        }

        image := new _BitmapImage(filePath)

        _search.setClickOffsetX(image.getW() + 20)
            .setClickOffsetY(image.getH() / 2)
            .click(button := "Left", repeat := 1, delay := "", debug := false)

        Sleep, 250

        keyPresses := {}
        switch (name) {
            case "graphics_engine":
                if (isTibia14()) {
                    keyPresses.Push({"down": 5})
                } else {
                    keyPresses.Push({"up": 5})
                    keyPresses.Push({"down": 2})
                }
            case "antialiasing":
                keyPresses.Push({"up": 3})
                keyPresses.Push({"down": 1})
            case "colourise_loot_value":
                keyPresses.Push({"down": 3})
            case "classic_control":
                keyPresses.Push({"up": 3})
            case "quick_loot":
                keyPresses.Push({"up": 3})
                keyPresses.Push({"down": 1})
        }

        if (keyPresses.Count() < 1) {
            throw Exception("no key presses: " name)
        }

        for _, keys in keyPresses
        {
            for key, presses in keys
            {
                Loop, % presses {
                    Send(key)
                    Sleep, 100
                }
            }
        }

        Send("Enter")
        Sleep, 200

        return mainImageSearch
        ; .debug()
            .search()
            .found()
    }

    checkSettingsRoutine()
    {
        if (ignoreCheckClientSettings = 1)
            return
        if (!new _InterfaceIniSettings().get("autoCheckClientSettings"))
            return


        if (WINDOWS_VERSION = "7" OR A_OSVersion = "WIN_8.1")
            return


        if (!A_IsCompiled)
            return
        StringTrimRight, Now, A_Now, 6

        IniRead, LastSettingCheck, %A_Temp%\OldBot\oldbot.ini, settings, LastSettingCheck, %A_Space%

        DaysSinceLastSettingCheck := abs(LastSettingCheck - Now)
        ; DaysSinceLastSettingCheck := 1 ; dont do auto update for now

        if (DaysSinceLastSettingCheck >= 5 OR LastSettingCheck = "") {

            if (TibiaClient.isClientClosed() = true)
                return

            TibiaClient.getClientArea()

            if (isDisconnected())
                return

            this.checkSettings(false)

        }
    }
}