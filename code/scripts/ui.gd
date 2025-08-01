class_name GUI extends Control

@onready var resources := $TopBar/Backdrop/Resources
@onready var tabBar := $BottomBar/TabBar
@onready var optionBar := $BottomBar/Options
@onready var infoBox := $InfoBox
@onready var turnButton := $Turn/Backdrop
@onready var layerText := $TopBar/Backdrop/Resources/LayerControl/Label
@onready var layerControl := $"TopBar/Backdrop/Resources/LayerControl/Panel/Change Layer"
@onready var floodProgress := $"TopBar/Seperator/ProgressBar"
@onready var floodProgressVertical := $"TopBar/Seperator/VerticalBarDisplay"
@onready var floodPercentLabel := $"TopBar/Seperator/floodPercent/HBoxContainer/Label"
@onready var floodPercentNextTurn := $"TopBar/Seperator/floodPercent/HBoxContainer/nextTurn"
@onready var waterLevelLabel := $"TopBar/Seperator/floodLayer/Label"

@export var notificationBlueprint: PackedScene
@export var choiceNotificationBlueprint: PackedScene

var tabSelected: int = 0
var optionSelected: int = -1

signal updateCursor(buildingType: StringName)
signal cursorSelect(selected: bool)
signal attemptPlaceTile(tile: GameTilemap.Terrain)
signal attemptPlaceBuilding(building: BuildingScripts.Building)
signal processBuildButtons(cursorSelected: bool, buildingName: StringName)
signal processInteract()
signal changeWorkerCount(change: int)
signal destroyBuilding()
signal processInfoTab()
signal nextTurn()
signal incrementLayer(increment: int)
signal attemptPlaceWaterPlatform()

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

func process(player: Game.Player, cursorCoords: Vector2, cursorSelected: bool, hasBuilding: bool, turn: int, layer: int, maxLayer: int,
		waterLevel, floodLevel, rainNextTurn):
	resources.get_child(0).setLabels(player.resources[&"Food"].amount, player.resources[&"Food"].change)
	resources.get_child(1).setLabels(player.resources[&"Earth"].amount, player.resources[&"Earth"].change)
	#resources.get_child(2).setLabels(player.resources["Bronze"].amount, player.resources["Bronze"].change)
	resources.get_child(2).setLabels(player.resources[&"Labor"].amount, player.resources[&"Labor"].change)
	
	turnButton.get_child(1).set_text("Turn " + str(turn))
	
	layerText.set_text("Height " + str(layer))
	if layer >= maxLayer-1: layerControl.get_child(1).disabled = true
	else: layerControl.get_child(1).disabled = false
	if layer <= 0: layerControl.get_child(2).disabled = true
	else: layerControl.get_child(2).disabled = false
	
	floodPercentLabel.text = "FLOOD PROGRESS: " + str(int(roundf(floodLevel))) + "%"
	waterLevelLabel.text = "LAYER " + str(waterLevel)
	floodProgress.value = floodLevel
	floodProgress.get_child(0).position.x = floodProgress.size.x * float(100-floodLevel)/100 - 12
	floodProgressVertical.value = floodLevel + 2
	if floodLevel + rainNextTurn < 100: 
		floodPercentNextTurn.text = " + " + str(int(roundf(rainNextTurn))) + "% NEXT TURN"
		floodPercentNextTurn.label_settings.font_color = Color(0.0, 0.22, 0.573)
	else: 
		floodPercentNextTurn.text = " LAYER " + str(waterLevel) + " WILL BE FLOODED NEXT TURN"
		floodPercentNextTurn.label_settings.font_color = Color(1.0, 0.0, 0.0)
	
	for i in range(len(tabBar.get_children())):
		if i == 1: 
			if cursorSelected and hasBuilding: tabBar.get_child(i).button.disabled = false
			else: 
				tabBar.get_child(i).button.disabled = true
				#if tabSelected == 1: tabSelected = 0
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
			infoOptions()
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
	processInteract.emit()

func infoOptions():
	processInfoTab.emit()

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
			infoBox.position.y = 296-64
			if tabSelected == 0 and optionSelected != -1: infoBoxForBuild(cursorSelected)

var FIP = {
	&"Food": "res://code/resources/miniResourceIcons/food.tres",
	&"Earth": "res://code/resources/miniResourceIcons/earth.tres",
	&"Labor": "res://code/resources/miniResourceIcons/labor.tres"
}

func infoBoxForBuild(cursorSelected):
	var bOps = optionBar.get_child(0)
	var selectedBuilding = bOps.get_child(optionSelected)
	if selectedBuilding.typeName == &"PlatformWater": infoBox.title.text = "Water\nPlatform"
	else: infoBox.title.text = selectedBuilding.typeName
	infoBox.icon.texture = selectedBuilding.icon
	infoBox.infoText.text = selectedBuilding.description
	processBuildButtons.emit(cursorSelected, selectedBuilding.typeName)

func infoBoxToggled(toggle):
	if toggle: infoBoxMode = InfoBoxMode.MINI
	else: infoBoxMode = InfoBoxMode.SHOW

func infoBoxBuildPressed():
	var bOps = optionBar.get_child(0)
	var selectedBuilding = bOps.get_child(optionSelected)
	if selectedBuilding.typeName == &"Platform": 
		attemptPlaceTile.emit(GameTilemap.Terrain.Platform)
		cursorSelect.emit(false)
		return
	if selectedBuilding.typeName == &"PlatformWater": 
		attemptPlaceWaterPlatform.emit()
		cursorSelect.emit(false)
		return
	var building : BuildingScripts.Building
	match selectedBuilding.typeName:
		&"City": building = BuildingScripts.City.new()
		&"Farm": building = BuildingScripts.Farm.new()
		&"Kiln": building = BuildingScripts.Kiln.new()
	attemptPlaceBuilding.emit(building)
	cursorSelect.emit(false)

func infoBoxCancelPressed():
	optionSelected = -1
	updateCursor.emit(&"None")
	infoBoxMode = InfoBoxMode.HIDE

func lessWorkers(): changeWorkerCount.emit(-1)

func moreWorkers(): changeWorkerCount.emit(1)

func destroyBuildingPressed(): destroyBuilding.emit()

func turnButtonPressed(): 
	nextTurn.emit()
	#turnButton.get_child(0).rotation += 10

func layerUp(): 
	incrementLayer.emit(1)
	cursorSelect.emit(false)

func layerDown(): 
	incrementLayer.emit(-1)
	cursorSelect.emit(false)
