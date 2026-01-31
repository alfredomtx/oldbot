global OldBotSettings
global Encryptor
global JsonLib
global API

class _OldBotInitializer
{
	__New()
	{
		; first
		this.checkRunningAsAdmin()

		; second
		this.writeProcess()
			new _GlobalIniSettings().submit("reloading", false)

		this.setOnMessageFunctions()

		this.setTrayIcon()

		this.initializeClasses()

		this.checkDrakmoraProcesses()
	}

	writeProcess()
	{
		_OldBotExe.writePID()
		_ProcessHandler.writeExePID("OldBotExeName")
	}

	forceOpenedByLauncher()
	{
		if (!A_IsCompiled) {
			return
		}

		if (new _GlobalIniSettings().get("openedByLauncher")) {
				new _GlobalIniSettings().submit("openedByLauncher", false)
			return
		}


		if (new _GlobalIniSettings().get("reloading")) {
			return
		}

		Gui, Carregando:Destroy

		; Bypass launcher check removed for open-source release

		if (GetKeyState("Ctrl")) {
			return
		}

		ExitApp
	}

	checkRunningAsAdmin()
	{
		if (A_IsCompiled) {
			if (isProcessElevated(DllCall("GetCurrentProcessId")) = 0) {
				Gui, Carregando:Destroy
				MsgBox, 48,, % "OldBot is not running as Administrator, please run it as Admin.", 10
				ExitApp
			}
		}
	}

	setOnMessageFunctions()
	{
		OnMessage(0x204, "WM_RBUTTONDOWN")
		OnMessage(0x201, "WM_LBUTTONDOWN")
		OnMessage(0x4a, "Receive_WM_COPYDATA")  ; 0x4a is WM_COPYDATA
		; OnMessage(0x200, "WM_MOUSEMOVE")
		; OnMessage(0x004E, "WM_NOTIFY")
	}

	setTrayIcon()
	{
		try Menu, Tray, Icon, %A_WorkingDir%\Data\Files\Images\GUI\icons\icon.ico
		catch {
			Gui, Conectando:Destroy
			Gui, Carregando:Destroy
			Msgbox, 16,, % LANGUAGE = "PT-BR" ? A_WorkingDir "\Data\Files\Images\GUI\icons\icon.ico não foi localizado.`n`nVocê está tentando abrir o OldBot fora da sua pasta principal, por favor abra-o corretamente." : A_WorkingDir "\Data\Files\Images\GUI\icons\icon.ico was not found.`n`nYou are trying to open the OldBot outside its main folder, please open it correctly."
			Gosub, ElfGUIGuiClose
			ExitApp
		}

	}

	initializeClasses()
	{
		global Encryptor := new _Encryptor()
		global JsonLib := New JSON()
		global API := new _API()

		this.initializeOldBotSettings()
	}

	initializeOldBotSettings()
	{
		global
		try OldBotSettings := new _OldBotSettings()
		catch e {
			Gui, Carregando:Destroy
			IniWrite, % AutoLogin := 0, %DefaultProfile%, accountsettings, AutoLogin
			if (A_IsCompiled)
				Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - OldBot Settings Init", % e.Message, 10
			else
				Msgbox, 16, % (StrReplace(A_ScriptName, ".exe", "")) " - OldBot Settings Init", % e.Message "`n" e.What "`n" e.Extra "`n" e.Line, 10
			Reload()
			return
		}

		OldBotSettings.resetIniExeNames()
		OldBotSettings.readExeNames()
	}

	checkDrakmoraProcesses()
	{
		return
		; Bypass functionality removed for open-source release
		if (true) {
			return
		}
	}
}
