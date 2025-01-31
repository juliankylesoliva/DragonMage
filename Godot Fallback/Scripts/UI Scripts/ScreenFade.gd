extends ColorRect

class_name ScreenFade

@export var enable_fading_on_start : bool = true

@export var fade_from_black : bool = false

@export var starting_fade_duration : float = 1

@export var camera_offset : Vector2

var target_alpha : float = 1

var current_alpha : float = 1

var current_alpha_change_rate : float = 1

var enable_fading : bool = false

func _ready():
	set_enable_fading(enable_fading_on_start)
	do_start_fade_in()

func _process(delta):
	if (enable_fading and current_alpha != target_alpha):
		current_alpha = move_toward(current_alpha, target_alpha, delta * current_alpha_change_rate)
		color = Color(color, current_alpha)

func do_start_fade_in():
	target_alpha = 0
	current_alpha = (1 if fade_from_black else 0)
	current_alpha_change_rate = (1.0 / starting_fade_duration)
	color = Color(color, current_alpha)

func set_fade(alpha : float, rate : float, col : Color):
	target_alpha = alpha
	current_alpha_change_rate = (1.0 / rate)
	color = Color(col, current_alpha)

func set_enable_fading(b : bool):
	enable_fading = b
