

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\_AbstractAction.ahk

class _IsBattleListEmpty extends _AbstractAction
{
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @return bool
    */
    __New()
    {
        try {
            this.validations()

            found := new _SearchBattleList().found()

            return new _TargetingJson().get("battleListSetup.emptyBattleListInvertResult", false) ? !found : found
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

        classLoaded("TargetingSystem", TargetingSystem)
    }
}