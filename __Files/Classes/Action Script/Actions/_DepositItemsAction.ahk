
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Action Script\Actions\_AbstractDepositAction.ahk

class _DepositItemsAction extends _AbstractDepositAction
{
    static IDENTIFIER := "deposititems"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    runAction()
    {
        functionValues := this.values
        this.info(ActionScript.string_log)

        params := {}
            , params.stashBackpack := functionValues.1
        ; , params.delay := this.getNumberParam(functionValues.1)

            , params := this.checkParamsVariables(params)

        this.closeChildBackpacks()

        this.depotWindow := new _OpenDepotAction().run()
        if (!this.depotWindow) {
            return false
        }

        slots := {}
            , slots.y := {}
            , slots.1 := {}
            , slots.2 := {}
            , slots.3 := {}
            , slots.4 := {}

            , slots.y := this.depotWindow.y + 30
            , slots.1.x := this.depotWindow.x + 6
            , slots.2.x := slots.1.x + 35
            , slots.3.x := slots.2.x + 35
            , slots.4.x := slots.3.x + 35

        if (params.stashBackpack != "") {
            this.depositBackpackToStash(this.IDENTIFIER, params.stashBackpack)
        }
        ; open depot locker
        ; mouseMove, WindowX + slots.1.x, WindowY + slots.y
        ; msgbox, a
        Sleep, 150
        MouseClick("Right", slots.1.x, slots.y, false)
        Sleep, 1000

        return this.depositItemsAction(slots, params.stash)
    }

    hasChildBackpacks()
    {
        if (!this.isValidBackpack(lootingObj.depositSettings.backpackSettings.mainBackpack)) {
            return false
        }

        loop, 4 {
            if (this.isValidBackpack(lootingObj.depositSettings.backpackSettings["backpack" A_Index])) {
                return true
            }
        }

        return false
    }

    isValidBackpack(backpack)
    {
        return !empty(backpack) && backpack != "Optional..."
    }

    getChildBackpacks()
    {
        backpacks := {}
            , backpacks.1 := lootingObj.depositSettings.backpackSettings.backpack1
            , backpacks.2 := lootingObj.depositSettings.backpackSettings.backpack2
            , backpacks.3 := lootingObj.depositSettings.backpackSettings.backpack3
            , backpacks.4 := lootingObj.depositSettings.backpackSettings.backpack4

        return _Arr.filter(backpacks, "Optional...")
    }

    depositItemsAction(slots, stash)
    {
        mainBackpack := lootingObj.depositSettings.backpackSettings.mainBackpack

        this.searchDepositItems(slots, stash)

        if (empty(mainBackpack)) {
            return true
        }

        backpacks := this.getChildBackpacks()

        ; check if the four backpacks are blank
        haveChildBp := false
        Loop, 4 {
            if (backpacks[A_Index] && backpacks[A_Index] != "Optional...") {
                haveChildBp := true
            }
        }
        if (!haveChildBp) {
            return true
        }

        if (!this.searchMainBackpack(mainBackpack)) {
            return false
        }

        childsOpened := 0
        for key, backpack in backpacks
        {
            Loop, 30 {
                if (this.openChildBackpack(backpack)) {
                    this.searchDepositItems(slots, stash)
                    childsOpened++
                    continue
                }

                if (childsOpened > 0) {
                    if (this.returnBackpackContainer(backpack, childsOpened) = false)
                        return false
                    childsOpened := 0
                }

                break
            }
        }

        return true
    }

