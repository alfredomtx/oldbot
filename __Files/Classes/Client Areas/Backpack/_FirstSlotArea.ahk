#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_SupportJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ClientAreasJson.ahk

class _FirstSlotArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "firstSlotArea"

    /**
    * @singleton
    */
    __New()
    {
        if (_FirstSlotArea.INSTANCE) {
            return _FirstSlotArea.INSTANCE
        }

        base.__New(this)

        _FirstSlotArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        base.setupFromClientAreasJson("backpack." this.getName(), _MainBackpackArea.CONTAINER_WIDTH, _MainBackpackArea.CONTAINER_HEIGHT)
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _FirstSlotArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _FirstSlotArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _FirstSlotArea.INSTANCE := ""
        _FirstSlotArea.INITIALIZED := false
    }
}