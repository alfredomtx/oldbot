#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ClientJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

class _SettingsJson extends _ClientJson
{
    static INSTANCE

    static DEFAULT_FILE := "settings.json"
    static TEMPLATE_FILE := "template_tibia14.json"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        if (_Settingsson.INSTANCE) {
            return _SettingsJson.INSTANCE
        }

        IniRead, DefaultClientJsonProfile, %DefaultProfile%, client, DefaultClientJsonProfile, %A_Space%
        /**
        Auto select the client according to the DefaultClientJsonProfileProfile
        */
        settingsFile := _SettingsJson.DEFAULT_FILE
        if (DefaultClientJsonProfile != "" && InStr(DefaultClientJsonProfile, ".json")) {
            settingsFile := DefaultClientJsonProfile
        }

        this.file := this.removeExtension(settingsFile)

        _SettingsJson.INSTANCE := this
    }

    removeExtension(value)
    {
        return StrReplace(value, ".json", "")
    }

    loadDefault()
    {
        IniWrite, % _SettingsJson.DEFAULT_FILE, %DefaultProfile%, client, DefaultClientJsonProfile

        _SettingsJson.INSTANCE := ""

        return new this().load()
    }


    /**
    * Creates a new settings file from the template and sets the memory identifier
    * @param {string} clientName - The memory identifier for the Tibia client
    * @returns {void}
    */
    addNew(clientName, fileName)
    {
        data := _Json.load(_Folders.JSON "\" _SettingsJson.TEMPLATE_FILE)
        data.tibiaClient.memoryIdentifier := clientName

        file := new JSONFile(_Folders.JSON "\" fileName)
        file.Fill(data)
        file.save(true)
        file := ""
    }

    ;#Region Getters
    getFolder()
    {
        return _Folders.JSON
    }

    getFile()
    {
        return this.file
    }

    getFileWithExtension()
    {
        return this.file ".json"
    }
    ;#EndRegion
}