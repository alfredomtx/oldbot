
class _AstarPath extends _BaseClass
{
    static ASTAR_TIMEOUT := 2

    static FAIL_NOT_WALKABLE := "DestinationNotWalkable"
    static FAIL_COORD_TOO_FAR := "CoordTooFar"
    static FAIL_SET_PATH_TIMEOUT := "setPathTimeout"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param _MapCoordinate mapCoordinate
    */
    __New(destination)
    {
        this.destination := destination
        this.x := destination.getCenterX()
        this.y := destination.getCenterY()
        this.z := destination.getZ()

        this.showOnScreen := true
    }

    /**
    * @return ?array
    * @throws
    */
    setPath()
    {
        if (posx = this.x) && (posy = this.y) {
            return
        }

        this.guardAgainstInvalidCoordinate()

        Grid := this.generatePixelMap()

        Closed := {}
        for Y, Line in StrSplit(Grid, "`n")
            for X, val in StrSplit(Line)
                if (val = "*")
                    Closed[X,Y] := true
        else if (val = "B")
            X1 := X, Y1 := Y
        else if (val = "A")
            X2 := X, Y2 := Y, AX := X, AY := Y

        /**
        check if the the north, south, east and west sqms are closed
        */
        if (Closed[AX - 1, AY] = true)  ; left
                && (Closed[AX + 1, AY] = true)  ; right
                && (Closed[AX - 1, AY - 1] = true)  ; up
                && (Closed[AX, AY + 1] = true) { ; down
                throw Exception(txt("Falha ao setar rota: sqms N, S, W e E estão fechados", "Failed to set path: N, S, W and E sqms are closed") )
        } 

        this.startAstarTimer()

        try {
            Path := this.Astar_Grid(X1, Y1, X2, Y2, Closed)
        } finally {
            this.deleteAstarTimer()
        }

        if (Path.MaxIndex() < 1) {
            throw Exception(txt("Falha ao setar rota, distância", "Could not set path, distance") " x: " this.destination.getDistanceX(posx) ", y: " this.destination.getDistanceY(posy) ". From: " posx ", " posy  ", " posz " to: " this.x ", " this.y  ", " this.z)
        }

        pathRealCoords := this.buildRealCoordsPath(Path)

        return pathRealCoords
    }

    destroyWaypointOnScreen(x, y, z)
    {
        this.waypoints[z, x, y].destroyOnScreen()
        deleteCoordinate(this.waypoints, x, y, z)
    }

    destroyWaypointsOnScreen()
    {
        for z, values1 in this.waypoints {
            for x, values2 in values1 {
                for y, _ in values2 {
                    this.destroyWaypointOnScreen(x, y, z)
                }
            }
        }

        this.waypoints := ""
    }

    updateWaypointsOnScreen()
    {
        for z, values in this.waypoints {
            for x, values in values {
                for y, _ in values {
                    this.waypoints[z, x, y].showOnScreen()
                }
            }
        }
    }

    /**
    * @return string
    */    
    generatePixelMap()
    {
        this.verticalSqms := this.getMaxVerticalDistance()
        this.horizontalSqms := this.getMaxHorizontalDistance()

        verticalIndex := 0
        horizontalIndex := 0
        this.initialX := posx - this.horizontalSqms
        this.initialY := posy - this.verticalSqms

        this.waypoints := {}

        string := ""
        Loop, % this.verticalSqms * 2 + this.getOutOfScreenSqms() {
            y := this.initialY + verticalIndex

            Loop, % this.horizontalSqms * 2 + this.getOutOfScreenSqms() {
                x := this.initialX + horizontalIndex
                    , mapCoord := new _MapCoordinate(x, y, this.z)
                    , specialArea := _SpecialAreas.get(x, y, this.z)
                    , mapCoord.walkable := this.resolveWalkable(mapCoord, specialArea)

                if (x = posx && y = posy) {
                    if (this.showOnScreen) {
                        ; mapCoord.destroyOnScreen()
                        ; this.charCoord := mapCoord.showOnScreen("green", "x: " x "`ny: " y)

                        this.waypoints[this.charCoord.z, this.charCoord.x, this.charCoord.y] := this.charCoord
                    }

                    string .= "A"
                } else if (x = this.x && y = this.y) {
                    if (this.showOnScreen) {
                        ; mapCoord.destroyOnScreen()
                        ; this.destCoord := mapCoord.showOnScreen("blue", "x: " x "`ny: " y)
                        this.waypoints[this.destCoord.z, this.destCoord.x, this.destCoord.y] := this.destCoord
                    }

                    string .= "B"
                } else {
                    string .= mapCoord.walkable ? " " : "*"
                }

                ; mapCoord.showOnScreen(mapCoord.walkable ? "" : "red", "x: " x "`ny: " y)
                ; if (!mapCoord.walkable) {
                ;     mapCoord.showOnScreen(mapCoord.walkable ? "" : "red", "x: " x "`ny: " y)
                ; }

                horizontalIndex++
            }

            horizontalIndex := 0
                , verticalIndex++
                , string .= "`n"
        }

        return string
    }

