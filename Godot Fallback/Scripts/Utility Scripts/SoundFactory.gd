extends Node

@export var stream_list : Array[AudioStream]

var stream_dictonary : Dictionary

const path_prefix : String = "res://Sounds/"

const path_suffix : String = ".wav"

const default_distance : float = 1024

func _ready():
	for stream in stream_list:
		var stream_name = stream.resource_path.right(-path_prefix.length()).left(-path_suffix.length())
		stream_dictonary[stream_name] = stream

func clear_sounds():
	for child in get_children():
		if (child is AudioStreamPlayer2D):
			(child as AudioStreamPlayer2D).stop()
		child.queue_free()

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

func play_sound_by_name(sound_name : String, position : Vector2, volume : float = 0, pitch : float = 1, bus_name : StringName = "SFX"):
	var selected_sound : AudioStream = get_sound_by_name(sound_name)
	if (selected_sound != null):
		play_sound(selected_sound, position, volume, pitch, bus_name)

func get_sound_by_name(sound_name : String):
	for key in stream_dictonary.keys():
		if (key == sound_name):
			return stream_dictonary[key]
	push_error("Invalid stream name! ({str})".format({"str": sound_name}))
	return null

func get_sound_instance_by_name(sound_name : String, volume : float = 0, pitch : float = 1, bus_name : StringName = "SFX"):
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
