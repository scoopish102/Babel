class_name TutorialNotification extends Notification

@onready var choices := $Backdrop/MarginContainer/VBoxContainer/Choices
@onready var choiceTitle := $Backdrop/MarginContainer/VBoxContainer/ChoiceTitle
@onready var nextButton := $Backdrop/MarginContainer/VBoxContainer/Choices/Next
@onready var backButton := $Backdrop/MarginContainer/VBoxContainer/Choices/Back
@export var choiceNotificationBlueprint : PackedScene
#@export var index: int

signal nextPage()
signal previousPage()

func getChoice() -> bool:
	return await result

func nextPressed():
	nextPage.emit()

func backPressed():
	previousPage.emit()

func exitButtonPressed():
	var ays: ChoiceNotification = choiceNotificationBlueprint.instantiate()
	get_parent().add_child(ays)
	ays.size = Vector2(256, 128+96)
	ays.centerOnScreen()
	ays.setContent(
		"Exit Tutorial", "Are you sure you want to exit the tutorial? The game may be confusing and difficult without instructions on how to play.
		\nThe tutorial can be viewed again by starting a new game.")
	ays.setChoices("Exit anyway?")
	var result = await ays.getChoice()
	ays.queue_free()
	if not result: return
	#result.emit(false)
	get_parent().queue_free()
