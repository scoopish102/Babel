extends Control

var i: float
var moonBobbing = false
@onready var content := $MarginContainer/VBoxContainer/PanelContainer/RichTextLabel
signal leave()

#const mainMenu: PackedScene = preload("res://code/scenes/mainMenu.tscn")

func _ready():
	i = Global.transfer
	#$AnimationPlayer.current_animation_position = Global.tprog
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($Moon, "position", Vector2(488, 16), 2).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Moon, "size", Vector2(176, 176), 2).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Moon, "pivot_offset", Vector2(176/2, 176/2), 2).set_trans(Tween.TRANS_QUAD)
	tween.set_parallel(false)
	tween.tween_callback(allowMoonBobbing)

func allowMoonBobbing():
	moonBobbing = true
	$MarginContainer/VBoxContainer/Button.disabled = false

func _process(_delta):
	i += _delta*60
	#print(i)
	i = fposmod(i, 360)
	$Control/Waves.position = Vector2(-320, -6) + Vector2(-4*fposmod(i/11.25, 32), -12*cos(deg_to_rad(i*2))+16)
	#$Moon.position = Vector2(488.0, 16)
	if moonBobbing: $Moon.position = Vector2(488, 16)
	$Moon.position.y += -8*cos(deg_to_rad(i*2))
	#$Label.set_text(str(i))

func _on_exit_pressed():
	Global.transfer = i
	Global.tprog = $AnimationPlayer.current_animation_position
	#print("lets get outa here scoobs")
	#get_tree().unload_current_scene()
	leave.emit()
