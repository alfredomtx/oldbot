global LEFT_HAND_X
global LEFT_HAND_Y

/**
*/
class _LeftHandArea extends _AbstractEquipmentArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "leftHandArea"

    static IMAGE_FOLDER := "left hand"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @singleton
    */
    __New()
    {
        if (_LeftHandArea.INSTANCE) {
            return _LeftHandArea.INSTANCE
        }

        base.__New(this)

        _LeftHandArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        this.setupEquipmentArea(new _ItemRefillJson().get("distanceWeapon.leftHandImage"), new _ItemRefillJson().get("distanceWeapon.variation"))

        center := this.getCoordinates().getCenter()

        ; this.debug()

        LEFT_HAND_X := center.getX()
        LEFT_HAND_Y := center.getY()
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _LeftHandArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _LeftHandArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    unsetInitialized() {
        _LeftHandArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _LeftHandArea.INSTANCE := ""
        _LeftHandArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @return string
    */
    resolveImageFolder()
    {
        return this.IMAGE_FOLDER
    }
}