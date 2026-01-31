

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\_AbstractAction.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_CavebotJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\_ReleaseArrowKeys.ahk

class _WaitDisconnected extends _AbstractAction
{
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @return void
    */
    __New(delayAfterDisconnected := 20000)
    {
        try {
            wasDisconnected := false
            releasedKey := false

            Loop, {
                if (isConnected()) {
                    break
                }

                Sleep, 1000

                if (!releasedKey) {
                        new _ReleaseArrowKeys()
                    releasedKey := true
                }

                _Logger.log(A_ThisFunc, "Disconnected...")
                wasDisconnected := true
            }

            if (wasDisconnected) {
                Sleep(delayAfterDisconnected)
            }
        } catch e {
            this.handleException(e, this)
            throw e
        }
    }

    searchImage()
    {
        static searchCache

        if (!searchCache) {
            minimapArea := new _MinimapArea()

            images := {}
            images.push(ImagesConfig.minimapFolder "\" minimapArea.areaSetup("baseImage"))
            images.push(ImagesConfig.minimapZoomMinusFolder "\" minimapArea.images("zoomMinus"))

            searchCache := new _MultipleImageSearch(images)
                .setVariation(minimapArea.images("variation"))
                .setArea(minimapArea)
            ; .setDebug(True)
        }

        return searchCache.search()
    }
}