    searchDepositItems(slots, stash)
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _ItemSearch()
                .setArea(new _SideBarsArea())
        }

        this.afterDragItemDelay := 400

        depositerLocker2Category := lootingObj.depositSettings.depositLootDestination.depositerLocker2Category
        depositerLocker3Category := lootingObj.depositSettings.depositLootDestination.depositerLocker3Category
        depositerLocker4Category := lootingObj.depositSettings.depositLootDestination.depositerLocker4Category

        ; msgbox, % serialize(this.depotWindow)
        for itemName, atributes in lootingObj.depositList
        {
            ; stackable items were already deposited in the stack 
            if (stash = 1 && itemsObj[itemName].stackable = "stackable") {
                continue
            }

            depotDestination := 1
            if (atributes.category = depositerLocker2Category) {
                depotDestination := 2
            }
            if (atributes.category = depositerLocker3Category) {
                depotDestination := 3
            }
            if (atributes.category = depositerLocker4Category) {
                depotDestination := 4
            }

            /*
            check if item is found before entering the loop and getting a new client bitmap

            loopCountAnimation 15 to see if don't miss "Wand of Starstorm" when searching
            */
            _search := searchCache
                .setName(itemName)
                .search()

            if (_search.notFound()) {
                this.info("Item """ itemName """ not found")
                continue
            }

            /*
            try to deposit up to 100 times each item
            */
            timer := new _Timer()
            Loop, % cavebotSystemObj.depositItemLimit { 
                sleepDelay := this.afterDragItemDelay - 50 - timer.elapsed()
                Sleep, % sleepDelay > 0 ? sleepDelay : 0

                timer.reset()

                _search.search()
                if (_search.notFound()) {
                    break
                }

                this.info("Depositing """ itemName """, locker: " depotDestination ", (x1: " _search.getX() ", y1: " _search.getY() ", x2: " slots[depotDestination].x ", y2: " slots.y ") tries: " A_Index "/" cavebotSystemObj.depositItemLimit ".. " sleepDelay "ms")

                this.dragitem(_search.getX(), _search.getY(), slots[depotDestination].x, slots.y, holdshift := false, 0, debug := false)
                Sleep, 50
            }
        }
    }

    openChildBackpack(backpack)
    {
        static searchCache
        if (!searchCache) {
            c1 := new _Coordinate(this.mainBackpackWindow.x1, this.mainBackpackWindow.y1)
            c2 := new _Coordinate(this.mainBackpackWindow.x2, this.mainBackpackWindow.y2)
            searchCache := new _ItemSearch()
                .setArea(new _SideBarsArea())
                .setCoordinates(new _Coordinates(c1, c2))
        }

        _search := searchCache
            .setName(backpack)
            .search()

        if (_search.notFound()) {
            this.info("Backpack """ backpack """ not found")
            return false
        }

        this.info("Opening backpack """ backpack """")
        _search.click("Right")
        Sleep, 600
        return true 
    }

    /**
    * @return void
    */
    closeChildBackpacks()
    {
        static searchCache
        if (!this.hasChildBackpacks()) {
            return
        }

        backpacks := this.getChildBackpacks()
        for, key, backpack in backpacks {
            Loop, 20 {
                _search := this.searchBackpack(backpack)
                    .click()

                if (_search.notFound()) {
                    break
                }

                _Logger.log(this.IDENTIFIER, txt("Fechando backpack configurada como próxima para abrir: """ backpack """", "Closing backpack configured as next to open: """ backpack """"))
                Sleep, 200
            }
        }
    }

    /**
    * @param string backpack
    * @param ?_ClientArea area
    * @return _ImageSearch
    */
    searchBackpack(backpack, area := "")
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFolder(ImagesConfig.mainBackpacksFolder)
                .setArea(area ? area : new _SideBarsArea())
        }

        backpack := StrReplace(backpack, " ", "_")

        loop, % ImagesConfig.mainBackpacksFolder "\" backpack "*" {
            _search := searchCache
                .setFile(A_LoopFileName)
                .setClickOffsetX(165)
                .setClickOffsetY(3)
                .search()

            if (_search.found()) {
                return _search
            }
        }

        return _search
    }

    /**
    * @return bool
    */
    searchMainBackpack(mainBackpack)
    {
        _search := this.searchBackpack(mainBackpack)

        if (_search.notFound()) {
            this.error("Main backpack window """ mainBackpack """ not found")
            this.mainBackpackWindow := false
            return false
        }

        this.mainBackpackWindow := new _Coordinates(_search.getResult())

        height := 250
        heightTwentySlots := 210
        this.resizeGameWindow(height, this.mainBackpackWindow.x1 - 5, this.mainBackpackWindow.y1, false) ; 250 is the height of a backpack showing 24 slots

        mainBackpackBorder := this.findWindowBorder(this.mainBackpackWindow.x1 - 5, this.mainBackpackWindow.y1)
        if (!mainBackpackBorder) {
            this.error("Failed to find main backpack window(" mainBackpack ") border")
            return false
        }

        this.mainBackpackWindow.setX2(this.mainBackpackWindow.x1 + 160)
        this.mainBackpackWindow.setY2(mainBackpackBorder.y)

        this.mainBackpackWindow.height := this.calcWindowHeight(this.mainBackpackWindow.y1, this.mainBackpackWindow.y2)
        if (this.mainBackpackWindow.height = "") {
            this.error("Failed to get height of main backpack window(" mainBackpack ") " serialize(this.mainBackpackWindow))
            return false
        }

        if (this.mainBackpackWindow.height < heightTwentySlots) {
            this.warning("Main backpack window(" mainBackpack ") has no space to show 20 slots, change its position to fit (height: " this.mainBackpackWindow.height "/210px)", true)
        }

        return true
    }

    returnBackpackContainer(backpack, count, delay := 600)
    {
        local x1, y1, x2, y2
        x1 := this.mainBackpackWindow.x1 + 118
        y1 := this.mainBackpackWindow.y1 - 1
        x2 := this.mainBackpackWindow.x1 + 168
        y2 := this.mainBackpackWindow.y1 + 17
        ; mousemove, WindowX + x1, WindowY + y1
        ; msgbox, a
        ; mousemove, WindowX + x2, WindowY + y2
        ; msgbox, b
        vars := ""
        try {
            vars := ImageClick({"x1": x1, "y1": y1, "x2": x2, "y2": y2
                    , "image": "backward_container_backpack"
                    , "directory": ImagesConfig.clientButtonsFolder
                    , "variation": 40
                    , "funcOrigin": A_ThisFunc
                    , "debug": false})
        } catch e {
            _Logger.exception(e, A_ThisFunc)

            return false
        }
        if (!vars.x) {
            this.error("Couldn't go back to main back containter")
            return false
        }

        this.info("Returning " count " containers of backpack """ backpack """")
        Loop, % count {
            MouseClick("Left", vars.x + 4, vars.y + 4)
            Sleep, % delay
        }
    }
}