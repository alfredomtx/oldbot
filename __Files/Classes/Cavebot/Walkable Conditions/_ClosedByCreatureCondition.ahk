
#Include, C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Cavebot\Walkable Conditions\_AbstractWalkableCondition.ahk

class _ClosedByCreatureCondition extends _AbstractWalkableCondition
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    handle()
    {
        if (cavebotSystemObj.blockedCoordinatesByCreatures[this.x, this.y, this.z]) {
            return false
        }

        return true
    }
}