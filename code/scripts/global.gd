extends Node

var tileSize = Vector2i(128, 64)
var mapSize = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width")/tileSize.x+1, 
		((ProjectSettings.get_setting("display/window/size/viewport_height")/tileSize.y) as int)+1)
