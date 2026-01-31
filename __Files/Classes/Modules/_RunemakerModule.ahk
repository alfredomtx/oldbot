#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Modules\_AbstractModule.ahk

class _RunemakerModule extends _AbstractModule
{
    static IDENTIFIER := "Runemaker"
    static DISPLAY_NAME := "Runemaker"

    static EXE := _RunemakerExe
    static SETTINGS_CLASS := _RunemakerSettings.__Class

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

        functions.Push(_Runemaker)

        return functions
    }

    /**
    * @return void
    */
    onPause()
    {
        _Logger.log(A_ThisFunc)
        ; _Runemaker.onPause()
    }

    /**
    * @return void
    */
    onUnpause()
    {
        _Logger.log(A_ThisFunc)
            new _RunemakerHUD().onUnpause()
    }

    /**
    * @return string
    */
    getWindowTitle()
    {
        return _RunemakerHUD.WINDOW_TITLE
    }

    /**
    * @param _AbstractModuleFunction function
    * @return bool
    */
    isEnabled(function)
    {
        return bool(this.getSettings().get(_AbstractSettings.ENABLED_KEY))
    }

}