/*
OldBot é desenvolvido por Alfredo Menezes, Brasil.
Copyright © 2024. Todos os direitos reservados.
true
OldBot is developed by Alfredo Menezes, Brazil.
Copyright © 2024. All rights reserved.
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\scripts_start_settings_section.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IRunemaker.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IHealing.ahk

global moduleName := _RunemakerModule.IDENTIFIER

try {
    _RunemakerModule.run()
} catch e {
    Msgbox, 16, % A_ScriptName " - " _RunemakerModule.DISPLAY_NAME " Run", % e.Message
    Reload
}
return


Reload() {
    Reload
    return
}

writeCavebotLog(Status, Text, isError := false) {
}
