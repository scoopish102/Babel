class_name TilemapDisplay extends Node2D

@export var tileDisplayScene : PackedScene
@export var cameraSpeed : int

var tilemap : GameTileMap
var tiles : Array[Tile]
var tileDisplayMap : Array[TileDisplay]
#Camera Position Variables
var cameraPosition : Vector2 = Vector2.ZERO
var cameraVelocity : Vector2 = Vector2.ZERO
var cameraAcceleration : Vector2 = Vector2.ZERO
var minPos : Vector2
var maxPos : Vector2
var origin : Vector2

func start(gameSize : Vector2i):
	#print(Global.mapSize)
	tilemap = GameTileMap.new(gameSize)
	tiles = tilemap.tiles
	for x in range(Global.mapSize.x):
		for y in range(Global.mapSize.y):
			var newTileDisplay = tileDisplayScene.instantiate()
			tileDisplayMap.append(newTileDisplay)
			add_child(newTileDisplay)
			newTileDisplay.updateDisplay(tiles[x+y*tilemap.size.x])
	updatePosition()
	minPos = Vector2(-((tilemap.size.x)*Global.tileSize.x-tilemap.size.y*Global.tileSize.y), -Global.mapSize.y*Global.tileSize.y/2)
	maxPos = Vector2(((tilemap.size.x)*Global.tileSize.x-tilemap.size.y*Global.tileSize.y), ((tilemap.size.x)*Global.tileSize.x-tilemap.size.y*Global.tileSize.y)-Global.mapSize.y*Global.tileSize.y/2)
	origin = Vector2((maxPos.x+minPos.x)/2, (maxPos.y+minPos.y)/2)

func updatePosition():
	for x in range(Global.mapSize.x):
		for y in range(Global.mapSize.y):
			var tileDisplay = tileDisplayMap[x+y*Global.mapSize.x]
			tileDisplay.mapPosition = Vector2(x, y)
			tileDisplay.mapPosition -= Vector2((cameraPosition.x / Global.tileSize.x) + (cameraPosition.y / Global.tileSize.y), 
					(cameraPosition.y / Global.tileSize.y) - (cameraPosition.x / Global.tileSize.x))
			tileDisplay.mapPosition = Vector2(fposmod(tileDisplay.mapPosition.x, Global.mapSize.x), 
					fposmod(tileDisplay.mapPosition.y, Global.mapSize.y))
			var relativeTilePosition = Vector2((tileDisplay.mapPosition.x),(tileDisplay.mapPosition.y))
			relativeTilePosition += Vector2((cameraPosition.x / Global.tileSize.x) + (cameraPosition.y / Global.tileSize.y), 
					(cameraPosition.y / Global.tileSize.y) -(cameraPosition.x / Global.tileSize.x))
			relativeTilePosition = floor(relativeTilePosition)
			#if x == 0 and y == 0: print(relativeTilePosition)
			if (relativeTilePosition.x >= tilemap.size.x or relativeTilePosition.y >= tilemap.size.y
					or relativeTilePosition.x < 0 or relativeTilePosition.y < 0):
				tileDisplay.outOfBoundsDisplay()
			else:
				tileDisplay.updateDisplay(tiles[relativeTilePosition.x+relativeTilePosition.y*tilemap.size.x])
			tileDisplay.updatePosition()

func _process(_delta):
	cameraAcceleration = Vector2i(2*(Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")),
			Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up"))
	cameraVelocity += cameraAcceleration * cameraSpeed
	cameraVelocity = Vector2(cameraVelocity.x, cameraVelocity.y)
	cameraVelocity *= 0.9
	cameraPosition += cameraVelocity
	cameraPosition = Vector2(min(cameraPosition.x, (1-abs(cameraPosition.y-origin.y)/abs(maxPos.y-origin.y))*maxPos.x),min(cameraPosition.y, maxPos.y))
	cameraPosition = Vector2(max(cameraPosition.x, -(1-abs(cameraPosition.y-origin.y)/abs(maxPos.y-origin.y))*maxPos.x),max(cameraPosition.y, minPos.y))
	cameraPosition = floor(cameraPosition)
	#print(cameraPosition)
	updatePosition()
