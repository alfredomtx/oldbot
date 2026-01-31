#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ClientJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

class _TargetingJson extends _ClientJson
{
    static INSTANCE

    __New()
    {
        if (_TargetingJson.INSTANCE) {
            return _TargetingJson.INSTANCE
        }

        this.file := StrReplace(OldBotSettings.settingsJsonObj.files.targeting, ".json", "")

        _TargetingJson.INSTANCE := this
    }

    ;#Region Getters
    getFolder()
    {
        return _Folders.JSON_TARGETING
    }

    getFile()
    {
        return this.file
    }
    ;#EndRegion
}