#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

/**
* @property _Coordinate pursePosition
*/
class _EquipmentArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "equipmentArea"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @singleton
    */
    __New()
    {
        if (_EquipmentArea.INSTANCE) {
            return _EquipmentArea.INSTANCE
        }

        base.__New(this)

        _EquipmentArea.INSTANCE := this
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

        if (isTibia13()) {
            this.getPursePosition()

            c1 := new _Coordinate(this.pursePosition.getX(), this.pursePosition.getY())
                .subX(75)
            c2 := new _Coordinate(c1.getX(), c1.getY())
                .addX(110)
                .addY(143)
            coordinates := new _Coordinates(c1, c2)
        } else {
            if (OldbotSettings.uncompatibleModule("support")) {
                coordinates := new _WindowArea().getCoordinates()
            } else {
                area := new _StatusBarArea()

                ; try to calculae the equipment area based on the status bar area(done on miracle 7.4 - otc)
                c1 := area.getC1().CLONE()
                    .addX(10)
                    .subY(140)

                c2 := c1.CLONE()
                    .addX(120)
                    .addY(170)

                coordinates := new _Coordinates(c1, c2)
            }
        }

        ; coordinates.debug()
        this.setCoordinates(coordinates)
    }

    /**
    * @abstract
    * @return bool
    */
    isInitialized()
    {
        return _EquipmentArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _EquipmentArea.INITIALIZED := true
    }

    /**
    * purse position is used to calculate the main backpack position to deposit to stash
    * also used in item refill to define the set area
    * @throws
    */
    getPursePosition() {
        _search := new _ImageSearch()
            .setFile(ImagesConfig.purse)
            .setFolder(ImagesConfig.cavebotFolder)
            .setVariation(90)
            .search()

        if (_search.notFound()) {
            msg := txt("Área do set não localizada, certifique-se de que o set(equipamentos) não está minimizado no cliente do Tibia e tente novamente.", "Set area not found, ensure that the set(equipments) is not minimized in the Tibia client try again.")
            ; msgbox_image(msg, "Data\Files\Images\GUI\Others\purse_set.png", 3)
            throw Exception(msg)
        }

        this.pursePosition := new _Coordinate(_search.getX(), _search.getY())
    }
}