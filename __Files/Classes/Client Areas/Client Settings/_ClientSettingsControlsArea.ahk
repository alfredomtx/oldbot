#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _ClientSettingsControlsArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "clientSettingsControlsArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_ClientSettingsControlsArea.INSTANCE) {
            return _ClientSettingsControlsArea.INSTANCE
        }

        base.__New(this)

        _ClientSettingsControlsArea.INSTANCE := this
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
        area := new _ClientSettingsArea()

        c1 := _Coordinate.FROM(area.getC1())
            .addX(90)
        c2 := _Coordinate.FROM(area.getC2())
            .subX(10)
            .subY(30)
        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)
    }

    /**
    * @abstract
    * @return void
    */
    afterInitialization()
    {
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _ClientSettingsControlsArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _ClientSettingsControlsArea.INITIALIZED := true
    }
}