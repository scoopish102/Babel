class_name Tile extends Object

var position : Vector2i
var tile : tileTypes
var terrain : terrainTypes

var hasBuilding : bool
var building : Building

enum tileTypes {NONE, PLAIN, SNOW, STONE, SAND, SEA, ROAD}
enum terrainTypes {NONE, FPLAIN, FSNOW, SPROUT, MTSAND, MTORESAND, ORESAND, MT, MTORE, ORE}

func _init(_position : Vector2i, _tile : int, _terrain : terrainTypes):
	position = _position
	tile = _tile
	terrain = _terrain
	hasBuilding = false
