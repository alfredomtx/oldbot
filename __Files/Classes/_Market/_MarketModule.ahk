
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Modules\_AbstractModule.ahk

class _MarketModule extends _AbstractModule
{
    static IDENTIFIER := "market"
    static DISPLAY_NAME := "Market"

    static EXE := _MarketExe
    static SETTINGS_CLASS := _MarketSettings.__Class

    /**
    * @abstract
    */
    functions()
    {
        static functions
        if (functions) {
            return functions
        }

        functions := {}

        functions.Push(_Market)


        return functions
    }

    /**
    * @param _AbstractModuleFunction function
    * @return bool
    */
    isEnabled(function)
    {
        ; if (!A_IsCompiled) {
        ;     return true
        ; }

        return bool(this.getSettings().get(_AbstractSettings.ENABLED_KEY))
    }

}
