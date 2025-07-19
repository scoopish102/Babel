class_name Cursor extends Node2D

@onready var sprite := $Sprite

func process(pos: Vector2):
	self.position = pos
	#print(self.position)
