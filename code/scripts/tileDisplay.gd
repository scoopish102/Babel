class_name TileDisplay extends Node2D

var mapPosition : Vector2 = Vector2.ZERO
var terrain : GameTilemap.Terrain
var building
var secondTerrain : GameTilemap.Terrain
var thirdTerrain : GameTilemap.Terrain
var lowerTerrain : GameTilemap.Terrain
var lowerBuilding
var lower2: GameTilemap.Terrain
var lower3: GameTilemap.Terrain

@onready var terrainDisplay := $terrain
@onready var buildingDisplay := $building
@onready var secondLayerDisplay := $secondLayer
@onready var lowerLayerDisplay := $lowerLayer
@onready var lowerBuildingDisplay := $lowerBuilding
@onready var lowestLayer := $superLowerLayer

func _ready():
	terrainDisplay.set_animation(&"None")
	buildingDisplay.set_animation(&"None")
	secondLayerDisplay.set_animation(&"None")
	lowerLayerDisplay.set_animation(&"None")
	lowerBuildingDisplay.set_animation(&"None")
	lowestLayer.set_animation(&"None")

func updateDisplay(dtm, tileMap, layer, waterLevel):
	var tile = dtm.x+dtm.y*tileMap.mapSize.x
	self.terrain = tileMap.terrainMap[layer][tile]
	self.building = tileMap.buildingMap[layer][tile]
	if layer < tileMap.mapHeight-1: self.secondTerrain = tileMap.terrainMap[layer+1][tile]
	else: self.secondTerrain = GameTilemap.Terrain.Air
	if layer < tileMap.mapHeight-2: self.thirdTerrain = tileMap.terrainMap[layer+2][tile]
	else: self.thirdTerrain = GameTilemap.Terrain.Air
	if layer > 0:
		self.lowerTerrain = tileMap.terrainMap[layer-1][tile]
		self.lowerBuilding = tileMap.buildingMap[layer-1][tile]
	else:
		self.lowerTerrain = GameTilemap.Terrain.Air
		self.lowerBuilding = null
	if layer > 1: self.lower2 = tileMap.terrainMap[layer-2][tile]
	else: self.lower2 = GameTilemap.Terrain.Air
	if layer > 2: self.lower3 = tileMap.terrainMap[layer-3][tile]
	else: self.lower3 = GameTilemap.Terrain.Air
	#if self.building != null: print("bananana")
	updateSprite(layer, waterLevel)

