extends Node

class_name PlayerCamera

@export var hub : PlayerHub

@export var player_cam : Camera2D

@export var screen_width : float = 512

@export var screen_height : float = 320

@export var base_x_lookahead : float = 64

@export var max_x_lookahead : float = 192

@export var max_y_lookahead : float = 128

@export var camera_height_from_ground : float = 96

@export var ground_level_update_height_threshold : float = 128

@export var fast_fall_y_lookahead : float = 256

@export var fast_fall_ground_distance_threshold : float = 320

@export var fire_tackle_y_lookahead : float = 128

@export var upper_camera_threshold : float = 128

@export var lower_camera_threshold : float = 0

@export var time_to_update_y : float = 0.25

@export var enable_camera_lock : bool = false

@export var locked_camera_move_speed : float = 192

var current_x_lookahead : float = 0

var saved_y_position : float = 0

var was_upper_threshold_crossed : bool = false

var was_lower_threshold_crossed : bool = false

var is_camera_locked : bool = false

func _ready():
	saved_y_position = hub.collisions.get_ground_point().y
	snap_camera_to_player()

func _physics_process(delta):
	check_camera_lock()
	if (!is_camera_locked):
		if (hub.state_machine.current_state.can_update_camera_x_pos):
			update_x_lookahead(delta)
		if (hub.state_machine.current_state.can_update_camera_y_pos):
			update_y_lookahead(delta)
	else:
		move_locked_camera(delta)

func update_x_lookahead(delta : float):
	if (player_cam == null):
		return
	if (is_camera_locked):
		return
	
	var target_direction : float = (hub.movement.get_facing_value() if hub.state_machine.current_state.name != "Gliding" else hub.get_input_vector().x)
	var max_lookahead : float = (max_x_lookahead if abs(hub.char_body.velocity.x) > hub.movement.top_speed else base_x_lookahead)
	current_x_lookahead = move_toward(current_x_lookahead, target_direction * max_lookahead, abs(hub.char_body.velocity.x) * delta)
	var target_x : float = (hub.char_body.global_position.x + current_x_lookahead)
	target_x = clamp_x_target(target_x)
	
	player_cam.global_position.x = target_x

func update_y_lookahead(delta : float):
	if (player_cam == null):
		return
	if (is_camera_locked):
		return
	
	var state_name : String = hub.state_machine.current_state.name
	if (hub.char_body.is_on_floor()):
		was_upper_threshold_crossed = false
		was_lower_threshold_crossed = false
	
	if ((hub.jumping.is_fast_falling and hub.collisions.get_distance_to_ground() > fast_fall_ground_distance_threshold) or (is_below_lower_threshold() and hub.char_body.velocity.y >= 0)):
		#saved_y_position = (hub.collisions.get_ground_point().y + (fast_fall_y_lookahead if hub.jumping.is_fast_falling else max_y_lookahead))
		was_lower_threshold_crossed = true
	elif (!hub.jumping.is_fast_falling and is_above_upper_threshold() and hub.char_body.velocity.y <= 0 and !was_upper_threshold_crossed and !was_lower_threshold_crossed):
		#saved_y_position = (hub.collisions.get_ground_point().y - max_y_lookahead)
		was_upper_threshold_crossed = true
	elif (!hub.jumping.is_fast_falling and ((hub.char_body.is_on_floor() and (abs(hub.collisions.get_ground_point().y - saved_y_position) >= ground_level_update_height_threshold or (hub.collisions.get_ground_point().y > saved_y_position))) or (is_above_upper_threshold() and (was_upper_threshold_crossed or was_lower_threshold_crossed)) or hub.collisions.get_ground_normal().x != 0)):
		saved_y_position = hub.collisions.get_ground_point().y
	else:
		pass
	
	if (was_upper_threshold_crossed or was_lower_threshold_crossed or state_name == "WallSliding" or state_name == "WallClimbing" or state_name == "WallVaulting"):
		saved_y_position = (hub.collisions.get_ground_point().y + clampf(hub.char_body.velocity.y, 0, min(hub.collisions.get_distance_to_ground() if state_name == "Falling" or state_name == "WallSliding" else fast_fall_y_lookahead if hub.jumping.is_fast_falling else max_y_lookahead, fast_fall_y_lookahead if hub.jumping.is_fast_falling else max_y_lookahead)))
	
	var target_y : float = (saved_y_position - camera_height_from_ground)
	target_y = clamp_y_target(target_y)
	
	player_cam.global_position.y = (move_toward(player_cam.global_position.y, target_y, (abs(target_y - player_cam.global_position.y) / time_to_update_y) * delta) if !hub.char_body.is_on_floor() or player_cam.global_position.y != target_y else target_y)

func fairy_guard_camera_update(delta : float):
	if (player_cam == null):
		return
	if (is_camera_locked):
		return
	
	current_x_lookahead = move_toward(current_x_lookahead, 0, hub.movement.top_speed * delta)
	
	var target_x : float = (hub.char_body.global_position.x + current_x_lookahead)
	target_x = clamp_x_target(target_x)
	player_cam.global_position.x = target_x

