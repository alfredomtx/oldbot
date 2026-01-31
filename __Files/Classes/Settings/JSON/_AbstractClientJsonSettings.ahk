#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\JSON\_AbstractJsonSettings.ahk

class _AbstractClientJsonSettings extends _AbstractJsonSettings
{
    /**
    * @return object
    */
    getObject()
    {
        identifier := this.getIdentifier()
        return %identifier%ClientObj
    }

    /**
    * @return void
    */
    save()
    {
        /**
        * @TODO implement correctly, not working as expected to load keys due to the shitty implmentatin of OldBotSettings.settingsJsonObj
        */
        identifier := this.getIdentifier()
        settingsJson[identifier] := _Arr.merge(OldBotSettings.settingsJsonObj[identifier], %identifier%ClientObj)
        settingsJson.save(true)
    }
}