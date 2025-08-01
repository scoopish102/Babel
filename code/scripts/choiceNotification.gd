class_name ChoiceNotification extends Notification

@onready var choices := $Backdrop/MarginContainer/VBoxContainer/Choices
@onready var choiceTitle := $Backdrop/MarginContainer/VBoxContainer/ChoiceTitle
@onready var confirmButton := $Backdrop/MarginContainer/VBoxContainer/Choices/Yes
@onready var cancelButton := $Backdrop/MarginContainer/VBoxContainer/Choices/No

func setChoices(_choiceText: String = ""):
	self.choiceTitle.text = _choiceText

func getChoice() -> bool:
	return await result

func yesPressed():
	result.emit(true)
	queue_free()

func noPressed():
	result.emit(false)
	queue_free()
