#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_GUI.ahk

class _SpecialAreasHUD extends _BaseClass
{
    static FOLDER := "Data"
    static MAIN_FILE := "special_areas.json"
    static SECONDARY_FILE := "special_areas_auto.json"
    static IMAGES_FILE := "special_areas_images.json"

    static DEFAULT_TYPE := _SpecialArea.TYPE_BLOCKED

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @return void
    */
    showSqms()
    {
        for _, data in _SpecialAreas.load() {
            area := _SpecialArea.fromArray(data)
            area.toMapCoordinate().showOnScreen(area.resolveColor(), area.resolveHudText())
        }
    }

    /**
    * @return void
    */
    selectSqms()
    {
        timer := new _Timer()
        if (!this.prepareSqmSelection()) {
            return
        }

        this.charX := posx
        this.charY := posy
        this.charZ := posz

        this.deleteCharMovedTimer()

        verticalIndex := 0
        horizontalIndex := 0
        initialX := posx - this.horizontalSqms
        initialY := posy - this.verticalSqms

        z := posz
        mapCoord := new _MapCoordinate(initialX, initialY, posz)

        Loop, % this.resolveVerticalSqms() {
            y := initialY + verticalIndex

            Loop, % this.resolveHorizontalSqms() {
                x := initialX + horizontalIndex

                mapCoord := new _MapCoordinate(x, y, z)
                area := _SpecialAreas.get(x, y, z)
                if (!area) {
                    area := this.specialAreaFromMapColor(mapCoord)
                }

                if (area) {
                    color := area.resolveColor()
                    mapCoord.showOnScreen(color ? color : _SpecialArea.COLOR_NONE, area.resolveHudText(area.getType()))
                } 

                if (!this.coordCache[z, x, y]) {
                    this.coordCache[z, x, y] := mapCoord
                }

                horizontalIndex++
            }

            horizontalIndex := 0
            verticalIndex++
        }

        this.afterShowSqms()

        _Logger.log(A_ThisFunc, "Elapsed: " timer.elapsed() "ms")
    }

    specialAreaFromMapColor(mapCoord)
    {
        action := new _CoordinatePixelCondition(mapCoord.getX(), mapCoord.getY(), mapCoord.getZ())
        isStair := action.isStair()
        if (isStair) {
            return _SpecialArea.fromMapCoordinate(mapCoord)
                .setType(_SpecialArea.TYPE_CHANGE_FLOOR_MAP_COLOR)
        }

        action.setParam("allowStair", false)

        walkable := action.setParam("allowStair", false)
            .handle()

        if (walkable) {
            return 
        }

        return _SpecialArea.fromMapCoordinate(mapCoord)
            .setWalkable(false)
            .setType(_SpecialArea.TYPE_BLOCKED_MAP_COLOR)
    }

    /**
    * @return void
    */
    afterShowSqms()
    {
        ; SplashTextOn, 270,,  % "Right Click: add/remove | Enter: save | Esc: cancel"

        this.hotkey:= this.sqmClicked.bind(this)
        this.esc := this.escPressed.bind(this)
        this.enter := this.enterPressed.bind(this)

        fn := this.getCharMovedTimer()
        SetTimer, % fn, 100

        this.toggleHotkeys("On") 
    }

    /**
    * @return void
    */
    deleteCharMovedTimer()
    {
        fn := this.getCharMovedTimer()
        SetTimer, % fn, Delete
    }

    /**
    * @return void
    */
    checkCharMoved()
    {
        _CharCoordinate.GET()
        if (this.charX != posx || this.charY != posy || this.charZ != posz) {
            this.charX := posx
            this.charY := posy
            this.charZ := posz

            this.selectSqms()
        }
    }

    /**
    * @return bool
    */
    prepareSqmSelection()
    {
        static gameWindowArea

        if (!TibiaClient.getClientArea()) {
            return false
        }

        if (!gameWindowArea) {
            gameWindowArea := new _GameWindowArea()
        }

        _MapCoordinate.HIDE_ALL()

        if (!this.coordsCache) {
            this.coordsCache := {}
        }

        ; setSystemCursor("IDC_HAND")
        _CharCoordinate.GET()

        this.verticalSqms := OldbotSettings.settingsJsonObj.options.horizontalSqms
        this.horizontalSqms := OldbotSettings.settingsJsonObj.options.verticalSqms

        this.removedAreas := {}
        this.changedAreas := {}
        this.addedAreas := {}

        if (_Ini.read(_SpecialAreas.INI_NEW_AUTO_DETECTED_KEY, _SpecialAreas.INI_TEMP_SECTION)) {
            _Ini.delete(_SpecialAreas.INI_NEW_AUTO_DETECTED_KEY, _SpecialAreas.INI_TEMP_SECTION)
            _SpecialAreas.load(force := true)
        }

            new _SpecialAreasHudControlsGUI().open()

        return true
    }

