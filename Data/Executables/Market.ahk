/*
OldBot é desenvolvido por Alfredo Menezes, Brasil.
Copyright © 2024. Todos os direitos reservados.

OldBot is developed by Alfredo Menezes, Brazil.
Copyright © 2024. All rights reserved.
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\scripts_start_settings_section.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\IMarket.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IActionScripts.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Window Events\gui_close.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Window Events\wm_lbuttondown.ahk

global moduleName := _MarketModule.IDENTIFIER

try {
    _MarketModule.run()
} catch e {
    Msgbox, 16, % A_ScriptName " - " _MarketModule.DISPLAY_NAME " Run", % e.Message
    Reload
}
return


ErrorsGUIGuiEscape:
ErrorsGUIGuiClose:
    Gui, ErrorsGUI:Destroy
return


Reload() {
    Reload
    return
}

writeCavebotLog(Status, Text, isError := false) {
}


#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\default_cavebot_functions.ahk
