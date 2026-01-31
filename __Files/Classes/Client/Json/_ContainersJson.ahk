#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ClientJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

class _ContainersJson extends _ClientJson
{
    static INSTANCE

    static DEFAULT_FILE := "crs_otclient.json"

    __New()
    {
        if (_ContainersJson.INSTANCE) {
            return _ContainersJson.INSTANCE
        }

        this.file := StrReplace(OldBotSettings.settingsJsonObj.files.containers, ".json", "")
        if (!this.file) {
            this.file := StrReplace(_ContainersJson.DEFAULT_FILE, ".json", "")
        }

        _ContainersJson.INSTANCE := this
    }

    exists()
    {
        return OldBotSettings.settingsJsonObj.files.containers
    }

    ;#Region Getters
    getFolder()
    {
        return _Folders.JSON_CONTAINERS
    }

    getFile()
    {
        return this.file
    }
    ;#EndRegion
}