

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\Image Searches\_AbstractImageSearchAction.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_TargetingJson.ahk

class _SearchPlayersBattleList extends _AbstractImageSearchAction
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
                    .setFile(isRubinot() ? "empty_rubinot" : "players_battlelist")
                    .setFolder(ImagesConfig.battleListFolder "\players")
                    .setVariation(new _TargetingJson().get("battleListImages.emptyImageVariation", 60))
                    .setArea(new _PlayersBattleListArea())
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
    validations() {
        static validated
        if (validated) {
            return
        }

        validated := true

        classLoaded("TargetingSystem", TargetingSystem)
        _Validation.number("TargetingSystem.targetingJsonObj.battleListImages.emptyImageVariation", TargetingSystem.targetingJsonObj.battleListImages.emptyImageVariation)
    }
}