class_name TilemapDisplay extends Node2D

@onready var cursor := $Cursor

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
	cameraPosition = Vector2.ZERO #origin

func updatePosition(tileMap : GameTilemap):
	for y in range(Global.mapSize.y):
		for x in range(Global.mapSize.x):
			var tileDisplay = tileDisplayMap[x+y*Global.mapSize.x]
			tileDisplay.mapPosition = Vector2(x, y)
			tileDisplay.mapPosition -= Vector2((cameraPosition.x / Global.tileSize.x) + (cameraPosition.y / Global.tileSize.y), 
					(cameraPosition.y / Global.tileSize.y) - (cameraPosition.x / Global.tileSize.x))
			tileDisplay.mapPosition = Vector2(fposmod(tileDisplay.mapPosition.x, Global.mapSize.x), 
					fposmod(tileDisplay.mapPosition.y, Global.mapSize.y))
			var relativeTilePosition = tileDisplayPosToTileCoordinates(tileDisplay.mapPosition)
			"""Vector2((tileDisplay.mapPosition.x),(tileDisplay.mapPosition.y))
			relativeTilePosition += Vector2((cameraPosition.x / Global.tileSize.x) + (cameraPosition.y / Global.tileSize.y), 
					(cameraPosition.y / Global.tileSize.y) - (cameraPosition.x / Global.tileSize.x))
			relativeTilePosition = floor(relativeTilePosition)"""
			#if x == 0 and y == 0: print(relativeTilePosition)
			if checkCoordsOutOfBounds(tileMap, relativeTilePosition):
				tileDisplay.outOfBoundsDisplay()
			else:
				tileDisplay.updateDisplay(tileMap.terrainMap[relativeTilePosition.x+relativeTilePosition.y*tileMap.mapSize.x], tileMap.buildingMap[relativeTilePosition.x+relativeTilePosition.y*tileMap.mapSize.x])
			tileDisplay.updatePosition()

func checkCoordsOutOfBounds(tileMap : GameTilemap, coords: Vector2) -> bool:
	if coords.x >= tileMap.mapSize.x or coords.y >= tileMap.mapSize.y or coords.x < 0 or coords.y < 0: return true
	else: return false

func snapPositionToGrid(pos: Vector2) -> Vector2:
	var snappedPosition = screenPositionToTileDisplayCoordinates(pos + Vector2(cameraPosition))
	snappedPosition = tileDisplayMap[snappedPosition.x + snappedPosition.y*Global.mapSize.x].global_position
	return snappedPosition

func screenPositionToTileCoordinates(pos: Vector2) -> Vector2:
	var tileCoords = screenPositionToTileDisplayCoordinates(pos)
	tileCoords = tileDisplayPosToTileCoordinates(tileCoords)
	return tileCoords

func tileDisplayPosToTileCoordinates(coords: Vector2) -> Vector2:
	var tileCoords = coords
	tileCoords = Vector2((tileCoords.x),(tileCoords.y))
	tileCoords += Vector2((cameraPosition.x / Global.tileSize.x) + (cameraPosition.y / Global.tileSize.y), 
			(cameraPosition.y / Global.tileSize.y) - (cameraPosition.x / Global.tileSize.x))
	tileCoords = floor(tileCoords)
	return tileCoords

func tileCoordinatesToScreenPosition(coords: Vector2) -> Vector2:
	var screenPos = Vector2(coords)
	screenPos = Vector2(screenPos.x*Global.tileSize.x/2-screenPos.y*Global.tileSize.x/2, screenPos.y*Global.tileSize.y/2+screenPos.x*Global.tileSize.y/2)
	screenPos.y += -(Global.mapSize.y * Global.tileSize.y / 2)
	return screenPos - cameraPosition

