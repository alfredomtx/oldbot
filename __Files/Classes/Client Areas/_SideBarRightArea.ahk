#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _SideBarRightArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "sideBarRightArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_SideBarRightArea.INSTANCE) {
            return _SideBarRightArea.INSTANCE
        }

        base.__New(this)

        _SideBarRightArea.INSTANCE := this
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

        if (isTibia13()) {
            c1 := new _Coordinate(new _ActionBarArea().getX2(), windowArea.getY1())
                .addX(27)
        } else {
            c1 := new _Coordinate(new _GameWindowArea().getX2(), windowArea.getY1())
        }

        c2 := new _Coordinate(windowArea.getX2(), windowArea.getY2())

        coordinates := new _Coordinates(c1, c2)

        /*
        Some OTs where the HUD is floating, the game window area will ocupy the entire screen
        */
        if (coordinates.getWidth() < 180) {
            _SideBarsArea.DISABLED := true
        }

        this.setCoordinates(coordinates)
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance() {
        _SideBarRightArea.INSTANCE := ""
        _SideBarRightArea.INITIALIZED := false
        _ActionBarArea.destroyInstance()
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _SideBarRightArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _SideBarRightArea.INITIALIZED := true
    }
}