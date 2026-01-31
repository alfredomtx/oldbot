

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\Image Searches\_AbstractImageSearchAction.ahk

class _SearchTradeConfirmationButton extends _AbstractImageSearchAction
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?_Coordinates coordinates
    * @return _ImageSearch
    * @throws
    */
    __New(coordinates := "")
    {
        try {
            this.validations()

            try {
                return this.searchImages(coordinates)
            } catch e {
                this.handleException(e, this)
                throw e
            }
        }
    }

    searchImages(coordinates)
    {
        static searchCache, images := {}
        if (!searchCache) {
            folder := ImagesConfig.npcTradeFolder "\confirmation"
            searchCache := new _ImageSearch()
                .setFolder(folder)
                .setVariation(50)
                .setClickOffsets(4)

            images.Push("ok_button.png")
            if (isRubinot()) {
                Loop, % folder "\*_rubinot.png" {
                    images.Push(A_LoopFileName)
                }
            }
        }

        _search := searchCache
            .setCoordinates(coordinates ? coordinates : new _WindowArea().getCoordinates())

        for _, image in images
        {
            _search := searchCache
                .setFile(image)
                .search()

            if (_search.found()) {
                break
            }
        }

        return _search
    }
}