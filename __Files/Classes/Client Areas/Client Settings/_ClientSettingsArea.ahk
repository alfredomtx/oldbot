#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _ClientSettingsArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "clientSettingsArea"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @singleton
    */
    __New()
    {
        if (_ClientSettingsArea.INSTANCE) {
            return _ClientSettingsArea.INSTANCE
        }

        base.__New(this)

        _ClientSettingsArea.INSTANCE := this
    }

    /**
    * @abstract
    * @throws
    */
    beforeSetupValidations()
    {
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        _search := this.searchOptions()

        c1 := new _Coordinate(_search.getResult().getX(), _search.getResult().getY())
            .subX(305)
            .addY(30)
        c2 := c1.CLONE()
            .addX(660)
            .addY(490)
        coordinates := new _Coordinates(c1, c2)

        ; coordinates.debug()
        this.setCoordinates(coordinates)
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _ClientSettingsArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _ClientSettingsArea.INITIALIZED := true
    }

    /**
    * @return _ImageSearch
    * @throws
    */
    searchOptions()
    {
        _search := new _ImageSearch()
            .setFile("options_title")
            .setFolder("Data\Files\Images\Others\CheckSettings")
            .setVariation(60)
            .search()

        if (_search.notFound()) {
            throw Exception("option_title not found.")
        }

        return _search
    }
}