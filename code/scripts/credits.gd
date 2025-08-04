extends Control

var i: float

#const mainMenu: PackedScene = preload("res://code/scenes/mainMenu.tscn")

func _ready():
	i = Global.transfer
	#$AnimationPlayer.current_animation_position = Global.tprog

func _process(_delta):
	i += _delta*60
	#print(i)
	i = fposmod(i, 360)
	$Control/Waves.position = Vector2(-320, -6) + Vector2(-4*fposmod(i/11.25, 32), -12*cos(deg_to_rad(i*2))+16)
	#$Moon.position = Vector2(488.0, 16)
	$Moon.position.y = -8*cos(deg_to_rad(i*2))+16
	#$Label.set_text(str(i))

func _on_exit_pressed():
	Global.transfer = i
	Global.tprog = $AnimationPlayer.current_animation_position
	#print("lets get outa here scoobs")
	#get_tree().unload_current_scene()
	get_tree().change_scene_to_file("res://code/scenes/mainMenu.tscn")
