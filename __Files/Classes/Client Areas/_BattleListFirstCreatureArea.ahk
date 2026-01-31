#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

/**
* @property array<_Coordinates> creaturePositions
* @property _Coordinate position
* @property _Coordinate attackPosition
* @property int height
*/
class _BattleListFirstCreatureArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "battleListFirstCreatureArea"

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
        if (_BattleListFirstCreatureArea.INSTANCE) {
            return _BattleListFirstCreatureArea.INSTANCE
        }

        base.__New(this)

        _BattleListFirstCreatureArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        battleListArea := new _BattleListArea()

        width := 130
        height := 16

        c1 := battleListArea.getC1().CLONE()
            .addX(53)
            .addY(61)
        c2 := c1.CLONE()
            .addX(width)
            .addY(height)

        coordinates := new _Coordinates(c1, c2)
        ; coordinates.debug()

        this.setCoordinates(coordinates)

        c1 := c1.clone()
            .addY(48)
        c2 := c1.clone()
            .addX(width)
            .addY(height)

        this.secondArea := new _Coordinates(c1, c2)
        ; .debug()
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _BattleListFirstCreatureArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _BattleListFirstCreatureArea.INITIALIZED := true
    }

    /**
    * @return _Coordinates
    */
    getSecondArea()
    {
        return this.secondArea
    }
}