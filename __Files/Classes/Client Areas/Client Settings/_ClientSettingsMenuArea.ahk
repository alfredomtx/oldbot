#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _ClientSettingsMenuArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "clientSettingsMenuArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_ClientSettingsMenuArea.INSTANCE) {
            return _ClientSettingsMenuArea.INSTANCE
        }

        base.__New(this)

        _ClientSettingsMenuArea.INSTANCE := this
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
        c2 := c1.CLONE()
            .addX(140)
            .addY(320)
        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _ClientSettingsMenuArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _ClientSettingsMenuArea.INITIALIZED := true
    }
}