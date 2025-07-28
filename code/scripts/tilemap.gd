class_name GameTilemap extends Object

enum Terrain {
	Air, Grass, Sand, Water, Dirt, Platform
}

var terrainMap : Array[Terrain] = []
var buildingMap : Array[BuildingScripts.Building] = []
var mapSize : Vector2i

func getOrthogonalNeighbors(center: Vector2i) -> Dictionary[StringName, Vector2i]:
	var neighbors: Dictionary[StringName, Vector2i]
	neighbors[&"North"] = Vector2i(center.x, center.y - 1)
	neighbors[&"East"] = Vector2i(center.x + 1, center.y)
	neighbors[&"South"] = Vector2i(center.x, center.y + 1)
	neighbors[&"West"] = Vector2i(center.x - 1, center.y)
	for direction in neighbors.keys():
		if (neighbors[direction].x < 0 or neighbors[direction].y < 0 or 
				neighbors[direction].x > mapSize.x or neighbors[direction].y > mapSize.y): 
			neighbors.erase(direction)
	return neighbors

func getDiagonalNeighbors(center: Vector2i) -> Dictionary[StringName, Vector2i]:
	var neighbors: Dictionary[StringName, Vector2i]
	neighbors[&"Northwest"] = Vector2i(center.x - 1, center.y - 1)
	neighbors[&"Northeast"] = Vector2i(center.x + 1, center.y - 1)
	neighbors[&"Southeast"] = Vector2i(center.x + 1, center.y + 1)
	neighbors[&"Southwest"] = Vector2i(center.x - 1, center.y + 1)
	for direction in neighbors.keys():
		if (neighbors[direction].x < 0 or neighbors[direction].y < 0 or 
				neighbors[direction].x > mapSize.x or neighbors[direction].y > mapSize.y): 
			neighbors.erase(direction)
	return neighbors

func getAllNeighbors(center: Vector2i) -> Dictionary[StringName, Vector2i]:
	var neighbors: Dictionary[StringName, Vector2i]
	neighbors.merge(getOrthogonalNeighbors(center))
	neighbors.merge(getDiagonalNeighbors(center), true)
	#Technically don't need to check it again but... just in case, right?
	for direction in neighbors.keys():
		if (neighbors[direction].x < 0 or neighbors[direction].y < 0 or 
				neighbors[direction].x > mapSize.x or neighbors[direction].y > mapSize.y): 
			neighbors.erase(direction)
	return neighbors

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
			if dist < 4: terrainMap[y*mapSize.x+x] = Terrain.Grass
			elif dist + temp*5 < rad: terrainMap[y*mapSize.x+x] = Terrain.Grass
			else: terrainMap[y*mapSize.x+x] = Terrain.Water
	buildingMap[center.y*mapSize.x+center.x] = BuildingScripts.City.new()
	buildingMap[center.y*mapSize.x+center.x-1] = BuildingScripts.Farm.new()
	buildingMap[(center.y+1)*mapSize.x+center.x] = BuildingScripts.Kiln.new()
	buildingMap[(center.y+1)*mapSize.x+center.x].workers = 1
	buildingMap[center.y*mapSize.x+center.x-1].workers = 1
	#print(center.y*mapSize.x+center.x)
	#print(buildingMap[center.y*mapSize.x+center.x].update())
	#print(buildingMap[(center.y+1)*mapSize.x+center.x].update())
	#print(ResourceScripts.mergeTickets(buildingMap[center.y*mapSize.x+center.x].update(), buildingMap[(center.y+1)*mapSize.x+center.x].update()))
