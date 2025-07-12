class_name TilemapDisplay extends Node2D

@export var tileDisplayScene : PackedScene
@export var cameraSpeed : int

var tileDisplayMap : Array[TileDisplay]

#Camera Position Variables
var cameraPosition : Vector2 = Vector2.ZERO
var cameraVelocity : Vector2 = Vector2.ZERO
var cameraAcceleration : Vector2 = Vector2.ZERO
var minPos : Vector2
var maxPos : Vector2
var origin : Vector2

func start(tileMap : GameTilemap):
	#print(Global.mapSize)
	for x in range(Global.mapSize.x):
		for y in range(Global.mapSize.y):
			var newTileDisplay = tileDisplayScene.instantiate()
			tileDisplayMap.append(newTileDisplay)
			add_child(newTileDisplay)
			newTileDisplay.updateDisplay(tileMap.terrainMap[x + y], tileMap.buildingMap[x + y])
	updatePosition(tileMap)
	minPos = Vector2(-((tileMap.mapSize.x)*Global.tileSize.x-tileMap.mapSize.y*Global.tileSize.y), -Global.mapSize.y*Global.tileSize.y/2)
	maxPos = Vector2(((tileMap.mapSize.x)*Global.tileSize.x-tileMap.mapSize.y*Global.tileSize.y), ((tileMap.mapSize.x)*Global.tileSize.x-tileMap.mapSize.y*Global.tileSize.y)-Global.mapSize.y*Global.tileSize.y/2)
	origin = Vector2((maxPos.x+minPos.x)/2, (maxPos.y+minPos.y)/2)

func updatePosition(tileMap : GameTilemap):
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
			if (relativeTilePosition.x >= tileMap.mapSize.x or relativeTilePosition.y >= tileMap.mapSize.y
					or relativeTilePosition.x < 0 or relativeTilePosition.y < 0):
				tileDisplay.outOfBoundsDisplay()
			else:
				tileDisplay.updateDisplay(tileMap.terrainMap[relativeTilePosition.x+relativeTilePosition.y*tileMap.mapSize.x], tileMap.buildingMap[relativeTilePosition.x+relativeTilePosition.y*tileMap.mapSize.x])
			tileDisplay.updatePosition()

func upperBoundFunction(x: float) -> float:
	return ((origin.y-minPos.y)/(maxPos.x-origin.x))*abs(x-origin.x) + minPos.y
func lowerBoundFunction(x: float) -> float:
	return ((origin.y-maxPos.y)/(maxPos.x-origin.x))*abs(x-origin.x) + maxPos.y
func leftBoundFunction(y: float) -> float:
	return ((origin.x-minPos.x)/(minPos.y-origin.y))*abs(y-origin.y) + minPos.x
func rightBoundFunction(y: float) -> float:
	return ((origin.x-maxPos.x)/(minPos.y-origin.y))*abs(y-origin.y) + maxPos.x

func process(delta, tileMap):
	cameraAcceleration = Vector2i(2*(Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")),
			Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")) * cameraSpeed
	#cameraVelocity = Vector2(cameraVelocity.x, cameraVelocity.y)
	if abs(cameraVelocity.x) < cameraSpeed*1.2: cameraVelocity.x = 0
	else: cameraVelocity.x -= cameraSpeed * sign(cameraVelocity.x)*1.2
	if abs(cameraVelocity.y) < cameraSpeed*0.6: cameraVelocity.y = 0
	else: cameraVelocity.y -= cameraSpeed * sign(cameraVelocity.y)*0.6
	
	cameraVelocity += cameraAcceleration
	cameraPosition += cameraVelocity * delta * 60
	
	cameraVelocity = Vector2(max(min(cameraVelocity.x, 20), -20), max(min(cameraVelocity.y, 10), -10))
	
	#p1 = (origin.x, minPos.y), p2 = (maxPos.x, origin.y)
	#slope = (origin.y-minPos.y)/(maxPos.x-origin.x)
	#equation: y < slope*abs(x-origin.x) + minPos.y
	#euqation: y < ((origin.y-minPos.y)/(maxPos.x-origin.x))*abs(x-origin.x) + minPos.y
	
	#cameraPosition = Vector2(min(cameraPosition.x, (1-abs(cameraPosition.y-origin.y)/abs(maxPos.y-origin.y))*maxPos.x), min(cameraPosition.y, maxPos.y))
	#cameraPosition = Vector2(max(cameraPosition.x, -(1-abs(cameraPosition.y-origin.y)/abs(maxPos.y-origin.y))*maxPos.x), max(cameraPosition.y, minPos.y))
	#cameraPosition = Vector2(min(cameraPosition.x, maxPos.x), min(cameraPosition.y, maxPos.y))
	#cameraPosition = Vector2(max(cameraPosition.x, minPos.x), max(cameraPosition.y, minPos.y))
	
	if cameraPosition.x > maxPos.x: cameraPosition.x = maxPos.x
	if cameraPosition.x < minPos.x: cameraPosition.x = minPos.x
	if cameraPosition.y > maxPos.y: cameraPosition.y = maxPos.y
	if cameraPosition.y < minPos.y: cameraPosition.y = minPos.y
	
	if cameraPosition.y < upperBoundFunction(cameraPosition.x): 
		cameraPosition.y = upperBoundFunction(cameraPosition.x)
	if cameraPosition.y > lowerBoundFunction(cameraPosition.x): 
		cameraPosition.y = lowerBoundFunction(cameraPosition.x)
	"""if cameraPosition.x < leftBoundFunction(cameraPosition.y): 
		cameraPosition.x = leftBoundFunction(cameraPosition.y)
	if cameraPosition.x > rightBoundFunction(cameraPosition.y): 
		cameraPosition.x = rightBoundFunction(cameraPosition.y)"""
	
	cameraPosition = floor(cameraPosition)
	#print(cameraPosition)
	updatePosition(tileMap)
