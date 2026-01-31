global posx
global posy
global posz

class _CharCoordinate extends _MapCoordinate
{
    static SHARED_FOLDER := "vm"
    static MEMORY_FILE := "data.txt"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    GET()
    {
        this.checkinjectClientMemory()

        posx := MemoryManager.readPosX()
        posy := MemoryManager.readPosY()

        if (OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection) {
            try {
                posz := this.getMinimapFloorLevelMemory()
            } catch e {
                _Logger.exception(e, A_ThisFunc)

                throw e
            }
        }

        this.checkIfCharCoordWasBlocked()

        return new this(posx, posy, posz, 0, 0)
    }

    readFromFile()
    {
        folder := A_MyDocuments "\" this.SHARED_FOLDER
        path := folder "\"  this.MEMORY_FILE
        _Validation.folderExists("folder", folder)
        _Validation.fileExists("path", path)

        FileRead, data, % path
        array := StrSplit(data, "|")

        title := array[1]
        x := array[2]
        y := array[3]
        z := array[4]

        return new this(x, y, z, 0, 0)
    }

    /**
    * @return int
    */
    getMinimapFloorLevelMemory()
    {
        static triedToGetNewMemory

        this.checkinjectClientMemory()

        level := MemoryManager.readPosZ()
        invalidFloor := this.isInvalidFloor(level)
        if (!invalidFloor) {
            return level
        }

        if (triedToGetNewMemory) {
            return
        }

        triedToGetNewMemory := true
        if (tryToGetNewMemoryAddresses() = true) {
            level := MemoryManager.readPosZ()
            invalidFloor := this.isInvalidFloor(level)
        }

        this.guardAgainstInvalidMemoryCoordinates(level, invalidFloor)

        return level
    }

    guardAgainstInvalidMemoryCoordinates(level, invalidFloor)
    {
        if (invalidFloor = true) {
            _CharCoordinate.throwInvalidMemoryCoordinatesException(level)
        }

        if (posz == 0 && posy == 0 && level == 0) {
            _CharCoordinate.throwInvalidMemoryCoordinatesException(level)
        }

    }

    throwInvalidMemoryCoordinatesException(level)
    {
        if (IsMemoryCoordinates()) {
            throw Exception("(2) " txt("Coordenadas invalidas: " posx "," posy "," level ".`n`nO cliente do Tibia atualizou seus endereços de memória e será necessário uma atualização nos arquivos do OldBot, por favor contate o suporte.", "Invalid coordinates: " posx "," posy "," level ".`n`nThe Tibia client has updated its memory addressses and an update in OldBot's files will be needed, please contact the support.") "`n`n[ Info: ] " "`nIdentifier: " TibiaClient.getClientIdentifier(true) "`nExe name: " TibiaClientExeName "`nWindow: " TibiaClientTitle)

        } else {
            throw Exception("(2) " txt("Coordenadas invalidas: " posx "," posy "," level "`nReabra o bot e o cliente do Tibia e tente novamente.`n`nCaso esteja com a opção de coordenadas da memória do cliente marcada, o cliente do Tibia atualizou e é necessário adaptar novamente o bot, por favor contate o suporte.", "Invalid coordinates: " posx "," posy "," level "`nPlease reopen the bot and the tibia client and try again.`n`nIn case the option of coordinates from the client memory is checked, the Tibia client has been updated and it is needed to adapt again the bot, please contact the support.") "`n`n[ Info: ] " "`nIdentifier: " TibiaClient.getClientIdentifier(true) "`nExe name: " TibiaClientExeName "`nWindow: " TibiaClientTitle)
        }
    }

    /**
    * @return bool
    */
    isInvalidFloor(level := "")
    {
        invalidFloor := (level < 0 OR level > 15)
        ; if (posx != "" && !invalidFloor) {
        ;     return posx = 0
        ; }

        return invalidFloor
    }

    /**
    * @return void
    */
    checkIfCharCoordWasBlocked()
    {
        if (cavebotSystemObj.blockedCoordinates[posx, posy, posz])
            cavebotSystemObj.blockedCoordinates[posx][posy].Delete(posz)

        if (cavebotSystemObj.blockedCoordinatesByCreatures[posx, posy, posz])
            cavebotSystemObj.blockedCoordinatesByCreatures[posx][posy].Delete(posz)
    }

    /**
    * @return void
    */
    checkinjectClientMemory()
    {
        static validated
        if (validated) {
            return
        }

        classLoaded("MemoryManager", MemoryManager)
        if (!IsObject(MemoryManager.mem)) {
            MemoryManager.injectClientMemory()
        }

        validated := true
    }
}