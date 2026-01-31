
class _MemoryManager
{
	__New(injectOnStart := false)
	{
		this.startMemoryClass := false

		if (!this.hasMemoryInjection()) {
			return this
		}


		this.moduleJsonFolder := OldBotSettings.JsonFolder "\memory\modules"

		this.clientName := ""
		this.clientIdentifier := TibiaClient.getClientIdentifier(memoryIdentifier := true)

		this.setDefaultMemoryAddressesSettings()


		this.readClientMemoryAddresses()

		this.setLightMemoryAddresses()

		if (injectOnStart = true)
			this.injectClientMemory()
	}

	findClientMemory(msgboxWithResult := false, showMsgBoxError := true) {

		this.startMemoryClass := true
		this.injectClientMemory()

		if (this.beforeStartValidationsMemory(showMsgBoxError) = false) {
			return false
		}

		this.coordinates := {}
		this.filesRead := 0

		if (this.loopFolderFindMemory(OldBotSettings.JsonFolder "\memory\*.json", msgboxWithResult) = true) {
			return true
		}
		if (this.loopFolderFindMemory(OldBotSettings.JsonFolder "\memory\old\*.json", msgboxWithResult) = true) {
			return true
		}

		if (msgboxWithResult = true)
			msgbox, 16,, % txt("Não foi possível configurar automaticamente a injeção de memória para esse cliente, por favor entre em contato com o suporte para verificar a possibilidade de adaptar para esse cliente.", "It was not possible to setup automatically the memory injection for this client. please contact support to check the possibility to adapt for this client.") "`n`n[ Info: ] " "`nName: " this.clientName "`nExe name: " TibiaClientExeName "`nWindow: " TibiaClientTitle " / " this.filesRead
		return false
	}

