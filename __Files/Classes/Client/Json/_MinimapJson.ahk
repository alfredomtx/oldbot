#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ClientJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

class _MinimapJson extends _ClientJson
{
    static INSTANCE

    static DEFAULT_FILE := "mp_otclient.json"

    __New()
    {
        if (_MinimapJson.INSTANCE) {
            return _MinimapJson.INSTANCE
        }

        this.file := StrReplace(OldBotSettings.settingsJsonObj.files.minimap, ".json", "")
        ; if (!this.file) {
        ;     this.file := StrReplace(_MinimapJson.DEFAULT_FILE, ".json", "")
        ; }

        _MinimapJson.INSTANCE := this
    }

    exists()
    {
        return OldBotSettings.settingsJsonObj.files.minimap
    }

    ;#Region Getters
    getFolder()
    {
        return _Folders.JSON_MINIMAP
    }

    getFile()
    {
        return this.file
    }
    ;#EndRegion
}