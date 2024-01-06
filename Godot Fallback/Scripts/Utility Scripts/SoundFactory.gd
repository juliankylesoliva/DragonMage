extends Node

var stream_dictonary : Dictionary

const path_prefix : String = "res://Sounds/"

const path_suffix : String = ".wav"

const default_distance : float = 512

func _ready():
	var file : FileAccess = FileAccess.open("res://Sounds/sounds_list.txt", FileAccess.READ)
	while (file.get_position() < file.get_length()):
		var line : String = file.get_line()
		if (FileAccess.file_exists(line)):
			var stream : AudioStream = load(line)
			var stream_name = line.right(-path_prefix.length()).left(-path_suffix.length())
			stream_dictonary[stream_name] = stream
	file.close()

func play_sound(stream : AudioStream, position : Vector2, volume : float = 0, pitch : float = 1, bus_name : StringName = "Master"):
	var instance = AudioStreamPlayer2D.new()
	instance.stream = stream
	instance.volume_db = volume
	instance.pitch_scale = pitch
	instance.bus = bus_name
	instance.max_distance = default_distance
	instance.finished.connect(remove_node.bind(instance))
	add_child(instance)
	(instance as Node2D).global_position = position
	instance.play()

func play_sound_by_name(sound_name : String, position : Vector2, volume : float = 0, pitch : float = 1, bus_name : StringName = "Master"):
	var selected_sound : AudioStream = get_sound_by_name(sound_name)
	if (selected_sound != null):
		play_sound(selected_sound, position, volume, pitch, bus_name)

func get_sound_by_name(sound_name : String):
	for key in stream_dictonary.keys():
		if (key == sound_name):
			return stream_dictonary[key]
	push_error("Invalid stream name! ({str})".format({"str": sound_name}))
	return null

func get_sound_instance_by_name(sound_name : String, volume : float = 0, pitch : float = 1, bus_name : StringName = "Master"):
	var stream : AudioStream = get_sound_by_name(sound_name)
	if (stream != null):
		var instance = AudioStreamPlayer2D.new()
		instance.stream = stream
		instance.volume_db = volume
		instance.pitch_scale = pitch
		instance.bus = bus_name
		instance.max_distance = default_distance
		instance.finished.connect(remove_node.bind(instance))
		return instance
	return null

func remove_node(instance : AudioStreamPlayer2D):
	instance.queue_free()
