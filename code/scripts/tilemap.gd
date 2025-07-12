class_name GameTilemap extends Object

enum Terrain {
	NONE, GRASS, SAND, WATER, DIRT, PLATFORM
}

var terrainMap : Array[Terrain] = []
var buildingMap : Array[BuildingScripts.Building] = []
var mapSize : Vector2i

func _init(size : Vector2i):
	mapSize = size
	for x in range(mapSize.x):
		for y in range(mapSize.y):
			#The tilemap is arranged so that the first to the last value corresponds
			#to left to right, up to down in the tilemap's display ingame. Thus
			#x values increase the index incrementally while y values increase it
			#by the size of the map's width
			terrainMap.append(randi_range(1,5))
			buildingMap.append(null)
	print(terrainMap)

func generateWorld():
	pass
