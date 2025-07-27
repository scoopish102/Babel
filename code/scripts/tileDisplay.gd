class_name TileDisplay extends Node2D

var mapPosition : Vector2 = Vector2.ZERO
var terrain : GameTilemap.Terrain
var building

@onready var terrainDisplay := $terrain
@onready var buildingDisplay := $building

func _ready():
	terrainDisplay.set_animation(&"None")
	buildingDisplay.set_animation(&"None")

func updateDisplay(_terrain, _building):
	self.terrain = _terrain
	self.building = _building
	#if self.building != null: print("bananana")
	updateSprite()

func updateSprite(outOfBounds: bool = false):
	if outOfBounds: 
		terrainDisplay.set_animation(&"None")
		buildingDisplay.set_animation(&"None")
		return
	match self.terrain:
		GameTilemap.Terrain.NONE:
			terrainDisplay.set_animation(&"None")
		GameTilemap.Terrain.GRASS:
			terrainDisplay.set_animation(&"Grass")
		GameTilemap.Terrain.SAND:
			terrainDisplay.set_animation(&"Sand")
		GameTilemap.Terrain.WATER:
			terrainDisplay.set_animation(&"Water")
		GameTilemap.Terrain.DIRT:
			terrainDisplay.set_animation(&"Dirt")
		GameTilemap.Terrain.PLATFORM:
			terrainDisplay.set_animation(&"Platform")
	if self.building == null: buildingDisplay.set_animation(&"None")
	else:
		buildingDisplay.set_animation(self.building.buildingName)

func outOfBoundsDisplay():
	self.terrain = GameTilemap.Terrain.NONE
	self.building = &"None"
	updateSprite(true)

func updatePosition():
	position = Vector2((mapPosition.x-mapPosition.y) * Global.tileSize.x/2, 
			(mapPosition.x + mapPosition.y) * Global.tileSize.y/2)
	position.y -= Global.mapSize.y * Global.tileSize.y / 2
	#@warning_ignore("narrowing_conversion")
	#z_index = position.y*2
	#buildingDisplay.z_index = z_index + 2
