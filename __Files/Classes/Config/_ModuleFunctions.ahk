
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_AbstractConfigClass.ahk

class _ModuleFunctions extends _ModuleFunctions.Getters
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    class Getters extends _ModuleFunctions.Setters
    {
        /**
        * @see __Files\Includes\Module Functions\IModuleFunctions.ahk
        * @return array<_AbstractModuleFunction>
        */
        getList()
        {
            static list
            if (list) {
                return list
            }

            classes := {}

            list := {}
            for _, class in classes {
                list[class.IDENTIFIER] := class
            }

            return list
        }
    }

    class Setters extends _ModuleFunctions.Predicates
    {
    }

    class Predicates extends _ModuleFunctions.Factory
    {
    }

    class Factory extends _ModuleFunctions.Base
    {
    }

    class Base extends _AbstractConfigClass
    {
    }
}