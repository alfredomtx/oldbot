#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _SideBarsArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "sideBarsArea"
    static DISABLED := false

    /**
    * @singleton
    */
    __New()
    {
        if (_SideBarsArea.INSTANCE) {
            return _SideBarsArea.INSTANCE
        }

        base.__New(this)

        _SideBarsArea.INSTANCE := this
    }

    /**
    * @abstract
    * @throws
    */
    beforeSetupValidations()
    {
        classLoaded("_CooldownBarArea", _CooldownBarArea)
        classLoaded("_GameWindowArea", _GameWindowArea)
        classLoaded("_WindowArea", _WindowArea)
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        this.setCoordinates(new _WindowArea().getCoordinates())
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _SideBarsArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _SideBarsArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance() {
        _SideBarsArea.INSTANCE := ""
        _SideBarsArea.INITIALIZED := false
        _SideBarRightArea.destroyInstance()
        _SideBarLeftArea.destroyInstance()
    }
}