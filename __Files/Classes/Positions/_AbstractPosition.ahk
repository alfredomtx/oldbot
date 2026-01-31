#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

/**
* @property _Coordinate position
*/
class _AbstractPosition extends _BaseClass
{
    __Init() {
        classLoaded("TibiaClient", TibiaClient)
        classLoaded("_Coordinate", _Coordinate)
        classLoaded("_Validation", _Validation)
    }

    __New(inheritorClass := "")
    {
        guardAgainstAbstractClassInstance(inheritorClass, this)

        this.validateDependencies()

        if (!this.isInitialized()) {
            this.initialize()
        }
    }

    /**
    * @abstract
    * @throws
    */
    setupPosition()
    {
        abstractMethod()
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        abstractMethod()
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        abstractMethod()
    }

    /**
    * @return void
    * @throws
    */
    validateDependencies()
    {
        _Validation.empty("TibiaClientID", TibiaClientID)
        _Validation.number("WindowWidth", WindowWidth)
    }

    /**
    * @return void
    */
    initialize()
    {
        this.setupPosition()

        _Validation.instanceOf("this.getPosition()", this.getPosition(), _Coordinate)
        this.getPosition().validate()

        this.setInitialized()
    }

    /**
    * @param string type
    * @return int
    */
    get(type)
    {
        return this["get" type]()
    }

    /**
    * @return int
    */
    getX()
    {
        return this.getPosition().getX()
    }

    /**
    * @return int
    */
    getY()
    {
        return this.getPosition().getY()
    }

    /**
    * @return _Coordinate
    */
    getPosition()
    {
        return this.position
    }

    /**
    * @param _Coordinate position
    * @return this
    */
    setPosition(position)
    {
        _Validation.instanceOf("position", position, _Coordinate)

        this.position := position

        if (this.getPosition().getX() > WindowWidth) {
            this.getPosition().setX(WindowWidth - 5)
        }

        if (this.getPosition().getY() > WindowHeight) {
            this.getPosition().setY(WindowHeight - 5)
        }

        return this
    }

    /**
    * @param string msg
    * @return void
    * @throws
    */
    exception(msg)
    {
        throw Exception(msg, -2)
    }

    /**
    * @return void
    * @msgbox
    */
    debug()
    {
        this.getPosition().debug()
    }

}