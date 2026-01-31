

class _DistanceLooting
{
	static DISTANCE_LIMIT := 8

	__New()
	{
		if (!IsObject(LootingSystem))
			throw Exception("LootingSystem not initialized.")
		this.queue := {}

		this.lootedCoords := {}

		this.windowX := 553
		this.windowY := 163
	}

	runLootingQueue()
	{
		if (!this.queue.Count()) {
			writeCavebotLog("Looting", txt("Nenhuma coordenada de criatura atacada detectada. Looteando SQMs em volta do char", "No coordinate of attacked creature detected. Looting SQMs around the characer"))	
			LootingSystem.lootAroundFromTargeting()
			return false
		}

		this.beforeRunLootingQueue()

		LootingSystem.lootCharacterSqm := true
		queueCount := this.queue.Count()

		Loop, % this.queue.Count() {
			this.sortQueueByDistanceFromChar()
			lootingCoords := this.queue[1]
			string := A_index "/" queueCount " (" lootingCoords.x "," lootingCoords.y "," lootingCoords.z ")"
			if (isDisconnected()) {
				writeCavebotLog("Looting", txt("Char está desconectado, abortando looting", "Character is disconnected, aborting looting") )	
				break
			}

			if (this.isInLootedCoords(lootingCoords)) {
				this.queue.RemoveAt(1)
				continue
			}

			if (this.walkToLootingCoord(lootingCoords, string) = false) {
				writeCavebotLog("Looting", txt("Falha ao caminhar até a coordenada de looting ", "Failed to walk to the looting coordinate " ) string )	
				continue
			}

			writeCavebotLog("Looting", txt("Looteando posição da queue ", "Looting queue position " ) string )	
			LootingSystem.lootAroundFromTargeting()
			this.addCoordsToQueue(lootingCoords)
			this.addToLootedCoords(lootingCoords)

			this.queue.RemoveAt(1)
		}

		this.afterLootingCoordinates()
	}

	addCoordsToQueue(lootingCoords)
	{
		try {
			if (CavebotWalker.isCoordWalkable(lootingCoords.x, lootingCoords.y, lootingCoords.z) = false) {
				writeCavebotLog("WARNING", txt("Coordenada de looting não é caminhável: ", "Looting coordinate is not walkable: ") lootingCoords.x "," lootingCoords.y "," lootingCoords.z)	
				return false 
			}
		} catch e {
			writeCavebotLog("ERROR", A_ThisFunc " (1): " e.Message " | " e.What) 
			return false 
		}

		if (this.getCoordsIndexFromQueue(lootingCoords) > 0)
			return false

		if (this.isInLootedCoords(lootingCoords))
			return false

		this.queue.Push(lootingCoords)
		return true
	}

	getCoordsIndexFromQueue(lootingCoords)
	{
		for key, value in this.queue
		{
			if (value.x = lootingCoords.x) && (value.y = lootingCoords.y)
				return key
		}

		return -1
	}

	removeFromQueue(lootingCoords)
	{
		index := this.getCoordsIndexFromQueue(lootingCoords)
		if (index > 0) {
			this.queue.RemoveAt(index)
		}
	}

	addCoordsFromDeadCreaturePos(screenPosX, screenPosY)
	{
		if (!screenPosX OR !screenPosY) {
			return false
		}

		lootingCoords := _MapCoordinate.FROM_SCREEN_POS(screenPosX, screenPosY)

		if (CavebotWalker.isWaypointTooFar(lootingCoords.x, lootingCoords.y, lootingCoords.z, posx, posy, posz, ignoreZ := true, false, false)) {
			return false
		}

		if (this.isTooDistant(lootingCoords)) {
			return false
		}

		lootingCoords.z := posz
		this.addCoordsToQueue(lootingCoords)

		return true
	}

	isTooDistant(coords)
	{
		distance := lootingCoords.getDistance(posx, posy)

		return distance >= this.DISTANCE_LIMIT
	}

