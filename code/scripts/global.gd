extends Node

const tileSize = Vector2(128, 64)
const tileHypotenuse = sqrt(pow(tileSize.x/2,2) + pow(tileSize.y/2,2))
var cameraSize = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"))
var mapSize = Vector2i(ceil(sqrt(pow(cameraSize.x,2) + pow(cameraSize.y,2))/tileHypotenuse)+2,
		ceil(sqrt(pow(cameraSize.x,2) + pow(cameraSize.y,2))/tileHypotenuse)+2)
var FIP = {
	&"FoodLarge": "[img]res://code/resources/miniResourceIcons/foodLarge.tres[/img]",
	&"EarthLarge": "[img]res://code/resources/miniResourceIcons/earthLarge.tres[/img]",
	&"LaborLarge": "[img]res://code/resources/miniResourceIcons/laborLarge.tres[/img]",
	&"Food": "[img]res://code/resources/miniResourceIcons/food.tres[/img]",
	&"Earth": "[img]res://code/resources/miniResourceIcons/earth.tres[/img]",
	&"Labor": "[img]res://code/resources/miniResourceIcons/labor.tres[/img]"
}
