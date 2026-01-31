global RIGHT_HAND_X
global RIGHT_HAND_Y

/**
*/
class _RightHandArea extends _AbstractEquipmentArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "rightHandArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_RightHandArea.INSTANCE) {
            return _RightHandArea.INSTANCE
        }

        base.__New(this)

        _RightHandArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        this.setupEquipmentArea(ItemRefillSystem.itemRefillJsonObj.distanceWeapon.rightHandImage, ItemRefillSystem.itemRefillJsonObj.distanceWeapon.variation)

        center := this.getCoordinates().getCenter()

        RIGHT_HAND_X := center.getX()
        RIGHT_HAND_Y := center.getY()
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _RightHandArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _RightHandArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    unsetInitialized() {
        _RightHandArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @return string
    */
    resolveImageFolder() {
        return "right hand"
    }
}