func fire_tackle_camera_update(delta : float, prev_x_velocity : float, vertical_axis : float):
	if (player_cam == null):
		return
	if (is_camera_locked):
		return
	
	current_x_lookahead = move_toward(current_x_lookahead, hub.movement.get_facing_value() * (max_x_lookahead if abs(prev_x_velocity) > hub.movement.top_speed else base_x_lookahead), max(hub.movement.top_speed, abs(prev_x_velocity)) * delta)
	
	var target_x : float = (hub.char_body.global_position.x + current_x_lookahead)
	target_x = clamp_x_target(target_x)
	player_cam.global_position.x = target_x
	
	var target_y : float = (hub.char_body.global_position.y if !hub.char_body.is_on_floor() else (saved_y_position - camera_height_from_ground)) + (-fire_tackle_y_lookahead if vertical_axis > 0 else fire_tackle_y_lookahead if vertical_axis < 0 else 0.0)
	target_y = clamp_y_target(target_y)
	player_cam.global_position.y = (move_toward(player_cam.global_position.y, target_y, (abs(target_y - player_cam.global_position.y) / time_to_update_y) * delta))

func wall_climb_horizontal_camera_update(delta : float, stored_speed : float, use_max_lookahead):
	if (player_cam == null):
		return
	if (is_camera_locked):
		return
	
	current_x_lookahead = move_toward(current_x_lookahead, hub.movement.get_facing_value() * (-1 if (hub.movement.get_facing_value() * hub.get_input_vector().x) <= 0 else 1) * (max_x_lookahead if use_max_lookahead else base_x_lookahead), stored_speed * delta)
	
	var target_x : float = (hub.char_body.global_position.x + current_x_lookahead)
	target_x = clamp_x_target(target_x)
	player_cam.global_position.x = target_x

func damaged_horizontal_camera_update(delta : float):
	if (player_cam == null):
		return
	if (is_camera_locked):
		return
	
	current_x_lookahead = move_toward(current_x_lookahead, 0, abs(hub.damage.horizontal_damage_knockback) * delta)
	
	var target_x : float = (hub.char_body.global_position.x + current_x_lookahead)
	target_x = clamp_x_target(target_x)
	player_cam.global_position.x = target_x

func clamp_x_target(x_pos : float):
	if (player_cam == null):
		return x_pos
	
	if (x_pos < (player_cam.limit_left + (screen_width / 2))):
		return (player_cam.limit_left + (screen_width / 2))
	elif (x_pos > (player_cam.limit_right - (screen_width / 2))):
		return (player_cam.limit_right - (screen_width / 2))
	else:
		return x_pos

func clamp_y_target(y_pos : float):
	if (player_cam == null):
		return y_pos
	
	if (y_pos < (player_cam.limit_top + (screen_height / 2))):
		return (player_cam.limit_top + (screen_height / 2))
	elif (y_pos > (player_cam.limit_bottom - (screen_height / 2))):
		return (player_cam.limit_bottom - (screen_height / 2))
	else:
		return y_pos

func snap_camera_to_player():
	if (player_cam == null):
		return
	
	player_cam.global_position.x = hub.char_body.global_position.x
	player_cam.global_position.x = clamp_x_target(player_cam.global_position.x)
	player_cam.global_position.y = (hub.collisions.get_ground_point().y - camera_height_from_ground)
	player_cam.global_position.y = clamp_y_target(player_cam.global_position.y)

func snap_camera_to_position(position : Vector2):
	if (player_cam == null):
		return
	
	player_cam.global_position.x = position.x
	player_cam.global_position.x = clamp_x_target(player_cam.global_position.x)
	player_cam.global_position.y = (position.y - camera_height_from_ground)
	player_cam.global_position.y = clamp_y_target(player_cam.global_position.y)

func reset_x_lookahead():
	current_x_lookahead = (hub.movement.get_facing_value() * base_x_lookahead)

func is_above_upper_threshold():
	if (player_cam == null):
		return false
	return (hub.char_body.global_position.y < (player_cam.get_screen_center_position().y - upper_camera_threshold))

func is_below_lower_threshold():
	if (player_cam == null):
		return false
	return (hub.char_body.global_position.y > (player_cam.get_screen_center_position().y + lower_camera_threshold))

func is_between_thresholds():
	return (!is_above_upper_threshold() and !is_below_lower_threshold())

func check_camera_lock():
	if (Input.is_action_just_pressed("Lock Camera")):
		is_camera_locked = !is_camera_locked

func move_locked_camera(delta : float):
	if (hub.is_deactivated):
		return
	var input_vector = Vector2.ZERO
	input_vector.x = ((1 if Input.is_action_pressed("Move Camera Right") else 0) - (1 if Input.is_action_pressed("Move Camera Left") else 0))
	input_vector.y = ((1 if Input.is_action_pressed("Move Camera Down") else 0) - (1 if Input.is_action_pressed("Move Camera Up") else 0))
	get_viewport().get_camera_2d().global_position += (locked_camera_move_speed * input_vector * delta)
