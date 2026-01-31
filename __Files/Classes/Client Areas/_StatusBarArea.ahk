#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_SupportJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ClientAreasJson.ahk

class _StatusBarArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "statusBarArea"

    /**
    * @singleton
    */
    __New()
    {
        if (_StatusBarArea.INSTANCE) {
            return _StatusBarArea.INSTANCE
        }

        base.__New(this)

        _StatusBarArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        if (OldbotSettings.uncompatibleModule("support")) {
            this.setCoordinates(new _WindowArea().getCoordinates())
            return
        }

        result := this.searchBaseImages()

        c1 := new _Coordinate(result.x, result.y)
            .addX(this.setup("offsetFromBaseImagePositionX"))
            .addY(this.setup("offsetFromBaseImagePositionY"))

        c2 := new _Coordinate(c1.getX(), c1.getY())
            .addX(this.setup("width"))
            .addY(this.setup("height"))

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
        return _StatusBarArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _StatusBarArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _StatusBarArea.INSTANCE := ""
        _StatusBarArea.INITIALIZED := false
    }

    /**
    * @return _Coordinate
    * @throws
    */
    searchBaseImages()
    {
        baseImageSearch := new _ImageSearch()
            .setFile(this.setup("baseImage"))
            .setFolder(ImagesConfig.supportFolder)
            .setVariation(this.setup("baseImageVariation"))
            .setArea(new _WindowArea())
        ; .setDebug()
        ; .setDebug(this.options("debug"))

        _search := baseImageSearch
            .setFile(this.setup("baseImage"))
            .search()

        if (_search.found()) {
            return _search.getResult()
        }

        if (this.setup("baseImage2")) {
            _search := baseImageSearch
                .setFile(this.setup("baseImage2"))
                .search()

            if (_search.found()) {
                return _search.getResult()
            }
        }

        if (this.setup("baseImage3")) {
            _search := baseImageSearch
                .setFile(this.setup("baseImage3"))
                .search()

            if (_search.found()) {
                return _search.getResult()
            }
        }

        throw Exception(txt("Falha ao localizar a área da Status Bar.`n`nCertifique-se de que:`n1) O personagem está logado.`n2) O set(equipamentos) NÃO está minimizado`n3) O cliente do Tibia está no idioma INGLÊS.", "Failed to find Status Bar area.`n`nMake sure that: `n1) The character is logged in.`n2) The set(equipments) is NOT minimized.`n3) The Tibia client is in ENGLISH language."))
    }

    /**
    * @return _Coordinate
    * @throws
    */
    searchButtons()
    {
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

    /**
    * @abstract
    * @return _ClientJson
    */
    clientJson()
    {
        return new _SupportJson()
    }

    setup(key, default := "")
    {
        return this.json("statusBarAreaSetup." key, default)
    }
}