class_name CustomTabButton extends NinePatchRect

@onready var button := $Button
@onready var label := $Label
@export var defaultModulate : Color
@export var hoverModulate : Color
@export var pressedModulate : Color
@export var selectedModulate : Color
@export var disabledModulate : Color

func process(selected: bool) -> bool:
	if button.disabled: 
		self_modulate = disabledModulate
		return false
	self_modulate = defaultModulate
	if button.is_hovered(): self_modulate = hoverModulate
	#if button.is_pressed(): self_modulate = pressedModulate
	if selected: self_modulate = selectedModulate
	return button.is_pressed()
