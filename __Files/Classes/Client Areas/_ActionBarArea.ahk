#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _ActionBarArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "actionBarArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_ActionBarArea.INSTANCE) {
            return _ActionBarArea.INSTANCE
        }

        base.__New(this)

        _ActionBarArea.INSTANCE := this
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
        ; if (isRubinot()) {
        ;     this.setCoordinates(new _WindowArea().getCoordinates())
        ;     return
        ; }

        if (isNotTibia13()) {
            this.setCoordinates(new _WindowArea().getCoordinates())
            return
        }

        classLoaded("_CooldownBarArea", _CooldownBarArea)

        _search := this.searchButtons()

        cooldownBarArea := new _CooldownBarArea()

        coord1 := new _Coordinate(cooldownBarArea.getX1(), _search.getY())
            .addX(19)
        coord2 := new _Coordinate(_search.getX(), cooldownBarArea.getY1())
            .addX(-15)

        coordinates := new _Coordinates(coord1, coord2)
        ; coordinates.debug()

        this.setCoordinates(coordinates)
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _ActionBarArea.INSTANCE := ""
        _ActionBarArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @throws
    */
    afterSetupValidations()
    {
        if (isTibia13()) {
            this.validateVerticalActionBars()
        }
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _ActionBarArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _ActionBarArea.INITIALIZED := true
    }

    /**
    * @return _ImageSearch
    * @throws
    */
    searchButtons()
    {
        loop, 3 {
            _search := new _ImageSearch()
                .setFile("unlocked")
                .setFolder(ImagesConfig.actionBarFolder "\" A_Index)
                .setVariation(50)
            ; .setDebug()
                .search()

            if (_search.found()) {
                break
            }

            _search := new _ImageSearch()
                .setFile("locked")
                .setFolder(ImagesConfig.actionBarFolder "\" A_Index)
                .setVariation(40)
                .search()

            if (_search.found()) {
                break
            }
        }

        if (_search.notFound()) {
            throw Exception(txt("Falha ao detectar a área da Action Bar.`nCertifique-se de que há Action Bars na parte de baixo do cliente(bottom) e tente novamente.", "Failed to detect Action Bar area.`nEnsure that there are Action Bars in the bottom part of the client and try again."))
        }

        return _search
    }

    validateVerticalActionBars() {
        /**
        count left action bars
        */
        y1 := this.getY1() - 25
        y2 := this.getY1() - 5

        c1 := new _Coordinate(this.getX1(), y1)
            .addX(-20)
        c2 := new _Coordinate(c1.getX(), y2)
            .addX(110)
        coordinates := new _Coordinates(c1, c2)

        Loop, 3 {
            index := A_Index
            _search := new _ImageSearch()
                .setFile("unlocked")
                .setFolder(ImagesConfig.actionBarFolder "\" A_Index "\vertical")
                .setVariation(50)
                .setCoordinates(coordinates)
                .search()

            if (_search.found()) {
                break
            }

            _search.setFile("locked")
                .search()

            if (_search.found()) {
                break
            }
        }

        leftBars := (_search.notFound()) ? 0 : index

        c1 := new _Coordinate(this.getX2(), y1)
            .addX(-81)
        c2 := new _Coordinate(c1.getX(), y2)
            .addX(110)
        coordinates := new _Coordinates(c1, c2)
        /**
        count right action bars
        */
        Loop, 3 {
            index := A_Index
            _search := new _ImageSearch()
                .setFile("unlocked")
                .setFolder(ImagesConfig.actionBarFolder "\" A_Index "\vertical")
                .setVariation(50)
                .setCoordinates(coordinates)
                .search()

            if (_search.found()) {
                break
            }

            _search.setFile("locked")
                .search()

            if (_search.found()) {
                break
            }
        }
        rightBars := (_search.notFound()) ? 0 : index

        if (leftBars != rightBars) {
            throw Exception(txt("É necessário ter o mesmo número de Action Bars LATERAIS no cliente. O cliente está com " leftBars " no lado ESQUERDO e " rightBars " no lado DIREITO.`n`nAjuste as action bars laterais e tente novamente.`n`nCaso esteja com as action bars iguais, verifique se a barra de vida e mana estão na parte superior(top) do cliente.", "It's needed to have the same number of LATERAL Action Bars in the client. The client has " leftBars " in the LEFT side and " rightBars " in the RIGHT side.`n`nAjudst the lateral action bars and try again.`n`nIn case the action bars are the same, check if the life and mana bar are in the top part of the client."))
        }
    }

}