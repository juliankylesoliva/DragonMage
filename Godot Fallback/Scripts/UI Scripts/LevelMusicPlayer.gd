extends AudioStreamPlayer

class_name LevelMusicPlayer

@export var fadeout_time : float = 3

@export var starting_volume : float = 0

@export var silent_volume : float = -80

var is_fading_out : bool = false

func _ready():
	volume_db = starting_volume

func fade_out():
	if (is_fading_out or !is_playing()):
		return
	
	is_fading_out = true
	
	while (volume_db > silent_volume):
		volume_db = move_toward(volume_db, silent_volume, ((starting_volume - silent_volume) / fadeout_time) * get_process_delta_time())
		await get_tree().process_frame
	
	stop()
	volume_db = starting_volume