	loopFolderFindMemory(folderDir, msgboxWithResult := true, debug := false) {
		loop, % folderDir {
			if (debug)
				msgbox, % A_LoopFileFullPath


			memoryJsonFile := "", memoryJsonFileObj := ""
			try {
				memoryJsonFile := this.readMemoryJsonFile(A_LoopFileName, A_LoopFileFullPath)
			} catch e {
				if (msgboxWithResult = true) {
					msgbox, 16, % e.what, % e.Message
				}
				continue
			}


			memoryJsonFileObj := memoryJsonFile.Object()

			this.setCoordinatesAddresses(A_LoopFileName, memoryJsonFileObj)

			this.filesRead++

			; debug := false
			; if (InStr(A_LoopFIleName, "mista")) {
			; 	debug := true
			; 	m("mista z " valueZ, A_LoopFIleName, memoryJsonFileObj, this.coordinates)
			; }
			valueZ := this.readMemoryPos("Z", debug)
			if (valueZ = "") OR (valueZ < 1 OR valueZ > 15)
				continue
			valueX := this.readMemoryPos("X")
			if (valueX = "") OR (valueX < 1 OR valueX > 99999)
				continue

			if (valueX == 1 && valueZ == 1) {
				continue
			}

			/*
			in "Old Tibia" server, the x and y were alays 32 and z 3 with some address found automatically
			*/
			if (valueX = 32 && valueZ = 3)
				continue

			valueY := this.readMemoryPos("X")
			if (valueY = "") OR (valueY < 1 OR valueY > 99999) {
				continue
			}

			if (valueX < 16 || valueY < 16) { ; necroxia
				continue
			}

			try {
				this.memoryFileFound(A_LoopFileFullPath, A_Index)
				this.memoryJsonFile := memoryJsonFile
				this.memoryJsonFileObj := memoryJsonFileObj
			} catch e {
				msgbox, 16, % A_ThisFunc, % e.Message "`n`n" e.What, 30
				break
			}

			/*
			if is the same selected client, reload the bot
			*/
			if (TibiaClient.getClientIdentifier(true) = this.clientName) {
				if (msgboxWithResult = true)
					msgbox, 64, , % txt("Configuração finalizada com sucesso!`n`nAgora você já pode usar o Cavebot no modo de coordenadas nesse cliente.", "Configuration finished with success!`n`nNow you use the Cavebot on coordinates mode in this client."), 10
			} else {
				if (msgboxWithResult = true) {

					msgbox, 64, ,% txt("Configuração finalizada com sucesso!`n`nAgora você já pode selecionar o novo cliente """ this.clientName """ na lista em ""Selecionar Client"".", "Configuration finished with success!`n`nNow you can select the new client """ this.clientName """ in the list on ""Select Client""."), 20
					; msgbox, % selectedClient
				}
			}

			_TibiaClient.setCurrentClientJson("settings_" this.clientName ".json", this.clientName)

			return true
		}
	}

	beforeStartValidationsMemory(showMsgBoxError := true) {
		if (this.checkTibiaClientLogged(showMsgBoxError) = false)
			return false
		if (this.clientName = "")
			return false

		if (this.mem.BaseAddress = "") {
			if (showMsgBoxError)
				msgbox, 16, % A_ThisFunc, % "empty BaseAddress."
			return false
		}
		Gui, memoryFindClientGUI:Destroy
		return true
	}

	checkTibiaClientLogged(showMsgBoxError := true) {
		if (TibiaClient.isClientClosed() = true) {
			if (showMsgBoxError)
				Msgbox, 64,, % txt("O cliente do Tibia está fechado.", "Tibia client is closed."), 2
			return false
		}

		If (isDisconnected()) {
			if (showMsgBoxError)
				Msgbox, 48, , % txt("Você precisa estar LOGADO no Tibia para continuar, logue em um personagem e tente novamente.", "You need to be LOGGED IN in Tibia to continue, log in a character and try again."), 10
			return false
		}
		return true
	}

	memoryFileFound(fileFullPath, index)
	{
		; commented since the bot was deleting files
		; fileDir := OldBotSettings.JsonFolder "\memory\" this.clientName ".json"
		; try FileDelete, % fileDir
		; catch {
		; }

		try {
			FileCopy, % fileFullPath, % OldBotSettings.JsonFolder "\memory\" this.clientName ".json", 1
			; m(fileFullPath "`n`n"OldBotSettings.JsonFolder "\memory\" this.clientName ".json")
		} catch e {
			throw Exception("Failed to copy file " fileDir " file:`n" e.Message "`n" e.What)
		}

		try {
			this.copySettingsJsonFileFromDefaultTemplate()
		} catch e {
			try FileDelete, % fileDir
			catch {
			}
			throw e
		}

		return true
	}


	copySettingsJsonFileFromDefaultTemplate() {
		if (isNotTibia13())
			return
		this.templateSettingsJsonNewFile := ""
		fileDir := OldBotSettings.JsonFolder "/settings.json"
		try {
			this.templateSettingsJsonNewFile := new JSONFile(fileDir)
		} catch e {
			throw Exception("Failed to Load " fileDir " file:`n" e.Message "`n" e.What)
		}
		this.templateSettingsJsonNewFileObj := this.templateSettingsJsonNewFile.Object()
		; m(serialize(this.templateSettingsJsonNewFileObj))


		/*
		write new json settings
		*/
		this.templateSettingsJsonNewFileObj.settings.cavebot.getCharCoordinatesFromMemory := true
		this.templateSettingsJsonNewFileObj.tibiaClient.memoryIdentifier := this.clientName
		this.templateSettingsJsonNewFileObj.tibiaClient.tibia12 := true

		this.settingsJsonNewFile := ""
		fileDir := OldBotSettings.JsonFolder "/settings_" this.clientName ".json"
		try FileDelete, % fileDir
		catch {
		}
		try {
			this.settingsJsonNewFile := new JSONFile(fileDir)
		} catch e {
			throw Exception("Failed to Load " fileDir " file:`n" e.Message "`n" e.What)
		}
		this.settingsJsonNewFile.Fill(this.templateSettingsJsonNewFileObj)
		try {
			this.settingsJsonNewFile.Save(true)
		} catch e {
			throw Exception("Failed to save " fileDir " file:`n" e.Message "`n" e.What)
		}

		; try FileCopy, % OldBotSettings.JsonFolder "/settings.json", % OldBotSettings.JsonFolder "/settings_" this.clientName ".json", 1
		; catch e {
		; 	throw Exception(txt("Falha ao copiar o arquivo settings.json para o novo client: " this.clientName, "Failed to copy the settings.json file for the new client: " this.clientName))
		; }
	}
	memoryFindClientGUI()
	{
		global

		w := 200
		; if (A_IsCompiled) {
		msgbox, 68,, % txt("Essa função pode ser usada SOMENTE para clientes da versão " _TibiaClient.TIBIA_14_IDENTIFIER ", ok?", "This function can ONLY be used for clients of version " _TibiaClient.TIBIA_14_IDENTIFIER ", ok?")
		IfMsgBox, no
			return
		; }

		Gui, memoryFindClientGUI:Destroy
		Gui, memoryFindClientGUI:-MinimizeBox
		Gui, memoryFindClientGUI:Add, Text, x10 y+5, % txt("Escreva o nome do OT:", "Write the name of the OT:")
		Gui, memoryFindClientGUI:Add, Edit, x10 y+3 vclientName hwndhclientName w%w%, % clientName
		SetEditCueBanner(hclientName, "CaterOT")

		Gui, memoryFindClientGUI:Font, cGray
		Gui, memoryFindClientGUI:Add, Text, x10 y+5 w%w%, % txt("Nenhum caractére especial é permitido.", "No special character is allowed.")
		Gui, memoryFindClientGUI:Font,

			new _Button()
			.title(txt("Adicionar cliente", "Add client"))
			.x(10).y("+5").w(w).h(25)
			.gui("memoryFindClientGUI")
			.event(TibiaClient.addNewTibiaClient.bind(TibiaClient))
			.add()

		Gui, memoryFindClientGUI:Show,, % txt("Injeção de memória - Adicionar cliente", "Memory injection - Add client")

	}

	setLightMemoryAddresses() {
		switch (this.clientIdentifier) {
			case "Tibia-Retro":
				this.LightPointerOffset := "0xD8"
			case "fossil":
				this.LightPointerOffset := "0xE8"
			case "medivia":
				this.LightPointerOffset := "0x164"
			case "darkrest":
				this.LightPointerOffset := "0xDC"
			case "exordion":
				this.LightPointerOffset := "0xB0"
			case "Tibia Sucks":
				this.LightPointerOffset := "0xD0"
			case "Eternal Odyssey":
				this.LightPointerOffset := "0xB4"
			case "odenia":
			case "Project Fibula":
				this.LightPointerValues := {}
				this.LightPointerValues.sqms := "15"
				this.LightPointerValues.value := "206"
				this.LightPointerOffsets := {}
				; this.LightPointerOffsets.sqms := "0x120"
				; this.LightPointerOffsets.value := "0x124"
				this.LightPointerOffsets.sqms := "0x258"
				this.LightPointerOffsets.value := "0x25C"
			case "tibiantis":
				this.LightPointerValues := {}
				this.LightPointerValues.sqms := "15"
				this.LightPointerValues.value := "215"
				this.LightPointerOffsets := {}
				this.LightPointerOffsets.sqms := "0x110"
				this.LightPointerOffsets.value := "0x114"

			default:
				data := this.memoryJsonFileObj.l
				if (!data) {
					; default for tibia 7.x OTC
					this.LightPointerOffset := new _MemoryAddress(this.localPlayerBaseAddress)
						.addOffset("0xAC")
					return
				}

				this.LightPointerOffset := _MemoryAddress.FROM_ARRAY(data)
		}
	}

	setDefaultMemoryAddressesSettings()
	{
		this.divide256 := {}
		this.divide256.x := false, this.divide256.y := false, this.divide256.z := false

		this.bytesReadRaw := {}
		this.bytesReadRaw.x := 0
		this.bytesReadRaw.y := 0
		this.bytesReadRaw.z := 0

		switch (this.clientIdentifier) {
			case "Project Talus":
				this.bytesReadRaw.z := 1
			case "Rubinot RTC":
				this.bytesReadRaw.z := 1
			case "karma":
				this.bytesReadRaw.z := 1
			case "antiga":
				this.bytesReadRaw.z := 1
			case "darkrest":
				this.bytesReadRaw.z := 1
			case "dragonsouls":
				this.bytesReadRaw.z := 1
			case "dragonsouls":
				this.bytesReadRaw.z := 1
			case "imperianic":
				this.bytesReadRaw.z := 1
			case "nostalther":
				this.bytesReadRaw.z := 1
			case "nwo":
				this.bytesReadRaw.z := 1
			case "exordion":
				this.bytesReadRaw.z := 1
			case "Ruthless Chaos":
				this.bytesReadRaw.z := 1
			case "Naruto Story":
				this.bytesReadRaw.z := 1
			case "tibiabase":
				this.bytesReadRaw.z := 1
			case "Tibia-Retro":
				this.bytesReadRaw.z := 1
			case "blacktalon":
				this.bytesReadRaw.z := 1
			case "outcast":
				this.bytesReadRaw.z := 4
			case "imperial_age":
				this.bytesReadRaw.z := 2
			case "fossil":
				this.divide256.z := true
				this.bytesReadRaw.x := 4, this.bytesReadRaw.y := 4, this.bytesReadRaw.z := 2

			case "medivia":
				this.bytesReadRaw.z := 1
		}
	}

	hasMemoryInjection() {
		return !empty(OldbotSettings.settingsJsonObj.tibiaClient.memoryIdentifier)
	}

	readClientMemoryAddresses()
	{
		this.memoryJsonFileDir := A_WorkingDir "\" OldBotSettings.JsonFolder "\memory\" OldbotSettings.settingsJsonObj.tibiaClient.memoryIdentifier ".json"
		; msgbox, % this.memoryJsonFileDir

		try {
			this.memoryJsonFile := this.readMemoryJsonFile(OldbotSettings.settingsJsonObj.tibiaClient.memoryIdentifier, this.memoryJsonFileDir)
		} catch e {
			Msgbox, 16, % e.What, % e.Message, 10
			return false
		}
		this.memoryJsonFileObj := this.memoryJsonFile.Object()

		; msgbox, % serialize(this.memoryJsonFileObj

		this.itemRefillFile := (this.memoryJsonFileObj.m.itemRefill = "") ? "itemRefill" : this.memoryJsonFileObj.m.itemRefill

		this.startMemoryClass := true

		this.setCoordinatesAddresses()

		this.setHealthAddresses()
		; this.setItemRefillAdressses()

	}

	readMemoryJsonFile(fileName, filePath) {
		if (!FileExist(filePath)) {
			throw Exception("File does not exist:`n" filePath)
		}

		try {
			return new JSONFile(filePath)
		} catch e {
			throw Exception("Failed to load " fileName ".json file:`n" e.Message "`n" e.What, "Load JSON file: " filePath)
		}
	}

	setCoordinatesAddresses(fileName := "", memoryJsonFileObj := "") {
		; msgbox, % serialize(this.memoryJsonFileObj.a)
		this.coordinatesObj := memoryJsonFileObj ? memoryJsonFileObj.a : this.memoryJsonFileObj.a

		; msgbox, % serialize(this.coordinatesObj)

		if (this.coordinatesObj.MaxIndex() < 4) {
			this.startMemoryClass := false
			_Logger.error("Memory index < 4, please contact support." "`n`nClient: " this.clientIdentifier "`nFile: " fileName "`nPath: " this.memoryJsonFileDir "\" fileName)
			; msgbox, 16, % "Outdated Memory Configuration", %
		} else if (this.coordinatesObj.MaxIndex() = 4) {
		} else if (this.coordinatesObj.MaxIndex() > 4) {
			loop, % this.coordinatesObj.MaxIndex() - 4 {
				this.coordinates.offsets[A_Index] := this.coordinatesObj[A_Index]
			}
		}

		this.localPlayerBaseAddress := this.coordinatesObj[this.coordinatesObj.MaxIndex()]



		this.coordinates := {}
		this.coordinates.offsets := {}

		this.coordinates.offsets.X := this.coordinatesObj[this.coordinatesObj.MaxIndex() - 3]
		this.coordinates.offsets.Y := this.coordinatesObj[this.coordinatesObj.MaxIndex() - 2]
		this.coordinates.offsets.Z := this.coordinatesObj[this.coordinatesObj.MaxIndex() - 1]


		offsetsOnly := []
		loop, % this.coordinatesObj.MaxIndex() - 4
			offsetsOnly.Push(this.coordinatesObj[A_Index])

		; m(serialize(offsetsOnly))

		this.coordinates.offsets.XwithOffsets := offsetsOnly.Clone()
		this.coordinates.offsets.XwithOffsets.Push(this.coordinates.offsets.X)
		this.coordinates.offsets.YwithOffsets := offsetsOnly.Clone()
		this.coordinates.offsets.YwithOffsets.Push(this.coordinates.offsets.Y)
		this.coordinates.offsets.ZwithOffsets := offsetsOnly.Clone()
		this.coordinates.offsets.ZwithOffsets.Push(this.coordinates.offsets.Z)
		; msgbox, % serialize(this.coordinates.offsets)
		; msgbox, % serialize(this.coordinates.offsets.XwithOffsets)
		; msgbox, % serialize(this.coordinates.offsets.ZwithOffsets)


	}

	setItemRefillAdressses() {

		this.defaultItemRefillFile := ""
		try {
			this.defaultItemRefillFile := this.readMemoryJsonFile(this.itemRefillFile, this.moduleJsonFolder "\" this.itemRefillFile ".json")
		} catch e {
			Msgbox, 16, % e.What " (" _Version.getDisplayVersion() ")", % e.Message, 10
			return false
		}
		this.defaultItemRefillFileObj := this.defaultItemRefillFile.Object()


		this.itemRefill := {}

		items := {}
		; items.Push("boots")
		items.Push("ring")

		for key, item in items
		{
			this.itemRefill[item] := {}
			this.itemRefill[item].offsets := []

			this.setDefaultItemRefillAddresses(item)

			if (this.memoryJsonFileObj.itemRefill[item].a != "")
				this.itemRefill[item].address := this.memoryJsonFileObj.itemRefill[item].a

			if (this.memoryJsonFileObj.itemRefill[item].o.Count() > 0) {
				for key, value in this.memoryJsonFileObj.itemRefill[item].o
					this.itemRefill[item].offsets.Push(value)
			}

		}
		; m(serialize(this.itemRefill.ring))

	}

	setDefaultItemRefillAddresses(item) {
		switch (TibiaClient.getClientIdentifier()) {
			case "rltibia":
				this.itemRefill[item].address := this.defaultItemRefillFile[item].a

				this.itemRefill[item].type := (this.defaultItemRefillFile[item].t = "") ? "UInt" : this.defaultItemRefillFile[item].t

				for key, value in this.defaultItemRefillFile[item].o
					this.itemRefill[item].offsets.Push(value)
		}
	}

	setDefaultHealthAddresses() {
		if (!IsObject(this.defaultHealingFile)) {
			return
		}

		for key, value in this.defaultHealingFileObj.o
			this.healing.offsets.Push(value)

		this.healing.life.current := this.defaultHealingFileObj.l[1]
		this.healing.life.total := this.defaultHealingFileObj.l[2]

		this.healing.mana.current := this.defaultHealingFileObj.m[1]
		this.healing.mana.total := this.defaultHealingFileObj.m[2]
	}

	setHealthAddresses() {

		defaultFile := "healing"
		if (isTibia74()) {
			defaultFile := "healing_otclientv8"
		}

		if (OldBotSettings.settingsJsonObj.files.memory.healing != "")
			defaultFile := StrReplace(OldBotSettings.settingsJsonObj.files.memory.healing, ".json", "")

		try {
			this.defaultHealingFile := this.readMemoryJsonFile("healing", this.moduleJsonFolder "\" defaultFile ".json")
		} catch e {
			Msgbox, 16, % e.What, % e.Message, 10
			return false
		}
		this.defaultHealingFileObj := this.defaultHealingFile.Object()
		; m(serialize(this.defaultHealingFileObj))

		this.healing := {}
		this.healing.life := {}
		this.healing.mana := {}

		this.healing.offsets := []

		this.setDefaultHealthAddresses()

		for key, value in this.memoryJsonFileObj.h.o
			this.healing.offsets.Push(value)

		this.healing.baseAddress := this.memoryJsonFileObj.h.a
		this.healing.type := (this.memoryJsonFileObj.h.t != "") ? this.memoryJsonFileObj.h.t : (this.defaultHealingFileObj.t != "" ? this.defaultHealingFileObj.t : "UInt")

		if (this.memoryJsonFileObj.h.l.Count() > 0) {
			this.healing.life.current := this.memoryJsonFileObj.h.l[1]
			this.healing.life.total := this.memoryJsonFileObj.h.l[2]
		}

		if (this.memoryJsonFileObj.h.m.Count() > 0) {
			this.healing.mana.current := this.memoryJsonFileObj.h.m[1]
			this.healing.mana.total := this.memoryJsonFileObj.h.m[2]
		}

		this.healing.life.currentWithOffsets := this.healing.offsets.Clone()
		this.healing.life.totalWithOffsets := this.healing.offsets.Clone()
		this.healing.life.currentWithOffsets.Push(this.healing.life.current)
		this.healing.life.totalWithOffsets.Push(this.healing.life.total)

		this.healing.mana.currentWithOffsets := this.healing.offsets.Clone()
		this.healing.mana.totalWithOffsets := this.healing.offsets.Clone()
		this.healing.mana.currentWithOffsets.Push(this.healing.mana.current)
		this.healing.mana.totalWithOffsets.Push(this.healing.mana.total)

		if (this.healing.baseAddress = "")
			this.healing.baseAddress := this.localPlayerBaseAddress

		; msgbox, % serialize(this.healing)
	}



	throwErrorMemoryAddress(msg) {
		Gui, Carregando:Hide
		Msgbox, 16, % "Memory Manager: " OldbotSettings.settingsJsonObj.tibiaClient.memoryIdentifier, % msg, 20
		Gui, Carregando:Show
	}

	injectClientMemory(forceStart := false) {
		if (this.startMemoryClass = false)
			return

		/*
		dont initialize twice
		*/
		if (forceStart = false) {
			if (isObject(this.mem))
				return
		}

		try TibiaClient.checkClientSelected()
		catch e {
			msgbox, 64,, % e.message, 2
			return
		}

		if (!IsObject(_ClassMemory))
			throw Exception("_ClassMemory not initialized.")

		this.mem := new _ClassMemory("ahk_id " TibiaClientID, "", hProcessCopy) ; *****

		; this.qt5CoreDll := this.mem.getModuleBaseAddress("Qt5Core.dll")
		; msgbox % "Module Base: " this.qt5CoreDll


		; Check if the above method was successful.
		if !isObject(this.mem)
		{
			if (!A_IsCompiled) {
					new _Notification()
					.error()
					.title("MemoryManager")
					.message("not running as admin")
					.timeout(3)
					.show()
				return
			}

			msgbox, 16, % "MemoryManager: " OldbotSettings.settingsJsonObj.tibiaClient.memoryIdentifier, % "Failed to open a handle.`n" A_LastError, 20
			if (hProcessCopy = 0)
				msgbox The program isn't running (not found) or you passed an incorrect program identifier parameter.
			else if (hProcessCopy = "")
				msgbox OpenProcess failed. If the target process has admin rights, then the script also needs to be ran as admin. Consult A_LastError for more information.
			return
		}

	}

	readTest() {
		this.injectClientMemory()

		if (OldbotSettings.settingsJsonObj.tibiaClient.memoryIdentifier = "") {
			msgbox, 16,, empty memoryIdentifier
			return
		}

		value := this.readMemoryPos("Z", debug := true)
		msgbox, % "Z: " value
		value := this.readMemoryPos("X", debug := true)
		msgbox, % "X: " value

	}

	readLightTest() {
		this.injectClientMemory()

		; msgbox, % this.mem.BaseAddress
		; msgbox, % this.localPlayerBaseAddress
		; msgbox, % this.coordinates.offsets.light
		switch (this.clientIdentifier) {
			case "kingdomswap":
				value := this.mem.read(this.mem.BaseAddress + this.localPlayerBaseAddress, "UInt", this.coordinates.offsets.light)
				msgbox, % value
				this.writeLocalPlayerOneOffset(256, this.coordinates.offsets.light)
				value := this.mem.read(this.mem.BaseAddress + this.localPlayerBaseAddress, "UInt", this.coordinates.offsets.light)
				msgbox, % value
			case "tibiascape", case "tibia-old", case "likeretro":
				msgbox, % this.localPlayerBaseAddress " / " this.LightPointerOffset
				value := this.mem.read(this.mem.BaseAddress + this.localPlayerBaseAddress, "UInt", this.LightPointerOffset)
				msgbox, % "value = " value
		}
	}

	readItemRefillTest() {
		Gui, Carregando:Destroy
		this.injectClientMemory()

		; msgbox, % this.mem.BaseAddress
		; msgbox, % this.localPlayerBaseAddress
		; msgbox, % this.coordinates.offsets.light
		; msgbox, % this.localPlayerBaseAddress " / " serialize(this.itemRefill)

		; value := this.readMemoryNew({"address": this.itemRefill.boots.address, "debug": true, "info": "itemRefill.boots"}, this.itemRefill.boots.offsets)

		this.readItemRefillItem("ring", "prismatic ring", debug := true)
	}

	readItemXor(value, item, debug := false) {
		if (value = 0)
			return
		if (value = itemsObj[item].itemid) {
			return value
		}
		if (!IsObject(itemsObj[item]))
			throw Exception("Invalid item: " item)

		expectedId := itemsObj[item].itemid
		xorCode := value ^ expectedId
		realValue := xorCode ^ value
		if (debug)
			msgbox, % item " expectedId = " expectedId ", value = " value ", xorCode = " xorCode ", realValue = " realValue
		return realValue
	}

	readHealthTest() {
		this.injectClientMemory()

		; msgbox, % this.mem.BaseAddress
		; msgbox, % this.localPlayerBaseAddress
		; msgbox, % this.coordinates.offsets.light
		; msgbox, % this.localPlayerBaseAddress " / " serialize(this.healing)
		current := this.readHealth("life", true, debug := false)
		total := this.readHealth("life", false, debug := false)
		msgbox, % "life current = " current ", total = " total

		current := this.readHealth("mana", true, debug := false)
		total := this.readHealth("mana", false, debug := false)
		msgbox, % "mana current = " current ", total = " total

	}

	writeLocalPlayerOneOffset(value, offset) {
		this.mem.write(this.mem.BaseAddress + this.localPlayerBaseAddress, value, "Uint", , offset)
	}

	readHealth(lifeOrMana, current := true, debug := false) {
		if (this.mem.BaseAddress = "")
			throw Exception("Empty base address")
		if (this.localPlayerBaseAddress = "")
			throw Exception("Empty player address")

		return this.readMemoryNew({"type": this.healing.type, "debug": debug, "info": lifeOrMana}, (current = true) ? this.healing[lifeOrMana].currentWithOffsets : this.healing[lifeOrMana].totalWithOffsets)
	}

	readPosX() {
		return this.readMemoryPos("X")
		; return this.readMemoryPos("X", GetKeyState("Ctrl"))
	}

	readPosY() {
		return this.readMemoryPos("Y")
	}

	readPosZ() {
		return this.readMemoryPos("Z")
	}

	readMemoryPos(type, debug := false) {
		if (this.coordinates.offsets[type "withOffsets"].Count() < 1) {
			if (debug)
				throw Exception("Invalid ""withOffsets"" for type " type)
			return
		}
		value := this.readMemoryNew({"debug": debug, "bytesReadRaw": this.bytesReadRaw[type], "divide256": this.divide256[type]}, this.coordinates.offsets[type "withOffsets"])

		if (type = "Z") && (value < 0 || value > 15)
			return
		; m(serialize(this.coordinates.offsets[type "withOffsets"]))
		return value
	}

	writeMemoryPos(type, value) {
		if (this.divide256[type] = true) {
			value := value * 256
		}

		return this.writeMemoryNew(value, {"debug": false, "bytesReadRaw": this.bytesReadRaw[type]}, this.coordinates.offsets[type "withOffsets"])
	}

	writePosX(value) {
		return this.writeMemoryPos("X", value)
	}

	writePosY(value) {
		return this.writeMemoryPos("Y", value)
	}

	writePosZ(value) {
		return this.writeMemoryPos("", value)
	}

	readMemoryNew(params, offsets) {
		params.type := (params.type = "") ? "UInt" : params.type
			, params.bytesReadRaw := (params.bytesReadRaw = "") ? 0 : params.bytesReadRaw
			, params.address := (params.address = "") ? this.localPlayerBaseAddress : params.address
			, params.debug := (params.debug = "") ? false : params.debug
			, params.divide256 := (params.divide256 = "") ? false : params.divide256

		; if (offsets.Count() < 1)
		; 	throw exception("No offsets, params:`n" serialize(params))

		if (params.debug)
			msgbox, % serialize(params) "`n`naddress: " params.address " (" (params.address = this.localPlayerBaseAddress) ")" "`n`noffsets:`n" serialize(offsets)
		; msgbox, % "offsets`n" serialize(offsets)

		if (params.bytesReadRaw = 0) {
			if (params.debug)
				msgbox, % this.mem.BaseAddress " + " params.address ", " params.type ", " serialize(offsets)
			value := this.mem.read(this.mem.BaseAddress + params.address, params.type, offsets*)
			if (params.debug)
				msgbox, % "value = " value  "`n`nErrorLevel:" errorLevel "`nLastError:" A_LastError
			return value
		}

		value := "a", byRefCoords := "a"
			, value := ""
			, byRefCoords := ""
		loop, 5 {
			VarSetCapacity(value, 0)
			VarSetCapacity(byRefCoords, 0)
			this.mem.readRaw(this.mem.BaseAddress + params.address, byRefCoords, params.bytesReadRaw, offsets*)
			; this.mem.readRaw(this.mem.BaseAddress + params.address, byRefCoords, params.bytesReadRaw, offsets*) ; asterisk?
			value := NumGet(byRefCoords, Offset := 0, params.type)
			if (params.debug)
				msgbox, % "value: " value "`nbytes readRaw: " params.bytesReadRaw  "`n`nErrorLevel:" errorLevel "`nLastError:" A_LastError

			VarSetCapacity(byRefCoords, 0)
			if (params.divide256 = true) {
				value := value / 256
				if (params.debug)
					msgbox, % "divided: " value
			}
			value2 := value
			if (value2 != "") {
				break
			}
			/**
			assigning random value after clean in case the var still has some weird reference or value
			*/
			value := "a", byRefCoords := "a"
			sleep, 10
			value := ""
				, byRefCoords := ""
		}

		if (params.debug)
			msgbox, % "value2 = " value2

		return value2
	}


	writeMemoryNew(value, params, offsets) {
		params.type := (params.type = "") ? "UInt" : params.type
			, params.address := (params.address = "") ? this.localPlayerBaseAddress : params.address
			, params.bytesReadRaw := (params.bytesReadRaw = "") ? 0 : params.bytesReadRaw
			, params.debug := (params.debug = "") ? false : params.debug

		; if (offsets.Count() < 1)
		; 	throw exception("No offsets, params:`n" serialize(params))

		if (params.debug)
			msgbox, % serialize(params) "`n`noffsets:`n" serialize(offsets)
		; msgbox, % "offsets`n" serialize(offsets)

		return this.mem.write(this.mem.BaseAddress + params.address, value, params.type, offsets*)
	}

	ReadMemory(MADDRESS, pOffset = 0) {
		; Process, wait, %PROGRAM%, 0.5
		; WinGet, test, PID, A
		WinGet, pid, PID, % "ahk_id " TibiaClientID
		; Process, wait, % "ahk_id " TibiaClientID, 0.5
		; pid = %ErrorLevel%
		; msgbox, % A_ThisFunc "`n" pid " / " TibiaClientID
		if (pid = 0 pid = "")
			return

		VarSetCapacity(MVALUE,4)
		ProcessHandle := DllCall("OpenProcess", "Int", 24, "Char", 0, "UInt", pid, "UInt")
		try DllCall("ReadProcessMemory", "UInt", ProcessHandle, "UInt", MADDRESS+pOffset, "Str", MVALUE, "Uint",4, "Uint *",0)
		catch {
		}
		try DllCall("CloseHandle", "int", ProcessHandle)
		catch {
		}
		Loop 4
			result += *(&MVALUE + A_Index-1) << 8*(A_Index-1)

		return result
	}

	DecToHex(Value) {
		SetFormat IntegerFast, Hex
		Value += 0
		Value .= "" ;required due to 'fast' mode
		SetFormat IntegerFast, D
		return Value
	}


	;WindowTitle can be anything ahk_exe ahk_class etc
	; getProcessBaseAddress(WindowTitle, Hex=1, MatchMode=3) {
	getProcessBaseAddress(Hex=1, MatchMode=3) {
		; SetTitleMatchMode, %MatchMode%    ;mode 3 is an exact match
		; WinGet, hWnd, ID, %WindowTitle%
		; msgbox, % A_ThisFunc "`n" TibiaClientID
		if (TibiaClientID = 0 OR TibiaClientID = "")
			return
		; AHK32Bit A_PtrSize = 4 | AHK64Bit - 8 bytes
		BaseAddress := DllCall(A_PtrSize = 4
			? "GetWindowLong"
			: "GetWindowLongPtr", "Uint", TibiaClientID, "Uint", -6)
		if Hex
			return this.dectohex(BaseAddress)
		else return BaseAddress
	}

	WriteProcessMemory(win_id, addr, addr_value, addr_offset = 0, value_size = 4) {
		if (win_id > 0)
		{
			addr += addr_offset

			WinGet, proc_id, PID, ahk_id %win_id%
			try ProcessHandle := DllCall("OpenProcess", "UInt", 0x28, "char", 0, "UInt", proc_id, "UInt")
			catch {
			}

			try write_success := DllCall("WriteProcessMemory", "UInt", ProcessHandle, "UInt", addr, "UInt *", addr_value, "Uint", value_size, "Uint *", BytesWritten)
			catch {
			}

			try DllCall("CloseHandle", "int", ProcessHandle)
			catch {
			}
		}

		return, % write_success
	}

	ReadMemory_Str(MADDRESS=0, pOffset = 0, PROGRAM = "AssaultCube", length = 0 , terminator = "") {
		Static OLDPROC, ProcessHandle
		VarSetCapacity(MVALUE,4,0)
		If PROGRAM != %OLDPROC%
		{
			WinGet, pid, pid, % OLDPROC := PROGRAM
			ProcessHandle := ( ProcessHandle ? 0*(closed:=DllCall("CloseHandle"
						,"UInt",ProcessHandle)) : 0 )+(pid ? DllCall("OpenProcess"
					,"Int",16,"Int",0,"UInt",pid) : 0) ;PID is stored in value pid
		}
		If (MADDRESS = 0) ; the above expression/syntax does my head, hence easy close handle
			closed:=DllCall("CloseHandle","UInt",ProcessHandle)
		If ( length = 0) ; read until terminator found
		{
			teststr =
			Loop
			{
				Output := "x"  ; Put exactly one character in as a placeholder. used to break loop on null
				tempVar := DllCall("ReadProcessMemory", "UInt", ProcessHandle, "UInt", MADDRESS+pOffset, "str", Output, "Uint", 1, "Uint *", 0)
				if (ErrorLevel or !tempVar)
					return teststr
				if (Output = terminator)
					break
				teststr .= Output
				MADDRESS++
			}
			return, teststr
		}
		Else ; will read until X length
		{
			teststr =
			Loop % length
			{
				Output := "x"  ; Put exactly one character in as a memory placeholder.
				tempVar := DllCall("ReadProcessMemory", "UInt", ProcessHandle, "UInt", MADDRESS+pOffset, "str", Output, "Uint", 1, "Uint *", 0)
				if (ErrorLevel or !tempVar)
					return teststr
				teststr .= Output
				MADDRESS++
			}
			return, teststr
		}
	}

	healingMemory()
	{
		if (TibiaClient.getClientIdentifier(true) = "monsterhunter") {
			return true
		}

		if (OldBotSettings.settingsJsonObj.files.memory.healing) {
			return true
		}


		return false
	}

	readItemRefillItem(item, itemName, debug := false) {
		value := this.readMemoryNew({"address": this.itemRefill[item].address, "debug": debug, "info": "itemRefill." item}, this.itemRefill.ring.offsets)
		; msgbox, % "value = " value

		value2 := this.readItemXor(value, itemName, debug)
		if (debug)
			msgbox, % "value2 = " value2
		return value2
	}

	testItemRefillRing() {

		OldBotSettings.stopFunction("itemRefill", "ringRefillEnabled")
		itemName := "Energy Ring"

		equippedItemId := this.readItemRefillItem("ring", itemName, debug := true)
		m("equippedItemId = " equippedItemId)
		if (equippedItemId = itemsObj[itemName].itemid) {
			msgbox, 64,, % "It's working!`nEquipped item id: " equippedItemId "`nItem name: " itemName
			return true
		}



		loop, % this.moduleJsonFolder "\itemRefill*"
		{
			this.itemRefillFile := StrReplace(A_LoopFileName, ".json", "")

			this.setItemRefillAdressses()
			equippedItemId := this.readItemRefillItem("ring", itemName, debug := true)
			m("equippedItemId = " equippedItemId "`n`n" A_LoopFileName)

			if (equippedItemId != itemsObj[itemName].itemid) {
				continue
			}

			this.memoryJsonFileObj.m := {"itemRefill": this.itemRefillFile}
			this.memoryJsonFile.Fill(this.memoryJsonFileObj)
			this.memoryJsonFile.Save(true)

			msgbox, 64,, % txt("Está funcionando agora! Inicie o Ring Refill novamente.`n`nItem equipado: ", "It's working now! Start the Ring Refill again.`n`nEquipped item: " ) itemName "`nID: " itemsObj[itemName].itemid "`n`nFile: " this.itemRefillFile
			return true
		}

		msgbox, 16,, % txt("Falha ao configurar Ring Refill por injeção de memória para o esse cliente, por favor contate o suporte.", "Failed to setup Ring item refill memory injection for this client, please contact support.") "`n`nClient: " TibiaClient.getClientIdentifier(true)

		return false


	}









} ; class
