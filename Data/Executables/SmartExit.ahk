
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\scripts_autoload_section.ahk

#Include 

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes/_ProcessHandler.ahk
/*
Project files
*/
; #Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\default_global_variables.ahk
; #Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\mouse_keyboard_functions.ahk

PID := _ProcessHandler.readExePID("OldBotExeName")
Process,Exist,%PID%
If (ErrorLevel = 0) {
    Tooltip, OldBot not opened, %x%, 100
    Sleep, 2000
    ToolTip
    ExitApp
}

x := A_ScreenWidth / 2

if (!InStr(A_ScriptDir, "Data\Executables\Functions")) {
    ; Tooltip, Wrong dir %A_ScriptDir%, A_ScreenWidth / 2, 200
    Tooltip, Wrong dir, %x%, 100
    Sleep, 2000
    ToolTip
    ExitApp
}
Process, Exist, client
if (ErrorLevel = 0) {
    Tooltip, % LANGUAGE = "PT-BR" ? "Cliente do Tibia não está aberto." : "Tibia client is not opened", %x%, 100
    Sleep, 1000
    ToolTip
    ExitApp
}
; só funciona rodando como admin
try
    Run, Data\Files\Third Part Programs\Cports\cports.exe /close * * * 443 %ErrorLevel%
catch
    Msgbox, % LANGUAGE = "PT-BR" ? "Erro ao realizar o smart exit (1)." : "Error performing the smart exit (1)."
try
    Run, Data\Files\Third Part Programs\Cports\cports.exe /close * * * 7171 %ErrorLevel%
catch
    Msgbox, % LANGUAGE = "PT-BR" ? "Erro ao realizar o smart exit (2)." : "Error performing the smart exit (2)."

Tooltip, % LANGUAGE = "PT-BR" ? "Sucesso." : "Sucess.", %x%, 100
Sleep, 1000
ToolTip
ExitApp
return
