#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_AbstractExecutablesConfig.ahk

class _Executables extends _Executables.Getters
{
    static RANDOMIZE_NAMES := false

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    class Getters extends _Executables.Setters
    {
        /**
        * @see __Files\Includes\Executables\IExecutables.ahk
        * @return array<_AbstractExe>
        */
        getList()
        {
            static list
            if (list) {
                return list
            }

            classes := {}
            classes.Push(_AlarmSingleExe)
            classes.Push(_AlertsExe)
            classes.Push(_CavebotExe)
            classes.Push(_FishingExe)
            classes.Push(_FullLightExe)
            classes.Push(_HealingExe)
            classes.Push(_HotkeysExe)
            classes.Push(_ItemRefillExe)
            classes.Push(_MarketExe)
            classes.Push(_OldBotExe)
            classes.Push(_PersistentExe)
            classes.Push(_ReconnectExe)
            classes.Push(_RunemakerExe)
            classes.Push(_SioFriendExe)
            classes.Push(_SmartExitExe)
            classes.Push(_SupportExe)
            ; classes.Push(_TargetingExe)
            ; classes.Push(this.validateClass("_TargetingExe", _TargetingExe, _AbstractExe))

            list := {}
            for _, class in classes {
                list[class.NAME] := class
            }

            return list
        }
    }

    class Setters extends _Executables.Predicates
    {
    }

    class Predicates extends _Executables.Factory
    {
    }

    class Factory extends _Executables.Base
    {
    }

    class Base extends _AbstractExecutablesConfig
    {
    }
}