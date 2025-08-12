class_name Game extends Node2D

@onready var tilemapDisplay := $TilemapDisplay
@onready var ui := $CanvasLayer/UI

@export var gameSize : Vector2i
@export var gameHeight: int
@export var noise : FastNoiseLite

var tilemap : GameTilemap

var turn : int = 0
var gameEnded: bool = false

class Player:
	var resources : Dictionary[StringName, ResourceScripts.RResource]
	var score : int
	var buildingCount : int
	var cityCount : int
	var workingBuildingCount : int
	var platformCount : int
	var rainPerTurn : float
	var rainNextTurn : float
	var favor : float
	var grace : int
	var effects : Dictionary[StringName, int]
	
	func _init():
		self.resources = {
			&"Food": ResourceScripts.RResource.new(&"Food", 4, false),
			&"Earth": ResourceScripts.RResource.new(&"Earth", 4, false),
			#&"Bronze": ResourceScripts.RResource.new(&"Bronze", 0, false),
			&"Labor": ResourceScripts.RResource.new(&"Labor", 2, true)}
		self.score = 0
		self.buildingCount = 0
		self.cityCount = 0
		self.workingBuildingCount = 0
		self.platformCount = 0
		self.rainPerTurn = 10
		self.rainNextTurn = self.rainPerTurn
		self.favor = 0.4
		self.grace = 5
		self.effects = {}
	
	func determineRainNextTurn(turn: int):
		if grace > 0:
			rainNextTurn = 0
			grace -= 1
		else:
			rainNextTurn = (floor(randf_range(0.75, 1.75)*rainPerTurn))
			if self.effects.has(&"Calm Waters"): rainNextTurn *= 0.75
			if self.effects.has(&"Great Storm"): rainNextTurn *= 1.25
	
	func redeemCost(ticket: Dictionary[StringName, int]):
		#var totalConsumed = 0
		#print(self.resources[&"Earth"].amount)
		for resource in ticket.keys():
			if resource in self.resources.keys(): 
				self.resources[resource].addAmount(ticket[resource])
				#totalConsumed += ticket[resource]
				#print("redeemed" + str(totalConsumed))
		#print(self.resources[&"Earth"].amount)
	
	func redeemBudget(ticket: Dictionary[StringName, int]):
		for resource in ticket.keys():
			if resource in self.resources.keys(): self.resources[resource].addChange(ticket[resource])
	
	func canBeRedeemed(ticket: Dictionary[StringName, int]) -> bool:
		for resource in ticket.keys():
			#print(resource)
			if not (self.resources[resource].getAmount() + ticket[resource] >= 0): return false
		return true
	
	func compileBuildingBudgets(waterLevel: int, buildingMap: Array[Array]) -> Dictionary[StringName, int]:
		self.workingBuildingCount = 0
		self.cityCount = 0
		self.favor = 0.4
		var finalBudget: Dictionary[StringName, int] = {}
		for layer in range(len(buildingMap)):
			if layer < waterLevel: continue
			for building in buildingMap[layer]:
				if not building == null: 
					finalBudget = ResourceScripts.mergeTickets(finalBudget, building.update())
					self.workingBuildingCount += 1
					if building.buildingName == &"Temple": self.favor += 0.05
					if building.buildingName == &"City": self.cityCount += 1
		self.favor = min(max(self.favor - self.workingBuildingCount*0.01 - self.grace*0.01, 0.05), 0.95)
		#if self.cityCount == 0: print("LOL U SHOULD BE DEAD")
		return finalBudget
	
	func process(waterLevel: int, buildingMap: Array[Array]):
		for res in self.resources.keys():
			self.resources[res].change = 0
		if self.effects.has(&"Refugees"): self.resources[&"Labor"].change += self.effects[&"Refugees"]
		if self.effects.has(&"Bumper Crop"): self.resources[&"Food"].change += 2
		if self.effects.has(&"Bring the Heat"): self.resources[&"Earth"].change += 2
		var buildingBudget : Dictionary[StringName, int] = compileBuildingBudgets(waterLevel, buildingMap)
		redeemBudget(buildingBudget)
	
	func update():
		for resource in self.resources.keys():
			self.resources[resource].update()
		self.resources[&"Labor"].addAmount(1)
		if self.effects.has(&"Plague"): self.resources[&"Labor"].addAmount(-2)
		for effect in self.effects.keys():
			if effect == &"Refugees": continue
			self.effects[effect] -= 1
			if self.effects[effect] < 0: self.effects.erase(effect)

