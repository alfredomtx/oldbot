
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_AbstractConfigClass.ahk

class _Modules extends _Modules.Getters
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    class Getters extends _Modules.Setters
    {
        /**
        * @see __Files\Includes\Module Functions\IModuleFunctions.ahk
        * @return array<_AbstractModule>
        */
        getList()
        {
            static list
            if (list) {
                return list
            }

            classes := {}
            classes.Push(_MarketModule)

            list := {}
            for _, class in classes {
                list[class.IDENTIFIER] := class
            }

            return list
        }
    }

    class Setters extends _Modules.Predicates
    {
    }

    class Predicates extends _Modules.Factory
    {
    }

    class Factory extends _Modules.Base
    {
    }

    class Base extends _AbstractConfigClass
    {
    }
}