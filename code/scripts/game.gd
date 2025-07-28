class_name Game extends Node2D

@onready var tilemapDisplay := $TilemapDisplay
@onready var ui := $CanvasLayer/UI

@export var gameSize : Vector2i
@export var noise : FastNoiseLite

var tilemap : GameTilemap

class Player:
	var resources : Dictionary[StringName, ResourceScripts.RResource]
	var score : int
	
	func _init():
		self.resources = {
			&"Food": ResourceScripts.RResource.new(&"Food", 4, false),
			&"Earth": ResourceScripts.RResource.new(&"Earth", 4, false),
			&"Bronze": ResourceScripts.RResource.new(&"Bronze", 0, false),
			&"Labor": ResourceScripts.RResource.new(&"Labor", 0, true)}
		self.score = 0
	
	func redeemCost(ticket: Dictionary[StringName, int]):
		for resource in ticket.keys():
			if resource in self.resources.keys(): self.resources[resource].addAmount(ticket[resource])
	
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
		for resource in self.res:
			self.res[resource].update()

var player = Player.new()

func _ready():
	#print(Global.mapSize)
	gameSize = Vector2(50, 50)
	tilemap = GameTilemap.new(gameSize)
	tilemap.generateWorld(noise)
	tilemapDisplay.start(tilemap)
	#print(player.resources)
	#ui.updateCursor.connect(updateCursorDisplay)
	#ui.cursorSelect.connect(tilemapDisplay.cursor.set_selected)
	#print(ResourceScripts.mergeTickets({&"A": 2, &"B": -2}, {&"A": 2, &"C": 2}))

func _process(delta):
	tilemapDisplay.process(delta, tilemap, get_global_mouse_position())
	ui.process(player, tilemapDisplay.cursor.tile, tilemapDisplay.cursor.selected)
	player.process(tilemap.buildingMap)
	if Input.is_action_just_pressed("ui_debug"): 
		#var tileAtMouse = tilemapDisplay.screenPositionToTileCoordinates(get_global_mouse_position())
		print(tilemapDisplay.cursor.tile)
		#print(tilemap.terrainMap[tileAtMouse.x + tileAtMouse.y * tilemap.mapSize.x])
		#if tilemapDisplay.checkCoordsOutOfBounds(tilemap, tileAtMouse): print("abc")
		#print(tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x)
		#print(tilemap.buildingMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * Global.mapSize.x].buildingName)

func updateCursorDisplay(buildingType: StringName):
	tilemapDisplay.cursor.building.set_animation(buildingType)

func updateBuildingAtCursor(building: BuildingScripts.Building):
	tilemap.buildingMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] = building
	#print(tilemap.buildingMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * Global.mapSize.x])

func updateTileAtCursor(tile: GameTilemap.Terrain):
	tilemap.tileMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * tilemap.mapSize.x] =  tile

func attemptPlaceTile(tile: GameTilemap.Terrain): pass

func attemptPlaceBuilding(building: BuildingScripts.Building):
	if player.canBeRedeemed(building.cost):
		#player.redeemCost(building.cost)
		updateBuildingAtCursor(building)
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
	ui.infoBox.build.disabled = (not cursorSelected) or (not player.canBeRedeemed(cost))
	building.call_deferred("free")
	#ui.infoBox.cancel.disabled = (not cursorSelected)
