#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _SideBarLeftArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "sideBarLeftArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_SideBarLeftArea.INSTANCE) {
            return _SideBarLeftArea.INSTANCE
        }

        base.__New(this)

        _SideBarLeftArea.INSTANCE := this
    }

    /**
    * @abstract
    * @throws
    */
    beforeSetupValidations()
    {
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        ; if (isRubinot()) {
        ;     this.setCoordinates(new _WindowArea().getCoordinates())
        ;     return
        ; }

        windowArea := new _WindowArea()
        if (OldbotSettings.settingsJsonObj.options.entireGameWindowArea) {
            this.setCoordinates(windowArea.getCoordinates())
            return
        }

        c1 := new _Coordinate(windowArea.getX1(), windowArea.getY1())

        if (isTibia13()) {
            c2 := new _Coordinate(new _CooldownBarArea().getX1(), windowArea.getY2())
        } else {
            c2 := new _Coordinate(new _GameWindowArea().getX1(), windowArea.getY2())
        }

        coordinates := new _Coordinates(c1, c2)
        this.setCoordinates(coordinates)
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance() {
        _SideBarLeftArea.INSTANCE := ""
        _SideBarLeftArea.INITIALIZED := false
        _CooldownBarArea.destroyInstance()
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _SideBarLeftArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _SideBarLeftArea.INITIALIZED := true
    }
}