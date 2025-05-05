class_name TilemapDisplay extends Node2D

@export var tileDisplayScene : PackedScene

var tilemap : GameTileMap
var tiles : Array[Tile]
var tileDisplayMap : Array[TileDisplay]

func start(mapSize : Vector2i):
	tilemap = GameTileMap.new(mapSize)
	tiles = tilemap.tiles
	for x in range(tilemap.size.x):
		for y in range(tilemap.size.y):
			var newTileDisplay = tileDisplayScene.instantiate()
			tileDisplayMap.append(newTileDisplay)
			add_child(newTileDisplay)
			newTileDisplay.updateDisplay(tiles[x+y*tilemap.size.x])
	updatePosition()

func updatePosition():
	for x in range(tilemap.size.x):
		for y in range(tilemap.size.y):
			var tileDisplay = tileDisplayMap[x+y*tilemap.size.x]
			tileDisplay.position = Vector2((x-y)*Global.tileSize.x/2, 
					(x+y)*Global.tileSize.y/2 - Global.mapSize.y/2 * Global.tileSize.y)
