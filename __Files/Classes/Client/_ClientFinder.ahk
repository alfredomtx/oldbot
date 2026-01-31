global CLIENT_FINDER_CLIENT := false

class _ClientFinder
{
	__New()
	{
		; window := this.spyWindowUnderMouse()

		/**

		*/

		if (A_IsCompiled)
			return
		; return

		; Gui, Carregando:Destroy

		; TibiaClient.windowTitleSearch := "Rivalia Online"
		; TibiaClient.windowClassFilter := "Rivalia Online"

		; this.findCurrentClient()
	}

	findCurrentClient()
	{
		if (this.setupClientWindow() = false)
			return

		this.setupBasicSettings()

		this.findBackpack()

		; ;
		this.findLifeBar()
		this.findBattleListTitle()
		this.findBattleListEmpty()
		; this.findBattleListButton()
		this.findMinimapCenter()
		this.findMinimapZoomMinus()

		this.findStatusBar()
		this.findHandSlot()
		this.findPzZone()

		this.findUse()
		this.findOpen()
		this.findFollow()
		this.findExit()
		; this.findChatButton()
		; this.findLifeBarBattleList()

		this.find100Gold()
		this.find100Platinum()
	}

	setupClientWindow() {
		CLIENT_FINDER_CLIENT := true
		if (TibiaClient.autoSelectFirstClient(false) = false) {
			Msgbox, 48, % A_ThisFunc, % "Failed to auto select Tibia Client."
			return false
		}

		if (!TibiaClientID) {
			Msgbox, 48, % A_ThisFunc, % "Empty Tibia Client ID."
			return false
		}

		return true

	}

	setupBasicSettings() {
		OldBotSettings.settingsJsonObj.input.defaultImageSearch := false

	}

	getClientFromImageName(fileName, imageName) {

		string := StrReplace(fileName, imageName, "")
		client := StrReplace(string, ".png", "")

		if (client = "")
			throw Exception("Unable to find client name:`n- " fileName "`n- " imageName)

		return client
	}

	getClientsListFromImagesFound(imagesFound, imageName) {

		clientsList := {}
		for key, image in imagesFound
		{
			client := this.getClientFromImageName(image.name, imageName)
			clientsList.Push(client)

		}

		return clientsList

	}

	findImage(params) {

		func := params.func
		folder := params.folder
		imageName := params.imageName
		ignoreFileName := params.ignoreFileName
		variation := (params.variation != "") ? params.variation : 60

		if (folder = "")
			msgbox, 16,, % "Empty folder"
		; if (imageName = "")
		; 	msgbox, 16,, % "Empty imageName"

		if (InStr(imageName, ".png")) {
			imageName := StrReplace(imageName, ".png", "")
		}

		if (!imageName) {
			throw Exception("Empty image name")
		}

		imagesFound := {}
		Loop, % folder "/" imageName "*.png" {

			if (ignoreFileName != "") && (InStr(A_LoopFileName, ignoreFileName))
				continue

			; msgbox, % A_LoopFileName
			try {
				vars := ImageClick({"image": A_LoopFileName
						, "directory": folder
						, "variation": variation
						, "debug": params.debug})
			} catch e {
				Msgbox, 16, % func, % e.Message "`n" e.What
				continue
			}

			if (!vars.x)
				continue

			imagesFound.Push({name: A_LoopFileName, x: vars.x, y: vars.y})


			; msgbox,64, % func, % "Found: " A_LoopFileName
		}

		if (imagesFound.Count() = 0)
			return false

		return imagesFound
	}


	imageSearch(file, folder, variation, debug)
	{
		return new _ImageSearch()
			.setFolder(folder)
			.setVariation(variation)
			.setDebug(debug)
			.setFile(file)
			.search()

	}

