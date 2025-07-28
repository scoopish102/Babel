class_name Game extends Node2D

@onready var tilemapDisplay := $TilemapDisplay
@onready var ui := $CanvasLayer/UI

@export var gameSize : Vector2i
@export var noise : FastNoiseLite

var tilemap : GameTilemap

var turn : int = 0

class Player:
	var resources : Dictionary[StringName, ResourceScripts.RResource]
	var score : int
	var buildingCount : int
	
	func _init():
		self.resources = {
			&"Food": ResourceScripts.RResource.new(&"Food", 4, false),
			&"Earth": ResourceScripts.RResource.new(&"Earth", 4, false),
			&"Bronze": ResourceScripts.RResource.new(&"Bronze", 0, false),
			&"Labor": ResourceScripts.RResource.new(&"Labor", 2, true)}
		self.score = 0
		self.buildingCount = 0
	
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
	
	func compileBuildingBudgets(buildingMap: Array[BuildingScripts.Building]) -> Dictionary[StringName, int]:
		var finalBudget: Dictionary[StringName, int] = {}
		for building in buildingMap:
			if not building == null: 
				finalBudget = ResourceScripts.mergeTickets(finalBudget, building.update())
		return finalBudget
	
	func process(buildingMap: Array[BuildingScripts.Building]):
		for res in self.resources.keys():
			self.resources[res].change = 0
		var buildingBudget : Dictionary[StringName, int] = compileBuildingBudgets(buildingMap)
		redeemBudget(buildingBudget)
	
	func update():
		for resource in self.resources.keys():
			self.resources[resource].update()

var player = Player.new()

func _ready():
	#print(Global.mapSize)
	#gameSize = Vector2(50, 50)
	tilemap = GameTilemap.new(gameSize)
	tilemap.generateWorld(noise)
	tilemapDisplay.start(tilemap)
	#print(player.resources)
	#ui.updateCursor.connect(updateCursorDisplay)
	#ui.cursorSelect.connect(tilemapDisplay.cursor.set_selected)
	#print(ResourceScripts.mergeTickets({&"A": 2, &"B": -2}, {&"A": 2, &"C": 2}))

func _process(delta):
	tilemapDisplay.process(delta, tilemap, get_global_mouse_position())
	var hasBuildingInCursor: bool
	if (tilemapDisplay.cursor.tile.x < 0 or tilemapDisplay.cursor.tile.y < 0 or 
			tilemapDisplay.cursor.tile.x >= tilemap.mapSize.x or tilemapDisplay.cursor.tile.y >= tilemap.mapSize.y):
		hasBuildingInCursor = false
	else: hasBuildingInCursor = tilemap.buildingMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] != null
	ui.process(player, tilemapDisplay.cursor.tile, tilemapDisplay.cursor.selected, hasBuildingInCursor, turn)
	player.process(tilemap.buildingMap)
	if Input.is_action_just_pressed("ui_debug"): pass
		#var tileAtMouse = tilemapDisplay.screenPositionToTileCoordinates(get_global_mouse_position())
		#print(tilemapDisplay.cursor.tile)
		#print(tilemap.terrainMap[tileAtMouse.x + tileAtMouse.y * tilemap.mapSize.x])
		#if tilemapDisplay.checkCoordsOutOfBounds(tilemap, tileAtMouse): print("abc")
		#print(tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x)
		#print(tilemap.buildingMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * Global.mapSize.x].buildingName)

func updateCursorDisplay(buildingType: StringName):
	tilemapDisplay.cursor.building.set_animation(buildingType)

func updateBuildingAtCursor(building: BuildingScripts.Building):
	tilemap.buildingMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] = building
	#print(tilemap.buildingMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * Global.mapSize.x])

func buildingAtPos(pos: Vector2):
	return tilemap.buildingMap[pos.x + pos.y * tilemap.mapSize.x]

func tileAtPos(pos: Vector2):
	return tilemap.terrainMap[pos.x + pos.y * tilemap.mapSize.x]

func updateTileAtCursor(tile: GameTilemap.Terrain):
	tilemap.tileMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] =  tile

func attemptPlaceTile(tile: GameTilemap.Terrain): pass

func attemptPlaceBuilding(building: BuildingScripts.Building):
	if player.canBeRedeemed(building.cost):
		player.redeemCost(building.cost)
		updateBuildingAtCursor(building)
		player.buildingCount += 1
	else: building.call_deferred("free")

