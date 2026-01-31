global SelectedFunctions
global ShortcutScriptsHWND
global MostrarShortcutGUI


global HotkeysToggleAll
global persistentsToggleAll



Class _ShortcutGUI  {

	__New() {

		this.sizes := {}
		/**
		minimum height, includes cavebotting and selected functions controls
		*/
		this.sizes.baseHeight := 40

		this.buttonHeight := 19

		this.guiWidth := 140

	}


	createShortcutGUI() {
		global

		this.sizes.height := this.sizes.baseHeight

		size := 7
		Gui, ShortcutScripts:Font, s%size%

		this.shortcutFirstElements()

		this.cavebottingElements()
		this.sizes.height += this.sizes.cavebotting

		if (!uncompatibleModule("healing") && new _OldBotIniSettings().get("showHealing")){
			this.healingElements()
			this.sizes.height += this.sizes.healing
		}

		if (!uncompatibleModule("itemRefill") && new _OldBotIniSettings().get("showItemRefill")) {
			this.itemRefillElements()
			this.sizes.height += this.sizes.itemRefill
		}

		if (!uncompatibleModule("support") && new _OldBotIniSettings().get("showSupport")) {
			this.supportElements()
			this.sizes.height += this.sizes.support
		}

		this.miscElements()
		this.sizes.height += this.sizes.misc

		if (!uncompatibleModule("alerts")  && new _OldBotIniSettings().get("showAlerts")) {
			this.alertsElements()
			this.sizes.height += this.sizes.alerts
		}

		this.hotkeysElements()
		this.sizes.height += this.sizes.hotkeys
		Gui, ShortcutScripts:Font, Bold


		y := this.sizes.height + 1
		this.sizes.height += 13
		Gui, ShortcutScripts:Font, norm
		Gui, ShortcutScripts:Font, s6
		Gui, ShortcutScripts:Add, Text, % "x4 y" y " h15 w" this.guiWidth - 5 " vshortcutGuiClientTitle BackgroundTrans", % TibiaClientTitle
		Gui, ShortcutScripts:Font, s%size%
		Gui, ShortcutScripts:Font, Bold

		if (MostrarShortcutGUI = 0)
			return

		Gui, ShortcutScripts:-MinimizeBox -ToolWindow +Owner -Caption +Border
		Gui, ShortcutScripts:Show, % "x" ScriptsShortcutGUI_X " y" ScriptsShortcutGUI_Y " w" this.guiWidth " h" this.sizes.height " NoActivate", Scripts shortcut

		WinGet, ShortcutScriptsHWND, ID, Scripts shortcut
		; msgbox, % serialize(this.sizes)

	}

	cavebottingElements() {
		global
		this.sizes.cavebotting := 0

		this.controls := {}
		if (uncompatibleFunction("support", "autoEatFood") = false) && autoEatFoodShortcutCheckbox && new _OldBotIniSettings().get("showSupport")
			this.controls.Push({control: "autoEatFood_2"                , text: "Auto eat food"                   , value: supportObj.autoEatFood})
		if (uncompatibleFunction("reconnect", "autoReconnect") = false) && autoReconnectShortcutCheckbox && new _OldBotIniSettings().get("showReconnect")
			this.controls.Push({control: "autoReconnect_2"              , text: "Auto reconnect"                   , value: reconnectObj.autoReconnect})
		if (uncompatibleFunction("fullLight", "fullLightEnabled") = false) && fullLightEnabledShortcutCheckbox
			this.controls.Push({control: "fullLightEnabled_2"              , text: "Light Hack"                   , value: fullLightObj.fullLightEnabled})
		if (OldBotSettings.uncompatibleModule("persistent") = false) && new _OldBotIniSettings().get("showPersistent")
			this.controls.Push({control: "persistentsToggleAll"              , text: "Persistent Toggle All"                   , value: 0})

		if (MostrarShortcut_Cavebot = 0)
			return

		CavebotTargeting := (CavebotEnabled = 1 && TargetingEnabled = 1) ? 1 : 0

		if (OldBotSettings.uncompatibleModule("targeting") = false) && (OldBotSettings.uncompatibleModule("cavebot") = false) && cavebotTargetingShortcutCheckbox {
			this.sizes.cavebotting += 14.5
			control := "CavebotTargeting", text := "Cavebot+Targeting"
			this.checkboxControl(control, text)
		}

		if (OldBotSettings.uncompatibleModule("cavebot") = false) && cavebotEnabledShortcutCheckbox {
			this.sizes.cavebotting += 14.5
			control := "cavebotEnabled_2", text := "Cavebot"
			this.checkboxControl(control, text)
		}

		if (OldBotSettings.uncompatibleModule("targeting") = false) && targetingEnabledShortcutCheckbox && new _OldBotIniSettings().get("showTargeting"){
			this.sizes.cavebotting += 14.5
			control := "targetingEnabled_2", text := "Targeting"
			this.checkboxControl(control, text)
		}


		this.sizes.cavebotting += 14.5 * this.controls.Count()

		for key, controlInfo in this.controls
		{
			control := controlInfo.control
			this.checkboxControl(control, controlInfo.text)
		}

	}

	healingElements() {
		global
		this.controls := {}
		this.sizes.healing := this.buttonHeight
		y := this.sizes.height

		this.buttonElement("Healer", "lifemana")
		if (MostrarShortcut_Healer = 0)
			return

		settingObj := "healing"
		if (uncompatibleFunction("healing", "lifeHealing") = false)
				&& (uncompatibleFunction("healing", "manaHealing") = false)
				&& (uncompatibleFunction("healing", "manaTrain") = false)
			this.controls.Push({control: "LifeManaTrain", text: "Life+Mana+Train", value: (LifeManaTrain := (lifeHealingEnabled = 1 && manaHealingEnabled = 1 && manaTrainEnabled = 1 && TibiaClientID != "") ? 1 : 0)})

		if (uncompatibleFunction("healing", "lifeHealing") = false) && lifeHealingEnabledShortcutCheckbox
			this.controls.Push({control: "lifeHealingEnabled_2", text: "Life healer", value: %settingObj%Obj.lifeHealingEnabled})
		if (uncompatibleFunction("healing", "manaHealing") = false) && manaHealingEnabledShortcutCheckbox
			this.controls.Push({control: "manaHealingEnabled_2", text: "Mana healer", value: %settingObj%Obj.manaHealingEnabled})
		if (uncompatibleFunction("healing", "manaTrain") = false) && manaTrainEnabledShortcutCheckbox
			this.controls.Push({control: "manaTrainEnabled_2", text: "Mana train", value: %settingObj%Obj.manaTrainEnabled})

		this.sizes.healing += 14.5 * this.controls.Count()
		this.loadChildControls()
	}

	itemRefillElements() {
		global
		this.controls := {}
		this.sizes.itemRefill := this.buttonHeight
		y := this.sizes.height

		this.buttonElement("ItemRefill", "itemrefill")
		if (MostrarShortcut_ItemRefill = 0)
			return

		settingObj := "itemRefill"
		if (uncompatibleFunction("itemRefill", "ringRefill") = false) && ringRefillEnabledShortcutCheckbox
			this.controls.Push({control: "ringRefillEnabled_2"              , text: "Ring"                   , value: %settingObj%Obj.ringRefillEnabled})
		if (uncompatibleFunction("itemRefill", "amuletRefill") = false) && amuletRefillEnabledShortcutCheckbox
			this.controls.Push({control: "amuletRefillEnabled_2"            , text: "Amulet"                 , value: %settingObj%Obj.amuletRefillEnabled})
		if (uncompatibleFunction("itemRefill", "bootsRefill") = false) && bootsRefillEnabledShortcutCheckbox
			this.controls.Push({control: "bootsRefillEnabled_2"         , text: "Boots"             , value: %settingObj%Obj.bootsRefillEnabled})
		if (uncompatibleFunction("itemRefill", "quiverRefill") = false) && quiverRefillEnabledShortcutCheckbox
			this.controls.Push({control: "quiverRefillEnabled_2"            , text: "Quiver"                 , value: %settingObj%Obj.quiverRefillEnabled})
		if (uncompatibleFunction("itemRefill", "distanceWeaponRefill") = false) && distanceWeaponRefillEnabledShortcutCheckbox
			this.controls.Push({control: "distanceWeaponRefillEnabled_2"    , text: "Distance weapon"        , value: %settingObj%Obj.distanceWeaponRefillEnabled})

		this.sizes.itemRefill += 14.5 * this.controls.Count()
		this.loadChildControls()
	}

	supportElements() {
		global
		this.controls := {}
		this.sizes.support := this.buttonHeight
		y := this.sizes.height

		this.buttonElement("Support", "support")
		if (MostrarShortcut_Support = 0)
			return

		settingObj := "support"
		if (uncompatibleFunction("support", "autoHaste") = false) && autoHasteShortcutCheckbox
			this.controls.Push({control: "autoHaste_2"              , text: "Auto haste"             , value: %settingObj%Obj.autoHaste})
		if (uncompatibleFunction("support", "autoUtamoVita") = false) && autoUtamoVitaShortcutCheckbox
			this.controls.Push({control: "autoUtamoVita_2"          , text: "Auto utamo vita"        , value: %settingObj%Obj.autoUtamoVita})
		if (uncompatibleFunction("support", "autoBuffSpell") = false) && autoBuffSpellShortcutCheckbox
			this.controls.Push({control: "autoBuffSpell_2"          , text: "Auto buff spell"        , value: %settingObj%Obj.autoBuffSpell})
		if (uncompatibleFunction("support", "cureParalyze") = false) && cureParalyzeShortcutCheckbox
			this.controls.Push({control: "cureParalyze_2"           , text: "Cure Paralyze"          , value: %settingObj%Obj.cureParalyze})
		if (uncompatibleFunction("support", "curePoison") = false) && curePoisonShortcutCheckbox
			this.controls.Push({control: "curePoison_2"             , text: "Cure Poison"            , value: %settingObj%Obj.curePoison})
		if (uncompatibleFunction("support", "cureFire") = false) && cureFireShortcutCheckbox
			this.controls.Push({control: "cureFire_2"               , text: "Cure Fire"              , value: %settingObj%Obj.cureFire})
		if (uncompatibleFunction("support", "cureCurse") = false) && cureCurseShortcutCheckbox
			this.controls.Push({control: "cureCurse_2"              , text: "Cure Curse"             , value: %settingObj%Obj.cureCurse})

		if (uncompatibleFunction("support", "autoShoot") = false) && autoShootShortcutCheckbox
			this.controls.Push({control: "autoShoot_2", text: "Auto Shoot", value: supportObj.autoShoot})

		if (!uncompatibleModule("floorSpy")) && floorSpyEnabledShortcutCheckbox
			this.controls.Push({control: "floorSpyToggle", text: "Floor Spy (X-Ray)", value: floorSpyEnabled})

		if (magnifierEnabledShortcutCheckbox) {
			this.controls.Push({control: "magnifierEnabled", text: "Magnifier", value: _Magnifier.CHECKBOX.get()})
		}

		this.sizes.support += 14.5 * this.controls.Count()

		this.loadChildControls()
	}

	miscElements() {
		global
		this.controls := {}
		this.sizes.misc := this.buttonHeight
		y := this.sizes.height

		this.buttonElement("Misc", "misc")
		if (MostrarShortcut_Misc = 0)
			return

		if (uncompatibleFunction("fishing", "fishingEnabled") = false) && fishingEnabledShortcutCheckbox
			this.controls.Push({control: "fishingEnabled_2", text: "Fishing", value: fishingObj.fishingEnabled})

		if (!uncompatibleModule("navigation") && !new _NavigationGUI().isDisabled()) {
			if (navigationLeaderShortcutCheckbox) {
				this.controls.Push({control: _Navigation.CHECKBOX_NAME, text: "Navigation Leader", value: new _NavigationSettings().get(_Navigation.CHECKBOX_NAME)})
			}
			if (navigationFollowerShortcutCheckbox) {
				this.controls.Push({control: _Follower.CHECKBOX_NAME, text: "Navigation Follower", value: new _NavigationSettings().get(_Follower.CHECKBOX_NAME)})
			}
		}

		this.sizes.misc += 14.5 * this.controls.Count()

		this.loadChildControls()
	}

	alertsElements()
	{
		global

		this.controls := {}
		this.sizes.alerts := this.buttonHeight
		y := this.sizes.height

		this.buttonElement("Alerts", "alerts")

		if (MostrarShortcut_Alerts = 0)
			return

		if (OldBotSettings.uncompatibleModule("alerts") = true)
			return


		indexImageIsFound := 0
		indexImageIsNotFound := 0
		for alertName, alert in alertsObj
		{
			if (alertName = AlertsSystem.settingsKey) {
				continue
			}


			if (uncompatibleFunction("alerts", alertName)) {
				continue
			}

			if (InStr(alertName, "Image is found")) {
				indexImageIsFound++
				if (indexImageIsFound > 10)
					continue
			}
			if (InStr(alertName, "Image is not found")) {
				indexImageIsNotFound++
				if (indexImageIsNotFound > 10)
					continue
			}

			this.sizes.alerts += 14.5

			; msgbox, % alertName "`n" serialize(alert)
			this.checkboxControl(_AlertsHandler.getShortcutAlertName(alertName), alertName)
		}
	}

	hotkeysElements() {
		global

		this.controls := {}
		this.sizes.hotkeys := this.buttonHeight
		y := this.sizes.height

		this.buttonElement("Hotkeys", "hotkeys")

		Gui, ShortcutScripts:Font, norm
		Gui, ShortcutScripts:Font, s6
		Gui, ShortcutScripts:Add, Text, x+2 yp+4 h15 BackgroundTrans, % _Version.getDisplayVersion()
		Gui, ShortcutScripts:Font, s%size%
		Gui, ShortcutScripts:Font, Bold

		if (MostrarShortcut_Hotkeys = 0)
			return

		if (OldBotSettings.uncompatibleModule("hotkeys") = false && new _OldBotIniSettings().get("showHotkeys")) {
			this.sizes.hotkeys += 14.5
			control := "HotkeysToggleAll", text := "Hotkeys Toggle All"
			this.checkboxControl(control, text)
		}

		if (uncompatibleFunction("reconnect", "loginHotkey1") = false) {
			this.sizes.hotkeys += 14.5
			this.checkboxControl("LoginHotkey1_2", "Login hotkey 1")
		}
		if (uncompatibleFunction("reconnect", "loginHotkey2") = false) {
			this.sizes.hotkeys += 14.5
			this.checkboxControl("LoginHotkey2_2", "Login hotkey 2")
		}

		if (uncompatibleFunction("others", "smartExit") = false) {
			this.sizes.hotkeys += 14.5
			this.checkboxControl("SmartExit", "Smart exit")

			Gui, ShortcutScripts:Font, norm
			Gui, ShortcutScripts:Font, s6
			Gui, ShortcutScripts:Add, Text, x+3 yp+1 BackgroundTrans, Ctrl+Shift+Q
			Gui, ShortcutScripts:Font, s%size%
			Gui, ShortcutScripts:Font, Bold
		}

	}

	shortcutFirstElements() {
		global



		Gui, ShortcutScripts:New, +Toolwindow +AlwaysOnTop

		Gui, ShortcutScripts:Add, Pic, x0 y0 0x4000000, Data\Files\Images\GUI\GrayBackground.png
		Gui, ShortcutScripts:Font,, Tahoma
		Gui, ShortcutScripts:Font, cc0c0c0 Bold s%size%
		; size := "8"


		control := "MostrarShortcut_Cavebot"
		checked_%control% := buttonFolder "\checkbutton_cavebotting_checked.png", unchecked_%control% := buttonFolder "\checkbutton_cavebotting_unchecked.png"
		Gui, ShortcutScripts:Add, Pic, x5 y5 gcheckbox_handle v%control%, % (%control% = 1) ? checked_%control% : unchecked_%control%

		x := this.guiWidth - 43
		Gui, ShortcutScripts:Add, Pic, x%x% yp-1 vHotkeysFunctionsButton gHotkeysFunctionsGUI, % ImagesConfig.folder "\GUI\Buttons\settings_button.png"
		Gui, ShortcutScripts:Add, Pic, x+3 yp+0 vminimizeShortcutButton gminimizeShortcutGUI, % ImagesConfig.folder "\GUI\Buttons\minimize_button.png"

		control := "SelectedFunctions", text := "Selected Functions"
		this.checkboxControl(control, text)
	}

	checkboxControl(control, text) {
		global
		Gui, ShortcutScripts:Add, Pic, x4 y+2 gcheckbox_handle v%control%, % (%control% = 1 && TibiaClientID != "") ? checked_img : unchecked_img

		Gui, ShortcutScripts:Add, Text, x+2 yp+1 BackgroundTrans v%control%_text gcheckbox_handle, %text%
	}

	loadChildControls() {
		global

		for key, controlInfo in this.controls
		{
			control := controlInfo.control
			this.checkboxControl(control, controlInfo.text)
		}
	}

	buttonElement(type, imageString) {
		global

		control := "MostrarShortcut_" type
		checked_%control% := buttonFolder "\checkbutton_" imageString "_checked.png", unchecked_%control% := buttonFolder "\checkbutton_" imageString "_unchecked.png"
		Gui, ShortcutScripts:Add, Pic, x5 y%y% gcheckbox_handle v%control%, % (%control% = 1) ? checked_%control% : unchecked_%control%
	}

}
