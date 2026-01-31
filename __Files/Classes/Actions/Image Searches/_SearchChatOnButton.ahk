

class _SearchChatOnButton extends _AbstractImageSearchAction
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

        try {
            this.validations()

            if (!searchCache) {
                searchCache := new _UniqueImageSearch()
                    .setFolder(ImagesConfig.clientChatFolder)

                if (_AbstractChatAction.isIncompatible()) {
                    return searchCache
                }

                searchCache.setVariation(OldBotSettings.settingsJsonObj.images.client.chat.chatImagesVariation)
                    .setFile(this.resolveImageName())
                    .setArea(new _ChatButtonArea())
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
    }

    /**
    * @return string
    */
    resolveImageName()
    {
        static imageName
        if (imageName) {
            return imageName
        }

        if (OldBotSettings.settingsJsonObj.images.client.chat.chatOn) {
            return imageName := OldBotSettings.settingsJsonObj.images.client.chat.chatOn
        }

        if (WINDOWS_VERSION = "7") && (isTibia13()) {
            return imageName := "chat_on_windows7.png"
        }

        if (InStr(WINDOWS_VERSION, "Win_8")) && (isTibia13()) {
            return imageName := "chat_on_windows8.png"
        }

        throw Exception("Could not resolve image name.")
    }
}