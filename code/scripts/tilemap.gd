class_name GameTileMap extends Object

var tiles : Array[Tile]
var size : Vector2i

func _init(_size : Vector2i):
	size = _size
	for x in range(size.x):
		for y in range(size.y):
			#The tilemap is arranged so that the first to the last value corresponds
			#to left to right, up to down in the tilemap's display ingame. Thus
			#x values increase the index incrementally while y values increase it
			#by the size of the map's width
			tiles.append(Tile.new(Vector2i(x, y), Tile.tileTypes.NONE, Tile.terrainTypes.NONE))

func generateWorld(noise : FastNoiseLite):
	for x in range(size.x):
		for y in range(size.y):
			var noiseValue = noise.get_noise_2d(x, y)
			tiles[x+y*size.x].tile = Tile.tileTypes.PLAIN
