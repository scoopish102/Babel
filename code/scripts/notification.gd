class_name Notification extends VBoxContainer

@onready var title := $Tab/HBoxContainer/Title
@onready var exitButton := $Tab/HBoxContainer/ExitButton
@onready var content := $Backdrop/MarginContainer/VBoxContainer/Text

static var sampleText := "Come, let us build ourselves a city, with a tower that reaches to the heavens, so that we may make a name for ourselves."
signal result(result: bool)

func setContent(_title: String, _text: String):
	self.title.text = _title
	self.content.text = _text

func exitButtonPressed():
	result.emit(false)
	self.queue_free()

func centerOnScreen():
	self.position.x = Global.cameraSize.x/2 - self.size.x/2
	self.position.y = Global.cameraSize.y/2 - self.size.y/2
