class_name Game extends Node2D

@onready var tilemapDisplay : TilemapDisplay = $TilemapDisplay
@export var gameSize : Vector2i
@export var noise : FastNoiseLite

var tilemap : GameTileMap

func _ready():
	tilemapDisplay.start(gameSize)
	tilemap = tilemapDisplay.tilemap
	tilemap.generateWorld(noise)
