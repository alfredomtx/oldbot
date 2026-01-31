#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ClientJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

class _LootingJson extends _ClientJson
{
    static INSTANCE

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        if (_LootingJson.INSTANCE) {
            return _LootingJson.INSTANCE
        }

        this.file := StrReplace(OldBotSettings.settingsJsonObj.files.looting, ".json", "")

        _LootingJson.INSTANCE := this
    }


    ;#Region Getters
    getFolder()
    {
        return _Folders.JSON_LOOTING
    }

    getFile()
    {
        return this.file
    }
    ;#EndRegion
}