#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_AbstractConfigClass.ahk

class _IniSettings extends _AbstractConfigClass
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return array<_AbstractIniSettings>
    */
    getList()
    {
        static list
        if (list) {
            return list
        }

        classes := {}

        ;#region Shared
        classes.Push(this.validateClass("_CavebotIniSettings", _CavebotIniSettings, _AbstractIniSettings))
        classes.Push(this.validateClass("_MarketIniSettings", _MarketIniSettings, _AbstractIniSettings))
        classes.Push(this.validateClass("_MarketItemSettings", _MarketItemSettings, _AbstractIniSettings))
        classes.Push(this.validateClass("_SpecialAreasIniSettings", _SpecialAreasIniSettings, _AbstractIniSettings))
        ;#endregion

        list := {}
        for _, class in classes {
            list[class.IDENTIFIER] := class
        }

        return list
    }

}