var player = Player.new()
@export_multiline var prologueText: String
@export_multiline var gameStartInfoText: String
@export var tutorialScene : PackedScene

func _ready():
	#RenderingServer.set_default_clear_color(Color(0.01, 0.0, 0.189))
	$BackgroundMusic.set_volume_db(-80)
	$CanvasLayer/ColorRect.visible = true
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($BackgroundMusic, "volume_db", -15, 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($CanvasLayer/ColorRect, "color", Color(0.0, 0.0, 0.0, 0.0), 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	#print(Global.mapSize)
	#gameSize = Vector2(50, 50)
	tilemap = GameTilemap.new(gameSize)
	var loaded = not Global.newGame
	if not loaded:
		tilemap.generateWorld(noise)
		player.determineRainNextTurn(turn)
	else:
		if loadGame(): loaded = true
		else: 
			tilemap.generateWorld(noise)
			player.determineRainNextTurn(turn)
			loaded = false
	tilemapDisplay.start(tilemap)
	#print(player.resources)
	#ui.updateCursor.connect(updateCursorDisplay)
	#ui.cursorSelect.connect(tilemapDisplay.cursor.set_selected)
	#print(ResourceScripts.mergeTickets({&"A": 2, &"B": -2}, {&"A": 2, &"C": 2}))
	if tilemap.floodPercentage + player.rainNextTurn < 100: 
		ui.floodPercentNextTurn.text = " + " + str(int(roundf(player.rainNextTurn))) + "% NEXT TURN"
		ui.floodPercentNextTurn.label_settings.font_color = Color(0.0, 0.22, 0.573)
	else: 
		ui.floodPercentNextTurn.text = " LAYER " + str(tilemap.waterLevel) + " WILL BE FLOODED NEXT TURN"
		ui.floodPercentNextTurn.label_settings.font_color = Color(1.0, 0.0, 0.0)
	if loaded: return
	"""var prolog: SingleOptionNotification = ui.singleOptionNotificationBlueprint.instantiate()
	ui.notifBox.add_child(prolog)
	ui.notifications.append(prolog)
	prolog.size.y -= 32
	prolog.centerOnScreen()
	prolog.setContent("Prologue", prologueText)
	prolog.setOption("Begin game")
	await prolog.result
	ui.notifications.erase(prolog)
	prolog.queue_free()"""
	var infolog: ChoiceNotification = ui.choiceNotificationBlueprint.instantiate()
	ui.notifBox.add_child(infolog)
	ui.notifications.append(infolog)
	infolog.size = Vector2(256, 192)
	infolog.centerOnScreen()
	infolog.setContent("Game Start", "Would you like to view the tutorial? Without it, some parts of the game may be confusing or difficult to understand.")
	infolog.setChoices("View tutorial?")
	var result = await infolog.result
	ui.notifications.erase(infolog)
	infolog.queue_free()
	if result: 
		var tutorial = tutorialScene.instantiate()
		ui.notifBox.add_child(tutorial)

func _process(delta):
	if gameEnded: return
	if not ui.menu.visible: tilemapDisplay.process(delta, tilemap, get_global_mouse_position())
	var hasBuildingInCursor: bool
	if (tilemapDisplay.cursor.tile.x < 0 or tilemapDisplay.cursor.tile.y < 0 or 
			tilemapDisplay.cursor.tile.x >= tilemap.mapSize.x or tilemapDisplay.cursor.tile.y >= tilemap.mapSize.y):
		hasBuildingInCursor = false
	else: hasBuildingInCursor = tilemap.buildingMap[tilemapDisplay.layer][tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * 
			tilemap.mapSize.x] != null and not tilemapDisplay.layer < tilemap.waterLevel
	"""if (tilemapDisplay.layer > 0 and tilemap.buildingMap[tilemapDisplay.layer-1][tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * 
			tilemap.mapSize.x] != null and not tilemapDisplay.layer < tilemap.waterLevel): 
		tilemapDisplay.cursor.lower.z_index = 6
	else: tilemapDisplay.cursor.lower.z_index = 5"""
	player.process(tilemap.waterLevel, tilemap.buildingMap)
	ui.process(player, tilemapDisplay.cursor.tile, tilemapDisplay.cursor.selected, hasBuildingInCursor, turn, 
			tilemapDisplay.layer, tilemap.mapHeight, tilemap.waterLevel, tilemap.floodPercentage)
	if Input.is_action_just_pressed("ui_debug"): 
		var event = EventScripts.Event.new().blueprint(ui, &"Divine Favor")
		processEvent(event)
		#event.free()
		#updateTileAtCursor(GameTilemap.Terrain.Platform)
		#print(tilemap.getBottomEmptyTileCount(tilemapDisplay.cursor.tile, tilemapDisplay.layer))
		pass

func updateCursorDisplay(buildingType: StringName):
	tilemapDisplay.cursor.building.set_animation(buildingType)

func updateBuildingAtCursor(building: BuildingScripts.Building):
	tilemap.buildingMap[tilemapDisplay.layer][tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] = building
	#print(tilemap.buildingMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * Global.mapSize.x])

func buildingAtPos(pos: Vector2):
	return tilemap.buildingMap[tilemapDisplay.layer][pos.x + pos.y * tilemap.mapSize.x]

func tileAtPos(pos: Vector2):
	return tilemap.terrainMap[tilemapDisplay.layer][pos.x + pos.y * tilemap.mapSize.x]

func updateTileAtCursor(tile: GameTilemap.Terrain):
	tilemap.terrainMap[tilemapDisplay.layer][tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] =  tile

func updateTileAtLayerAbove(tile: GameTilemap.Terrain):
	tilemap.terrainMap[tilemapDisplay.layer+1][tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] =  tile

func attemptPlaceTile(tile: GameTilemap.Terrain): 
	if tile == GameTilemap.Terrain.Platform:
		if player.canBeRedeemed({&"Earth": int(-2), &"Labor": int(-1)}):
			player.redeemCost({&"Earth": int(-2), &"Labor": int(-1)})
			updateTileAtLayerAbove(GameTilemap.Terrain.Platform)
			player.platformCount += 1
			#print(tilemap.mapHeight - 1 - tilemapDisplay.layer)
			if tilemap.mapHeight-1 <= tilemapDisplay.layer: 
				tilemap.addLayer()
				#tilemap.addLayer()
				#tilemap.mapHeight -= 1

func attemptPlaceWaterPlatform(): 
	if player.canBeRedeemed({&"Earth": int(-2), &"Labor": int(-1)}):
		player.redeemCost({&"Earth": int(-2), &"Labor": int(-1)})
		updateTileAtCursor(GameTilemap.Terrain.Platform)
		player.platformCount += 1

func attemptPlaceBuilding(building: BuildingScripts.Building):
	if player.canBeRedeemed(building.cost):
		player.redeemCost(building.cost)
		updateBuildingAtCursor(building)
		player.buildingCount += 1
	else: building.call_deferred("free")

func processBuildButtons(cursorSelected: bool, buildingName: StringName):
	if tilemapDisplay.checkCoordsOutOfBounds(tilemap, tilemapDisplay.cursor.tile): 
		ui.infoBox.build.disabled = true
		ui.infoBox.build.tooltip_text = "Selected a tile first."
		return
	var cost: Dictionary[StringName, int]
	var hasNeighbors: bool = false
	var hasLowerNeighbor: bool = false
	if (tilemap.terrainMap[tilemapDisplay.layer][tilemapDisplay.cursor.tile.x+tilemapDisplay.cursor.tile.y*tilemap.mapSize.x]
			!= GameTilemap.Terrain.Air): hasLowerNeighbor = true
	if cursorSelected: 
		for neighbor in tilemap.getAllNeighbors(tilemapDisplay.cursor.tile).values():
			if tilemap.buildingMap[tilemapDisplay.layer][neighbor.x+neighbor.y*tilemap.mapSize.x] != null:
				hasNeighbors = true
				break
	if (tilemap.terrainMap[tilemapDisplay.layer][tilemapDisplay.cursor.tile.x+tilemapDisplay.cursor.tile.y*tilemap.mapSize.x]
			== GameTilemap.Terrain.Platform): hasNeighbors = true
	if buildingName == &"Platform":
		cost = {&"Earth": int(-2), &"Labor": int(-1)}
		ui.infoBox.build.disabled = ((not cursorSelected) or (not player.canBeRedeemed(cost))
				or tilemap.terrainMap[tilemapDisplay.layer+1][tilemapDisplay.cursor.tile.x+tilemapDisplay.cursor.tile.y*tilemap.mapSize.x]
				!= GameTilemap.Terrain.Air or (not hasLowerNeighbor) or (not hasNeighbors))
		ui.infoBox.build.tooltip_text = ""
		#player.canBeRedeemed(cost) 
		if not cursorSelected: ui.infoBox.build.tooltip_text += "Select a tile first. "
		else:
			if not player.canBeRedeemed(cost): ui.infoBox.build.tooltip_text += "Insufficient resources. "
			if (not hasLowerNeighbor): ui.infoBox.build.tooltip_text += "Cannot build platform on air. "
			if (not hasNeighbors): ui.infoBox.build.tooltip_text += "No neighboring buildings. "
			if (tilemapDisplay.layer+1 < tilemap.mapHeight and tilemap.terrainMap[tilemapDisplay.layer+1][tilemapDisplay.cursor.tile.x+tilemapDisplay.cursor.tile.y*tilemap.mapSize.x]
					!= GameTilemap.Terrain.Air): ui.infoBox.build.tooltip_text += "Cannot be built inside a tile. "
			#if (tilemapDisplay.layer+1 >= tilemap.mapHeight-1): ui.infoBox.build.tooltip_text += "Max height limit. "
			#MAX HEIGHT LIMIT IS TEMPORARY LOL!!!
		return
	elif buildingName == &"PlatformWater":
		cost = {&"Earth": int(-2), &"Labor": int(-1)}
		var tileIsWater: bool = (tilemapDisplay.layer == tilemap.waterLevel)
		ui.infoBox.build.disabled = ((not cursorSelected) or (not player.canBeRedeemed(cost))
				or tilemap.terrainMap[tilemapDisplay.layer][tilemapDisplay.cursor.tile.x+tilemapDisplay.cursor.tile.y*tilemap.mapSize.x]
				!= GameTilemap.Terrain.Air or (not tileIsWater) or (not hasNeighbors))
		ui.infoBox.build.tooltip_text = ""
		#player.canBeRedeemed(cost) 
		if not cursorSelected: ui.infoBox.build.tooltip_text += "Select a tile first. "
		else:
			if not player.canBeRedeemed(cost): ui.infoBox.build.tooltip_text += "Insufficient resources. "
			if (not tileIsWater): ui.infoBox.build.tooltip_text += "Must be built on a surface of water. "
			if (not hasNeighbors): ui.infoBox.build.tooltip_text += "No neighboring buildings. "
			if (tilemap.terrainMap[tilemapDisplay.layer][tilemapDisplay.cursor.tile.x+tilemapDisplay.cursor.tile.y*tilemap.mapSize.x]
					!= GameTilemap.Terrain.Air): ui.infoBox.build.tooltip_text += "Cannot be built inside a tile. "
			#if (tilemapDisplay.layer+1 >= tilemap.mapHeight-1): ui.infoBox.build.tooltip_text += "Max height limit. "
			#MAX HEIGHT LIMIT IS TEMPORARY LOL!!!
		return
	
	var building: BuildingScripts.Building
	match buildingName:
		&"City": building = BuildingScripts.City.new()
		&"Farm": building = BuildingScripts.Farm.new()
		&"Kiln": building = BuildingScripts.Kiln.new()
	cost = building.cost
	#print(cursorSelected, cost.canBeRedeemed(player.resources))
	#print(player.canBeRedeemed(cost))
	#player.canBeRedeemed(cost)
	ui.infoBox.build.disabled = ((not cursorSelected) or (not player.canBeRedeemed(cost)) or 
			tilemap.buildingMap[tilemapDisplay.layer][tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] != null or
			(not hasNeighbors) or not hasLowerNeighbor)
	ui.infoBox.build.tooltip_text = ""
	if not cursorSelected: 
		ui.infoBox.build.tooltip_text += "Select a tile first. "
	else:
		if not player.canBeRedeemed(cost): 
			ui.infoBox.build.tooltip_text += "Insufficient resources. "
		if (tilemap.buildingMap[tilemapDisplay.layer][tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] != null):
			ui.infoBox.build.tooltip_text += "Tile occupied. "
		if (not hasNeighbors):
			ui.infoBox.build.tooltip_text += "No neighboring buildings. "
		if (tilemap.terrainMap[tilemapDisplay.layer][tilemapDisplay.cursor.tile.x + 
				tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] == GameTilemap.Terrain.Air):
			ui.infoBox.build.tooltip_text += "Cannot build on air or water. "
		if tilemapDisplay.layer+1 < tilemap.mapHeight and (not tilemap.terrainMap[tilemapDisplay.layer+1][tilemapDisplay.cursor.tile.x + 
				tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] in [GameTilemap.Terrain.Platform, GameTilemap.Terrain.Air]):
			ui.infoBox.build.tooltip_text += "Cannot build inside a tile. "
	building.call_deferred("free")
	#ui.infoBox.cancel.disabled = (not cursorSelected)

func processInteract():
	var nOps = ui.optionBar.get_child(1)
	var building : BuildingScripts.Building
	if tilemapDisplay.checkCoordsOutOfBounds(tilemap, tilemapDisplay.cursor.tile): building = null
	else: building = buildingAtPos(Vector2(tilemapDisplay.cursor.tile))
	if building == null or tilemapDisplay.layer < tilemap.waterLevel: 
		#ui.tabSelected = 0
		for child in nOps.get_children(): child.visible = false
		nOps.get_child(1).show()
		nOps.get_child(2).show()
		nOps.get_child(2).set_text("Select a building.")
		return
	else: for child in nOps.get_children(): child.visible = true
	if building is BuildingScripts.ProductionBuilding:
		nOps.get_child(0).visible = true
		nOps.get_child(0).get_child(2).set_text(str(building.workers) + " [img]res://code/resources/miniResourceIcons/laborLarge.tres[/img]")
		nOps.get_child(0).get_child(1).disabled = (not building.workers > 0)
		nOps.get_child(0).get_child(3).disabled = (not building.workers < building.workerSlots) or (not player.resources[&"Labor"].change > 0)
	else: nOps.get_child(0).visible = false
	var production = ResourceScripts.ticketToText(building.update())
	if production != "":
		nOps.get_child(2).set_text(building.buildingName + " at (" + str(tilemapDisplay.cursor.tile.x) + ", " + 
			str(tilemapDisplay.cursor.tile.y) + ", " + str(int(tilemapDisplay.layer)) + "). " + production + " per turn.")
	else: nOps.get_child(2).set_text(building.buildingName + " at (" + str(tilemapDisplay.cursor.tile.x) + ", " + 
			str(tilemapDisplay.cursor.tile.y) + ", " + str(int(tilemapDisplay.layer)) + "). Produces nothing.")
	"""if player.buildingCount <= 1: 
		nOps.get_child(4).disabled = true
		return"""
	if building is BuildingScripts.City: 
		#nOps.get_child(4).disabled = false
		if player.resources[&"Labor"].change - 2 >= 0 and player.cityCount > 1: nOps.get_child(4).disabled = false
		else: nOps.get_child(4).disabled = true
	else: nOps.get_child(4).disabled = false #temporary measure

func changeBuildingWorkers(change: int):
	buildingAtPos(Vector2(tilemapDisplay.cursor.tile)).workers += change
	#print(change)

func destroyBuilding():
	player.buildingCount -= 1
	#player.resources[&"Labor"].amount -= 1
	var building = tilemap.buildingMap[tilemapDisplay.layer][tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x]
	tilemap.buildingMap[tilemapDisplay.layer][tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] = null
	building.call_deferred("free")

func processInfoTab():
	var fOps = ui.optionBar.get_child(2)
	if (tilemapDisplay.cursor.tile.x < 0 or tilemapDisplay.cursor.tile.y < 0 or 
			tilemapDisplay.cursor.tile.x >= tilemap.mapSize.x or tilemapDisplay.cursor.tile.y >= tilemap.mapSize.y):
		fOps.get_child(1).set_text("Out of Bounds")
		return
	var tileName = str(GameTilemap.Terrain.keys()[tileAtPos(tilemapDisplay.cursor.tile)])
	var buildingName : String
	if buildingAtPos(tilemapDisplay.cursor.tile) != null:
		buildingName = " with a " + buildingAtPos(tilemapDisplay.cursor.tile).buildingName
	else: buildingName = ""
	if tileName == &"Air":
		tileName = &"Empty"
		if tilemapDisplay.layer <= tilemap.waterLevel: tileName = &"Water"
	fOps.get_child(1).set_text(tileName + " tile" + buildingName + " at: (" + str(int(tilemapDisplay.cursor.tile.x)) + 
			", " + str(int(tilemapDisplay.cursor.tile.y)) + ", " + str(int(tilemapDisplay.layer)) + ")")

func generateEvent() -> EventScripts.Event:
	var rand = randf_range(0.0, 1.0)
	var events: Array[StringName]
	if rand <= player.favor:
		events = [&"Calm Waters", &"Exceeding Quotas", &"Heaven\'s Mercy", &"Bountiful Harvests", &"Industrious Spirit",
		&"Bumper Crop", &"Bring the Heat", &"Refugees"]
		if tilemap.floodPercentage >= 10: 
			events.append(&"Divine Favor")
			if player.favor >= 0.5: 
				events.append(&"Divine Favor")
				events.append(&"Calm Waters")
	else:
		events = [&"Great Storm", &"Flash Flood", &"Furious Waves"] # &"Famine", &"City Fire", &"Plague", &"Heaven\'s Wrath"
		if player.resources[&"Food"].amount > 0: events.append(&"Famine")
		if player.resources[&"Earth"].amount > 0: events.append(&"City Fire")
		if player.resources[&"Labor"].amount > 0: events.append(&"Plague")
		if player.grace > 0: events.append(&"Heaven\'s Wrath")
	rand = randi_range(0, len(events)-1)
	var event = EventScripts.Event.new().blueprint(ui, events[rand])
	return event

func processEvent(event: EventScripts.Event):
	match event.eventName:
		&"Calm Waters": player.effects[&"Calm Waters"] = 10
		&"Great Storm": player.effects[&"Great Storm"] = 10
		&"Furious Waves": player.rainNextTurn += 20
		#&"Divine Favor": tilemap.floodPercentage = 0
		&"Flash Flood": player.rainNextTurn += 10
		&"Heaven\'s Mercy": player.grace += 5
		&"Heaven\'s Wrath": player.grace = 0
		&"Bountiful Harvests": player.resources[&"Food"].addAmount(4)
		&"Exceeding Quotas": player.resources[&"Earth"].addAmount(4)
		&"Industrious Spirit": player.resources[&"Labor"].addAmount(4)
		&"Famine": player.resources[&"Food"].setAmount(player.resources[&"Food"].amount/2)
		&"City Fire": player.resources[&"Earth"].setAmount(player.resources[&"Earth"].amount/2)
		&"Plague": player.effects[&"Plague"] = 5
		&"Bumper Crop": player.effects[&"Bumper Crop"] = 5
		&"Bring the Heat": player.effects[&"Bring the Heat"] = 5
		&"Refugees": 
			if not player.effects.has(&"Refugees"): player.effects[&"Refugees"] = 1
			else: player.effects[&"Refugees"] += 1
	event.free()

var tween: Tween
var otherTween: Tween

func nextTurn():
	if ui.turnButton.get_child(0).get_child(1).is_stopped():
		ui.turnButton.get_child(0).get_child(1).start()
	else: return
	
	if player.resources[&"Food"].amount + player.resources[&"Food"].change < 0:
		var ays: ChoiceNotification = ui.choiceNotificationBlueprint.instantiate()
		ui.notifications.append(ays)
		ui.notifBox.add_child(ays)
		ays.centerOnScreen()
		ays.setContent(
			"Next Turn Confirmation", "You do not produce enough food to sustain your population. 
			\nIf you run out of food, your civilization will fall.")
		ays.setChoices("Proceed anyway?")
		var result = await ays.getChoice()
		ui.notifications.erase(ays)
		ays.queue_free()
		if not result: return
	if player.cityCount < 0:
		var ays: ChoiceNotification = ui.choiceNotificationBlueprint.instantiate()
		ui.notifications.append(ays)
		ui.notifBox.add_child(ays)
		ays.centerOnScreen()
		ays.setContent(
			"Next Turn Confirmation", "You have no cities established above the waterline. 
			If you proceed to the next turn, your civilization will fall.")
		ays.setChoices("Proceed anyway?")
		var result = await ays.getChoice()
		ui.notifications.erase(ays)
		ays.queue_free()
		if not result: return

	player.update()
	if player.resources[&"Food"].amount < 0: 
		loseGame("starvation")
		return
	#tilemapDisplay.modulate = Color(1.0, 1.0, 1.0)
	if tween: tween.kill()
	tween = get_tree().create_tween()
	if otherTween: otherTween.kill()
	otherTween = get_tree().create_tween()
	var rainThisTurn: float = player.rainNextTurn
	var total = tilemap.floodPercentage + rainThisTurn
	#tilemap.floodPercentage += (player.rainPerTurn + floor(randf_range(0.5, 1.5)*player.rainPerTurn))/2
	ui.turnButton.get_child(0).rotation = 0
	tween.set_parallel(false)
	otherTween.tween_property(ui.turnButton.get_child(0), "rotation_degrees", 360, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if tilemap.floodPercentage + rainThisTurn >= 100:
		var ratio: float = (100-tilemap.floodPercentage) / rainThisTurn
		tween.tween_property(tilemap, "floodPercentage", 100, ratio).set_trans(Tween.TRANS_QUAD)#.set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(cullFlood)
		tween.tween_property(tilemap, "floodPercentage", posmod(total, 100), 1-ratio)
		tween.tween_callback(checkIfNoCities)
	else:
		tween.tween_property(tilemap, "floodPercentage", total, 1).set_trans(Tween.TRANS_QUAD)#.set_ease(Tween.EASE_IN_OUT)
	#tween.tween_property(ui.floodProgressVertical, "value", tilemap.floodPercentage, 1).set_trans(Tween.TRANS_QUAD)
	#tween.tween_property(tilemapDisplay, "modulate", Color(1.0, 1.0, 1.0), 0.5).set_trans(Tween.TRANS_QUAD)
	player.determineRainNextTurn(turn)
	turn += 1
	if randf_range(0.0, 1.0) > 0.93: 
		var event: EventScripts.Event = generateEvent()
		if event.eventName == &"Divine Favor":
			tween.tween_property(tilemap, "floodPercentage", 0, 1).set_trans(Tween.TRANS_QUAD)
		else: processEvent(event)

func checkIfNoCities():
	#print("scoobydoobydoo")
	player.compileBuildingBudgets(tilemap.waterLevel, tilemap.buildingMap)
	if player.cityCount <= 0: 
		#print("scoobydoobytwo")
		loseGame("flooding")
		return

func cullFlood():
	if tilemap.floodPercentage >= 100:
		tilemap.waterLevel += floor(float(tilemap.floodPercentage)/100)
		tilemap.floodPercentage = posmod(tilemap.floodPercentage, 100)
	for layer in range(len(tilemap.buildingMap)):
		if layer < tilemap.waterLevel:
			for building in tilemap.buildingMap[layer]:
				if building != null and building is BuildingScripts.ProductionBuilding: building.workers = 0

func incrementLayer(increment: int): 
	tilemapDisplay.layer += increment
	#tilemapDisplay.cameraPosition.y += increment * Global.tileSize.y

func saveGame():
	var saveData = {
		"turn":turn,
		"score":player.score,
		"food":player.resources[&"Food"].amount,
		"earth":player.resources[&"Earth"].amount,
		"labor":player.resources[&"Labor"].amount,
		"buildingCount":player.buildingCount,
		"platformCount":player.platformCount,
		"favor":player.favor,
		"grace":player.grace,
		"effects":player.effects,
		"gameSize.x":tilemap.mapSize.x,
		"gameSize.y":tilemap.mapSize.y,
		"gameLayers":tilemap.mapHeight,
		"terrainMapCode":tilemap.getTerrainMapCode(),
		"buildingMapCode":tilemap.getBuildingMapCode(),
		"waterLevel":tilemap.waterLevel,
		"floodPercentage":tilemap.floodPercentage,
		"rainNextTurn":player.rainNextTurn
	}
	var saveFile = FileAccess.open("user://save.json", FileAccess.WRITE)
	var jsonString = JSON.stringify(saveData)
	saveFile.store_line(jsonString)
	saveFile.close()
	var infolog: SingleOptionNotification = ui.singleOptionNotificationBlueprint.instantiate()
	ui.add_child(infolog)
	ui.notifications.append(infolog)
	infolog.size = Vector2(256, 128)
	infolog.centerOnScreen()
	infolog.setContent("SAVED GAME", "Game successfully saved!")
	infolog.setOption("Okay")
	await infolog.result
	ui.notifications.erase(infolog)
	infolog.queue_free()
	#print("Game Saved Successfully?")

func loadGame() -> bool:
	if not FileAccess.file_exists("user://save.json"):
		print("No save found.")
		return false
	var saveFile = FileAccess.open("user://save.json", FileAccess.READ)
	var jsonString = saveFile.get_line()
	var json = JSON.new()
	var parse = json.parse(jsonString)
	if not parse == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", jsonString, " at line ", json.get_error_line())
		return false
	var saveData = json.data
	saveFile.close()
	turn = int(saveData["turn"])
	player.score = saveData["score"]
	player.resources[&"Food"].amount = int(saveData["food"])
	player.resources[&"Earth"].amount = int(saveData["earth"])
	player.resources[&"Labor"].amount = int(saveData["labor"])
	player.buildingCount = int(saveData["buildingCount"])
	player.platformCount =int(saveData["platformCount"])
	player.favor = saveData["favor"]
	player.grace = int(saveData["grace"])
	#player.effects = saveData["effects"]
	for effect in saveData["effects"]:
		player.effects[effect] = int(saveData["effects"][effect])
	tilemap.mapSize = Vector2(saveData["gameSize.x"], saveData["gameSize.y"])
	tilemap.mapHeight = int(saveData["gameLayers"])
	tilemap.convertTerrainMapCode(saveData["terrainMapCode"])
	tilemap.convertBuildingMapCode(saveData["buildingMapCode"])
	tilemap.waterLevel = int(saveData["waterLevel"])
	tilemap.floodPercentage = saveData["floodPercentage"]
	player.rainNextTurn = saveData["rainNextTurn"]
	return true
"""
		"turn":turn,
		"score":player.score,
		"food":player.resources[&"Food"].amount,
		"earth":player.resources[&"Earth"].amount,
		"labor":player.resources[&"Labor"].amount,
		"buildingCount":player.buildingCount,
		"platformCount":player.platformCount,
		"favor":player.favor,
		"grace":player.grace,
		"effects":player.effects,
		"gameSize.x":tilemap.gameSize.x,
		"gameSize.y":tilemap.gameSize.y,
		"gameLayers":tilemap.gameHeight,
		"terrainMap":tilemap.terrainMap,
		"buildingMapCode":tilemap.getBuildingMapCode(),
		"waterLevel":tilemap.waterLevel,
		"floodPercentage":tilemap.floodPercentage
"""

func returnToMenu():
	if tween: tween.kill()
	tween = get_tree().create_tween()
	#print("lesgo")
	tween.set_parallel(true)
	tween.tween_property($CanvasLayer/ColorRect, "color", Color(0.0, 0.0, 0.0), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($BackgroundMusic, "volume_db", -80, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	$BackgroundMusic.saveAudioPosition()
	tween.tween_callback(loadMenuScene)

func loadMenuScene():
	get_tree().change_scene_to_file("res://code/scenes/mainMenu.tscn")

var l: Tween
@export var lossScreenBlueprint: PackedScene

func resign():
	loseGame("resignation")

func loseGame(why):
	gameEnded = true
	l = get_tree().create_tween()
	l.tween_property(ui, "modulate", Color(0.0, 0.0, 0.0, 0.0), 2).set_trans(Tween.TRANS_CUBIC)
	tilemapDisplay.cursor.visible = false
	var lossScreen = lossScreenBlueprint.instantiate()
	$CanvasLayer.add_child(lossScreen)
	var epitaph = "May the Lord judge between you and me.\n - Genesis 16:5b"
	var reason = "The precise reason your civilization fell is unknown. There are many guesses, but none prove conclusive."
	if why == "starvation":
		epitaph = ("Because of thirst the infant’s tongue\nsticks to the roof of its mouth;\nThe children beg for bread,"+
				"\nbut no one gives it to them.\n - Lamentations 4:4")
		reason = ("In the end, your civilization fell to starvation rather than floodwaters."+
				" Matters of human mismanagement are as deadly as natural disasters.")
	elif why == "flooding":
		epitaph = ("The waters rose and increased greatly on the earth... "+
				"\nEvery living thing that moved on land perished— birds, livestock, " +  
				"wild animals, all the creatures that swarm over the earth, and all mankind."+
				"\n - Genesis 7:18a and 7:21")
		reason = ("Heaven's wrathful downpour proved too much for your civilization. "+
				"All that remains of your civilization lies beneath the waves. But will anyone survive to find it?")
	elif why == "resignation":
		epitaph = ("Woe! Woe to you, great city, you mighty city of Babylon! In one hour your doom has come!\n - Revelations 18:10b")
		reason = ("Rather than brave the tides alongside your people, you have left them to their fate. "+
				"They will surely perish without a leader at the helm.")
	var stats = ""
	if why != "flooding": stats = ("\nYour civilization survived " + str(tilemap.waterLevel) +" flood(s) and climbed " + str(tilemap.mapHeight-1) + " layer(s). You built " +
			str(player.buildingCount) + " building(s) and " + str(player.platformCount) + " platforms. ")
	else: stats = ("\nYour civilization survived " + str(tilemap.waterLevel-1) +" flood(s) and climbed " + str(tilemap.mapHeight-1) + " layer(s). You built " +
			str(player.buildingCount) + " building(s) and " + str(player.platformCount) + " platform(s). ")
	lossScreen.content.text = (epitaph + "\n\n" + reason + "\n" + stats)
	var saveFile = FileAccess.open("user://save.json", FileAccess.WRITE)
	var jsonString = JSON.stringify({})
	saveFile.store_line(jsonString)
	saveFile.close()
	lossScreen.leave.connect(returnToMenu)