func updateSprite(layer, waterLevel, outOfBounds: bool = false):
	terrainDisplay.modulate = Color(1.0, 1.0, 1.0)
	buildingDisplay.modulate = Color(1.0, 1.0, 1.0)
	secondLayerDisplay.modulate = Color(1.0, 1.0, 1.0, 0.471)
	lowerBuildingDisplay.modulate = Color(0.85, 0.85, 0.85)
	lowerLayerDisplay.modulate = Color(0.85, 0.85, 0.85)
	lowestLayer.modulate = Color(0.7, 0.7, 0.7)
	if outOfBounds: 
		terrainDisplay.set_animation(&"None")
		buildingDisplay.set_animation(&"None")
		secondLayerDisplay.set_animation(&"None")
		lowerLayerDisplay.set_animation(&"None")
		lowestLayer.set_animation(&"None")
		return
	
	match self.terrain:
		GameTilemap.Terrain.Air:
			if waterLevel >= layer: 
				terrainDisplay.set_animation(&"Water")
			else: 
				terrainDisplay.set_animation(&"None")
		GameTilemap.Terrain.Grass:
			terrainDisplay.set_animation(&"Grass")
		GameTilemap.Terrain.Platform:
			terrainDisplay.set_animation(&"Platform")
	if terrainDisplay.animation == &"Water": 
		if waterLevel > layer: 
			terrainDisplay.frame = 2
		else: terrainDisplay.frame = 1
	elif terrainDisplay.animation == &"Platform":
		if waterLevel > layer: 
			terrainDisplay.frame = 2
		elif waterLevel == layer: terrainDisplay.frame = 1
		else: terrainDisplay.frame = 0
	else:
		if waterLevel > layer: 
			terrainDisplay.modulate = Color(0.192, 0.324, 0.8)
			buildingDisplay.modulate = Color(0.192, 0.324, 0.8)
			#lowerBuildingDisplay.modulate = Color(0.156, 0.263, 0.65)
		#	if waterLevel > layer+1: secondLayerDisplay.modulate = Color(0.192, 0.324, 0.8, 0.588)
		#if waterLevel > layer-1: lowerLayerDisplay.modulate = Color(0.156, 0.263, 0.65)
		#if waterLevel > layer-2: lowestLayer.modulate = Color(0.12, 0.202, 0.5)
		if self.secondTerrain == self.terrain: 
			if self.lowerTerrain == self.terrain: terrainDisplay.frame = 2
			else: terrainDisplay.frame = 3
		else: 
			if self.lowerTerrain == self.terrain: terrainDisplay.frame = 1
			else: terrainDisplay.frame = 0
	#if waterLevel >= layer: secondLayerDisplay.set_animation(&"None")
	#else:
	match self.secondTerrain:
		GameTilemap.Terrain.Air:
			if waterLevel >= layer+1: secondLayerDisplay.set_animation(&"Water")
			else: secondLayerDisplay.set_animation(&"None")
		GameTilemap.Terrain.Grass:
			secondLayerDisplay.set_animation(&"Grass")
		GameTilemap.Terrain.Platform:
			secondLayerDisplay.set_animation(&"Platform")
	if secondLayerDisplay.animation == &"Water": 
		secondLayerDisplay.modulate.a = 0.2
		if waterLevel > layer+1: 
			secondLayerDisplay.frame = 2
		elif layer+1 == waterLevel: 
			#secondLayerDisplay.set_animation(&"None")
			secondLayerDisplay.frame = 1
	elif secondLayerDisplay.animation == &"Platform":
		if waterLevel > layer+1: 
			secondLayerDisplay.frame = 2
		elif waterLevel == layer+1: secondLayerDisplay.frame = 1
		else: secondLayerDisplay.frame = 0
	else:
		if waterLevel > layer+1: secondLayerDisplay.modulate = Color(0.192, 0.324, 0.8, 0.471)
		if self.thirdTerrain == self.secondTerrain: 
			if self.terrain == self.secondTerrain: secondLayerDisplay.frame = 2
			else: secondLayerDisplay.frame = 3
		else: 
			if self.terrain == self.secondTerrain: secondLayerDisplay.frame = 1
			else: secondLayerDisplay.frame = 0
	
	lowerLayerDisplay.frame = 0
	match self.lowerTerrain: 
		GameTilemap.Terrain.Air:
			if waterLevel >= layer-1: lowerLayerDisplay.set_animation(&"Water")
			else: lowerLayerDisplay.set_animation(&"None")
		GameTilemap.Terrain.Grass:
			lowerLayerDisplay.set_animation(&"Grass")
		GameTilemap.Terrain.Platform:
			lowerLayerDisplay.set_animation(&"Platform")
	if lowerLayerDisplay.animation == &"Water": 
		if waterLevel > layer-1: 
			lowerLayerDisplay.frame = 2
		elif layer-1 == waterLevel: lowerLayerDisplay.frame = 1
	elif lowerLayerDisplay.animation == &"Platform":
		if waterLevel > layer-1: 
			lowerLayerDisplay.frame = 2
		elif waterLevel == layer-1: lowerLayerDisplay.frame = 1
		else: lowerLayerDisplay.frame = 0
	else:
		if waterLevel > layer-1:
			lowerLayerDisplay.modulate = Color(0.156, 0.263, 0.65)
			lowerBuildingDisplay.modulate = Color(0.156, 0.263, 0.65)
		if self.terrain == self.lowerTerrain: 
			if self.lower2 == self.lowerTerrain: lowerLayerDisplay.frame = 2
			else: lowerLayerDisplay.frame = 3
		else: 
			if self.lower2 == self.lowerTerrain: lowerLayerDisplay.frame = 1
			else: lowerLayerDisplay.frame = 0

	match self.lower2:
		GameTilemap.Terrain.Air:
			if waterLevel >= layer-2: lowestLayer.set_animation(&"Water")
			else: lowestLayer.set_animation(&"None")
		GameTilemap.Terrain.Grass:
			lowestLayer.set_animation(&"Grass")
		GameTilemap.Terrain.Platform:
			lowestLayer.set_animation(&"Platform")
	if lowestLayer.animation == &"Water": 
		if waterLevel > layer-2: 
			if layer == 0: lowestLayer.frame = 3
			else: lowestLayer.frame = 2
		else: lowestLayer.frame = 1
	elif lowestLayer.animation == &"Platform":
		if waterLevel > layer-2: 
			lowestLayer.frame = 2
		elif waterLevel == layer-2: lowestLayer.frame = 1
		else: lowestLayer.frame = 0
	else:
		if waterLevel > layer-2: lowestLayer.modulate = Color(0.12, 0.202, 0.5)
		if self.lowerTerrain == self.lower2: 
			if self.lower3 == self.lower2: lowestLayer.frame = 2
			else: lowestLayer.frame = 3
		else: 
			if self.lower3 == self.lower2: lowestLayer.frame = 1
			else: lowestLayer.frame = 0
	
	if self.building == null: buildingDisplay.set_animation(&"None")
	else:
		buildingDisplay.set_animation(self.building.buildingName)
		if self.building is BuildingScripts.ProductionBuilding:
			if self.building.workers > 0: buildingDisplay.frame = 0
			else: buildingDisplay.frame = 1
		else: buildingDisplay.frame = 0
	if self.lowerBuilding == null: lowerBuildingDisplay.set_animation(&"None")
	else:
		lowerBuildingDisplay.set_animation(self.lowerBuilding.buildingName)
		if self.lowerBuilding is BuildingScripts.ProductionBuilding:
			if self.lowerBuilding.workers > 0: lowerBuildingDisplay.frame = 0
			else: lowerBuildingDisplay.frame = 1
		else: lowerBuildingDisplay.frame = 0

func outOfBoundsDisplay():
	self.terrain = GameTilemap.Terrain.Air
	self.building = null
	self.secondTerrain = GameTilemap.Terrain.Air
	self.thirdTerrain = GameTilemap.Terrain.Air
	self.lowerTerrain = GameTilemap.Terrain.Air
	self.lowerBuilding = null
	self.lower2 = GameTilemap.Terrain.Air
	self.lower3 = GameTilemap.Terrain.Air
	updateSprite(0, -1, true)

func updatePosition():
	position = Vector2((mapPosition.x-mapPosition.y) * Global.tileSize.x/2, 
			(mapPosition.x + mapPosition.y) * Global.tileSize.y/2)
	position.y -= Global.mapSize.y * Global.tileSize.y / 2
	#@warning_ignore("narrowing_conversion")
	#z_index = position.y*2
	#buildingDisplay.z_index = z_index + 2
