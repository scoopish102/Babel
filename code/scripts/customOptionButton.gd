class_name CustomOptionButton extends NinePatchRect

@onready var button := $GButton
@onready var label := $Label
@onready var timer := $Timer
@export var defaultModulate : Color
@export var hoverModulate : Color
@export var pressedModulate : Color
@export var selectedModulate : Color
@export var typeName : StringName
@export var icon : Texture2D
@export_multiline var description : String

func process(selected: bool) -> bool:
	#print(selected)
	self_modulate = defaultModulate
	if button.is_hovered(): self_modulate = hoverModulate
	#if button.is_pressed(): self_modulate = pressedModulate
	if selected: self_modulate = selectedModulate
	return button.is_pressed() and timer.is_stopped()
