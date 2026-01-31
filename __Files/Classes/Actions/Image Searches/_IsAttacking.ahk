

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\Image Searches\_AbstractImageSearchAction.ahk

class _IsAttacking extends _AbstractImageSearchAction
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return _UniqueImageSearch
    * @throws
    */
    __New()
    {
        try {
            this.validations()

            return this.searchPixelImage()
        } catch e {
            this.handleException(e, this)
            throw e
        }
    }

    /**
    * @return _ImageSearch
    */
    searchPixelImage()
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFolder(ImagesConfig.targetingFolder)
                .setArea(new _BattleListPixelArea())
                .setVariation(TargetingSystem.targetingJsonObj.redPixelArea.pixelImageVariation)
            ; .setDebug()

            if (jsonConfig("targeting", "redPixelArea", "backgroundTrans")) {
                searchCache.setTransColor("0")
            }
        }

        search := searchCache
            .setFile(TargetingSystem.targetingJsonObj.redPixelArea.pixelImage)
            .search()

        if (search.found()) {
            return search
        }

        if (!TargetingSystem.targetingJsonObj.redPixelArea.pixelImage2) {
            return search
        }

        return searchCache
            .setFile(TargetingSystem.targetingJsonObj.redPixelArea.pixelImage2)
            .search()
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
        _Validation.number("TargetingSystem.targetingJsonObj.redPixelArea.pixelImageVariation", TargetingSystem.targetingJsonObj.redPixelArea.pixelImageVariation)
    }
}