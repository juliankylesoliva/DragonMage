extends Node

class_name PlayerTemper

@export var hub : PlayerHub

@export_range(3, 12) var total_segments : int = 12

@export var min_segments : int = 3

@export var max_segments : int = 12

@export var cold_segments : int = 3

@export var hot_segments : int = 3

var current_temper_level : int = 0

var cold_threshold : int = 0

var hot_threshold : int = 0

var min_temper_level : int = 1

func _ready():
	validate_parameters()

func is_form_locked():
	return ((hub.form.is_a_mage() and current_temper_level <= cold_threshold) or (hub.form.is_a_dragon() and current_temper_level >= hot_threshold))

func is_forcing_form_change():
	return ((hub.form.is_a_mage() and current_temper_level >= hot_threshold) or (hub.form.is_a_dragon() and current_temper_level <= cold_threshold))

func validate_parameters():
	if (total_segments < min_segments):
		total_segments = min_segments
	elif (total_segments > max_segments):
		total_segments = max_segments
	else:
		pass
	
	while ((cold_segments + hot_segments) >= total_segments):
		if (cold_segments >= hot_segments):
			cold_segments -= 1
		else:
			hot_segments -= 1
	
	cold_threshold = cold_segments
	hot_threshold = (total_segments - (hot_segments - 1))
	
	current_temper_level = ((cold_threshold + 1) if hub.form.is_a_mage() else (hot_threshold - 1))

func neutralize_temper_by(num : int):
	current_temper_level += num
	
	if (num < 0 and current_temper_level <= cold_threshold):
		current_temper_level = (cold_threshold + 1)
	elif (num > 0 and current_temper_level >= hot_threshold):
		current_temper_level = (hot_threshold - 1)
	else:
		pass

func change_temper_by(num : int):
	current_temper_level += num
	
	if (current_temper_level < min_temper_level):
		current_temper_level = min_temper_level
	elif (current_temper_level > total_segments):
		current_temper_level = total_segments
	else:
		pass

func form_lock_temper_change():
	if (current_temper_level >= hot_threshold):
		current_temper_level = total_segments
	elif (current_temper_level <= cold_threshold):
		current_temper_level = min_temper_level
	else:
		pass
