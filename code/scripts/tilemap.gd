class_name GameTilemap extends Object

enum Terrain {
	NONE, GRASS, SAND, WATER, DIRT, PLATFORM
}

var terrainMap : Array[Terrain] = []
var buildingMap : Array[BuildingScripts.Building] = []
var mapSize : Vector2i

func _init(size : Vector2i):
	mapSize = size
	for y in range(mapSize.y):
		for x in range(mapSize.x):
			#The tilemap is arranged so that the first to the last value corresponds
			#to left to right, up to down in the tilemap's display ingame. Thus
			#x values increase the index incrementally while y values increase it
			#by the size of the map's width
			terrainMap.append(0)
			buildingMap.append(null)
	#print(terrainMap)

func generateWorld(noise):
	@warning_ignore("integer_division")
	var center = Vector2(mapSize.x/2, mapSize.y/2)
	@warning_ignore("integer_division")
	var rad = (mapSize.x+mapSize.y)/4 - 5
	var temp = 0
	var dist = 0
	var randomOffset = Vector2i(randi()%1000, randi()%1000)
	for y in range(mapSize.y):
		for x in range(mapSize.x):
			dist = floor(sqrt((x-center.x)**2 + (y-center.y)**2))
			temp = noise.get_noise_2dv(Vector2i(x, y) + randomOffset)
			if dist + temp*10 < rad: terrainMap[y*mapSize.x+x] = Terrain.GRASS
			else: terrainMap[y*mapSize.x+x] = Terrain.WATER
	buildingMap[center.y*mapSize.x+center.x] = BuildingScripts.City.new()
	buildingMap[center.y*mapSize.x+center.x-1] = BuildingScripts.Farm.new()
	buildingMap[(center.y+1)*mapSize.x+center.x] = BuildingScripts.Kiln.new()
	buildingMap[(center.y+1)*mapSize.x+center.x].workers = 1
	buildingMap[center.y*mapSize.x+center.x-1].workers = 1
	print(center.y*mapSize.x+center.x)
	#print(buildingMap[center.y*mapSize.x+center.x].update())
	#print(buildingMap[(center.y+1)*mapSize.x+center.x].update())
	#print(ResourceScripts.mergeTickets(buildingMap[center.y*mapSize.x+center.x].update(), buildingMap[(center.y+1)*mapSize.x+center.x].update()))
