/*_Files\Classes\Targeting\_Targeting_Files\Classes\Targeting\_Targeting
OldBot é desenvolvido por Alfredo Menezes, Brasil.
Copyright © 2017. Todos os direitos reservados.

OldBot is developed by Alfredo Menezes, Brazil.
Copyright © 2017. All rights reserved.
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\scripts_start_settings_section.ahk
/*
Includes folder
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\ISupport.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IHealing.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IHealing.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Sio.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\Targeting.ahk

/*
system
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Cavebot\_CavebotSystem.ahk

/*
others
*/
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\_ClientAreas.ahk


/*
module name
*/
global moduleName := "sioFriend"

/*
main Handler class initializing before hasFunctionEnabled()
*/

if (A_IsCompiled) {
	if (OldBotSettings.hasFunctionEnabled(moduleName) = false)
		ExitApp
}

PID := _ProcessHandler.writeModuleExePID(moduleName)

; reloads if client is closed
if (TibiaClient.getClientAreaFunctions(StrReplace(A_ScriptName, ".exe", "")) = false)
	return

; OutputDebug(moduleName, "Starting...")

/*
If client is disconnected, loop until it is connected again
or exitapp if tibia window doesn't exist anymore
*/
TibiaClient.isDisconnectedLoopWaitOrExit(moduleName)

/*
initializing classes
*/
global MemoryManager := new _MemoryManager(injectOnStart := true)
global TargetingSystem := new _TargetingSystem() ; before TargetingHandler

/*
handler
*/
global TargetingHandler := new _TargetingHandler()

/*
system
*/
global CavebotSystem := new _CavebotSystem()
global SupportSystem := new _SupportSystem()

/*
others
*/
global AttackSpell := new _AttackSpell()
global ClientAreas := new _ClientAreas()


/*
initializing functions
*/
try {
	global HealingSystem := new _HealingSystem()
} catch e {
	if (e.Message != "") ; if life bars are not found, msgbox_image will already show msgbox and will throw no message
		Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - Healing Setup Init", % e.Message, 10
	Reload
	return
}

try {
	_ClientAreas.setupCommonAreas()
} catch e {
	Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - setupCommonAreas()", % e.Message
	Reload
	return
}

if (new _SioSystem().sioFriendJsonObj.options.enableAttackRune = true) {
	try TargetingSystem.createCreaturesDangerObj()
	catch e {
		Msgbox, 48, % (StrReplace(A_ScriptName, ".exe", "")) " " e.What, % e.Message, 10
		Reload
		return
	}

}

/*
after all initial functions loadings
*/
Random, R, 0, 400
SetTimer, VerifyFunctionsFromExe, % 4000 + R
SetTimer, CheckClientClosedMinimized, % 2000 + R


/*
start running module system & functions
*/


	new _SioSystem().run()

return


VerifyFunctionsFromExe:
	CavebotScript.loadSpecificSettingFromExe(moduleName, currentScript, A_ScriptName)
	if (OldBotSettings.hasFunctionEnabled(moduleName) = false)
		ExitApp
return

CheckClientClosedMinimized:
	TibiaClient.isClientClosed(false, moduleName) ; check if client is closed and reload if true
	TibiaClient.isClientMinimized(true)
return


/*
to include CavebotSystem
*/
Reload() {
	Reload
	return
}

/*
to include AttackSpell
*/
writeCavebotLog(Status, Text, isError := false) {
	return
}

/*
to include TargetingSystem
*/
countIgnoredTargetingTimer:
countCreatureNotReachedTimer:
countAttackingCreatureTimer:
getMonsterPosition:
CooldownExeta:
return


#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\default_cavebot_functions.ahk
