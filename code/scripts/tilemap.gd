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

func getTerrainMapCode() -> String:
	var code: String = ""
	var index = 0
	var layerIndex = 0
	var count = 0
	var terrainType: Terrain = terrainMap[0][0]
	for layer in terrainMap:
		index = 0
		if layerIndex == len(terrainMap): continue
		for terrain in layer:
			if terrainType == terrain:
				count += 1
			else:
				if count != 0: code += str(terrainType) + "*" + str(count) + "|"
				count = 1
				terrainType = terrain
			index += 1
		layerIndex += 1
	if count != 0: code += str(terrainType) + "*" + str(count) + "|"
	code = code.erase(code.length() - 1, 1)
	return code

func convertTerrainMapCode(code: String):
	terrainMap.clear()
	var tempt = []
	for h in range(mapHeight+1):
		for y in range(mapSize.y):
			for x in range(mapSize.x):
				tempt.append(Terrain.Air)
		terrainMap.append(tempt.duplicate())
		tempt = []
	var index = 0
	var layer = 0
	for i in (code.get_slice_count("|")):
		var slice = code.get_slice("|", i)
		var terrain = int(slice.get_slice("*", 0)) as Terrain
		var count = int(slice.get_slice("*", 1))
		#print(str(Terrain.keys()[terrain]) + " terrain times " + str(count))
		for t in range(count): 
			terrainMap[layer][index] = terrain
			index += 1
			if index >= mapSize.x*mapSize.y: 
				index = 0
				layer += 1

func getBuildingMapCode() -> String:
	var code: String = ""
	var index = 0
	var layerIndex = 0
	for layer in buildingMap:
		index = 0
		for building in layer:
			if building != null:
				code += building.buildingName + "@" + str(layerIndex) + "@" + str(index)
				if building is BuildingScripts.ProductionBuilding:
					code += "@" + str(building.workers) + "|"
				else: code += "@" + str(-1) + "|"
			index += 1
		layerIndex += 1
	code = code.erase(code.length() - 1, 1)
	return code

func convertBuildingMapCode(code: String):
	buildingMap.clear()
	var tempb = []
	for h in range(mapHeight):
		for y in range(mapSize.y):
			for x in range(mapSize.x):
				tempb.append(null)
		buildingMap.append(tempb.duplicate())
		tempb = []
	for i in (code.get_slice_count("|")):
		var slice = code.get_slice("|", i)
		var buildingName = slice.get_slice("@", 0)
		var buildingLayer = int(slice.get_slice("@", 1))
		var buildingIndex = int(slice.get_slice("@", 2))
		var buildingWorkers = int(slice.get_slice("@", 3))
		var building: BuildingScripts.Building
		match buildingName:
			&"City": building = BuildingScripts.City.new()
			&"Farm": building = BuildingScripts.Farm.new()
			&"Kiln": building = BuildingScripts.Kiln.new()
		if buildingWorkers != -1 and building is BuildingScripts.ProductionBuilding: 
			building.workers = buildingWorkers
		buildingMap[buildingLayer][buildingIndex] = building

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
		tempt = []
		tempb = []
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
