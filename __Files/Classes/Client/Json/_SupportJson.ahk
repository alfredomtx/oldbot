#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ClientJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

class _SupportJson extends _ClientJson
{
    static INSTANCE

    __New()
    {
        if (_SupportJson.INSTANCE) {
            return _SupportJson.INSTANCE
        }

        this.file := StrReplace(OldBotSettings.settingsJsonObj.files.support, ".json", "")

        _SupportJson.INSTANCE := this
    }

    ;#Region Getters
    getFolder()
    {
        return _Folders.JSON_SUPPORT
    }

    getFile()
    {
        return this.file
    }
    ;#EndRegion
}