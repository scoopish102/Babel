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
			terrainMap.append(0)
			buildingMap.append(null)
	#print(terrainMap)

func generateWorld(noise):
	for x in range(mapSize.x):
		for y in range(mapSize.y):
			terrainMap[x*mapSize.y+y] = randi_range(1, 5)
	return
	
	var center = Vector2(mapSize.x/2, mapSize.y/2)
	var rad = (mapSize.x+mapSize.y)/4 - 5
	var temp = 0
	var dist = 0
	var randomOffset = Vector2i(randi()%1000, randi()%1000)
	for x in range(mapSize.x):
		for y in range(mapSize.y):
			dist = floor(sqrt((x-center.x)**2 + (y-center.y)**2))
			temp = noise.get_noise_2dv(Vector2i(x, y) + randomOffset)
			if dist + temp*10 < rad: terrainMap[x*mapSize.y+y] = Terrain.GRASS
			else: terrainMap[x*mapSize.y+y] = Terrain.WATER
