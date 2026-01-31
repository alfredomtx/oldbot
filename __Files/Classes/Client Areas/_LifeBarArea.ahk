#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_HealingJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Healing\_HealingSystem.ahk

class _LifeBarArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "lifeBarArea"

    /**
    * @singleton
    */
    __New()
    {
        if (_LifeBarArea.INSTANCE) {
            return _LifeBarArea.INSTANCE
        }

        base.__New(this)

        _LifeBarArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        if (OldbotSettings.uncompatibleModule("healing")) {
            this.setCoordinates(new _WindowArea().getCoordinates())
            return
        }

        vars := _HealingSystem.searchLifeBar()
        if (!vars.x) {
            throw Exception("Failed to find Life Bar position")
        }

        c1 := new _Coordinate(vars.x, vars.y)
            .addX(this.clientJson().get("life.offsetFromBaseImagePositionX", 0))
            .addY(this.clientJson().get("life.offsetFromBaseImagePositionY", 0))

        c2 := new _Coordinate(c1.getX(), c1.getY())
            .addX(this.clientJson().get("options.barWidth", 94))
            .addY(this.clientJson().get("options.barHeight", 10))

        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)

        if (this.options("debug")) {
            this.debug()
        }
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _LifeBarArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _LifeBarArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _LifeBarArea.INSTANCE := ""
        _LifeBarArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @return _ClientJson
    */
    clientJson()
    {
        return new _HealingJson()
    }
}