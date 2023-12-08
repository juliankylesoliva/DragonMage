extends Node

class_name AudioHandler

@export var hub : PlayerHub

func play_sound(sound_name : String, volume : float = 0, pitch : float = 1, bus_name : StringName = "SFX"):
	var stream : AudioStream = SoundFactory.get_sound_by_name(sound_name)
	if (stream != null):
		hub.stream_player.stream = stream
		hub.stream_player.volume_db = volume
		hub.stream_player.pitch_scale = pitch
		hub.stream_player.bus = bus_name
		hub.stream_player.play()
