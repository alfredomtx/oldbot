

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\Image Searches\_AbstractImageSearchAction.ahk

class _SearchProtectionZone extends _AbstractImageSearchAction
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return _ImageSearch
    * @throws
    */
    __New()
    {
        static searchCache

        if (!OldBotSettings.settingsJsonObj.clientFeatures.protectionZoneIndicator) {
            return false
        }

        try {
            this.validations()

            if (!searchCache) {
                searchCache := new _UniqueImageSearch()
                    .setFile(SupportSystem.supportJsonObj.options.pzZoneStatusBarImage)
                    .setFolder(ImagesConfig.statusBarFolder)
                    .setVariation(60)
                    .setArea(new _StatusBarArea())
            }

            return searchCache
                .search()
        } catch e {
            this.handleException(e, this)
            ; swallow exception
            return false
        }
    }

    /**
    * @abstract
    * @throws
    */
    validations() {
    }
}