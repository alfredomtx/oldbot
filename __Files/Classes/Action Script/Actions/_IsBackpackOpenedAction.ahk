
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Action Script\Actions\_AbstractActionScript.ahk

class _IsBackpackOpenedAction extends _AbstractActionScript
{
    static IDENTIFIER := "isbackpackopened"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return void
    */
    identifyParams()
    {
        this.params.backpack := _A.first(this.params)
    }

    /**
    * @abstract
    * @throws
    */
    validate()
    {
        if (empty(this.params.backpack)) {
            this.error("Empty backpack param")
            return false
        }

        backpackImageName := StrReplace(this.params.backpack, " ", "_") ".png"
        if (!FileExist(ImagesConfig.mainBackpacksFolder "\" backpackImageName)) {
            this.error( "Main Backpack image file doesn't exist: " ImagesConfig.mainBackpacksFolder "\" backpackImageName)
            return false
        }
    }

    /**
    * @return bool
    */
    runAction()
    {
        this.info("backpack: " this.params.backpack)

        result := this.searchBackpack().found()

        this.info(_Str.quoted(this.params.backpack) " opened: " boolToString(result))

        return result
    }

    searchBackpack()
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFolder(ImagesConfig.mainBackpacksFolder)
                .setVariation(50)
                .setArea(new _SideBarsArea())
        }

        backpackImageName := StrReplace(this.params.backpack, " ", "_") ".png"

        return searchCache
            .setFile(backpackImageName)
            .search()
    }
}