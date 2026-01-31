#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ItemRefillJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client Areas\Equipment\_AbstractEquipmentArea.ahk

global TORCH_X
global TORCH_Y

/**
*/
class _TorchArea extends _AbstractEquipmentArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "torchArea"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @singleton
    */
    __New()
    {
        if (_TorchArea.INSTANCE) {
            return _TorchArea.INSTANCE
        }

        base.__New(this)

        _TorchArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        this.setupEquipmentArea(new _ItemRefillJson().get("distanceWeapon.torchImage"), new _ItemRefillJson().get("distanceWeapon.variation"))

        center := this.getCoordinates().getCenter()
        ; this.debug()

        TORCH_X := center.getX()
        TORCH_Y := center.getY()
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _TorchArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _TorchArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _TorchArea.INSTANCE := ""
        _TorchArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @return void
    */
    unsetInitialized() {
        _TorchArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @return string
    */
    resolveImageFolder() {
        return "torch"
    }
}