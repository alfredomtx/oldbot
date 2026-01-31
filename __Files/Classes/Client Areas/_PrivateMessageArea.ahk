#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

/**
* @property _Coordinates npcMessageArea
*/
class _PrivateMessageArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "privateMessageArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_PrivateMessageArea.INSTANCE) {
            return _PrivateMessageArea.INSTANCE
        }

        base.__New(this)

        _PrivateMessageArea.INSTANCE := this
    }

    /**
    * @abstract
    * @throws
    */
    beforeSetupValidations()
    {
        classLoaded("_GameWindowArea", _GameWindowArea)
        classLoaded("_CharPosition", _CharPosition)
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        gameWindowArea := new _GameWindowArea()
        charPosition := new _CharPosition()

        c1 := new _Coordinate(charPosition.getX(), gameWindowArea.getSqmSize() * 3)
            .addX(-(gameWindowArea.getSqmSize() * 1))
            .addY(-gameWindowArea.getSqmSize())

        c2 := new _Coordinate(charPosition.getX(), charPosition.getY())
            .addX(gameWindowArea.getSqmSize() * 1)
            .addY(-((gameWindowArea.getSqmSize() * 2)) )

        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)

        this.setNpcMessageArea() 
    }

    /**
    * @abstract
    * @throws
    */
    afterSetupValidations()
    {
        _Validation.instanceOf("this.getNpcMessageArea()", this.getNpcMessageArea(), _Coordinates)
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _PrivateMessageArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _PrivateMessageArea.INITIALIZED := true
    }

    /**
    * @return void
    */
    setNpcMessageArea() {
        gameWindowArea := new _GameWindowArea()

        c1 := new _Coordinate(gameWindowArea.getX1(), this.getY2())
        c2 := new _Coordinate(gameWindowArea.getX2(), gameWindowArea.getY2())

        this.npcMessageArea := new _Coordinates(c1, c2)
            .validate()
    }

    /**
    * @return _Coordinates
    */
    getNpcMessageArea() {
        return this.npcMessageArea
    }
}