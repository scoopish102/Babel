class_name GameTilemap extends Object

enum Terrain {
	Air, Grass, Platform
}

var terrainMap : Array[Array] = []
var buildingMap : Array[Array] = []
var mapSize : Vector2i
var mapHeight: int = 1
var waterLevel: int = 0
var floodPercentage: float = 0

func getBottomEmptyTileCount(tile: Vector2, layer: int) -> float:
	#Water isn't empty btw schlawg
	var count: float = 0
	var empty: bool
	var i: int = 0
	if layer < waterLevel: return 0
	while (i <= layer):
		empty = terrainMap[layer-i][tile.x+tile.y*mapSize.x] == Terrain.Air
		if empty: 
			if waterLevel == layer-i: count += 0.5
			else: count += 1
		else: break
		i += 1
	return count

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
	mapHeight = 1
	var tempt = []
	var tempb = []
	for h in range(mapHeight+1):
		for y in range(mapSize.y):
			for x in range(mapSize.x):
				tempt.append(0)
				tempb.append(null)
		self.terrainMap.append(tempt.duplicate())
		self.buildingMap.append(tempb.duplicate())
	#print(terrainMap)

func addLayer():
	mapHeight += 1
	var tempt = []
	var tempb = []
	for y in range(mapSize.y):
		for x in range(mapSize.x):
			tempt.append(0)
			tempb.append(null)
	self.terrainMap.append(tempt.duplicate())
	self.buildingMap.append(tempb.duplicate())
	if mapHeight == len(self.terrainMap): self.terrainMap.append(tempt.duplicate())
	if mapHeight == len(self.buildingMap): self.buildingMap.append(tempb.duplicate())
	#print(terrainMap[mapHeight-1])

func generateWorld(noise):
	@warning_ignore("integer_division")
	var center = Vector2(mapSize.x/2, mapSize.y/2)
	@warning_ignore("integer_division")
	var rad = (mapSize.x+mapSize.y)/4 - 5
	var temp = 0
	var dist = 0
	var strength = 0
	var randomOffset = Vector2i(randi()%1000, randi()%1000)
	for h in range(mapHeight):
		for y in range(mapSize.y):
			for x in range(mapSize.x):
				dist = floor(sqrt((x-center.x)**2 + (y-center.y)**2))
				temp = noise.get_noise_2dv(Vector2i(x, y) + randomOffset)
				if h == 0: 
					if dist < 2: terrainMap[h][y*mapSize.x+x] = Terrain.Grass
					if dist + temp*(4-h) < rad-h: 
						if h == 0: terrainMap[h][y*mapSize.x+x] = Terrain.Grass
					else: terrainMap[h][y*mapSize.x+x] = Terrain.Air
	buildingMap[0][center.y*mapSize.x+center.x] = BuildingScripts.City.new()
	buildingMap[0][center.y*mapSize.x+center.x-1] = BuildingScripts.Farm.new()
	buildingMap[0][(center.y+1)*mapSize.x+center.x] = BuildingScripts.Kiln.new()
	buildingMap[0][(center.y+1)*mapSize.x+center.x].workers = 1
	buildingMap[0][center.y*mapSize.x+center.x-1].workers = 1
	#print(center.y*mapSize.x+center.x)
	#print(buildingMap[center.y*mapSize.x+center.x].update())
	#print(buildingMap[(center.y+1)*mapSize.x+center.x].update())
	#print(ResourceScripts.mergeTickets(buildingMap[center.y*mapSize.x+center.x].update(), buildingMap[(center.y+1)*mapSize.x+center.x].update()))
