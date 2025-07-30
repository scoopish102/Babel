class_name Cursor extends Node2D

@onready var sprite := $Sprite
@onready var overlay := $overlay
@onready var spriteOverlay := $spriteOverlay
@onready var building := $building
@onready var lower := $lowerindicator
@onready var lowest := $lowestindicator
@onready var superlow := $superLowest
var tile : Vector2i = Vector2i.ZERO
var tileDisplay : Vector2i = Vector2i.ZERO
var selected : bool = false
var outOfBounds : bool = false

@export var defaultColor : Color
@export var selectedColor : Color

func _ready():
	building.set_animation(&"None")

func set_selected(selected: bool):
	self.selected = selected

func process(pos: Vector2, outOfBounds: bool):
	#sprite.z_index = z + 1
	#overlay.z_index = z + 3
	self.outOfBounds = outOfBounds
	if self.outOfBounds: 
		visible = false
		return
	else: visible = true
	self.global_position = pos
	if selected: 
		sprite.modulate = selectedColor
		spriteOverlay.modulate = selectedColor
		spriteOverlay.modulate.a = 0.3
	else:
		sprite.modulate = defaultColor
		spriteOverlay.modulate = defaultColor
		spriteOverlay.modulate.a = 0.3
	if building.animation == &"Platform": building.offset.y = -16
	else: building.offset.y = 0
	self.overlay.offset.y = 0
	self.overlay.z_index = sprite.z_index
	if self.lower.visible: 
		self.overlay.offset.y = self.lower.offset.y+16
		self.overlay.z_index = self.lower.z_index
	if self.lowest.visible: 
		self.overlay.offset.y = self.lowest.offset.y+16
		self.overlay.z_index = self.lowest.z_index
	if self.superlow.visible: 
		self.overlay.offset.y = self.superlow.offset.y+16
		self.overlay.z_index = self.superlow.z_index

func _unhandled_input(event):
	if not self.outOfBounds and event.is_action_released("ui_select"): 
		self.selected = not self.selected
		#print(self.tile)
		#print(self.tile.x + self.tile.y * Global.mapSize.x)
