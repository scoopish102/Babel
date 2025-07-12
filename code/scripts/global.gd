extends Node

const tileSize = Vector2(128, 64)
const tileHypotenuse = sqrt(pow(tileSize.x/2,2) + pow(tileSize.y/2,2))
var cameraSize = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"))
var mapSize = Vector2i(ceil(sqrt(pow(cameraSize.x,2) + pow(cameraSize.y,2))/tileHypotenuse)+2,
		ceil(sqrt(pow(cameraSize.x,2) + pow(cameraSize.y,2))/tileHypotenuse)+2) - Vector2i(10, 10)
