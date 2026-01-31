#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

/**
* @factory - new instance returns an instance of another class
*/
class _ControlFactory extends _BaseClass
{
    static ADD_NEW_BUTTON := "addNewButton"
    static EDIT_USER_VALUES_BUTTON := "editUserValuesButton"
    static HOTKEYS_BUTTON := "hotkeysButton"
    static SCRIPT_IMAGES_BUTTON := "scriptImagesButton"
    static SETTINGS_BUTTON := "settingsButton"
    static SET_GAME_AREAS_BUTTON := "setGameAreasButton"
    static SCRIPT_SETTINGS_EDIT := "scriptSettingsEdit"
    static PROFILE_SETTINGS_EDIT := "profileSettingsEdit"
    static LINE := "line"

    /**
    * @return _AbstractControl
    * @throws
    */
    __New(name, params := "")
    {
        (params.iconSize ? params.iconSize : 16) := 16

        return this.getControl(name, params)
    }

    getControl(name, params)
    {
        switch (name) {
            case _ControlFactory.SET_GAME_AREAS_BUTTON:
                return new _Button().title("Definir Game Areas", "Set Game Areas")
                    .event("setGameAreas")
                    .disabled(isTibia13() && !isRubinot())
                    .icon(_Icon.get(_Icon.MOUSE_POINTER), "a0 l5 b1 s" (params.iconSize ? params.iconSize : 16))

            case _ControlFactory.HOTKEYS_BUTTON:
                return new _Button().title("Hotkeys")
                    .w(75)
                    .icon(_Icon.get(_Icon.KEYBOARD), "a0 b0 t1 s" (params.iconSize ? params.iconSize : 16) " l" (params.iconLeft ? params.iconLeft : 3))

            case _ControlFactory.SCRIPT_IMAGES_BUTTON:
                return new _Button().title("Abrir Script Images", "Open Script Images")
                    .w(75)
                    .icon(_Icon.get(_Icon.IMAGE), "a0 l3 b0 t1 s" (params.iconSize ? params.iconSize : 16))
                    .event("ScriptImagesGUI")

            case _ControlFactory.EDIT_USER_VALUES_BUTTON:
                return new _Button().title("Editar User Values", "Edit User Values")
                    .icon(_Icon.get(_Icon.CHECK_RED), "a0 l5 b1 s" (params.iconSize ? params.iconSize : 16))

            case _ControlFactory.ADD_NEW_BUTTON:
                return new _Button().title("Adicionar novo", "Add new")
                    .x("s+10").y("p+20")
                    .icon(_Icon.get(_Icon.PLUS), "a0 l3 b0 s" (params.iconSize ? params.iconSize : 14))

            case _ControlFactory.SETTINGS_BUTTON:
                return new _Button()
                    .xadd(3).yp(-5).w(24).h(24)
                    .icon(_Icon.get(_Icon.SETTINGS), "a0 l1 b0 s" (params.iconSize ? params.iconSize : 16))

            case _ControlFactory.SCRIPT_SETTINGS_EDIT:
                return new _Edit()
                    .xs().yadd(5).h(20)
                    .value(txt("Configurações do script", "Script settings") ": " currentScript)
                    .disabled(true)
                    .option("Center")
                    .loadAfterAdd(false)

            case _ControlFactory.PROFILE_SETTINGS_EDIT:
                return new _Edit()
                    .xs().yadd(5).h(20)
                    .value(txt("Configurações do perfil", "Profile settings") ": " DefaultProfile_SemIni)
                    .disabled(true)
                    .option("Center")
                    .loadAfterAdd(false)

            case _ControlFactory.LINE:
                return new _Groupbox().title("")
                    .x(10).yadd(10).h(8)
                    .color("black")
        }

        throw Exception("Control not found: " name)
    }

}