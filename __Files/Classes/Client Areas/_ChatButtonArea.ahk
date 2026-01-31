#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _ChatButtonArea extends _AbstractClientArea
{
    static INSTANCE
    static INITIALIZED := false
    static NAME := "chatButtonArea"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @singleton
    */
    __New()
    {
        if (_ChatButtonArea.INSTANCE) {
            return _ChatButtonArea.INSTANCE
        }

        base.__New(this)

        _ChatButtonArea.INSTANCE := this
    }

    /**
    * @abstract
    * @throws
    */
    beforeSetupValidations()
    {
        classLoaded("_ChatArea", _ChatArea)
        _Validation.empty("OldBotSettings.settingsJsonObj.clientFeatures.chatOnOff", OldBotSettings.settingsJsonObj.clientFeatures.chatOnOff)
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

        if (!OldBotSettings.settingsJsonObj.clientFeatures.chatOnOff) {
            this.setCoordinates(new _WindowArea().getCoordinates())
            return
        }

        chatArea := new _ChatArea()

        chatButtonWidth := 68
        chatButtonHeight := 20

        if (isTibia13()) {
            c1 := new _Coordinate(chatArea.getX2(), chatArea.getY2())
                .subX(chatButtonWidth)
                .subY(2)
            c2 := new _Coordinate(chatArea.getX2(), c1.getY())
                .addY(chatButtonHeight)
        } else {
            c1 := new _Coordinate(chatArea.getX1(), chatArea.getY1())
            c2 := new _Coordinate(chatArea.getX2(), chatArea.getY2())
        }

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
        return _ChatButtonArea.INITIALIZED
    }

    /**
    * @abstract
    * @return void
    */
    setInitialized()
    {
        _ChatButtonArea.INITIALIZED := true
    }
}