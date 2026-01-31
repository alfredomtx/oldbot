
global AMULET_X
global AMULET_Y

/**
*/
class _AmuletArea extends _AbstractEquipmentArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "amuletArea"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @singleton
    */
    __New()
    {
        if (_AmuletArea.INSTANCE) {
            return _AmuletArea.INSTANCE
        }

        base.__New(this)

        _AmuletArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        this.setupEquipmentArea(ItemRefillSystem.itemRefillJsonObj.amulet.amuletSlotImage, ItemRefillSystem.itemRefillJsonObj.amulet.variation)

        center := this.getCoordinates().getCenter()

        AMULET_X := center.getX()
        AMULET_Y := center.getY()
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _AmuletArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _AmuletArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    unsetInitialized()
    {
        _AmuletArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _AmuletArea.INSTANCE := ""
        _AmuletArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @return string
    */
    resolveImageFolder()
    {
        return "amulet"
    }
}