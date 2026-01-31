

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\_AbstractAction.ahk

/**
* @property _MapCoordinate coordinate
* @property string item
*/
class _UseItemOnSqm extends _AbstractAction
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param _Coordinate sqmPosition
    * @param string item
    * @return bool
    * @throws
    */
    __New(sqmPosition, item)
    {
        this.sqmPosition := sqmPosition
        this.item := item

        try {
            this.validations()

            if (!clientHasFeature("useItemWithHotkey")) {
                _CavebotWalker.dragItemFromSqmToChar(this.sqmPosition)

                try {
                    return this.useCavebotItemWithoutHotkey()
                } catch e {
                    _Logger.exception(e, A_ThisFunc, this.item)
                    return false
                }
            }

            itemHotkey := scriptSettingsObj["itemHotkeys"][this.item "Hotkey"]
            if (empty(itemHotkey)) {
                _Logger.error("Empty hotkey to use item: " this.item, A_ThisFunc)
                return false
            }

            Loop, 2 { ; use it 2 times
                if (A_Index > 1) {
                    CavebotWalker.getCharCoords()
                }

                _Logger.log("Cavebot", "Using " this.item " [hotkey: " itemHotkey "]")

                Send(itemHotkey)
                Sleep, 100
                this.sqmPosition.click()
                Sleep, 800
            }

            return true
        } catch e {
            this.handleException(e, this)
            throw e
        }

        return false
    }

    /**
    * @throws
    */
    useCavebotItemWithoutHotkey()
    {
        _Logger.log("Cavebot", "Using " this.item "..")
        _search := new _ItemSearch()
            .setName(this.item)
        ; .debug()
            .search()

        if (_search.notFound()) {
            _Logger.log("WARNING", "Item not found on screen: " this.item)

            return false
        }

        if (!_search.clickOnUse()) {
            _Logger.log("ERROR", "Failed to use item: " this.item " (classic control disabled: " boolToString(new _ClientInputIniSettings().get("classicControlDisabled")) ")")
            _Logger.log("WARNING", "Using right click to use item as fallback")

            Send("Esc")
            Sleep, 100


            _search.click("Right")
        }

        Sleep, 100
        this.sqmPosition.click()
        Sleep, 200
        Send("Esc")

        return true
    }

    /**
    * @abstract
    * @throws
    */
    validations()
    {
        _Validation.empty("this.item", this.item)
    }
}