

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\_AbstractAction.ahk

class _UseSqm extends _AbstractAction
{
    __Call(method, args*)
    {
        methodParams(this[method], method, args)
    }

    /**
    * @param _Coordinate sqmPosition
    * @param ?string action
    * @return bool
    * @throws
    */
    __New(sqmPosition, action := "")
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _UseMenuSearch()
        }

        try {
            this.validations()
            _Validation.isCoordinate("sqmPosition", sqmPosition)

            switch action {
                case "ladder":
                    _Logger.log("Cavebot", "Clicking on the ladder SQM")
                case "door":
                    _Logger.log("Cavebot", "Opening door on SQM")
                default:
                    _Logger.log("Cavebot", "Use on SQM")
            }

            Loop, 3 {
                if (sqmPosition.clickOnUse()) {
                    return true
                }

                Sleep, 200
            }

            Send("Esc")

            _Logger.error("""Use"" option not found", A_ThisFunc)
            return false
        } catch e {
            this.handleException(e, this)
            throw e
        }
    }

    /**
    * @abstract
    * @throws
    */
    validations()
    {
        static validated
        if (validated) {
            return
        }

        validated := true

        classLoaded("CavebotSystem", CavebotSystem)
    }
}