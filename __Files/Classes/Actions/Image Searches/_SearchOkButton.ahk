

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\Image Searches\_AbstractImageSearchAction.ahk

class _SearchOkButton extends _AbstractImageSearchAction
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?_Coordinates coordinates
    * @return _ImageSearch
    * @throws
    */
    __New(coordinates := "") {
        static searchCache
        try {
            this.validations()

            if (!searchCache) {
                searchCache := new _ImageSearch()
                    .setFile("ok_button.png")
                    .setFolder(ImagesConfig.clientFolder)
                    .setVariation(50)
                    .setClickOffsets(4)
            }

            return searchCache
                .setCoordinates(coordinates ? coordinates : new _WindowArea().getCoordinates())
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