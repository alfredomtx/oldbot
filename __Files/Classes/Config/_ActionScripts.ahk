#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_AbstractConfigClass.ahk

class _ActionScripts extends _ActionScripts.Getters
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    class Getters extends _ActionScripts.Setters
    {
        /**
        * @return array<_AbstractExe>
        */
        getList()
        {
            static list
            if (list) {
                return list
            }

            classes := {}
            classes.Push(this.validateClass("_DepositItemsAction", _DepositItemsAction, _AbstractActionScript))
            classes.Push(this.validateClass("_IsBackpackOpenedAction", _IsBackpackOpenedAction, _AbstractActionScript))
            classes.Push(this.validateClass("_OpenDepotAction", _OpenDepotAction, _AbstractActionScript))
            classes.Push(this.validateClass("_OpenDepotAroundAction", _OpenDepotAroundAction, _AbstractActionScript))
            ; classes.Push(this.validateClass("_GoToLabelAction", _GoToLabelAction, _AbstractActionScript))
            ; classes.Push(this.validateClass("_ImageSearchWait", _ImageSearchWait, _AbstractActionScript))
            ; classes.Push(this.validateClass("_SellItemsNpc", _SellItemsNpc, _AbstractActionScript))
            ; classes.Push(this.validateClass("_SetSettingAction", _SetSettingAction, _AbstractActionScript))

            list := {}
            for _, class in classes {
                list[class.IDENTIFIER] := class
            }

            return list
        }
    }

    class Setters extends _ActionScripts.Predicates
    {
    }

    class Predicates extends _ActionScripts.Factory
    {
    }

    class Factory extends _ActionScripts.Base
    {
    }

    class Base extends _AbstractConfigClass
    {
    }
}