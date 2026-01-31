global RING_X
global RING_Y

/**
*/
class _RingArea extends _AbstractEquipmentArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "ringArea"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @singleton
    */
    __New()
    {
        if (_RingArea.INSTANCE) {
            return _RingArea.INSTANCE
        }

        base.__New(this)

        _RingArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        this.setupEquipmentArea(ItemRefillSystem.itemRefillJsonObj.ring.ringSlotImage, ItemRefillSystem.itemRefillJsonObj.ring.variation)

        center := this.getCoordinates().getCenter()

        global RING_X := center.getX()
        global RING_Y := center.getY()
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _RingArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _RingArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    unsetInitialized()
    {
        _RingArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _RingArea.INSTANCE := ""
        _RingArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @return string
    */
    resolveImageFolder()
    {
        return "ring"
    }
}