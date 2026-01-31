

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\Image Searches\_AbstractImageSearchAction.ahk

class _SearchEmptyEquipmentSlot extends _AbstractImageSearchAction
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return _ImageSearch
    * @throws
    */
    __New(item, image := "") {
        try {
            this.validations()

            area := new _ClientAreaFactory(this.resolveAreaName(item, image))

            return new _UniqueImageSearch()
                .setFile(image ? image : ItemRefillSystem.itemRefillJsonObj[item][item "SlotImage"])
                .setFolder(ImagesConfig.itemRefillFolder "\" area.resolveImageFolder())
                .setVariation(ItemRefillSystem.itemRefillJsonObj[item].variation)
                .setArea(area)
                .search()
        } catch e {
            this.handleException(e, this)
            throw e
        }
    }

    /**
    * @param string item
    * @param string image
    * @return string
    */
    resolveAreaName(item, image) {
        areaName := item "Area"
        if (item = "distanceWeapon") {
            areaName := RegExMatch(image, "(torch|arrow)") ? "torchArea" : "leftHandArea"
        }

        return areaName
    }

    /**
    * @abstract
    * @throws
    */
    validations() {
        static validated
        if (!validated) {
            validated := true
        }

        classLoaded("ItemRefillSystem", ItemRefillSystem)
    }
}