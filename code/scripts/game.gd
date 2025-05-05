class_name Game extends Node2D

@onready var tilemapDisplay : TilemapDisplay = $TilemapDisplay

func _ready():
	tilemapDisplay.start(Global.mapSize)
