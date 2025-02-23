extends AudioStreamPlayer

class_name LevelMusicPlayer

@export var fadeout_time : float = 3

@export var starting_volume : float = 0

@export var silent_volume : float = -80

@export var delay_autoplay : bool = false

@export var delay_autoplay_time : float = 0.25

var is_fading_out : bool = false

func _ready():
	volume_db = starting_volume
	if (delay_autoplay and !autoplay):
		do_delayed_autoplay()

func do_delayed_autoplay():
	if (playing):
		return
	
	await get_tree().create_timer(delay_autoplay_time).timeout
	if (!playing):
		play()

func restart_music():
	play()

func fade_out():
	if (is_fading_out or !is_playing()):
		return
	
	is_fading_out = true
	
	while (volume_db > silent_volume):
		volume_db = move_toward(volume_db, silent_volume, ((starting_volume - silent_volume) / fadeout_time) * get_process_delta_time())
		await get_tree().process_frame
	
	stop()
	volume_db = starting_volume
	is_fading_out = false
