#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ClientJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

class _ClientMenusJson extends _ClientJson
{
    static INSTANCE

    __New()
    {
        if (_ClientMenusJson.INSTANCE) {
            return _ClientMenusJson.INSTANCE
        }

        this.file := StrReplace(OldBotSettings.settingsJsonObj.files.clientMenus, ".json", "")

        _ClientMenusJson.INSTANCE := this
    }

    exists()
    {
        return OldBotSettings.settingsJsonObj.files.clientMenus
    }

    ;#Region Getters
    getFolder()
    {
        return _Folders.JSON_CLIENT_MENUS
    }

    getFile()
    {
        return this.file
    }
    ;#EndRegion
}