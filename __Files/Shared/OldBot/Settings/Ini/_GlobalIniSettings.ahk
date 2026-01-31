#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Ini\_AbstractIniSettings.ahk

class _GlobalIniSettings extends _AbstractIniSettings
{
    static INSTANCE
    static IDENTIFIER := "global"
    static SECTION_DATA := "data"
    static FILE_DIR := A_AppData "\OldBot"
    static FILE_PATH := _GlobalIniSettings.FILE_DIR "\global_settings.ini"

    __New()
    {
        if (_GlobalIniSettings.INSTANCE) {
            return _GlobalIniSettings.INSTANCE
        }

        base.__New()

        if (!FileExist(_GlobalIniSettings.FILE_DIR)) {
            FileCreateDir, % _GlobalIniSettings.FILE_DIR
        }

        _GlobalIniSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _GlobalIniSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes["openedByLauncher"] := new _DefaultBoolean(false, "openedByLauncher")
        this.attributes["reloading"] := new _DefaultBoolean(false, "reloading")
        this.attributes["injectedClient"] := new _DefaultString("", "injectedClient")
        this.attributes["injectedClient2"] := new _DefaultString("", "injectedClient2")
        this.attributes["injectedClient3"] := new _DefaultString("", "injectedClient3")
    }

    /**
    * @param string key
    */
    read(key)
    {
        return _Ini.read(key, this.SECTION_DATA, "", this.FILE_PATH)
    }

    /**
    * @param string key
    * @param mixed value
    * @return void
    */
    write(key, value)
    {
        _Ini.write(key, value, this.SECTION_DATA, this.FILE_PATH)
    }

    /**
    * @param string key
    */
    delete(key)
    {
        return _Ini.delete(key, this.SECTION_DATA, this.FILE_PATH)
    }
}