#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Module Functions\_AbstractModuleFunction.ahk

global HealingSystem
global ItemsHandler

class _Runemaker extends _AbstractModuleFunction
{
    static IDENTIFIER := "runemaker"
    static DISPLAY_NAME := "Runemaker"
    static MODULE := _RunemakerModule


    static ANTI_IDLE_MINUTES := 5
    static FOOD_INTERVAL_MINUTES := 1

    static ERRORS := {}

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @return void
    */
    run()
    {
        try {
            if (A_IsCompiled && !this.isEnabled()) {
                ; if (!this.isEnabled()) {
                return
            }

            ; this.openHud()
            this.execute()

            ; this.updateLogsTimer()
        } catch e {
            this.logException(e, A_ThisFunc)
        }
    }

    /**
    * @return void
    */
    execute()
    {
        this.setup()

        this.initialValidation()

        Loop, {
            try {
                    new _WaitDisconnected(5000)

                this.runemaking()
                this.logoutWithoutBlankRune()
                this.eatFood()
                this.checkAntiIdle()

                sleep(400, 1000)
            } catch e {
                this.logException(e, A_ThisFunc)
            } finally {
                Sleep, 1000
            }
        }
    }

    initialValidation()
    {
            new _WaitDisconnected(5000)

        try {
            this.guardAgainstLeftHandNotFound()
            this.runemakerValidations()
        } catch e {
            Msgbox, 48, % A_ScriptName " - " _RunemakerModule.DISPLAY_NAME, % e.Message
            Reload
        }
    }

    runemaking()
    {
        this.validations()

        if (!this.predicates()) {
            return
        }

        this.moveBlankRuneToHand()
        this.castSpell()
        this.moveRuneFromHand()
        this.openNextBackpack()
    }

    moveBlankRuneToHand()
    {
        if (!this.settings("moveBlankToHand")) {
            return
        }

        this.log(A_ThisFunc)
        this.guardAgainstDisconnected()

        blankRune := this.searchBlackRune()
        if (blankRune.notFound()) {
            this.log("blank rune not found on screen")
            return false
        }


        this.log("moving blank rune to hand")
        blankRune.getResult().drag(this.getLeftHandCenter(), false)

        Sleep, % _Delay.moveItem()
    }

    castSpell()
    {
        htk := this.settings("spellHotkey")
        _Validation.empty("spellHotkey", htk)

        this.log("casting spell, hotkey: " _Str.quoted(htk))

        Send(htk)
        Sleep, 1000
    }

    moveRuneFromHand()
    {
        this.moveRuneToFirstSlot()

        if (!enabled := this.settings("enabled", "moveRunePosition")) {
            return
        }

        position := enabled ? this.moveRuneToPosition() : this.moveRuneToBackpack()

        this.getLeftHandCenter().drag(position)

        Sleep, % _Delay.moveItem()
    }

    moveRuneToFirstSlot()
    {
        this.log(A_ThisFunc)
        this.guardAgainstDisconnected()

        position := this.getFirstBackpackArea().getCenter()

        this.getLeftHandCenter().drag(position)
        Sleep, % _Delay.moveItem()
    }

    moveRuneToPosition()
    {
        this.log(A_ThisFunc)
        this.guardAgainstDisconnected()

        x := this.settings("x", "moveRunePosition")
        y := this.settings("y", "moveRunePosition")

        this.log("moving rune to position, x: " x ", y: " y)

        return new _Coordinate(x, y)
    }

    moveRuneToBackpack()
    {
        this.log(A_ThisFunc)
        this.guardAgainstDisconnected()
        bp := this.findMainBackpack()

        result := bp.getResult()

        coordinate := new _Coordinate(result.getX(), result.getY())
            .addX(20)
        coordinate.addY(bp.getImageBitmap().getHeight() + 20)

        return coordinate
    }

    findMainBackpack()
    {
        return new _MainBackpackArea().findMainBackpack()
    }

    openNextBackpack()
    {
        if (!this.settings("openNextBackpack")) {
            return
        }

        this.log(A_ThisFunc)
        this.guardAgainstDisconnected()

        area:= this.getLastBackpackArea()

        backpack := new _ItemSearch()
            .setName("backpack")
            .setCoordinates(area)
        ;.setDebug(true)
            .search()

        if (backpack.notFound()) {
            return
        }

        blankRune := this.getBlankRuneSearch()
            .setArea(new _MainBackpackArea())
        ; .setDebug()
            .search()

        if (blankRune.found()) {
            return
        }


        this.log("opening next backpack")

        backpack.getResult().click("Right")
        Sleep, % _Delay.moveItem()
    }

    predicates()
    {
        mana := this.settings("manaPercent")
        if (!HealingSystem.hasManaPercent(mana)) {
            this.log("not enough mana (" mana "%)")
            return false
        }

        if (this.searchBlackRune().notFound()) {
            this.log(this.getBlankRuneItemName() " not found on screen")
            return false
        }

        return true
    }

    getBlankRuneItemName()
    {
        value := this.settings("blankRune")
        return value ? value : "blank rune"
    }

    getBlankRuneSearch()
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _ItemSearch()
                .setName(this.getBlankRuneItemName())
            ; .setName("rope")
            ; .setDebug()

        }

