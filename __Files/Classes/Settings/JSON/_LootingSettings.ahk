#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\JSON\_AbstractJsonSettings.ahk

class _LootingSettings extends _AbstractJsonSettings
{
    static INSTANCE
    static IDENTIFIER := "looting"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        if (_LootingSettings.INSTANCE) {
            return _LootingSettings.INSTANCE
        }

        base.__New()

        _LootingSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _LootingSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes.lootingHotkey := new _DefaultValue()
        this.attributes[i := "dontLootAroundIfFastManualLootingFails"] := new _DefaultBoolean(false, i)

        this.lootingMethod()
    }

    lootingMethod()
    {
        if (isTibia13()) {
            this.attributes.lootingMethod := new _DefaultEnum("Click around", ["Click around", "Press hotkey"])
        } else {
            defaultValue := "Click around"
            if (OldbotSettings.settingsJsonObj.settings.looting.defaultLootingMethod != "") {
                defaultValue := OldbotSettings.settingsJsonObj.settings.looting.defaultLootingMethod
            }

            this.attributes.lootingMethod := new _DefaultEnum(defaultValue, ["Click around", "Click on the item", "Press hotkey"])
        }

        this.attributes.lootingMethod.setIdentifier("lootingMethod")
    }
}