	findBackpack()
	{
		loop, % _Folders.JSON_CONTAINERS "\*.json" {
			data := _Json.load(file := A_LoopFileFullPath)
			for _, image in data.backpack.list {
				if (InStr(image, "bag")) {
					continue
				}
				search := this.imageSearch(image, ImagesConfig.mainBackpacksFolder, _ItemsHandler.isWordBackpack(image) ? _ItemsHandler.WORD_BACKPACK_VARIATION : 60, false)
				if (search.found()) {
					msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
					; return
				}
			}
		}

		data := _Json.load(file := _Folders.JSON_LOOTING "\otclient_word_bp_images.json")
		for _, image in data.mainBackpacks.backpacksList {
			search := this.imageSearch(image, ImagesConfig.mainBackpacksFolder, _ItemsHandler.isWordBackpack(image) ? _ItemsHandler.WORD_BACKPACK_VARIATION : 60, false)
			if (search.found()) {
				msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
				; return
			}
		}

		data := _Json.load(file := _Folders.JSON_LOOTING "\otclient.json")
		for _, image in data.mainBackpacks.backpacksList {
			search := this.imageSearch(image, ImagesConfig.mainBackpacksFolder, 60, false)
			if (search.found()) {
				msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
				; return
			}
		}

		data := _Json.load(file := _Folders.JSON_LOOTING "\otclient_classic.json")
		for _, image in data.mainBackpacks.backpacksList {
			search := this.imageSearch(image, ImagesConfig.mainBackpacksFolder, 60, false)
			if (search.found()) {
				msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
				; return
			}
		}

		imagesFound := this.findImage({"folder": ImagesConfig.mainBackpacksFolder, "imageName": "backpack_", "func": A_ThisFunc, "debug": false})
		if (imagesFound) {
			msgbox, 64, % A_ThisFunc, % serialize(imagesFound)
			; return
		}

		imagesFound := this.findImage({"folder": ImagesConfig.mainBackpacksFolder, "imageName": "bag_", "func": A_ThisFunc, "debug": false})
		if (imagesFound) {
			msgbox, 64, % A_ThisFunc, % serialize(imagesFound)
			; return
		}
	}

	findMinimapZoomMinus()
	{
		Loop, % _Folders.JSON_MINIMAP "\mp_*.json" {
			file := A_LoopFileName
			data := _Json.load(A_LoopFilePath)
			try {
				imagesFound := this.findImage({"folder": ImagesConfig.minimapZoomMinusFolder, "imageName": image := data.images.zoomMinus, "func": A_ThisFunc})
			} catch e {
				_Logger.msgboxException(16, e, file)
			}
			if (imagesFound) {
				msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
			}
		}

		imageName := "zoom_minus_"
		imagesFound := this.findImage({"folder": ImagesConfig.minimapZoomMinusFolder, "imageName": imageName, "func": A_ThisFunc})

		if (imagesFound = false) {
			Msgbox, 48, % A_ThisFunc, % "No images found."
			return false
		}
		clientsList := this.getClientsListFromImagesFound(imagesFound, imageName)
		msgbox, 64, % A_ThisFunc, % serialize(imagesFound) "`n`n" serialize(clientsList)
	}

	findMinimapCenter()
	{
		Loop, % _Folders.JSON_MINIMAP "\mp_*.json" {
			file := A_LoopFileName
			data := _Json.load(A_LoopFilePath)
			try {
				imagesFound := this.findImage({"folder": ImagesConfig.minimapCenterFolder, "imageName": image := data.images.center, "func": A_ThisFunc})
			} catch e {
				_Logger.msgboxException(16, e, file)
			}
			if (imagesFound) {
				msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
			}
		}

		; data := _Json.load(file := _Folders.JSON_CAVEBOT "\otclient.json")
		; imagesFound := this.findImage({"folder": ImagesConfig.minimapCenterFolder, "imageName": image := data.minimap.images.center, "func": A_ThisFunc})
		; if (imagesFound) {
		; 	msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
		; 	return
		; }

		data := _Json.load(file := _Folders.JSON_CAVEBOT "\otclient_classic.json")
		imagesFound := this.findImage({"folder": ImagesConfig.minimapCenterFolder, "imageName": image := data.minimap.images.center, "func": A_ThisFunc})
		if (imagesFound) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
			return
		}

		imagesFound := this.findImage({"folder": ImagesConfig.minimapCenterFolder, "imageName": image := "otclient_small.png", "func": A_ThisFunc})
		if (imagesFound) {
			msgbox, 64, % A_ThisFunc, % "Found: " image
			return
		}


		imageName := "center_"
		imagesFound := this.findImage({"folder": ImagesConfig.minimapCenterFolder, "imageName": imageName, "func": A_ThisFunc})

