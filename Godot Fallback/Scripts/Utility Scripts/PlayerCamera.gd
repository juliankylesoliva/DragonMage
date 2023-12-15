extends Camera2D

class_name PlayerCamera

@export var hub : PlayerHub

@export var x_lookahead : float = 64

@export var max_x_lookahead : float = 192

@export var target_x_lookahead_delta_multiplier : float = 2

@export var rising_lookahead_threshold : float = 96

@export var falling_lookahead_threshold : float = 96

@export var max_y_lookahead : float = 128

@export var target_y_lookahead_delta_multiplier : float = 2

var last_ground_position : float = 0

var has_crossed_threshold : bool = false

func _ready():
	last_ground_position = hub.char_body.global_position.y

func _physics_process(delta):
	if (hub.state_machine.current_state.can_update_camera):
		update_lookahead(delta)

func update_lookahead(delta : float):
	var target_x : float = (x_lookahead * (hub.char_body.velocity.x / hub.movement.top_speed))
	if (abs(target_x) > max_x_lookahead):
		if (target_x > 0):
			target_x = max_x_lookahead
		else:
			target_x = -max_x_lookahead
	position.x = (move_toward(position.x, target_x, abs(target_x - position.x) * target_x_lookahead_delta_multiplier * delta) as int)
	
	if (hub.char_body.is_on_floor()):
		has_crossed_threshold = false
		last_ground_position = hub.char_body.global_position.y
	
	var target_y : float = (position.y if has_crossed_threshold or hub.char_body.is_on_floor() else -max_y_lookahead if is_above_rising_threshold() else max_y_lookahead if is_below_falling_threshold() else last_ground_position - hub.char_body.global_position.y)
	
	if (!hub.char_body.is_on_floor() and !has_crossed_threshold and (is_above_rising_threshold() or is_below_falling_threshold())):
		has_crossed_threshold = true
	
	position.y = (target_y as int if hub.char_body.is_on_floor() or !has_crossed_threshold else (move_toward(position.y, target_y, abs(target_y - position.y) * target_y_lookahead_delta_multiplier * delta) as int))

func is_above_rising_threshold():
	return (hub.char_body.global_position.y < (get_screen_center_position().y - rising_lookahead_threshold))

func is_below_falling_threshold():
	return (hub.char_body.global_position.y > (get_screen_center_position().y + falling_lookahead_threshold))

func is_between_thresholds():
	return (!is_above_rising_threshold() and !is_below_falling_threshold())
