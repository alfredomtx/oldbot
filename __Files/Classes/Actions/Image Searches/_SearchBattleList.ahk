

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\Image Searches\_AbstractImageSearchAction.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_TargetingJson.ahk

class _SearchBattleList extends _AbstractImageSearchAction
{
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @return _UniqueImageSearch
    * @throws
    */
    __New()
    {
        static searchCache
        try {
            this.validations()

            if (!searchCache) {
                searchCache := new _UniqueImageSearch()
                    .setFile(new _TargetingJson().get("battleListImages.emptyImage", "battle_list.png"))
                    .setFolder(ImagesConfig.battleListEmptyFolder)
                    .setVariation(new _TargetingJson().get("battleListImages.emptyImageVariation", 60))
                    .setArea(new _BattleListArea())
                 ;.setDebug()
            }

            return searchCache
                .search()
        } catch e {
            this.handleException(e, this)
            throw e
        }
    }

    /**
    * @abstract
    * @throws
    */
    validations()
    {
        static validated
        if (validated) {
            return
        }

        validated := true

        classLoaded("TargetingSystem", TargetingSystem)
        _Validation.number("TargetingSystem.targetingJsonObj.battleListImages.emptyImageVariation", TargetingSystem.targetingJsonObj.battleListImages.emptyImageVariation)
    }
}
