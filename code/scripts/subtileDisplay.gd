class_name SubtileDisplay extends Node2D

@onready var tileSprite := $tileSprite
@onready var terrainSprite := $terrainSprite

var tile : Tile.tileTypes
var terrain : Tile.terrainTypes

func updateDisplay():
	tileSprite.frame = tile
	terrainSprite.frame = terrain
