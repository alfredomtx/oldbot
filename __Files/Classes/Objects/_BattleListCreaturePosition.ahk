

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

/**
* @property _Coordinate coordinate
*/
class _BattleListCreaturePosition extends _BaseClass
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param int y
    */
    __New(y) {

    }

    /**
    * @param string type
    * @return int
    */
    get() {
        return this["get" type]()
    }
}