func screenPositionToTileDisplayCoordinates(pos: Vector2) -> Vector2:
	var tileCoords = Vector2(pos.x, pos.y + Global.tileSize.y/2 - (Global.mapSize.y * Global.tileSize.y / 2))
	tileCoords = Vector2(tileCoords.y/Global.tileSize.y+tileCoords.x/Global.tileSize.x, tileCoords.y/Global.tileSize.y-tileCoords.x/Global.tileSize.x)
	tileCoords = floor(tileCoords)
	tileCoords = Vector2(fposmod(tileCoords.x, Global.mapSize.x), fposmod(tileCoords.y, Global.mapSize.y))
	#print(tileCoords)
	return tileCoords

func upperBoundFunction(x: float) -> float:
	return ((origin.y-minPos.y)/(maxPos.x-origin.x))*abs(x-origin.x) + minPos.y
func lowerBoundFunction(x: float) -> float:
	return ((origin.y-maxPos.y)/(maxPos.x-origin.x))*abs(x-origin.x) + maxPos.y
func leftBoundFunction(y: float) -> float:
	return ((origin.x-minPos.x)/(minPos.y-origin.y))*abs(y-origin.y) + minPos.x
func rightBoundFunction(y: float) -> float:
	return ((origin.x-maxPos.x)/(minPos.y-origin.y))*abs(y-origin.y) + maxPos.x

func process(delta, tileMap, mousePos):
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
	
	if not cursor.selected: 
		#cursor.tile = screenPositionToTileCoordinates(mousePos + Vector2(fmod(cameraPosition.x, Global.tileSize.x),fmod(cameraPosition.y, Global.tileSize.y)))
		cursor.tileDisplay = screenPositionToTileDisplayCoordinates(mousePos + Vector2(cameraPosition))
		#var isocampos = Vector2(cameraPosition.x+cameraPosition.y, cameraPosition.y-cameraPosition.x)
		#var fullMapsOffset = Vector2(isocampos.x/(Global.mapSize.x*Global.tileSize.x), 
		#		isocampos.y/(Global.mapSize.y*Global.tileSize.y))
		#fullMapsOffset = floor(fullMapsOffset)
		cursor.tile = Vector2(0, 0)
		if cursor.tileDisplay.x + cursor.tileDisplay.y*Global.mapSize.x > len(tileDisplayMap) or cursor.tileDisplay.x + cursor.tileDisplay.y*Global.mapSize.x < 0: 
			cursor.process(Vector2(0, 0), true, 1)
		else: 
			cursor.tile = tileDisplayMap[cursor.tileDisplay.x + cursor.tileDisplay.y*Global.mapSize.x].mapPosition
			cursor.tile = tileDisplayPosToTileCoordinates(cursor.tile) + Vector2(1, 1)
			cursor.process(tileDisplayMap[cursor.tileDisplay.x + cursor.tileDisplay.y*Global.mapSize.x].global_position, 
				checkCoordsOutOfBounds(tileMap, cursor.tile), 
				tileDisplayMap[cursor.tileDisplay.x + cursor.tileDisplay.y*Global.mapSize.x].z_index)
			#cursor.tile = tileDisplayPosToTileCoordinates(Vector2(cursor.global_position) + Vector2(cameraPosition))
	else: 
		if cursor.tileDisplay.x + cursor.tileDisplay.y*Global.mapSize.x > len(tileDisplayMap) or cursor.tileDisplay.x + cursor.tileDisplay.y*Global.mapSize.x < 0: 
			cursor.selected = false
			return
		else: 
			cursor.process(tileDisplayMap[cursor.tileDisplay.x + cursor.tileDisplay.y*Global.mapSize.x].global_position, 
					checkCoordsOutOfBounds(tileMap, cursor.tile), 
					tileDisplayMap[cursor.tileDisplay.x + cursor.tileDisplay.y*Global.mapSize.x].z_index)
			#print(tileMap.buildingMap[cursor.tile.x + cursor.tile.y*Global.mapSize.x])
	if (cursor.global_position.x > Global.cameraSize.x/2 or cursor.global_position.y > Global.cameraSize.y/2 
			or cursor.global_position.x < -Global.cameraSize.x/2 or cursor.global_position.y < -Global.cameraSize.y/2):
		#print("okala")
		cursor.selected = false
