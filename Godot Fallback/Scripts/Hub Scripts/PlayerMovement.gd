extends Node

class_name PlayerMovement

@export var hub : PlayerHub

@export var can_change_facing_direction_in_midair : bool = true
@export var acceleration : float = 25
@export var deceleration : float = 20
@export var top_speed : float = 5.25
@export var turning_speed : float = 45

@export var is_facing_right : bool = true

var current_horizontal_velocity : float = 0

func update_facing_direction():
	set_facing_direction(hub.get_input_vector().x)
	pass

func set_facing_direction(horizontal_axis : float):
	if (horizontal_axis > 0):
		is_facing_right = true
		hub.char_sprite.flip_h = false
	elif (horizontal_axis < 0):
		is_facing_right = false
		hub.char_sprite.flip_h = true
	else:
		pass

func get_facing_value():
	return (1 if is_facing_right else -1)

func is_turning():
	var horizontal_axis = hub.get_input_vector().x
	return (horizontal_axis * current_horizontal_velocity < 0)

func is_running_into_a_wall():
	return (hub.char_body.is_on_wall() and !is_turning() and hub.char_body.velocity.x == 0)

func do_movement(delta):
	var horizontal_axis = hub.get_input_vector().x
	
	if (is_running_into_a_wall()):
		current_horizontal_velocity = 0
	elif (horizontal_axis != 0):
		var accel_delta = (acceleration if !is_turning() else turning_speed)
		current_horizontal_velocity = move_toward(current_horizontal_velocity, top_speed * horizontal_axis, accel_delta * delta)
	else:
		current_horizontal_velocity = move_toward(current_horizontal_velocity, 0, deceleration * delta)
	
	hub.char_body.velocity.x = current_horizontal_velocity
	hub.char_body.move_and_slide()

func get_speed_portion(clamped : bool = true):
	var ret_val = abs(hub.char_body.velocity.x / top_speed)
	return (min(1, ret_val) if clamped else ret_val)
