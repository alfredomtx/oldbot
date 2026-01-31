#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client Areas\_BattleListArea.ahk

/**
* @property _Coordinate position
*/
class _PlayersBattleListArea extends _BattleListArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "playersBattleListArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_PlayersBattleListArea.INSTANCE) {
            return _PlayersBattleListArea.INSTANCE
        }

        base.__New(this)

        _PlayersBattleListArea.INSTANCE := this
    }

    /**
    * @abstract
    * @throws
    */
    beforeSetupValidations()
    {
        classLoaded("TargetingSystem", TargetingSystem)
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        if (isTibia13()) {
            this.setupTibia13Area()
        } else {
            this.setupAreaOthers()
        }
    }

    /**
    * @abstract
    * @throws
    */
    afterSetupValidations()
    {
            new _BattleListArea().checkBattleListButtons(this.getCoordinates(), "Players Battle List")
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _PlayersBattleListArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _PlayersBattleListArea.INITIALIZED := true
    }

    /**
    * @return void
    */
    setupAreaOthers()
    {
        coordinates := new _BattleListArea().getCoordinates()
        this.setCoordinates(coordinates)
    }

    /**
    * @return void
    */
    setupTibia13Area()
    {
        this.searchBattleListTitle()

        c1 := new _Coordinate(this.position.getX(), this.position.getY())
            .add(-3)
        c2 := new _Coordinate(c1.getX(), c1.getY())
            .addX(120)
            .addY(65)

        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)
    }

    /**
    * @return void
    * @throws
    * @msgbox
    */
    searchBattleListTitle()
    {
        _search := new _ImageSearch()
            .setFile(isRubinot() ? "title_rubinot" : "players_battlelist_title")
            .setFolder(ImagesConfig.battleListFolder "\players")
            .setVariation(TargetingSystartem.targetingJsonObj.battleListImages.baseImageVariation)
            .search()

        if (_search.found()) {
            this.position := _search.getResult()
            return
        }

        file := "Data\Files\Videos\targeting_extra_player_battle_window.mp4"
        try  {
            Run, %file%
            sleep, 1000
        } Catch {
        }

        msg := txt("Não foi possível localizar o battle list de ""Players"" na tela, certifique-se de que o battle list está visível e tente novamente.`n`nO battle list the ""Players"" é magias marcadas com ""player safe"" e o anti-KS no modo ""Player on screen"".", "It was not possible to find the ""Players"" battle list on screen, ensure that it's visible and try again.`n`nThe ""Players"" battle list is needed for Attack Spells checked with ""player safe"" option and the anti-KS on ""Player on screen"" mode.")
        msgbox, 48, % "Players Battle List", % msg

        throw Exception(msg)
    }
}