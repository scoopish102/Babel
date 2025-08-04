extends Control

var i: float

#const gameScene: PackedScene = preload(Global.gameScene)
#const creditsScene: PackedScene = preload(Global.creditsScene)

func _ready():
	RenderingServer.set_default_clear_color(Color(0.0, 0.0, 0.0))
	i = Global.transfer
	#$AnimationPlayer.current_animation_position = Global.tprog
	var saveFile = FileAccess.open("res://code/saves/save.json", FileAccess.READ)
	var jsonString = saveFile.get_line()
	var json = JSON.new()
	var parse = json.parse(jsonString)
	if parse == 0: $"MarginContainer/VBoxContainer/Continue Game".visible = false
	saveFile.close()

func _process(_delta):
	i += _delta*60
	#print(i)
	i = fposmod(i, 360)
	$Control/Waves.position = Vector2(-320, -6) + Vector2(-4*fposmod(i/11.25, 32), -12*cos(deg_to_rad(i*2))+16)
	#$Moon.position = Vector2(488.0, 16)
	$Moon.position.y = -8*cos(deg_to_rad(i*2))+16
	$Label.set_text(str(i))

func _on_new_game_pressed():
	Global.newGame = true
	#get_tree().change_scene_to_file("res://code/scenes/game.tscn")
	loadingAnim("res://code/scenes/game.tscn")

func _on_continue_game_pressed():
	Global.newGame = false
	loadingAnim("res://code/scenes/game.tscn")

func _on_credits_pressed():
	Global.transfer = i
	Global.tprog = $AnimationPlayer.current_animation_position
	#get_tree().unload_current_scene()
	get_tree().change_scene_to_file("res://code/scenes/credits.tscn")

func _on_exit_pressed():
	get_tree().quit()

func loadingAnim(next_scene: String):
	$ColorRect.visible = true
	#ResourceLoader.load_threaded_request(next_scene)
	var tween = get_tree().create_tween()
	tween.set_parallel(false)
	tween.tween_property($ColorRect, "color", Color(0.0, 0.0, 0.0), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(loadScene.bind(next_scene))

func loadScene(next_scene: String):
	#get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(next_scene))
	get_tree().change_scene_to_file(next_scene)
