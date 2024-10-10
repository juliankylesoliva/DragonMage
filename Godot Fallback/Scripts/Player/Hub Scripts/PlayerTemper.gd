extends Node

class_name PlayerTemper

@export var hub : PlayerHub

@export_range(3, 13) var total_segments : int = 13

@export var min_segments : int = 3

@export var max_segments : int = 13

@export var cold_segments : int = 3

@export var hot_segments : int = 3

@export var temper_rebound_interval : float = 3

var current_temper_level : int = 0

var cold_threshold : int = 0

var hot_threshold : int = 0

var min_temper_level : int = 1

var current_temper_rebound_timer = 0

func _ready():
	validate_parameters()

func _process(delta):
	check_temper_rebound(delta)

func check_temper_rebound(delta : float):
	if (current_temper_rebound_timer > 0 and is_form_locked()):
		current_temper_rebound_timer = move_toward(current_temper_rebound_timer, 0, delta)
		if (current_temper_rebound_timer <= 0):
			if (current_temper_level < cold_threshold):
				neutralize_temper_by(1)
			else:
				neutralize_temper_by(-1)
			
			if (is_form_locked()):
				current_temper_rebound_timer = temper_rebound_interval
	else:
		current_temper_rebound_timer = 0

func activate_temper_rebound_timer():
	current_temper_rebound_timer = temper_rebound_interval

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
	
	set_starting_temper_level()

func set_starting_temper_level():
	current_temper_level = get_warm_midpoint()

func set_boss_courtesy_temper_level():
	if (is_forcing_form_change() or is_form_locked()):
		current_temper_level = (get_min_warm_threshold() if current_temper_level <= cold_threshold else get_max_warm_threshold() if current_temper_level >= hot_threshold else current_temper_level)

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

func set_temper_level(num : int):
	current_temper_level = clampi(num, min_temper_level, total_segments)

func form_lock_temper_change():
	if (current_temper_level >= hot_threshold):
		current_temper_level = total_segments
	elif (current_temper_level <= cold_threshold):
		current_temper_level = min_temper_level
	else:
		pass

func get_min_warm_threshold():
	return (cold_threshold + 1)

func get_max_warm_threshold():
	return (hot_threshold - 1)

func get_warm_midpoint():
	return (((get_min_warm_threshold() + get_max_warm_threshold()) / 2.0) as int)
