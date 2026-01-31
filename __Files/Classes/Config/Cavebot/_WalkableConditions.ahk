#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_AbstractConfigClass.ahk

class _WalkableConditions extends _AbstractConfigClass
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return array<_AbstractWalkableCondition>
    */
    getList()
    {
        static list
        if (list) {
            return list
        }

        classes := {}

        classes.Push(this.validateClass("_ClosedByCreatureCondition", _ClosedByCreatureCondition, _AbstractWalkableCondition))
        classes.Push(this.validateClass("_CavebotWalkerCondition", _CavebotWalkerCondition, _AbstractWalkableCondition))

        list := {}
        for _, class in classes {
            list[class.IDENTIFIER ? class.IDENTIFIER : class.__Class] := class
        }

        return list
    }

}