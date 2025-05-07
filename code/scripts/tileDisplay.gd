class_name TileDisplay extends Node2D

#Stored in North, East, South, West order. 
#Displayed in North, West, East, South (up, left, right, down) order.
@onready var subtiles : Array[SubtileDisplay] = [$north, $east, $south, $west]

var tile : Tile
var mapPosition : Vector2 = Vector2.ZERO

func updateDisplay(_tile : Tile):
	tile = _tile
	for subtile in subtiles:
		subtile.tile = tile.tile
		subtile.terrain = tile.terrain
		subtile.updateDisplay()

func outOfBoundsDisplay():
	for subtile in subtiles:
		subtile.tile = Tile.tileTypes.NONE
		subtile.terrain = Tile.terrainTypes.NONE
		subtile.updateDisplay()

func updatePosition():
	position = Vector2((mapPosition.x-mapPosition.y) * Global.tileSize.x/2, 
			(mapPosition.x + mapPosition.y) * Global.tileSize.y/2)
	position.y -= Global.mapSize.y * Global.tileSize.y / 2
	z_index = position.y
