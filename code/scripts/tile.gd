class_name Tile extends Object

var position : Vector2i
var tile : tileTypes
var terrain : terrainTypes

enum tileTypes {PLAIN, SNOW, STONE, SAND, SEA, ROAD, FARM}
enum terrainTypes {NONE, FPLAIN, FSNOW, SPROUT, MTSAND, MTORESAND, ORESAND, MT, MTORE, ORE}

func _init(_position : Vector2i, _tile : tileTypes, _terrain : terrainTypes):
	position = _position
	tile = _tile
	terrain = _terrain
