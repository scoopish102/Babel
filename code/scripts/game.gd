class_name Game extends Node2D

@onready var tilemapDisplay := $TilemapDisplay
@onready var ui := $CanvasLayer/UI
@onready var cursor := $Cursor

@export var gameSize : Vector2i
@export var noise : FastNoiseLite

var tilemap : GameTilemap

class Player:
	var resources : Dictionary
	var score : int
	
	func _init():
		self.resources = {
			"Food": ResourceScripts.RResource.new("Food", 4, false),
			"Earth": ResourceScripts.RResource.new("Earth", 4, false),
			"Bronze": ResourceScripts.RResource.new("Bronze", 0, false),
			"Labor": ResourceScripts.RResource.new("Labor", 0, true)}
		self.score = 0
	
	func redeemCost(ticket: ResourceScripts.RResourceTicket):
		if ticket.canRedeem(self.resources):
			for resource in ticket.res:
				if resource in self.res: self.res[resource].addAmount(ticket.res[resource])
	
	func redeemBudget(ticket: ResourceScripts.RResourceTicket):
		for resource in ticket.res:
			if resource in self.res: self.res[resource].change += ticket.res[resource]
	
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

func _process(delta):
	tilemapDisplay.process(delta, tilemap)
	cursor.process(tilemapDisplay.snapPositionToGrid(get_global_mouse_position()))
	ui.process(player, cursor.position, tilemapDisplay.screenPositionToTileCoordinates(get_global_mouse_position()))
