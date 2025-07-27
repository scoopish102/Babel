class_name GUI extends Control

@onready var resources := $TopBar/Backdrop/Resources
@onready var tabBar := $BottomBar/TabBar
@onready var optionBar := $BottomBar/Options
@onready var infoBox := $InfoBox

var tabSelected: int = 0
var optionSelected: int = -1

signal updateCursor(buildingType: StringName)

signal cursorSelect(selected: bool)

signal attemptPlaceTile(tile: GameTilemap.Terrain)

signal attemptPlaceBuilding(building: BuildingScripts.Building)

signal processBuildButtons(cursorSelected: bool, buildingName: StringName)

enum OptionMode {
	BUILD,
	INTERACT,
	INFO
}

enum InfoBoxMode {
	HIDE,
	MINI,
	SHOW
}

func process(player: Game.Player, cursorCoords: Vector2, cursorSelected: bool):
	resources.get_child(0).setLabels(player.resources[&"Food"].amount, player.resources[&"Food"].change)
	resources.get_child(1).setLabels(player.resources[&"Earth"].amount, player.resources[&"Earth"].change)
	#resources.get_child(2).setLabels(player.resources["Bronze"].amount, player.resources["Bronze"].change)
	resources.get_child(2).setLabels(player.resources[&"Labor"].amount, player.resources[&"Labor"].change)
	for i in range(len(tabBar.get_children())):
		if tabBar.get_child(i).process(i as OptionMode == tabSelected): 
			tabSelected = i as OptionMode
			optionSelected = -1
			updateCursor.emit(&"None")
			infoBoxMode = InfoBoxMode.HIDE
		optionBar.get_child(i).visible = i as OptionMode == tabSelected
	match tabSelected:
		OptionMode.BUILD: buildOptions()
		OptionMode.INTERACT: 
			interactOptions()
		OptionMode.INFO: 
			infoOptions(cursorCoords)
	processInfoBox(cursorSelected)

func buildOptions():
	var bOps = optionBar.get_child(0)
	for i in range(len(bOps.get_children())):
		if bOps.get_child(i).process(i == optionSelected):
			bOps.get_child(i).timer.start()
			if not optionSelected == i: 
				optionSelected = i
				infoBoxMode = InfoBoxMode.SHOW
				updateCursor.emit(bOps.get_child(i).typeName)
			else: 
				optionSelected = -1
				updateCursor.emit(&"None")
				infoBoxMode = InfoBoxMode.HIDE

func interactOptions():
	pass

func infoOptions(cursorCoords: Vector2):
	var fOps = optionBar.get_child(2)
	fOps.get_child(1).set_text("Tile at: (" + str(cursorCoords.x) + ", " + str(cursorCoords.y) + ")")

var infoBoxMode = InfoBoxMode.HIDE

func processInfoBox(cursorSelected: bool):
	match infoBoxMode:
		InfoBoxMode.HIDE: infoBox.visible = false
		InfoBoxMode.MINI: 
			infoBox.visible = true
			infoBox.content.visible = false
			infoBox.position.y = 296+256
		InfoBoxMode.SHOW:
			infoBox.visible = true
			infoBox.content.visible = true
			infoBox.position.y = 296
			if tabSelected == 0 and optionSelected != -1: infoBoxForBuild(cursorSelected)

var FIP = {
	"Food": "res://code/resources/miniResourceIcons/food.tres",
	"Earth": "res://code/resources/miniResourceIcons/earth.tres",
	"Labor": "res://code/resources/miniResourceIcons/labor.tres"
}

func infoBoxForBuild(cursorSelected):
	var bOps = optionBar.get_child(0)
	var selectedBuilding = bOps.get_child(optionSelected)
	infoBox.title.text = selectedBuilding.typeName
	infoBox.icon.texture = selectedBuilding.icon
	infoBox.infoText.text = selectedBuilding.description
	processBuildButtons.emit(cursorSelected, selectedBuilding.typeName)

func infoBoxToggled(toggle):
	if toggle: infoBoxMode = InfoBoxMode.MINI
	else: infoBoxMode = InfoBoxMode.SHOW

func infoBoxBuildPressed():
	var building : BuildingScripts.Building
	var bOps = optionBar.get_child(0)
	var selectedBuilding = bOps.get_child(optionSelected)
	match selectedBuilding.typeName:
		&"City": building = BuildingScripts.City.new()
		&"Farm": building = BuildingScripts.Farm.new()
		&"Kiln": building = BuildingScripts.Kiln.new()
	attemptPlaceBuilding.emit(building)
	#cursorSelect.emit(false)

func infoBoxCancelPressed():
	optionSelected = -1
	updateCursor.emit(&"None")
	infoBoxMode = InfoBoxMode.HIDE
