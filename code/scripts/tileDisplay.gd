class_name TileDisplay extends Node2D

var mapPosition : Vector2 = Vector2.ZERO
var terrain : GameTilemap.Terrain
var building : BuildingScripts.Building

@onready var terrainDisplay := $terrain
@onready var buildingDisplay := $building

func updateDisplay(_terrain, _building):
	self.terrain = _terrain
	self.building = _building
	updateSprite()

func updateSprite(outOfBounds: bool = false):
	if outOfBounds: 
		terrainDisplay.play("None")
		buildingDisplay.play("None")
		return
	match self.terrain:
		GameTilemap.Terrain.NONE:
			terrainDisplay.play("None")
		GameTilemap.Terrain.GRASS:
			terrainDisplay.play("Grass")
		GameTilemap.Terrain.SAND:
			terrainDisplay.play("Sand")
		GameTilemap.Terrain.WATER:
			terrainDisplay.play("Water")
		GameTilemap.Terrain.DIRT:
			terrainDisplay.play("Dirt")
		GameTilemap.Terrain.PLATFORM:
			terrainDisplay.play("Platform")
	match typeof(self.building):
		null:
			buildingDisplay.play("None")
		BuildingScripts.House:
			buildingDisplay.play("House")
		BuildingScripts.Farm:
			buildingDisplay.play("Farm")
		BuildingScripts.Kiln:
			buildingDisplay.play("Kiln")

func outOfBoundsDisplay():
	self.terrain = GameTilemap.Terrain.NONE
	self.building = null
	updateSprite(true)

func updatePosition():
	position = Vector2((mapPosition.x-mapPosition.y) * Global.tileSize.x/2, 
			(mapPosition.x + mapPosition.y) * Global.tileSize.y/2)
	position.y -= Global.mapSize.y * Global.tileSize.y / 2
	@warning_ignore("narrowing_conversion")
	z_index = position.y*2
