class_name Cursor extends Node2D

@onready var sprite := $Sprite
@onready var building := $building
var tile : Vector2i = Vector2i.ZERO
var tileDisplay : Vector2i = Vector2i.ZERO
var selected : bool = false
var outOfBounds : bool = false

@export var defaultColor : Color
@export var selectedColor : Color
@export var invalidColor : Color
@export var validColor : Color

func _ready():
	building.set_animation(&"None")

func set_selected(selected: bool):
	self.selected = selected

func process(pos: Vector2, outOfBounds: bool):
	self.outOfBounds = outOfBounds
	if self.outOfBounds: 
		visible = false
		return
	else: visible = true
	self.global_position = pos
	if selected: 
		sprite.modulate = selectedColor
	else:
		sprite.modulate = defaultColor

func _unhandled_input(event):
	if not self.outOfBounds and event.is_action_released("ui_select"): 
		self.selected = not self.selected
		print(self.tile)
	pass
