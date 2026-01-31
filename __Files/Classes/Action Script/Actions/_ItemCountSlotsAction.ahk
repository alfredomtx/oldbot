
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Action Script\Actions\_AbstractActionScript.ahk

class _ItemCountSlotsAction extends _AbstractActionScript
{
    static IDENTIFIER := "itemcountslots"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    runAction()
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _ItemSearch()
                .setArea(new _SideBarsArea())
                .setAllResults(true)
        }

        this.info(ActionScript.string_log)

        itemName := this.params.itemName

        t1ItemCount := A_TickCount

        this.info("Searching item """ itemName """..")

        _search := searchCache
            .setName(itemName)
            .search()

        if (_search.getResultsCount() < 1) {
            elapsedString  := " (" A_TickCount - t1ItemCount " ms)"
            this.error("item """ itemName """ not found on screen (" itemsImageObj[itemName].sprites " sprites)" "" elapsedString)
            return 0
        }

        if (itemsImageObj[itemName].stackable != "stackable") {
            elapsedString  := " (" A_TickCount - t1ItemCount " ms)"
            this.info("""" itemName """ (" itemsImageObj[itemName].stackable "), amount: " itemsFound.Count() "" elapsedString)
            return _search.getResultsCount()
        }

        switch (TibiaClient.getClientIdentifier()) {
            case "olders":
                PotX3 := 13, PotY3 := 16
            default:
                PotX3 := 17, PotY3 := 18
        }

        itemCount := 0
        for key, position in _search.getResults()
        {
            PotX := position.x + (CavebotSystem.cavebotJsonObj.settings.items.offsetFromItemX)
                , PotY := position.y + (CavebotSystem.cavebotJsonObj.settings.items.offsetFromItemY)

            itemAmount := this.readActionBarOCR(PotX, PotY, PotX + PotX3, PotY + PotY3, "item", 3, debugNumbers := false, debugColumns := false)
                , itemAmount := itemAmount < 1 ? 1 : itemAmount
                , itemCount += itemAmount
        }

        elapsedString := " (" A_TickCount - t1ItemCount " ms)"
        this.info("""" itemName """ (stackable), amount: " itemCount ", slots found: " itemsFound.Count() "" elapsedString)

        return itemCount
    }
}