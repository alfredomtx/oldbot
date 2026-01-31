

class _WalkToSingleSqm extends _AbstractWalkAction
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param _MapCoordinate destination
    * @param _MapCoordinate sqmDestination
    */
    __New(destination, sqmDestination)
    {
        this.destination := destination
        this.sqmDestination := sqmDestination

        try {
            return this.run()
        } catch e {
            this.handleException(e, this)
            throw e
        }
    }

    /**
    * @return bool
    */
    run()
    {
        ; try to walk 2 times to the same coord(in case there is a character in the position)
        Loop, 2 {
            cavebotSystemObj.triesWalk++

            if (cavebotSystemObj.triesWalk > cavebotSystemObj.triesWalkLimit) {
                return false
            }

            if (this.walkToCoordSqm()) {
                return true
            }
        }

        return false
    }

    /**
    * @return bool
    */
    walkToCoordSqm()
    {
        if (this.destination.arrived()) {
            return true
        }

        if (isDisconnected()) {
            return false
        }

        walkCoords := realCoordsToMinimapRelative(this.sqmDestination.x, this.sqmDestination.y)
        /**
        if the next step is the char sqm, will be 0
        */
        if (walkCoords.X = 0 && walkCoords.Y = 0) {
            return true
        }

        try {
            this.SQM := _CavebotWalker.getSQMByMinimapDirection(walkCoords.X, walkCoords.Y)
        } catch e {
            _Logger.log("Cavebot Path ERROR",  e.Message, true)
            return false
        }

        /**
        can't use arrow keys here, because will fail to walk in diagonal
        and also arrow keys walk slower than clicking
        */
        _CavebotWalker.clickOnSQM(this.SQM, "Left")

        defaultDelay := 50
        Sleep, % defaultDelay ; small delay after click before searching not possible

        if (CavebotSystem.searchSorryNotPossible()) {
            CavebotWalker.clickOnSQM(this.SQM, "Left")
            Sleep, % defaultDelay
        }

        return this.afterClickedOnSqm(defaultDelay)
    }

    /**
    * @return bool
    */
    afterClickedOnSqm(defaultDelay)
    {
        realDelay := new _CavebotIniSettings().get("walkDelay") + (isTibia13() ? 0 : 100)
        realDelay -= defaultDelay
        if (realDelay < 50) {
            realDelay :=  50
        }

        Sleep, % realDelay ;  little delay to wait for the char to move

        if (cavebotSystemObj.triesWalk > 10) {
            _Logger.log("Cavebot", "[" cavebotSystemObj.triesWalk "/" cavebotSystemObj.triesWalkLimit "] " txt("Caminhando pelas setas até o SQM ", "Walking arrow keys to SQM ") this.SQM ", x:" this.sqmDestination.getX() ", y:" this.sqmDestination.getY() ", delay: " realDelay "ms")
        } else {
            _Logger.log("Cavebot", txt("Caminhando pelas setas até o SQM ", "Walking arrow keys to SQM ") this.SQM ", x:" this.sqmDestination.getX() ", y:" this.sqmDestination.getY() ", delay: " realDelay "ms")
        }

        Loop, % isTibia13() ? 4 : 8 {
            _CharCoordinate.GET()
            if (this.sqmDestination.isCharacterPos()) {
                return true
            }

            /**
            if character changed floor while walking by arrow return true
            */
            if (posz != this.destination.z) {
                return true
            }

            Sleep, % 50 - elapsed
        }

        ; algo bloqueou o caminho e não conseguiu caminhar, voltar para gerar o path novamente?
        _Logger.log("Cavebot", txt("Não foi possível caminhar até o SQM: ", "Couldn't walk to SQM: ") this.sqmDestination.getX() "," this.sqmDestination.getY() " (" walkCoords.X "," walkCoords.Y ") (tries: " cavebotSystemObj.triesWalk "/" cavebotSystemObj.triesWalkLimit ")")

        this.dragRandomSqm()

        return false
    }

    /**
    * @return void
    */
    dragRandomSqm()
    {
        SQM := this.SQM
        /**
        drag the mouse of the coordinate destination sqm in case it's a player
        will drag from the destination sqm to a random sqm in the same sqm row
        */
        sqmDragDist := SQM_SIZE
        Random, randomSQM, 1, 3
        switch SQM {
            case 4: ; <= vertical
                pushSmqs := {1: 1, 2: 4, 3: 7}
                randomSqmY := pushSmqs[randomSQM]
                this.dragSqmLog(SQM, randomSqmY)

                MouseDrag(SQM%SQM%X, SQM%SQM%Y, SQM%SQM%X - sqmDragDist, SQM%randomSqmY%Y)

            case 6: ; => vertical
                pushSmqs := {1: 3, 2: 6, 3: 9}
                randomSqmY := pushSmqs[randomSQM]
                this.dragSqmLog(SQM, randomSqmY)

                MouseDrag(SQM%SQM%X, SQM%SQM%Y, SQM%SQM%X + sqmDragDist, SQM%randomSqmY%Y)

            case 2: ; \/ horizontal
                pushSmqs := {1: 1, 2: 2, 3: 3}
                randomSqmX := pushSmqs[randomSQM]
                this.dragSqmLog(SQM, randomSqmX)

                MouseDrag(SQM%SQM%X, SQM%SQM%Y, SQM%randomSqmX%X, SQM%SQM%Y + sqmDragDist)

            case 8: ; /\ horizontal
                pushSmqs := {1: 7, 2: 8, 3: 9}
                randomSqmX := pushSmqs[randomSQM]
                this.dragSqmLog(SQM, randomSqmX)

                MouseDrag(SQM%SQM%X, SQM%SQM%Y, SQM%randomSqmX%X, SQM%SQM%Y - sqmDragDist)
        }

        /**
        Delay to be able to drag players
        TO DO: search for life bar
        */
        if (!clientHasFeature("walkThroughPlayers")) {
            Sleep, 1050
        }
    }

    /**
    * @return void
    */
    dragSqmLog(sqm, pos)
    {
        _Logger.log("Cavebot", txt("Arrastando(push) do SQM " sqm " para " pos, "Dragging(push) from SQM " sqm " to "  pos) )
    }
}