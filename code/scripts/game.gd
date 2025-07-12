class_name Game extends Node2D

@onready var tilemapDisplay : TilemapDisplay = $TilemapDisplay
@export var gameSize : Vector2i
@export var noise : FastNoiseLite

var tilemap : GameTilemap

class Player:
	var resources : ResourceScripts.RResourceAccount
	var score : int
	
	func _init():
		self.resources = ResourceScripts.RResourceAccount.new({
			"Food": ResourceScripts.RResource.new("Food", 4, false),
			"Earth": ResourceScripts.RResource.new("Earth", 4, false),
			"Bronze": ResourceScripts.RResource.new("Bronze", 0, false),
			"Labor": ResourceScripts.RResource.new("Labor", 4, true)})
		self.score = 0

func _ready():
	print(Global.mapSize)
	gameSize = Vector2(50, 50)
	tilemap = GameTilemap.new(gameSize)
	tilemap.generateWorld()
	tilemapDisplay.start(tilemap)

func _process(delta):
	tilemapDisplay.process(delta, tilemap)
