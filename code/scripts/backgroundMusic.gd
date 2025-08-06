extends AudioStreamPlayer

@export var tracklist : Array[AudioStream]

func _ready():
	stop()
	set_stream(Global.currentAudio)
	play(Global.audioPosition)
	#play(60)
	pass

func saveAudioPosition():
	Global.currentAudio = stream
	Global.audioPosition = get_playback_position()

func _on_finished():
	var time = randf_range(10, 50)
	#print(time)
	await get_tree().create_timer(time).timeout
	set_stream(tracklist[randi_range(0, len(tracklist)-1)])
	play()
