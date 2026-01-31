#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ClientAreasJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client Areas\Backpack\_MainBackpackArea.ahk

/**
* @property bool areaFound
*/
class _AbstractEquipmentArea extends _AbstractClientArea
{
    static SIZE := 34

    /**
    * @param object inheritorClass
    * @singleton
    */
    __New(inheritorClass := "") {
        guardAgainstAbstractClassInstance(inheritorClass, this)
        base.__New(this)
    }

    /**
    * @abstract
    * @throws
    */
    beforeSetupValidations()
    {
        _Validaton.instanceOf("ItemRefillSystem", ItemRefillSystem, _ItemRefillSystem)
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupEquipmentArea(image, variation)
    {
        if (uncompatibleModule("itemRefill") || !image) {
            this.setCoordinates(new _EquipmentArea().getCoordinates())
            return
        }

        _search := new _ImageSearch()
            .setFile(image)
            .setFolder(ImagesConfig.itemRefillFolder "\" this.resolveImageFolder())
            .setVariation(variation)
        ; .setDebug()
            .search()

        this.notFound := _search.notFound()
        if (_search.notFound()) {
            this.setCoordinates(new _EquipmentArea().getCoordinates())

            base.setupFromClientAreasJson("equipment." this.getName(), _MainBackpackArea.CONTAINER_WIDTH, _MainBackpackArea.CONTAINER_HEIGHT)

            return
        }

        c1 := new _Coordinate(_search.getX(), _search.getY())
        ; .subX(1)
        ; .subY(2)
        c2 := new _Coordinate(c1.getX(), c1.getY())
            .add(this.SIZE)

        coordinates := new _Coordinates(c1, c2)
        if (ItemRefillSystem.itemRefillJsonObj.options.debug = true) {
            coordinates.debug()
        }

        this.setCoordinates(coordinates)
        this.areaFound := true
    }

    /**
    * @abstract
    * @return void
    */
    afterInitialization()
    {
        if (!this.areaFound) {
            this.unsetInitialized()
        }
    }

    /**
    * @abstract
    * @return string
    */
    resolveImageFolder()
    {
        abstractMethod()
    }
}
