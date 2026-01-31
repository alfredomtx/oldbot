#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _FightControlsArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "fightControlsArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_FightControlsArea.INSTANCE) {
            return _FightControlsArea.INSTANCE
        }

        base.__New(this)

        _FightControlsArea.INSTANCE := this
    }

    /**
    * @abstract
    * @throws
    */
    beforeSetupValidations()
    {
        classLoaded("_EquipmentArea", _EquipmentArea)
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        equipmentArea := new _EquipmentArea() 
        if (isTibia13()) {
            windowArea := new _WindowArea()

            c1 := new _Coordinate(windowArea.getX2(), equipmentArea.getY1())
                .subX(60)
                .subY(2)
            c2 := new _Coordinate(windowArea.getX2(), equipmentArea.getY2())
                .subX(14)
                .subY(75)

            coordinates := new _Coordinates(c1, c2)
        } else {
            coordinates := equipmentArea.getCoordinates()
        }

        this.setCoordinates(coordinates)
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _FightControlsArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _FightControlsArea.INITIALIZED := true
    }
}