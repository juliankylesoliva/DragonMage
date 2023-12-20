extends Node

class_name PlayerCamera

@export var hub : PlayerHub

@export var player_cam : Camera2D

@export var base_x_lookahead : float = 64

@export var max_x_lookahead : float = 192

@export var time_to_update_x : float = 0.25

@export var max_y_lookahead : float = 128

@export var fast_fall_y_lookahead : float = 256

@export var fast_fall_ground_distance_threshold : float = 320

@export var fire_tackle_y_lookahead : float = 128

@export var upper_camera_threshold : float = 128

@export var lower_camera_threshold : float = 0

@export var time_to_update_y : float = 0.25

var saved_y_position : float = 0

var was_upper_threshold_crossed : bool = false

var was_lower_threshold_crossed : bool = false

func _ready():
	saved_y_position = hub.char_body.global_position.y
	snap_camera_to_player()

func _physics_process(delta):
	if (hub.state_machine.current_state.can_update_camera_x_pos):
		update_x_lookahead(delta)
	if (hub.state_machine.current_state.can_update_camera_y_pos):
		update_y_lookahead(delta)

func update_x_lookahead(delta : float):
	var x_lookahead : float = (base_x_lookahead * (hub.char_body.velocity.x / hub.movement.top_speed))
	if (abs(x_lookahead) > max_x_lookahead):
		if (x_lookahead > 0):
			x_lookahead = max_x_lookahead
		else:
			x_lookahead = -max_x_lookahead
	
	var target_x : float = (hub.char_body.global_position.x + x_lookahead)
	player_cam.global_position.x = move_toward(player_cam.global_position.x, target_x, (abs(target_x - player_cam.global_position.x) / time_to_update_x) * delta)

func update_y_lookahead(delta : float):
	if (hub.char_body.is_on_floor() or !is_between_thresholds() or hub.jumping.is_fast_falling):
		var state_name : String = hub.state_machine.current_state.name
		if (hub.char_body.is_on_floor() or state_name == "WallSliding" or state_name == "WallClimbing" or state_name == "WallVaulting"):
			was_upper_threshold_crossed = false
			was_lower_threshold_crossed = false
		
		if ((hub.jumping.is_fast_falling and hub.collisions.get_distance_to_ground() > fast_fall_ground_distance_threshold) or (is_below_lower_threshold() and hub.char_body.velocity.y >= 0 and !was_lower_threshold_crossed)):
			saved_y_position = (hub.char_body.position.y + (fast_fall_y_lookahead if hub.jumping.is_fast_falling else max_y_lookahead))
			was_lower_threshold_crossed = true
		elif (!hub.jumping.is_fast_falling and is_above_upper_threshold() and hub.char_body.velocity.y <= 0 and !was_upper_threshold_crossed and !was_lower_threshold_crossed):
			saved_y_position = (hub.char_body.position.y - max_y_lookahead)
			was_upper_threshold_crossed = true
		if (!hub.jumping.is_fast_falling and (hub.char_body.is_on_floor() or !is_between_thresholds()) and was_upper_threshold_crossed and was_lower_threshold_crossed):
			saved_y_position = hub.char_body.position.y
			if ((is_above_upper_threshold() and hub.char_body.velocity.y <= 0) or (is_below_lower_threshold() and hub.char_body.velocity.y >= 0)):
				was_upper_threshold_crossed = false
				was_lower_threshold_crossed = false
		else:
			pass
	
	var target_y : float = saved_y_position
	player_cam.global_position.y = (move_toward(player_cam.global_position.y, target_y, (abs(target_y - player_cam.global_position.y) / time_to_update_y) * delta) if hub.char_body.is_on_floor() or player_cam.global_position.y != target_y else saved_y_position)

func fire_tackle_camera_update(delta : float, prev_x_velocity : float, vertical_axis : float):
	var x_lookahead : float = (base_x_lookahead * ((prev_x_velocity * hub.movement.get_facing_value()) / hub.movement.top_speed))
	if (abs(x_lookahead) > max_x_lookahead):
		if (x_lookahead > 0):
			x_lookahead = max_x_lookahead
		else:
			x_lookahead = -max_x_lookahead
	
	var target_x : float = (hub.char_body.global_position.x + x_lookahead)
	player_cam.global_position.x = (move_toward(player_cam.global_position.x, target_x, (abs(target_x - player_cam.global_position.x) / time_to_update_x) * delta) as int)
	
	var target_y : float = hub.char_body.global_position.y + (-fire_tackle_y_lookahead if vertical_axis > 0 else fire_tackle_y_lookahead if vertical_axis < 0 else 0.0)
	player_cam.global_position.y = ((move_toward(player_cam.global_position.y, target_y, (abs(target_y - player_cam.global_position.y) / time_to_update_y) * delta) as int))

func snap_camera_to_player():
	player_cam.global_position = hub.char_body.global_position

func is_above_upper_threshold():
	return (hub.char_body.global_position.y < (player_cam.get_screen_center_position().y - upper_camera_threshold))

func is_below_lower_threshold():
	return (hub.char_body.global_position.y > (player_cam.get_screen_center_position().y + lower_camera_threshold))

func is_between_thresholds():
	return (!is_above_upper_threshold() and !is_below_lower_threshold())
