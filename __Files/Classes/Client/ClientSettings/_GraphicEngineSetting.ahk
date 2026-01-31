#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\ClientSettings\_Tibia13ClientSetting.ahk

class _GraphicEngineSetting extends _Tibia13ClientSetting
{
    static CATEGORY := "Graphics"
    static NAME := "graphics_engine"
    static TYPE := "dropdown"

    progressText()
    {
        return txt("Verificando as configurações graphic engine...", "Checking graphic engine settings...")
    }

    settingCheck()
    {
        this.selectCategory(this.CATEGORY)

        this.dropdownOption(this.NAME, this.TYPE)
    }
}