
class _CavebotTrappedEvent extends _BaseClass
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    handle()
    {
        /**
        if is the first time that setpath failed, we can enable the targeting to attack creatures around that blocked the way
        and also reset the blocked coords by them
        */
        CavebotSystem.runIsTrappedAction()
        targetingSystemObj.isTrapped := true

        if (targetingSystemObj.targetingDisabled OR targetingSystemObj.targetingIgnored.active) {
            /**
            delete timer of NoCreatureFound, that will probably be running when walking through
            creatures that are checked onlyIfTrapped
            */
            TargetingSystem.deleteIgnoredTargetingTimer()
            writeCavebotLog("Cavebot", txt("Habilitando Targeting para matar as criaturas em volta", "Enabling Targeting to kill creatures around") )
            Sleep, 1000 ; to give time to the targeting to kill the creatures around???
        }
    }
}