    /**
    * @param _MapCoordinate mapCoord
    * @param ?_SpecialArea specialArea
    * @return bool
    */    
    resolveWalkable(mapCoord, specialArea)
    {
        conditions := _WalkableConditions.getList()

        condition := true
        for _, class in conditions {
            if (!new class(mapCoord.x, mapCoord.y, mapCoord.z).handle()) {
                condition := false
                break
            }
        }

        walkable := specialArea ? this.isWalkable(specialArea) : condition

        return walkable
    }

    /**
    * @return array
    */
    buildRealCoordsPath(Path)
    {
        result := {}
        Path := _Arr.invert(Path)

        for key, value in Path
        {
            ; ajustes para a coordenada ficar certa(real - não no display)
            ; if (generateBigPath = true)
            ;     Path[key]["X"] -= 54, Path[key]["Y"] -= isTibia13() = true ? 55: 56 ; 56 in OTClientV8
            Path[key]["X"] -= 1, Path[key]["Y"] -= 1 ; 2 in OTClientV8
            ; }
            coords := this.minimapToRealCoords(Path[key]["X"], Path[key]["Y"])
            if (coords.X = posx && coords.Y = posy) {
                continue
            }

            mapCoord := new _MapCoordinate(coords.X, coords.Y, this.z)

            if (this.showOnScreen) {
                isDest := coords.X == this.x && coords.Y == this.y
                coord := mapCoord.showOnScreen(isDest ? "blue" : "", "x: " coords.X "`ny: " coords.Y)
                this.waypoints[coord.z, coord.x, coord.y] := coord
            }

            result.Push(mapCoord)
        }

