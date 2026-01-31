

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\Image Searches\_AbstractImageSearchAction.ahk

class _SearchCreature extends _AbstractImageSearchAction
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param string creatureName
    * @param ?bool firstResult
    * @param ?_Coordinates coordinates
    * @return _TargetingBase64ImageSearch
    * @throws
    */
    __New(creatureName, firstResult := true, coordinates := "")
    {
        static searchCache, battleListCoordinates

        try {
            this.validations()

            if (!searchCache || !battleListCoordinates) {
                searchCache := new _TargetingBase64ImageSearch()
                    .setVariation(TargetingSystem.targetingJsonObj.options.searchCreatureVariation)

                battleListCoordinates := new _BattleListArea().getCoordinates()
            }

            searchCache
                .setAllResults(!firstResult)
                .setCoordinates(coordinates ? coordinates : battleListCoordinates)

            if (!targetingObj.targetList[creatureName].image) {
                return searchCache
            }

            return searchCache
                .setImage(new _CreatureImage(creatureName))
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
    }
}