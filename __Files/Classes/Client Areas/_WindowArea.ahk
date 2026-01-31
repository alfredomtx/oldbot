#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _WindowArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "windowArea"

    static OFFSET_Y1 := 31 ; changed from 32 on 05/03/2025 because in antiga online it was cropping the first pixel

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @singleton
    */
    __New()
    {
        if (_WindowArea.INSTANCE) {
            return _WindowArea.INSTANCE
        }

        base.__New(this)

        _WindowArea.INSTANCE := this
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
        coordinates := new _Coordinates(new _Coordinate(0, _WindowArea.OFFSET_Y1), new _Coordinate(WindowWidth, WindowHeight))
        ; .debug()

        this.setCoordinates(coordinates)
    }

    /**
    * @abstract
    * @throws
    */
    afterSetupValidations()
    {
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
        return _WindowArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _WindowArea.INITIALIZED := true
    }
}