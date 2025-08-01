extends Control

@onready var notif := $ChoiceNotification

func _ready():
	var result = await notif.getChoice()
	notif.queue_free()
	print(result)