        return searchCache
    }

    searchBlackRune()
    {
        return this.getBlankRuneSearch()
            .setArea(new _SideBarsArea())
            .search()
    }

    setup()
    {
        global HealingSystem := new _HealingSystem()

        itemsArray := {}
        itemsArray["ultimate healing rune"] := {}
        itemsArray["blank rune"] := {}

        global ItemsHandler := new _ItemsHandler(false, true)
        ; createItemsBitmaps(itemsArray)
        this.antiIdleTimer := new _Timer()
        this.foodTimer := new _Timer()

    }

    logoutWithoutBlankRune()
    {
        if (!this.settings("logoutWithoutBlankRune")) {
            return false
        }

        this.log("logout without blank rune")
        this.guardAgainstDisconnected()

        if (this.searchBlackRune().found()) {
            return false
        }

        this.log("No blank runes found, logging out.")

        Loop, 3 {
            this.log("Logging out, tries: " A_Index "/3")
            Send("Esc")
            Sleep(100, 200)
            SendModifier("Ctrl", "Q")
            Sleep(300, 400)
            if (isDisconnected()) {
                return true
            }
        }

        this.log("Failed to logout")

        return false
    }

    eatFood()
    {
        this.log(A_ThisFunc)
        this.guardAgainstDisconnected()

        enabled := this.settings("eatFood.enabled")
        if (!enabled) {
            return
        }

        this.log("[eat food] " this.foodTimer.minutes() "/" this.FOOD_INTERVAL_MINUTES " minutes")
        if (this.foodTimer.minutes() <= this.FOOD_INTERVAL_MINUTES) {
            return
        }


        try {
            food := this.settings("eatFood.food")
            _Validation.empty("food", food)
            search := new _ItemSearch()
                .setName(food)
                .search()

            if (search.notFound()) {
                this.log("[eat food] " _Str.quoted(food) " not found on screen")
                return
            }

            this.log("[eat food] eating " _Str.quoted(food))
            search.getResult().useWithoutCtrl()

            Sleep, % _Delay.useDisappearingItem()
        } finally {
            this.foodTimer.reset()
        }
    }


    checkAntiIdle()
    {
        this.log("[anti idle] " this.antiIdleTimer.minutes() "/" this.ANTI_IDLE_MINUTES " minutes")
        if (this.antiIdleTimer.minutes() <= this.ANTI_IDLE_MINUTES) {
            return
        }

        this.runAntiIdle()
    }

    runAntiIdle()
    {
        this.log(A_ThisFunc)

        this.antiIdleTimer.reset()

        this.guardAgainstDisconnected()

        ; TODO: anti idle without holding modifier keys
            new _AntiIdle().run()
    }

    /**
    * @return void
    * @exitApp
    */
    openHud()
    {
        try {
            this.hud := new _MarketbotHUD().open(close := false)
        } catch e {
            _Logger.msgboxException(16, e, A_ThisFunc, identifier)
            this.logException(e, identifier := "Failed to open Marketbot HUD")
            ExitApp
        }
    }

    runemakerValidations()
    {
        this.guardAgainstMultipleOpenedBackpacks()
        this.guardAgainstBackpackNotOpened()
        this.guardAgainstBackpackOnTheFirstSlot()
        this.guardAgainstBackpackNotOnTheLastSlot()
    }

    settings(key, nested := "")
    {
        return new _RunemakerSettings().get(key, nested)
    }


    log(msg)
    {
        _Logger.log("Runemaker", msg)
    }

    logException(e, identifier := "Runemaker")
    {
        _Logger.error(e.Message, identifier)
    }

    ;#region Events
    onPause()
    {
        this.log(A_ThisFunc, "Paused")
    }
    ;#endregion

    ;#region Getters
    getMainBackpackBitmap()
    {
        return _ItemsHandler.getMainBackpackSearch(_ItemsHandler.resolveMainBackpack()).getImageBitmap()
    }

    getLastBackpackArea()
    {
        area := new _MainBackpackArea()

        size := 50
        c1 := area.getC2().CLONE()
            .sub(size)
            .subX(10)

        c2 := c1.CLONE()
            .add(size)

        return new _Coordinates(c1, c2)
        ; .debug()
    }

    getFirstBackpackArea()
    {
        area := new _MainBackpackArea()

        bitmap := this.getMainBackpackBitmap()

        size := 50
        c1 := area.getC1().CLONE()
            .addY(bitmap.getHeight())

        c2 := c1.CLONE()
            .add(size)

        return new _Coordinates(c1, c2)
        ; .debug()
    }

    getLeftHandCenter()
    {
        return this.getLeftHandCoordinates().getCenter()
    }

    getLeftHandCoordinates()
    {
        return new _LeftHandArea().getCoordinates()
    }

    getBackpackIdentifier()
    {
        static value

        if (value) {
            return value
        }
        value := _ItemsHandler.resolveMainBackpack()
        if (InStr(value, "_")) {
            value := _Arr.first(StrSplit(value, "_"))
        }

        return value
    }
    ;#endregion
    ;#region Guards
    guardAgainstBackpackNotOpened()
    {
        try {
            this.findMainBackpack()
        } catch {
            throw Exception(txt("Backpack " _Str.quoted(this.getBackpackIdentifier()) "(marrom) não encontrada na tela, abra a backpack.", "Backpack " _Str.quoted(this.getBackpackIdentifier()) "(brown) not found on the screen, open the backpack."))
        }
    }

    guardAgainstMultipleOpenedBackpacks()
    {
        count := _ItemsHandler.getMainBackpackSearch(_ItemsHandler.resolveMainBackpack(), new _WindowArea())
            .setAllResults(true)
            .search()
            .getResultsCount()

        if (count > 1) {
            throw Exception(txt("Só pode haver 1 backpack do tipo " _Str.quoted(this.getBackpackIdentifier()) "(marrom) aberta na tela.", "There can only be 1 backpack of type " _Str.quoted(this.getBackpackIdentifier()) "(brown) opened on the screen."))
        }
    }

    guardAgainstLeftHandNotFound()
    {
        _search := new _ImageSearch()
            .setFile(new _ItemRefillJson().get("distanceWeapon.leftHandImage"))
            .setFolder(ImagesConfig.itemRefillFolder "\" _LeftHandArea.IMAGE_FOLDER)
            .setVariation(new _ItemRefillJson().get("distanceWeapon.variation"))
            .setArea(new _LeftHandArea())
        ; .setDebug()
            .search()

        if (_search.notFound()) {
            throw Exception("O slot da mão esquerda precisa estar vazio para iniciar o Runemaker, remova qualquer item que esteja na mão esquerda.", "The left hand slot needs to be empty to start the Runemaker, remove any item that is in the left hand.")
        }
    }

    guardAgainstBackpackOnTheFirstSlot()
    {
        area:= this.getFirstBackpackArea()

        search := new _ItemSearch()
            .setName("backpack")
            .setCoordinates(area)
        ; .setDebug(true)
            .search()

        if (search.notFound()) {
            return
        }

        throw Exception("Encontrado uma backpack no primeiro slot da " _Str.quoted(this.getBackpackIdentifier()) "(marrom), coloque algum outro item no primeiro slot.", "Found a backpack on the first slot of the " _Str.quoted(this.getBackpackIdentifier()) "(brown), put some other item on the first slot.")
    }

    guardAgainstBackpackNotOnTheLastSlot()
    {
        if (!this.settings("openNextBackpack")) {
            return
        }

        area:= this.getLastBackpackArea()

        search := new _ItemSearch()
            .setName("backpack")
            .setCoordinates(area)
        ; .setDebug(true)
            .search()

        if (search.found()) {
            return
        }

        throw Exception("Não há nenhuma backpack " _Str.quoted(this.getBackpackIdentifier()) "(marrom), no último slot da backpack aberta, coloque a backpack no último slot como é mostrado na imagem na tela do Runemaker.`nCaso você não tenha proximas backpacks para abrir, desmarque a opção ""Abrir próxima backpack"" no Runemaker.", "There is no " _Str.quoted(this.getBackpackIdentifier()) "(brown) backpack on the last slot of the opened backpack, put the backpack on the last slot as shown in the image on the Runemaker screen.`nIf you don't have next backpacks to open, uncheck the option ""Open next backpack"" in the Runemaker.")
    }

    guardAgainstDisconnected()
    {
        if (isDisconnected()) {
            throw Exception(txt("Char desconectado", "Char disconnected"))
        }
    }
    ;#endregion
}