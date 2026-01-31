#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _CooldownBarArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "cooldownBarArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_CooldownBarArea.INSTANCE) {
            return _CooldownBarArea.INSTANCE
        }

        base.__New(this)

        _CooldownBarArea.INSTANCE := this
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

        if (!isTibia13()) {
            this.setCoordinates(new _WindowArea().getCoordinates())
            return
        }

        buttons := this.searchButtons()
        cooldownIconSearch := this.searchCooldownIcons()

        cooldownBarWidth := 330
        cooldownBarHeight := 26

        c1 := new _Coordinate(cooldownIconSearch.getX(), buttons.getY())
            .addY(-27)
        c2 := new _Coordinate(c1.getX(), c1.getY())
            .addX(cooldownBarWidth)
            .addY(cooldownBarHeight)

        coordinates := new _Coordinates(c1, c2)
        ; coordinates.debug()
        this.setCoordinates(coordinates)
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance() {
        _CooldownBarArea.INSTANCE := ""
        _CooldownBarArea.INITIALIZED := false
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _CooldownBarArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _CooldownBarArea.INITIALIZED := true
    }

    /**
    * @return _Coordinate
    * @throws
    */
    searchCooldownIcons() {
        /*
        Search for the Support icon of cooldown bar if not found search for attack and then healing.

        Variation higher than 40 is finding images in the gray area of the client.
        */
        cooldownBarSearch := new _ImageSearch()
            .setFolder(ImagesConfig.cooldownBarFolder)
            .setVariation(40)

        _search := cooldownBarSearch
            .setFile("special")
            .setResultOffsetX(-78)
            .search()

        if (_search.found()) {
            return _search.getResult()
        }

        _search := cooldownBarSearch
            .setFile("support")
            .setResultOffsetX(-54)
            .search()

        if (_search.found()) {
            return _search.getResult()
        }

        _search := cooldownBarSearch
            .setFile("attack")
            .setResultOffsetX(-5)
            .search()

        if (_search.found()) {
            return _search.getResult()
        }

        _search := cooldownBarSearch
            .setFile("healing")
            .setResultOffsetX(-30)
            .search()

        if (_search.found()) {
            return _search.getResult()
        }

        throw Exception(txt("Não foi possível localizar a Cooldown Bar, ative a opção na interface do cliente e tente novamente.", "It was not possible to find the Cooldown Bar area, enable the option on the client interface and trya again."))
    }

    /**
    * @return _Coordinate
    * @throws
    */
    searchButtons() {
        _search := new _ImageSearch()
            .setFile(ImagesConfig.chatButtons)
            .setFolder(ImagesConfig.clientChatFolder)
            .setArea(new _WindowArea())
            .setVariation(40)
            .search()

        if (_search.notFound()) {
            throw Exception(txt("Falha ao encontrar os botões do chat (1), por favor contate o suporte junto com um screenshot da tela do Tibia", "Failed to find chat buttons (1), please contact support with a screenshot of Tibia's screen."))
        }

        return _search.getResult()
    }
}