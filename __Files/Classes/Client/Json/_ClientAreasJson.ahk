#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ClientJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

class _ClientAreasJson extends _ClientJson
{
    static INSTANCE

    __New()
    {
        if (_ClientAreasJson.INSTANCE) {
            return _ClientAreasJson.INSTANCE
        }

        this.file := StrReplace(OldBotSettings.settingsJsonObj.files.clientAreas, ".json", "")

        _ClientAreasJson.INSTANCE := this
    }


    ;#Region Getters
    getFolder()
    {
        return _Folders.JSON_CLIENT_AREAS
    }

    getFile()
    {
        return this.file
    }
    ;#EndRegion
}