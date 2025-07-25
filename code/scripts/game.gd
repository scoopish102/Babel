class_name Game extends Node2D

@onready var tilemapDisplay := $TilemapDisplay
@onready var ui := $CanvasLayer/UI

@export var gameSize : Vector2i
@export var noise : FastNoiseLite

var tilemap : GameTilemap

class Player:
	var resources : Dictionary
	var score : int
	
	func _init():
		self.resources = {
			&"Food": ResourceScripts.RResource.new(&"Food", 4, false),
			&"Earth": ResourceScripts.RResource.new(&"Earth", 4, false),
			&"Bronze": ResourceScripts.RResource.new(&"Bronze", 0, false),
			&"Labor": ResourceScripts.RResource.new(&"Labor", 0, true)}
		self.score = 0
	
	func redeemCost(ticket: Dictionary):
		for resource in ticket.res:
			if resource in self.res: self.res[resource].addAmount(ticket.res[resource])
	
	func redeemBudget(ticket: Dictionary):
		for resource in ticket.res:
			if resource in self.res: self.res[resource].change += ticket.res[resource]
	
	func canBeRedeemed(ticket: Dictionary) -> bool:
		for resource in ticket.res:
			print(resource)
			if not (self.resources[resource].amount + ticket.res[resource] >= 0): return false
		return true
	
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
	print(player.resources)
	#ui.updateCursor.connect(updateCursorDisplay)
	#ui.cursorSelect.connect(tilemapDisplay.cursor.set_selected)

func _process(delta):
	tilemapDisplay.process(delta, tilemap, get_global_mouse_position())
	ui.process(player, tilemapDisplay.cursor.tile, tilemapDisplay.cursor.selected)

func updateCursorDisplay(buildingType: StringName):
	tilemapDisplay.cursor.building.set_animation(buildingType)

func updateBuildingAtCursor(building: BuildingScripts.Building):
	tilemap.buildingMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * Global.mapSize.x] = building

func updateTileAtCursor(tile: GameTilemap.Terrain):
	tilemap.tileMap[tilemapDisplay.cursor.tile.x + tilemapDisplay.cursor.tile.y * Global.mapSize.x] =  tile

func attemptPlaceTile(tile: GameTilemap.Terrain): pass

func attemptPlaceBuilding(building: BuildingScripts.Building):
	if player.canBeRedeemed(building.cost):
		player.redeemCost(building.cost)
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
	ui.infoBox.build.disabled = false#(not cursorSelected) or (not cost.canBeRedeemed(player.resources))
	building.call_deferred("free")
	#ui.infoBox.cancel.disabled = (not cursorSelected)
