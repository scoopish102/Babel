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
@onready var menuButton := $"Turn/Backdrop/HBoxContainer/MenuButton"
@onready var menu := $"MenuStuff"
@onready var menuButtons := {
	&"Resume": $"MenuStuff/Menu/VBoxContainer/Resume",
	&"Save": $"MenuStuff/Menu/VBoxContainer/Save",
	&"Resign": $"MenuStuff/Menu/VBoxContainer/Resign",
	&"Return": $"MenuStuff/Menu/VBoxContainer/Return",
	&"Quit": $"MenuStuff/Menu/VBoxContainer/Quit",
}
@onready var notifBox := $NotificationBox

@export var notificationBlueprint: PackedScene
@export var choiceNotificationBlueprint: PackedScene
@export var singleOptionNotificationBlueprint: PackedScene

var notifications: Array = []

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

func _ready():
	notifBox.show()

#function gleamed from the wisdom of u/Nkzar on r/Godot. awesome work to an odd problem
func clean(dirty_array: Array) -> Array:
	var clean_array := []
	for item in dirty_array:
		if is_instance_valid(item): clean_array.append(item)
	return clean_array

func process(player: Game.Player, cursorCoords: Vector2, cursorSelected: bool, hasBuilding: bool, turn: int, layer: int, maxLayer: int,
		waterLevel, floodLevel):
	resources.get_child(0).setLabels(player.resources[&"Food"].amount, player.resources[&"Food"].change)
	resources.get_child(1).setLabels(player.resources[&"Earth"].amount, player.resources[&"Earth"].change)
	#resources.get_child(2).setLabels(player.resources["Bronze"].amount, player.resources["Bronze"].change)
	resources.get_child(2).setLabels(player.resources[&"Labor"].amount, player.resources[&"Labor"].change)
	
	turnButton.get_child(0).get_child(0).set_text(str(turn))
	
	notifications = clean(notifications)
	
	if (player.resources[&"Labor"].change < 0): 
		turnButton.get_child(0).disabled = true
		turnButton.get_child(0).tooltip_text = "Resolve labor shortage first."
	elif len(notifications) > 0:
		turnButton.get_child(0).disabled = true
		turnButton.get_child(0).tooltip_text = "Resolve notification first."
	else: 
		turnButton.get_child(0).disabled = false
		turnButton.get_child(0).tooltip_text = "Press to begin the next turn."
	
	layerText.set_text("Height " + str(layer))
	if layer >= maxLayer-1: layerControl.get_child(1).disabled = true
	else: layerControl.get_child(1).disabled = false
	if layer <= 0: layerControl.get_child(2).disabled = true
	else: layerControl.get_child(2).disabled = false
	
	floodPercentLabel.text = "FLOOD PROGRESS: " + str(int(roundf(floodLevel))) + "%"
	waterLevelLabel.text = "HEIGHT " + str(waterLevel)
	floodProgress.value = floodLevel
	floodProgress.get_child(0).position.x = floodProgress.size.x * float(100-floodLevel)/100 - 12
	floodProgressVertical.value = floodLevel + 2
	if floodLevel + player.rainNextTurn < 100: 
		floodPercentNextTurn.text = " + " + str(int(roundf(player.rainNextTurn))) + "% NEXT TURN"
		floodPercentNextTurn.label_settings.font_color = Color(0.0, 0.22, 0.573)
	else: 
		floodPercentNextTurn.text = " HEIGHT " + str(waterLevel) + " WILL BE FLOODED NEXT TURN"
		floodPercentNextTurn.label_settings.font_color = Color(1.0, 0.0, 0.0)
	
	for i in range(len(tabBar.get_children())):
		if i == 1: 
			#if cursorSelected and hasBuilding: tabBar.get_child(i).button.disabled = false
			#else: 
				#tabBar.get_child(i).button.disabled = true
				#if tabSelected == 1: tabSelected = 0
			pass
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

func menuToggled(toggle):
	if toggle: menu.visible = true
	else: menu.visible = false

func resumeGamePressed(): 
	menu.visible = false
	menuButton.set_pressed(false)

signal saveGame

func saveGamePressed():
	saveGame.emit()

signal resignGame

func resignGamePressed():
	var ays: ChoiceNotification = choiceNotificationBlueprint.instantiate()
	notifications.append(ays)
	add_child(ays)
	ays.size.y = 128+64
	ays.centerOnScreen()
	ays.setContent(
		"Resign Game", "Are you sure you want to give up here? When you resign, you will be unable to play this file again.")
	ays.setChoices("Resign anyway?")
	var result = await ays.getChoice()
	notifications.erase(ays)
	ays.queue_free()
	if not result: return
	resignGame.emit()

signal returnToMenu

func returnPressed():
	var ays: ChoiceNotification = choiceNotificationBlueprint.instantiate()
	notifications.append(ays)
	add_child(ays)
	ays.size.y = 128+64
	ays.centerOnScreen()
	ays.setContent(
		"Return to Menu", "Are you sure you want to return to the menu? Don't forget to save your progress.")
	ays.setChoices("Return anyway?")
	var result = await ays.getChoice()
	notifications.erase(ays)
	ays.queue_free()
	if not result: return
	returnToMenu.emit()

func quitToDesktop(): 
	var ays: ChoiceNotification = choiceNotificationBlueprint.instantiate()
	notifications.append(ays)
	add_child(ays)
	ays.size.y = 128+64
	ays.centerOnScreen()
	ays.setContent(
		"Quit Game", "Are you sure you want to quit? Don't forget to save your progress.")
	ays.setChoices("Quit anyway?")
	var result = await ays.getChoice()
	notifications.erase(ays)
	ays.queue_free()
	if not result: return
	get_tree().quit()
