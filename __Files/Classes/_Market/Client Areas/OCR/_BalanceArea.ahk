#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\_OcrArea.ahk

class _BalanceArea extends _OcrArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "balanceArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_BalanceArea.INSTANCE) {
            return _BalanceArea.INSTANCE
        }

        base.__New(this)

        _BalanceArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        area := new _MarketWindowArea()

        c1 := new _Coordinate(area.getX1(), area.getY2())
            .addX(35)
            .subY(32)

        c2 := _Coordinate.FROM(c1)
            .addX(100)
            .addY(14)

        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)
        ; this.debug()
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _BalanceArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _BalanceArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _BalanceArea.INSTANCE := ""
        _BalanceArea.INITIALIZED := false
    }
}