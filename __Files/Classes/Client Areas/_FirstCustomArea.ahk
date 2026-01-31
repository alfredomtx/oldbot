#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

/**
* @property array<_Coordinates> creaturePositions
* @property _Coordinate position
* @property _Coordinate attackPosition
* @property int height
*/
class _FirstCustomArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "firstCustomArea"

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
        if (_FirstCustomArea.INSTANCE) {
            return _FirstCustomArea.INSTANCE
        }

        base.__New(this)

        _FirstCustomArea.INSTANCE := this
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
        return _FirstCustomArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _FirstCustomArea.INITIALIZED := true
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