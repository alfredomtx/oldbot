#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_SupportJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ClientAreasJson.ahk

class _MainBackpackArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "mainBackpackArea"

    static CONTAINER_WIDTH := 34
    static CONTAINER_HEIGHT := 34

    /**
    * @singleton
    */
    __New()
    {
        if (_MainBackpackArea.INSTANCE) {
            return _MainBackpackArea.INSTANCE
        }

        base.__New(this)

        _MainBackpackArea.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    * @throws
    */
    setupArea()
    {
        if (!_ContainersJson.exists()) {
            return this.getOpenedBackpackArea()
        }

        width := this.clientJson().get("backpack.areaSetup.width", 176)
        height := this.clientJson().get("backpack.areaSetup.height", 212)
        offsetX := this.clientJson().get("backpack.areaSetup.offsets.x", -30)
        offsetY := this.clientJson().get("backpack.areaSetup.offsets.y", 0)


        bp := this.findMainBackpack()

        c1 := bp.getResult()
            .addX(offsetX)
            .addY(offsetY)
        ; if (slots = 5) {
        ;     c1.subY(50)
        ; }

        c2 := c1.CLONE()
            .addX(width)
            .addY(height)


        ; if (slots = 5) {
        ;     c2.addX(24)
        ; }

        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)

        if (this.clientJson().get("backpack.areaSetup.debug")) {
            this.debug()
        }
    }

    getOpenedBackpackArea()
    {
        size := 38
        width := 4 * size
        height := (OldBotSettings.settingsJsonObj.options.containers.widthInSlots = 5 ? 4 : 5) * size

        backpackImage := _ItemsHandler.resolveMainBackpack()
        isWordBackpack := _ItemsHandler.isWordBackpack(backpackImage)

        bp := this.findMainBackpack()
        bitmap := bp.getImageBitmap()

        c1 := bp.getResult()

        if (isWordBackpack) {
            c1.subX(24)
        }

        c2 := c1.CLONE()
            .addX(width)
            .addX(10)
            .addY(height)
            .addY(bitmap.getHeight())
            .addY(5)


        if (OldBotSettings.settingsJsonObj.options.containers.widthInSlots = 5) {
            c2.addX(24)
            c2.subY(10)
        }

        coordinates := new _Coordinates(c1, c2)

        this.setCoordinates(coordinates)

        if (this.clientJson().get("backpack.areaSetup.debug")) {
            this.debug()
        }
    }


    findMainBackpack()
    {
        return _ItemsHandler.findBackpack(_ItemsHandler.resolveMainBackpack(), new _SideBarsArea())
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _MainBackpackArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _MainBackpackArea.INITIALIZED := true
    }

    /**
    * @abstract
    * @return void
    */
    destroyInstance()
    {
        _MainBackpackArea.INSTANCE := ""
        _MainBackpackArea.INITIALIZED := false
    }


    /**
    * @abstract
    * @return _ClientJson
    */
    clientJson()
    {
        return new _ContainersJson()
    }
}