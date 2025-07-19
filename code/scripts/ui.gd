class_name GUI extends Control

@onready var resources := $TopBar/Backdrop/Resources
@onready var tabBar := $BottomBar/TabBar
@onready var optionBar := $BottomBar/Options
@onready var infoBox := $InfoBox
@onready var infoBoxMinimize := $InfoBox/Tab/Caption/Open

var tabSelected: int = 0
var optionSelected: int = -1

func process(player: Game.Player, cursorPos: Vector2, cursorCoords: Vector2):
	resources.get_child(0).setLabels(player.resources["Food"].amount, player.resources["Food"].change)
	resources.get_child(1).setLabels(player.resources["Earth"].amount, player.resources["Earth"].change)
	#resources.get_child(2).setLabels(player.resources["Bronze"].amount, player.resources["Bronze"].change)
	resources.get_child(2).setLabels(player.resources["Labor"].amount, player.resources["Labor"].change)
	for i in range(len(tabBar.get_children())):
		if tabBar.get_child(i).process(i == tabSelected): 
			tabSelected = i
			optionSelected = -1
		optionBar.get_child(i).visible = i == tabSelected
	match tabSelected:
		0: buildOptions()
		1: 
			interactOptions()
			infoBoxMode = -1
		2: 
			infoOptions(cursorCoords)
			infoBoxMode = -1
	processInfoBox()

func buildOptions():
	var bOps = optionBar.get_child(0)
	for i in range(len(bOps.get_children())):
		if bOps.get_child(i).process(i == optionSelected):
			bOps.get_child(i).timer.start()
			if not optionSelected == i: 
				optionSelected = i
				infoBoxMode = 1
			else: optionSelected = -1
	if optionSelected == -1: infoBoxMode = -1

func interactOptions():
	pass

func infoOptions(cursorCoords: Vector2):
	var fOps = optionBar.get_child(2)
	fOps.get_child(1).set_text("Tile at: (" + str(cursorCoords.x) + ", " + str(cursorCoords.y) + ")")

var infoBoxMode = -1

func processInfoBox():
	match infoBoxMode:
		-1: infoBox.visible = false
		0: 
			infoBox.visible = true
			infoBox.get_child(1).visible = false
			infoBox.position.y = 296+256
		1:
			infoBox.visible = true
			infoBox.get_child(1).visible = true
			infoBox.position.y = 296