    /**
    * @return void
    */
    sqmClicked()
    {
        if (!coord := _MapCoordinate.FROM_MOUSE_POS()) {
            return
        }   

        x := coord.getX(), y := coord.getY(), z := coord.getZ()

        area := _SpecialAreas.get(x, y, z)
        newArea := false
        if (!area) {
            area := _SpecialArea.fromMapCoordinate(coord)
            area.setType(_SpecialAreasHUD.DEFAULT_TYPE)
            this.addedAreas.Push(area)

            newArea := true
        }

        if (GetKeyState("Ctrl")) {
            this.setSpecialAreaType(coord, area)
            return
        }

        this.changedAreas.Push(area.clone())

        if (GetKeyState("Shift")) {
            this.removeSpecialArea(coord, area)
            return
        }


        this.destroyCachedCoord(x, y, z)

        if (!newArea) {
            area.toggleType()
        }

        coord.destroyOnScreen()
        coord.showOnScreen(area.resolveColor(), area.resolveHudText(area.getType()))
        this.coordCache[z, x, y] := coord

        _SpecialAreas.add(area, false, addToMain := true)
    }

    destroyCachedCoord(x, y, z)
    {
        cache := this.coordCache[z, x, y]
        cache.destroyOnScreen()
    }

    /**
    * @param _MapCoordinate coord
    * @param _SpecialArea area
    * @return void
    */
    removeSpecialArea(coord, area)
    {
        _SpecialAreas.softDeleteArea(area, false)
        ; this.removedAreas.Push(area)

        this.destroyCachedCoord(coord.z, coord.x, coord.y)
        coord.destroyOnScreen()
        coord.showOnScreen(area.resolveColor(), area.resolveHudText(area.getType()))
    }

    /**
    * @param _MapCoordinate coord
    * @param _SpecialArea area
    * @return void
    */
    setSpecialAreaType(coord, area)
    {
            new _SpecialAreaTypeGUI()
            .setData(coord, area)
            .open()
    }

    /**
    * @param string state
    * @return void
    */
    toggleHotkeys(state)
    {
        fn := this.esc
        Hotkey, Esc, % fn, % state
        fn := this.enter
        Hotkey, Enter, % fn, % state
        fn := this.hotkey
        Hotkey, Space, % fn, % state
        Hotkey, +Space, % fn, % state
        Hotkey, ^Space, % fn, % state
    }

    /**
    * @return void
    */
    enterPressed()
    {
        this.deleteCharMovedTimer()
        _SpecialAreas.saveAll()
        this.destroyHud()
    }

    /**
    * @return void
    */
    destroyHud()
    {
        ; restoreCursor()
        this.toggleHotkeys("Off") 
            new _SpecialAreasHudControlsGUI().close()
            new _SpecialAreaTypeGUI().close()

        ; fn := this.charCoordTimer
        ; SetTimer, % fn, Delete

        _MapCoordinate.HIDE_ALL()
        this.coordsCache := {}
        this.removedAreas := {}
        this.changedAreas := {}
        this.addedAreas := {}
    }

    /**
    * @return void
    */
    escPressed()
    {
        this.deleteCharMovedTimer()

        for _, area in this.removedAreas {
            _SpecialAreas.add(area, false, addToMain := true)
            if (area.getType() == _SpecialArea.TYPE_BLOCKED_AUTO_DETECTED) {
                _SpecialAreas.addAutoDetected(area, save := false, writeIni := false)
            }
        }

        for _, area in this.changedAreas {
            _SpecialAreas.add(area, false, addToMain := true)
        }

        for _, area in this.addedAreas {
            _SpecialAreas.deleteArea(area, false)
        }

        this.destroyHud()
    }

    /**
    * @return int
    */
    resolveVerticalSqms()
    {
        return (OldbotSettings.settingsJsonObj.options.horizontalSqms * 2) + 1
    }

    /**
    * @return int
    */
    resolveHorizontalSqms()
    {
        return (OldbotSettings.settingsJsonObj.options.verticalSqms * 2) + 1
    }

    ;#Region Getters
    /**
    * @return BoundFunc
    */
    getCharMovedTimer()
    {
        static fn
        if (fn) {
            return fn
        }

        fn := this.checkCharMoved.bind(this)

        return fn
    }
    ;#Endregion
}