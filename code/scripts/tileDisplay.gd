class_name TileDisplay extends Node2D

#Stored in North, East, South, West order. 
#Displayed in North, West, East, South (up, left, right, down) order.
@onready var subtiles : Array[SubtileDisplay] = [$north, $east, $south, $west]

var tile : Tile

func updateDisplay(_tile : Tile) :
	tile = _tile
	for subtile in subtiles:
		subtile.tile = tile.tile
		subtile.terrain = tile.terrain
		subtile.updateDisplay()