func processBuildButtons(cursorSelected: bool, buildingName: StringName):
	var building: BuildingScripts.Building
	var cost
	match buildingName:
		&"City": building = BuildingScripts.City.new()
		&"Farm": building = BuildingScripts.Farm.new()
		&"Kiln": building = BuildingScripts.Kiln.new()
	cost = building.cost
	#print(cursorSelected, cost.canBeRedeemed(player.resources))
	#print(player.canBeRedeemed(cost))
	player.canBeRedeemed(cost)
	var hasNeighbors: bool = false
	for neighbor in tilemap.getAllNeighbors(tilemapDisplay.cursor.tile).values():
		if tilemap.buildingMap[neighbor.x+neighbor.y*tilemap.mapSize.x] != null:
			hasNeighbors = true
			break
	ui.infoBox.build.disabled = ((not cursorSelected) or (not player.canBeRedeemed(cost)) or 
			tilemap.buildingMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] != null or
			(not hasNeighbors))
	ui.infoBox.build.tooltip_text = ""
	if not cursorSelected: 
		ui.infoBox.build.tooltip_text += "Select a tile first. "
	else:
		if not player.canBeRedeemed(cost): 
			ui.infoBox.build.tooltip_text += "Insufficient resources. "
		if (tilemap.buildingMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] != null):
			ui.infoBox.build.tooltip_text += "Tile occupied. "
		if (not hasNeighbors):
			ui.infoBox.build.tooltip_text += "No neighboring buildings. "
		if tilemap.terrainMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] == GameTilemap.Terrain.Water:
			ui.infoBox.build.tooltip_text += "Cannot build on water. "
	building.call_deferred("free")
	#ui.infoBox.cancel.disabled = (not cursorSelected)

func processInteract():
	var nOps = ui.optionBar.get_child(1)
	var building = buildingAtPos(Vector2(tilemapDisplay.cursor.tile))
	if building == null: 
		#ui.tabSelected = 0
		for child in nOps.get_children(): child.visible = false
		return
	else: for child in nOps.get_children(): child.visible = true
	if building is BuildingScripts.ProductionBuilding:
		nOps.get_child(0).visible = true
		nOps.get_child(0).get_child(2).set_text(str(building.workers) + " [img]res://code/resources/miniResourceIcons/laborLarge.tres[/img]")
		nOps.get_child(0).get_child(1).disabled = (not building.workers > 0)
		nOps.get_child(0).get_child(3).disabled = (not building.workers < building.workerSlots) or (not player.resources[&"Labor"].change > 0)
	else: nOps.get_child(0).visible = false
	var production = ResourceScripts.ticketToText(building.update())
	nOps.get_child(2).set_text(building.buildingName + " at (" + str(tilemapDisplay.cursor.tile.x) + ", " + 
			str(tilemapDisplay.cursor.tile.y) + "), Producing: " + production)
	if player.buildingCount <= 1: 
		nOps.get_child(4).disabled = true
		return
	if building is BuildingScripts.City: 
		if player.resources[&"Labor"].change - 2 >= 0: nOps.get_child(4).disabled = false
		else: nOps.get_child(4).disabled = true
	else: nOps.get_child(4).disabled = false #temporary measure

func changeBuildingWorkers(change: int):
	buildingAtPos(Vector2(tilemapDisplay.cursor.tile)).workers += change
	print(change)

func destroyBuilding():
	player.buildingCount -= 1
	var building = tilemap.buildingMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x]
	tilemap.buildingMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] = null
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
		buildingName = buildingAtPos(tilemapDisplay.cursor.tile).buildingName
	else: buildingName = "no building"
	fOps.get_child(1).set_text(tileName + " tile with " + buildingName + " at: (" + str(int(tilemapDisplay.cursor.tile.x)) + 
			", " + str(int(tilemapDisplay.cursor.tile.y)) + ")")

#var tween

func nextTurn():
	turn += 1
	player.update()
	#tilemapDisplay.modulate = Color(1.0, 1.0, 1.0)
	#if tween: tween.kill()
	#tween = get_tree().create_tween()
	#tween.tween_property(tilemapDisplay, "modulate", Color(0.22, 0.259, 0.569), 0.5).set_trans(Tween.TRANS_QUAD)
	#tween.tween_property(tilemapDisplay, "modulate", Color(1.0, 1.0, 1.0), 0.5).set_trans(Tween.TRANS_QUAD)
