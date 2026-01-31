#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

/**
*/
class _BattleListPixelArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "battleListPixelArea"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @singleton
    */
    __New()
    {
        if (_BattleListPixelArea.INSTANCE) {
            return _BattleListPixelArea.INSTANCE
        }

        base.__New(this)

        _BattleListPixelArea.INSTANCE := this
    }

    /**
    * @abstract
    * @throws
    */
    beforeSetupValidations()
    {
        classLoaded("_BattleListArea", _BattleListArea)
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        if (jsonConfig("targeting", "redPixelArea", "manualArea")) {
            this.setupFromIni()
            return
        }

        battleListArea := new _BattleListArea()

        c1 := new _Coordinate(battleListArea.getX1(), battleListArea.getY1())
            .addX(this.setup("offsetFromBattleListX", 19))
            .addY(this.setup("offsetFromBattleListY", 0))
        c2 := new _Coordinate(c1.getX(), battleListArea.getY2())
            .addX(this.setup("width", 4))

        coordinates := new _Coordinates(c1, c2)
        ; m("a")
        ; coordinates.debug()
        this.setCoordinates(coordinates)

        if (TargetingSystem.targetingJsonObj.options.debug) {
            msgbox, will debug pixel area
            this.debug()
        }
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _BattleListPixelArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _BattleListPixelArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _BattleListPixelArea.INSTANCE := ""
        _BattleListPixelArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @return _ClientJson
    */
    clientJson()
    {
        return new _TargetingJson()
    }

    setup(key, default := "")
    {
        return this.json("redPixelArea." key, default)
    }
}