	addCoordsFromCreatureCorpse(waitDelay := true)
	{
		corpsesFound := {}
		if (!IsObject(TargetingSystem.corpseScriptImages))
			TargetingSystem.createCorpseImagesArray()

		if (waitDelay = true) && (LootingSystem.lootingJsonObj.delays.delayBeforeSearchingForCorpseImages > 0)
			Sleep, % LootingSystem.lootingJsonObj.delays.delayBeforeSearchingForCorpseImages

		for key, imageName in TargetingSystem.corpseScriptImages 
		{
			atributes := scriptImagesObj[imageName]
			; msgbox, % imageName "`n" atributes.category "`n" serialize(atributes)
			_search := TargetingSystem.searchCorpseScriptImage(imageName, firstResult := false)
			; m(imageName "`n" serialize(_search))

			if (_search.getResultsCount() < 1)
				continue

			for _, coordinate in _search
				corpsesFound.Push(coordinate)
		}
		; m(serialize(corpsesFound))

		if (corpsesFound.Count() = 0) {
			writeCavebotLog("Looting", txt("Nenhuma imagem de ""Corpse"" encontrada", " No ""Corpse"" images found") " (delay: " LootingSystem.lootingJsonObj.delays.delayBeforeSearchingForCorpseImages "ms)")	
		} else {
			writeCavebotLog("Looting", corpsesFound.Count() txt(" imagens de ""Corpse"" encontradas", " ""Corpse"" images found") " (delay: " LootingSystem.lootingJsonObj.delays.delayBeforeSearchingForCorpseImages "ms)")
		}

		for key, vars in corpsesFound
		{
			lootingCoords := _MapCoordinate.FROM_SCREEN_POS(screenPosX, screenPosY)
			if (CavebotWalker.isWaypointTooFar(lootingCoords.x, lootingCoords.y, lootingCoords.z, posx, posy, posz, ignoreZ := true, false, false) = true)
				continue


			if (this.isTooDistant(lootingCoords)) {
				continue
			}

			/*
			if is already in the queue(may be because looting by position already added it), skip it
			*/ 
			if (this.getCoordsIndexFromQueue(lootingCoords) > 0)
				continue

			lootingCoords.type := "corpse"
			lootingCoords.z := posz

			this.addCoordsToQueue(lootingCoords)
		}

		; m(serialize(this.queue))
	}

	sortQueueByDistanceFromChar()
	{
		distanceQueue := "", distanceQueue := {}
		for key, lootingCoords in this.queue {
			distX := abs(posx - lootingCoords.x)
				, distY := abs(posy - lootingCoords.y)
				, distance := distX + distY
			if (!IsObject(distanceQueue[distance]))
				distanceQueue[distance] := {}
			distanceQueue[distance].Push(lootingCoords)
			;msgbox, % distX "," distY " / " distance "`n`n" serialize(distanceQueue)
		}

		this.queue := "", this.queue := {}
		for distance, value in distanceQueue {
			for key, lootingCoords in value
				this.queue.Push(lootingCoords)
		}
		distanceQueue := ""
	}

	isInLootedCoords(lootingCoords)
	{
		for key, value in this.lootedCoords {
			if (value.x = lootingCoords.x && value.y = lootingCoords.y) {

				return true
			}
		}

		return false
	}

	addToLootedCoords(lootingCoords)
	{
		lootingCoords.time := A_TickCount

		this.lootedCoords.Push(lootingCoords)
		; NW
		this.lootedCoords.Push({"x": lootingCoords.x - 1, "y": lootingCoords.y - 1})
		; N
		this.lootedCoords.Push({"x": lootingCoords.x, "y": lootingCoords.y - 1})
		; NE
		this.lootedCoords.Push({"x": lootingCoords.x + 1, "y": lootingCoords.y - 1})
		; W
		this.lootedCoords.Push({"x": lootingCoords.x - 1, "y": lootingCoords.y})
		; E
		this.lootedCoords.Push({"x": lootingCoords.x + 1, "y": lootingCoords.y})
		; SW
		this.lootedCoords.Push({"x": lootingCoords.x - 1, "y": lootingCoords.y + 1})
		; S
		this.lootedCoords.Push({"x": lootingCoords.x, "y": lootingCoords.y + 1})
		; SE
		this.lootedCoords.Push({"x": lootingCoords.x + 1, "y": lootingCoords.y + 1})
	}

	afterLootingCoordinates()
	{
		this.queue := {}
		this.lootedCoords := {}
		LootingSystem.lootCharacterSqm := false

		this.runAfterLootingQueueAction()
	}

	walkToLootingCoord(lootingCoords, string) {
		global
		writeCavebotLog("Looting", txt("Caminhando para posição da queue ", "Walking to queue position " ) string )	

		mapCoord := new _MapCoordinate(lootingCoords.x - 1, lootingCoords.y - 1, lootingCoords.z, 3, 3)
		; .showOnScreen()
		; Sleep, 100
		; mapCoord.destroyOnScreen()
		result := new _WalkToCoordinate(mapCoord, {}, {}).run()

		return result

		if (walkToWaypoint() = false)
			return false

		return true	
	}

	beforeRunLootingQueue()
	{
		writeCavebotLog("Looting", txt("Iniciando queue, " this.queue.Count() " posições para lootear", "Starting queue, " this.queue.Count() " positions to loot"))

		this.runBeforeLootingQueueAction()
	}

	runBeforeLootingQueueAction()
	{
		if (!waypointsObj.HasKey("Special"))
			return
		ActionScript.runactionwaypoint({1: "BeforeLootingQueue", 2: "Special"}, log := false)
	}

	runAfterLootingQueueAction()
	{
		if (!waypointsObj.HasKey("Special"))
			return
		ActionScript.runactionwaypoint({1: "AfterLootingQueue", 2: "Special"}, log := false)
	}


}

