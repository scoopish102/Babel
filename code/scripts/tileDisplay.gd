class_name TileDisplay extends Node2D

var mapPosition : Vector2 = Vector2.ZERO
var terrain : GameTilemap.Terrain
var building
var secondTerrain : GameTilemap.Terrain
var thirdTerrain : GameTilemap.Terrain
var lowerTerrain : GameTilemap.Terrain

@onready var terrainDisplay := $terrain
@onready var buildingDisplay := $building
@onready var secondLayerDisplay := $secondLayer
@onready var lowerLayerDisplay := $lowerLayer

func _ready():
	terrainDisplay.set_animation(&"None")
	buildingDisplay.set_animation(&"None")
	secondLayerDisplay.set_animation(&"None")

func updateDisplay(_terrain, _building, secondTerrain, thirdTerrain, lowerTerrain, layer, waterLevel):
	self.terrain = _terrain
	self.building = _building
	self.secondTerrain = secondTerrain
	self.thirdTerrain = thirdTerrain
	self.lowerTerrain = lowerTerrain
	#if self.building != null: print("bananana")
	updateSprite(layer, waterLevel)

func updateSprite(layer, waterLevel, outOfBounds: bool = false):
	terrainDisplay.modulate = Color(1.0, 1.0, 1.0)
	buildingDisplay.modulate = Color(1.0, 1.0, 1.0)
	secondLayerDisplay.modulate = Color(1.0, 1.0, 1.0, 0.294)
	if layer != 0: lowerLayerDisplay.modulate = Color(1.0, 1.0, 1.0, 0.294)
	else: lowerLayerDisplay.modulate = Color(1.0, 1.0, 1.0)
	if outOfBounds: 
		terrainDisplay.set_animation(&"None")
		buildingDisplay.set_animation(&"None")
		secondLayerDisplay.set_animation(&"None")
		lowerLayerDisplay.set_animation(&"None")
		$"cookie cutter/terrain".set_animation(terrainDisplay.animation)
		$"cookie cutter/terrain".frame = terrainDisplay.frame
		return
	match self.terrain:
		GameTilemap.Terrain.Air:
			if waterLevel >= layer: 
				terrainDisplay.set_animation(&"Water")
			else: 
				terrainDisplay.set_animation(&"None")
		GameTilemap.Terrain.Grass:
			terrainDisplay.set_animation(&"Grass")
		GameTilemap.Terrain.Sand:
			terrainDisplay.set_animation(&"Sand")
		GameTilemap.Terrain.Water:
			terrainDisplay.set_animation(&"Water")
		GameTilemap.Terrain.Dirt:
			terrainDisplay.set_animation(&"Dirt")
		GameTilemap.Terrain.Platform:
			terrainDisplay.set_animation(&"Platform")
	if terrainDisplay.animation == &"Water": 
		if waterLevel >= layer+1: 
			if layer == 0: terrainDisplay.frame = 3
			else: terrainDisplay.frame = 2
		elif layer == 0: terrainDisplay.frame = 1
		else: terrainDisplay.frame = 1
	else:
		if waterLevel > layer: 
			terrainDisplay.modulate = Color(0.196, 0.325, 0.808)
			buildingDisplay.modulate = Color(0.196, 0.325, 0.808)
			if waterLevel > layer+1: secondLayerDisplay.modulate = Color(0.196, 0.325, 0.808, 0.294)
		if waterLevel > layer-1: lowerLayerDisplay.modulate = Color(0.196, 0.325, 0.808, 0.294)
		if self.secondTerrain == self.terrain: 
			if self.lowerTerrain == self.terrain: terrainDisplay.frame = 2
			else: terrainDisplay.frame = 3
		else: 
			if self.lowerTerrain == self.terrain: terrainDisplay.frame = 1
			else: terrainDisplay.frame = 0
	match self.secondTerrain:
		GameTilemap.Terrain.Air:
			secondLayerDisplay.set_animation(&"None")
		GameTilemap.Terrain.Grass:
			secondLayerDisplay.set_animation(&"Grass")
		GameTilemap.Terrain.Sand:
			secondLayerDisplay.set_animation(&"Sand")
		GameTilemap.Terrain.Water:
			secondLayerDisplay.set_animation(&"Water")
		GameTilemap.Terrain.Dirt:
			secondLayerDisplay.set_animation(&"Dirt")
		GameTilemap.Terrain.Platform:
			secondLayerDisplay.set_animation(&"Platform")
	if self.thirdTerrain == self.secondTerrain: 
		if self.terrain == self.secondTerrain: secondLayerDisplay.frame = 2
		else: secondLayerDisplay.frame = 3
	else: 
		if self.terrain == self.secondTerrain: secondLayerDisplay.frame = 1
		else: secondLayerDisplay.frame = 0
	if self.building == null: buildingDisplay.set_animation(&"None")
	else:
		buildingDisplay.set_animation(self.building.buildingName)
		if self.building is BuildingScripts.ProductionBuilding:
			if self.building.workers > 0: buildingDisplay.frame = 0
			else: buildingDisplay.frame = 1
		else: buildingDisplay.frame = 0
	if layer > 0: 
		lowerLayerDisplay.frame = 0
		match self.lowerTerrain: 
			GameTilemap.Terrain.Air:
				if waterLevel > layer-1: lowerLayerDisplay.set_animation(&"Water")
				else: lowerLayerDisplay.set_animation(&"None")
			GameTilemap.Terrain.Grass:
				lowerLayerDisplay.set_animation(&"Grass")
			GameTilemap.Terrain.Platform:
				lowerLayerDisplay.set_animation(&"Platform")
	else: 
		lowerLayerDisplay.set_animation(&"Water")
		lowerLayerDisplay.frame = 3
	
	$"cookie cutter/terrain".set_animation(terrainDisplay.animation)
	$"cookie cutter/terrain".frame = terrainDisplay.frame

func outOfBoundsDisplay():
	self.terrain = GameTilemap.Terrain.Air
	self.building = &"None"
	
	updateSprite(0, -1, true)

func updatePosition():
	position = Vector2((mapPosition.x-mapPosition.y) * Global.tileSize.x/2, 
			(mapPosition.x + mapPosition.y) * Global.tileSize.y/2)
	position.y -= Global.mapSize.y * Global.tileSize.y / 2
	#@warning_ignore("narrowing_conversion")
	#z_index = position.y*2
	#buildingDisplay.z_index = z_index + 2
