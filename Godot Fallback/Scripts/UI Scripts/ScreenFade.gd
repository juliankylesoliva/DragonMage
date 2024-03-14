extends ColorRect

class_name ScreenFade

@export var fade_from_black : bool = false

@export var starting_fade_duration : float = 1

@export var camera_offset : Vector2

var target_alpha : float = 1

var current_alpha : float = 1

var current_alpha_change_rate : float = 1

func _ready():
	target_alpha = 0
	current_alpha = (1 if fade_from_black else 0)
	current_alpha_change_rate = (1.0 / starting_fade_duration)
	color = Color(color, current_alpha)

func _process(delta):
	uniform_process(delta)

func _physics_process(delta):
	uniform_process(delta)

func uniform_process(delta):
	global_position = (get_viewport().get_camera_2d().global_position + camera_offset)
	if (current_alpha != target_alpha):
		current_alpha = move_toward(current_alpha, target_alpha, delta * current_alpha_change_rate)
		color = Color(color, current_alpha)

func set_fade(alpha : float, rate : float, col : Color):
	target_alpha = alpha
	current_alpha_change_rate = (1.0 / rate)
	color = col
