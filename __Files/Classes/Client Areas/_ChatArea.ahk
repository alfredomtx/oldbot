#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _ChatArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "chatArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_ChatArea.INSTANCE) {
            return _ChatArea.INSTANCE
        }

        base.__New(this)

        _ChatArea.INSTANCE := this
    }

    /**
    * @abstract
    * @throws
    */
    beforeSetupValidations()
    {
        classLoaded("_CooldownBarArea", _CooldownBarArea)
        classLoaded("_GameWindowArea", _GameWindowArea)
        classLoaded("_SideBarLeftArea", _SideBarLeftArea)
        classLoaded("_SideBarRightArea", _SideBarRightArea)
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        windowArea := new _WindowArea()
        cooldownBarArea := new _CooldownBarArea()
        gameWindowArea := new _GameWindowArea()
        sideBarLeftArea := new _SideBarLeftArea()
        sideBarRightArea := new _SideBarRightArea()

        if (isTibia13()) {
            c1 := new _Coordinate(sideBarLeftArea.getX2(), cooldownBarArea.getY2())
                .addX(1)
            c2 := new _Coordinate(sideBarRightArea.getX1(), windowArea.getY2())
                .subX(2)
                .subY(28)
        } else {
            c1 := new _Coordinate(sideBarLeftArea.getX2(), gameWindowArea.getY2())
                .subX(5)
            c2 := new _Coordinate(sideBarRightArea.getX1(), windowArea.getHeight())
        }

        coordinates := new _Coordinates(c1, c2)
        ; coordinates.debug()
        this.setCoordinates(coordinates)
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _ChatArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _ChatArea.INITIALIZED := true
    }
}