        return result
    }

    /**
    * @return void
    */
    deleteAstarTimer()
    {
        fn := this.getAstarTimer()
        SetTimer, % fn, Delete
    }

    /**
    * @return float
    */
    astarElapsedTimer()
    {
        if (!this.astarGridElapsed) {
            throw Exception("astarGridElapsed is not set")
        }

        return this.astarGridElapsed.seconds()
    }

    /**
    * @param x int
    * @param y int
    * @return object
    */
    minimapToRealCoords(x, y) 
    {
        return {"X": this.initialX + x, "Y": this.initialY + y}
    }

    ; Astar_Grid and supporting functions
    Astar_Grid(X1, Y1, X2, Y2, Closed := "")
    {
        if !IsObject(Closed)
            Closed := {}
        Open := {}, From := {}, G := {}, F := {}
            , Open[X1, Y1] := true, G[X1, Y1] := 0
            , F[X1, Y1] := this.Estimate_F(X1, Y1, X2, Y2)
        while Open.MaxIndex()
        {
            if (this.astarElapsedTimer() > this.ASTAR_TIMEOUT) {
                this.deleteAstarTimer()
                throw Exception("set path timed out (" this.ASTAR_TIMEOUT " seconds)", "setPathTimeout")
            }

            this.Lowest_F_Set(X, Y, F, Open)
            if (X = X2 and Y = Y2)
                return this.From_Path(From, X, Y)
            Open[X].Delete(Y)
            if !Open[X].MaxIndex()
                Open.Delete(X)
            Closed[X, Y] := true
            for index, Near in [{"X": X, "Y": Y-1},{"X": X-1, "Y": Y},{"X": X+1, "Y": Y},{"X": X, "Y": Y+1}]
            {
                if (Closed[Near.X, Near.Y] = true)
                    continue
                Open[Near.X, Near.Y] := true, tG := G[X, Y] + 1
                if (IsObject(G[Near.X, Near.Y]) and tG >= G[Near.X, Near.Y])
                    continue
                From[Near.X, Near.Y] := {"X": X, "Y": Y}
                    , G[Near.X, Near.Y] := tG
                    , F[Near.X, Near.Y] := G[Near.X, Near.Y] + this.Estimate_F(Near.X, Near.Y, X2, Y2)
            }
        }
    }

    Estimate_F(X1, Y1, X2, Y2)
    {
        return Abs(X1-X2) + Abs(Y1-Y2)
    }

    Lowest_F_Set(ByRef X, ByRef Y, ByRef F, ByRef Set)
    {
        l := 0x7FFFFFFF
        for tX , element in Set
            for tY, val in element
                if (F[tX, tY] < l)
                    l := F[tX, tY], X := tX, Y := tY
        return l
    }

    From_Path(From, X, Y)
    {
        Path := {}, XY := {"X": X, "Y": Y}
        Path.InsertAt(1, XY)
        while (IsObject(From[XY.X, XY.Y]))
            Path.InsertAt(1, XY:= From[XY.X, XY.Y]) 
        return Path 
    }

    /**
    * @return void
    */
    startAstarTimer()
    {
        this.astarGridElapsed := new _Timer()

        this.deleteAstarTimer()

        fn := this.getAstarTimer()
        SetTimer, % fn, 1000, 99
    }

    ;#Region Getters
    /**
    * @return int
    */
    getOutOfScreenSqms()
    {
        return 2
    }

    /**
    * @return int
    */
    getMaxHorizontalDistance()
    {
        return OldbotSettings.settingsJsonObj.options.verticalSqms + this.getOutOfScreenSqms()
    }

    /**
    * @return int
    */
    getMaxVerticalDistance()
    {
        return OldbotSettings.settingsJsonObj.options.horizontalSqms + this.getOutOfScreenSqms()
    }

    /**
    * @return BoundFunc
    */
    getAstarTimer()
    {
        if (!this.astarTimer) {
            this.astarTimer := this.astarElapsedTimer.bind(this)
        }

        return this.astarTimer
    }   
    ;#Endregion

    ;#Region Setters

    /**
    * @param bool value
    * @return this
    */
    setShowOnScreen(value)
    {
        this.showOnScreen := value

        return this
    }
    ;#Endregion

    ;#Region Predicates
    /**
    * @param _SpecialArea specialArea
    * @return bool
    */
    isWalkable(specialArea)
    {
        if (specialArea.getX() == this.x && specialArea.getY() == this.y) {
            return specialArea.isWalkable()
        }   

        return specialArea.isWalkable() && !specialArea.isChangeFloor()
    }
    ;#Endregion


    ;#Region Guards
    /**
    * @return void
    * @throws Exception
    */
    guardAgainstInvalidCoordinate()
    {
        d := this.getMaxHorizontalDistance()
        if (this.destination.getDistanceX(posx) > d) {
            throw Exception(txt("Coordenada X está muito longe(" d ") do char para andar com rota traçada", "X coordinate is too far(" d ") from the character to walk with traced route"), this.FAIL_COORD_TOO_FAR)
        }

        d := this.getMaxVerticalDistance()
        if (this.destination.getDistanceY(posy) > d) {
            throw Exception(txt("Coordenada Y está muito longe(" d ") do char para andar com rota traçada", "Y coordinate is too far(" d ") from the character to walk with traced route"), this.FAIL_COORD_TOO_FAR)
        }

        try {
            this.destination.guardAgainstNonWalkableSpecialArea()
        } catch e {
            throw Exception(e.Message, this.FAIL_NOT_WALKABLE)
        }

        /**
        if the dest coord is one of the blocked coords by creatures
        */
        ; if (cavebotSystemObj.blockedCoordinatesByCreatures[this.x, this.y, this.z] = true)
        ; throw Exception("Coordinate SQM is blocked by creature")
    }
    ;#Endregion
}