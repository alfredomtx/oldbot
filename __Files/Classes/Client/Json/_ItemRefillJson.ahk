#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ClientJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

class _ItemRefillJson extends _ClientJson
{
    static INSTANCE

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        if (_ItemRefillJson.INSTANCE) {
            return _ItemRefillJson.INSTANCE
        }

        this.file := StrReplace(OldBotSettings.settingsJsonObj.files.itemRefill, ".json", "")

        _ItemRefillJson.INSTANCE := this
    }


    ;#Region Getters
    getFolder()
    {
        return _Folders.JSON_ITEM_REFILL
    }

    getFile()
    {
        return this.file
    }
    ;#EndRegion
}