		if (imagesFound = false) {
			Msgbox, 48, % A_ThisFunc, % "No images found."
			return false
		}
		clientsList := this.getClientsListFromImagesFound(imagesFound, imageName)
		msgbox, 64, % A_ThisFunc, % serialize(imagesFound) "`n`n" serialize(clientsList)
	}


	findStatusBar()
	{
		data := _Json.load(file := _Folders.JSON_SUPPORT "\otclient.json")
		search := this.imageSearch(image := data.statusBarAreaSetup.baseImage, ImagesConfig.supportFolder, data.statusBarAreaSetup.baseImageVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
		}

		data := _Json.load(file := _Folders.JSON_SUPPORT "\otclient_classic.json")
		search := this.imageSearch(image := data.statusBarAreaSetup.baseImage, ImagesConfig.supportFolder, data.statusBarAreaSetup.baseImageVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
		}

		data := _Json.load(file := _Folders.JSON_SUPPORT "\otclient_classic_small.json")
		search := this.imageSearch(image := data.statusBarAreaSetup.baseImage, ImagesConfig.supportFolder, data.statusBarAreaSetup.baseImageVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
		}


		data := _Json.load(file := _Folders.JSON_SUPPORT "\otclient_tall.json")
		search := this.imageSearch(image := data.statusBarAreaSetup.baseImage, ImagesConfig.supportFolder, data.statusBarAreaSetup.baseImageVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
		}


		imageName := "base_image_"

		imagesFound := this.findImage({"folder": ImagesConfig.supportFolder, "imageName": imageName, "func": A_ThisFunc})

		if (imagesFound = false) {
			Msgbox, 48, % A_ThisFunc, % "No images found."
			return false
		}

		clientsList := this.getClientsListFromImagesFound(imagesFound, imageName)

		msgbox, 64, % A_ThisFunc, % serialize(imagesFound) "`n`n" serialize(clientsList)
	}


	findBattleListEmpty()
	{
		data := _Json.load(file := _Folders.JSON_TARGETING "\otclient.json")
		search := this.imageSearch(image := data.battleListImages.emptyImage, ImagesConfig.battleListEmptyFolder, data.battleListImages.emptyImageVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
			return
		}
		data := _Json.load(file := _Folders.JSON_TARGETING "\otclient_classic.json")
		search := this.imageSearch(image := data.battleListImages.emptyImage, ImagesConfig.battleListEmptyFolder, data.battleListImages.emptyImageVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
			return
		}


		imagesFound := this.findImage({"folder": ImagesConfig.battleListEmptyFolder, "imageName": "*", "func": A_ThisFunc})

		if (imagesFound = false) {
			Msgbox, 48, % A_ThisFunc, % "No images found."
			return false
		}
		clientsList := this.getClientsListFromImagesFound(imagesFound, imageName)
		msgbox, 64, % A_ThisFunc, % serialize(imagesFound) "`n`n" serialize(clientsList)
	}

	findBattleListTitle()
	{
		data := _Json.load(file := _Folders.JSON_TARGETING "\otclient.json")
		search := this.imageSearch(image := data.battleListImages.baseImage, ImagesConfig.battleListTitleFolder, data.battleListImages.baseImageVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
			return
		}

		data := _Json.load(file := _Folders.JSON_TARGETING "\otclient_classic.json")
		search := this.imageSearch(image := data.battleListImages.baseImage, ImagesConfig.battleListTitleFolder, data.battleListImages.baseImageVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
			return
		}

		imagesFound := this.findImage({"folder": ImagesConfig.battleListTitleFolder, "imageName": "*", "func": A_ThisFunc})

		if (imagesFound = false) {
			Msgbox, 48, % A_ThisFunc, % "No images found."
			return false
		}
		clientsList := this.getClientsListFromImagesFound(imagesFound, imageName)
		msgbox, 64, % A_ThisFunc, % serialize(imagesFound) "`n`n" serialize(clientsList)
	}

	findBattleListButton()
	{
		data := _Json.load(file := _Folders.JSON_TARGETING "\otclient.json")
		search := this.imageSearch(image := data.battleListImages.battleListButtonsVisible, ImagesConfig.battleListButtonsFolder, data.battleListImages.battleListButtonsVisibleVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
			return
		}

		search := this.imageSearch(image := data.battleListImages.battleListButtonsVisible2, ImagesConfig.battleListButtonsFolder, data.battleListImages.battleListButtonsVisibleVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
			return
		}

		data := _Json.load(file := _Folders.JSON_TARGETING "\otclient_classic.json")
		search := this.imageSearch(image := data.battleListImages.battleListButtonsVisible, ImagesConfig.battleListButtonsFolder, data.battleListImages.battleListButtonsVisibleVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
			return
		}

		search := this.imageSearch(image := data.battleListImages.battleListButtonsVisible2, ImagesConfig.battleListButtonsFolder, data.battleListImages.battleListButtonsVisibleVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
			return
		}

		imageName := "*"
		imagesFound := this.findImage({"folder": ImagesConfig.battleListButtonsFolder, "imageName": imageName, "func": A_ThisFunc})

		if (imagesFound = false) {
			Msgbox, 48, % A_ThisFunc, % "No images found."
			return false
		}
		clientsList := this.getClientsListFromImagesFound(imagesFound, imageName)
		msgbox, 64, % A_ThisFunc, % serialize(imagesFound) "`n`n" serialize(clientsList)
	}

	findLifeBar()
	{
		data := _Json.load(file := _Folders.JSON_HEALING "\otclient.json")
		search := this.imageSearch(image := data.options.baseImage, ImagesConfig.healingLifeBarFolder, data.life.pixelVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
		}

		data := _Json.load(file := _Folders.JSON_HEALING "\otclient_classic.json")
		search := this.imageSearch(image := data.options.baseImage, ImagesConfig.healingLifeBarFolder, data.life.pixelVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
		}

		data := _Json.load(file := _Folders.JSON_HEALING "\otclient_strong_color.json")
		search := this.imageSearch(image := data.options.baseImage, ImagesConfig.healingLifeBarFolder, data.life.pixelVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
		}

		data := _Json.load(file := _Folders.JSON_HEALING "\otclient_large.json")
		search := this.imageSearch(image := data.options.baseImage, ImagesConfig.healingLifeBarFolder, data.life.pixelVariation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
		}

		imagesFound := this.findImage({"folder": ImagesConfig.healingLifeBarFolder, "imageName": "*", "func": A_ThisFunc})

		if (imagesFound = false) {
			Msgbox, 48, % A_ThisFunc, % "No images found."
		}
		clientsList := this.getClientsListFromImagesFound(imagesFound, imageName)
		msgbox, 64, % A_ThisFunc, % serialize(imagesFound) "`n`n" serialize(clientsList)
	}


	findOpen()
	{
		data := _Json.load(file := _Folders.JSON_CLIENT_MENUS "\cm_otclient_classic.json")
		search := this.imageSearch(image := data.openCorpse.image, ImagesConfig.clientOpenMenuFolder, data.openCorpse.variation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
			return
		}

		data := _Json.load(file := _Folders.JSON_CLIENT_MENUS "\cm_otclient.json")
		search := this.imageSearch(image := data.openCorpse.image, ImagesConfig.clientOpenMenuFolder, data.openCorpse.variation, false)
		if (search.found()) {
			msgbox, 64, % A_ThisFunc, % "Found: " image "`n" file
			return
		}


		msgbox, 48,, % "findOpen() time, click on sqm"
		imageName := "open_"
		imagesFound := this.findImage({"folder": ImagesConfig.clientOpenMenuFolder, "imageName": imageName, "func": A_ThisFunc})

		if (imagesFound = false) {
			Msgbox, 48, % A_ThisFunc, % "No images found."
			return false
		}
		clientsList := this.getClientsListFromImagesFound(imagesFound, imageName)
		msgbox, 64, % A_ThisFunc, % serialize(imagesFound) "`n`n" serialize(clientsList)
	}




	findHandSlot() {
		msgbox, will search for left hand slot
		imageName := "hand_"
		imagesFound := this.findImage({"folder": _LeftHandArea.resolveImageFolder(), "imageName": imageName, "func": A_ThisFunc})

		if (imagesFound = false) {
			Msgbox, 48, % A_ThisFunc, % "No images found."
			return false
		}
		clientsList := this.getClientsListFromImagesFound(imagesFound, imageName)
		msgbox, 64, % A_ThisFunc, % serialize(imagesFound) "`n`n" serialize(clientsList)
	}

	find100Gold() {
		imageName := "100_gold_coin"
		imagesFound := this.findImage({"folder": ImagesConfig.cavebotFolder, "imageName": imageName, "func": A_ThisFunc})

		if (imagesFound = false) {
			Msgbox, 48, % A_ThisFunc, % "No images found."
			return false
		}
		clientsList := this.getClientsListFromImagesFound(imagesFound, imageName)
		msgbox, 64, % A_ThisFunc, % serialize(imagesFound) "`n`n" serialize(clientsList)
	}

	find100Platinum() {
		imageName := "100_platinum_coin"
		imagesFound := this.findImage({"folder": ImagesConfig.cavebotFolder, "imageName": imageName, "func": A_ThisFunc})

		if (imagesFound = false) {
			Msgbox, 48, % A_ThisFunc, % "No images found."
			return false
		}
		clientsList := this.getClientsListFromImagesFound(imagesFound, imageName)
		msgbox, 64, % A_ThisFunc, % serialize(imagesFound) "`n`n" serialize(clientsList)
	}

	findUse() {
		msgbox, 48,, % "findUse() time, click on sqm"
		imageName := "use_"
		imagesFound := this.findImage({"folder": ImagesConfig.clientMenusFolder "\use", "imageName": imageName, "func": A_ThisFunc})

		if (imagesFound = false) {
			Msgbox, 48, % A_ThisFunc, % "No images found."
			return false
		}
		clientsList := this.getClientsListFromImagesFound(imagesFound, imageName)
		msgbox, 64, % A_ThisFunc, % serialize(imagesFound) "`n`n" serialize(clientsList)
	}


	findFollow() {
		msgbox, 48,, % "findFollow() time, show menu"
		imageName := "follow_"
		imagesFound := this.findImage({"folder": ImagesConfig.clientMenusFolder "\follow", "imageName": imageName, "func": A_ThisFunc})

		if (imagesFound = false) {
			Msgbox, 48, % A_ThisFunc, % "No images found."
			return false
		}
		clientsList := this.getClientsListFromImagesFound(imagesFound, imageName)
		msgbox, 64, % A_ThisFunc, % serialize(imagesFound) "`n`n" serialize(clientsList)
	}

	findExit() {
		msgbox, 48,, % "findExit() time, show menu"
		imageName := "exit_"
		imagesFound := this.findImage({"folder": ImagesConfig.clientButtonsFolder, "imageName": imageName, "func": A_ThisFunc})

		if (imagesFound = false) {
			Msgbox, 48, % A_ThisFunc, % "No images found."
			return false
		}
		clientsList := this.getClientsListFromImagesFound(imagesFound, imageName)
		msgbox, 64, % A_ThisFunc, % serialize(imagesFound) "`n`n" serialize(clientsList)
	}

	findPzZone() {
		imageName := "pz_zone"
		imagesFound := this.findImage({"folder": ImagesConfig.statusBarFolder, "imageName": imageName, "func": A_ThisFunc})

		if (imagesFound = false) {
			Msgbox, 48, % A_ThisFunc, % "No images found."
			return false
		}
		clientsList := this.getClientsListFromImagesFound(imagesFound, imageName)
		msgbox, 64, % A_ThisFunc, % serialize(imagesFound) "`n`n" serialize(clientsList)
	}


	setupHealingJsonFile() {

		this.lifeBarImage := "life_bar_ardera"
		this.manaBarImage := "mana_bar_ardera"


	}

	spyWindowUnderMouse()
	{
		ToolTip, Move mouse over a window and left-click to capture its title/class. Press ESC to cancel.
		Loop
		{
			if GetKeyState("Esc", "P")
			{
				ToolTip
				return false
			}
			MouseGetPos,,, winID
			WinGetTitle, winTitle, ahk_id %winID%
			WinGetClass, winClass, ahk_id %winID%
			ToolTip, % "Window Title: " winTitle "`nWindow Class: " winClass "`n(Left-click to select, ESC to cancel)"
			if GetKeyState("LButton", "P")
			{
				ToolTip
				return {"title": winTitle, "class": winClass}
			}

			Sleep, 50
		}
	}

}
