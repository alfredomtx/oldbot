#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_HealingJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client Areas\_LifeBarArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _ManaBarArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "manaBarArea"


    /**
    * @singleton
    */
    __New()
    {
        if (_ManaBarArea.INSTANCE) {
            return _ManaBarArea.INSTANCE
        }

        base.__New(this)

        _ManaBarArea.INSTANCE := this
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

        lifeBarArea := new _LifeBarArea()

        c1 := new _Coordinate(lifeBarArea.getCoordinates().getX1(), lifeBarArea.getCoordinates().getY1())
            .addX(this.clientJson().get("mana.offsetFromLifeBarX", 0))
            .addY(this.clientJson().get("mana.offsetFromLifeBarY", 14))

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
        return _ManaBarArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _ManaBarArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _ManaBarArea.INSTANCE := ""
        _ManaBarArea.INITIALIZED := false
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