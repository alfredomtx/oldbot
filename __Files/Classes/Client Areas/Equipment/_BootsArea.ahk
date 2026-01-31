global BOOTS_X
global BOOTS_Y

/**
*/
class _BootsArea extends _AbstractEquipmentArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "bootsArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_BootsArea.INSTANCE) {
            return _BootsArea.INSTANCE
        }

        base.__New(this)

        _BootsArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        this.setupEquipmentArea(ItemRefillSystem.itemRefillJsonObj.boots.bootsSlotImage, ItemRefillSystem.itemRefillJsonObj.boots.variation)

        center := this.getCoordinates().getCenter()

        BOOTS_X := center.getX()
        BOOTS_Y := center.getY()
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _BootsArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _BootsArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    unsetInitialized() {
        _BootsArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _BootsArea.INSTANCE := ""
        _BootsArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @return string
    */
    resolveImageFolder() {
        return "boots"
    }
}