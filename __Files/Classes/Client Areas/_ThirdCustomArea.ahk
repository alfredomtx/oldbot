#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

/**
* @property array<_Coordinates> creaturePositions
* @property _Coordinate position
* @property _Coordinate attackPosition
* @property int height
*/
class _ThirdCustomArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "thirdCustomArea"

    static MIN_HEIGHT := 16
    static MIN_WIDTH := 60

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_ThirdCustomArea.INSTANCE) {
            return _ThirdCustomArea.INSTANCE
        }

        base.__New(this)

        _ThirdCustomArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        this.setupFromIni()
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _ThirdCustomArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _ThirdCustomArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _FirstCustomArea.INSTANCE := ""
        _FirstCustomArea.INITIALIZED := false
    }
}