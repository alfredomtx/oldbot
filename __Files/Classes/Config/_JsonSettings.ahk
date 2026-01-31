#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_AbstractConfigClass.ahk

class _JsonSettings extends _AbstractConfigClass
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

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
        classes.Push(_CavebotSettings)
        classes.Push(_HealingSettings)
        classes.Push(_MarketSettings)
        classes.Push(_LootingSettings)
        classes.Push(_NavigationSettings)
        classes.Push(_ReconnectSettings)
        classes.Push(_SupportSettings)
        classes.Push(_SioSettings)
        classes.Push(_TargetingSettings)

        list := {}
        for _, class in classes {
            if (!class) {
                continue
            }

            list[class.IDENTIFIER] := class
        }

        return list
    }
}