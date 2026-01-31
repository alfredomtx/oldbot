#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_ClientJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

class _CavebotJson extends _ClientJson
{
    static INSTANCE

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        if (_CavebotJson.INSTANCE) {
            return _CavebotJson.INSTANCE
        }

        this.file := StrReplace(OldBotSettings.settingsJsonObj.files.cavebot, ".json", "")

        _CavebotJson.INSTANCE := this
    }


    ;#Region Getters
    getFolder()
    {
        return _Folders.JSON_CAVEBOT
    }

    getFile()
    {
        return this.file
    }
    ;#EndRegion
}