class_name SingleOptionNotification extends Notification

@onready var optionButton := $Backdrop/MarginContainer/VBoxContainer/Choices/Confirm

#static var sampleText := "Come, let us build ourselves a city, with a tower that reaches to the heavens, so that we may make a name for ourselves."
#signal result(result: bool)

func setOption(option: String = "Okay"):
	self.optionText.text = option

func exitButtonPressed():
	result.emit(false)
	self.queue_free()

func confirmButtonPressed():
	result.emit(true)
	self.queue_free()
