
Class _HotkeysHandler
{
    __New()
    {
        global

        this.hotkeyScreenshotFolder := "Data\Screenshots\Hotkeys"


        if (!FileExist(this.hotkeyScreenshotFolder))
            FileCreateDir, % this.hotkeyScreenshotFolder


        this.hotkeyList := {}

        this.hotkeyList.Push("Action Script")
        this.hotkeyList.Push("Click on item")
        this.hotkeyList.Push("Click on image")
        this.hotkeyList.Push("Drag character position to mouse")
        this.hotkeyList.Push("Drag mouse to item")
        this.hotkeyList.Push("Drag mouse to image")
        this.hotkeyList.Push("Drag mouse to position")
        this.hotkeyList.Push("Drag mouse to backpack position")
        this.hotkeyList.Push("Drag mouse to character position")
        this.hotkeyList.Push("Drag position to character position")
        this.hotkeyList.Push("Drag position to item")
        this.hotkeyList.Push("Drag position to mouse")
        this.hotkeyList.Push("Drag position to position")

        this.hotkeyList.Push("Drag item to mouse")
        this.hotkeyList.Push("Drag item to position")
        this.hotkeyList.Push("Drag item to character position")

        this.hotkeyList.Push("Drag image to mouse")
        this.hotkeyList.Push("Drag image to position")
        this.hotkeyList.Push("Drag image to character position")

        if (!uncompatibleModule("looting")) {
            this.hotkeyList.Push("Loot around (quick looting)")
            this.hotkeyList.Push("Loot around (opening corpses)")
            this.hotkeyList.Push("Loot items (manual looting)")
        }

        this.hotkeyList.Push("Shoot rune on target (battle list)")
        ; this.hotkeyList.Push("Use healing Life Potion")
        ; this.hotkeyList.Push("Use healing Mana Potion")
        this.hotkeyList.Push("Use item on character")
        this.hotkeyList.Push("Use item on follow target")
        this.hotkeyList.Push("Use item on mouse position")

        this.hotkeyOptions := {}
        this.hotkeyOptions.Push("action")
        this.hotkeyOptions.Push("enabled")
        this.hotkeyOptions.Push("hotkey")
        ; this.hotkeyOptions.Push("userValue")
        this.hotkeyOptions.Push("comment")

        this.allowedHotkeys := {}
        this.allowedHotkeys.Push("Mouse Scroll Button")
        this.allowedHotkeys.Push("Mouse Back Button")
        this.allowedHotkeys.Push("Mouse Forward Button")
        this.allowedHotkeys.Push("Delete")
        this.allowedHotkeys.Push("End")
        this.allowedHotkeys.Push("Home")
        this.allowedHotkeys.Push("Insert")
        this.allowedHotkeys.Push("PauseBreak")
        this.allowedHotkeys.Push("Page Down")
        this.allowedHotkeys.Push("Page Up")
        this.allowedHotkeys.Push("Tab")

        Loop, 12 
            this.allowedHotkeys.Push("F" A_Index)

        Loop, 10
            this.allowedHotkeys.Push(A_Index - 1)

        /**
        Numpad
        */
        this.allowedHotkeys.Push("Numpad /")
        this.allowedHotkeys.Push("Numpad *")
        this.allowedHotkeys.Push("Numpad +")
        this.allowedHotkeys.Push("Numpad -")
        Loop, 10
            this.allowedHotkeys.Push("Numpad" A_Index - 1)


        this.allowedHotkeys.Push("'")
        this.allowedHotkeys.Push("-")
        this.allowedHotkeys.Push("=")
        this.allowedHotkeys.Push("[")
        this.allowedHotkeys.Push("]")
        this.allowedHotkeys.Push(".")
        this.allowedHotkeys.Push(",")
        this.allowedHotkeys.Push(";")



        this.allowedHotkeysList := ""
        for key, value in this.allowedHotkeys
            this.allowedHotkeysList .= value "|"

        this.loadHotkeysSettings()

    }

    loadHotkeysSettings() {
        global

        this.checkDefaultHotkeysSettings()

    }

    checkDefaultHotkeysSettings() {

        /**
        Add by default all Hotkeys if there is none
        */
        if (hotkeysObj.Count() < 1)
            this.addDefaultHotkeys()

        for hotkeyID, atributes in hotkeysObj
        {
            hotkeysObj[hotkeyID].enabled := (hotkeysObj[hotkeyID].enabled = "" && hotkeysObj[hotkeyID].enabled != false) ? false : hotkeysObj[hotkeyID].enabled
            hotkeysObj[hotkeyID].action := (hotkeysObj[hotkeyID].action = A_Space) ? "" : hotkeysObj[hotkeyID].action
        }
    }

    addDefaultHotkeys() {
        for key, hotkeyName in this.hotkeyList
        {
            hotkeysObj[A_Index] := {}
            this.setDefaultHotkeyActionValues(A_Index, hotkeyName, fromInitialCheck := true)
            ; m(serialize(hotkeysObj))
        }
    }

    saveHotkeys(saveCavebotScript := true) {
        scriptFile.hotkeys := hotkeysObj
        if (saveCavebotScript = true)
            CavebotScript.saveSettings(A_ThisFunc)
    }

    enableHotkey() {
        GuiControl, CavebotGUI:, hotkeyEnabled, % HotkeysGUI.disabledText
        GuiControl, CavebotGUI:, hotkeyEnabled, 1
    }

    disableHotkey() {
        GuiControl, CavebotGUI:, hotkeyEnabled, % HotkeysGUI.enabledText
        GuiControl, CavebotGUI:, hotkeyEnabled, 0
    }

    checkBeforeEnablingHotkeys(hotkeyID := "") {
        if (hotkeyID != "") {
            if (hotkeysObj[hotkeyID].enabled = 0)
                return
        }
        try TibiaClient.checkClientSelected()
        catch e {
            throw Exception(e.Message, 2)
        }
    }

    changeHotkeyEnabled(hotkeyID, save := false) {
        if (hotkeyID = "") {
            if (!A_IsCompiled) {
                Msgbox, 48, % A_ThisFunc, % "hotkeyID = " hotkeyID
            }
        }
        if (hotkeysObj[hotkeyID].enabled = 1) && (CheckClientMC() = false) {
            hotkeysObj[hotkeyID].enabled := 0
            save := true
        }
        if (hotkeysObj[hotkeyID].enabled = 1) {
            this.enableHotkey()
        } else {
            this.disableHotkey()
            ; if (this.hasHotkeysEnabled() = false)
            ; ProcessExistClose(hotkeysExeName, "hotkeysExeName")
        }
        if (save = true)
            this.saveHotkeys(saveCavebotScript := true)


        HotkeysGUI.updateHotkeyRow(hotkeyID, A_ThisFunc)
        if (hotkeysObj[hotkeyID].enabled = 1) {
            _HotkeysExe.start()
        }
    }

    hasHotkeysEnabled() {
        for hotkeyID, hotkey in hotkeysObj
        {
            if (hotkeysObj[hotkeyID].enabled = true)
                return true
        }
        return false
    }

    checkDeleteButton() {
        GuiControl, % "CavebotGUI:" (hotkeysObj.Count() > 0 ? "Enable" : "Disable"), deleteHotkeysButton
    }

    editHotkeyActionScript() {
        Gui, CavebotGUI:Default
        Gui, ListView, LV_HotkeysList
        hotkeyID := _ListviewHandler.getSelectedItemOnLV("LV_HotkeysList", column := 1, defaultGUI := "CavebotGUI", returnRow := false)
        if (hotkeyID = "" OR hotkeyID = "ID")
            return

            new _ActionScriptGUI("Hotkey", hotkeyID, hotkeysObj[hotkeyID].actionScript).open()
    }

    deleteHotkey() {
        Gui, CavebotGUI:Default
        Gui, ListView, LV_HotkeysList
        hotkeyID := _ListviewHandler.getSelectedItemOnLV("LV_HotkeysList", column := 1, defaultGUI := "CavebotGUI", returnRow := false)
        if (hotkeyID = "" OR hotkeyID = "ID")
            return

        GetKeyState, CtrlPressed, Ctrl, D
        if (CtrlPressed != "D") {
            Msgbox, 52,, % "Delete hotkey " hotkeyID " (" HotkeysGUI.rowAction(hotkeyID) ")?"
            IfMsgBox, No
                return
        }
        try hotkeysObj.RemoveAt(hotkeyID)
        catch {
        }

        HotkeysGUI.loadHotkeysListLV()

        if (hotkeysObj.Count() > 1) {
            row := hotkeyID - 1
            _ListviewHandler.selectRow("LV_HotkeysList", row)
        }
        if (hotkeysObj.Count() > 0) {
            try {
                HotkeysGUI.loadHotkeysGuiElements(row)
            } catch {
            }
        }
        this.checkDeleteButton()

        this.saveHotkeys()
    }


    addNewHotkey() {

        hotkeysObj.Push({"action": "", "hotkey": ""})

        HotkeysGUI.loadHotkeysListLV()

        hotkeyID := hotkeysObj.Count()
        _ListviewHandler.selectRow("LV_HotkeysList", hotkeyID)
        HotkeysGUI.loadHotkeysGuiElements(hotkeyID)
        this.checkDeleteButton()

        this.saveHotkeys()
    }

    saveHotkeysOptions() {
        Gui, CavebotGUI:Default
        Gui, CavebotGUI:Submit, NoHide
        GuiControlGet, hotkeyID

        if (hotkeyID = "")
            throw Exception("No hotkey selected.")

        for key, control in HotkeysGUI.controls
        {
            try GuiControlGet, %control%
            catch {
            }
        }


        if (hotkeyHotkey != A_Space) {
            if (this.isValidHotkey(hotkeyHotkey) = false)
                throw Exception("Invalid hotkey: " hotkeyHotkey)
        }

        /**
        if (hotkeyHealPercent < 5 OR hotkeyHealPercent > 99)
        throw Exception("Invalid percentage value for Player HP %, min: 5, max: 99.")
        */

        ; msgbox, % "before " serialize(hotkeysObj)

        for key, option in this.hotkeyOptions
        {
            if (option = "userValue")
                continue
            value := hotkey%option%
            ; if value is Number
            ; value += 0
            hotkeysObj[hotkeyID][option] := value
        }

        hotkeysObj[hotkeyID].action := (hotkeysObj[hotkeyID].action = A_Space) ? "" : hotkeysObj[hotkeyID].action

        hotkeysObj[hotkeyID].interval := hotkeyinterval += 0

        switch hotkeysObj[hotkeyID].enabled {
            case 1:
            case 0:
        }

        HotkeysGUI.updateHotkeyRow(hotkeyID)
        HotkeysGUI.resizeColumns()

        this.saveHotkeys(saveCavebotScript := true)
    }

    saveHotkeysUserValue() {

        Gui, EditHotkeysUserValueGUI:Default
        Gui, EditHotkeysUserValueGUI:Submit, NoHide
        Gui, EditHotkeysUserValueGUI:Destroy

        /**
        validation first
        */
        Loop, 10 {
            key := hotkeyUserKey%A_Index%
            value := hotkeyUserValue%A_Index%
            if (key = "")
                continue

            switch hotkeysObj[hotkeyID].action {
                case "Press hotkey":
                case "Click on image":
                    if (key = "button") && (value != "Left" && value != "Right")
                        throw Exception(" ""button"" value must be ""Left"" or ""Right"".")

            }

            if (key = "image") && (!scriptImagesObj[value]) {
                if (value = "")
                    throw Exception("Empty ""image"" value.", "Save User Value")

                CavebotGUI.createScriptImagesGUI()
                throw Exception("Image """ value """ doesn't exist in the Script Images list.", "Save User Value")
            }

            if (key = "hotkey") {
                try HealingHandler.validateHealingHotkey("", value)
                catch e 
                    throw e
            }
        }

        hotkeysObj[hotkeyID]["userValue"] := {}
        Loop, 10 {
            if (hotkeyUserKey%A_Index% = "")
                continue

            key := removeSpecialCharacters(hotkeyUserKey%A_Index%, TelegramAPI.characterExceptions), value := removeSpecialCharacters(hotkeyUserValue%A_Index%, TelegramAPI.characterExceptions)
            ; msgbox, % key " = " value

            hotkeysObj[hotkeyID]["userValue"].Push(Object(key, value))
        }

        ; msgbox, % serialize(hotkeysObj[hotkeyID].userValue)
        ; hotkeysObj[hotkeyID].userValue := alertUserValue

        HotkeysGUI.updateHotkeyRow(hotkeyID)
        HotkeysGUI.resizeColumns()

        HotkeysHandler.saveHotkeys(saveCavebotScript := true)
    }

    countScreenshotsHotkeysFolder() {
        count := 0
        loop, % this.hotkeyScreenshotFolder "\*.png"{
            count++
        }
        return count
    }

    setDefaultHotkeyActionValues(hotkeyID, action, fromInitialCheck := false) {
        if (hotkeyID = "")
            return
        ; throw Exception("No hotkey selected.")


        if (fromInitialCheck = true) && (hotkeysObj[hotkeyID].action != "" && hotkeysObj[hotkeyID].action != "none")
            return

        ; msgbox, % hotkeyID "`n" action "`n" serialize(hotkeysObj[hotkeyID])
        hotkeysObj[hotkeyID].action := action
        hotkeysObj[hotkeyID].userValue := {}

        /**
        Copy to clipboard the previous contents as a backup before changing to the default comments
        */
        if (hotkeysObj[hotkeyID].comment != "") {
            try Clipboard := hotkeysObj[hotkeyID].comment
            catch {
            }
        }

        hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "" : ""

        switch action {
            case "Action Script":
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Executa a Action Script (experimental)." : "Run the Action Script (experimental)."
                hotkeysObj[hotkeyID].userValue.Push({"showTooltip": "true"})

            case "Click on item":
                hotkeysObj[hotkeyID].userValue.Push({"button": "Right"})
                hotkeysObj[hotkeyID].userValue.Push({"item": ""})
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Clica no item." : "Click on the item."
            case "Click on image":
                hotkeysObj[hotkeyID].userValue.Push({"button": "Right"})
                hotkeysObj[hotkeyID].userValue.Push({"image": ""})
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Clica na imagem(Script Image)." : "Click on the image(Script Image)."
            case "Drag character position to mouse":
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse da posição do char(sqm do centro) até a posição atual do mouse." : "Drag the mouse from the character position(center sqm) to the current mouse position."
            case "Drag mouse to item":
                hotkeysObj[hotkeyID].userValue.Push({"item": ""})
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse da posição atual até a posição do item." : "Drag the mouse from the current position to the item position."
            case "Drag mouse to image":
                hotkeysObj[hotkeyID].userValue.Push({"image": ""})
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse da posição atual até a posição da imagem" : "Drag the mouse from the current position to the image position."
            case "Drag item to mouse":
                hotkeysObj[hotkeyID].userValue.Push({"item": ""})
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse da posição do item até a posição atual do mouse" : "Drag the mouse from the item position to the current mouse position."
            case "Drag image to mouse":
                hotkeysObj[hotkeyID].userValue.Push({"image": ""})
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse da posição da imagem até a posição atual do mouse." : "Drag the mouse from the image position to the current mouse position."
            case "Drag mouse to backpack position":
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "true"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse da posição atual até a posição da backpack(definida em Game Areas)." : "Drag the mouse from the current position to the backpack position(set in Game Areas)."
            case "Drag mouse to character position":
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "true"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse da posição atual até a posição do char(sqm do centro)." : "Drag the mouse from the current position to the character position(center sqm)."
            case "Drag item to position":
                hotkeysObj[hotkeyID].userValue.Push({"item": ""})
                hotkeysObj[hotkeyID].userValue.Push({"x": ""})
                hotkeysObj[hotkeyID].userValue.Push({"y": ""})
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse da posição do item até uma posição(coordenada) fixa da tela." : "Drag the mouse from the item position to a fixed position(coordinate) of the screen."
            case "Drag item to character position":
                hotkeysObj[hotkeyID].userValue.Push({"item": ""})
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse da posição do item até a posição do char(sqm do centro)." : "Drag the mouse from the item position to the character position(center sqm)."
            case "Drag image to position":
                hotkeysObj[hotkeyID].userValue.Push({"image": ""})
                hotkeysObj[hotkeyID].userValue.Push({"x": ""})
                hotkeysObj[hotkeyID].userValue.Push({"y": ""})
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse da posição da imagem até uma posição(coordenada) fixa da tela." : "Drag the mouse from the image position to a fixed position(coordinate) of the screen."
            case "Drag image to character position":
                hotkeysObj[hotkeyID].userValue.Push({"image": ""})
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse da posição da imagem até a posição do char(sqm do centro)." : "Drag the mouse from the image position to the character position(center sqm)."
            case "Drag mouse to position":
                hotkeysObj[hotkeyID].userValue.Push({"x": ""})
                hotkeysObj[hotkeyID].userValue.Push({"y": ""})
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse da posição atual até uma posição(coordenada) fixa da tela." : "Drag the mouse from the current position to a fixed position(coordinate) of the screen."
            case "Drag position to character position":
                hotkeysObj[hotkeyID].userValue.Push({"x": ""})
                hotkeysObj[hotkeyID].userValue.Push({"y": ""})
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse de uma posição(coordenada) fixa da tela até a posição do char(sqm do centro)." : "Drag the mouse from a fixed position(coordinate) of the screen to the character position(center sqm)."
            case "Drag position to item":
                hotkeysObj[hotkeyID].userValue.Push({"item": ""})
                hotkeysObj[hotkeyID].userValue.Push({"x": ""})
                hotkeysObj[hotkeyID].userValue.Push({"y": ""})
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse de uma posição(coordenada) fixa da tela até a posição do item." : "Drag the mouse from a fixed position(coordinate) of the screen to the item position."
            case "Drag position to mouse":
                hotkeysObj[hotkeyID].userValue.Push({"x": ""})
                hotkeysObj[hotkeyID].userValue.Push({"y": ""})
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse de uma posição(coordenada) fixa da tela até a posição atual do mouse." : "Drag the mouse from a fixed position(coordinate) of the screen to the current mouse position."
            case "Drag position to position":
                hotkeysObj[hotkeyID].userValue.Push({"x1": ""})
                hotkeysObj[hotkeyID].userValue.Push({"y1": ""})
                hotkeysObj[hotkeyID].userValue.Push({"x2": ""})
                hotkeysObj[hotkeyID].userValue.Push({"y2": ""})
                hotkeysObj[hotkeyID].userValue.Push({"holdCtrl": "false"})
                hotkeysObj[hotkeyID].userValue.Push({"holdShift": "false"})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Arrasta o mouse de uma posição(coordenada) fixa da tela até outra posição fixa da tela." : "Drag the mouse from a fixed position(coordinate) of the screen to the other fixed screen position."
            case "Loot around (opening corpses)":
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Abre os corpos nos sqms em volta do char e depois procura pelos itens adicionados na LootList e move para a backpack." : "Open the corpses on the sqms around the char and then search for the items added in the LootList and move to the backpack."
            case "Loot around (quick looting)":
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Looteia os 8 sqms em volta do char pressionando Shift+Right Click, ou a hotkey configurada na aba Looting." : "Loot the 8 sqms around the char pressing Shift+Right Click, or the hotkey configured in the Looting tab."
            case "Loot items (manual looting)":
                hotkeysObj[hotkeyID].userValue.Push({"moveOnlyOneItem": "true"})
                hotkeysObj[hotkeyID].userValue.Push({"pressEnterAfterMoveItem": "false"})
                hotkeysObj[hotkeyID].userValue.Push({"showTooltipWhenFinished": "true"})
                hotkeysObj[hotkeyID].userValue.Push({"tooltipDuration": 150})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Procura pelos itens adicionados na LootList e move para a backpack." : "Search for the items added in the LootList and move to the backpack."
            case "Shoot rune on target (battle list)":
                hotkeysObj[hotkeyID].userValue.Push({"item": ""})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Usa o item no alvo que está sendo atacado no Battle List." : "Use the item on the target that is being attacked on the Battle List."
            case "Use item on character":
                hotkeysObj[hotkeyID].userValue.Push({"item": ""})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Usa o item na posição do char(sqm do centro)." : "Use the item on the character position(center sqm)."
            case "Use item on mouse position":
                hotkeysObj[hotkeyID].userValue.Push({"item": ""})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Usa o item na posição atual do mouse." : "Use the item on the current mouse position."
            case "Use item on follow target":
                hotkeysObj[hotkeyID].userValue.Push({"item": ""})
                hotkeysObj[hotkeyID].comment := LANGUAGE = "PT-BR" ? "Usa o item no alvo que está com Follow no Battle List." : "Use the item on the target that is with Follow on the Battle List."
        }

        if (fromInitialCheck = true)
            return
        ; msgbox, % hotkeyID "`n" action "`n" serialize(hotkeysObj[hotkeyID])
        HotkeysGUI.updateHotkeyRow(hotkeyID)

        try GuiControl, CavebotGUI:, hotkeyComment, % hotkeysObj[hotkeyID].comment
        catch {
        }
        HotkeysGUI.resizeColumns()
    }

    getRealHotkey(hotkey) {
        switch hotkey {
            case "Mouse Forward Button":
                return "XButton2"
            case "Mouse Back Button":
                return "XButton1"
            case "Mouse Scroll Button":
                return "MButton"
            case "Page Down":
                return "PgDn"
            case "Page Up":
                return "PgUp"
            case "Numpad /":
                return "NumpadDiv"
            case "Numpad *":
                return "NumpadMult"
            case "Numpad +":
                return "NumpadAdd"
            case "Numpad 0":
                return "NumpadSub"
            case "aaaaaa":
                return "bbbbb"
            default:
                return hotkey
        }
    }

    isValidHotkey(hotkey := "") {
        if (hotkey = "")
            return false

        validHotkey := false
        for key, value in this.allowedHotkeys
        {
            if (value = hotkey) {
                validHotkey := true
                break
            }
        }

        if (validHotkey = false)
            return false


        return true

    }

}



