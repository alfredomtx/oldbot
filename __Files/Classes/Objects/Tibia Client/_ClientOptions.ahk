/**
* @property object json
* @property array<string> allowedPresets
*/
class _ClientOptions extends _BaseClass
{
    static FILE := "clientoptions.json"

    static PRESET_KNIGHT := "Knight"
    static PRESET_PALADIN := "Paladin"
    static PRESET_DRUID := "Druid"
    static PRESET_SORCERER := "Sorcerer"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        classLoaded("TibiaClient", TibiaClient)

        if (empty(TibiaClient.clientDir)) {
            try {
                TibiaClient.listTibiaClientsGUI()
            } catch {
            }

            throw Exception(txt("É necessário setar o diretório da pasta do cliente do Tibia no botão """ TibiaClient.SET_CLIENT_DIR_BUTTON """ para carregar as configurações do cliente.", "It's necessary to set the Tibia Client directory in the """ TibiaClient.SET_CLIENT_DIR_BUTTON """ screen to load the client settings."))
        }

        baseDir := StrReplace(TibiaClient.clientDir, "\bin", "")
        _Validation.folderExists("baseDir", baseDir)

        this.clientOptionsJsonFile := baseDir "\conf\" this.FILE
        _Validation.fileExists("this.clientOptionsJsonFile", this.clientOptionsJsonFile)

        this.json := _Json.load(this.clientOptionsJsonFile)

        this.allowedPresets := {}
        this.allowedPresets.Push(this.PRESET_KNIGHT)
        this.allowedPresets.Push(this.PRESET_PALADIN)
        this.allowedPresets.Push(this.PRESET_DRUID)
        this.allowedPresets.Push(this.PRESET_SORCERER)

        this.readHotkeys()
    }

    open()
    {
        try {
            Run, % this.clientOptionsJsonFile
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            throw Exception(txt("Erro ao abrir o arquivo de configurações do cliente do Tibia: " this.clientOptionsJsonFile, "Error opening the Tibia client settings file: " this.clientOptionsJsonFile))
        }
    }

    /**
    * @param string value - item or spell name
    * @return ?_ActionBarButton
    */
    getHotkey(value)
    {
        ; if (!this.data.HasKey(value)) {
        ;     throw Exception(txt("Não há nenhuma hotkey configurada na Action Bar com """ value """.", "There are no hotkeys set in the Action Bar with """ value """."))
        ; }

        return this.data[value]
    }

    options()
    {
        this.options := this.json.options
        /*
        "autoChaseEnabled": true,
        "colorizeLootStyle": 2,
        "dragAndDropDefaultActionIsMoveAll": true,
        "gameWindowScaleOnlyByEvenMultiples": true,
        "optionsShowAdvanced": true,
        "rendererIndex": 5,

        */
    }

    /**
    * @return void
    * @throws
    */
    readHotkeys()
    {
        this.preset := this.json.hotkeyOptions.currentHotkeySetName

        if (!_Arr.search(this.allowedPresets, this.preset)) {
            presets := _Arr.concat(this.allowedPresets, ", ")

            throw Exception(txt("O preset atual de hotkeys selecionado no cliente do Tibia é  """ this.preset """.`n`nSelecione um dos presets abaixo pressionando a hotkey ""Ctrl + K"" no Tibia, RELOGUE o char e tente novamente.`n`n- Presets válidos: ", "The current hotkey preset selected in Tibia is """ this.preset """.`n`nSelectone of the presets below pressing the ""Ctrl + K"" hotkey in Tibia, RELOGIN the character and try again.`n`n- Válid presets: ") presets)
        }

        hotkeySets := this.json.hotkeyOptions.hotkeySets[this.preset]
        this.mappings := hotkeySets.actionBarOptions.mappings
        this.chatOffHotkeys := hotkeySets.chatOff

        this.loadHotkeys()
    }

    /**
    * @return void
    */
    loadHotkeys()
    {
        this.data := {}

        for _, option in this.mappings {
            for key, value in option.actionsetting {
                ; if (key != "chatText" && key != "useObject" && key != "Equip") {
                ;     continue
                ; }
                if (key = "useObject") {
                    item := this.getItemFromObjectId(value)
                    if (!item) {
                        continue
                    }

                    value := item
                }

                if (!value) {
                    continue
                }

                hotkey := ""
                for _, hotkeyOption in this.chatOffHotkeys {
                    needle := "TriggerActionButton_" option.actionBar "." option.actionButton
                    if (hotkeyOption.actionsetting.action = needle) {
                        hotkey := hotkeyOption.keysequence
                        break
                    }
                }

                if (empty(hotkey)) {
                    continue
                }

                this.data[value] := new _ActionBarButton(option.actionBar, option.actionButton, value, hotkey)
            }
        }
    }

    /**
    * @return ?string
    */
    getItemFromObjectId(id)
    {
        map := this.objectsMapping()
        return map[id]
    }

    /**
    * @return array<string>
    */
    objectsMapping()
    {
        static map
        if (map) {
            return map
        }

        map := {}
        /*
        health potions
        */
        map[266] := "health potion"
        map[236] := "strong health potion"
        map[239] := "great health potion"
        map[7643] := "ultimate health potion"
        map[23375] := "supreme health potion"
        /*
        mana potions
        */
        map[268] := "mana potion"
        map[237] := "strong mana potion"
        map[238] := "great mana potion"
        map[23373] := "ultimate mana potion"
        /*
        spirit potions
        */
        map[7642] := "great spirit potion"
        map[23374] := "ultimate spirit potion"

        /*
        food
        */
        map[3725] := "brown mushroom"

        return map
    }

    /**
    * @return ?_ActionBarButton
    * @throws
    */
    getHealthSpellHotkey(rule)
    {
        switch (this.preset) {
            case this.PRESET_KNIGHT:
                switch (rule) {
                    case "highest": 
                        return this.getHotkey("exura infir ico")
                    default:
                        return this.getHotkey("exura ico")
                }

                return this.getHotkey("exura ico")

            case this.PRESET_PALADIN:
                switch (rule) {
                    case "highest": 
                        return this.getHotkey("exura")
                    case "high": 
                        return this.getHotkey("exura gran")
                    case "mid": 
                        return this.getHotkey("exura san")
                    case "low": 
                        return this.getHotkey("exura gran san")
                }

            default:
                switch (rule) {
                    case "highest": 
                        return this.getHotkey("exura infir")
                    case "high": 
                        return this.getHotkey("exura")
                    case "mid": 
                        return this.getHotkey("exura gran")
                    case "low": 
                        return this.getHotkey("exura vita")
                }
        }

        throw exception("Invalid " this.preset " rule: " rule)
    }

    /**
    * @return string
    */
    getPreset()
    {
        return this.preset
    }

    /**
    * @return ?_ActionBarButton
    */
    getManaPotionHotkey()
    {
        potions := {}
        switch (this.preset) {
            case this.PRESET_KNIGHT:
            case this.PRESET_PALADIN:
                potions.push("great mana potion")
            default:
                potions.push("ultimate mana potion")
                potions.push("great mana potion")
        }

        potions.push("strong mana potion")
        potions.push("mana potion")

        return this.findItemHotkey(potions)
    }

    /**
    * @return ?_ActionBarButton
    */
    getFoodHotkey()
    {
        foods := {}
        foods.push("brown mushroom")

        return this.findItemHotkey(foods)
    }

    /**
    * @return ?_ActionBarButton
    */
    getHealthPotionHotkey()
    {
        potions := {}
        switch (this.preset) {
            case this.PRESET_KNIGHT:
                potions.push("supreme health potion")
                potions.push("supreme health potion")
                potions.push("ultimate health potion")
                potions.push("great health potion")
                potions.push("strong health potion")
                potions.push("health potion")
            case this.PRESET_PALADIN:
                potions.push("ultimate spirit potion")
                potions.push("great spirit potion")
        }

        return this.findItemHotkey(potions)
    }

    /**
    * @param array<string> itemList
    * @return ?_ActionBarButton
    */
    findItemHotkey(itemList)
    {
        for _, item in itemList {
            try {
                action := this.getHotkey(item)
                if (action) {
                    return action
                }
            } catch {
            }
        }
    }

    /**
    * @return ?_ActionBarButton
    */
    getHasteHotkey()
    {

    }
}