/*
File purpose:
Include all the common functions that are used on all scripts (exception for Cavebot.ahk)
*/

workingDir := A_WorkingDir
if (InStr(workingDir, "Data\Executables"))
	workingDir := StrReplace(workingDir, "Data\Executables", ""), workingDir := StrReplace(workingDir, "Data\Executables\", "")
SetWorkingDir, % workingDir

/*
Includes
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\scripts_autoload_section.ahk

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\_Core.ahk

/*
Project files
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\default_global_variables.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\default_functions.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\default_functions.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\mouse_keyboard_functions.ahk

/*
Classes
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes/Cavebot\_CavebotScript.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes/Client\_ClientAreas.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Encryptor.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes/_ProcessHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes/_OldBotSettings.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes/Client\_TibiaClient.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_ImagesConfig.ahk ; depends on TibiaClient

/*
Libraries
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ILibraries.ahk


if (A_IsCompiled)
	VerificarOldBotAberto()

global Encryptor := new _Encryptor()

; first
try {
	global OldBotSettings := new _OldBotSettings()
} catch e {
	Gui, Carregando:Destroy
	if (A_IsCompiled)
		Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - OldBot Settings Init", % e.Message, 10
	else
		Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - OldBot Settings Init", % e.Message "`n" e.What "`n" e.Extra "`n" e.Line, 10
	Reload
	return
}

global TibiaClient := new _TibiaClient() ;  depends on OldBotSettings

IniRead, LANGUAGE, %DefaultProfile%, settings, LANGUAGE, PT-BR
global LANGUAGE
IniRead, TibiaClientID, %DefaultProfile%, advanced, TibiaClientID, %A_Space%
if (A_IsCompiled && TibiaClientID = "") {
	Gui, Carregando:Destroy
	; Msgbox, 48, % StrReplace(A_ScriptName, ".exe", ""), % "There is no Tibia client selected."
	ExitApp
}


; second
global CavebotScript := new _CavebotScript(currentScript, true, false)
; third
global ImagesConfig := new _ImagesConfig()
global ClientAreas := new _ClientAreas()  ; keep together with Images

classLoaded("_BitmapEngine", _BitmapEngine)
