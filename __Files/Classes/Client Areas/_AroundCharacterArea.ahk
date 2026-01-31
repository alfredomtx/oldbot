#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _AroundCharacterArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "aroundCharacterArea"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @singleton
    */
    __New()
    {
        if (_AroundCharacterArea.INSTANCE) {
            return _AroundCharacterArea.INSTANCE
        }

        base.__New(this)

        _AroundCharacterArea.INSTANCE := this
    }

    /**
    * @abstract
    * @throws
    */
    beforeSetupValidations()
    {
        classLoaded("_GameWindowArea", _GameWindowArea)
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        c1 := new _Coordinate(CHAR_POS_X, CHAR_POS_Y)
            .sub(SQM_SIZE)
            .sub(SQM_SIZE_HALF)

        c2 := c1.CLONE()
            .add(SQM_SIZE * 3)
        ; .add(SQM_SIZE_HALF)
        ; .sub(SQM_SIZE_HALF)
        ; .sub(SQM_SIZE_HALF / 3)

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
        return _AroundCharacterArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _AroundCharacterArea.INITIALIZED := true
    }
}