global floorSpyEnabled
global floorSpyObj

global characterSpyPosX
global currentCharX
global currentSpyPosX
global characterSpyPosY
global currentCharY
global currentSpyPosY
global characterSpyPosZ
global currentCharZ
global currentSpyPosZ

Class _FloorSpy {

	test() {
		return "ação"
	}


	__New() {
		global
		floorSpyObj := {}

		this.directionButtons := {}
		this.directionButtons.Push("spyDirectionFloorUp")
		this.directionButtons.Push("spyDirectionFloorDown")
		this.directionButtons.Push("spyDirectionUp")
		this.directionButtons.Push("spyDirectionDown")
		this.directionButtons.Push("spyDirectionRight")
		this.directionButtons.Push("spyDirectionLeft")
	}

	FloorSpyHotkeysGUI() {
		global

		fontSize := 10

		Gui, FloorSpyHotkeysGUI:Destroy
		Gui, FloorSpyHotkeysGUI:+AlwaysOnTop +Owner -MinimizeBox
		Gui, FloorSpyHotkeysGUI:Font, s%fontSize%

		Gui, FloorSpyHotkeysGUI:Add, Text, xp+0 y+10, % (LANGUAGE = "PT-BR" ? "As hotkeys precisam do ""Ctrl"" e ""Alt"" pressionados." : "The hotkeys need ""Ctrl"" and ""Alt"" pressed.")
		Gui, FloorSpyHotkeysGUI:Add, Picture, xp+0 y+5, % ImagesConfig.GUIFolder "\Support\CtrlAlt.png" 


		hotkeys := {}
		hotkeys.Push("Title: " (LANGUAGE = "PT-BR" ? "Ativar/desativar" : "Enable/disable"))
		hotkeys.Push({hotkey: "Space", desc: "Toggle Floor Spy"})
		hotkeys.Push({hotkey: "Scroll Middle Button", desc: "Toggle Floor Spy"})

		hotkeys.Push("<br>")

		hotkeys.Push("Title: " (LANGUAGE = "PT-BR" ? "Floor up/down" : "Floor up/down"))
		hotkeys.Push({hotkey: "Mouse Forward Button", desc: "Floor up"})
		hotkeys.Push({hotkey: "Mouse Backward Button", desc: "Floor down"})
		hotkeys.Push({hotkey: "Ctrl + Shift + Scroll Up", desc: (LANGUAGE = "PT-BR" ? "Floor up (sem Alt pressionado)" : "Floor up (without Alt pressed)")})
		hotkeys.Push({hotkey: "Ctrl + Shift + Scroll Down", desc: (LANGUAGE = "PT-BR" ? "Floor down (sem Alt pressionado)" : "Floor down (without Alt pressed)")})

		hotkeys.Push("<br>")

		hotkeys.Push("Title: " (LANGUAGE = "PT-BR" ? "Spy para a direção(teclas)" : "Spy to direction (keys)"))
		hotkeys.Push({hotkey: "W || Arrow Up", desc: "Spy SQM up"})
		hotkeys.Push({hotkey: "A || Arrow Left", desc: "Spy SQM left"})
		hotkeys.Push({hotkey: "S || Arrow Down", desc: "Spy SQM down"})
		hotkeys.Push({hotkey: "D || Arrow Right", desc: "Spy SQM right"})

		hotkeys.Push("<br>")

		hotkeys.Push("Title: " (LANGUAGE = "PT-BR" ? "Spy para a direção(scroll)" : "Spy to direction (scroll)"))

		hotkeys.Push({hotkey: "Scroll Up", desc: "Spy SQM up"})
		hotkeys.Push({hotkey: "Scroll Left", desc: "Spy SQM left"})
		hotkeys.Push({hotkey: "Scroll Down", desc: "Spy SQM down"})
		hotkeys.Push({hotkey: "Scroll Right", desc: "Spy SQM right"})


		w := 165
		for key, value in hotkeys
		{
			if (value = "<br>") {
				Gui, FloorSpyHotkeysGUI:Add, Text, x10 y+1 w%w% Section, % ""
				continue
			}
			if (InStr(value, "Title: ")) {
				title := StrReplace(value, "Title: ", "")

				Gui, FloorSpyHotkeysGUI:Font, s16 bold
				Gui, FloorSpyHotkeysGUI:Add, Text, x10 y+5 w300 Section, % title
				Gui, FloorSpyHotkeysGUI:Font, norm
				Gui, FloorSpyHotkeysGUI:Font, s%fontSize%
				continue
			}
			Gui, FloorSpyHotkeysGUI:Add, Text, x10 y+5 w%w% Section, % "[ " value.hotkey " ]"
			Gui, FloorSpyHotkeysGUI:Add, Text, x+5 yp+0, % value.desc
		}

		Gui, FloorSpyHotkeysGUI:Show,, Floor Spy Hotkeys

	}

	setSpyDirection(direction := "", fromHotkey := false)
	{
		this.fromHotkey := fromHotkey
		if (direction = "") {
			Gui, CavebotGUI:Submit, NoHide
			direction := StrReplace(A_GuiControl, "spyDirection", "")
		}

		switch direction {
			case "FloorUp", case "FloorDown":
				this.spyDirectionFloor(direction)
			case "Right", case "Left":
				this.spyDirectionX(direction)
			case "Up", case "Down":
				this.spyDirectionY(direction)
		}
	}

	spyDirectionFloor(direction)
	{
		this.changeButtonsSpy("Disable")

		characterSpyPosZ := this.gui().charZ.get()

		if (this.gui().spyZ.get() = "") {
			this.set("Z", characterSpyPosZ, write := false)
		}

		currentSpyPosZ := this.gui().spyZ.get()

		previousSpyPosZ := currentSpyPosZ
		switch direction {
			case "FloorUp": currentSpyPosZ -= 1
			case "FloorDown": currentSpyPosZ += 1
		}

		; if (currentCharZ <= 7 && currentSpyPosZ > 7) && (!isRavendawn()) {
		; 	currentSpyPosZ := previousSpyPosZ
		; 	return this.changeButtonsSpy("Enable")
		; }

		if (currentSpyPosZ < 0 OR currentSpyPosZ > 15) {
			currentSpyPosZ := previousSpyPosZ
			return this.changeButtonsSpy("Enable")
		}

		this.set("Z", currentSpyPosZ)

		this.changeButtonsSpy("Enable")

		; this.checkPosZFloor7()
	}

	spyDirectionX(direction)
	{
		this.changeButtonsSpy("Disable")

		if (!this.gui().spyX.get()) {
			this.set("X", this.gui().charX.get(), write := false)
		}

		currentSpyPosX := this.gui().spyX.get()
		_Validation.number("currentSpyPosX", currentSpyPosX)

		switch direction {
			case "Left": currentSpyPosX -= 1
			case "Right": currentSpyPosX += 1
		}

		this.set("X", currentSpyPosX)

		this.changeButtonsSpy("Enable")
	}

	spyDirectionY(direction)
	{
		; msgbox, % A_ThisFunc
		this.changeButtonsSpy("Disable")

		if (!this.gui().spyY.get()) {
			this.set("Y", this.gui().charY.get(), write := false)
		}
		; msgbox, % direction ","  currentSpyPosY "," characterSpyPosY
		currentSpyPosY := this.gui().spyY.get()
		_Validation.number("currentSpyPosY", currentSpyPosY)

		switch direction {
			case "Up": currentSpyPosY -= 1
			case "Down": currentSpyPosY += 1
		}

		this.set("Y", currentSpyPosY)

		this.changeButtonsSpy("Enable")
	}

	changeButtonsSpy(action) {
		; if (this.fromHotkey = true)
		; return

			new _FloorSettingsSpyGUI().setDefault()
		for key, value in this.directionButtons
		{
			GuiControl, %action%, % value
		}
	}

	toggle()
	{
		if (floorSpyEnabled = 1) {
			this.disableFloorSpy()
		} else {
			this.enableFloorSpy()
		}
	}

	enableFloorSpy() {
		; msgbox, % A_ThisFunc
			; new _FloorSettingsSpyGUI().setDefault()
		; GuiControl, ,floorSpyEnabled, % floorSpyEnabled := 1
		; checkbox_setvalue("floorSpyEnabled", floorSpyEnabled)

		this.startFloorSpy()
	}

	disableFloorSpy() {
		; msgbox, % A_ThisFunc
		; 	new _FloorSettingsSpyGUI().setDefault()
		; GuiControl, ,floorSpyEnabled, % floorSpyEnabled := 0
		; checkbox_setvalue("floorSpyEnabled", floorSpyEnabled)
		this.stopFloorSpy()
	}

	startFloorSpy()
	{
		this.gui().open(close := false)
		try TibiaClient.checkClientSelected()
		catch e {
			msgbox, 64,, % e.message, 2
			return
		}

		MemoryManager.injectClientMemory()

		this.changeButtonsSpy("Enable")

		this.getCurrentCharCoords()

		if (currentCharZ < 0 OR currentCharZ > 15) {
			this.disableFloorSpy()
			Msgbox, 48,, % "Wrong character floor values detected(" currentCharZ "), please contact support.`nClient: " TibiaClientExeName, 10
			return
		}
	}

	stopFloorSpy() {
		try {
			this.changeButtonsSpy("Disable")
		} catch e {
		}

		if (TibiaClient.isClientClosed() = true)
			return

		; msgbox % A_ThisLabel " / " currentSpyPosZ " / " characterSpyPosZ
		if (this.gui().spyX.get() != this.gui().charX.get())
			MemoryManager.writeMemoryPos("X", this.gui().charX.get())
		if (this.gui().spyY.get() != this.gui().charY.get())
			MemoryManager.writeMemoryPos("Y", this.gui().charY.get())
		if (this.gui().spyZ.get() != this.gui().charZ.get())
			MemoryManager.writeMemoryPos("Z", this.gui().charZ.get())

		this.gui().charX.set("")
		this.gui().spyX.set("")
		this.gui().charY.set("")
		this.gui().spyY.set("")
		this.gui().charZ.set("")
		this.gui().spyZ.set("")
	}

	checkPosZFloor7()
	{
		if (currentCharZ = 7) && (this.gui().spyZ.get() = 7) {
			GuiControl, Disable, spyFloorDown
		}
	}

	getCurrentCharCoords()
	{
		global
		currentCharX := MemoryManager.readPosX()
		currentCharY := MemoryManager.readPosY()
		currentCharZ := MemoryManager.readPosZ()

		this.gui().charX.set(currentCharX)
		this.gui().charY.set(currentCharY)
		this.gui().charZ.set(currentCharZ)

		; this.checkPosZFloor7()
	}

	gui()
	{
		return new _FloorSpySettingsGUI()
	}

	set(type, value, write := true)
	{
		if (value = "") {
			return
		}

		if (write = true) {
			MemoryManager.writeMemoryPos(type, value)
		}

		this.gui()["spy" type].set(value)
	}
}