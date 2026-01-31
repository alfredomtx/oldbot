
CreateMenus:
    /*
    menu bar
    */
    #Include __Files\menus\menu_file.ahk
    #Include __Files\menus\menu_edit.ahk
    #Include __Files\menus\menu_window.ahk

    #Include __Files\menus\menu_tutorials.ahk
    #Include __Files\menus\menu_modules.ahk
    #Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\GUI\_TestGameAreasMenu.ahk
    #Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\GUI\_ClientFinderMenu.ahk

    Menu, MyMenuBar, Add, % "&" txt("Arquivo", "File"), :FileMenu
    icon := _Icon.get(_Icon.SETTINGS)
    try {
        Menu, MyMenuBar, Icon, % "&" txt("Arquivo", "File"), % icon.dllName, % icon.number,16
    } catch {
    }

    Menu, MyMenuBar, Add, % "&" txt("Editar", "Edit"), :EditMenu
    ; Menu, MyMenuBar, Add, % LANGUAGE = "PT-BR" ? "Opções" : "Options", :OptionsMenu
    Menu, MyMenuBar, Add, % txt("&Janela", "Window"), :WindowsMenu
    Menu, MyMenuBar, Add, % txt("Tutoriais", "Tutorials"), :InfoMenu
    try {
        Menu, MyMenuBar, Icon, % txt("Tutoriais", "Tutorials"), imageres.dll,95,14
    } catch {
    }

        new _TestGameAreasMenu().createMenu()
        new _ClientFinderMenu().createMenu()

    ; Menu, MyMenuBar, Add, % "&" txt("Módulos", "Modules"), :ModulesMenua
    ; try {
    ;     icon := _Icon.get(_Icon.STAR)
    ;     Menu, MyMenuBar, Icon, % "&" txt("Módulos", "Modules"), % icon.dllName, % icon.number,16
    ; } catch {
    ; }

    StringReplace, DataLicenca_2, DataLicenca,-,, All
    StringReplace, data_banco_2, data_banco,-,, All
    Diff := DataLicenca_2
    Diff -= data_banco_2, days


    if (Diff = "")
        Diff = 0

    global versao_string := "[" _Version.getDisplayVersion() "]"

    versionMenu := versao_string
    daysMenu := (LANGUAGE = "PT-BR" ?  "[Dias: " Diff "]" : "[Days: " Diff "]")
    profileMenu := (LANGUAGE = "PT-BR" ?  "[Perfil: " : "[Profile: ") DefaultProfile_SemIni "]"
    global settingsFileMenu := "[Settings file]"

    if (OldBotSettings.settingsJsonObj.configFile != "settings.json") {
        Menu, MyMenuBar, Add, % settingsFileMenu, MenuHandler
        Menu, MyMenuBar, Disable, % settingsFileMenu
    }


    Menu, MyMenuBar, Add, % daysMenu, MenuHandler
    Menu, MyMenuBar, Add, % profileMenu, MenuHandler
    Menu, MyMenuBar, Add, % TibiaClient.TitleTibiaClientMenu, MenuHandler
    Menu, MyMenuBar, Add, % versionMenu, MenuHandler

    Menu, MyMenuBar, Disable, % daysMenu
    Menu, MyMenuBar, Disable, % profileMenu
    Menu, MyMenuBar, Disable, % TibiaClient.TitleTibiaClientMenu
    Menu, MyMenuBar, Disable, % versionMenu




return
