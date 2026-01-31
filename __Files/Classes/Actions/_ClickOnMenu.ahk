#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ClientMenusJson.ahk

class _ClickOnMenu extends _AbstractAction
{
    static OPEN := "open"
    static PASTE := "paste"
    static FOLLOW := "follow"
    static OPEN_BACKPACK := "openBackpack"

    /**
    * @param string image
    */
    __New(image)
    {
        this.image := image
    }

    /**
    * @return _ImageSearch
    */
    run()
    {
        try {
            this.validations()

            if (!this.clickParams) {
                this.clickParams := new _ClickParams("Left", 10, 3)
            }

            _search := new _ImageSearch()
                .setFile(this.resolveImage())
                .setFolder(this.resolveFolder())
                .setVariation(this.resolveVariation())
                .setClickOffsetX(this.clickParams.offsetX)
                .setClickOffsetY(this.clickParams.offsetY)
                .setDefaultClickMethod(new _ClientInputIniSettings().get("defaultMenuClickMethod"))
            ;.setDebug(true)

            if (this.coordinates) {
                _search.setCoordinates(this.coordinates)
            }

            _search.search()
                .click(this.clickParams.button)

            return _search
        } catch e {
            this.handleException(e, this)
            throw e
        }
    }

    /**
    * @param _ClickParams clickParams
    */
    setClickParams(clickParams)
    {
        _Validation.instanceOf("clickParams", clickParams, _ClickParams)
        this.clickParams := clickParams
        return this
    }

    /**
    * @param _Coordinates coordinates
    * @return this
    */
    setCoordinates(coordinates) {
        _Validation.instanceOf("coordinates", coordinates, _Coordinates)
        this.coordinates := coordinates

        return this
    }

    /**
    * @throws
    */
    resolveImage()
    {
        switch (this.image) {
            case this.FOLLOW: return OldBotSettings.settingsJsonObj.images.client.menu.follow
            case this.OPEN_BACKPACK: return OldBotSettings.settingsJsonObj.images.client.menu.openBackpackNewWindow
            case this.PASTE: return OldBotSettings.settingsJsonObj.images.client.chat.paste
            case this.OPEN: return _ClientMenusJson.exists() ? new _ClientMenusJson().get("openCorpse.image") : LootingSystem.lootingJsonObj.images.openCorpseImage
        }

        throw Exception("Could not resolve image for """ this.image """.")
    }

    resolveVariation()
    {
        switch (this.image) {
            case this.OPEN: return _ClientMenusJson.exists() ? new _ClientMenusJson().get("openCorpse.variation") : new _LootingJson().get("images.openCorpseImageVariation")
            default: return OldBotSettings.settingsJsonObj.images.client.menu.menuImagesVariation
        }
    }

    /**
    * @throws
    */
    resolveFolder()
    {
        switch (this.image) {
            case this.FOLLOW: return ImagesConfig.clientMenusFolder "\follow"
            case this.PASTE: return ImagesConfig.clientMenusFolder
            case this.OPEN: return ImagesConfig.clientOpenMenuFolder
            case this.OPEN_BACKPACK: return ImagesConfig.clientMenusFolder
        }

        throw Exception("Could not resolve folder for """ this.image """.")
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

        classLoaded("OldBotSettings", OldBotSettings)
        classLoaded("LootingSystem", LootingSystem)
    }
}